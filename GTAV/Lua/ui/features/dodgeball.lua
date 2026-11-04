-- Dodgeball. Published fields: active (bool), state (1 countdown, 2 playing, 3 won, 4 lost), lives, max_lives,
-- seconds (left in the round), countdown (seconds before the first throw), dodged (balls that missed you),
-- hit (1..0 right after you are hit).
features.on_draw("Dodgeball", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 1)

    local w, h = 300 * s, 64 * s
    local x0, y0 = sw / 2 - w / 2, 40 * s
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 18, 215, 12 * s)
    text.draw(font.small, x0 + 14 * s, y0 + 8 * s, 235, 235, 245, 255, "DODGEBALL")

    local lives, max = math.floor(f.lives or 0), math.floor(f.max_lives or 3)
    for i = 1, max do
        local cx = x0 + w - 14 * s - (max - i) * 24 * s - 8 * s
        local on = i <= lives
        draw.circle(cx, y0 + 18 * s, 8 * s, on and 255 or 60, on and 90 or 60, on and 90 or 70, 255)
    end

    local mid
    if state == 1 then mid = string.format("GET READY  %d", math.floor(f.countdown or 0))
    elseif state == 2 then
        local secs = math.floor(f.seconds or 0)
        mid = string.format("SURVIVE  %d:%02d", math.floor(secs / 60), secs % 60)
    elseif state == 3 then mid = "YOU SURVIVED!"
    else mid = "KNOCKED OUT" end
    local r, g, b = 255, 230, 120
    if state == 3 then r, g, b = 130, 255, 160 elseif state == 4 then r, g, b = 255, 110, 110 end
    text.draw(font.item, x0 + 14 * s, y0 + 32 * s, r, g, b, 255, mid)
    local dodged = string.format("%d DODGED", math.floor(f.dodged or 0))
    text.draw(font.tiny, x0 + w - 14 * s - text.width(font.tiny, dodged), y0 + 40 * s, 190, 190, 205, 230, dodged)

    local hit = f.hit or 0
    if hit > 0 then
        draw.rect_outline(0, 0, sw, sh, 255, 60, 60, math.floor(160 * hit), 0, 14 * s)
        local msg = "HIT!"
        text.draw(font.title, sw / 2 - text.width(font.title, msg) / 2, sh * 0.35, 255, 90, 90, math.floor(255 * hit), msg)
    end
    if state == 2 then
        local hint = "STAY IN THE COURT  -  DODGE THE BALLS"
        text.draw(font.tiny, sw / 2 - text.width(font.tiny, hint) / 2, y0 + h + 8 * s, 200, 200, 214, math.floor(150 + 60 * math.sin(t * 2)), hint)
    end
end)
