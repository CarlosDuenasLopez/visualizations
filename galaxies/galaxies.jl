using LinearAlgebra:norm
using GeometryBasics

mutable struct Particle
    posi::Point
    velocity::Point
    mass::Float64
end

function step!(particle::Particle, all_particles::Vector{Partice}, dt::Float64)
    a = Point(0, 0, 0)
    
    for other in all_particles
        a += calculate_acc(particle, other)
    end

    particle.velocity += a
    particle.posi += particle.velocity * dt
end


function calculate_acc(p1, p2)
    G = 6.674f-11
    F = G * (p1.mass * p2.mass) / dist(p1, p2)
    og_vec = p2-p1
    og_vec = og_vec / norm(og_vec) * F
    return og_vec
end


function dist(p1, p2)
    √sum((p2-p1) .^ 2)
end