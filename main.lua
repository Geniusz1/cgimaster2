require('scripts.CGImaster2.pngLua.png')
require('scripts.Powderface.Powderface')

local mw, mh = gfx.WIDTH, gfx.HEIGHT
local mx, my = gfx.WIDTH/2 - mw/2, gfx.HEIGHT/2 - mh/2
local mx2, my2 = mx + mw, my + mh
local enabled = true

local logo = pngImage('./scripts/CGImaster2/cgimasterlogo.png')

local main = ui.container()

local window = ui.box(mx, my, mw, mh)

local exit_button = ui.flat_button(mx2 - 31, my + 6, 30, 15, '', function() enabled = false end)
function exit_button:draw()
    gfx.fillRect(self.x, self.y, self.w, self.h, 200, 70, 70)
    if self.hover then
        gfx.fillRect(self.x, self.y, self.w, self.h, 200, 130, 130)
    end
    if self.held then
        gfx.fillRect(self.x, self.y, self.w, self.h, 200, 60, 60)
    end
    gfx.drawLine(self.x + 2, self.y + 2, self.x + 12, self.y2 - 2, 0, 0, 0)
    gfx.drawLine(self.x + 12, self.y + 2, self.x + 2, self.y2 - 2, 0, 0, 0)
    gfx.drawLine(self.x + 3, self.y + 2, self.x + 13, self.y2 - 2, 0, 0, 0)
    gfx.drawLine(self.x + 13, self.y + 2, self.x + 3, self.y2 - 2, 0, 0, 0)
    gfx.drawLine(self.x + 4, self.y + 2, self.x + 14, self.y2 - 2, 0, 0, 0)
    gfx.drawLine(self.x + 14, self.y + 2, self.x + 4, self.y2 - 2, 0, 0, 0)
    gfx.drawLine(self.x + 14, self.y + 2, self.x + 4, self.y2 - 2, 0, 0, 0)
end

local credits = ui.text(mx2 - tpt.textwidth('v2.0,  created by Gienio aka Geniusz1') - 35, my + 10, 'v2.0, created by Gienio aka Geniusz1', 255, 255, 255, 100)

local input = ui.inputbox(mx + 10, my + 50, 200, 0, 'Provide file name or path')
-- local search_button = ui.button(mx + 115, my + 50, 15, 15, '', function() end)
-- search_button:drawadd(function(self)
--     gfx.drawCircle(self.x + 6, self.y + 6, 4, 4)
--     gfx.drawLine(self.x + 8, self.y + 8, self.x2 - 3, self.y2 - 3)
-- end)

local files = ui.list(mx + 10, my + 75, 200, 167, false, true, 0, 0)

if platform then
	OS = platform.platform()
else
    tpt.throw_error('CGImaster2 requires presence of the platform API')
    return
end

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local dir
    if OS:sub(1, 3) == 'WIN' then
        dir = 'dir "'..directory..'" /b /ad'
    else
        dir = 'ls -A --file-type "'..directory..'"'
    end
    local pfile = popen(dir)
    for filename in pfile:lines() do
        local is_dir = filename:sub(#filename) == '/'
        if not (filename:find("%.png$") or is_dir) then
            goto continue
        end
        table.insert(t, filename)
        ::continue::
    end
    for i, v in ipairs(t) do -- move folders to the top
        local is_dir = v:sub(#v) == '/'
        if is_dir then
            temp_t = {unpack(t, i)}
            for _, v in ipairs({unpack(t, 1, i - 1)}) do
                table.insert(temp_t, v)
            end
            t = temp_t
            break
        end
    end
    pfile:close()
    return t
end

sfile = function(fullpath)
    local file = ui.flat_button(files.x, files.y, files.w - 6, 15, fullpath, function() end, 'left')
    file.fullpath = fullpath
    file.is_selected = false
    function file:set_selected(selected)
        self.is_selected = selected == true and true or false -- so that is_selected is always a bool
    end
    file:drawadd(function(self)
        if self.is_selected then
            gfx.drawRect(self.x, self.y, self.w, self.h, 255, 255, 255, 155)
        end
    end)
    file:set_function(function()
        file:set_selected(true)
    end)
    file:set_border(0, 0, 0, 0)
    return file
end
    

for _, v in ipairs(scandir('/')) do   
    local item = sfile(v)
    files:append(item)
end

main:append(
    window,
    credits,
    input,
    files,
    exit_button
)

window.draw_background = true

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