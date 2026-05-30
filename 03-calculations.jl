# To type subscripts and superscripts in Julia/VS Code, use Unicode tab completion.
# Examples: \_1<Tab> gives ₁, \_2<Tab> gives ₂, \^2<Tab> gives ², and z\bar<Tab> gives z̄.

z₁ = 120.0          # top depth in meters
z₂ = 138.5          # bottom depth in meters
Δz = z₂ - z₁        # layer thickness in meters
z̄ = (z₁ + z₂) / 2   # average depth in meters
w = 25.0            # outcrop width in meters
A = Δz * w          # cross-sectional area in square meters


println("Thickness: ", Δz, " m")
println("Average depth: ", z̄, " m")
println("Area: ", A, " m^2")