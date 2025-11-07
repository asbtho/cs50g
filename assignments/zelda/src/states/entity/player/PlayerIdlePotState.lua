--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdlePotState = Class{__includes = EntityIdleState}

function PlayerIdlePotState:enter(params)
    
    -- render offset for spaced character sprite (negated in render function of state)
    self.entity.offsetY = 5
    self.entity.offsetX = 0

    self.potObject = nil

    for k, object in pairs(self.dungeon.currentRoom.objects) do
        if object.state == 'pickedup' then
            self.potObject = object
        end
    end

    self.potObject.x = self.entity.x
    self.potObject.y = self.entity.y


    self.entity:changeAnimation('pot-idle-' .. self.entity.direction)
end

function PlayerIdlePotState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk-pot')
    end
end
