using Statistics: mean

export find_neighbors, find_neighbor_spins, energy, partition_function, magnetization

function find_neighbors(lattice::Lattice, index::CartesianIndex)
    width, height = size(lattice)
    i, j = Tuple(index)  # See https://discourse.julialang.org/t/unpacking-cartesianindex/27374/6
    return CartesianIndex(mod1(i + 1, width), j),
    CartesianIndex(mod1(i - 1, width), j), CartesianIndex(i, mod1(j + 1, height)),
    CartesianIndex(i, mod1(j - 1, height))
end
find_neighbors(lattice::Lattice, i, j) = find_neighbors(lattice, CartesianIndex(i, j))

function find_neighbor_spins(lattice::Lattice, index::CartesianIndex)
    neighbors = find_neighbors(lattice, index)
    return map(Base.Fix1(getindex, lattice), neighbors)
end
find_neighbor_spins(lattice::Lattice, i, j) =
    find_neighbor_spins(lattice, CartesianIndex(i, j))

function energy(lattice::Lattice, i::CartesianIndex, J, B=0)
    ∑ⱼsⱼ = sum(find_neighbor_spins(lattice, i))
    sᵢ = lattice[i]
    return -(J / 2 * ∑ⱼsⱼ + B) * sᵢ
end
energy(lattice::Lattice, i, j, J, B=0) = energy(lattice, CartesianIndex(i, j), J, B)
energy(lattice::Lattice, J, B=0) =
    sum(energy(lattice, index, J, B) for index in eachindex(lattice))

partition_function(lattice::Lattice, args...) = exp(-energy(lattice, args...))

magnetization(lattice::Lattice) = mean(lattice)
