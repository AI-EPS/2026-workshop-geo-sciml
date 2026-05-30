# Learning goal: Real work often involves several values that belong together.

sample_names = ["A", "B", "C", "D"]   # sample labels
SiO₂ = [62.1, 49.5, 71.3, 55.2]             # silica percentage for each sample
Fe = [5.4, 9.8, 2.1, 7.0]                   # iron percentage for each sample

for i in eachindex(sample_names)
    println(
        "Sample ",
        sample_names[i],
        ": SiO2=", SiO₂[i], "%",
        ", Fe=", Fe[i], "%"
    )
end