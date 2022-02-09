using Distributed
@everywhere using GeometryBasics
@everywhere using LinearAlgebra:norm
@everywhere using DataStructures:CircularBuffer
using LoopVectorization

@everywhere mutable struct Body
    posi::Point
    velocity::Vector{Float32}
    mass::BigFloat
    size::Float32
end

@everywhere dist(p1, p2) = √sum((p2.posi-p1.posi) .^ 2)

@everywhere function gen_bodies(num, radius, avg_mass, mass_deviation, speed=0.3)
    # Generate num bodies in circular shape with velocities in direction perpendicular to circle center.
    bodies = Body[]
    for _ in 1:num
        my_angle = rand(1:360*100) / 100
        dist = rand(1:radius*100) / 100
        x = cosd(my_angle) * dist
        y = sind(my_angle) * dist
        z = rand(-1:0.01:1)
        velocity = [-y, x, z] ./ 10
        # velocity = velocity / norm(velocity) * speed
        mass = rand(avg_mass-mass_deviation:avg_mass+mass_deviation)
        push!(bodies, Body(Point(x, y, z), velocity, mass, 2))
    end
    bodies
end

@everywhere function calc_f(particle::Body, other::Body)
    G = 6.67408f-11
    r = dist(particle, other)
    if r < particle.size/2 + other.size/2
        r = particle.size/2 + other.size/2
    end
    F = G * (particle.mass * other.mass) / r^2
    return F
end

@everywhere function calc_acceleration(particle::Body, all_particles::Vector{Body})
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
    a_vec
end

@everywhere function multiple_accelerations(compute_bodies::Vector{Body}, all_bodies::Vector{Body})
    accs = Vector{Vector{Float32}}()
    for body in compute_bodies
        push!(accs, calc_acceleration(body, all_bodies))
    end
    accs
end

function main_dist(num_bodies)
    bodies = gen_bodies(num_bodies, 10, 20e8, 20e4)
    segments = Vector()
    step = Int(num_bodies / nprocs())
    start = 1
    for i in step:step:num_bodies
        push!(segments, bodies[start:i])
        start = i+1
    end

    r = @distributed append! for s in segments
        multiple_accelerations(s, bodies)
    end
    
end

function main_slow(num_bodies)
    bodies = gen_bodies(num_bodies, 10, 20e8, 20e4)
    multiple_accelerations(bodies, bodies)
end