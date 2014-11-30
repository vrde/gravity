function love.load()
    MASS_CONSTANT = 1
    TRAIL_LENGTH = 100
    TRAIL_SAMPLING = 0.1
    trailTimer = 0

    bodies = { }
    addbody(400, 300, 3000, 0, 0)
end

function radius(area)
    r = math.sqrt(area / math.pi) / 10
    if r < 1 then
        r = 2
    end
    return r
end


function addbody(x, y, m, vx, vy)
    body = {}
    body.x = x
    body.y = y
    body.m = m
    body.vx = vx
    body.vy = vy
    body.r = radius(m)
    body.sides = r * 2
    body.selected = false
    body.trail = {}
    for i=10,1 do
        table.insert(body.trail, {x, y})
    end
    body.lastTrail = TRAIL_LENGTH

    table.insert(bodies, body)
    return body
end


function getbody(x, y)
    for i, a in pairs(bodies) do
        if math.pow(x - a.x, 2) + math.pow(y - a.y, 2) < math.pow(a.r, 2) then
            return a
        end
    end
end


function collide(a, b)
    local min = math.pow(a.r - b.r, 2)
    local mid = math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2)
    local max = math.pow(a.r + b.r, 2)
    return min <= mid and mid <= max
end


function resetSelected()
    for i, a in pairs(bodies) do
        a.selected = false
    end
end

function updateTrail(a)
    a.trail[a.lastTrail] = { x=a.x, y=a.y }
    a.lastTrail = ((a.lastTrail + 1) % TRAIL_LENGTH)
end

function update(a, b, dt)
    dx = a.x - b.x
    dy = a.y - b.y
    mag = dt * (math.pow((dx * dx + dy * dy), -1.5))
    am = a.m * MASS_CONSTANT * mag
    bm = b.m * MASS_CONSTANT * mag
    
    if not a.lock then
        a.vx = a.vx - dx * bm
        a.vy = a.vy - dy * bm
    end

    if not b.lock then
        b.vx = b.vx + dx * am
        b.vy = b.vy + dy * am
    end
end


function love.update(dt)

    if love.keyboard.isDown("a") then
        currentBody.vx = currentBody.vx - 0.4
    end
    if love.keyboard.isDown("d") then
        currentBody.vx = currentBody.vx + 0.4
    end
    if love.keyboard.isDown("s") then
        currentBody.vy = currentBody.vy + 0.4
    end
    if love.keyboard.isDown("w") then
        currentBody.vy = currentBody.vy - 0.4
    end
    if love.keyboard.isDown("k") then
        currentBody.m = currentBody.m + 1000
        currentBody.r = radius(currentBody.m)
        currentBody.sides = currentBody.r * 2
    end
    if love.keyboard.isDown("j") then
        currentBody.m = currentBody.m - 1000
        currentBody.r = radius(currentBody.m)
        currentBody.sides = currentBody.r * 2
    end
    if love.keyboard.isDown("l") then
        currentBody.lock = true
    end


    for i, a in pairs(bodies) do
        for j, b in pairs(bodies) do
            if a ~= b then
                update(a, b, dt)
            end
        end
    end

    for i, a in pairs(bodies) do
        if not a.lock then
            a.x = a.x + a.vx * dt
            a.y = a.y + a.vy * dt
        end
    end
    --[[
    local collisions = {}
    for i, a in pairs(bodies) do
        for j, b in pairs(bodies) do
            if a ~= b then
                if collide(a, b) then
                    collisions[{math.min(i, j), math.max(i, j)}] = true
                end
            end
        end
    end

    local a, b
    for objects, i in pairs(collisions) do
        a, b = bodies[objects[1] ], bodies[objects[2] ]
        a.m = a.m + b.m
        a.r = radius(a.m)
        a.sides = r * 2
    end

    for objects, i in pairs(collisions) do
        table.remove(bodies, objects[2])
    end
    --]]

    trailTimer = trailTimer + dt
    if trailTimer > TRAIL_SAMPLING then
        for i, a in pairs(bodies) do
            updateTrail(a)
        end
        trailTimer = trailTimer - TRAIL_SAMPLING
    end
end


function drawTrail(a)
    love.graphics.setColor(133, 164, 233, 128)
    for i, p in pairs(a.trail) do
        love.graphics.point(p.x, p.y)
    end
end

function love.draw()
    local r, s
    for i, a in pairs(bodies) do
        if a.selected then
            love.graphics.setColor(255, 128, 128)
        elseif a.lock then
            love.graphics.setColor(128, 128, 128)
        else
            love.graphics.setColor(255, 255, 255)
        end
        love.graphics.circle("fill", a.x, a.y, a.r, a.sides)
        love.graphics.setColor(133, 164, 233, 64)
        love.graphics.line(a.x, a.y, a.x + a.vx, a.y + a.vy)
        drawTrail(a)
    end
end


function love.mousepressed(x, y, button)
    local newBody
    if love.mouse.isDown("l") then
        newBody = getbody(love.mouse.getX(), love.mouse.getY())
        if newBody then
            currentBody = newBody
            resetSelected()
            currentBody.selected = true
        end
    elseif love.mouse.isDown("r") then
        currentBody = addbody(love.mouse.getX(), love.mouse.getY(), 3000, 0, 0)
        resetSelected()
        currentBody.selected = true
    end
end



love.window.setMode(800, 800, {fsaa=4})

