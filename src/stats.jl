using LsqFit: curve_fit
using Statistics: mean

export Modeller, spincor, timeaverage_spincor

struct Modeller{T}
    n::T
end
Modeller(lattice::Lattice) = Modeller(size(lattice, 2))
function (m::Modeller)(z, params)
    a, b = float.(params)
    return @. a * (exp(-z / b) + exp(-(m.n - z) / b))
end

function average(lattice::Lattice, dim)
    if dim == :x
        return map(sum, eachcol(lattice)) / size(lattice, 2)  # Note we sum over `y`!
    elseif dim == :y
        return map(sum, eachrow(lattice)) / size(lattice, 1)  # Note we sum over `x`!
    else
        throw(ArgumentError("argument `dim` must be either `x` or `y`!"))
    end
end

function spincor(lattice::Lattice)
    Σx, Σy = average(lattice, :x), average(lattice, :y)
    return function (z)
        Σx₊z, Σy₊z = average(circshift(lattice, (0, -z)), :x),
        average(circshift(lattice, (-z, 0)), :y)
        term1 = mean(Σx .* Σx₊z)
        term2 = mean(Σy .* Σy₊z)
        return (term1 + term2) / 2
    end
end
spincor(trace) = z -> [spincor(lattice)(z) for lattice in trace]

timeaverage_spincor(trace) = z -> mean(spincor(trace)(z))  # Time average
