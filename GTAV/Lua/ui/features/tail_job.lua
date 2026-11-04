-- Tail Job. Published fields: active (bool), state (1 tailing, 2 result), distance (metres to the target car), suspicion
-- (0..1, spotted at 1), lost_left (seconds before you lose them, -1 while in range), dest_dist (metres the target still
-- has to go, unknown to the player so only shown as a hint), result (1 success, 2 spotted, 3 lost, 4 wasted), pay, jobs.
features.on_draw("Tail Job", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local cx = sw / 2
    local state = math.floor(f.state or 0)
    local t = ctx.time() or 0

    if state == 2 then
        local result = math.floor(f.result or 0)
        local msgs = { "TARGET HOUSED", "YOU WERE MADE", "TARGET LOST", "WASTED" }
        local msg = msgs[result] or ""
        local r, g, b = 240, 80, 70
        if result == 1 then r, g, b = ar, ag, ab end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.28, r, g, b, 255, msg)
        if (f.pay or 0) > 0 then
            local p = string.format("+$%d", math.floor(f.pay))
            text.draw(font.item, cx - text.width(font.item, p) / 2, sh * 0.28 + text.height(big), 245, 245, 250, 255, p)
        end
        return
    end

    local w, h = 320 * s, 12 * s
    local x, y = cx - w / 2, sh * 0.08
    local max_d = 200
    local close_x = x + w * 18 / max_d
    local far_x = x + w * 160 / max_d
    draw.rect(x, y, close_x, y + h, 230, 60, 50, 170, 0)
    draw.rect(close_x, y, far_x, y + h, 90, 200, 110, 150, 0)
    draw.rect(far_x, y, x + w, y + h, 120, 120, 130, 140, 0)
    local d = math.max(0, math.min(max_d, f.distance or 0))
    local mx = x + w * d / max_d
    draw.rect(mx - 2 * s, y - 5 * s, mx + 2 * s, y + h + 5 * s, 255, 255, 255, 255, 2 * s)
    local dstr = string.format("%d M", math.floor(f.distance or 0))
    text.draw(font.small, cx - text.width(font.small, dstr) / 2, y - text.height(font.small) - 4 * s, 235, 235, 245, 255, dstr)

    local sus = math.max(0, math.min(1, f.suspicion or 0))
    local sy = y + h + 12 * s
    draw.rect(x, sy, x + w, sy + 6 * s, 255, 255, 255, 25, 3 * s)
    if sus > 0 then draw.rect(x, sy, x + w * sus, sy + 6 * s, 245, 180, 60, 240, 3 * s) end

    local lost = f.lost_left or -1
    local msg, r, g, b
    if lost >= 0 then
        local pulse = 0.5 + 0.5 * math.sin(t * 8)
        msg, r, g, b = string.format("CATCH UP  %d", math.ceil(lost)), 240, 120, 90
        text.draw(font.item, cx - text.width(font.item, msg) / 2, sy + 14 * s, r, g, b, math.floor(160 + 95 * pulse), msg)
    elseif sus > 0.5 then
        msg = "BACK OFF"
        text.draw(font.item, cx - text.width(font.item, msg) / 2, sy + 14 * s, 245, 180, 60, 255, msg)
    end
end)
