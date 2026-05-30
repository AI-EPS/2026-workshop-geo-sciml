# Mathematical symbols can also be used in Julia variable names.
# Try names like \theta<Tab>, \sigma<Tab>, or \lambda<Tab> in the editor.
# Learning goal: Sometimes math symbols make an equation easier to read.



θ = 35      # slope angle in degrees
σ = 12.4    # effective stress in MPa
λ = 0.08    # decay factor
ϕ = 0.22    # porosity fraction
Δz = 150    # depth change in meters





stability_index = (θ + σ) * (1 - λ) + (ϕ * Δz)




println("Slope angle (degrees) = ", θ)
println("Effective stress (MPa) = ", σ)
println("Decay factor = ", λ)
println("Porosity fraction = ", ϕ)
println("Depth change (m) = ", Δz)
println("Stability index = ", round(stability_index, digits = 2))




# Plain-text style:
# stability_index = (theta_deg + sigma_mpa) * (1 - lambda_decay) + (phi_porosity * delta_z_m)
#
# Symbol style:
# stability_index = (θ + σ) * (1 - λ) + (ϕ * Δz)