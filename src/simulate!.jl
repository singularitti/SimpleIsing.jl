export Plain, simulate!

abstract type Algorithm end
struct Plain <: Algorithm end
struct SwendsenWang <: Algorithm end

function simulate!(lattice::Lattice, β, J, B, ::Plain)
    for index in eachindex(lattice)
        trial_spin = -lattice[index]  # Trial move, no in-place update now!
        eᵢ_old = energy(lattice, index, J, B)
        eᵢ_new = energy(sum(neighborspins(lattice, index)), trial_spin, J, B)
        P = exp(-β * (eᵢ_new - eᵢ_old))
        if eᵢ_new > eᵢ_old  # Moving into a higher-energy state with probability P < 1
            if P > rand()
                lattice[index] = trial_spin  # Accept the trial move
            end
        else  # eᵢ_new <= eᵢ_old
            if P > rand()  # Always true
                lattice[index] = trial_spin  # Accept the trial move
            end
        end
    end
    return lattice
end
