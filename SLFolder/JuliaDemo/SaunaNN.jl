using Lux, Random, Optimisers, Zygote, Statistics, Printf # Required packages

# ------------------------------------------------------------
# Step 0: Construct the dataset
# ------------------------------------------------------------

rng = Xoshiro(42) # Random number generator
n = 200 # Number of data points

# Generate inputs
sauna_temp   = 60.0f0 .+ 40.0f0 .* rand(rng, Float32, n)
outside_temp = -30.0f0 .+ 40.0f0 .* rand(rng, Float32, n)
coffee_min   = 5.0f0 .+ 115.0f0 .* rand(rng, Float32, n)

# Define a 'true' equation for the neural network to learn
sweet_spot = exp.(-(((sauna_temp .- 80.0f0) ./ 10.0f0) .^ 2))
contrast   = 0.3f0 .* (1.0f0 .- (outside_temp .+ 30.0f0) ./ 40.0f0) # Colder temperatures outside > higher enjoyment
coffee_pen = -0.2f0 .* clamp.((coffee_min .- 60.0f0) ./ 60.0f0, 0.0f0, 1.0f0) # Penalty if coffee was more than 60 mins ago
noise      = 0.08f0 .* randn(rng, Float32, n) # Gaussian noise to prevent NN from overfitting

raw_score = sweet_spot .+ contrast .+ coffee_pen .+ noise # Final enjoyment score
score = clamp.(raw_score, 0.0f0, 1.0f0) # Clamp score between 0 and 1

# Write to text file
open("sauna_log.txt", "w") do f
    write(f, "sauna_temp,outside_temp,coffee_min,score\n")
    for i in 1:n
        @printf(f, "%.1f,%.1f,%.1f,%.4f\n",
            sauna_temp[i], outside_temp[i], coffee_min[i], score[i])
    end
end

# ------------------------------------------------------------
# 5.1.1 Step 1: Load and prepare the data
# ------------------------------------------------------------

# Open text file and read it
lines = readlines("sauna_log.txt")
data = reduce(hcat, [parse.(Float32, split(l, ",")) for l in lines[2:end]]) # Convert text to numbers and add to a matrix

X_raw = data[1:3, :] # Input data
Y     = data[4:4, :] # Output score

# Normalize inputs to zero mean and unit variance for faster NN learning
mu  = mean(X_raw, dims = 2)
sig = std(X_raw, dims = 2)
X   = (X_raw .- mu) ./ sig # mean of 0 and std of 1 for each feature

# Split to train and test (80/20)
rng = Xoshiro(123)
n_train = Int(round(0.8 * size(X, 2)))
idx = randperm(rng, size(X, 2))

X_train = X[:, idx[1:n_train]]
Y_train = Y[:, idx[1:n_train]]
X_test  = X[:, idx[n_train+1:end]]
Y_test  = Y[:, idx[n_train+1:end]]

@printf "Train: %d  Test: %d\n" size(X_train, 2) size(X_test, 2)

# ------------------------------------------------------------
# 5.1.2 Step 2: Build the model
# ------------------------------------------------------------

model = Chain(
    Dense(3 => 8, tanh), # 3 inputs > 8 outputs
    Dense(8 => 1) # 8 inputs > 1 output
)

# Initialize model parameters and state
ps, st = Lux.setup(rng, model)

# Loss function (mean squared error)
function mse_loss(model, ps, st, data)
    x, y_true = data
    y_pred, st_new = model(x, ps, st) # Forward pass: feed input to NN
    loss = mean((y_pred .- y_true) .^ 2) # MSE loss
    return loss, st_new, ()
end

# ------------------------------------------------------------
# 5.1.3 Step 3: Train
# ------------------------------------------------------------

opt = Adam(0.01f0) # Adam optimiser adjusts parameters
# Epochs: model iterations
# Lerning rate (lr): weight updates
function train_model(model, ps, st, data; epochs = 500, lr = 0.01f0)
    tstate = Training.TrainState(model, ps, st, Adam(lr)) # State of the model training
    for epoch in 1:epochs
        _, loss, _, tstate = Training.single_train_step!( # Training step
            AutoZygote(), mse_loss, data, tstate
        )
        if epoch == 1 || epoch % 100 == 0 # Print progress
            @printf "Epoch %4d  MSE = %.6f\n" epoch loss
        end
    end
    return tstate
end

tstate = train_model(model, ps, st, (X_train, Y_train)) # Trained parameters

# Evaluate on test data
Y_pred_test, _ = model(X_test, tstate.parameters, tstate.states)
test_mse = mean((Y_pred_test .- Y_test) .^ 2) # Test error
test_mae = mean(abs.(Y_pred_test .- Y_test)) # Average absolute error

# Model baseline, used to determine if model is learning well
baseline = fill(mean(Y_train), size(Y_test))
baseline_mae = mean(abs.(baseline .- Y_test))

@printf "Test MSE: %.6f  Test MAE: %.4f\n" test_mse test_mae
@printf "Baseline MAE (predict mean): %.4f\n" baseline_mae

# ------------------------------------------------------------
# 5.1.4 Step 4: Predict
# ------------------------------------------------------------

scenarios = [
    (sauna=80, outside=-20, coffee=10, label="Perfect: 80°C, -20°C, fresh coffee"),
    (sauna=65, outside=5,   coffee=100, label="Poor: lukewarm, mild, stale coffee"),
    (sauna=95, outside=-25, coffee=30, label="Extreme: 95°C, deep winter"),
]

function predict_score(s, model, ps, st, mu, sig)
    x = Float32.([(s.sauna - mu[1]) / sig[1], # Normalize input data
                  (s.outside - mu[2]) / sig[2],
                  (s.coffee - mu[3]) / sig[3]])
    pred, _ = model(reshape(x, 3, 1), ps, st) # Apply trained model
    return pred[1]
end
# Predicted enjoyment score for each scenario
for s in scenarios
    sc = predict_score(s, model, tstate.parameters, tstate.states, mu, sig)
    @printf "%-35s %.2f\n" s.label sc
end