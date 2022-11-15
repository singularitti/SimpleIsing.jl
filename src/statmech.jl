export find_neighbors, find_neighbor_spins, hamiltonian, partition_function

function find_neighbors(lattice::Lattice, I::CartesianIndex)
    width, height = size(lattice)
    i, j = Tuple(I)  # See https://discourse.julialang.org/t/unpacking-cartesianindex/27374/6
    return CartesianIndex(mod(i + 1, width), j),
    CartesianIndex(mod(i - 1, width), j), CartesianIndex(i, mod(j + 1, height)),
    CartesianIndex(i, mod(j - 1, height))
end
find_neighbors(lattice::Lattice, i, j) = find_neighbors(lattice, CartesianIndex(i, j))

function find_neighbor_spins(lattice::Lattice, I::CartesianIndex)
    neighbors = find_neighbors(lattice, I)
    return map(Base.Fix1(getindex, lattice), neighbors)
end
find_neighbor_spins(lattice::Lattice, i, j) =
    find_neighbor_spins(lattice, CartesianIndex(i, j))

function hamiltonian(lattice::Lattice, I::CartesianIndex, coupling, magnetic_field=0)
    neighbor_spins = find_neighbor_spins(lattice, I)
    spin = lattice[I]
    return -coupling / 2 * neighbor_spins .* spin - magnetic_field * spin
end
hamiltonian(lattice::Lattice, i::Integer, j::Integer, coupling, magnetic_field=0) =
    hamiltonian(lattice, CartesianIndex(i, j), coupling, magnetic_field)
function hamiltonian(lattice::Lattice, coupling, magnetic_field=0)
    return sum(
        hamiltonian(lattice, I, coupling, magnetic_field) for I in eachindex(lattice)
    )
end

partition_function(lattice::Lattice, coupling, magnetic_field=0) =
    exp(-hamiltonian(lattice, coupling, magnetic_field))
