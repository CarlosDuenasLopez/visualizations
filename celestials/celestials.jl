using GLMakie
using GeometryBasics
using LinearAlgebra:norm

mutable struct Body
    posi::Point
    velocity::Vector{Float64}
    mass::BigFloat
end

function gen_bodies(num, radius, avg_mass, mass_deviation, speed=1)
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
        # velocity = [0, 0, 0]
        mass = rand(avg_mass-mass_deviation:avg_mass+mass_deviation)
        push!(bodies, Body(Point(x, y, z), velocity, mass))
    end
    bodies
end

bodies = gen_bodies(1000, 10, 10, 5)
starts = [b.posi for b in bodies]
posis = Observable([b.posi for b in bodies])
num_bodies = Observable(1000)
mass = Observable(1)

on(num_bodies) do num
    global bodies = gen_bodies(num, 10, 10, 5)
    global posis[] = [b.posi for b in bodies]
    global starts = [b.posi for b in bodies]
    println("Now there are $num bodies")
end

on(mass)do mass
    for b in bodies
        b.mass = mass
    end
    println("Everything now has a mass of $mass")
end


function move!(bodies::Vector{Body}, posis)
    for b in bodies
        b.posi += b.velocity ./20
    end
    posis[] = [b.posi for b in bodies]
end


function makefig()
    set_theme!(theme_black())
    fig = Figure()
    ax = Axis3(fig[1, 1:2])
    screen = display(fig)
    resize!(screen, 1500, 1500)
    scatter!(ax, posis, markersize = 2000)
    play = Button(fig[2, 1]; label = "play", tellwidth=false)
    reset = Button(fig[2, 2]; label = "reset", tellwidth=false)
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
            sleep(0.01)
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
    end
end

