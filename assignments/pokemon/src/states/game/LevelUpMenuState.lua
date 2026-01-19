--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelUpMenuState = Class{__includes = BaseState}

function LevelUpMenuState:init(battleState)
    self.battleState = battleState
    
    self.levelUpMenu = Menu {
        x = VIRTUAL_WIDTH - 64,
        y = VIRTUAL_HEIGHT - 192,
        width = 64,
        height = 128,
        items = {
            {
                text = 'Test1'
            },
            {
                text = 'Test2'
            }
        },
        selectionOn = false
    }
end

function LevelUpMenuState:update(dt)
    self.levelUpMenu:update(dt)
end

function LevelUpMenuState:render()
    self.levelUpMenu:render()
end
