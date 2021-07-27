function love.load()
    baseX = 300
    baseY = 400
    radius = 100
    offsetY = radius*.5*math.sqrt(3)
    love.graphics.setBackgroundColor(255,255,255)
end

function love.draw()
    love.graphics.setColor(255, 0, 0, 100)
    love.graphics.circle('fill', baseX, baseY, radius, 50)
    love.graphics.setColor(0, 255, 0, 100)
    love.graphics.circle('fill', baseX + radius / 2, baseY - offsetY, radius, 50)
    love.graphics.setColor(0, 0, 255, 100)
    love.graphics.circle('fill', baseX + radius, baseY, radius, 50)
end
