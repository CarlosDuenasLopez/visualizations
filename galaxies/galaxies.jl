using LinearAlgebra:norm
using GeometryBasics
using GLMakie

mutable struct Particle
    posi::Point
    velocity::Point
    mass::BigFloat
end


function calc_f(particle, other)
    G = 6.67408f-11
    r = dist(particle, other)
    F = G * (particle.mass * other.mass) / r^2
    return F
end

function update_velocitiy!(particle, all_particles, dt)
    a_vec = [0, 0, 0]
    G = 6.67408f-11
    for other in all_particles
        if other != particle
            F = calc_f(particle, other)
            a = F / particle.mass
            connection_vector =  other.posi - particle.posi
            normed = connection_vector ./ norm(connection_vector)
            a_vec += normed .* a
        end
    end
    particle.velocity += a_vec .* dt
end


function step!(all_particles)
    dt = 100000
    for p in all_particles
        update_velocitiy!(p, all_particles, dt)
    end
    for p in all_particles
        p.posi += p.velocity * dt
    end
end


function simulate(iterations)
    sun = Particle(Point(0., 0., 0.), Point(0., 0., 0.), 1.9f30)
    earth = Particle(Point(-15f10, 0., 0.), Point(0., 29_000, 0), 5.9f24)
    mercury = Particle(Point(-5.7f10, 0, 0), Point(0, 47_400, 0), 0.33f24)
    venus = Particle(Point(-10.8f10, 0, 0), Point(0, 35_000, 0), 4.87f24)
    mars = Particle(Point(-22.7f10, 0, 0), Point(0, 24_000, 0), 0.642f24)
    all_parts = [sun, earth, mercury, venus, mars]
    all_posis = [[] for _ in 1:length(all_parts)]
    for i in 1:iterations
        for (i, a) in enumerate(all_parts)
            push!(all_posis[i], a.posi)
        end
        step!(all_parts)
    end

    all_posis
end


function animate(posis, frames)
    set_theme!(theme_black())
    fig = Figure(resolution = (1000, 1000))
    ax = Axis3(fig[1, 1], aspect = (1, 1, 1),
    limits = (-10f11/4, 10f11/4, -10f11/4, 10f11/4, -10f11/4, 10f11/4,))

    start_posis = [i[1] for i in posis]
    planets = Node(start_posis)
    colors = [:yellow, :blue, :white, :red, :orange]
    scatter!(ax, planets, color=colors, markersize=5000)
    tails = Vector{Node}()
    for (i, p) in enumerate(posis)
        push!(tails, Node([p[1]]))
        lines!(ax, tails[end], color=colors[i])
    end
    record(fig, "example.gif", 1:frames, framerate = 50) do frame
        for planet_idx in 1:length(posis)
            current_tail = tails[Int(planet_idx)][]
            push!(current_tail, posis[Int(planet_idx)][Int(frame)])
            if length(current_tail) > 50
                deleteat!(current_tail, 1)
            end
            start_posis[Int(planet_idx)] = posis[Int(planet_idx)][Int(frame)]
        end
        notify(planets)
        notify.(tails)
    end
end


function tester(frames, skip)
    println("simulating...")
    hists = simulate(frames)
    println("rendering...")
    animate(hists, frames/skip)
end


function dist(p1, p2)
    √sum((p2.posi-p1.posi) .^ 2)
end