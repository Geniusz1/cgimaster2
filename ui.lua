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
            if child[evt] then
                child[evt](child, ...)
            end
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
        if self.visible then
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
    local txt = {
        x = x,
        y = y,
        text = text,
        visible = true,
        color = {r = r, g = g, b = b, a = a},
        drawlist = {}
    }
    txt.w, txt.h = gfx.textSize(text)
    txt.x2 = x + txt.w
    txt.y2 = y + txt.h
    function txt:draw()
        if self.visible then
            gfx.drawText(self.x, self.y, text, self.color.r, self.color.g, self.color.b, self.color.a)
        end
    end
    function txt:drawadd(f)
        table.insert(self.drawlist, f)
    end
	function txt:set_color(r, g, b, a) 
        self.color.r = r
        self.color.g = g
        self.color.b = b
        self.color.a = a
    end
    function txt:settext(text) 
        self.text = text
        self.w, self.h = gfx.textSize(text)
    end
	return txt
end

ui.button = function(x, y, w, h, text, f, r, g, b)
    local tw, th = gfx.textSize(text)
    th = th - 4 -- for some reason it's 4 too many
    if w == 0 then w = tw + 7 end
    if h == 0 then h = th + 9 end
    local button = ui.box(x, y, w, h, r, g, b, a)
    button.enabled = true
    button.hover = false
    button.held = false
    button.f = f
    button:set_border(r, g, b)
    button.label = ui.text(x + w/2 - tw/2, y + h/2 - th/2, text, r, g, b, a)
    button.color = {r = r, g = g, b = b}
    button:drawadd(function(self)
        if self.hover then
            gfx.fillRect(self.x+1, self.y+1, self.w-2, self.h-2, self.color.r, self.color.g, self.color.b, 70)
        end
        self.label:draw()
        if not self.held then
            gfx.drawLine(self.x, self.y2, self.x2-2, self.y2, self.color.r, self.color.g, self.color.b)
            gfx.drawLine(self.x-1, self.y+1, self.x-1, self.y2, self.color.r, self.color.g, self.color.b)
        end
    end)
    function button:set_color(r, g, b)
        self.label.color = {
            r = r,
            g = g,
            b = b,
        }
        self.color = {
            r = r,
            g = g,
            b = b,
        }
        self:set_border(r, g, b)
    end
    function button:mousemove(x, y, dx, dy)
        self.hover = ui.contains(x, y, self.x, self.y, self.x2, self.y2)
    end
    function button:mousedown(x, y, button)
        if self.hover then
            self.held = true
            self.x = self.x - 1
            self.y = self.y + 1
            self.label.x = self.label.x - 1
            self.label.y = self.label.y + 1
        end
    end
    function button:mouseup(x, y, button, reason)
        if self.held then
            self.held = false
            self.x = self.x + 1
            self.y = self.y - 1
            self.label.x = self.label.x + 1
            self.label.y = self.label.y - 1
        end
        if self.hover then
            self.f()
        end
    end
    return button
end

ui.checkbox = function(x, y, text, r, g, b)
    local cb = ui.box(x, y, 9, 9)
    cb.checked = false
    cb.label = ui.text(x + 14, y + 1, text, r, g, b)
    cb.hover = false
    cb.held = false
    cb.color = {r = r, g = g, b = b}
    cb:set_backgroud(r, g, b, a)
    cb:drawadd(function (self)
        if self.hover then
            gfx.fillRect(self.x2 + 3, self.y - 1, self.label.w + 3, 11, self.color.r, self.color.g, self.color.b, 50)
        end
        if self.draw_background then
            gfx.drawLine(self.x + 1, self.y + 3, self.x + 3, self.y + 5, 0, 0, 0)
            gfx.drawLine(self.x + 1, self.y + 4, self.x + 3, self.y + 6, 0, 0, 0)
            gfx.drawLine(self.x + 1, self.y + 5, self.x + 3, self.y + 7, 0, 0, 0)
            gfx.drawLine(self.x + 4, self.y + 4, self.x2 - 1, self.y, 0, 0, 0)
            gfx.drawLine(self.x + 4, self.y + 5, self.x2 - 1, self.y + 1, 0, 0, 0)
            gfx.drawLine(self.x + 4, self.y + 6, self.x2 - 1, self.y + 2, 0, 0, 0)
        end
        if self.held then
            gfx.fillRect(self.x + 1, self.y + 1, 7, 7, self.color.r, self.color.g, self.color.b)
        end
        gfx.drawRect(self.x, self.y, 9, 9, self.color.r, self.color.g, self.color.b)
        self.label:draw()
    end)
    function cb:set_color(r, g, b)
        self.label.color = {
            r = r,
            g = g,
            b = b
        }
        self.color = {
            r = r,
            g = g,
            b = b
        }
        self:set_backgroud(r, g, b)
    end
    function cb:mousemove(x, y, dx, dy)
        self.hover = ui.contains(x, y, self.x, self.y, self.x2 + 6 + self.label.w, self.y2)
    end
    function cb:mousedown(x, y, button)
        self.held = self.hover
    end
    function cb:mouseup(x, y, button, reason)
        if self.held then
            self.held = false
        end
        if self.hover then
            self.checked = not self.checked
            self.draw_background = not self.draw_background
        end
    end
    return cb
end

ui.radio_button = function(x, y, text, r, g, b, a)
    local rb = {
        x = x,
        y = y,
        w = 9,
        h = 9,
        x2 = x + 9,
        y2 = y + 9,
        visible = true,
        color = {r = r, g = g, b = b, a = a},
        selected = false,
        label = ui.text(x + 14, y + 1, text, r, g, b, a),
        hover = false,
        held = false
    }
    function rb:draw()
        if self.visible then
            if self.hover then
                gfx.fillRect(self.x2 + 3, self.y - 1, self.label.w + 3, 11, self.color.r, self.color.g, self.color.b, 50)
            end
            if self.selected then
                gfx.fillRect(self.x + 2, self.y + 2, 5, 5, self.color.r, self.color.g, self.color.b, self.color.a)
                gfx.drawLine(self.x + 2, self.y + 2, self.x + 2, self.y + 2, 0, 0, 0)
                gfx.drawLine(self.x + 2, self.y2 - 3, self.x + 2, self.y2 - 3, 0, 0, 0)
                gfx.drawLine(self.x2 - 3, self.y + 2, self.x2 - 3, self.y + 2, 0, 0, 0)
                gfx.drawLine(self.x2 - 3, self.y2 - 3, self.x2 - 3, self.y2 - 3, 0, 0, 0)
            end
            if self.held then
                gfx.fillRect(self.x + 1, self.y + 1, 7, 7, self.color.r, self.color.g, self.color.b, self.color.a)
            end
            -- the 'circle'
            gfx.drawLine(self.x, self.y + 2, self.x, self.y2 - 3, self.color.r, self.color.g, self.color.b, self.color.a)
            gfx.drawLine(self.x2 - 1, self.y + 2, self.x2 - 1, self.y2 - 3, self.color.r, self.color.g, self.color.b, self.color.a)
            gfx.drawLine(self.x + 2, self.y, self.x2 - 3, self.y, self.color.r, self.color.g, self.color.b, self.color.a)
            gfx.drawLine(self.x + 2, self.y2 - 1, self.x2 - 3, self.y2 - 1, self.color.r, self.color.g, self.color.b, self.color.a)
            gfx.drawLine(self.x + 1, self.y + 1, self.x + 1, self.y + 1, self.color.r, self.color.g, self.color.b, self.color.a)
            gfx.drawLine(self.x + 1, self.y2 - 2, self.x + 1, self.y2 - 2, self.color.r, self.color.g, self.color.b, self.color.a)
            gfx.drawLine(self.x2 - 2, self.y + 1, self.x2 - 2, self.y + 1, self.color.r, self.color.g, self.color.b, self.color.a)
            gfx.drawLine(self.x2 - 2, self.y2 - 2, self.x2 - 2, self.y2 - 2, self.color.r, self.color.g, self.color.b, self.color.a)
            -- that was the 'circle'
            self.label:draw()
        end
    end
    function rb:set_color(r, g, b, a)
        self.label.color = {
            r = r,
            g = g,
            b = b,
            a = a
        }
        self.color = {
            r = r,
            g = g,
            b = b,
            a = a
        }
    end
    function rb:mousemove(x, y, dx, dy)
        self.hover = ui.contains(x, y, self.x, self.y, self.x2 + 6 + self.label.w, self.y2)
    end
    function rb:mousedown(x, y, button)
        self.held = self.hover
    end
    function rb:mouseup(x, y, button, reason)
        if self.held then
            self.held = false
        end
        if self.hover then
            self.selected = true
        end
    end
    return rb
end

ui.radio_group = function()
    local rg = {
        buttons = {},
        selected = 0
    }
    function rg:add_button(butt)
        table.insert(self.buttons, butt)
    end
    function rg:set_selected(n)
        self.selected = n
        for _, butt in ipairs(self.buttons) do
            butt.selected = false
        end
        self.buttons[n].selected = true
    end
    function rg:draw()
        for _, butt in ipairs(self.buttons) do
            butt:draw(self)
        end
    end
    function rg:mousemove(x, y, dx, dy)
        for _, butt in ipairs(self.buttons) do
            butt:mousemove(x, y, dx, dy)
        end
    end
    function rg:mousedown(x, y, button)
        for _, butt in ipairs(self.buttons) do
            butt:mousedown(x, y, button)
        end
    end
    function rg:mouseup(x, y, button, reason)
        for i, butt in ipairs(self.buttons) do
            butt:mouseup(x, y, button, reason)
            if butt.hover then
                self.selected = i
                for _, other in ipairs(self.buttons) do
                    if other ~= butt then
                        other.selected = false
                    end
                end
            end
        end
    end
    return rg
end

ui.inputbox = function(x, y, w, h, r, g, b)
end
return ui