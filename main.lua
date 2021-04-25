require('scripts.CGImaster2.pngLua.png')
require('scripts.Powderface.Powderface')

local mw, mh = 420, 256
local mx, my = gfx.WIDTH/2 - mw/2, gfx.HEIGHT/2 - mh/2
local mx2, my2 = mx + mw - 1, my + mh - 1
local enabled = true
local image_placing_mode = false

local logo = pngImage('./scripts/CGImaster2/cgimasterlogo.png')

local function draw_image(image, x, y)
    if not (image or x or y) then return false end
    for x_ = 1, image.width do
        for y_ = 1, image.height do
            local pix = image:getPixel(x_, y_)
            gfx.drawPixel(x + x_ - 1, y + y_ - 1, pix.R, pix.G, pix.B, pix.A)
        end
    end
end

local main = ui.container()
local image_placing_container = ui.container()

local window = ui.box(mx, my, mw, mh)

local exit_button = ui.flat_button(mx2 - 30, my + 6, 30, 15, '', function() enabled = false end)
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

local input = ui.inputbox(mx + 10, my + 50, 186, 15, 'Provide file name or path')

local enter_button = ui.flat_button(input.x2, input.y, 15, 15, '', function() end)
enter_button:drawadd(function(self)
    local a, b, c, d, e = self.x + 4, self.y + 3, self.x2 - 6, self.y2 - 7, self.y2 - 3
    gfx.drawLine(a, b, c, d)
    gfx.drawLine(a, e, c, d)
    gfx.drawLine(a + 1, b, c + 1, d)
    gfx.drawLine(a + 1, e , c + 1, d)
    gfx.drawLine(a + 2, b, c + 2, d)
    gfx.drawLine(a + 2, e , c + 2, d)
end)


local files = ui.list(mx + 10, input.y2 + 14, 200, 167, false, true, 0, 0)

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
        dir = 'ls --file-type "'..directory..'"'
    end
    local pfile, err = popen(dir)
    if err then tpt.throw_error(err) return false end
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

local function execute(command)
    local output, t = io.popen(command):lines(), {}
    for line in output do
        table.insert(t, line)
    end
    return t
end

local selected_file
local working_dir = execute('pwd')[1]..'/scripts/CGImaster2/'
local scrollbar_drawn = #files.items > files:get_max_visible_items()

sfile = function(fullpath)
    local file = ui.flat_button(files.x, files.y, files.w - 6, 15, '   '..fullpath:sub(#fullpath - (fullpath:reverse():sub(2):find('/') or 2)):sub(2), function() end, 'left')
    file.name = fullpath:sub(#fullpath - (fullpath:reverse():sub(2):find('/') or 2)):sub(2)
    file.fullpath = fullpath
    file.is_selected = false
    file.is_dir = file.name:sub(#file.name) == '/'
    function file:set_selected(selected)
        self.is_selected = selected == true and true or false -- so that is_selected is always a bool
        if self.is_selected then
            selected_file = self
            self.label:set_color(0, 0, 0)
        end
    end
    file:drawadd(function(self)
        if self.is_selected and selected_file == self then
            gfx.fillRect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, 255, 255, 255, 155)
        else
            self.label:set_color(255, 255, 255)
        end
        if self.is_dir then
            -- folder icon
            gfx.fillRect(self.x + 3, self.y + 5, 11, 7)
            gfx.fillRect(self.x + 3, self.y + 4, 10, 1, 160, 160, 160)
            gfx.fillRect(self.x + 3, self.y + 3, 5, 1, 160, 160, 160)
            gfx.fillRect(self.x + 3, self.y + 12, 10, 1, 160, 160, 160)
            -- end folder icon
        else
            -- picture icon
            gfx.fillRect(self.x + 4, self.y + 3, 9, 9)
            gfx.fillRect(self.x + 3, self.y + 3, 1, 9)
            gfx.fillRect(self.x + 4, self.y + 2, 9, 1)
            gfx.fillRect(self.x + 13, self.y + 3, 1, 9)
            gfx.fillRect(self.x + 4, self.y + 12, 9, 1)
            -- smaller mountain
            gfx.fillRect(self.x + 4, self.y + 8, 3, 3, 150, 150, 150)
            gfx.drawPixel(self.x + 5, self.y + 7, 150, 150, 150)
            -- bigger mountain
            gfx.fillRect(self.x + 5, self.y + 11, 7, 1, 57, 57, 57)
            gfx.fillRect(self.x + 5, self.y + 10, 8, 1, 57, 57, 57)
            gfx.fillRect(self.x + 6, self.y + 9, 7, 1, 57, 57, 57)
            gfx.fillRect(self.x + 7, self.y + 8, 5, 1, 57, 57, 57)
            gfx.fillRect(self.x + 8, self.y + 7, 3, 1, 57, 57, 57)
            gfx.drawPixel(self.x + 9, self.y + 6, 57, 57, 57)
            -- the 'sun'
            gfx.fillRect(self.x + 6, self.y + 3, 1, 3, 218, 218, 218)
            gfx.fillRect(self.x + 5, self.y + 4, 3, 1, 218, 218, 218)
            -- end picture icon
        end
    end, 1)
    file:set_function(function()
        file:set_selected(true)
        if file.is_dir then
            working_dir = working_dir..file.name
            load_directory(working_dir)
        end
    end)
    file:set_border(0, 0, 0, 0)
    return file
end


function goup()
    working_dir = working_dir:sub(1, #working_dir - (working_dir:reverse():sub(2):find('/') or 1))
    working_dir = working_dir == '' and '/' or working_dir
    load_directory(working_dir)
end

local goup_button = ui.flat_button(input.x, input.y2, 15, 15, '', goup)
goup_button:drawadd(function(self)
    gfx.drawLine(self.x + self.w/2 - 1, self.y + 3, self.x + self.w/2 - 1, self.y2 - 3)
    gfx.drawLine(self.x + 3, self.y + 7, self.x + self.w/2 - 1, self.y + 3)
    gfx.drawLine(self.x2 - 3, self.y + 7, self.x + self.w/2 - 1, self.y + 3)
end)

local working_dir_text = ui.scroll_text(goup_button.x2 + 4, goup_button.y + 4, 181, working_dir, nil, 200, 200, 200)
function working_dir_text:mousewheel(x, y, d)
    if ui.contains(x, y, self.x, self.y, self.x2, self.y2) then
        self:set_scroll_pos(self.scroll_pos + d)
    end
end

function begin()
    image_placing_mode = true
end

local begin_button = ui.button(mx2 - tpt.textwidth('BEGIN PLACING THE IMAGE') - 20, my2 - 30, 0, 0, 'BEGIN PLACING THE IMAGE', begin, nil, 0, 255, 0)

function load_directory(dir)
    files.items = {}
    files.scrollbar_pos = 1
    files:set_padding(0)
    for i, v in ipairs(scandir(dir)) do   
        local item = sfile(working_dir..v)
        files:append(item)
        if i > 500 then break end
    end
    if #files.items == 0 then
        files:set_padding(35)
        files:append(ui.text(files.x, files.y, 'No PNG images or folders\n      found in here', 100, 100, 100))
        local hyperlink_goup = ui.flat_button(files.x, files.y, 121, 20, 'go back', goup, nil, 100, 100, 200)
        function hyperlink_goup:draw()
            if self.visible then
                local r, g, b = 100, 100, 200
                if self.hover then
                    r, g, b = 70, 70, 255
                end
                if self.held then
                    r, g, b = 20, 20, 200
                end
                gfx.drawLine(self.x + self.w/2 - tpt.textwidth(self.label.text)/2 + 5, self.y2 - 1, self.x2 - self.h/2 - tpt.textwidth(self.label.text), self.y2 - 1, r , g , b)
                gfx.drawText(self.x + self.w/2 - tpt.textwidth(self.label.text)/2, self.y + self.h/2, self.label.text, r, g, b)
            end
        end
        files:append(hyperlink_goup)
    end
    working_dir_text:set_text(working_dir)
    scrollbar_drawn = #files.items > files:get_max_visible_items()
    for _, v in ipairs(files.items) do
        if v['set_size'] and v.fullpath then v:set_size(scrollbar_drawn and files.w - 6 or files.w - 2, v.h) end
    end
    working_dir_text:set_scroll_pos(#working_dir - working_dir_text:get_max_visible_chars())
end

load_directory(working_dir)

main:append(
    window,
    credits,
    input,
    files,
    exit_button,
    enter_button,
    goup_button,
    working_dir_text,
    begin_button
)

window.draw_background = true

local function contains(x, y, a1, b1, a2, b2)
    return not (x < a1 or x > a2 or y < b1 or y > b2)
end

local function tick()
    if enabled and not image_placing_mode then
        gfx.fillRect(0, 0, gfx.WIDTH, gfx.HEIGHT, 0, 0, 0, 140)
        main:draw()
        draw_image(logo, mx + 10, my + 10)
    end
end

local function mouseup(x, y, button, reason)
    if enabled and not image_placing_mode then 
        if not contains(x, y, mx, my, mx2, my2) then enabled = false end
        main:handle_event('mouseup', x, y, button, reason)
        return false  
    end
end

local function mousemove(x, y, dx, dy)
    if enabled and not image_placing_mode then
        main:handle_event('mousemove', x, y, dx, dy)
        return false  
    end
end

local function mousedown(x, y, button)
    if enabled and not image_placing_mode then 
        main:handle_event('mousedown', x, y, button)
        return false  
    end
end
local function mousewheel(x, y, d)
    if enabled and not image_placing_mode then 
        main:handle_event('mousewheel', x, y, d)
        return false  
    end
end


local function keypress(key, scan, rep, shift, ctrl, alt)
    if enabled and not image_placing_mode then
        main:handle_event('keypress', key, scan, rep, shift, ctrl, alt)
    elseif enabled and image_placing_mode then
        if scan == 27 then
            image_placing_mode = false
            return false
        end
    end
    if scan == 18 and ctrl and shift then
        enabled = true
    end
    if scan == 41 then
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