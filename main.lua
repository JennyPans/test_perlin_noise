local line
local SCALE = 75
local SCREEN_WIDTH = love.graphics.getWidth()
local SCREEN_HEIGHT = love.graphics.getHeight()
local seed = love.math.random(1000)
local time = 0
local PLANET_WIDTH = 60 * 7
local PLANET_HEIGHT = 60 * 7
local canvas = love.graphics.newCanvas(PLANET_WIDTH, PLANET_HEIGHT)

local plan_to_sphere = love.graphics.newShader([[
  const number pi = 3.14159265;
  const number pi2 = 2.0 * pi;
  extern number time;
  vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pixel_coords)
  {
    vec2 p = 2.0 * (tc - 0.5);
    
    number r = sqrt(p.x*p.x + p.y*p.y);
    if (r > 1.0) discard;
    
    number d = r != 0.0 ? asin(r) / r : 0.0;
          
    vec2 p2 = d * p;
    
    number x3 = mod(p2.x / (pi2) + 0.5 + time, 1.0);
    number y3 = p2.y / (pi2) + 0.5;
    
    vec2 newCoord = vec2(x3, y3);
    
    vec4 sphereColor = color * Texel(texture, newCoord);
          
    return sphereColor;
  }
  ]])

local function normalize(value, min, max)
    return (value - min) / (max - min)
end

local function generate_ground()
    line = {}
    local min = 0
    local max = 0
    for l = 1, PLANET_HEIGHT do
        line[l] = {}
        for n = 1, PLANET_WIDTH do
            local noise = love.math.noise((n + seed) / SCALE, (l + seed) / SCALE)
            line[l][n] = noise
            if noise < min or min == 0 then min = noise end
            if noise > max then max = noise end
        end
    end
    for l = 1, PLANET_HEIGHT do
        for n = 1, PLANET_WIDTH do
            line[l][n] = normalize(line[l][n], min, max)
        end
    end
end

function love.keypressed(key)
    generate_ground()
end

function love.load()
    -- love.graphics.setDefaultFilter("nearest", "nearest")
    generate_ground()
end

function love.update(dt)
    seed = seed + 50 * dt
    generate_ground()
    plan_to_sphere:send("time", time)
    time = time +  dt * -0.1

end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    local amplitude = 20
    for l = 1, PLANET_HEIGHT, 4 do
        for n = 1, PLANET_WIDTH, 4 do
            love.graphics.points(n, l + (line[l][n] * amplitude))
        end
    end
    love.graphics.setCanvas()
    love.graphics.setShader(plan_to_sphere)
    love.graphics.draw(
        canvas,
        SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2,
        0,
        1, 1,
        PLANET_WIDTH / 2, PLANET_HEIGHT / 2
    )
    love.graphics.setShader()
end