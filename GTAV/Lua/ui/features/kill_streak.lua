-- Kill Streak. Published fields: active (bool), streak (kills since you last died),
-- next (kill count of the next reward; absent once every reward is earned),
-- invincible (seconds of invincibility left; absent when not invincible).
local pulse = 0
local last = 0

features.on_draw("Kill Streak", function(f)
    if not f.active then
        last = 0
        return
    end

    local streak = math.floor(f.streak or 0)
    if streak > last then pulse = 1 end
    last = streak
    pulse = pulse * 0.9

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()

    local title = string.format("%d STREAK", streak)
    local sub
    if f.invincible then
        sub = string.format("INVINCIBLE %.0fs", f.invincible)
    elseif f.next then
        sub = string.format("NEXT REWARD AT %d", math.floor(f.next))
    else
        sub = "ALL REWARDS EARNED"
    end

    local tw = text.width(font.hud, title)
    local sw2 = text.width(font.hud_tiny, sub)
    local pad = 10 * s
    local w = math.max(tw, sw2) + pad * 2
    local h = text.height(font.hud) + text.height(font.hud_tiny) + pad * 2 + 2 * s
    local x = sw - w - 28 * s
    local y = sh * 0.30

    draw.rect(x, y, x + w, y + h, 10, 10, 16, 160, 6 * s)
    draw.rect(x, y, x + 3 * s, y + h, ar, ag, ab, 255, 0)
    local glow = math.floor(255 * pulse)
    text.draw(font.hud, x + w - pad - tw, y + pad, 255, 255 - math.floor(glow * 0.4), 255 - glow, 255, title)
    local r, g, b = 170, 170, 180
    if f.invincible then r, g, b = 255, 215, 90 end
    text.draw(font.hud_tiny, x + w - pad - sw2, y + pad + text.height(font.hud) + 2 * s, r, g, b, 230, sub)
end)
