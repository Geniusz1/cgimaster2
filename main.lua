require('scripts.CGImaster2.pngLua.png')
require('scripts.CGImaster2.ui')

local mw, mh = 400, 255
local mx, my = gfx.WIDTH/2 - mw/2, gfx.HEIGHT/2 - mh/2
local mx2, my2 = mx + mw, my + mh

local logo = pngImage('./scripts/CGImaster2/cgimasterlogo.png')

local main = ui.container()

local window = ui.box(mx, my, mw, mh)

local credits = ui.text(mx2 - tpt.textwidth('v2.0,  created by Gienio aka Geniusz1') - 10, my + 10, 'v2.0, created by Gienio aka Geniusz1', 255, 255, 255, 100)

local input = ui.inputbox(mx + 10, my + 50, 100, 0, 'Provide file name')
-- local search_button = ui.button(mx + 115, my + 50, 15, 15, '', function() end)
-- search_button:drawadd(function(self)
--     gfx.drawCircle(self.x + 6, self.y + 6, 4, 4)
--     gfx.drawLine(self.x + 8, self.y + 8, self.x2 - 3, self.y2 - 3)
-- end)

local files = ui.list(mx + 10, my + 75, 100, 170, false)

for i = 1, 20 do   
    --local item = ui.text(files.x, files.y, i..' item')
    local item = ui.box(files.x, files.y, files.w - 8, 10)
    item.label = ui.text(item.x, item.y, i..' item')
    item:drawadd(function(self) self.label:draw() end)
    files:append(item)
end

main:append(window)
main:append(credits)
main:append(input)
-- main:append(search_button)
main:append(files)

window.draw_background = true

local enabled = true

local function contains(x, y, a1, b1, a2, b2)
    return not (x < a1 or x > a2 or y < b1 or y > b2)
end

local function tick()
    if enabled then
        gfx.fillRect(0, 0, gfx.WIDTH, gfx.HEIGHT, 0, 0, 0, 140)
        main:draw()
        for x = 1, logo.width do
            for y = 1, logo.height do
                local pix = logo:getPixel(x, y)
                gfx.drawPixel(mx + x + 5, my + y + 5, pix.R, pix.G, pix.B,  pix.A)
            end
        end
    end
end

local function mouseup(x, y, button, reason)
    if enabled then 
        if not contains(x, y, mx, my, mx2, my2) then enabled = false end
        main:handle_event('mouseup', x, y, button, reason)
        return false  
    end
end

local function mousemove(x, y, dx, dy)
    if enabled then 
        main:handle_event('mousemove', x, y, dx, dy)
        return false  
    end
end

local function mousedown(x, y, button)
    if enabled then 
        main:handle_event('mousedown', x, y, button)
        return false  
    end
end
local function mousewheel(x, y, d)
    if enabled then 
        main:handle_event('mousewheel', x, y, d)
        return false  
    end
end


local function keypress(key, scan, rep, shift, ctrl, alt)
    main:handle_event('keypress', key, scan, rep, shift, ctrl, alt)
    if scan == 18 and ctrl and shift then
        enabled = true
    elseif scan == 41 and enabled then
        enabled = false
        return false
    end
    return not enabled
end

local function textinput(text)
    if enabled then
        main:handle_event('textinput', text)
    end
    return not enabled
end


evt.register(evt.keypress, keypress)
evt.register(evt.tick, tick)
evt.register(evt.mouseup, mouseup)
evt.register(evt.mousedown, mousedown)
evt.register(evt.mousemove, mousemove)
evt.register(evt.textinput, textinput)
evt.register(evt.mousewheel, mousewheel)