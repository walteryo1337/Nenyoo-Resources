-- Graffiti. Shown while you are on foot with Graffiti on. Published fields: active (bool), aim_ok (bool, you are close to
-- a wall you can tag), spraying (bool), progress (0..1 of the current tag), tags (how many tags you have up), spotted
-- (bool, a cop just saw you).
features.on_draw("Graffiti", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx = sw / 2

    if f.spraying then
        local w = 220 * s
        local x0, y0 = cx - w / 2, sh * 0.62
        draw.rect(x0, y0, x0 + w, y0 + 10 * s, 30, 30, 40, 220, 5 * s)
        draw.rect(x0, y0, x0 + w * math.max(0, math.min(1, f.progress or 0)), y0 + 10 * s, 255, 80, 190, 255, 5 * s)
        local label = "SPRAYING..."
        text.draw(font.tiny, cx - text.width(font.tiny, label) / 2, y0 + 16 * s, 235, 235, 245, 230, label)
    elseif f.aim_ok then
        local label = "HOLD E TO TAG THIS WALL"
        text.draw(font.tiny, cx - text.width(font.tiny, label) / 2, sh * 0.62, 235, 235, 245, 230, label)
    end

    local tally = string.format("%d TAGS", math.floor(f.tags or 0))
    if (f.tags or 0) > 0 or f.aim_ok then
        text.draw(font.tiny, sw - 30 * s - text.width(font.tiny, tally), sh * 0.5, 255, 80, 190, 220, tally)
    end
    if f.spotted then
        local warn = "BUSTED BY A COP"
        text.draw(font.small, cx - text.width(font.small, warn) / 2, sh * 0.56, 255, 90, 80, 255, warn)
    end
end)
