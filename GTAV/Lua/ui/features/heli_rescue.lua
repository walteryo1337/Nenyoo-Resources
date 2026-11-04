-- Heli Rescue. Shown while the job is on. Published fields: active (bool), finding / delivering (bool, job phase),
-- in_heli (bool, you are flying a helicopter), distance (metres to the current marker), time_left (seconds on this
-- call), board (0..1, how far along the pickup is while you hover next to them), no_room (bool, every passenger seat
-- is taken), rescued (people saved this shift), earned (cash this shift).
features.on_draw("Heli Rescue", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0

    local w, h = 270 * s, 118 * s
    local x0, y0 = 30 * s, sh * 0.5 - h / 2
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 18, 210, 12 * s)
    text.draw(font.small, x0 + 14 * s, y0 + 8 * s, 235, 235, 245, 255, "HELI RESCUE")

    local tl = f.time_left or 0
    if f.finding or f.delivering then
        local clock = string.format("%d:%02d", math.floor(tl / 60), math.floor(tl % 60))
        local cr, cg, cb = 245, 245, 250
        if tl < 30 then cr, cg, cb = 255, 90, 80 end
        text.draw(font.small, x0 + w - 14 * s - text.width(font.small, clock), y0 + 8 * s, cr, cg, cb, 255, clock)
    end

    local line, r, g, b
    if not f.in_heli then line, r, g, b = "GET BACK IN A HELICOPTER", 255, 90, 80
    elseif f.no_room then line, r, g, b = "NO FREE SEAT IN THIS HELICOPTER", 255, 90, 80
    elseif f.finding then line, r, g, b = string.format("STRANDED PERSON  %.0fM", f.distance or 0), 255, 120, 110
    elseif f.delivering then line, r, g, b = string.format("DROP ZONE  %.0fM  -  LAND THERE", f.distance or 0), 255, 210, 90
    else line, r, g, b = "WAITING FOR THE NEXT CALL", 200, 200, 214 end
    text.draw(font.tiny, x0 + 14 * s, y0 + 40 * s, r, g, b, math.floor(190 + 60 * math.sin(t * 3)), line)

    local k = f.board or 0
    if f.finding and k > 0 then
        local bx0, bx1, by = x0 + 14 * s, x0 + w - 14 * s, y0 + 62 * s
        draw.rect(bx0, by, bx1, by + 8 * s, 40, 40, 52, 255, 4 * s)
        draw.rect(bx0, by, bx0 + (bx1 - bx0) * math.min(1, k), by + 8 * s, 120, 230, 150, 255, 4 * s)
        text.draw(font.tiny, bx0, by + 12 * s, 120, 230, 150, 230, "HOLD STEADY, THEY ARE CLIMBING IN")
    end

    local tally = string.format("%d SAVED   $%d", math.floor(f.rescued or 0), math.floor(f.earned or 0))
    text.draw(font.tiny, x0 + 14 * s, y0 + h - 24 * s, 255, 220, 90, 230, tally)
end)
