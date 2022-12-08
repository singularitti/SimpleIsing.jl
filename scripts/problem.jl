using JackknifeAnalysis: JackknifeAnalysis, Population, PartitionSampler
using LsqFit: curve_fit
using Plots
using SimpleIsing: Lattice, SwendsenWang, Modeller, simulate!, spincor, paramplot!, corplot!
using Statistics: mean, std

plotsdir() = abspath("../tex/plots")
if !isdir(plotsdir())
    mkpath(plotsdir())
end

const β = 1
const nsteps = 5000
const nsteps_thermal = 2000  # Number of steps needed to be thermalized
𝐉 = [0.439, 0.435, 0.43, 0.425, 0.42, 0.41, 0.4]  # Increasing temperature

function plot_correlation(𝐚, 𝐛, Σ̄, N, σ)
    plot()  # Start a new figure
    𝐳 = 1:N  # Each z
    # return map(enumerate(zip(𝐚, 𝐛, 𝐉))) do (j, (a, b, J))
    for (j, (a, b, J)) in enumerate(zip(𝐚, 𝐛, 𝐉))
        scatter!(𝐳, Σ̄[j, :]; label="", markersize=2, markerstrokewidth=0, z_order=:back)
        corplot!(
            𝐳, Modeller(N)(𝐳, [a, b]); yerror=σ[j, :], label=string(raw"$J = ", J, raw" $")
        )
        figname = string("correlation_N=", N, ".pdf")
        savefig(joinpath(plotsdir(), figname))
    end
    return current()  # See https://discourse.julialang.org/t/plotting-from-within-a-loop-using-gr/4435/6
end

function prepare(N, binsize)
    lattice = Lattice(ones(N, N))
    𝐳 = 1:N  # Each z
    Σ̄ = Matrix{Float64}(undef, length(𝐉), N)  # Mean value of Σ(z) for each J for each N
    σ = Matrix{Float64}(undef, length(𝐉), N)  # Standard deviation of Σ(z) for each J for each N
    fitted = map(enumerate(𝐉)) do (j, J)
        trace = simulate!(lattice, nsteps, β, J, 0, SwendsenWang())[nsteps_thermal:end]
        Σz = map(spincor(trace), 𝐳)  # Vector of vectors, Σ(z) for each z at each time step for this J for this N
        𝚺̄z = map(mean, Σz)  # Vector, ensemble average ⟨Σ(z)⟩ for each z for this J for this N
        Σ̄[j, :] = 𝚺̄z
        𝛔 = map(
            Base.Fix2(JackknifeAnalysis.std, PartitionSampler(binsize)) ∘ Population, Σz
        )  # Vector, std √⟨(Σ(z) - 𝚺̄z)²⟩ for each z for this J for this N
        σ[j, :] = 𝛔 ./ sqrt(N)
        a, b = curve_fit(Modeller(N), 𝐳, 𝚺̄z, [0.2588, 32.537]).param  # Parameters for ⟨Σ(z)⟩
        a, b
    end
    𝐚, 𝐛 = first.(fitted), last.(fitted)
    return 𝐚, 𝐛, Σ̄, σ
end

for N in [32, 64, 128]  # Sizes of the lattice
    𝐚, 𝐛, Σ̄, σ = prepare(N, 20)
    paramplot!(𝐉, 𝐛; label=raw"$N = " * string(N) * '$')
    plot_correlation(𝐚, 𝐛, Σ̄, N, σ)
end
