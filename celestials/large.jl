# using GLMakie
using GeometryBasics
using LinearAlgebra:norm
using DataStructures:CircularBuffer, DefaultDict

include("large_helper.jl")

mutable struct Body
    posi::Point
    velocity::Vector{Float64}
    mass::BigFloat
    gridinfo::Dict{Real, Point3}

    Body(posi, velocity, mass) = new(posi, velocity, mass, Dict())
end

function determine_field(body, field_size)
    base = collect(body.posi .÷ field_size)
    for cord_idx in 1:length(base)
        base[cord_idx] = (body.posi[cord_idx] > 0) ? 1 : -1
    end
    base
end

Body(x::Real, y::Real) = Body(Point(x, y, 0), [0, 0, 0], 10)

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
        # velocity = [0, 0, 0]
        mass = rand(avg_mass-mass_deviation:avg_mass+mass_deviation)
        push!(bodies, Body(Point(x, y, z), velocity, mass))
    end
    bodies
end

gen_bodies(num) = gen_bodies(num, 10, 10, 0)


dist(p1, p2) = √sum((p2-p1) .^ 2)

const BOUND = 100
const REACH = 3
const FIELD_SIZES = [1, 5, 20, 50]
const dt = 1


function calc_gridinfo!(body)
    for size in FIELD_SIZES
        body.gridinfo[size] = determine_field(body, size)
    end
end

function update_gridinfos!(bodies)
    for b in bodies
        calc_gridinfo!(b)
    end
end

function specific_grid!(bodies::Vector{Body}, field_size::Real)
    d = DefaultDict(Vector{Body})
    for b in bodies
        field = determine_field(b, field_size)
        push!(d[field], b)
        b.gridinfo[field_size] = field
    end
    d
end

function all_grids!(bodies)
    d = Dict()
    for size in FIELD_SIZES
        d[size] = specific_grid!(bodies, size)
    end
    d
end

function neighbors(body, grids, field_size)
    field_cords = body.gridinfo[field_size]
    # keys = field_cords .+ generate_adders()                 # does NOT work
    mykeys = [a + field_cords for a in generate_adders()]     # does work
    d = grids[field_size]
    [key for key in mykeys if key in keys(d)]
end

function generate_adders()
    positives = [[x, y, z] for x in 0:1 for y in 0:1 for z in 0:1][2:end]
    negatives = positives .* -1
    append!(positives, negatives)
end

calculate_mass_sum(bodies) = sum([body.mass for body in bodies])

function get_mass_dict(spec_grid)
    d = Dict()
    for key in keys(spec_grid)
        d[key] = calculate_mass_sum(spec_grid[key])
    end
    d
end

function get_all_mass_dicts(grids)
    d = Dict()
    for key in keys(grids)
        d[key] = get_mass_dict(grids[key])
    end
    d
end

get_raw_cords(size, field_cords) = field_cords .* size .- size/2

function step!(bodies, grids)
    mass_dicts = get_all_mass_dicts(grids)
    for body in bodies
        a_vec = Float32[0, 0, 0]
        for size in FIELD_SIZES
            relevant_mass_dict = mass_dicts[size]
            relevant_grid = grids[size]
            # get neighboring fields for this size
            my_neighbors = neighbors(body, grids, size)
            # for each neighboring field:
            for neighbor in my_neighbors
                # get mass in that field
                field_mass = relevant_mass_dict[neighbor]
                # calculate force to that field
                raw_field_cords = get_raw_cords(size, neighbor)

                a_vec += calc_acceleration(body.posi, raw_field_cords, body.mass, field_mass) * dt
                # add to a_vec accordingly
                # p1 = body.posi; p2 = size * 1
            end
        end
        # add a_vec to body.velocity
        body.velocity += a_vec * dt
        body.posi += body.velocity * dt
    end
end