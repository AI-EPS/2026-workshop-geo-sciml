# Notes:
# - In machine learning, training data usually comes in pairs: an input x and a label or target y.
# - Sometimes x and y are vectors, sometimes they are matrices, and sometimes x is a tensor such as an RGB image.
# - A vector is a 1D list of numbers.
# - A matrix is a 2D table of numbers.
# - A grayscale image can be stored as a matrix, but an RGB image needs a tensor because each pixel has red, green, and blue values.
# - In a batch of images, we often add one more dimension for the image number, so the image data becomes 4D.
# - For example, a size like (2, 2, 3, 1) can mean height, width, RGB channel, and image number 1 in the batch.
# - Labels can also be stored as vectors or matrices, depending on the task.

x_vector = [18.2, 101.3, 0.24]
y_vector = [0.81, 0.12]

# println(x_vector)
# println(y_vector)

X_matrix = [
    18.2 101.3 0.24
    20.1  98.7 0.31
    16.9 105.5 0.19
]
y_batch = [0.81, 0.65, 0.92]

# println(X_matrix)
# println(y_batch)

sample_rgb_path = joinpath("data", "sample_rgb.txt")
x_image = reshape(parse.(Float64, split(read(sample_rgb_path, String))) ./ 255, 2, 2, 3, 1)

y_label = [1.0, 0.0]

# println(x_image)
# println(y_label)

println("training pair: ", size(x_vector), " ------> ", size(y_vector))
println("training pair: ", size(X_matrix), " ------> ", size(y_batch))
println("training pair: ", size(x_image), " ------> ", size(y_label))
