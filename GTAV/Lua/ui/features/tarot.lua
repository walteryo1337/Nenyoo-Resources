-- Tarot Deck. Published fields: active (bool), card (0..12), name, meaning, reversed (bool), seconds (left on
-- the card's fate), flip (0..1 over the reveal right after the card is drawn, then 1).
local numerals = { "XIX", "XVIII", "VIII", "VII", "X", "XVII", "VI", "I", "XVI", "XIII", "0", "XV", "XII" }
local colours = {
    { 255, 200, 70 }, { 170, 180, 255 }, { 255, 130, 70 }, { 120, 200, 255 }, { 120, 230, 120 }, { 255, 240, 160 },
    { 255, 120, 170 }, { 200, 130, 255 }, { 255, 90, 60 }, { 200, 200, 200 }, { 255, 210, 120 }, { 220, 50, 50 }, { 140, 220, 200 },
}

local function emblem(cx, cy, r, c, reversed, t)
    local glow = math.floor(70 + 30 * math.sin(t * 3))
    draw.circle(cx, cy, r * 1.35, c[1], c[2], c[3], glow)
    draw.circle(cx, cy, r, c[1], c[2], c[3], 255)
    draw.circle(cx, cy, r * 0.62, 24, 14, 36, 255)
    draw.circle(cx, cy, r * 0.32, c[1], c[2], c[3], 255)
    for i = 0, 7 do
        local a = i * math.pi / 4 + t * 0.4
        draw.line(cx + math.cos(a) * r * 1.1, cy + math.sin(a) * r * 1.1, cx + math.cos(a) * r * 1.6, cy + math.sin(a) * r * 1.6, c[1], c[2], c[3], 200, 2)
    end
    if reversed then
        draw.line(cx - r, cy + r, cx + r, cy - r, 255, 60, 60, 230, 3)
    end
end

local function card_face(x0, y0, w, h, s, f, c, t)
    draw.rect(x0, y0, x0 + w, y0 + h, 24, 14, 36, 245, 10 * s)
    draw.rect_outline(x0 + 5 * s, y0 + 5 * s, x0 + w - 5 * s, y0 + h - 5 * s, c[1], c[2], c[3], 230, 7 * s, 2 * s)
    local num = numerals[(f.card or 0) + 1] or ""
    text.draw(font.small, x0 + w / 2 - text.width(font.small, num) / 2, y0 + 16 * s, c[1], c[2], c[3], 255, num)
    emblem(x0 + w / 2, y0 + h * 0.45, w * 0.2, c, f.reversed, t)
    local name = f.name or ""
    text.draw(font.item, x0 + w / 2 - text.width(font.item, name) / 2, y0 + h - 70 * s, 240, 235, 250, 255, name)
    if f.reversed then
        local rv = "REVERSED"
        text.draw(font.tiny, x0 + w / 2 - text.width(font.tiny, rv) / 2, y0 + h - 40 * s, 255, 110, 100, 255, rv)
    end
end

local function card_back(x0, y0, w, h, s)
    draw.rect(x0, y0, x0 + w, y0 + h, 40, 18, 70, 245, 10 * s)
    draw.rect_outline(x0 + 5 * s, y0 + 5 * s, x0 + w - 5 * s, y0 + h - 5 * s, 210, 170, 90, 230, 7 * s, 2 * s)
    local cx, cy = x0 + w / 2, y0 + h / 2
    draw.circle_outline(cx, cy, w * 0.3, 210, 170, 90, 220, 2 * s)
    draw.circle_outline(cx, cy, w * 0.18, 210, 170, 90, 220, 2 * s)
end

features.on_draw("Tarot Deck", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local c = colours[(f.card or 0) + 1] or colours[1]
    local flip = f.flip or 1

    if flip < 1 then
        local w, h = 240 * s, 390 * s
        local turn = math.min(flip / 0.3, 1)
        local sx = math.abs(math.cos(turn * math.pi))
        local fade = flip > 0.85 and (1 - flip) / 0.15 or 1
        local cw = w * math.max(sx, 0.02)
        local x0, y0 = sw / 2 - cw / 2, sh / 2 - h / 2
        if turn < 0.5 then
            card_back(x0, y0, cw, h, s)
        elseif sx > 0.15 then
            card_face(x0, y0, cw, h, s, f, c, t)
        end
        if turn >= 1 then
            local m = f.meaning or ""
            local mw = text.width(font.small, m)
            draw.rect(sw / 2 - mw / 2 - 14 * s, y0 + h + 14 * s, sw / 2 + mw / 2 + 14 * s, y0 + h + 48 * s, 12, 8, 20, math.floor(210 * fade), 14 * s)
            text.draw(font.small, sw / 2 - mw / 2, y0 + h + 20 * s, 235, 230, 245, math.floor(255 * fade), m)
        end
        return
    end

    local w, h = 220 * s, 64 * s
    local x0, y0 = sw - w - 24 * s, 200 * s
    draw.rect(x0, y0, x0 + w, y0 + h, 18, 10, 28, 215, 10 * s)
    draw.rect(x0, y0, x0 + 5 * s, y0 + h, c[1], c[2], c[3], 255)
    emblem(x0 + 32 * s, y0 + h / 2, 11 * s, c, f.reversed, t)
    text.draw(font.small, x0 + 58 * s, y0 + 9 * s, 240, 235, 250, 255, f.name or "")
    local secs = math.floor(f.seconds or 0)
    local sub = string.format("%s%d:%02d", f.reversed and "REVERSED  " or "", math.floor(secs / 60), secs % 60)
    local r, g, b = 190, 185, 205
    if f.reversed then r, g, b = 255, 130, 120 end
    text.draw(font.tiny, x0 + 58 * s, y0 + 36 * s, r, g, b, 230, sub)
end)
