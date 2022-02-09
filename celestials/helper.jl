function calc_f(particle::Body, other::Body)
    G = 6.67408f-11
    r = dist(particle, other)
    if r < particle.size/2 + other.size/2
        r = particle.size/2 + other.size/2
    end
    F = G * (particle.mass * other.mass) / r^2
    return F
end

function update_velocity!(particle::Body, all_particles::Vector{Body})
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
    particle.velocity += a_vec .* dt[]
end