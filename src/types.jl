using StaticArrays: MMatrix, MArray

export Lattice, Evolution

struct Lattice{S1,S2} <: AbstractMatrix{Bool}
    spins::MMatrix{S1,S2,Bool}
end
Lattice(spins::AbstractMatrix{Bool}) = Lattice{size(spins, 1),size(spins, 2)}(spins)

struct Evolution{S1,S2,T} <: AbstractArray{Bool,3}
    history::MArray{Tuple{S1,S2,T},Bool,3}
end
Evolution(history::AbstractArray{Bool,3}) =
    Evolution{size(history, 1),size(history, 2),size(history, 3)}(history)
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

function Base.show(io::IO, lattice::Lattice)
    if get(io, :compact, false) || get(io, :typeinfo, nothing) == typeof(lattice)
        Base.show_default(IOContext(io, :limit => true), lattice)  # From https://github.com/mauro3/Parameters.jl/blob/ecbf8df/src/Parameters.jl#L556
    else
        println(io, string(typeof(lattice)))
        for row in eachrow(lattice.spins)
            println(io, ' ', join(Int.(row), ' '^2))
        end
    end
end
