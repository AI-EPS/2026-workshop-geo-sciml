# Learning goal: If we have many measurements, it helps to keep them together.
# With an array, we can keep many values together, count them, pick one value out, look at part of the array, and summarize them.
# Julia starts indexing at 1, so the first element is d[1]. (same as MATLAB)
# In Python, indexing starts at 0, so the first element would be d[0].





d = [0.120, 0.180, 0.220, 0.160, 0.200, 0.140, 0.190, 0.210]   # grain size measurements in mm
μ = sum(d) / length(d)                                         # average grain size in mm

println("Measurements: ", d)
println("Number of measurements: ", length(d))
println("First measurement: ", d[1], " mm")
println("Third measurement: ", d[3], " mm")
println("Measurements 3 to 5: ", d[3:5], " mm")
println("Last measurement: ", d[end], " mm")
println("Average grain size: ", μ, " mm")
println("Average grain size rounded: ", round(μ, digits = 3), " mm")