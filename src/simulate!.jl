export Basic, Checkerboard, SwendsenWang, simulate!

abstract type Algorithm end
struct Basic <: Algorithm end
struct Checkerboard <: Algorithm end
struct SwendsenWang <: Algorithm end

function simulate!(lattice::Lattice, β, J, B, ::Basic)
    for index in eachindex(lattice)
        trial_spin = flipspin!(lattice, index)  # Trial move, no in-place update now!
        eᵢ_old = energy(lattice, index, J, B)
        eᵢ_new = energy(sum(neighborspins(lattice, index)), trial_spin, J, B)
        P = exp(-β * (eᵢ_new - eᵢ_old))
        # No matter whether you move into a higher-energy state with probability P < 1,
        # or move into a lower-energy state with probability 1, always do:
        if P > rand()
            lattice[index] = trial_spin  # Accept the trial move
        end
    end
    return lattice
end
function simulate!(lattice::Lattice, β, J, B, ::Checkerboard)
    m, n = size(lattice)
    interactions = sum(findneighbors(lattice))
    for mask in checkerboardmasks(m, n)  # Do it twice
        # ΔE = new state - old state = interactions * ((-lattice) - (lattice))
        ΔE = (2J * interactions .+ B) .* lattice  # Note the elementwise multiplication!
        P = exp.(-β .* ΔE) .* mask  # A matrix of Boltzmann factors
        indices = P .> rand(m, n)  # Determine which atoms to update states
        mapat!(flipspin, lattice, indices)
    end
    return lattice
end
function simulate!(lattice::Lattice, β, J, B, ::SwendsenWang)
    index = rand(CartesianIndices(lattice))  # Randomly select an atom from `lattice`
    p = 1 - exp(-β * (2J + B))
    recursive_flipspin!(lattice, index, lattice[index], p)
    return lattice
end
function simulate!(lattice::Lattice, n, β, J, B, alg::Algorithm)
    return map(1:n) do _
        deepcopy(simulate!(lattice, β, J, B, alg))  # Remember to `deepcopy`!
    end
end

function flipspin(spin)
    a, b = states(typeof(spin))
    return spin == a ? b : a
end
function flipspin(lattice::Lattice, index::CartesianIndex)
    a, b = states(eltype(lattice))
    return lattice[index] == a ? b : a
end
# Flip a spin in-place
function flipspin!(lattice::Lattice, index::CartesianIndex)
    spin = flipspin(lattice, index)
    lattice[index] = spin
    return spin
end
flipspin!(lattice::Lattice, i, j) = flipspin!(lattice, CartesianIndex(i, j))
# Flip a spin in-place recursively
function recursive_flipspin!(lattice::Lattice, index::CartesianIndex, spin₀, p)
    spin = flipspin!(lattice, index)
    for index′ in findneighbors(lattice, index)
        if lattice[index′] == spin₀ && p > rand()
            return recursive_flipspin!(lattice, index′, spin₀, p)  # Recursive call
        end
    end
    return spin
end

# Idea from https://github.com/chezou/julia-100-exercises/blob/master/README.md#1-create-a-8x8-matrix-and-fill-it-with-a-checkerboard-pattern
function checkerboardmasks(m, n)
    mask = falses(m, n)
    mask[1:2:end, 2:2:end] .= true
    mask[2:2:end, 1:2:end] .= true
    return mask, true .- mask
end

function mapat!(f, array, indices...)  # Map function `f` at specific indices of an array
    area = view(array, indices...)
    map!(f, area, area)
    return array
end
