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
    all_parts = [sun, earth]
    earth_posis = []

    for i in 1:iterations
        push!(earth_posis, earth.posi)
        step!(all_parts)
    end

    earth_posis
    # "yo"
end


function animate(posis, frames)
    set_theme!(theme_black())
    fig = Figure(resolution = (1000, 1000))
    ax = Axis3(fig[1, 1], aspect = (1, 1, 1),
    limits = (-10f11/4, 10f11/4, -10f11/4, 10f11/4, -10f11/4, 10f11/4,))

    sun = Point(0, 0, 0)
    earth = posis[1]
    planets = Node([sun, earth])

    scatter!(planets, color=:white, markersize=5000)
    record(fig, "movie.gif", 1:frames, framerate = 30) do frame
        planets[][2] = posis[Int(frame)]
        notify(planets)
    end
end


function tester(frames, skip)
    println("simulating...")
    hists = simulate(frames)
    println("rendering...")
    animate(hists[1:skip:frames], frames/skip)
end


function dist(p1, p2)
    √sum((p2.posi-p1.posi) .^ 2)
end