export Lattice, Evolution, Spin, up, down, states

@enum Spin up = 1 down = -1

struct Lattice{T} <: AbstractMatrix{T}
    spins::Matrix{T}
    function Lattice{T}(spins) where {T}
        @assert all(spin in states(T) for spin in spins)
        return new(spins)
    end
end
Lattice(spins::AbstractMatrix) = Lattice{eltype(spins)}(collect(spins))

states(::Spin) = instances(Spin)

struct Evolution{T} <: AbstractVector{Lattice{T}}
    history::Vector{Lattice{T}}
end

Base.parent(lattice::Lattice) = lattice.spins
Base.parent(evolution::Evolution) = evolution.history

Base.size(lattice::Lattice) = size(parent(lattice))
Base.size(evolution::Evolution) = size(parent(evolution))

Base.IndexStyle(::Type{<:Evolution}) = IndexLinear()

Base.getindex(lattice::Lattice, I...) = getindex(parent(lattice), I...)
Base.getindex(evolution::Evolution, I) = getindex(parent(evolution), I)

function Base.setindex!(lattice::Lattice, v, I...)
    if v in states(eltype(lattice))
        return setindex!(parent(lattice), v, I...)
    else
        throw(DomainError(v, "you cannot set spin to value $v."))
    end
end
Base.setindex!(evolution::Evolution, v, I) = setindex!(parent(evolution), v, I)
