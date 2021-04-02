require('scripts.CGImaster2.pngLua.png')
require('scripts.CGImaster2.ui')

local img = pngImage('./scripts/CGImaster2/mario.png', newRowCallback)
local lo = img:getPixel(1,1)

local w = 100
local h = 100
mainbox = ui.box(gfx.WIDTH/2 - w/2, gfx.HEIGHT/2 - h/2, w, h)
mainbox.draw_background = true

local function handle_tick()
    mainbox:draw()
end

evt.register(evt.tick, handle_tick)