# If these packages are not installed yet, start Julia in this folder with:
# julia --project=.
# Then enter Pkg mode with ] and run:
# add CSV DataFrames

using CSV
using DataFrames

sauna_path = joinpath(@__DIR__, "data", "sauna_log.txt")
sauna_log = CSV.read(sauna_path, DataFrame)

println("Columns: ", names(sauna_log))
println("Size: ", size(sauna_log))
println()
println("First 8 rows:")
show(stdout, MIME("text/plain"), first(sauna_log, 20))
println()
