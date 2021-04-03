ui = {}

ui.contains = function(x, y, a1, b1, a2, b2)
    return not (x < a1 or x > a2 or y < b1 or y > b2)
end

ui.container = function()
    local c = {}
    c.children = {}
    function c:draw()
        for _, child in ipairs(self.children) do
            child:draw()
        end
    end
    function c:handle_event(evt, ...)
        for _, child in ipairs(self.children) do
            child[evt](child, ...)
        end
    end
    function c:append(child)
        table.insert(self.children, child)
    end
    return c
end

ui.box = function(x, y, w, h)
    local box = {
        x = x,
        y = y,
        w = w,
        h = h,
        x2 = x + w,
        y2 = y + h,
        visible = true,
        draw_background = false,
        draw_border = true,
        border = {r = 255, g = 255, b = 255, a = 255},
        background = {r = 0, g = 0, b = 0, a = 255},
        drawlist = {}
    }
    function box:draw()
        if box.visible then
            if self.draw_background then
                gfx.fillRect(self.x, self.y, self.w, self.h, self.background.r, self.background.g, self.background.b,  self.background.a)
            end
            if self.draw_border then
                gfx.drawRect(self.x, self.y, self.w, self.h, self.border.r, self.border.g, self.border.b, self.border.a)
            end
            for _, f in ipairs(self.drawlist) do
                f(self)
            end
        end
    end
    function box:drawadd(f)
        table.insert(self.drawlist, f)
    end
    function box:set_backgroud(r, g, b, a)
        self.background.r = r
        self.background.g = g
        self.background.b = b
        self.background.a = a
    end
    function box:set_border(r, g, b, a)
        self.border.r = r
        self.border.g = g
        self.border.b = b
        self.border.a = a
    end
    return box
end

ui.text = function(x, y, text, r, g, b, a)

end

ui.button = function(x, y, w, h, text, f)
    local button = ui.box(x, y, w, h)
    button.enabled = true
    button.hover = false
    button.background = {r = 255, g = 255, b = 255, a = 60}
    button:drawadd(function(self)
        local tw, th = gfx.textSize(text)
        th = th - 3 -- for some reason it's 3 too many
        self.draw_background = self.hover
        gfx.drawText(self.x + self.w/2 - tw/2, self.y + self.h/2 - th/2, text)
        
    end)
    function button:mousemove(x, y, dx, dy)
        self.hover = ui.contains(x, y, self.x, self.y, self.x2, self.y2)
    end
    function button:mousedown(x, y, dx, dy)

    end
    return button
end

return ui