-- Eating Contest. Published fields: active (bool), state (1 countdown, 2 eating, 3 result), countdown / time_left
-- (seconds), mine / rival1 / rival2 (hot dogs eaten, fractional while mid-dog), choke (seconds of choking left, missing
-- when fine), place (1..3 once finished), best (most hot dogs in one contest), wins.
local function row(x, y, w, label, value, lead, colour, s)
    local frac = math.min(1, value / math.max(1, lead))
    draw.rect(x, y, x + w, y + 18 * s, 0, 0, 0, 140, 4 * s)
    draw.rect(x, y, x + w * frac, y + 18 * s, colour[1], colour[2], colour[3], 230, 4 * s)
    text.draw(font.hud_tiny, x + 6 * s, y + 9 * s - text.height(font.hud_tiny) / 2, 255, 255, 255, 255, label)
    local n = string.format("%d", math.floor(value))
    text.draw(font.hud_small, x + w + 8 * s, y + 9 * s - text.height(font.hud_small) / 2, 245, 245, 250, 255, n)
end

features.on_draw("Eating Contest", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)

    if state == 1 then
        local n = math.ceil(f.countdown or 0)
        local msg = n > 0 and tostring(n) or "EAT!"
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.3, 255, 255, 255, 255, msg)
        return
    end

    local mine, r1, r2 = f.mine or 0, f.rival1 or 0, f.rival2 or 0
    local lead = math.max(mine, r1, r2, 10)
    local w = 300 * s
    local x, y = cx - w / 2 - 16 * s, sh * 0.06
    if state == 2 then
        local t = string.format("%d", math.ceil(f.time_left or 0))
        text.draw(big, cx - text.width(big, t) / 2, y, 245, 245, 250, 255, t)
        y = y + text.height(big) + 6 * s
    end
    row(x, y, w, "YOU", mine, lead, { ar, ag, ab }, s)
    row(x, y + 26 * s, w, "BIG TONY", r1, lead, { 200, 90, 70 }, s)
    row(x, y + 52 * s, w, "HUNGRY HANK", r2, lead, { 120, 120, 200 }, s)

    if state == 2 then
        local part = mine - math.floor(mine)
        local by = y + 84 * s
        draw.rect(cx - 60 * s, by, cx + 60 * s, by + 5 * s, 0, 0, 0, 150, 2 * s)
        draw.rect(cx - 60 * s, by, cx - 60 * s + 120 * s * part, by + 5 * s, 255, 200, 90, 255, 2 * s)
        if f.choke then
            local pulse = 160 + math.floor(95 * math.abs(math.sin(ctx.time() * 10)))
            local msg = "CHOKING! SLOW DOWN"
            text.draw(big, cx - text.width(big, msg) / 2, sh * 0.42, 240, 80, 70, pulse, msg)
        end
    elseif state == 3 then
        local place = math.floor(f.place or 3)
        local names = { "CHAMPION!", "SECOND PLACE", "THIRD PLACE" }
        local msg = names[place] or "DONE"
        local r, g, b = 220, 220, 230
        if place == 1 then r, g, b = ar, ag, ab end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.3, r, g, b, 255, msg)
        local sub = string.format("BEST %d   WINS %d", math.floor(f.best or 0), math.floor(f.wins or 0))
        text.draw(font.hud_small, cx - text.width(font.hud_small, sub) / 2, sh * 0.3 + text.height(big), 210, 210, 222, 240, sub)
    end
end)
