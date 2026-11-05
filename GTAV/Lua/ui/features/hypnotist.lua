-- Hypnotist. Published fields: active (bool), hold (0-1 progress while holding E on someone; present only while you are
-- looking at a valid target), minions (0-3 people under your spell), mode (0 follow, 1 dance, 2 sit, 3 freeze,
-- 4 attack others), left1 / left2 / left3 (seconds of trance left per slot; 0 = empty slot).
local modes = { "FOLLOWING YOU", "DANCING", "SITTING", "FROZEN", "ATTACKING" }

features.on_draw("Hypnotist", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local cx, cy = sw / 2, sh / 2

    if f.hold and f.hold > 0 then
        -- a spinning spiral that tightens as the hold completes
        local r = 46 * s
        local p = math.min(1, f.hold)
        for i = 0, 23 do
            local a1 = t * 6 + i * 0.5
            local rr = r * (1 - i / 26) * (1.2 - p * 0.4)
            local a2 = a1 + 0.5
            local rr2 = r * (1 - (i + 1) / 26) * (1.2 - p * 0.4)
            draw.line(cx + math.cos(a1) * rr, cy + math.sin(a1) * rr, cx + math.cos(a2) * rr2, cy + math.sin(a2) * rr2,
                170, 90, 240, math.floor(120 + 135 * p), 3 * s)
        end
        draw.circle_outline(cx, cy, r * 1.3, 255, 255, 255, 80, 2 * s)
        local pct = string.format("%d%%", math.floor(p * 100))
        text.draw(font.hud_small, cx - text.width(font.hud_small, pct) / 2, cy + r * 1.4, 230, 210, 255, 255, pct)
    end

    local n = math.floor(f.minions or 0)
    if n == 0 then return end
    local w = 230 * s
    local lh = text.height(font.hud_small) + 6 * s
    local h = 40 * s + lh * 3
    local x, y = 30 * s, sh * 0.4
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 205, 8 * s)
    draw.rect(x, y, x + 3 * s, y + h, 170, 90, 240, 255, 0)
    local m = modes[math.floor(f.mode or 0) + 1] or ""
    text.draw(font.hud, x + 14 * s, y + 8 * s, 230, 210, 255, 255, m)
    local lefts = { f.left1 or 0, f.left2 or 0, f.left3 or 0 }
    for i = 1, 3 do
        local ly = y + 16 * s + text.height(font.hud) + (i - 1) * lh
        local left = lefts[i]
        if left > 0 then
            local bx1, bx2 = x + 14 * s, x + w - 60 * s
            draw.rect(bx1, ly + 4 * s, bx2, ly + 10 * s, 40, 40, 50, 220, 3 * s)
            draw.rect(bx1, ly + 4 * s, bx1 + (bx2 - bx1) * math.min(1, left / 120), ly + 10 * s, 170, 90, 240, 255, 3 * s)
            local tl = string.format("%ds", math.ceil(left))
            text.draw(font.hud_small, x + w - 14 * s - text.width(font.hud_small, tl), ly, 220, 220, 232, 240, tl)
        else
            text.draw(font.hud_tiny, x + 14 * s, ly, 140, 140, 155, 200, "EMPTY SLOT")
        end
    end
end)
