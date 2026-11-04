-- Crop Duster. Published fields: active (bool), state (1 fly to the field, 2 dusting, 3 finished), coverage (0-100 %),
-- tank (0-100 %), time_left (seconds; the clock starts on your first pass), agl (metres above ground), distance (metres
-- to the field centre), spraying / too_high / in_field (bool), pos_l / pos_w (0-1 your position along / across the
-- field, may be outside 0-1), heading (radians, your direction relative to the field's long axis), paid, grid_l /
-- grid_w (cells along / across), grid (blob, grid_l * grid_w chars, cell i*grid_w+j: "1" sprayed, "0" not yet).
features.on_draw("Crop Duster", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local state = math.floor(f.state or 0)

    if state == 3 then
        local msg = string.format("%d%% COVERED", math.floor(f.coverage or 0))
        text.draw(big, sw / 2 - text.width(big, msg) / 2, sh * 0.26, 120, 230, 120, 255, msg)
        local p = string.format("+$%d", math.floor(f.paid or 0))
        text.draw(font.item, sw / 2 - text.width(font.item, p) / 2, sh * 0.26 + text.height(big), 245, 245, 250, 255, p)
        return
    end

    local gl, gw = math.floor(f.grid_l or 16), math.floor(f.grid_w or 8)
    local cell = 13 * s
    local mw, mh = gw * cell, gl * cell
    local x = sw - mw - 50 * s
    local y = sh * 0.24
    draw.rect(x - 14 * s, y - 50 * s, x + mw + 14 * s, y + mh + 92 * s, 12, 12, 16, 215, 8 * s)
    local grid = f.grid or ""
    for i = 0, gl - 1 do
        for j = 0, gw - 1 do
            local idx = i * gw + j + 1
            local done = grid:sub(idx, idx) == "1"
            local cx, cy = x + j * cell, y + (gl - 1 - i) * cell
            if done then draw.rect(cx + 1, cy + 1, cx + cell - 1, cy + cell - 1, 120, 200, 90, 255, 0)
            else draw.rect(cx + 1, cy + 1, cx + cell - 1, cy + cell - 1, 110, 85, 50, 255, 0) end
        end
    end
    local pl, pw = f.pos_l or 0, f.pos_w or 0
    if pl > -0.3 and pl < 1.3 and pw > -0.6 and pw < 1.6 then
        local px, py = x + pw * mw, y + (1 - pl) * mh
        local h = f.heading or 0
        local dx, dy = math.sin(h), -math.cos(h)
        draw.line(px, py, px + dx * 16 * s, py + dy * 16 * s, 255, 255, 255, 255, 2 * s)
        draw.circle(px, py, 4 * s, f.spraying and 255 or 230, f.spraying and 220 or 230, f.spraying and 90 or 240, 255)
    end

    local cov = string.format("%d%%", math.floor(f.coverage or 0))
    text.draw(font.title, x, y - 44 * s, 245, 245, 250, 255, cov)
    local t = f.time_left or 0
    local clock = string.format("%d:%02d", math.floor(t / 60), math.floor(t % 60))
    text.draw(font.item, x + mw - text.width(font.item, clock), y - 40 * s, 220, 220, 232, 255, clock)

    local by = y + mh + 12 * s
    draw.rect(x, by, x + mw, by + 8 * s, 40, 40, 50, 220, 3 * s)
    local tank = math.max(0, math.min(100, f.tank or 0))
    local tr, tg, tb = ar, ag, ab
    if tank < 20 then tr, tg, tb = 240, 90, 80 end
    draw.rect(x, by, x + mw * tank / 100, by + 8 * s, tr, tg, tb, 255, 3 * s)
    text.draw(font.tiny, x, by + 12 * s, 190, 190, 205, 230, "TANK")

    local agl = math.floor(f.agl or 0)
    local alt = string.format("ALT %d M", agl)
    local cr, cg, cb = 200, 200, 214
    if f.too_high then cr, cg, cb = 240, 90, 80 elseif agl <= 12 then cr, cg, cb = 120, 230, 120 end
    text.draw(font.small, x, by + 30 * s, cr, cg, cb, 255, alt)
    if state == 1 then
        local d = string.format("FIELD %d M", math.floor(f.distance or 0))
        text.draw(font.small, x + mw - text.width(font.small, d), by + 30 * s, 200, 200, 214, 240, d)
    end
    if f.too_high then
        local msg = "TOO HIGH, GET UNDER 12 M"
        text.draw(font.title, sw / 2 - text.width(font.title, msg) / 2, sh * 0.2, 240, 90, 80, 255, msg)
    end
end)
