export Lattice, Evolution, Spin, up, down, states

@enum Spin up = 1 down = -1

struct Lattice{T} <: AbstractMatrix{T}
    spins::Matrix{T}
end

states(::Type{Spin}) = instances(Spin)
states(::Type{<:Number}) = (1, -1)

isvalid(spin) = spin in states(typeof(spin))

Base.parent(lattice::Lattice) = lattice.spins

Base.size(lattice::Lattice) = size(parent(lattice))

Base.getindex(lattice::Lattice, I...) = getindex(parent(lattice), I...)

Base.setindex!(lattice::Lattice, v, I...) = setindex!(parent(lattice), v, I...)

Base.similar(::Lattice, ::Type{T}, dims::Dims) where {T} = Lattice(rand(states(T), dims...))
