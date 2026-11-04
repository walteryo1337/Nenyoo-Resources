-- Now Playing. Published fields: active (bool), age (0..1 through the display time), station, song,
-- artist (strings; song and artist are empty during talk, ads and DJ chatter).
local function fade(age)
    if age < 0.08 then return age / 0.08 end
    if age > 0.8 then return math.max(0, (1 - age) / 0.2) end
    return 1
end

features.on_draw("Now Playing", function(f)
    if not f.active then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local age = f.age or 1
    local t = fade(age)
    local a = math.floor(255 * t)
    local ar, ag, ab = theme.accent()

    local station = string.upper(f.station or "")
    local song = f.song or ""
    local artist = f.artist or ""
    if station == "" and song == "" then return end

    local pad = 12 * s
    local eq_w = 26 * s
    local th = text.height(font.tiny)
    local lines_w = math.max(text.width(font.tiny, station), text.width(font.item, song), text.width(font.small, artist))
    local w = math.max(220 * s, lines_w + eq_w + pad * 3)
    local h = pad * 2 + th
    if song ~= "" then h = h + text.height(font.item) + 2 * s end
    if artist ~= "" then h = h + text.height(font.small) end

    local x = 28 * s - (1 - t) * 40 * s
    local y = sh * 0.66 - h

    draw.rect(x, y, x + w, y + h, 10, 10, 16, math.floor(200 * t), 6 * s)
    draw.rect(x, y, x + 3 * s, y + h, ar, ag, ab, a, 0)

    local bars = 4
    local bw = eq_w / (bars * 2 - 1)
    local base = y + h - pad
    local now = ctx.time()
    for i = 0, bars - 1 do
        local level = 0.35 + 0.65 * math.abs(math.sin(now * (3.1 + i * 1.7) + i * 1.3))
        local bh = (h - pad * 2) * level
        local bx = x + pad + i * bw * 2
        draw.rect(bx, base - bh, bx + bw, base, ar, ag, ab, a, 0)
    end

    local tx = x + pad * 2 + eq_w
    local ty = y + pad
    text.draw(font.tiny, tx, ty, ar, ag, ab, a, station ~= "" and station or "NOW PLAYING")
    ty = ty + th + 2 * s
    if song ~= "" then
        text.draw(font.item, tx, ty, 245, 245, 250, a, song)
        ty = ty + text.height(font.item)
    end
    if artist ~= "" then
        text.draw(font.small, tx, ty, 185, 185, 200, a, artist)
    end
end)
