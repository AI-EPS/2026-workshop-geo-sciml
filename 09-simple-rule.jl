sample_names = ["A", "B", "C", "D"]   # sample labels
SiO₂ = [62.1, 49.5, 71.3, 55.2]             # silica percentage for each sample

for i in eachindex(sample_names)
    label = SiO₂[i] > 60 ? "felsic" : "mafic/intermediate"   # simple rock class rule
    println("Sample ", sample_names[i], " is classified as ", label)
end 