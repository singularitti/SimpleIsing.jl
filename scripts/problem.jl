using LsqFit
using SimpleIsing
using Statistics

N = 64  # Size of the lattice
lattice = Lattice(ones(N, N))
β = 1
𝐉 = [
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
    0.6,
]
𝐛 = Float64[]
𝚺z = Vector{Float64}[]
for J in 𝐉
    nsteps = 8000
    nsteps_thermal = 2000  # Number of steps needed to be thermalized
    trace = simulate!(lattice, nsteps, β, J, 0, SwendsenWang())
    Σz = ensembleaverage(trace[nsteps_thermal:end])
    push!(𝚺z, Σz)
    b = fit(lattice, trace[nsteps_thermal:end], [0.2588, 32.537]).param[2]
    push!(𝐛, b)
end
# paramplot(𝐉, 𝐛)
