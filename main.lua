require('scripts.CGImaster2.pngLua.png')

local img = pngImage('./scripts/CGImaster2/mario.png', newRowCallback)
local lo = img:getPixel(1,1)

local w = 100
local h = 100