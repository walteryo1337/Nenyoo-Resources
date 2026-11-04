-- Weather Widget. Published fields: active (bool), night (bool, 21:00 to 06:00), kind (0 sun, 1 cloud, 2 fog,
-- 3 rain, 4 storm, 5 snow), temp (estimated degrees C), wind (km/h), wind_deg (direction the wind blows towards,
-- 0 north, clockwise), label (blob, translated description). Drawn top-right, just below the Clock.
local DIRS = { "N", "NE", "E", "SE", "S", "SW", "W", "NW" }

local function cloud(cx, cy, r, g, b, a, s)
    draw.circle(cx - 7 * s, cy + 2 * s, 6 * s, r, g, b, a)
    draw.circle(cx + 1 * s, cy - 3 * s, 8 * s, r, g, b, a)
    draw.circle(cx + 8 * s, cy + 2 * s, 6 * s, r, g, b, a)
    draw.rect(cx - 7 * s, cy + 2 * s, cx + 8 * s, cy + 8 * s, r, g, b, a, 0)
end

local function icon(kind, night, cx, cy, s, t)
    if kind == 0 then
        if night then
            draw.circle(cx, cy, 10 * s, 225, 225, 210, 255)
            draw.circle(cx + 5 * s, cy - 4 * s, 9 * s, 10, 10, 16, 255)
        else
            for i = 0, 7 do
                local ang = i * math.pi / 4 + t * 0.4
                draw.line(cx + math.cos(ang) * 12 * s, cy + math.sin(ang) * 12 * s,
                          cx + math.cos(ang) * 16 * s, cy + math.sin(ang) * 16 * s, 255, 200, 60, 255, 2 * s)
            end
            draw.circle(cx, cy, 9 * s, 255, 200, 60, 255)
        end
        return
    end
    if kind == 2 then
        for i = 0, 2 do
            local yy = cy - 7 * s + i * 7 * s
            local off = math.sin(t * 1.5 + i) * 2 * s
            draw.line(cx - 13 * s + off, yy, cx + 13 * s + off, yy, 190, 190, 200, 230, 2.5 * s)
        end
        return
    end
    cloud(cx, cy - 2 * s, 200, 205, 215, 255, s)
    if kind == 3 or kind == 4 then
        for i = 0, 2 do
            local x = cx - 6 * s + i * 6 * s
            local ph = (t * 2 + i * 0.33) % 1
            local y = cy + 8 * s + ph * 8 * s
            draw.line(x, y, x - 2 * s, y + 4 * s, 110, 170, 255, math.floor(255 * (1 - ph)), 1.6 * s)
        end
    end
    if kind == 4 and math.floor(t * 3) % 3 == 0 then
        draw.line(cx + 1 * s, cy + 4 * s, cx - 3 * s, cy + 11 * s, 255, 230, 90, 255, 2 * s)
        draw.line(cx - 3 * s, cy + 11 * s, cx + 2 * s, cy + 11 * s, 255, 230, 90, 255, 2 * s)
        draw.line(cx + 2 * s, cy + 11 * s, cx - 2 * s, cy + 18 * s, 255, 230, 90, 255, 2 * s)
    end
    if kind == 5 then
        for i = 0, 2 do
            local ph = (t * 0.8 + i * 0.33) % 1
            draw.circle(cx - 6 * s + i * 6 * s, cy + 9 * s + ph * 8 * s, 1.8 * s, 245, 245, 255, math.floor(255 * (1 - ph)))
        end
    end
end

features.on_draw("Weather Widget", function(f)
    if not f.active then return end
    local sw = ctx.screen_w()
    local s = ctx.screen_h() / 1080
    local t = ctx.time() or 0
    local ar, ag, ab = theme.accent()

    local temp = string.format("%d C", math.floor(f.temp or 0))
    local label = f.label or ""
    local deg = f.wind_deg or 0
    local dir = DIRS[(math.floor((deg + 22.5) / 45) % 8) + 1]
    local wind = string.format("Wind %d km/h %s", math.floor((f.wind or 0) + 0.5), dir)

    local pad = 10 * s
    local icon_w = 36 * s
    local tw = text.width(font.item, temp)
    local lw = text.width(font.small, label)
    local ww = text.width(font.tiny, wind)
    local w = icon_w + pad + math.max(tw + pad + lw, ww) + pad * 2
    local h = text.height(font.item) + text.height(font.tiny) + pad * 1.5
    local x = sw - w - 18 * s
    local y = 90 * s

    draw.rect(x, y, x + w, y + h, 10, 10, 16, 150, 6 * s)
    icon(math.floor(f.kind or 1), f.night, x + pad + icon_w * 0.5, y + h * 0.5, s, t)

    local tx = x + pad + icon_w + pad
    local ty = y + pad * 0.5
    text.draw(font.item, tx, ty, 240, 240, 245, 255, temp)
    text.draw(font.small, tx + tw + pad, ty + 2 * s, ar, ag, ab, 255, label)
    text.draw(font.tiny, tx, ty + text.height(font.item) + 2 * s, 180, 180, 195, 230, wind)
end)
