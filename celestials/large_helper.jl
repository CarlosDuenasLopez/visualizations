using LinearAlgebra:norm

dist(p1, p2) = √sum((p2-p1) .^ 2)

G = 6.67408f-11
calc_force(distance, m1, m2) = G * ((m1 * m2) / distance^2)

function calc_acceleration(posi1, posi2, m1, m2)
    F = calc_force(dist(posi1, posi2), m1, m2)
    a = F / m1
    connection_vector =  posi2 - posi1
    normed = connection_vector ./ norm(connection_vector)
    normed .* a
end