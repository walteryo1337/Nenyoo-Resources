-- Mind Reader. Published fields: active (bool), count (bubbles, up to 5), and per bubble i = 1..count:
-- xi / yi (screen position of the spot above the head, 0..1), scalei (0.6..1, smaller further away), cati
-- (0 person, 1 cop, 2 gang, 3 driver, 4 scared, 5 hurt, 6 medic or firefighter, 7 night owl, 8 animal), texti.
local TINTS = {
    [0] = { 245, 245, 250 },
    [1] = { 170, 200, 255 },
    [2] = { 255, 215, 140 },
    [3] = { 210, 240, 210 },
    [4] = { 255, 180, 180 },
    [5] = { 255, 205, 205 },
    [6] = { 200, 255, 240 },
    [7] = { 205, 195, 255 },
    [8] = { 255, 240, 200 },
}

features.on_draw("Mind Reader", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local count = math.floor(f.count or 0)
    for i = 1, count do
        local txt = f["text" .. i]
        if txt and txt ~= "" then
            local sc = (f["scale" .. i] or 1) * s
            local cat = math.floor(f["cat" .. i] or 0)
            local tint = TINTS[cat] or TINTS[0]
            local bob = math.sin(t * 2 + i) * 3 * sc
            local fnt = sc > 0.8 * s and font.small or font.tiny
            local tw, th = text.width(fnt, txt), text.height(fnt)
            local pad = 12 * sc
            local cx = (f["x" .. i] or 0.5) * sw
            local by = (f["y" .. i] or 0.5) * sh - 40 * sc + bob
            local x1, y1 = cx - tw / 2 - pad, by - th - pad * 1.6
            local x2, y2 = cx + tw / 2 + pad, by
            draw.rect(x1 + 3 * sc, y1 + 4 * sc, x2 + 3 * sc, y2 + 4 * sc, 0, 0, 0, 70, 18 * sc)
            draw.rect(x1, y1, x2, y2, tint[1], tint[2], tint[3], 240, 18 * sc)
            draw.circle(cx - 6 * sc, y2 + 10 * sc, 6 * sc, tint[1], tint[2], tint[3], 235)
            draw.circle(cx - 12 * sc, y2 + 22 * sc, 3.5 * sc, tint[1], tint[2], tint[3], 225)
            text.draw(fnt, cx - tw / 2, y1 + pad * 0.8, 30, 30, 40, 255, txt)
        end
    end
end)
