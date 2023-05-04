using YAML,ApproxOperator,Plots, LinearAlgebra


xlims_ = (-0.1,5.1)
ylims_ = (-0.1,5.1)


linestyle = (:solid,0.1)
markstyle = (:circle,1,Plots.stroke(0, :black))

function plotmesh(as::Vector{T}) where T<:ApproxOperator.AbstractElement
    p = plot(;framestyle=:none,legend = false,background_color=:transparent,aspect_ratio=:equal)
    for a in as
        plotmesh(a,p)
    end
    return p
end

function plotmesh(a::T,p::Plots.Plot) where T<:ApproxOperator.AbstractElement{:Seg2}
    plot!([a.𝓒[i].x for i in 1:2],zeros(2),color=:black,line=linestyle,marker=markstyle)
end

function plotmesh(a::T,p::Plots.Plot) where T<:ApproxOperator.AbstractElement{:Tri3}
    plot!([a.𝓒[i].x for i in (1,2,3,1)],[a.𝓒[i].y for i in (1,2,3,1)],color=:black,line=linestyle,marker=markstyle)
end


ndiv = 10
include("input.jl")
elements, nodes = import_gauss_quadratic("./msh/cantilever_"*string(ndiv)*".msh",:TriGI3)
nₚ = length(nodes)
nₑ = length(elements["Ω"])
s = 3.1*12.0/ndiv*ones(nₚ)
push!(nodes,:s₁=>s,:s₂=>s,:s₃=>s)
set𝝭!(elements["Ω"])
p = plotmesh(elements["Ω"])

lw = 1.5
plot!([-10/3,20/3,-10/3,-10/3],[-10/3^0.5,0,10/3^0.5,-10/3^0.5],color=:black,line=(:solid,lw))
# plot!([0,0],[1,2],color=:black,line=(:solid,lw))
# plot!([1,2],[0,0],color=:black,line=(:solid,lw))
# curves!([0,0.552284749831,1,1],[1,1,0.552284749831,0],color=:black,line=(:solid,lw))
# curves!([0,2*0.552284749831,2,2],[2,2,2*0.552284749831,0],color=:black,line=(:solid,lw))
# plot!([nodes[i].x for i in (1,2,3,4,1)],[nodes[i].y for i in (1,2,3,4,1)],color=:black,line=(:solid,2.0))
# savefig(p,"./figure/patch_test.svg")
# savefig(p,"./figure/cantilever_10.svg")

# elements, nodes = importmsh("./msh/plate_with_hole_24.msh")
# p = plotmesh(elements["Ω"])
# savefig(p,"./figure/plate_with_hole_24.svg")

plot(p)
