export find_neighbors, find_neighbor_spins, hamiltonian, partition_function

function find_neighbors(lattice::Lattice, i, j)
    width, height = size(lattice)
    return (mod(i + 1, width), j),
    (mod(i - 1, width), j), (i, mod(j + 1, height)),
    (i, mod(j - 1, height))
end

function find_neighbor_spins(lattice::Lattice, i, j)
    neighbors = find_neighbors(lattice, i, j)
    return map(Base.Fix1(getindex, lattice), neighbors)
end

function hamiltonian(lattice::Lattice, i::Integer, j::Integer, coupling, magnetic_field=0)
    neighbor_spins = find_neighbor_spins(lattice, i, j)
    spin = lattice[i, j]
    return -coupling / 2 * neighbor_spins .* spin - magnetic_field * spin
end
function hamiltonian(lattice::Lattice, coupling, magnetic_field=0)
    return sum(
        hamiltonian(lattice, i, j, coupling, magnetic_field) for
        (i, j) in eachindex(lattice)
    )
end

partition_function(lattice::Lattice, coupling, magnetic_field=0) =
    exp(-hamiltonian(lattice, coupling, magnetic_field))
