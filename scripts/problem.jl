using JackknifeAnalysis: JackknifeAnalysis, Population, PartitionSampler
using LsqFit: curve_fit
using Plots
using SimpleIsing: Lattice, SwendsenWang, Modeller, simulate!, spincor, paramplot!, corplot!
using Statistics: mean, std

plotsdir() = abspath("../tex/plots")
if !isdir(plotsdir())
    mkpath(plotsdir())
end

const Ξ² = 1
const nsteps = 5000
const nsteps_thermal = 2000  # Number of steps needed to be thermalized
π = [0.439, 0.435, 0.43, 0.425, 0.42, 0.41, 0.4]  # Increasing temperature

function plot_correlation(π, π, Ξ£Μ, N, Ο)
    plot()  # Start a new figure
    π³ = 1:N  # Each z
    # return map(enumerate(zip(π, π, π))) do (j, (a, b, J))
    for (j, (a, b, J)) in enumerate(zip(π, π, π))
        scatter!(π³, Ξ£Μ[j, :]; label="", markersize=2, markerstrokewidth=0, z_order=:back)
        corplot!(
            π³, Modeller(N)(π³, [a, b]); yerror=Ο[j, :], label=string(raw"$J = ", J, raw" $")
        )
        figname = string("correlation_N=", N, ".pdf")
        savefig(joinpath(plotsdir(), figname))
    end
    return current()  # See https://discourse.julialang.org/t/plotting-from-within-a-loop-using-gr/4435/6
end

function prepare(N, binsize)
    lattice = Lattice(ones(N, N))
    π³ = 1:N  # Each z
    Ξ£Μ = Matrix{Float64}(undef, length(π), N)  # Mean value of Ξ£(z) for each J for each N
    Ο = Matrix{Float64}(undef, length(π), N)  # Standard deviation of Ξ£(z) for each J for each N
    fitted = map(enumerate(π)) do (j, J)
        trace = simulate!(lattice, nsteps, Ξ², J, 0, SwendsenWang())[nsteps_thermal:end]
        Ξ£z = map(spincor(trace), π³)  # Vector of vectors, Ξ£(z) for each z at each time step for this J for this N
        πΊΜz = map(mean, Ξ£z)  # Vector, ensemble average β¨Ξ£(z)β© for each z for this J for this N
        Ξ£Μ[j, :] = πΊΜz
        π = map(
            Base.Fix2(JackknifeAnalysis.std, PartitionSampler(binsize)) β Population, Ξ£z
        )  # Vector, std ββ¨(Ξ£(z) - πΊΜz)Β²β© for each z for this J for this N
        Ο[j, :] = π ./ sqrt(N)
        a, b = curve_fit(Modeller(N), π³, πΊΜz, [0.2588, 32.537]).param  # Parameters for β¨Ξ£(z)β©
        a, b
    end
    π, π = first.(fitted), last.(fitted)
    return π, π, Ξ£Μ, Ο
end

for N in [32, 64, 128]  # Sizes of the lattice
    π, π, Ξ£Μ, Ο = prepare(N, 20)
    paramplot!(π, π; label=raw"$N = " * string(N) * '$')
    plot_correlation(π, π, Ξ£Μ, N, Ο)
end
