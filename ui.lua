ui = {}

ui.container = function()
    local c = {}
    c.children = {}
    function c:draw()
        for _, child in ipairs(self.children) do
            child:draw()
        end
    end
    return c
end

ui.box = function(x, y, w, h, r, g, b)
    local box = {
        x = x,
        y = y,
        w = w,
        h = h,
        x2 = x + w,
        y2 = y + h,
        r = r or 255,
        g = g or 255,
        b = b or 255,
        visible = true,
        draw_background = false,
        draw_border = true,
        border = {r = 255, g = 255, b = 255},
        background = {r = 0, g = 0, b = 0}
    }
    function box:draw()
        if box.visible then
            if self.draw_background then
                gfx.fillRect(self.x, self.y, self.w, self.h, self.background.r, self.background.g, self.background.b)
            end
            if self.draw_border then
                gfx.drawRect(self.x, self.y, self.w, self.h, self.border.r, self.border.g, self.border.b)
            end
        end
    end
    function box:set_backgroud(r, g, b)
        self.background.r = r
        self.background.g = g
        self.background.b = b
    end
    return box
end

return ui