using JackknifeAnalysis: JackknifeAnalysis, Population, PartitionSampler
using LaTeXFigures: Figure, latexformat
using LsqFit: curve_fit
using Plots
using ProgressMeter: @showprogress
using SimpleIsing: Lattice, SwendsenWang, Modeller, simulate!, spincor, paramplot!, corplot!
using Statistics: mean, std

plotsdir() = abspath("../tex/plots")
if !isdir(plotsdir())
    mkpath(plotsdir())
end

const β = 1
const nsteps = 5000
const nsteps_thermal = 2000  # Number of steps needed to be thermalized
𝐉 = [0.435, 0.43, 0.425, 0.42, 0.41, 0.4]  # Increasing temperature
boxsizes = [32, 64, 128]  # Size of the lattice
A = Matrix{Float64}(undef, length(𝐉), length(boxsizes))  # Parameter a for each J for each N
B = Matrix{Float64}(undef, length(𝐉), length(boxsizes))  # Parameter b for each J for each N
Σ = Matrix{Vector{Float64}}(undef, length(𝐉), length(boxsizes))

function plot_bJ(𝐉, 𝐛, N)
    plot()  # Start a new figure
    paramplot!(𝐉, 𝐛)
    figname = string("b(J)_N=", N, ".pdf")
    savefig(joinpath(plotsdir(), figname))
    return clipboard(latexformat(Figure(figname; caption=raw"", label="fig:bJ", width=0.8)))
end

function plot_correlation(𝐚, 𝐛, 𝐉, 𝚺, N, yerr)
    plot()  # Start a new figure
    𝐳 = 1:N  # Each z
    return map(enumerate(zip(𝐚, 𝐛, 𝐉, 𝚺))) do (j, (a, b, J, sg))
        scatter!(𝐳, sg; label="", markersize=2, markerstrokewidth=0)
        corplot!(
            𝐳, Modeller(N)(𝐳, [a, b]); yerr=yerr[j, :], label=string(raw"$J = ", J, raw" $")
        )
        ylims!(-Inf, 0.6)
        figname = string("correlation_N=", N, ".pdf")
        savefig(joinpath(plotsdir(), figname))
        clipboard(latexformat(Figure(figname; caption=raw"", label="fig:corr", width=0.8)))
    end
end

for (i, N) in enumerate(boxsizes)
    lattice = Lattice(ones(N, N))
    𝐳 = 1:N  # Each z
    𝚺z = []
    σ = Matrix{Float64}(undef, length(𝐉), N)  # Standard deviation of Σz for each J for each N
    @showprogress for (j, J) in enumerate(𝐉)
        trace = simulate!(lattice, nsteps, β, J, 0, SwendsenWang())[nsteps_thermal:end]
        Σz = map(spincor(trace), 𝐳)  # Vector of vectors, Σ(z) for each z at each timestep for this J for this N
        push!(𝚺z, Σz)
        𝚺̄z = map(mean, Σz)  # Vector, ensemble average ⟨Σ(z)⟩ for each z for this J for this N
        Σ[j, i] = 𝚺̄z
        𝛔 = map(Base.Fix2(JackknifeAnalysis.std, PartitionSampler(20)) ∘ Population, Σz)  # Vector, std √⟨(Σ(z) - 𝚺̄z)²⟩ for each z for this J for this N
        σ[j, :] = 𝛔
        a, b = curve_fit(Modeller(N), 𝐳, 𝚺̄z, [0.2588, 32.537]).param  # Parameters for ⟨Σ(z)⟩
        A[j, i] = a
        B[j, i] = b
    end
    plot_bJ(𝐉, B[:, i], N)
    plot_correlation(A[:, i], B[:, i], 𝐉, Σ[:, i], N, σ)
end
