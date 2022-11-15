module SimpleIsing

using StaticArrays: MMatrix, MArray

export Lattice, Evolution

struct Lattice{S1,S2}
    spins::MMatrix{S1,S2,Bool}
end
Lattice(spins::AbstractMatrix{Bool}) = Lattice{size(spins, 1),size(spins, 2)}(spins)

struct Evolution{S1,S2,T}
    history::MArray{Tuple{S1,S2},Bool,3}
end

end
