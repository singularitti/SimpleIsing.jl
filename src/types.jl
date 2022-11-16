export Lattice, Evolution, Spin, up, down

@enum Spin up = 1 down = -1

struct Lattice{T} <: AbstractMatrix{T}
    spins::Matrix{T}
    states::NTuple{2,T}
    function Lattice{T}(spins) where {T}
        states = extrema(spins)
        @assert all(spin in states for spin in spins)
        return new(spins, states)
    end
end
Lattice(spins::AbstractMatrix) = Lattice{eltype(spins)}(collect(spins))

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

Base.setindex!(lattice::Lattice, v, I...) = setindex!(parent(lattice), v, I...)
Base.setindex!(evolution::Evolution, v, I) = setindex!(parent(evolution), v, I)
