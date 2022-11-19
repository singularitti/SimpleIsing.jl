using Statistics: mean

export findneighbors, neighborspins, energy, partition_function, magnetization

function findneighbors(lattice::Lattice, index::CartesianIndex)
    width, height = size(lattice)
    i, j = Tuple(index)  # See https://discourse.julialang.org/t/unpacking-cartesianindex/27374/6
    return CartesianIndex(mod1(i + 1, width), j),
    CartesianIndex(mod1(i - 1, width), j), CartesianIndex(i, mod1(j + 1, height)),
    CartesianIndex(i, mod1(j - 1, height))
end
findneighbors(lattice::Lattice, i, j) = findneighbors(lattice, CartesianIndex(i, j))

function neighborspins(lattice::Lattice, index::CartesianIndex)
    neighbors = findneighbors(lattice, index)
    return map(Base.Fix1(getindex, lattice), neighbors)
end
neighborspins(lattice::Lattice, i, j) = neighborspins(lattice, CartesianIndex(i, j))

energy(∑ⱼsⱼ, sᵢ, J, B) = -(J * ∑ⱼsⱼ + B) * sᵢ
energy(lattice::Lattice, i::CartesianIndex, J, B) =
    energy(sum(neighborspins(lattice, i)), lattice[i], J, B)
energy(lattice::Lattice, i, j, J, B) = energy(lattice, CartesianIndex(i, j), J, B)
energy(lattice::Lattice, J, B) =
    sum(energy(lattice, index, J, B) for index in eachindex(lattice))

partition_function(lattice::Lattice, i::CartesianIndex, β, J, B) =
    exp(-β * energy(lattice, i, J, B))
partition_function(lattice::Lattice, i, j, β, J, B) = exp(-β * energy(lattice, i, j, J, B))
partition_function(lattice::Lattice, β, J, B) = exp(-β * energy(lattice, J, B))

magnetization(lattice::Lattice) = mean(lattice)
