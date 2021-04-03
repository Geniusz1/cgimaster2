require('scripts.CGImaster2.pngLua.png')
require('scripts.CGImaster2.ui')

local mw, mh = 400, 250
local mx, my = gfx.WIDTH/2 - mw/2, gfx.HEIGHT/2 - mh/2
local mx2, my2 = mx + mw, my + mh

local main = ui.container()
local window = ui.box(mx, my, mw, mh)
main:append(window)
window.draw_background = true

local enabled = false

local function contains(x, y, a1, b1, a2, b2)
    return not (x < a1 or x > a2 or y < b1 or y > b2)
end

local logo = pngImage('./scripts/CGImaster2/cgimasterlogo.png')
local function tick()
    if enabled then
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
    if not contains(x, y, mx, my, mx2, my2) then enabled = false end
end

local function keypress(key, scan, rep, shift, ctrl, alt)
    if scan == 18 and ctrl and shift then
        enabled = true
    end
end

evt.register(evt.keypress, keypress)
evt.register(evt.tick, tick)
evt.register(evt.mouseup, mouseup)