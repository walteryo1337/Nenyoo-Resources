-- Roadster Thrusters: the jet fuel ring beside the minimap. Published fields: show (bool, the Fuel Gauge option
-- while you drive); fuel (0..1); label ("RCS Fuel"); suction (status text); armed / attached (bools);
-- mode (Flight / Water Hover / Landing / Boost / Stunt, missing when idle); warn (missing unless a move needed
-- more fuel than was left).
local shown = 0

features.on_draw("Roadster Thrusters", function(f)
    local dt = ctx.delta() or 0.016
    shown = shown + ((f.show and 1 or 0) - shown) * math.min(1, dt * 10)
    if shown < 0.02 then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local fade = shown
    local cx, cy = sw * 0.205 + 46 * s, sh - 128 * s
    local r = 40 * s
    local fuel = math.max(0, math.min(1, f.fuel or 0))

    local cr, cg, cb = 245, 245, 250
    if fuel < 0.10 then cr, cg, cb = 235, 103, 92 elseif fuel < 0.30 then cr, cg, cb = 240, 180, 80 end

    draw.circle(cx, cy, r + 14 * s, 8, 10, 16, math.floor(150 * fade))

    -- 270 degree track from bottom-left round to bottom-right, filled clockwise.
    local start, sweep, steps = math.rad(135), math.rad(270), 54
    local function arc(from, to, red, green, blue, alpha, width)
        local n = math.max(1, math.floor(steps * (to - from)))
        local px, py
        for i = 0, n do
            local a = start + sweep * (from + (to - from) * i / n)
            local x, y = cx + math.cos(a) * r, cy + math.sin(a) * r
            if px then draw.line(px, py, x, y, red, green, blue, alpha, width) end
            px, py = x, y
        end
    end
    arc(0, 1, 90, 95, 110, math.floor(120 * fade), 4 * s)
    if fuel > 0.003 then arc(0, fuel, cr, cg, cb, math.floor(240 * fade), 4 * s) end
    for _, t in ipairs({ 0, 1 }) do
        local a = start + sweep * t
        draw.line(cx + math.cos(a) * (r - 7 * s), cy + math.sin(a) * (r - 7 * s),
                  cx + math.cos(a) * (r + 7 * s), cy + math.sin(a) * (r + 7 * s), 200, 205, 215, math.floor(200 * fade), 2 * s)
    end

    local pct = string.format("%d%%", math.floor(fuel * 100 + 0.5))
    text.draw(font.title, cx - text.width(font.title, pct) / 2,
              cy - text.height(font.title) * 0.6, cr, cg, cb, math.floor(255 * fade), pct)
    local label = f.label or "RCS Fuel"
    text.draw(font.tiny, cx - text.width(font.tiny, label) / 2, cy + r * 0.38, 200, 205, 215, math.floor(220 * fade), label)

    local y = cy + r + 18 * s
    if f.suction then
        local sr, sg, sb = 170, 175, 190
        if f.attached then sr, sg, sb = 120, 230, 150 elseif f.armed then sr, sg, sb = 240, 200, 110 end
        text.draw(font.tiny, cx - text.width(font.tiny, f.suction) / 2, y, sr, sg, sb, math.floor(230 * fade), f.suction)
        y = y + text.height(font.tiny) + 2 * s
    end
    if f.mode then
        text.draw(font.tiny, cx - text.width(font.tiny, f.mode) / 2, y, 150, 200, 255, math.floor(235 * fade), f.mode)
        y = y + text.height(font.tiny) + 2 * s
    end
    if f.warn and (math.floor((ctx.time() or 0) * 4) % 2 == 0) then
        text.draw(font.tiny, cx - text.width(font.tiny, f.warn) / 2, cy - r - 22 * s, 235, 103, 92, math.floor(255 * fade), f.warn)
    end
end)
