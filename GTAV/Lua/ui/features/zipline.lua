-- Zipline. Published fields: active (bool), state (1 aiming where the line ends, 2 line rigged, 3 riding), aim_valid
-- (bool), aim_len (m), aim_sx / aim_sy (aim point on screen, 0-1, -1 off screen), near_top (bool, close enough to hook
-- on), speed / top_speed (m/s), progress (0-1 along the ride), rope (blob "sx,sy;" screen points from the top anchor
-- to the bottom one, -1,-1 for points off screen).
features.on_draw("Zipline", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 0)

    local px, py
    for x, y in string.gmatch(f.rope or "", "([%-%d%.]+),([%-%d%.]+);") do
        x, y = tonumber(x), tonumber(y)
        if x >= 0 and y >= 0 then
            local sx, sy = x * sw, y * sh
            if px then
                draw.line(px, py, sx, sy, 20, 20, 24, 200, 4 * s)
                draw.line(px, py, sx, sy, 190, 190, 200, 255, 2 * s)
            end
            px, py = sx, sy
        else
            px, py = nil, nil
        end
    end

    local function hint(msg, r, g, b)
        local w = text.width(font.small, msg)
        local y = sh * 0.82
        draw.rect(sw / 2 - w / 2 - 14 * s, y - 8 * s, sw / 2 + w / 2 + 14 * s, y + text.height(font.small) + 8 * s, 10, 10, 14, 200, 6 * s)
        text.draw(font.small, sw / 2 - w / 2, y, r, g, b, 255, msg)
    end

    if state == 1 then
        local ax, ay = f.aim_sx or -1, f.aim_sy or -1
        if ax >= 0 and ay >= 0 then
            local x, y = ax * sw, ay * sh
            local ok = f.aim_valid
            local r, g, b = 255, 90, 80
            if ok then r, g, b = 120, 240, 140 end
            draw.circle_outline(x, y, 14 * s, r, g, b, 255, 3 * s)
            draw.circle(x, y, 3 * s, r, g, b, 255)
            local label = string.format("%d m", math.floor(f.aim_len or 0))
            text.draw(font.small, x + 18 * s, y - 10 * s, r, g, b, 255, label)
        end
        if f.aim_valid then hint("AIM AT WHERE THE LINE SHOULD END AND PRESS E TO RIG IT", 230, 230, 236)
        else hint("AIM AT A SPOT 12 TO 400 M AWAY, HIGHER OR LOWER THAN YOU", 255, 200, 120) end
    elseif state == 2 then
        if f.near_top then hint("PRESS E TO HOOK ON AND RIDE   Q TO RIG A NEW LINE", 120, 240, 140)
        else hint("WALK TO THE TOP END TO RIDE   Q TO RIG A NEW LINE", 230, 230, 236) end
    elseif state == 3 then
        local w = 260 * s
        local x = sw / 2 - w / 2
        local y = sh * 0.84
        draw.rect(x - 12 * s, y - 40 * s, x + w + 12 * s, y + 20 * s, 10, 10, 14, 200, 8 * s)
        local kmh = math.floor((f.speed or 0) * 3.6)
        local label = string.format("%d KM/H", kmh)
        text.draw(font.item, sw / 2 - text.width(font.item, label) / 2, y - 34 * s, 245, 245, 250, 255, label)
        local p = math.max(0, math.min(1, f.progress or 0))
        draw.rect(x, y, x + w, y + 8 * s, 40, 40, 48, 255, 4 * s)
        local r, g, b = theme.accent()
        if p > 0 then draw.rect(x, y, x + w * p, y + 8 * s, r, g, b, 255, 4 * s) end
        local tip = "E LET GO"
        text.draw(font.tiny, x + w - text.width(font.tiny, tip), y - 34 * s, 200, 200, 210, 255, tip)
    end
end)
