export Basic, simulate!

abstract type Algorithm end
struct Basic <: Algorithm end
struct SwendsenWang <: Algorithm end

function simulate!(lattice::Lattice, β, J, B, ::Basic)
    for index in eachindex(lattice)
        trial_spin = flipspin(lattice, index)  # Trial move, no in-place update now!
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

flipspin(lattice::Lattice, index::CartesianIndex) =
    lattice[index] == lattice.states[1] ? lattice.states[2] : lattice.states[1]
flipspin(lattice::Lattice, i, j) = flipspin(lattice, CartesianIndex(i, j))
