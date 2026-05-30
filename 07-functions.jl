function geothermal_temperature(Tₛ, ∇T, z)
    z_km = z / 1000   # depth converted to kilometers
    return Tₛ + ∇T * z_km
end

T = geothermal_temperature(15.0, 25.0, 1800.0)   # estimated temperature in C

println("Estimated temperature at 1800 m: ", round(T, digits = 1), " C")
