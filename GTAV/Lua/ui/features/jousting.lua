-- Jousting. Shown while a match is running. Published fields: active (bool); countdown / charging / result / done
-- (bool, the current phase); count (seconds left in the countdown); pass / passes (current pass, passes in a match);
-- me / rival (scores); struck (bool, you already struck this pass); gap (metres between the bikes); sweet / band (the
-- perfect strike distance and its tolerance); my_res / their_res (0 none, 1 miss, 2 glance, 3 unseat, 4 too wide);
-- won (bool, you lead or won); wins (matches won this session).
local mine = { "YOU MISSED", "GLANCING BLOW", "UNSEATED THEM!", "TOO WIDE" }
local theirs = { "THEY MISSED", "THEY CLIPPED YOU", "YOU WERE UNSEATED", "" }

features.on_draw("Jousting", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx = sw / 2

    local w, h = 320 * s, 70 * s
    local x0, y0 = cx - w / 2, 40 * s
    draw.rect(x0, y0, x0 + w, y0 + h, 14, 12, 20, 220, 12 * s)
    draw.rect(x0, y0, x0 + w, y0 + 4 * s, 220, 180, 70, 230, 0)
    local title = string.format("JOUST  PASS %d/%d", math.floor(f.pass or 0), math.floor(f.passes or 3))
    text.draw(font.tiny, x0 + 14 * s, y0 + 12 * s, 230, 210, 150, 240, title)
    local score = string.format("YOU %d  -  %d RIVAL", math.floor(f.me or 0), math.floor(f.rival or 0))
    text.draw(font.small, cx - text.width(font.small, score) / 2, y0 + 34 * s, 245, 245, 250, 255, score)

    if f.countdown then
        local n = string.format("%d", math.max(1, math.ceil(f.count or 0)))
        text.draw(font.title, cx - text.width(font.title, n) / 2, sh * 0.32, 255, 220, 90, 255, n)
    elseif f.charging then
        local bw, bh = 420 * s, 14 * s
        local bx, by = cx - bw / 2, sh * 0.78
        local far = 30
        local function xat(d) return bx + bw * (1 - math.min(d, far) / far) end
        draw.rect(bx, by, bx + bw, by + bh, 20, 20, 28, 210, bh / 2)
        local sweet, band = f.sweet or 6, f.band or 1.5
        draw.rect(xat(sweet + band), by, xat(sweet - band), by + bh, 255, 210, 80, 230, 0)
        local gx = xat(f.gap or far)
        draw.rect(gx - 2 * s, by - 6 * s, gx + 2 * s, by + bh + 6 * s, 255, 255, 255, 255, 0)
        local hint = f.struck and "STRUCK" or "HORN TO STRIKE IN THE GOLD"
        text.draw(font.tiny, cx - text.width(font.tiny, hint) / 2, by + bh + 10 * s, 235, 235, 245, 230, hint)
    elseif f.result then
        local a = mine[math.floor(f.my_res or 0)] or ""
        local b = theirs[math.floor(f.their_res or 0)] or ""
        text.draw(font.small, cx - text.width(font.small, a) / 2, sh * 0.30, 255, 220, 90, 255, a)
        if b ~= "" then
            text.draw(font.small, cx - text.width(font.small, b) / 2, sh * 0.30 + 36 * s, 255, 130, 110, 255, b)
        end
    elseif f.done then
        local msg = "DRAW"
        local r, g, b = 220, 220, 230
        if (f.me or 0) > (f.rival or 0) then msg, r, g, b = "CHAMPION", 120, 255, 160
        elseif (f.me or 0) < (f.rival or 0) then msg, r, g, b = "DEFEATED", 255, 90, 80 end
        text.draw(font.title, cx - text.width(font.title, msg) / 2, sh * 0.3, r, g, b, 255, msg)
        local wins = string.format("%d WINS", math.floor(f.wins or 0))
        text.draw(font.tiny, cx - text.width(font.tiny, wins) / 2, sh * 0.3 + 64 * s, 200, 200, 214, 220, wins)
    end
end)
