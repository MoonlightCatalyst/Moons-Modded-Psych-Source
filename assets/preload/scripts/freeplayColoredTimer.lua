-- freeplay colored timebar script by CoolingTool

-- minimum brightness for easier visibility on dark colors | from 0.00 - 1.00
local minBrightness = 0.35

function onCreatePost()
    addHaxeLibrary('WeekData')
    runHaxeCode[[
        // this just gets the songs week data, somehow does not break when the song isnt in a week
        game.setOnLuas('songWeekData',
            WeekData.weeksLoaded.get(WeekData.weeksList[PlayState.storyWeek]).songs
            .filter(s -> Paths.formatToSongPath(s[0]) == Paths.formatToSongPath(PlayState.SONG.song))[0]
        );
    ]]

    if songWeekData then
        colors = songWeekData[3]
        if not colors or #colors < 3 then
            colors = {146, 113, 253} -- from FreeplayState
        end
        ermFixColor(colors)

        -- technically minBrightness should be minLightness cause this is hsl and not hsb but who cares
        hslcolors = {luacolors.RGBtoHSL(unpack(colors))}
        if hslcolors[3] / 255 < minBrightness then
            hslcolors[3] = minBrightness * 255
            colors = {luacolors.HSLtoRGB(unpack(hslcolors))}
            ermFixColor(colors)
        end

        setTimeBarColors(('%02x%02x%02x'):format(unpack(colors)), '000000')
    end
end

function ermFixColor(color)
    for i = 1, 3 do color[i] = math.min(math.max(math.ceil(color[i]), 0), 255) end
end

-- ===========================================================================================================
-- small portion of the luacolors library below (license included so i can't get sued 👍👍👍) 

luacolors = {
    _VERSION     = 'luacolors v0.1.0',
    _DESCRIPTION = 'Color utility library for Lua',
    _URL         = 'https://github.com/icrawler/luacolors',
    _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2014 Phoenix Enero

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

-- public functions

-- convert HSL to RGB
-- (taken from https://www.love2d.org/wiki/HSL_color with a few modifications)
local function HSLtoRGB(h, s, l)
    if s<=0 then return l,l,l   end
    h, s, l = h/360*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255
end


-- convert RGB to HSL
local function RGBtoHSL(r, g, b)
    r, g, b    = r/255, g/255, b/255
	local M, m =  math.max(r, g, b),
				  math.min(r, g, b)
	local c, H = M - m, 0
	if     M == r then H = (g-b)/c%6
	elseif M == g then H = (b-r)/c+2
	elseif M == b then H = (r-g)/c+4
	end	local L = 0.5*M+0.5*m
	local S = c == 0 and 0 or c/(1-math.abs(2*L-1))
	return ((1/6)*H)*360%360, S*255, L*255
end

-- public interface
luacolors.HSLtoRGB = HSLtoRGB
luacolors.RGBtoHSL = RGBtoHSL