export Lattice, Evolution

struct Lattice{T} <: AbstractMatrix{T}
    spins::Matrix{T}
end

struct Evolution{T} <: AbstractArray{T,3}
    history::Array{T,3}
end
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
