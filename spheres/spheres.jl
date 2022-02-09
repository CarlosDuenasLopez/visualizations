using CairoMakie
using GeometryBasics
using Random
using LinearAlgebra:norm

mutable struct Body
    posi::Point
    velocity::Point
    mass::Float64
end


function gen_particles(num_particles::Int, radius::Real)
    particles = Vector{Body}()
    for i in 1:num_particles
        point = rand(Int, 3)
        point = point ./ norm(point)
        point .*= radius
        push!(particles, Body(Point(point...), Point(0, 0, 0), 1))
    end
    particles
end


function step!(particles::Vector{Body}, attractor::Body, radius, dt)
    G = 6.674f-11
    for p in particles
        F = (G * p.mass * attractor.mass) / dist(p.posi, attractor.posi)
        a_scalar = F / p.mass
        a = attractor.posi - p.posi .* (a_scalar / norm(attractor.posi - p.posi))
        p.velocity += a
        p.posi += (p.velocity .* dt)
        p.posi = p.posi .* (radius / norm(p.posi))
    end
end


function simulate(iterations, radius, num_particles, at_mass, change_frequency)
    particles = gen_particles(num_particles, radius)
    attractor = random_particle(at_mass, radius)
    hists = [[p.posi for p in particles]]
    for it in 1:iterations
        # if it % change_frequency == 0
        #     attractor = random_particle(100, radius)
        #     for p in particles
        #         p.velocity = Point(0, 0, 0)
        #     end
        # end
        step!(particles, attractor, radius, 0.01)
        push!(hists, [p.posi for p in particles])
    end
    hists
end

function random_particle(mass, radius)
    point = rand(Int, 3)
    point = point ./ norm(point)
    point .*= radius
    Body(Point(point...), Point(0, 0, 0), mass)
end


function dist(p1, p2)
    √sum((p2-p1) .^ 2)
end


function draw(particles, frames)
    set_theme!(theme_black())

    fig = Figure(resolution=(600, 600))
    ax = Axis3(fig[1, 1], aspect = (1, 1, 1))

    ps = Node(particles[1])

    hidedecorations!(ax)
    hidespines!(ax)

    meshscatter!(ps, color=:white)

    record(fig, "spheres.gif", 1:frames, framerate = 50) do frame
        ps[] = particles[frame]
        notify(ps)
    end

    current_figure()
end
