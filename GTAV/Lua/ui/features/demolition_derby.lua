-- Demolition Derby. Published fields: active (bool, a round is running), state (1 countdown, 2 fight,
-- 3 won, 4 lost), countdown (seconds left before GO), left / total (rivals still running / started),
-- knockouts (this round's knockouts credited to you), wins, pay (last round's payout), place (finishing
-- place once the round ends), seconds (fight time), ko_age (0..1 since your last knockout; 1 = old),
-- outside (bool, you are outside the arena and about to be disqualified).
local function ordinal(n)
    local last2, last = n % 100, n % 10
    if last2 >= 11 and last2 <= 13 then return n .. "TH" end
    if last == 1 then return n .. "ST" elseif last == 2 then return n .. "ND" elseif last == 3 then return n .. "RD" end
    return n .. "TH"
end

local function centred(fnt, cx, y, str, r, g, b, a)
    text.draw(fnt, cx - text.width(fnt, str) / 2, y, r, g, b, a, str)
end

features.on_draw("Demolition Derby", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)

    if state == 1 then
        local n = math.floor(f.countdown or 0)
        centred(font.hud_small, cx, sh * 0.30, "DEMOLITION DERBY", ar, ag, ab, 230)
        centred(big, cx, sh * 0.30 + text.height(font.hud_small) + 6 * s, n > 0 and tostring(n) or "GO", 255, 255, 255, 255)
        return
    end

    local left, total = math.floor(f.left or 0), math.floor(f.total or 0)
    local secs = math.floor(f.seconds or 0)
    local w, h = 300 * s, 58 * s
    local x, y = cx - w / 2, sh * 0.06
    draw.rect(x, y, x + w, y + h, 10, 10, 16, 210, 6 * s)
    draw.rect(x, y, x + w, y + 3 * s, ar, ag, ab, 255, 2 * s)
    text.draw(font.hud_tiny, x + 12 * s, y + 9 * s, 165, 165, 180, 255, "DEMOLITION DERBY")
    local clock = string.format("%d:%02d", math.floor(secs / 60), secs % 60)
    text.draw(font.hud_tiny, x + w - 12 * s - text.width(font.hud_tiny, clock), y + 9 * s, 165, 165, 180, 255, clock)
    local line = string.format("RIVALS %d/%d    KO %d    WINS %d", left, total, math.floor(f.knockouts or 0), math.floor(f.wins or 0))
    text.draw(font.hud_small, x + 12 * s, y + 9 * s + text.height(font.hud_tiny) + 4 * s, 245, 245, 250, 255, line)

    local below = y + h + 10 * s
    local ko = f.ko_age or 1
    if state == 2 and ko < 1 then
        centred(font.hud, cx, below + ko * 8 * s, "KNOCKOUT!", 255, 170, 60, math.floor(255 * (1 - ko)))
    end
    if state == 2 and f.outside then
        local pulse = 160 + math.floor(95 * math.abs(math.sin(ctx.time() * 6)))
        centred(font.hud, cx, sh * 0.22, "GET BACK IN THE ARENA", 255, 70, 60, pulse)
    end

    if state == 3 or state == 4 then
        local won = state == 3
        local title = won and "LAST CAR STANDING" or ("WRECKED - " .. ordinal(math.floor(f.place or 0)) .. " PLACE")
        local r, g, b = 255, 80, 70
        if won then r, g, b = ar, ag, ab end
        centred(big, cx, sh * 0.30, title, r, g, b, 255)
        local pay = math.floor(f.pay or 0)
        if pay > 0 then centred(font.hud, cx, sh * 0.30 + text.height(big) + 8 * s, string.format("+$%d", pay), 120, 230, 120, 255) end
    end
end)
