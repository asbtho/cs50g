--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level

    -- powerup two balls
    self.ballPowerUpPickup = false
    self.spawnPowerUp = false
    self.powerup = Powerup()
    self.powerupTimer = 0
    self.lastScore = params.score

    -- powerup key
    self.keyPowerupPickup = false
    self.spawnKeyPowerup = false
    self.keyPowerup = Powerup()
    self.keyPowerup.skin = 10
    self.keyPowerupTimer = 0

    self.recoverPoints = 5000

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    self:ballsPowerupUpdate(dt)
    self:keyPowerupUpdate(dt)

    -- update positions based on velocity
    self.paddle:update(dt)
    --self.ball:update(dt)
    for k, ball in pairs(self.balls) do
        ball:update(dt)
    end

    --self:updateBallLogic(self.ball)
    for k, ball in pairs(self.balls) do
        self:updateBallLogic(ball)
    end

    for k, ball in pairs(self.balls) do
        if ball.remove then
            table.remove(self.balls, k)
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    if self.spawnPowerUp then
        self.powerup:render()
    end

    if self.spawnKeyPowerup then
        self.keyPowerup:render()
    end

    self.paddle:render()

    for k, ball in pairs(self.balls) do
        ball:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Key is:' .. tostring(self.keyPowerupPickup), 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end

function PlayState:updateBallLogic(inputball)
    -- increase size if points over 
    if self.score - self.lastScore > 800 and self.paddle.size < 3 then
        self.paddle.width = self.paddle.width + 32
        self.paddle.size = self.paddle.size + 1
        self.lastScore = self.score
    end
    if self.score - self.lastScore > 10000 and self.paddle.size < 4 then
        self.paddle.width = 128
        self.paddle.size = 4
    end

    if inputball:collides(self.paddle) then
        -- raise ball above paddle in case it goes below it, then reverse dy
        inputball.y = self.paddle.y - 8
        inputball.dy = -inputball.dy

        --
        -- tweak angle of bounce based on where it hits the paddle
        --

        -- if we hit the paddle on its left side while moving left...
        if inputball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
            inputball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - inputball.x))
        
        -- else if we hit the paddle on its right side while moving right...
        elseif inputball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
            inputball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - inputball.x))
        end

        gSounds['paddle-hit']:play()
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

        -- only check collision if we're in play
        if brick.inPlay and inputball:collides(brick) then

            -- add to score
            if brick.lockedBrick then
                if self.keyPowerupPickup then
                    brick.unlocked = true
                    self.keyPowerupPickup = false
                end
            else
                self.score = self.score + (brick.tier * 200 + brick.color * 25)
            end
             -- trigger the brick's hit function, which removes it from play
            brick:hit()
            
            -- if we have enough points, recover a point of health
            if self.score > self.recoverPoints then
                -- can't go above 3 health
                self.health = math.min(3, self.health + 1)

                -- multiply recover points by 2
                self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                -- play recover sound effect
                gSounds['recover']:play()
            end

            -- go to our victory screen if there are no more bricks left
            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    ball = inputball,
                    recoverPoints = self.recoverPoints
                })
            end

            --
            -- collision code for bricks
            --
            -- we check to see if the opposite side of our velocity is outside of the brick;
            -- if it is, we trigger a collision on that side. else we're within the X + width of
            -- the brick and should check to see if the top or bottom edge is outside of the brick,
            -- colliding on the top or bottom accordingly 
            --

            -- left edge; only check if we're moving right, and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            if inputball.x + 2 < brick.x and inputball.dx > 0 then
                
                -- flip x velocity and reset position outside of brick
                inputball.dx = -inputball.dx
                inputball.x = brick.x - 8
            
            -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            elseif inputball.x + 6 > brick.x + brick.width and inputball.dx < 0 then
                
                -- flip x velocity and reset position outside of brick
                inputball.dx = -inputball.dx
                inputball.x = brick.x + 32
            
            -- top edge if no X collisions, always check
            elseif inputball.y < brick.y then
                
                -- flip y velocity and reset position outside of brick
                inputball.dy = -inputball.dy
                inputball.y = brick.y - 8
            
            -- bottom edge if no X collisions or top collision, last possibility
            else
                
                -- flip y velocity and reset position outside of brick
                inputball.dy = -inputball.dy
                inputball.y = brick.y + 16
            end

            -- slightly scale the y velocity to speed up the game, capping at +- 150
            if math.abs(inputball.dy) < 150 then
                inputball.dy = inputball.dy * 1.02
            end

            -- only allow colliding with one brick, for corners
            break
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    if inputball.y >= VIRTUAL_HEIGHT then
        if #self.balls > 1 then
            inputball.remove = true
        else
            self.health = self.health - 1
            self.paddle.width = 32
            self.paddle.size = 1
        end
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            if #self.balls == 1 then
               gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    recoverPoints = self.recoverPoints
                })
            end
        end
    end
end

function PlayState:ballsPowerupUpdate(dt)
    self.powerupTimer = self.powerupTimer + dt

    -- spawn powerup on interval
    if self.powerupTimer > POWERUP_INTERVAL and not self.spawnPowerUp then
        self.spawnPowerUp = true
        self.powerupTimer = 0
    end

    -- spawn powerup
    if self.spawnPowerUp then
        self.powerup:update(dt)
    end

    -- if powerup is caught enable extra balls
    if self.powerup:collides(self.paddle) then
        gSounds['confirm']:play()
        self.ballPowerUpPickup = true
        self.spawnPowerUp = false
        self.powerup:reset()
    end

    -- remove powerup when out of screen
    if self.powerup.y >= VIRTUAL_HEIGHT then
        self.spawnPowerUp = false
        self.powerup:reset()
    end

    -- extra ball powerup pickup generate two balls
    if self.ballPowerUpPickup then
        for i = 1, 2 do
            extraball = Ball()
            extraball.skin = math.random(7)
            extraball.extra = true
            extraball.x = self.paddle.x + (self.paddle.width / 2) - 4
            extraball.y = self.paddle.y - 8
            extraball.dx = math.random(-200, 200)
            extraball.dy = math.random(-50, -60)
            table.insert(self.balls, extraball)
        end
        self.ballPowerUpPickup = false
    end
end

function PlayState:keyPowerupUpdate(dt)
    self.keyPowerupTimer = self.keyPowerupTimer + dt

    -- spawn powerup on interval
    if self.keyPowerupTimer > KEY_POWERUP_INTERVAL and not self.spawnKeyPowerup then
        self.spawnKeyPowerup = true
        self.keyPowerupTimer = 0
    end

    -- spawn key powerup
    if self.spawnKeyPowerup then
        self.keyPowerup:update(dt)
    end

    -- if powerup is caught enable extra balls
    if self.keyPowerup:collides(self.paddle) then
        gSounds['confirm']:play()
        self.keyPowerupPickup = true
        self.spawnKeyPowerup = false
        self.keyPowerup:reset()
    end

    -- remove powerup when out of screen
    if self.keyPowerup.y >= VIRTUAL_HEIGHT then
        self.spawnKeyPowerup = false
        self.keyPowerup:reset()
    end
end

function PlayState:getKeyStatus()
    return self.keyPowerupPickup
end

function PlayState:resetKeyStatus()
    self.keyPowerupPickup = false
end
