# Learning goal: If we need to do something many times, it is better to use a loop.

rock_samples = ["granite", "basalt", "limestone", "shale"]   # rock names to inspect

for rock in rock_samples
    println("Observed rock: ", rock)
end 