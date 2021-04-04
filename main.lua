require('scripts.CGImaster2.pngLua.png')
require('scripts.CGImaster2.ui')

local mw, mh = 400, 250
local mx, my = gfx.WIDTH/2 - mw/2, gfx.HEIGHT/2 - mh/2
local mx2, my2 = mx + mw, my + mh

local logo = pngImage('./scripts/CGImaster2/cgimasterlogo.png')

local main = ui.container()

local window = ui.box(mx, my, mw, mh)

local credits = ui.text(mx2 - tpt.textwidth('v2.0,  created by Gienio aka Geniusz1') - 10, my + 10, 'v2.0, created by Gienio aka Geniusz1', 255, 255, 255, 100)

local start_button = ui.button(mx + 10, my + 100, 0, 0,'START', function() tpt.log('I\'m cwicked! OwO') end)
start_button:set_color(0, 255, 0)
local check = ui.checkbox(mx + 10, my + 150, 'Will you check me, senpai? OwO')
check:set_color(255, 0, 0)
local rad1 = ui.radio_button(mx + 10, my + 170, 'Am I the one, senpai? UwU')
local rad2 = ui.radio_button(mx + 10, my + 182, 'Or maybe it\'s me? OwO')
local rad3 = ui.radio_button(mx + 10, my + 194, 'OUmmmmmmmm? OwO')

local rgroup = ui.radio_group()
rgroup:add_button(rad1)
rgroup:add_button(rad2)
rgroup:add_button(rad3)

main:append(window)
main:append(credits)
main:append(start_button)
main:append(check)
main:append(rgroup)

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
                gfx.drawRect(mx + x + 5, my + y + 5, 1, 1, pix.R, pix.G, pix.B,  pix.A)
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

local function keypress(key, scan, rep, shift, ctrl, alt)
    if scan == 18 and ctrl and shift then
        enabled = true
    elseif scan == 41 and enabled then
        enabled = false
        return false
    end
    if not enabled then return end
end

evt.register(evt.keypress, keypress)
evt.register(evt.tick, tick)
evt.register(evt.mouseup, mouseup)
evt.register(evt.mousedown, mousedown)
evt.register(evt.mousemove, mousemove)