push!(LOAD_PATH, dirname(pwd()))

using LaTeXFigures: Figure, latexformat
using LsqFit: curve_fit
using Plots: plot, savefig
using ProgressMeter: @showprogress
using SimpleIsing: Lattice, SwendsenWang, Modeller, simulate!, spincor, paramplot!, corplot!
using Statistics: mean

plotsdir() = abspath("../tex/plots")
if !isdir(plotsdir())
    mkpath(plotsdir())
end

const β = 1
const nsteps = 5000
const nsteps_thermal = 2000  # Number of steps needed to be thermalized
𝐉 = [0.44, 0.439, 0.438, 0.435, 0.43, 0.425, 0.4]  # Increasing temperature
boxsizes = [32, 64, 128, 256]  # Size of the lattice
A = Matrix{Float64}(undef, length(𝐉), length(boxsizes))  # Parameter a for each J for each N
B = Matrix{Float64}(undef, length(𝐉), length(boxsizes))  # Parameter b for each J for each N

function plot_bJ(𝐉, 𝐛, N)
    plot()  # Start a new figure
    paramplot!(𝐉, 𝐛)
    figname = string("b(J)_N=", N, ".pdf")
    savefig(joinpath(plotsdir(), figname))
    return clipboard(latexformat(Figure(figname; caption=raw"", label="fig:bJ", width=0.8)))
end

function plot_correlation(𝐚, 𝐛, 𝐉, N)
    plot()  # Start a new figure
    𝐳 = 1:N  # Each z
    return map(𝐚, 𝐛, 𝐉) do a, b, J
        corplot!(𝐳, Modeller(N)(𝐳, [a, b]); label=string(raw"$J = ", J, raw" $"))
        figname = string("correlation_N=", N, ".pdf")
        savefig(joinpath(plotsdir(), figname))
        clipboard(latexformat(Figure(figname; caption=raw"", label="fig:corr", width=0.8)))
    end
end

for (i, N) in enumerate(boxsizes)
    lattice = Lattice(ones(N, N))
    𝐳 = 1:N  # Each z
    𝚺z = []
    @showprogress for (j, J) in enumerate(𝐉)
        trace = simulate!(lattice, nsteps, β, J, 0, SwendsenWang())
        Σz = map(spincor(trace), 𝐳)  # Vector of vectors, Σ(z) for each z for each timestep for this J for this N
        push!(𝚺z, Σz)
        𝚺̄z = map(mean, Σz)  # Vector, ensemble average ⟨Σ(z)⟩ for each z for this J for this N
        a, b = curve_fit(Modeller(N), 𝐳, 𝚺̄z, [0.2588, 32.537]).param  # Parameters for ⟨Σ(z)⟩
        A[j, i] = a
        B[j, i] = b
    end
    plot_bJ(𝐉, B[:, i], N)
    plot_correlation(A[:, i], B[:, i], 𝐉, N)
end
