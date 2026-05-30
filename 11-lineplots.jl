using Plots

depth_km = [0, 1, 2, 3, 4]
temperature_C = [15, 38, 61, 84, 107]

line_plot = plot(
    depth_km,
    temperature_C,
    linewidth = 3,
    marker = :circle,
    markersize = 6,
    xlabel = "Depth (km)",
    ylabel = "Temperature (C)",
    title = "Geothermal gradient",
    legend = false
)


display(line_plot)

#plots_dir = joinpath(@__DIR__, "plots")
#mkpath(plots_dir)
#output_path = joinpath(plots_dir, "11-lineplots.png");
#savefig(line_plot, output_path);
