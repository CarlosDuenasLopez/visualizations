using GLMakie
using GeometryBasics
using LinearAlgebra:norm
using DataStructures:CircularBuffer

mutable struct Body
    posi::Point
    velocity::Vector{Float64}
    mass::BigFloat
end

function gen_bodies(num, radius, avg_mass, mass_deviation, speed=0.1)
    # Generate num bodies in circular shape with velocities in direction perpendicular to circle center.
    bodies = Body[]
    for _ in 1:num
        my_angle = rand(1:360*100) / 100
        dist = rand(1:radius*100) / 100
        x = cosd(my_angle) * dist
        y = sind(my_angle) * dist
        z = 0
        velocity = [-y, x, z]
        velocity = velocity / norm(velocity) * speed
        velocity = [0, 0, 0]
        mass = rand(avg_mass-mass_deviation:avg_mass+mass_deviation)
        push!(bodies, Body(Point(x, y, z), velocity, mass))
    end
    bodies
end

RADIUS, MASS, MASS_DEV = 3, 10e7, 0

bodies = gen_bodies(2, RADIUS, MASS, MASS_DEV)
starts = [b.posi for b in bodies]
start_velocitiy = [0, 0, 0]
posis = Observable([b.posi for b in bodies])
num_bodies = Observable(1000)
mass = Observable(BigFloat(1))
dt = Observable(0.001)
body_obs = Observable(Body[])
distance = Observable([dist(Body(Point(0, 0, 0), [0, 0, 0], 0), bodies[1])])
speed = Observable(CircularBuffer{Float64}(1000))
fill!(speed[], 0.0)

on(num_bodies) do num
    global bodies = gen_bodies(num, RADIUS, MASS, MASS_DEV)
    global posis[] = [b.posi for b in bodies]
    global starts = posis[]
    # for (i, b) in enumerate(bodies)
    #     b.velocity = start_velocities[i]
    # end
    println("Now there are $num bodies")
end

on(mass)do mass
    for b in bodies
        b.mass = mass
    end
    println("Everything now has a mass of $mass")
end

on(body_obs) do bs
    global bodies = bs
    global posis[] = [b.posi for b in bodies]
end


function move!(bodies::Vector{Body}, posis)
    for body in bodies
        update_velocity!(body, bodies)
    end
    for b in bodies
        b.posi += b.velocity ./20
    end
    posis[] = [b.posi for b in bodies]
end

function calc_f(particle, other)
    G = 6.67408f-11
    r = dist(particle, other)
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


function makefig()
    set_theme!(theme_black())
    fig = Figure()
    ax = Axis3(fig[1, 1:2], limits = (-10, 10, -10, 10, -10, 10), aspect = (1, 1, 1))
    screen = display(fig)
    resize!(screen, 1500, 1500)
    scatter!(ax, posis, markersize = 2000)
    play = Button(fig[2, 1]; label = "play", tellwidth=false)
    reset = Button(fig[2, 2]; label = "reset", tellwidth=false, color=:blue)
    configure_reset(reset)
    configure_play(play)
    return fig, posis, starts
end

isrunning = Observable(false)

function configure_play(butt)
    on(butt.clicks) do clicks
        isrunning[] = !isrunning[]
    end
    on(butt.clicks) do clicks
        @async while isrunning[]
            move!(bodies, posis)
            distance[][1] = dist(Body(Point(0, 0, 0), [0, 0, 0], 0), bodies[1])
            distance[] = distance[]
            push!(speed[], sum(abs.(bodies[1].velocity)))
            notify(speed)
            sleep(0.000000001)
        end
    end
end

function configure_reset(butt)
    on(butt.clicks) do clicks
        reset_fig!(bodies, posis, starts)
    end
end

function reset_fig!(bodies, posis, start_posis)
    posis[] = start_posis
    for (i, b) in enumerate(bodies)
        b.posi = start_posis[i]
        b.velocity = start_velocities[i]
    end
end

function vs()
    [println(b.velocity) for b in bodies]
    nothing
end

dist(p1, p2) = √sum((p2.posi-p1.posi) .^ 2)

# @async while true
#     if dist(Body(Point(0, 0, 0), [0, 0, 0], 0), bodies[1]) == 0
#         println("they back")
#     end
#     sleep(0.01)
# end
function distance_plot(fig)
    global distance
    ax = Axis(fig[1, 3])
    barplot!([0], distance, strokewidth = 1)
    xlims!(ax, (-1, 1))
    ylims!(ax, (0, 10000))
end

function speed_plot(fig)
    ax = Axis(fig[1, 3])
    lines!(ax, 1:1000, speed)
    ylims!(ax, (-0.1, 20))
end