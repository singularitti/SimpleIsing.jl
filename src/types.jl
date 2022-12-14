export Lattice, states

struct Lattice{T} <: AbstractMatrix{T}
    spins::Matrix{T}
end

states(::Type{T}) where {T<:Number} = (one(T), -one(T))

isvalid(spin) = spin in states(typeof(spin))

Base.parent(lattice::Lattice) = lattice.spins

Base.size(lattice::Lattice) = size(parent(lattice))

Base.getindex(lattice::Lattice, I...) = getindex(parent(lattice), I...)

Base.setindex!(lattice::Lattice, v, I...) = setindex!(parent(lattice), v, I...)

Base.similar(::Lattice, ::Type{T}, dims::Dims) where {T} = Lattice(Matrix{T}(undef, dims))
