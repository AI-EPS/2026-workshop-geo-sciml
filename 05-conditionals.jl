ϕ = 0.18   # porosity fraction

if ϕ >= 0.2
    println("This sample has relatively high porosity.")
elseif ϕ >= 0.1
    println("This sample has moderate porosity.")
else
    println("This sample has low porosity.")
end