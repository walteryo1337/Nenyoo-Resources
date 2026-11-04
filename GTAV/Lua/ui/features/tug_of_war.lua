-- Tug of War. Shown from the countdown to the result screen. Published fields: active (bool), countdown / pulling /
-- won / lost (bool), count (seconds left in the countdown), pos (-1..1, rope position: 1 = you dragged them over your
-- line, -1 = they dragged you over theirs), tension (0..1, how tight the rope is), time_left (seconds), wins / losses
-- (this session).
features.on_draw("Tug of War", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local cx = sw / 2

    local w, h = 420 * s, 96 * s
    local x0, y0 = cx - w / 2, 40 * s
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 18, 215, 12 * s)
    text.draw(font.small, x0 + 16 * s, y0 + 8 * s, 235, 235, 245, 255, "TUG OF WAR")
    local tally = string.format("%d - %d", math.floor(f.wins or 0), math.floor(f.losses or 0))
    if f.pulling then tally = string.format("%d", math.ceil(f.time_left or 0)) end
    text.draw(font.small, x0 + w - 16 * s - text.width(font.small, tally), y0 + 8 * s, 245, 245, 250, 255, tally)

    local bx0, bx1, by = x0 + 16 * s, x0 + w - 16 * s, y0 + 50 * s
    local mid = (bx0 + bx1) / 2
    draw.rect(bx0, by, mid, by + 12 * s, 120, 40, 40, 255, 6 * s)
    draw.rect(mid, by, bx1, by + 12 * s, 40, 110, 60, 255, 6 * s)
    draw.rect(mid - 1 * s, by - 4 * s, mid + 1 * s, by + 16 * s, 245, 245, 250, 255, 0)
    local p = math.max(-1, math.min(1, f.pos or 0))
    local mx = mid + p * (bx1 - bx0) / 2
    local ten = f.tension or 0
    local shake = f.pulling and ten > 0.5 and math.sin(t * 60) * 2 * s or 0
    draw.circle(mx + shake, by + 6 * s, 10 * s, 255, 220, 90, 255)
    text.draw(font.tiny, bx0, by + 20 * s, 255, 120, 110, 230, "THEM")
    text.draw(font.tiny, bx1 - text.width(font.tiny, "YOU"), by + 20 * s, 120, 230, 150, 230, "YOU")
    if f.pulling then
        local label = ten > 0.05 and "ROPE TIGHT - FLOOR IT" or "ROPE SLACK"
        text.draw(font.tiny, cx - text.width(font.tiny, label) / 2, by + 20 * s, 220, 220, 230, 220, label)
    end

    local msg, r, g, b
    if f.countdown then
        local n = math.ceil(f.count or 0)
        msg, r, g, b = n > 0 and tostring(n) or "PULL!", 255, 220, 90
    elseif f.won then msg, r, g, b = "YOU WIN", 120, 255, 160
    elseif f.lost then msg, r, g, b = "DRAGGED", 255, 90, 80 end
    if msg then text.draw(font.title, cx - text.width(font.title, msg) / 2, sh * 0.3, r, g, b, 255, msg) end
end)
