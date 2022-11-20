using RecipesBase

export magplot

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

@userplot MagPlot
@recipe function f(plot::MagPlot)
    # See http://juliaplots.org/RecipesBase.jl/stable/types/#User-Recipes-2
    magnetization = plot.args[end]  # Extract `magnetization` from the args
    # If we are passed two args, use the first as indices.
    steps = length(plot.args) == 2 ? plot.args[1] : eachindex(magnetization)
    size --> (800, 500)
    seriestype --> :scatter
    markersize --> 2
    markerstrokewidth --> 0
    xlims --> extrema(steps)
    ylims --> extrema(magnetization)
    xguide --> "steps (after thermalization)"
    yguide --> "magnetization"
    label --> "total"
    fontfamily --> "Palatino"
    guidefontsize --> 12
    tickfontsize --> 10
    legendfontsize --> 12
    legend_foreground_color --> nothing
    legend_position --> :right
    frame --> :box
    palette --> :tab10
    grid --> nothing
    _zero = zero(eltype(magnetization))
    @series begin
        label := "spin up"
        x := findall(>(_zero), magnetization)
        y := magnetization[magnetization .<= 0]
    end
    @series begin
        label := "spin down"
        x := findall(<=(_zero), magnetization)
        y := magnetization[magnetization .> 0]
    end
    return steps, magnetization
end
