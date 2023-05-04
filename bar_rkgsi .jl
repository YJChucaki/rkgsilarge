
using   ApproxOperator, LinearAlgebra, Printf, CairoMakie, TOML

# config = TOML.parsefile("./toml/bar_rkgsi_quadratic.toml")
# elements, nodes = ApproxOperator.importmsh("./msh/bar_10.msh",config)
include("input.jl")
elements, nodes = import_rkgsi("./msh/bar_10.msh")
nₚ = length(nodes)
s = 2.5*10.0/ndiv*ones(nₚ)
push!(nodes,:s₁=>s,:s₂=>s,:s₃=>s)

set𝝭!(elements["Ω"])
# set∇𝝭!(elements["Ω"])
set∇̃𝝭!(elements["Ω̃"],elements["Ω"])
set𝝭!(elements["Γᵗ"])
set𝝭!(elements["Γᵍ"])

prescribe!(elements["Γᵍ"],:g=>(x,y,z)->0.0)

# set operator
ops = [
    Operator{:∫ESdx}(:E=>400.0),
    Operator{:∫vbdΩ}(),
    Operator{:∫vtdΓ}(),
    Operator{:∫vgdΓ}(:α=>1e15)
]

# assembly

fig = Figure()
ax = Axis(fig[1,1],title = "Load-displacement curve",xlabel = "u",ylabel = "f")
u=zeros(Float64,21)
y=range(0,1000,length=21)
k = zeros(nₚ,nₚ)
fint = zeros(nₚ)
fext = zeros(nₚ)
f = zeros(nₚ)
d = zeros(nₚ)

push!(nodes,:d=>d)

tolerance=1.0e-10;maxiters=100;
for n in 1:20
    @printf  "Load step=%i,f=%e \n" n 50.0*n
    fill!(fext,0.0)
    prescribe!(elements["Γᵗ"],:t=>(x,y,z)->50.0*n)
    ops[3](elements["Γᵗ"],fext)
    iters = 0
    while iters < maxiters 
        iters += 1
        fill!(k,0.0)
        fill!(fint,0.0)
        ops[1](elements["Ω̃"],k,fint)
        f .= fext - fint
        fnorm = LinearAlgebra.norm(f)
        ops[4](elements["Γᵍ"],k,f)
        Δd = k\f
        d .+= Δd 

        Δdnorm = LinearAlgebra.norm(Δd)
        @printf "iter = %i, fnorm = %e, Δdnorm = %e \n" iters fnorm Δdnorm

        if Δdnorm < tolerance
            u[n+1]=d[nₚ]
            break
        end
    end
end 
scatterlines!(ax, u, y)
display(fig)