graphics = {}

function graphics.new_animation(image, width, height, duration, loop)
    if loop == nil then
        loop = true
    end

    local animation = {}
    function animation:play(dt)
        if self.finished then
            return
        end
        self.currentTime = self.currentTime + dt
        if self.currentTime >= self.duration then
            if self.loop then
                self.currentTime = self.currentTime - self.duration
            else
                self.finished = true
                self.currentTime = self.duration - 0.1
            end
        end
    end
    function animation:current_frame()
        local spriteNum = math.floor(self.currentTime / self.duration * #self.quads) + 1
        return self.quads[spriteNum] or self.quads[0]
    end

    function animation:reset()
        self.finished = false
        self.currentTime = 0
    end

    animation.spriteSheet = image
    animation.quads = {}
    animation.width = width
    animation.height = height
    for y = 0, image:getHeight() - animation.height, animation.height do
        for x = 0, image:getWidth() - animation.width, animation.width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, animation.width, animation.height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0
    animation.loop = loop

    return animation
end

return graphics