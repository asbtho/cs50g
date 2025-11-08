--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- throwable for pot
    self.projectile = false
    self.projectileGravity = 150
    self.projectileDirection = 'left'
    self.dx = 150
    self.dy = 150
    self.dxdy = 0
    self.firedFromX = 0
    self.firedFromY = 0
    self.removed = false

    -- default empty collision callback
    self.onCollide = function() end
end

function GameObject:update(dt)
    if self.projectile then
        self.dxdy = self.dxdy + ( self.projectileGravity * dt ) 
        if self.projectileDirection == 'left' then
            self.x = self.x - (self.dx * dt)
            self.y = self.y + (self.dxdy * dt)

            if ( self.firedFromX - self.x ) > ( 5 * (TILE_SIZE) ) then
                self:breakPot()
            end

            if self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then 
                self.x = MAP_RENDER_OFFSET_X + TILE_SIZE
                self:breakPot()
            end
        elseif self.projectileDirection == 'right' then
            self.x = self.x + (self.dx * dt)
            self.y = self.y + (self.dxdy * dt)

            if ( self.x - self.firedFromX ) > ( 5 * (TILE_SIZE) ) then
                self:breakPot()
            end

            if self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
                self.x = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.width
                self:breakPot()
            end
        elseif self.projectileDirection == 'up' then
            self.y = self.y - (self.dy * dt)

            if ( self.firedFromY - self.y ) > ( 4 * (TILE_SIZE) ) then
                self:breakPot()
            end

            if self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2 then 
                self.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2
                self:breakPot()
            end
        elseif self.projectileDirection == 'down' then
            self.y = self.y + (self.dy * dt)

            if ( self.y - self.firedFromY ) > ( 4 * (TILE_SIZE) ) then
                self:breakPot()
            end

            local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE

            if self.y + self.height >= bottomEdge then
                self.y = bottomEdge - self.height
                self:breakPot()
            end
        end
    end
end

function GameObject:collides(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                self.y + self.height < target.y or self.y > target.y + target.height)
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end

function GameObject:fire()
    self.firedFromX = self.x
    self.firedFromY = self.y
end

function GameObject:breakPot()
    self.state = 'destroyed'
    self.solid = false
    self.projectile = false
    gSounds['hit-enemy']:play()
end
