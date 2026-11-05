-- Roadster Thrusters: the jet fuel ring beside the minimap. Published fields: show (bool, the Fuel Gauge option
-- while you drive); fuel (0..1); label ("RCS Fuel"); suction (status text); armed / attached (bools);
-- mode (Flight / Water Hover / Landing / Boost / Stunt, missing when idle); warn (missing unless a move needed
-- more fuel than was left).
local shown = 0
local shown_fuel = nil

local function pill(cx, y, w, h, s, a)
    draw.rect(cx - w / 2, y, cx + w / 2, y + h, 8, 10, 16, math.floor(200 * a), h / 2)
    draw.rect_outline(cx - w / 2, y, cx + w / 2, y + h, 255, 255, 255, math.floor(24 * a), h / 2, 1 * s)
end

features.on_draw("Roadster Thrusters", function(f)
    local dt = ctx.delta() or 0.016
    shown = shown + ((f.show and 1 or 0) - shown) * math.min(1, dt * 10)
    if shown < 0.02 then shown_fuel = nil return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local fade = shown
    local cx, cy = sw * 0.205 + 46 * s, sh - 132 * s
    local ro = 42 * s
    local ri = ro - 6 * s

    local fuel = math.max(0, math.min(1, f.fuel or 0))
    shown_fuel = shown_fuel and (shown_fuel + (fuel - shown_fuel) * math.min(1, dt * 8)) or fuel

    local cr, cg, cb = 120, 205, 255
    if fuel < 0.10 then cr, cg, cb = 235, 103, 92 elseif fuel < 0.30 then cr, cg, cb = 240, 180, 80 end

    -- Backdrop disc with a faint rim.
    draw.circle(cx, cy, ro + 10 * s, 8, 10, 16, math.floor(170 * fade))
    draw.arc(cx, cy, ro + 10 * s, 0, math.pi * 2, 255, 255, 255, math.floor(22 * fade), 1 * s)

    -- 270 degree track from bottom-left round to bottom-right, filled clockwise.
    local start, sweep = math.rad(135), math.rad(270)
    draw.ring(cx, cy, ri, ro, start, start + sweep, 255, 255, 255, math.floor(30 * fade))
    if shown_fuel > 0.003 then
        local tip = start + sweep * shown_fuel
        draw.ring(cx, cy, ri, ro, start, tip, cr, cg, cb, math.floor(235 * fade))
        draw.circle(cx + math.cos(tip) * (ro - 3 * s), cy + math.sin(tip) * (ro - 3 * s), 4.5 * s,
                    255, 255, 255, math.floor(235 * fade))
    end

    -- Percentage, scaled so "100" always sits inside the ring.
    local num = tostring(math.floor(fuel * 100 + 0.5))
    local nw, nh = text.width(font.display, num), text.height(font.display)
    local scale = math.min(0.78, (ri * 1.15) / math.max(1, nw))
    local ny = cy - 6 * s
    text.draw_scaled(font.display, cx - nw / 2, ny - nh / 2, cr, cg, cb, math.floor(255 * fade), scale, num)
    text.draw(font.hud_small, cx + nw * scale / 2 + 1 * s, ny - nh * scale / 2 + 3 * s,
              cr, cg, cb, math.floor(220 * fade), "%")

    local label = string.upper(f.label or "RCS Fuel")
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, label) / 2, ny + nh * scale / 2 + 1 * s,
              170, 178, 195, math.floor(230 * fade), label)

    -- Status pill under the gauge: coloured dot, suction state, then the active mode.
    local parts = {}
    if f.suction then parts[#parts + 1] = f.suction end
    if f.mode then parts[#parts + 1] = f.mode end
    if #parts > 0 then
        local status = table.concat(parts, "  \xC2\xB7  ")
        local tw, th = text.width(font.hud_small, status), text.height(font.hud_small)
        local h = th + 10 * s
        local w = tw + 30 * s
        local y = cy + ro + 18 * s
        local dr, dg, db = 150, 155, 170
        if f.attached then dr, dg, db = 120, 230, 150 elseif f.armed then dr, dg, db = 240, 200, 110 end
        if f.mode then dr, dg, db = 120, 205, 255 end
        pill(cx, y, w, h, s, fade)
        draw.circle(cx - w / 2 + 12 * s, y + h / 2, 3 * s, dr, dg, db, math.floor(255 * fade))
        text.draw(font.hud_small, cx - w / 2 + 21 * s, y + 5 * s, 225, 228, 235, math.floor(240 * fade), status)
    end

    if f.warn and (math.floor((ctx.time() or 0) * 4) % 2 == 0) then
        local tw, th = text.width(font.hud_small, f.warn), text.height(font.hud_small)
        local h = th + 10 * s
        local y = cy - ro - 18 * s - h
        pill(cx, y, tw + 24 * s, h, s, fade)
        text.draw(font.hud_small, cx - tw / 2, y + 5 * s, 235, 103, 92, math.floor(255 * fade), f.warn)
    end
end)
