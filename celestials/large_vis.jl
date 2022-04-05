using GLMakie
using Revise
includet("large.jl")

function makefig()
    set_theme!(theme_black())
    fig = Figure()
    ax = Axis3(fig[1, 1], limits = (-100, 100, -100, 100, -100, 100), aspect = (1, 1, 1))
    screen = display(fig)
    resize!(screen, 1500, 1500)
    return fig, ax
end

Makie.convert_single_argument(b::Body) = b.posi     # Enable Makie to plot instances of Body
Makie.convert_single_argument(vb::Vector{Body}) = [b.posi for b in vb]

function fill_plot(fig, ax, bodies)
    scatter!(ax, bodies, markersize = 2000)
end

function run(num_bodies, mass)
    println("HALLo")
    fig, ax = makefig()
    bodies = Observable(gen_bodies(num_bodies, 50, mass, 10, 0.1))
    grids = all_grids!(bodies[])
    fill_plot(fig, ax, bodies)
    while true 
        grids = step!(bodies[], grids)
        notify(bodies)
        sleep(0.03)
    end
end