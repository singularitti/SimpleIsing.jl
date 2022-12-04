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
    size --> (700, 400)
    seriestype --> :scatter
    markersize --> 2
    markerstrokecolor --> :auto
    markerstrokewidth --> 0
    xguide --> raw"$N$ (steps after thermalization)"
    yguide --> raw"$M$ (magnetization)"
    guidefontsize --> 10
    tickfontsize --> 8
    legendfontsize --> 8
    legend_foreground_color --> nothing
    legend_position --> :topright
    frame --> :box
    palette --> :tab10
    grid --> nothing
    # See http://juliaplots.org/RecipesBase.jl/stable/types/#User-Recipes-2
    trace = plot.args[end]  # Extract trace from the args
    𝐌 = map(magnetization, trace)
    𝟘 = zero(eltype(𝐌))
    spin_up, spin_down = findall(>(𝟘), 𝐌), findall(<=(𝟘), 𝐌)
    for (steps, label) in zip((spin_up, spin_down), ("spin up", "spin down"))
        if !isempty(steps)
            @series begin
                xlims --> extrema(steps)
                label --> label
                steps, 𝐌[steps]
            end
        end
    end
end

@userplot ParamPlot
@recipe function f(plot::ParamPlot)
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
    # See http://juliaplots.org/RecipesBase.jl/stable/types/#User-Recipes-2
    𝐉, 𝐛 = plot.args  # Extract `𝐉` and `𝐛` from the args
    for type in (:scatter, :path)
        @series begin
            seriestype --> type
            𝐉, 𝐛
        end
    end
end

@userplot CorPlot
@recipe function f(plot::CorPlot)
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
    # See http://juliaplots.org/RecipesBase.jl/stable/types/#User-Recipes-2
    𝐳, 𝐀 = plot.args  # Extract `𝐉` and `𝐛` from the args
    return 𝐳, 𝐀
end
