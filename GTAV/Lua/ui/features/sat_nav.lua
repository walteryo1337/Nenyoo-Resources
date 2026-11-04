-- Sat Nav. Published fields: active (bool), direction (game route code: 1 recalculating, 2 please wait, 3 turn left,
-- 4 turn right, 5 straight on, 6 keep left, 7 keep right, anything else = follow the road), junction (metres to the
-- next junction), destination (straight-line metres to the waypoint), arriving (bool).
local function metres(d)
    if d >= 1000 then return string.format("%.1f KM", d / 1000) end
    return string.format("%d M", math.floor(d / 10 + 0.5) * 10)
end

local function head(tx, ty, dx, dy, len, thick, r, g, b, a)
    local l = math.sqrt(dx * dx + dy * dy)
    if l <= 0 then return end
    dx, dy = dx / l, dy / l
    for _, ang in ipairs({ 0.6, -0.6 }) do
        local c, s = math.cos(ang), math.sin(ang)
        local bx, by = -(dx * c - dy * s), -(dx * s + dy * c)
        draw.line(tx, ty, tx + bx * len, ty + by * len, r, g, b, a, thick)
    end
end

local function arrow(kind, cx, cy, size, r, g, b)
    local t = size * 0.16
    local bottom, mid = cy + size, cy
    if kind == 3 or kind == 4 then
        local side = kind == 3 and -1 or 1
        draw.line(cx, bottom, cx, mid, r, g, b, 255, t)
        draw.line(cx, mid, cx + side * size, mid, r, g, b, 255, t)
        head(cx + side * size, mid, side, 0, size * 0.5, t, r, g, b, 255)
    elseif kind == 6 or kind == 7 then
        local side = kind == 6 and -1 or 1
        draw.line(cx, bottom, cx, mid, r, g, b, 255, t)
        local tx, ty = cx + side * size * 0.7, cy - size * 0.7
        draw.line(cx, mid, tx, ty, r, g, b, 255, t)
        head(tx, ty, side * 0.7, -0.7, size * 0.5, t, r, g, b, 255)
    else
        draw.line(cx, bottom, cx, cy - size, r, g, b, 255, t)
        head(cx, cy - size, 0, -1, size * 0.5, t, r, g, b, 255)
    end
end

features.on_draw("Sat Nav", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local dir = math.floor(f.direction or 0)

    local w, h = 250 * s, 96 * s
    local x, y = 24 * s, sh * 0.6
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 205, 8 * s)
    draw.rect(x, y, x + 3 * s, y + h, ar, ag, ab, 255, 0)

    local icon_cx, icon_cy = x + 48 * s, y + h / 2 - 4 * s
    local title, sub
    if f.arriving then
        draw.circle_outline(icon_cx, icon_cy + 4 * s, 20 * s, ar, ag, ab, 255, 4 * s)
        draw.circle(icon_cx, icon_cy + 4 * s, 7 * s, ar, ag, ab, 255)
        title, sub = "ARRIVING", "DESTINATION AHEAD"
    elseif dir == 1 or dir == 2 then
        local t = ctx.time() or 0
        for i = 0, 7 do
            local a = t * 4 + i * math.pi / 4
            local alpha = math.floor(60 + 195 * (i / 7))
            draw.circle(icon_cx + math.cos(a) * 18 * s, icon_cy + 4 * s + math.sin(a) * 18 * s, 3.5 * s, 245, 245, 250, alpha)
        end
        title, sub = "ROUTING", "RECALCULATING"
    else
        arrow(dir, icon_cx, icon_cy, 22 * s, 245, 245, 250)
        local labels = { [3] = "TURN LEFT", [4] = "TURN RIGHT", [5] = "STRAIGHT ON", [6] = "KEEP LEFT", [7] = "KEEP RIGHT" }
        local j = f.junction or 0
        title = j > 0 and metres(j) or "FOLLOW ROAD"
        sub = labels[dir] or "CONTINUE"
    end

    local tx = x + 92 * s
    local r, g, b = 245, 245, 250
    if not f.arriving and (dir == 3 or dir == 4) and (f.junction or 999) <= 60 then r, g, b = ar, ag, ab end
    text.draw(font.title, tx, y + 12 * s, r, g, b, 255, title)
    text.draw(font.small, tx, y + 14 * s + text.height(font.title), 215, 215, 228, 240, sub)
    local dest = metres(f.destination or 0) .. " TO GO"
    text.draw(font.tiny, tx, y + h - 10 * s - text.height(font.tiny), 180, 180, 195, 230, dest)
end)
