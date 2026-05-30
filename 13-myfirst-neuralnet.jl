# If these packages are not installed yet, start Julia in this folder with:
# julia --project=.
# Then enter Pkg mode with ] and run:
# add CSV DataFrames Lux Optimisers Zygote Statistics Random
# Printf is a Julia standard library, so it does not need to be added.

using CSV
using DataFrames
using Lux
using Random
using Optimisers
using Zygote
using Statistics
using Printf


# Problem description:
# We want to train a small neural network that predicts sauna enjoyment score
# from three inputs: sauna temperature, outside temperature, and how many
# minutes ago the coffee was brewed.
#
# The goal is to learn the relationship from example data and then use the
# trained model to score a few Finnish sauna scenarios.


#▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
#--- STEP 1: read and prepare the data --------
#▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
# We already have example sauna data in a text file, so the first job is to
# load it into Julia and turn it into numeric arrays the network can use.
sauna_path = joinpath(@__DIR__, "data", "sauna_log.txt")
sauna_log = CSV.read(sauna_path, DataFrame)

# Convert the table into a numeric matrix.
# Rows 1:3 will be inputs and row 4 will be the target score.
feature_table = Matrix(sauna_log[:, [:sauna_temp, :outside_temp, :coffee_min, :score]])
data = Float32.(permutedims(feature_table))

input_data_raw = data[1:3, :]                                            # Input data
target_scores = data[4:4, :]                                              # Output score

# We normalize the inputs because the three features live on very different
# scales. This makes training more stable and helps gradient-based updates.
feature_mean = mean(input_data_raw, dims = 2)
feature_std = std(input_data_raw, dims = 2)
input_data = (input_data_raw .- feature_mean) ./ feature_std              # mean of 0 and std of 1 for each feature

# Split to train and test (80/20).
# The model learns only from the training split. The test split is kept aside
# and used only at the end to measure performance on unseen data.
rng = Xoshiro(123)
n_train = Int(round(0.8 * size(input_data, 2)))
shuffled_indices = randperm(rng, size(input_data, 2))

X_train = input_data[:, shuffled_indices[1:n_train]]
Y_train = target_scores[:, shuffled_indices[1:n_train]]
X_test = input_data[:, shuffled_indices[n_train + 1:end]]
Y_test = target_scores[:, shuffled_indices[n_train + 1:end]]

@printf "Train: %d  Test: %d\n" size(X_train, 2) size(X_test, 2)


#▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
#--- STEP 2: build the model --------
#▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
# Now we define a very small neural network. It takes 3 inputs, transforms
# them through a hidden layer, and returns 1 predicted enjoyment score.
# The final sigmoid keeps the prediction in the 0 to 1 range.
#
#   Inputs              Hidden layer               Output
#
#   sauna temp    o ----\
#                      o --\
#   outside temp  o -----)--- o  o  o  o  o  o  o  o ----> o   predicted score
#                      o --/
#   coffee age    o ----/
#
#   3 features        Dense(3 => 8, tanh)      Dense(8 => 1, sigmoid)



model = Chain(
    Dense(3 => 8, tanh),                                               # 3 inputs > 8 outputs


    Dense(8 => 1, sigmoid)                                             # 8 inputs > 1 output in [0, 1]
)




# Initialize model parameters and state
parameters, model_state = Lux.setup(rng, model)







# This function takes a batch of inputs and target scores, runs the network,
# and returns the mean squared error. Training will try to make this smaller.
function mse_loss(model, parameters, model_state, batch)
    x, y_true = batch
    y_pred, new_model_state = model(x, parameters, model_state)          # Forward pass: feed input to NN
    loss = mean((y_pred .- y_true) .^ 2)                                 # MSE loss
    return loss, new_model_state, ()
end
















#▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
#--- STEP 3: train --------
#▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
# This function takes the network, its parameters, and the training data,
# then repeatedly updates the parameters to reduce prediction error.
# Epochs = how many times we loop over the training data.
# Learning rate = how large each parameter update should be.
function train_model(model, parameters, model_state, train_batch; epochs = 500, lr = 0.01f0)
    train_state = Training.TrainState(model, parameters, model_state, Adam(lr))   # State of the model training
    for epoch in 1:epochs


        _, loss, _, train_state = Training.single_train_step!(AutoZygote(), mse_loss, train_batch, train_state)           # Training step
        @printf "Epoch %4d  Training loss = %.6f\n" epoch loss
    end
    return train_state
end





# Train only on the training split. We will use the test split afterwards.


train_state = train_model(model, parameters, model_state, (X_train, Y_train))   # Trained parameters

# After training, run the model once on the held-out data to get a final test
# error that summarizes how well it predicts unseen examples.
Y_pred_test, _ = model(X_test, train_state.parameters, train_state.states)
test_mse = mean((Y_pred_test .- Y_test) .^ 2)                            # Test error
test_mae = mean(abs.(Y_pred_test .- Y_test))                             # Average absolute error

@printf "Test MSE: %.6f  Test MAE: %.4f\n" test_mse test_mae






#▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
#--- STEP 4: predict --------
#▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰
# Finally, try a few hand-picked sauna situations and see what score the
# trained network gives to each one.
scenarios = [
    (sauna = 80, outside = -20, coffee = 10),
    (sauna = 65, outside = 5, coffee = 100),
    (sauna = 95, outside = -25, coffee = 30)
]





# This function takes one scenario, normalizes it the same way as the training
# data, feeds it through the trained network, and returns one predicted score.
function predict_score(s, model, parameters, model_state, feature_mean, feature_std)
    x = Float32.([(s.sauna - feature_mean[1]) / feature_std[1], (s.outside - feature_mean[2]) / feature_std[2], (s.coffee - feature_mean[3]) / feature_std[3]])   # Normalize input data
    pred, _ = model(reshape(x, 3, 1), parameters, model_state)            # Apply trained model
    return pred[1]
end





# Predicted enjoyment score for each scenario
for scenario in scenarios
    predicted_score = predict_score(scenario, model, train_state.parameters, train_state.states, feature_mean, feature_std)
    @printf "Scenario: sauna=%dC outside=%dC coffee=%dmin\n" scenario.sauna scenario.outside scenario.coffee
    @printf "Predicted score: %.2f\n\n" predicted_score
end