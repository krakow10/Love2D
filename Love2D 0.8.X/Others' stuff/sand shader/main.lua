
--[=[
--]=]

local floor = math.floor
local rect = love.graphics.rectangle



fluid = love.graphics.newPixelEffect [[

    const float size = 1.0/512.0;
    const vec4 blue = vec4(0.2,0.2,0.8,1.0);

    vec4 effect(vec4 global_color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
        vec4 pixel = Texel(texture, texture_coords);
        vec4 upper = Texel(texture, vec2(texture_coords.x, texture_coords.y+size));
        vec4 lower = Texel(texture, vec2(texture_coords.x, texture_coords.y-size));
        vec4 ll = Texel(texture, vec2(texture_coords.x-size, texture_coords.y-size));
        vec4 lr = Texel(texture, vec2(texture_coords.x+size, texture_coords.y-size));
        vec4 ul = Texel(texture, vec2(texture_coords.x-size, texture_coords.y+size));
        vec4 ur = Texel(texture, vec2(texture_coords.x+size, texture_coords.y+size));
        vec4 l = Texel(texture, vec2(texture_coords.x-size, texture_coords.y));
        vec4 r = Texel(texture, vec2(texture_coords.x+size, texture_coords.y));

        if (pixel.b == 1.0) { //its solid, skip it
            return pixel;
        }
            
        if (lower.b == 1.0){
            if (pixel.r == 1.0) {
                return pixel;
            }
            else if (upper.r == 1.0) {
                pixel.g = min (1.0-pixel.g, upper.g);
                return upper;
            }
        }    
        
        if (pixel.r != 1.0 && upper.r == 1.0) {
            return upper; //needs changing
        }     


         if (lower.r != 1.0 && pixel.r == 1.0 ) {
            return vec4(0.0);
            
        }
    else
        return pixel;
    }
]]



drawer = love.graphics.newPixelEffect [[


    const vec4 blue = vec4(0.2,0.2,0.8,1.0);

 vec4 effect(vec4 global_color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
        vec4 pixel = Texel(texture, texture_coords);

        if (pixel.r == 1.0) {
            return blue;//needs changing
        }
        else if (pixel.b == 1.0) {
            return vec4(1.0);
        }

    }


]]






local fb1 = love.graphics.newCanvas()
local fb2= love.graphics.newCanvas()
local drawing = love.graphics.newCanvas()

local screensize = love.graphics.getWidth()

local tilesize = 8
local tilenumber = screensize/tilesize
local t = {}

for i = 0, tilenumber-1 do for j = 0, tilenumber-1 do
    if not t[i] then t[i] = {} end
    t[i][j] = {f = 0}
end end





local x,y
function love.mousepressed(x,y,button)
x = floor((x)/tilesize)
y = floor((y)/tilesize)

    if button == "r" then
        if t[x][y].solid then
            t[x][y].f = 0
            t[x][y].solid = nil
        else
            t[x][y].solid = true
        end
    end
end


function love.draw()
    drawing:clear()
    love.graphics.setCanvas(drawing)
    if love.mouse.isDown("l") then
        local x,y = love.mouse.getPosition()
        love.graphics.setColor(255,100,0,255)
        love.graphics.rectangle("fill", x,y,5,5 )
    end


    for i = 0, tilenumber-1 do
        for j = 0, tilenumber-1 do
            if t[i][j].solid then
                love.graphics.setColor(0,0,255,255)
                rect("fill", i*tilesize, j*tilesize, tilesize,tilesize)
            end
        end 
    end

    love.graphics.setColor(255,255,255,255)

    love.graphics.setCanvas(fb1)
        love.graphics.setPixelEffect(fluid)
        love.graphics.draw(fb2)
        love.graphics.draw(drawing)
       

    
    
    love.graphics.setPixelEffect()
    fb2:clear()
    love.graphics.setCanvas(fb2)
    love.graphics.draw(fb1)
    love.graphics.setCanvas()

    fb1:clear()
    love.graphics.setPixelEffect(drawer)
    love.graphics.draw(fb2)
    love.graphics.setPixelEffect()
    love.graphics.print(love.timer.getFPS(), 20, 20)

  
   
   
end
