using StaticArrays: MMatrix, MArray

export Lattice, Evolution

struct Lattice{S1,S2,T} <: AbstractMatrix{T}
    spins::MMatrix{S1,S2,T}
end
Lattice(spins::AbstractMatrix) = Lattice{size(spins, 1),size(spins, 2),eltype(spins)}(spins)

struct Evolution{S1,S2,S3,T} <: AbstractArray{T,3}
    history::MArray{Tuple{S1,S2,S3},T,3}
end
Evolution(history::AbstractArray) =
    Evolution{size(history, 1),size(history, 2),size(history, 3),eltype(history)}(history)
# See https://discourse.julialang.org/t/turn-vector-of-matrices-into-3d-array/69777/6
Evolution(history::AbstractVector{<:Lattice}) =
    Evolution(reduce((x, y) -> cat(x, y; dims=3), history))

Base.parent(lattice::Lattice) = lattice.spins
Base.parent(evolution::Evolution) = evolution.history

Base.size(lattice::Lattice) = size(parent(lattice))
Base.size(evolution::Evolution) = size(parent(evolution))

Base.getindex(lattice::Lattice, I...) = getindex(parent(lattice), I...)
Base.getindex(evolution::Evolution, I...) = getindex(parent(evolution), I...)

Base.setindex!(lattice::Lattice, v, I...) = setindex!(parent(lattice), v, I...)
Base.setindex!(evolution::Evolution, v, I...) = setindex!(parent(evolution), v, I...)
