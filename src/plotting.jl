using RecipesBase

@recipe function f(lattice::Lattice)
    yflip --> true  # Set the origin to the upper left corner, see https://github.com/MakieOrg/Makie.jl/issues/46
    xlims --> extrema(axes(lattice, 1)) .+ (-0.5, 0.5)  # See https://discourse.julialang.org/t/can-plots-jl-heatmap-coordinates-start-at-1-instead-of-0-5/90385/3
    ylims --> extrema(axes(lattice, 2)) .+ (-0.5, 0.5)
    xguide --> "x"
    xguideposition --> :top  # Place xguide along top axis
    xmirror --> true  # Place xticks along top axis, see https://github.com/JuliaPlots/Plots.jl/issues/337
    yguide --> "y"
    guidefontsize --> 8
    tickfontsize --> 6
    color --> :binary
    colorbar --> false
    frame --> :box
    aspect_ratio --> :equal
    margins --> (0, :mm)  # See https://github.com/JuliaPlots/Plots.jl/issues/4522#issuecomment-1318511879
    return axes(lattice)..., lattice
end
