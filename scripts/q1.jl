using LsqFit
using SimpleIsing
using Statistics

N = 64  # Size of the lattice
lattice = Lattice(ones(N, N))
β = 1
J = 0.435
nsteps = 8000
nsteps_thermal = 2000  # Number of steps needed to be thermalized
trace = simulate!(lattice, nsteps, β, J, 0, SwendsenWang())
fit(lattice, trace[nsteps_thermal:end], [0.2588312476412214, 32.53734520801327])
