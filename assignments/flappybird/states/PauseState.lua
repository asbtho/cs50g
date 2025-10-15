PauseState = Class{__includes = BaseState}

function PauseState:update(dt)
    if love.keyboard.wasPressed('p') then
        gStateMachine:change('play', {
            bird = self.bird,
            pipePairs = self.pipePairs,
            timer = self.timer,
            score = self.score
        })
    end
end

function PauseState:enter(params)
    -- keep state from play state
    self.bird = params.bird
    self.pipePairs = params.pipePairs
    self.timer = params.timer
    self.score = params.score

    -- pause sound and stop music 
    sounds['pause']:play()
    sounds['music']:pause()
    -- stop scrolling since paused
    scrolling = false
end

function PauseState:exit()
    -- start music and scrolling
    sounds['pause']:play()
    sounds['music']:play()
    scrolling = true
end

function PauseState:render()
    -- only render images
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()

    -- new text for paused
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Paused', 0, 64, VIRTUAL_WIDTH, 'center')
end
