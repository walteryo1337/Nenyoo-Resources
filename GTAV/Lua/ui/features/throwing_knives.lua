-- Throwing Knives. Published fields: active (bool, holding the knife on foot), ready (knives in hand),
-- total (knives you carry).
features.on_draw("Throwing Knives", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local ready, total = math.floor(f.ready or 0), math.floor(f.total or 0)

    local size = 10 * s
    local gap = 6 * s
    local w = total * size + (total - 1) * gap
    local x = sw - 40 * s - w
    local y = sh * 0.80

    text.draw(font.hud_tiny, x + w - text.width(font.hud_tiny, "KNIVES"), y - text.height(font.hud_tiny) - 4 * s, 200, 200, 210, 230, "KNIVES")
    for i = 1, total do
        local bx = x + (i - 1) * (size + gap)
        if i <= ready then
            draw.rect(bx, y, bx + size, y + size * 2.4, ar, ag, ab, 255, 2 * s)
        else
            draw.rect(bx, y, bx + size, y + size * 2.4, 60, 60, 70, 160, 2 * s)
        end
    end
    if ready == 0 then
        local msg = "PICK UP YOUR KNIVES"
        text.draw(font.hud_tiny, x + w - text.width(font.hud_tiny, msg), y + size * 2.4 + 6 * s, 255, 90, 80, 230, msg)
    end
end)
