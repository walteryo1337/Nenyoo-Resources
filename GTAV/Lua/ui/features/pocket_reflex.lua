-- Pocket Reflex. Published fields: active (bool), state (1 wait for green, 2 GO, 3 round result, 4 pressed too
-- early, 5 all rounds done), round (rounds finished), rounds (total), last (ms, latest reaction), average (ms over
-- the finished rounds), best (ms, best average this session; 0 = none yet), times (blob "ms;" per round, 0 = not
-- played yet).
local function rating(ms)
    if ms <= 0 then return "", 200, 200, 214 end
    if ms < 200 then return "LIGHTNING", 120, 230, 255 end
    if ms < 250 then return "SHARP", 90, 225, 120 end
    if ms < 320 then return "DECENT", 240, 200, 70 end
    return "SLEEPY", 235, 120, 70
end

features.on_draw("Pocket Reflex", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local bw, bh = 560 * s, 420 * s
    local x0, y0 = sw / 2 - bw / 2, sh / 2 - bh / 2
    local state = math.floor(f.state or 0)

    local r, g, b = 40, 40, 52
    local big, small = "", ""
    if state == 1 then
        r, g, b = 170, 40, 40
        big, small = "WAIT...", "PRESS SPACE THE MOMENT THIS TURNS GREEN"
    elseif state == 2 then
        r, g, b = 40, 190, 80
        big, small = "NOW!", ""
    elseif state == 3 then
        r, g, b = 40, 70, 150
        big = string.format("%d MS", math.floor(f.last or 0))
        small = (rating(f.last or 0))
    elseif state == 4 then
        r, g, b = 150, 90, 30
        big, small = "TOO EARLY", "WAIT FOR GREEN"
    elseif state == 5 then
        r, g, b = 40, 70, 150
        big = string.format("AVG %d MS", math.floor(f.average or 0))
        small = "PRESS SPACE TO GO AGAIN"
    end

    draw.rect(x0, y0, x0 + bw, y0 + bh, r, g, b, 240, 16 * s)
    if state == 2 then
        local pulse = 0.5 + 0.5 * math.sin(t * 20)
        draw.rect_outline(x0, y0, x0 + bw, y0 + bh, 255, 255, 255, math.floor(120 + 135 * pulse), 16 * s, 6 * s)
    end
    text.draw(font.display, sw / 2 - text.width(font.display, big) / 2, y0 + bh * 0.38, 255, 255, 255, 255, big)
    if small ~= "" then
        local _, rr, rg, rb = rating(state == 3 and (f.last or 0) or 0)
        if state ~= 3 then rr, rg, rb = 235, 235, 245 end
        text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, small) / 2, y0 + bh * 0.58, rr, rg, rb, 240, small)
    end

    local i = 0
    local n = math.floor(f.rounds or 5)
    local slot = 70 * s
    local sx = sw / 2 - (n * slot) / 2
    for ms in string.gmatch(f.times or "", "(%d+);") do
        local v = tonumber(ms)
        local cx = sx + i * slot + slot / 2
        local label = v > 0 and tostring(v) or "-"
        local _, cr, cg, cb = rating(v)
        text.draw(font.hud_small, cx - text.width(font.hud_small, label) / 2, y0 + bh - 60 * s, cr, cg, cb, 240, label)
        i = i + 1
    end
    local best = math.floor(f.best or 0)
    local foot = string.format("ROUND %d / %d", math.min(math.floor(f.round or 0) + (state == 5 and 0 or 1), n), n)
    if best > 0 then foot = foot .. string.format("     BEST AVERAGE %d MS", best) end
    text.draw(font.hud_tiny, sw / 2 - text.width(font.hud_tiny, foot) / 2, y0 + bh - 26 * s, 220, 220, 232, 230, foot)
end)
