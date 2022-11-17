using RecipesBase

@recipe function f(lattice::Lattice)
    xlims --> extrema(axes(lattice, 1))
    ylims --> extrema(axes(lattice, 2))
    xguide --> "x"
    yguide --> "y"
    guidefontsize --> 8
    tickfontsize --> 6
    color --> :binary
    colorbar --> false
    frame --> :box
    aspect_ratio --> :equal
    return axes(lattice)..., lattice
end
