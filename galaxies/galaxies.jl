using LinearAlgebra:norm
using GeometryBasics
using GLMakie

mutable struct Particle
    posi::Point
    velocity::Point
    mass::Float64
end

function step!(particle::Particle, all_particles::Vector{Particle}, dt::Real)
    a = Point(0, 0, 0)
    for other in all_particles
        if other != particle
            a += calculate_acc(particle, other)
        end
    end

    old_v = particle.velocity[1]
    particle.velocity += a * dt
    particle.posi += particle.velocity
end


function calculate_acc(p1, p2)
    G = 6.67408f-11
    F = big(G * (big(p1.mass) * big(p2.mass)) / (big(dist(p1, p2))^2)) + big(0.22f22)
    og_vec = p2.posi-p1.posi
    a = big(F) / big(p1.mass)
    normed = og_vec ./ norm(og_vec)
    og_vec = (normed) * (a)
    return og_vec
end


function simulate(iterations)
    sun = Particle(Point(0., 0., 0.), Point(0., 0., 0.), 1.9f30)
    earth = Particle(Point(15f10, 0., 0.), Point(0., 29780f3, 0), 5.9f24)
    all_parts = [sun, earth]
    earth_posis = []

    for i in 1:iterations
        push!(earth_posis, earth.posi)
        step!(earth, all_parts, 2.628f8)
    end

    earth_posis
end


function animate(posis, frames)
    set_theme!(theme_black())
    fig = Figure(resolution = (1000, 1000))
    ax = Axis3(fig[1, 1], aspect = (1, 1, 1),
    limits = (-10f11/4, 10f11/4, -10f11/4, 10f11/4, -10f11/4, 10f11/4,))


    # hidedecorations!(ax)
    # hidespines!(ax)

    sun = Point(0, 0, 0)
    earth = posis[1]
    planets = Node([sun, earth])

    scatter!(planets, color=:white, markersize=5000)

    record(fig, "galaxies.gif", 1:frames, framerate = 30) do frame
        planets[][2] = posis[frame]
        notify(planets)
    end

    current_figure()
    # for frame in 1:frames
    #     # println(frame)
    #     planets[][2] = posis[frame]
    #     notify(planets)
    #     sleep(1/10)
    # end

end


function tester(frames)
    hists = simulate(frames)
    animate(hists, frames)
end


function example()
    points = Node(Point2f[randn(2)])

    fig, ax = scatter(points)
    limits!(ax, -4, 4, -4, 4)

    fps = 60
    nframes = 120

    current_figure()
    for i = 1:nframes
        new_point = Point2f(randn(2))
        points[] = push!(points[], new_point)
        sleep(1/fps) # refreshes the display!
    end
end

function dist(p1, p2)
    √sum((p2.posi-p1.posi) .^ 2)
end