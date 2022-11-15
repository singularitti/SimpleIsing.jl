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
