--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelUpMenuState = Class{__includes = BaseState}

function LevelUpMenuState:init(playerPokemon, levelUpValues)
    self.HPIncrease = levelUpValues[1]
    self.attackIncrease = levelUpValues[2]
    self.defenseIncrease = levelUpValues[3]
    self.speedIncrease = levelUpValues[4]

    self.HP = playerPokemon.HP
    self.attack = playerPokemon.attack
    self.defense = playerPokemon.defense
    self.speed = playerPokemon.speed

    self.startHP = self.HP - self.HPIncrease
    self.startAttack = self.attack - self.attackIncrease
    self.startDefense = self.defense - self.defenseIncrease
    self.startSpeed = self.speed - self.speedIncrease
    
    self.levelUpMenu = Menu {
        x = VIRTUAL_WIDTH - 192,
        y = VIRTUAL_HEIGHT - 192,
        width = 192,
        height = 160,
        items = {
            {
                text = 'HP: ' .. tostring(self.startHP) .. ' + ' .. tostring(self.HPIncrease) .. ' = ' .. tostring(self.HP)
            },
            {
                text = 'Attack: ' .. tostring(self.startAttack) .. ' + ' .. tostring(self.attackIncrease) .. ' = ' .. tostring(self.attack)
            },
            {
                text = 'Defense: ' .. tostring(self.startDefense) .. ' + ' .. tostring(self.defenseIncrease) .. ' = ' .. tostring(self.defense)
            },
            {
                text = 'Speed: ' .. tostring(self.startSpeed) .. ' + ' .. tostring(self.speedIncrease) .. ' = ' .. tostring(self.speed)
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
