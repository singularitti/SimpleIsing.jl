using RecipesBase

export magplot, paramplot, corplot

@recipe function f(lattice::Lattice)
    size --> (600, 600)
    yflip --> true  # Set the origin to the upper left corner, see https://github.com/MakieOrg/Makie.jl/issues/46
    xlims --> extrema(axes(lattice, 1)) .+ (-0.5, 0.5)  # See https://discourse.julialang.org/t/can-plots-jl-heatmap-coordinates-start-at-1-instead-of-0-5/90385/3
    ylims --> extrema(axes(lattice, 2)) .+ (-0.5, 0.5)
    xguide --> raw"$x$"
    xguideposition --> :top  # Place xguide along top axis
    xmirror --> true  # Place xticks along top axis, see https://github.com/JuliaPlots/Plots.jl/issues/337
    yguide --> raw"$y$"
    tick_direction --> :out
    guidefontsize --> 10
    tickfontsize --> 8
    legendfontsize --> 8
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
    trace = plot.args[end]  # Extract trace from the args
    # If we are passed two args, we use the first as labels
    steps = length(plot.args) == 2 ? plot.args[1] : eachindex(trace)
    size --> (700, 400)
    markersize --> 2
    markerstrokecolor --> :auto
    markerstrokewidth --> 0
    xlims --> extrema(steps)
    xguide --> raw"$N$ (steps)"
    yguide --> raw"$M$ (magnetization)"
    guidefontsize --> 10
    tickfontsize --> 8
    legendfontsize --> 8
    legend_foreground_color --> nothing
    legend_position --> :bottomright
    frame --> :box
    palette --> :tab20
    grid --> nothing
    𝐌 = map(magnetization, trace)
    𝟘 = zero(eltype(𝐌))
    f = step -> minimum(steps) <= step <= maximum(steps)
    up_steps, down_steps = filter(f, findall(>(𝟘), 𝐌)), filter(f, findall(<(𝟘), 𝐌))
    for (selected_steps, label) in zip((up_steps, down_steps), ("spin up", "spin down"))
        if !isempty(selected_steps)
            average = mean(𝐌[selected_steps])
            @series begin
                seriestype --> :scatter
                label --> label * ", average = " * string(average)[1:5]
                selected_steps, 𝐌[selected_steps]
            end
            @series begin
                seriestype --> :hline
                z_order --> :back
                label --> ""
                Base.vect(average)
            end
        end
    end
end

@userplot ParamPlot
@recipe function f(plot::ParamPlot)
    # See http://juliaplots.org/RecipesBase.jl/stable/types/#User-Recipes-2
    𝐉, 𝐛 = plot.args  # Extract `𝐉` and `𝐛` from the args
    size --> (700, 400)
    markersize --> 2
    markerstrokecolor --> :auto
    markerstrokewidth --> 0
    xlims --> extrema(𝐉)
    ylims --> extrema(𝐛)
    xguide --> raw"$J = \bar{J} / k_B T$"
    yguide --> raw"$b$ (parameter)"
    guidefontsize --> 10
    tickfontsize --> 8
    legend --> :none
    frame --> :box
    palette --> :tab20
    grid --> nothing
    for type in (:scatter, :path)
        @series begin
            seriestype --> type
            𝐉, 𝐛
        end
    end
end

@userplot CorPlot
@recipe function f(plot::CorPlot)
    # See http://juliaplots.org/RecipesBase.jl/stable/types/#User-Recipes-2
    𝐳, 𝐟 = plot.args  # Extract `𝐳` and `𝐟` from the args
    size --> (700, 400)
    markersize --> 2
    markerstrokecolor --> :auto
    markerstrokewidth --> 0
    xlims --> extrema(𝐳)
    xguide --> raw"$z$"
    yguide --> raw"$\langle \Sigma(z) \rangle = a \left(\exp(-z/b) + \exp(-(N-z)/b)\right)$"
    guidefontsize --> 10
    tickfontsize --> 8
    legendfontsize --> 8
    legend_foreground_color --> nothing
    legend_position --> :topright
    frame --> :box
    palette --> :tab20
    grid --> nothing
    return 𝐳, 𝐟
end
