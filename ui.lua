require('socket')

ui = {}

ui.contains = function(x, y, a1, b1, a2, b2)
    return not (x < a1 or x > a2 or y < b1 or y > b2)
end

gfx.drawPixel = function(x, y, r, g, b, a)
    gfx.drawLine(x, y, x, y, r, g, b, a)
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

ui.box = function(x, y, w, h, r, g, b, a, draw_background, draw_border)
    local box = {
        x = x,
        y = y,
        w = w,
        h = h,
        x2 = x + w,
        y2 = y + h,
        visible = true,
        draw_background = draw_background or false,
        draw_border = draw_border or true,
        border = {r = r or 255, g = g or 255, b = b or 255},
        background = {r = r or 0, g = g or 0, b = b or 0, a = a or 255},
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
        color = {r = r or 255, g = g or 255, b = b or 255, a = a or 255},
        drawlist = {},
        hover = false
    }
    txt.w, txt.h = gfx.textSize(text)
    txt.x2 = x + txt.w
    txt.y2 = y + txt.h
    function txt:draw()
        if self.visible then
            gfx.drawText(self.x, self.y, self.text, self.color.r, self.color.g, self.color.b, self.color.a)
            for _, f in ipairs(self.drawlist) do
                f(self)
            end
        end
    end
    function txt:drawadd(f)
        table.insert(self.drawlist, f)
    end
    function txt:mousemove(x, y, dx, dy)
        self.hover = ui.contains(x, y, self.x, self.y, self.x2, self.y2)
    end
	function txt:set_color(r, g, b, a) 
        self.color.r = r
        self.color.g = g
        self.color.b = b
        self.color.a = a
    end
    function txt:set_text(text) 
        self.text = text
        self.w, self.h = gfx.textSize(text)
    end
	return txt
end

ui.fixed_text = function(x, y, max_w, text, r, g, b, a)
    local txt = {
        x = x,
        y = y,
        text = text,
        visible_text = '',
        visible = true,
        color = {r = r or 255, g = g or 255, b = b or 255, a = a or 255},
        drawlist = {}
    }
    txt.w, txt.h = gfx.textSize(text)
    txt.real_x = x
    txt.max_w = max_w
    txt.x2 = x + max_w - 1
    txt.y2 = y + txt.h
    function txt:draw()
        if self.visible then
            self.real_x = self.x
            gfx.drawLine(self.x, self.y-2, self.x2, self.y-2, 255, 0, 0)
            if tpt.textwidth(self.text) > self.max_w then
                self.real_x = self.x2 - tpt.textwidth(self.visible_text)
            end
            gfx.drawText(self.real_x, self.y, self.visible_text, self.color.r, self.color.g, self.color.b, self.color.a)
            for _, f in ipairs(self.drawlist) do
                f(self)
            end
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
    function txt:set_text(text) 
        self.text = text
        self.visible_text = text
        while tpt.textwidth(self.visible_text) > self.max_w do
            self.visible_text = self.visible_text:sub(2)
        end
    end
	return txt
end

ui.button = function(x, y, w, h, text, f, r, g, b)
    local tw, th = gfx.textSize(text)
    th = th - 4 -- for some reason it's 4 too many
    if w == 0 then w = tw + 7 end
    if h == 0 then h = th + 9 end
    x, y = x - 1, y - 1
    local button = ui.box(x, y, w, h, r, g, b, a)
    button.enabled = true
    button.hover = false
    button.held = false
    button.f = f
    button:set_border(r, g, b)
    button.label = ui.text(x + w/2 - tw/2, y + h/2 - th/2, text, r, g, b, a)
    button.color = {r = r or 255, g = g or 255, b = b or 255},
    button:drawadd(function(self)
        local r, g, b = self.color.r, self.color.g, self.color.b
        if not self.enabled then 
            r, g, b = 100, 100, 100
        end
        if self.enabled and self.hover then
            gfx.fillRect(self.x + 1, self.y + 1, self.w-2, self.h-2, self.color.r, self.color.g, self.color.b, 70)
        end
        self.label:draw()
        if not self.held then            
            gfx.drawLine(self.x, self.y2, self.x2-2, self.y2, r, g, b)
            gfx.drawLine(self.x-1, self.y + 1, self.x-1, self.y2, r, g, b)
        end
    end)
    function button:set_color(r, g, b)
        self.label:set_color(r, g, b)
        self.color = {
            r = r,
            g = g,
            b = b,
        }
        self:set_border(r, g, b)
    end
    function button:set_enabled(enabled)
        self.enabled = enabled
        if enabled then
            self.label:set_color(self.color.r, self.color.g, self.color.b)
            self:set_border(self.color.r, self.color.g, self.color.b)
        else
            self.label:set_color(100, 100, 100)
            self:set_border(100, 100, 100)
        end
    end
    function button:mousemove(x, y, dx, dy)
        self.hover = ui.contains(x, y, self.x, self.y, self.x2, self.y2) and self.enabled
    end
    function button:mousedown(x, y, button)
        if self.hover then
            self.held = true
            self.x = self.x - 1
            self.y = self.y + 1
            self.x2 = self.x2 - 1
            self.y2 = self.y2 + 1
            self.label.x = self.label.x - 1
            self.label.y = self.label.y + 1
        end
    end
    function button:mouseup(x, y, button, reason)
        if self.held then
            self.held = false
            self.x = self.x + 1
            self.y = self.y - 1
            self.x2 = self.x2 + 1
            self.y2 = self.y2 - 1
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
    cb.enabled = true
    cb.hover = false
    cb.held = false
    color = {r = r or 255, g = g or 255, b = b or 255},
    cb:set_backgroud(r, g, b)
    cb:drawadd(function (self)
        local r, g, b = self.color.r, self.color.g, self.color.b
        if not self.enabled then 
            r, g, b = 100, 100, 100
        end
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
        gfx.drawRect(self.x, self.y, 9, 9, r, g, b)
        self.label:draw()
    end)
    function cb:set_color(r, g, b)
        self.label:set_color(r, g, b)
        self.color = {
            r = r,
            g = g,
            b = b
        }
        self:set_backgroud(r, g, b)
    end
    function cb:set_enabled(enabled)
        self.enabled = enabled
        if enabled then
            self.label:set_color(self.color.r, self.color.g, self.color.b)
            self:set_backgroud(self.color.r, self.color.g, self.color.b)
        else
            self.label:set_color(100, 100, 100)
            self:set_backgroud(100, 100, 100)
        end
    end
    function cb:mousemove(x, y, dx, dy)
        self.hover = ui.contains(x, y, self.x, self.y, self.x2 + 6 + self.label.w, self.y2) and self.enabled
    end
    function cb:mousedown(x, y, button)
        self.held = self.hover and self.enabled
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
        color = {r = r or 255, g = g or 255, b = b or 255},
        selected = false,
        label = ui.text(x + 14, y + 1, text, r, g, b, a),
        enabled = true,
        hover = false,
        held = false,
        drawlist = {}
    }
    function rb:draw()
        if self.visible then
            local r, g, b = self.color.r, self.color.g, self.color.b
            if not self.enabled then 
                r, g, b = 100, 100, 100
            end
            if self.hover then
                gfx.fillRect(self.x2 + 3, self.y - 1, self.label.w + 3, 11, self.color.r, self.color.g, self.color.b, 50)
            end
            if self.selected then
                gfx.fillRect(self.x + 2, self.y + 2, 5, 5, r, g, b)
                gfx.drawPixel(self.x + 2, self.y + 2, 0, 0, 0) -- top left
                gfx.drawPixel(self.x + 2, self.y2 - 3, 0, 0, 0) -- bottom left
                gfx.drawPixel(self.x2 - 3, self.y + 2, 0, 0, 0) -- top right
                gfx.drawPixel(self.x2 - 3, self.y2 - 3, 0, 0, 0) -- bottom right
            end
            if self.held then
                gfx.fillRect(self.x + 1, self.y + 1, 7, 7, self.color.r, self.color.g, self.color.b)
            end
            -- the 'circle'
            gfx.drawLine(self.x, self.y + 2, self.x, self.y2 - 3, r, g, b)
            gfx.drawLine(self.x2 - 1, self.y + 2, self.x2 - 1, self.y2 - 3, r, g, b)
            gfx.drawLine(self.x + 2, self.y, self.x2 - 3, self.y, r, g, b)
            gfx.drawLine(self.x + 2, self.y2 - 1, self.x2 - 3, self.y2 - 1, r, g, b)
            gfx.drawPixel(self.x + 1, self.y + 1, r, g, b)
            gfx.drawPixel(self.x + 1, self.y2 - 2, r, g, b)
            gfx.drawPixel(self.x2 - 2, self.y + 1, r, g, b)
            gfx.drawPixel(self.x2 - 2, self.y2 - 2, r, g, b)
            -- that was the 'circle'
            self.label:draw()
            for _, f in ipairs(self.drawlist) do
                f(self)
            end
        end
    end
    function rb:drawadd(f)
        table.insert(self.drawlist, f)
    end
    function rb:set_color(r, g, b)
        self.label:set_color(r, g, b)
        self.color = {
            r = r,
            g = g,
            b = b
        }
    end
    function rb:set_enabled(enabled)
        self.enabled = enabled
        if enabled then
            self.label:set_color(self.color.r, self.color.g, self.color.b)
        else
            self.label:set_color(100, 100, 100)
        end
    end
    function rb:mousemove(x, y, dx, dy)
        self.hover = ui.contains(x, y, self.x, self.y, self.x2 + 6 + self.label.w, self.y2) and self.enabled
    end
    function rb:mousedown(x, y, button)
        self.held = self.hover and self.enabled
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
        selected = 0,
        enabled = true,
        visible = true
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
        if self.visible then
            for _, butt in ipairs(self.buttons) do
                butt:draw(self)
            end
        end
    end
    function rg:set_enabled(enabled)
        self.enabled = enabled
        for _, butt in ipairs(self.buttons) do
            butt:set_enabled(enabled)
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

ui.switch = function(x, y, text, r, g, b, colorful)
    local sw = {
        x = x,
        y = y,
        w = 15,
        h = 9,
        x2 = x + 15,
        y2 = y + 9,
        visible = true,
        color = {r = r or 255, g = g or 255, b = b or 255},
        switched_on = false,
        colorful = colorful or false,
        label = ui.text(x + 20, y + 1, text, r, g, b, a),
        enabled = true,
        hover = false,
        held = false,
        drawlist = {}
    }
    function sw:draw()
        if self.visible then
            local r, g, b = self.color.r, self.color.g, self.color.b
            if self.switched_on then 
                if self.colorful then
                    r, g, b = 0, 255, 0
                end
            else
                r, g, b = self.color.r - 100, self.color.g - 100, self.color.b - 100
                if self.colorful then
                    r, g, b = 255, 0, 0
                end
            end
            if not self.enabled then 
                r, g, b = 100, 100, 100
            end
            if self.hover then
                gfx.fillRect(self.x2 + 3, self.y - 1, self.label.w + 3, 11, self.color.r, self.color.g, self.color.b, 50)
            end
            
            if self.switched_on then
                gfx.fillRect(self.x + 8, self.y + 2, 5, 5, r, g, b)
                gfx.drawPixel(self.x + 8, self.y + 2, 0, 0, 0) -- top left
                gfx.drawPixel(self.x + 8, self.y2 - 3, 0, 0, 0) -- bottom left
                gfx.drawPixel(self.x + 12, self.y + 2, 0, 0, 0) -- top right
                gfx.drawPixel(self.x + 12, self.y2 - 3, 0, 0, 0) -- bottom right
            else 
                gfx.fillRect(self.x + 2, self.y + 2, 5, 5, r, g, b)
                gfx.drawPixel(self.x + 2, self.y + 2, 0, 0, 0) -- top left
                gfx.drawPixel(self.x + 2, self.y2 - 3, 0, 0, 0) -- bottom left
                gfx.drawPixel(self.x + 6, self.y + 2, 0, 0, 0) -- top right
                gfx.drawPixel(self.x + 6, self.y2 - 3, 0, 0, 0) -- bottom right
            end
            if self.held then
                gfx.fillRect(self.x + 5, self.y + 2, 5, 5, r, g, b)
                if self.switched_on then 
                    gfx.drawPixel(self.x + 5, self.y + 2, 0, 0, 0) -- top left
                    gfx.drawPixel(self.x + 5, self.y2 - 3, 0, 0, 0) -- bottom left
                else
                    gfx.drawPixel(self.x + 9, self.y + 2, 0, 0, 0) -- top right
                    gfx.drawPixel(self.x + 9, self.y2 - 3, 0, 0, 0) -- bottom right
                end
            end
            -- the 'circle'
            gfx.drawLine(self.x, self.y + 2, self.x, self.y2 - 3, r, g, b) -- left
            gfx.drawLine(self.x2 - 1, self.y + 2, self.x2 - 1, self.y2 - 3, r, g, b) -- right
            gfx.drawLine(self.x + 2, self.y, self.x2 - 3, self.y, r, g, b) -- top
            gfx.drawLine(self.x + 2, self.y2 - 1, self.x2 - 3, self.y2 - 1, r, g, b) -- bottom
            gfx.drawPixel(self.x + 1, self.y + 1, r, g, b) -- top left
            gfx.drawPixel(self.x + 1, self.y2 - 2, r, g, b) -- bottom left
            gfx.drawPixel(self.x2 - 2, self.y + 1, r, g, b) -- top right
            gfx.drawPixel(self.x2 - 2, self.y2 - 2, r, g, b) -- bottom right
            -- that was the 'circle'
            self.label:draw()
            for _, f in ipairs(self.drawlist) do
                f(self)
            end
        end
    end
    function box:drawadd(f)
        table.insert(self.drawlist, f)
    end
    function sw:set_color(r, g, b)
        self.label:set_color(r, g, b)
        self.color = {
            r = r,
            g = g,
            b = b
        }
    end
    function sw:set_enabled(enabled)
        self.enabled = enabled
        if enabled then
            self.label:set_color(self.color.r, self.color.g, self.color.b)
        else
            self.label:set_color(100, 100, 100)
        end
    end
    function sw:mousemove(x, y, dx, dy)
        self.hover = ui.contains(x, y, self.x, self.y, self.x2 + 6 + self.label.w, self.y2) and self.enabled
    end
    function sw:mousedown(x, y, button)
        self.held = self.hover and self.enabled
    end
    function sw:mouseup(x, y, button, reason)
        if self.held then
            self.held = false
        end
        if self.hover then
            self.switched_on = not self.switched_on
        end
    end
    return sw
end

ui.inputbox = function(x, y, w, h, placeholder, r, g, b)
    local pw, ph = gfx.textSize(placeholder)
    ph = ph - 4 -- for some reason it's 4 too many
    if w == 0 then w = pw + 7 end
    if h == 0 then h = ph + 9 end
    tpt.log(h)
    local ib = ui.box(x, y, w, h)
    ib.placeholder = ui.text(x + 4, y + h/2 - ph/2, placeholder, r, g, b, 100)
    ib.text = ui.fixed_text(x + 4, y + h/2 - ph/2, w - 8, '', r, g, b)
    ib.hover = false
    ib.held = false
    ib.focus = false
    ib.cursor = 0
    ib.cursor_moving = false
    ib.visible_cursor = 0
    ib.color = {r = r or 255, g = g or 255, b = b or 255},
    ib:set_backgroud(r, g, b)
    ib:drawadd(function (self)
        local cursorx = tpt.textwidth(self.text.visible_text:sub(1, self.cursor)) + 5   
        if self.hover and not self.focus then
            gfx.fillRect(self.x + 1, self.y + 1, self.w-2, self.h-2, self.color.r, self.color.g, self.color.b, 30)
        end
        if self.focus then
            gfx.fillRect(self.x + 1, self.y + 1, self.w-2, self.h-2, self.color.r, self.color.g, self.color.b, 30)
            if math.floor(socket.gettime()*2) % 2 == 0 and not self.cursor_moving then
                gfx.drawLine(self.x + cursorx,self.y + 2,self.x + cursorx,self.y2-3, self.color.r, self.color.g, self.color.b)
            elseif self.cursor_moving then
                gfx.drawLine(self.x + cursorx,self.y + 2,self.x + cursorx,self.y2-3, self.color.r, self.color.g, self.color.b)
            end
        end
        if #self.text.text ~= 0  then
            self.text:draw()
        end
        if not self.focus and #self.text.text == 0 then
            self.placeholder:draw()
        end
        self.cursor_moving = false
    end)
    function ib:set_color(r, g, b)
        self.placeholder:set_color(r, g, b, 100)
        self.text:set_color(r, g, b)
        self.color = {
            r = r,
            g = g,
            b = b
        }
        self:set_backgroud(r, g, b)
        self:set_border(r, g, b)
    end
    function ib:mousemove(x, y, dx, dy)
        self.hover = ui.contains(x, y, self.x, self.y, self.x2, self.y2)
    end
    function ib:mousedown(x, y, button)
        self.held = self.hover
        if self.hover then
            self.focus = true
        end
    end
    function ib:mouseup(x, y, button, reason)
        -- if self.held then
        --     self.held = false
        -- end
        if not self.hover then
            self.focus = false
        end
    end
    function ib:move_cursor(amt)
		self.cursor = self.cursor + amt
		if self.cursor > #self.text.text then self.cursor = #self.text.text end
		if self.cursor < 0 then self.cursor = 0 return end
	end
    function ib:keypress(key, scan, rep, shift, ctrl, alt)
        local amt = 0
        -- Esc
		if scan == 41 then
			self.focus = false
		-- Enter
		elseif scan == 40 and not rep then
			self.focus = false
		-- Right
		elseif scan == 79 then
			amt = amt + 1
            self.cursor_moving = true
			--self.t:update(nil, self.cursor)
		-- Left
		elseif scan == 80 then
			amt = amt - 1
            self.cursor_moving = true
			--self.t:update(nil, self.cursor)
		end

		local newstr
		-- Backspace
		if scan == 42 then
			if self.cursor > 0 then
				newstr = self.text.text:sub(1,self.cursor-1)..self.text.text:sub(self.cursor + 1)
				amt = amt - 1
			end
		-- Delete
		elseif scan == 76 then
			newstr = self.text.text:sub(1,self.cursor)..self.text.text:sub(self.cursor + 2)
		-- CTRL + C
		elseif scan == 6 and ctrl then
			platform.clipboardPaste(self.text.text)
		-- CTRL + V
		elseif scan == 25 and ctrl then
			local paste = platform.clipboardCopy()
			newstr = self.text.text:sub(1, self.cursor)..paste..self.text.text:sub(self.cursor + 1)
			amt = amt + #paste
		-- CTRL + X
		elseif scan == 27 and ctrl then
			platform.clipboardPaste(self.text.text)
			self.cursor = 0
		end
        if newstr then
			self.text:set_text(newstr) 
		end
        self:move_cursor(amt)
        return
    end
    function ib:textinput(text)
        if not self.focus then
			return
		end
        --if #text > 1 or string.byte(text) < 20 or string.byte(text) > 126 then return end
        newstr = self.text.text:sub(1, self.cursor)..text..self.text.text:sub(self.cursor + 1)
        self.text:set_text(newstr)
        self:move_cursor(1)
        return
    end
    return ib
end

ui.list = function(x, y, w, h, draw_separator, r, g, b, a)
    local list = ui.box(x, y, w, h, r, g, b, a)
    list.items = {}
    list.visible_items = {}
    list.scrollbar_pos = 1
    list.hover = false
    list.draw_separator = draw_separator or false
    local max_items = 1
    list:drawadd(function(self)
        for i, item in ipairs(self.visible_items) do
            item.y = self.y + item.h*(i - 1) + 4*(i - 1) + 4
            item.y2 = item.y + item.h
            item.x = self.x + 4
            item.x2 = item.x + item.w
            if self.draw_separator then
                item.y = item.y + i
            end
            item:draw()
            if self.draw_separator then
                gfx.drawLine(self.x, item.y2 , self.x2 - 1, item.y2 , self.border.r, self.border.g, self.border.b, self.border.a)
            end
        end
        for i, item in ipairs(self.visible_items) do
            if item.y2 <= self.y2 then
                max_items = i
            end
        end
        local pos = self.scrollbar_pos + max_items - 1
        self.visible_items = {unpack(self.items, self.scrollbar_pos, pos)}
        --print(self.scrollbar_pos)
        print(self.scrollbar_pos, max_items)
        
    end)
    function list:append(item, pos)
        table.insert(self.items, pos or #self.items + 1, item)
        max_items = max_items + 1
    end
    function list:mousemove(x, y, dx, dy)
        self.hover = ui.contains(x, y, self.x, self.y, self.x2, self.y2)
        for _, item in ipairs(self.items) do
            if item['mousemove'] then
                item:mousemove(x, y, dx, dy)
            end
        end
        -- TODO automate event handling
    end
    function list:mousewheel(x, y, d)
        if self.hover then
            self.scrollbar_pos = self.scrollbar_pos - d
            if self.scrollbar_pos < 1 then
                self.scrollbar_pos = 1
            elseif #self.items - self.scrollbar_pos + 1 < #self.visible_items then
                self.scrollbar_pos = self.scrollbar_pos + d
            end
       end
    end
    return list
end

return ui