using RecipesBase

@recipe function f(lattice::Lattice)
    xlabel --> "x"
    yguide --> "y"
    color --> :gist_earth
    clim --> (-2, 1.1)
    colorbar --> false
    frame --> :box
    return axes(lattice)..., lattice
end
