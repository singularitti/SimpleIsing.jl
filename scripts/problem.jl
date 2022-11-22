push!(LOAD_PATH, dirname(pwd()))

using LaTeXFigures: Figure, latexformat
using LsqFit: curve_fit
using Plots: plot, savefig
using SimpleIsing: Lattice, SwendsenWang, Modeller, simulate!, spincor, paramplot, corplot!
using Statistics: mean

plotsdir() = abspath("../tex/plots")
if !isdir(plotsdir())
    mkpath(plotsdir())
end

β = 1
nsteps = 5000
nsteps_thermal = 2000  # Number of steps needed to be thermalized
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
]
N = 32  # Size of the lattice
lattice = Lattice(ones(N, N))
𝐳 = 1:N
𝐚 = Float64[]
𝐛 = Float64[]
𝚺z = []

for J in 𝐉
    trace = simulate!(lattice, nsteps, β, J, 0, SwendsenWang())
    Σz = map(spincor(trace), 𝐳)
    push!(𝚺z, Σz)
    𝚺̄z = map(mean, Σz)
    a, b = curve_fit(Modeller(N), 𝐳, 𝚺̄z, [0.2588, 32.537]).param
    push!(𝐚, a)
    push!(𝐛, b)
end
paramplot(𝐉, 𝐛)
clipboard(latexformat(Figure("J-b.pdf"; caption="", label="", width=1)))
savefig(joinpath(plotsdir(), "J-b.pdf"))

plot()
for (a, b, J) in zip(𝐚, 𝐛, 𝐉)
    corplot!(𝐳, Modeller(lattice)(𝐳, [a, b]); label=raw"$J = " * string(J) * raw" $")
end
savefig(joinpath(plotsdir(), "correlation.pdf"))
clipboard(latexformat(Figure("correlation.pdf"; caption="", label="", width=1)))
