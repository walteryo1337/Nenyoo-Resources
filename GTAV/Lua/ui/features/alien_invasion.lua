-- Alien Invasion. Published fields: active (bool), ufos (ships in the sky), aliens (on the ground), abducted (people
-- taken), downed (ships shot down), killed (aliens killed), beamed (bool, you are caught in a tractor beam right now),
-- hp1 / hp2 / hp3 (0-1 hull of each ship in the sky, present only for ships that exist).
features.on_draw("Alien Invasion", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local hps = {}
    for _, k in ipairs({ "hp1", "hp2", "hp3" }) do if f[k] then hps[#hps + 1] = f[k] end end

    local pw = 300 * s
    local ph = (78 + #hps * 22) * s
    local px, py = sw - pw - 30 * s, sh * 0.30
    draw.rect(px, py, px + pw, py + ph, 10, 16, 12, 215, 10 * s)
    draw.rect(px, py, px + 4 * s, py + ph, 90, 255, 130, 255, 2 * s)
    text.draw(font.item, px + 16 * s, py + 10 * s, 140, 255, 160, 255, "ALIEN INVASION")
    local stats = string.format("DOWNED %d   ALIENS %d   TAKEN %d", math.floor(f.downed or 0), math.floor(f.aliens or 0), math.floor(f.abducted or 0))
    text.draw(font.small, px + 16 * s, py + 42 * s, 200, 220, 205, 255, stats)
    for i, hp in ipairs(hps) do
        local by = py + (66 + (i - 1) * 22) * s
        local bx1, bx2 = px + 16 * s, px + pw - 16 * s
        draw.rect(bx1, by, bx2, by + 10 * s, 30, 40, 34, 255, 5 * s)
        if hp > 0 then draw.rect(bx1, by, bx1 + (bx2 - bx1) * hp, by + 10 * s, 90, 255, 130, 255, 5 * s) end
    end

    if f.beamed then
        local pulse = 0.5 + 0.5 * math.sin(t * 10)
        draw.rect_gradient(0, 0, sw, sh, 90, 255, 130, math.floor(40 * pulse), 90, 255, 130, math.floor(40 * pulse),
            90, 255, 130, math.floor(80 * pulse), 90, 255, 130, math.floor(80 * pulse))
        local msg = "TRACTOR BEAM!  SHOOT THE SHIP TO BREAK FREE"
        local w = text.width(font.title, msg)
        draw.rect(sw / 2 - w / 2 - 16 * s, sh * 0.2 - 10 * s, sw / 2 + w / 2 + 16 * s, sh * 0.2 + text.height(font.title) + 10 * s, 10, 16, 12, 220, 8 * s)
        text.draw(font.title, sw / 2 - w / 2, sh * 0.2, 140, 255, 160, 255, msg)
    end
end)
