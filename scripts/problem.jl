using LsqFit
using SimpleIsing
using Statistics

N = 64  # Size of the lattice
lattice = Lattice(ones(N, N))
β = 1
nsteps = 5000
nsteps_thermal = 2000  # Number of steps needed to be thermalized
let 𝐉 = [
        0.425,
        0.43,
        0.435,
        0.438,
        0.439,
        0.44,
        0.4405,
        0.4406868,
        0.4407,
        0.441,
        0.442,
        0.45,
        0.5,
    ]
    𝐛 = Float64[]
    𝚺z = []
    plot()
    for J in 𝐉
        trace = simulate!(lattice, nsteps, β, J, 0, SwendsenWang())
        𝐳 = 1:N
        Σz = map(spincor(trace), 𝐳)
        push!(𝚺z, Σz)
        𝚺̄z = map(mean, Σz)
        a, b = curve_fit(Modeller(N), 𝐳, 𝚺̄z, [0.2588, 32.537]).param
        corplot!(𝐳, Modeller(lattice)(𝐳, [a, b]); label=raw"$J = " * string(J) * raw" $")
        savefig("autocor.pdf")
        push!(𝐛, b)
    end
    paramplot(𝐉, 𝐛)
end
