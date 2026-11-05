-- Insurance Scam. Published fields: active (bool), state (1 under review, 2 approved, 3 denied: hit by police, 4 denied:
-- you died, 5 denied: already claimed against that car), progress (0..1 through the review), amount (claim value),
-- speed (km/h of the car that hit you), claims (approved this session), total (cash collected this session).
features.on_draw("Insurance Scam", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local state = math.floor(f.state or 0)

    local w, h = 300 * s, 92 * s
    local x, y = sw - w - 30 * s, sh * 0.3
    draw.rect(x, y, x + w, y + h, 245, 242, 232, 235, 4 * s)
    draw.rect(x, y, x + w, y + 22 * s, 40, 70, 130, 255, 4 * s)
    local head = "CLAIM FORM"
    text.draw(font.hud_small, x + 10 * s, y + 11 * s - text.height(font.hud_small) / 2, 255, 255, 255, 255, head)
    local num = string.format("NO. %04d", (math.floor(f.claims or 0) + 1) * 37 % 10000)
    text.draw(font.hud_tiny, x + w - 10 * s - text.width(font.hud_tiny, num), y + 11 * s - text.height(font.hud_tiny) / 2, 220, 230, 255, 230, num)

    local line1 = string.format("IMPACT  %d KM/H", math.floor(f.speed or 0))
    local line2 = string.format("CLAIM   $%d", math.floor(f.amount or 0))
    text.draw(font.hud_small, x + 10 * s, y + 28 * s, 40, 40, 50, 255, line1)
    text.draw(font.hud_small, x + 10 * s, y + 30 * s + text.height(font.hud_small), 40, 40, 50, 255, line2)

    if state == 1 then
        local p = math.max(0, math.min(1, f.progress or 0))
        local by = y + h - 14 * s
        draw.rect(x + 10 * s, by, x + w - 10 * s, by + 6 * s, 40, 40, 50, 40, 3 * s)
        draw.rect(x + 10 * s, by, x + 10 * s + (w - 20 * s) * p, by + 6 * s, 40, 70, 130, 255, 3 * s)
        local rv = "UNDER REVIEW"
        text.draw(font.hud_tiny, x + w - 10 * s - text.width(font.hud_tiny, rv), by - text.height(font.hud_tiny) - 2 * s, 90, 90, 100, 255, rv)
        return
    end

    local stamp, r, g, b
    if state == 2 then stamp, r, g, b = "APPROVED", 40, 150, 70
    elseif state == 3 then stamp, r, g, b = "DENIED - POLICE", 190, 40, 40
    elseif state == 4 then stamp, r, g, b = "DENIED - DECEASED", 190, 40, 40
    else stamp, r, g, b = "DENIED - DUPLICATE", 190, 40, 40 end
    local sx = x + w - 14 * s - text.width(font.hud, stamp)
    local sy = y + h - 12 * s - text.height(font.hud)
    draw.rect(sx - 6 * s, sy - 2 * s, sx + text.width(font.hud, stamp) + 6 * s, sy + text.height(font.hud) + 2 * s, r, g, b, 40, 3 * s)
    text.draw(font.hud, sx, sy, r, g, b, 255, stamp)
    if state == 2 and (f.total or 0) > 0 then
        local tot = string.format("TOTAL $%d", math.floor(f.total))
        text.draw(font.hud_tiny, x + 10 * s, y + h - 10 * s - text.height(font.hud_tiny), 90, 90, 100, 255, tot)
    end
end)
