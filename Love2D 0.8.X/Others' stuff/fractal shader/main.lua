
--[=[
--]=]

local floor = math.floor
local rect = love.graphics.rectangle


fade = love.graphics.newPixelEffect [[
        // REMEMBER TO ADD ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
        const float blurSize = 1.0/512.0; 
        

        vec4 effect(vec4 global_color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {

        vec4 sum = vec4(0.0);
        float fade = 0.0001;
 
       sum += (texture2D(texture, vec2(texture_coords.x - 4.0*blurSize, texture_coords.y)) * 0.05)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x - 3.0*blurSize, texture_coords.y)) * 0.09)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x - 2.0*blurSize, texture_coords.y)) * 0.12)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x - blurSize, texture_coords.y)) * 0.15)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x, texture_coords.y)) * 0.181)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x + blurSize, texture_coords.y)) * 0.15)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x + 2.0*blurSize, texture_coords.y)) * 0.12)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x + 3.0*blurSize, texture_coords.y)) * 0.09)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x + 4.0*blurSize, texture_coords.y)) * 0.05)-fade;
        sum.a = 1;
         
         return sum ;
        }
    ]]

fade2 = love.graphics.newPixelEffect [[
        // REMEMBER TO ADD ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
        const float blurSize = 1.0/512.0; 
        

        vec4 effect(vec4 global_color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {

        vec4 sum = vec4(0.0);
        float fade = 0.00;
 
 sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y - 4.0*blurSize)) * 0.05;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y- 3.0*blurSize)) * 0.09;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y- 2.0*blurSize)) * 0.12;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y - blurSize)) * 0.15;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y)) * 0.16;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y + blurSize)) * 0.15;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y  + 2.0*blurSize)) * 0.12;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y + 3.0*blurSize)) * 0.09;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y + 4.0*blurSize)) * 0.05;
        sum.a = 1;
         
         return sum ;
        }
    ]]


fluid = love.graphics.newPixelEffect [[

    const float size = 1.0/512.0;
    const vec4 blue = vec4(0.2,0.2,0.8,1.0);

    vec4 effect(vec4 global_color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
        vec4 pixel = Texel(texture, texture_coords);
        vec4 upper = Texel(texture, vec2(texture_coords.x, texture_coords.y+size));
        vec4 lower = Texel(texture, vec2(texture_coords.x, texture_coords.y-size));

        if (pixel == 1.0 ) {  
            return pixel;
        }
        if (lower.rgba == 1.0) {
            if (pixel == blue) {
                return pixel;
            }
            else if(upper == blue) {
                return blue;
            }
        }
        
        
        if (upper == blue) {
            if (pixel != blue) {
                return blue;
            }
        }
        else return pixel;

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
        love.graphics.setColor(51,51,204,255)
        love.graphics.rectangle("fill", x,y,5,5 )
    end


    for i = 0, tilenumber-1 do
        for j = 0, tilenumber-1 do
            if t[i][j].solid then
                love.graphics.setColor(255,255,255,255)
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
    love.graphics.draw(fb2)
    love.graphics.print(love.timer.getFPS(), 20, 20)

    --[[
     love.graphics.setPixelEffect()
    love.graphics.setCanvas(fb1)
    love.graphics.draw(fb2)
    if love.mouse.isDown("l") then
        local x,y = love.mouse.getPosition()
       local size = math.random(5,30)
        love.graphics.setColor(255,255,255,255)
        love.graphics.rectangle("fill",x-size/2,y-size/2, size, size) 
            
    elseif love.mouse.isDown("r") then
         local x,y = love.mouse.getPosition()
       local size = math.random(5,30)
        love.graphics.setColor(0,0,0,255)
        love.graphics.rectangle("fill",x-size/2,y-size/2, size, size) 
         love.graphics.setColor(255,255,255,255)
    end

    love.graphics.setCanvas(fb2)
    
        love.graphics.setPixelEffect(fade)
        love.graphics.draw(fb1)
    
    love.graphics.setCanvas()
    love.graphics.setPixelEffect(fade2)
    love.graphics.draw(fb2)
]]
   
   
end
