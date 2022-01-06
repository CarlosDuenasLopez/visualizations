using GLMakie

function example()
    points = Node(Point2f[randn(2)])
    println("yo")
    fig, ax = scatter(Point2f(5, 1))
    fps = 60
    nframes = 120
    current_figure()
    for i = 1:nframes
        new_point = Point2f(randn(2))
        points[] = push!(points[], new_point)
        sleep(1/fps) # refreshes the display!
    end
end

function another()
    scatter(Point2f(2, 1))
end