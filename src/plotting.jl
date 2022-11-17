using RecipesBase

@recipe function f(lattice::Lattice)
    yflip --> true  # Set the origin to the upper left corner, see https://github.com/MakieOrg/Makie.jl/issues/46
    xlims --> extrema(axes(lattice, 1))
    ylims --> extrema(axes(lattice, 2))
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
    return axes(lattice)..., lattice
end
