export Lattice, Evolution, Spin, up, down, states

@enum Spin up = 1 down = -1

struct Lattice{T} <: AbstractMatrix{T}
    spins::Matrix{T}
    function Lattice{T}(spins) where {T}
        @assert all(isvalid(spin) for spin in spins)
        return new(spins)
    end
end
Lattice(spins::AbstractMatrix) = Lattice{eltype(spins)}(collect(spins))

states(::Type{Spin}) = instances(Spin)
states(::Type{<:Number}) = (1, -1)

isvalid(spin) = spin in states(typeof(spin))

Base.parent(lattice::Lattice) = lattice.spins

Base.size(lattice::Lattice) = size(parent(lattice))

Base.getindex(lattice::Lattice, I...) = getindex(parent(lattice), I...)

function Base.setindex!(lattice::Lattice, v, I...)
    if v in states(eltype(lattice))
        return setindex!(parent(lattice), v, I...)
    else
        throw(DomainError(v, "you cannot set spin to value $v."))
    end
end
