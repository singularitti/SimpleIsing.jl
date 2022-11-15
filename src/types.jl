using StaticArrays: MMatrix, MArray

export Lattice, Evolution

struct Lattice{S1,S2}
    spins::MMatrix{S1,S2,Bool}
end
Lattice(spins::AbstractMatrix{Bool}) = Lattice{size(spins, 1),size(spins, 2)}(spins)

struct Evolution{S1,S2,T}
    history::MArray{Tuple{S1,S2,T},Bool,3}
end

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
