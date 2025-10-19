--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety
    self.shiny = true

    if self.shiny then
            -- particle system belonging to the brick, emitted on hit
        self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)
        -- various behavior-determining functions for the particle system
        -- https://love2d.org/wiki/ParticleSystem
        -- lasts between 0.5-1 seconds seconds
        self.psystem:setParticleLifetime(0.5, 1.5)
        -- give it an acceleration of anywhere between X1,Y1 and X2,Y2 (0, 0) and (80, 80) here
        -- gives generally downward 
        --self.psystem:setLinearAcceleration(-15, 0, 15, 80)
        -- spread of particles; normal looks more natural than uniform
        self.psystem:setEmissionArea('borderrectangle', 10, 10)
        -- Set emission rate (how many particles are emitted per second)
        self.psystem:setEmissionRate(50)
        -- Set particle speed (how fast particles move)
        self.psystem:setSpeed(50, 150) -- Random speed between 50 and 150 units/second
        -- Set particle direction (upwards for fire)
        self.psystem:setDirection(-math.pi / 2, math.pi / 2) -- Emits in a cone upwards
        -- Set particle spread (how wide the emission cone is)
        self.psystem:setSpread(math.pi / 8) -- A narrow cone for fire
        -- Set particle colors (fade from orange/yellow to transparent)
        self.psystem:setColors(
            255, 100, 0, 255, -- Start color (orange)
            255, 200, 0, 150, -- Middle color (yellowish)
            255, 255, 255, 0  -- End color (transparent white, for fading out)
        )
        -- Set particle sizes (shrink as they fade)
        self.psystem:setSizes(0.5, 0.1) -- Start size 0.5, end size 0.1
        -- Set gravity (optional, for a slight upward pull)
        self.psystem:setLinearAcceleration(0, 0, 0, -20)
        -- Set position (where the fire originates)
        --self.psystem:setPosition(self.x, self.y)
    end
end

function Tile:update(dt)
    self.psystem:update(dt)
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    if self.shiny then
        love.graphics.draw(self.psystem, self.x + x + 16, self.y + y + 32)
    end
end