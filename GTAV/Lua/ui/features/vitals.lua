
-- Stamina & Breath. Published fields: active (bool), stamina (0..1), breath (0..1), underwater (bool).
-- hunger (0..1, present only while the Hunger option is on; shown once you are getting hungry).
-- warmth (0..1, present only while the Cold Exposure option is on; shown once you are getting cold).
-- thirst (0..1 hydration, present only while the Thirst option is on; shown once you are getting thirsty).
-- hygiene (0..1 cleanliness, present only while the Hygiene option is on; shown once you start to smell).
-- Each bar shows while it is draining or refilling and fades out once full.
local shown = { stamina = 0, breath = 0, hunger = 0, warmth = 0, thirst = 0, hygiene = 0 }

local function bar(x, y, w, h, frac, r, g, b, a)
    draw.rect(x, y, x + w, y + h, 0, 0, 0, math.floor(a * 0.55), h * 0.5)
    if frac > 0 then draw.rect(x, y, x + w * frac, y + h, r, g, b, a, h * 0.5) end
end

features.on_draw("Vitals", function(f)
    local st = f.stamina or 1
    local br = f.breath or 1
    local want_st = f.active and st < 0.995
    local want_br = f.active and (f.underwater or br < 0.995)
    shown.stamina = shown.stamina + ((want_st and 1 or 0) - shown.stamina) * 0.1
    shown.breath = shown.breath + ((want_br and 1 or 0) - shown.breath) * 0.1
    local hu = f.hunger
    local want_hu = f.active and hu ~= nil and hu < 0.34
    shown.hunger = shown.hunger + ((want_hu and 1 or 0) - shown.hunger) * 0.1
    local wa = f.warmth
    local want_wa = f.active and wa ~= nil and wa < 0.5
    shown.warmth = shown.warmth + ((want_wa and 1 or 0) - shown.warmth) * 0.1
    local th = f.thirst
    local want_th = f.active and th ~= nil and th < 0.34
    shown.thirst = shown.thirst + ((want_th and 1 or 0) - shown.thirst) * 0.1
    local hy = f.hygiene
    local want_hy = f.active and hy ~= nil and hy <= 0.5
    shown.hygiene = shown.hygiene + ((want_hy and 1 or 0) - shown.hygiene) * 0.1
    if shown.stamina < 0.01 and shown.breath < 0.01 and shown.hunger < 0.01 and shown.warmth < 0.01 and shown.thirst < 0.01 and shown.hygiene < 0.01 then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local w, h = 180 * s, 6 * s
    local x = sw * 0.5 - w * 0.5
    local y = sh - 60 * s

    if shown.hygiene >= 0.01 then
        local r, g, b = 150, 200, 90
        if (hy or 1) <= 0.0 then r, g, b = 150, 120, 60 end
        bar(x, y, w, h, math.max(hy or 0, 0.02), r, g, b, math.floor(230 * shown.hygiene))
        y = y - h - 6 * s
    end
    if shown.warmth >= 0.01 then
        local r, g, b = 150, 215, 255
        if (wa or 1) <= 0.0 then r, g, b = 235, 245, 255 end
        bar(x, y, w, h, math.max(wa or 0, 0.02), r, g, b, math.floor(230 * shown.warmth))
        y = y - h - 6 * s
    end
    if shown.thirst >= 0.01 then
        local r, g, b = 60, 210, 190
        if (th or 1) <= 0.0 then r, g, b = 235, 70, 70 end
        bar(x, y, w, h, math.max(th or 0, 0.02), r, g, b, math.floor(230 * shown.thirst))
        y = y - h - 6 * s
    end
    if shown.hunger >= 0.01 then
        local r, g, b = 235, 150, 60
        if (hu or 1) <= 0.0 then r, g, b = 235, 70, 70 end
        bar(x, y, w, h, math.max(hu or 0, 0.02), r, g, b, math.floor(230 * shown.hunger))
        y = y - h - 6 * s
    end
    if shown.breath >= 0.01 then
        local r, g, b = 80, 190, 255
        if br < 0.25 then r, g, b = 235, 70, 70 end
        bar(x, y, w, h, br, r, g, b, math.floor(230 * shown.breath))
        y = y - h - 6 * s
    end
    if shown.stamina >= 0.01 then
        local r, g, b = 250, 210, 70
        if st < 0.2 then r, g, b = 240, 120, 50 end
        bar(x, y, w, h, st, r, g, b, math.floor(230 * shown.stamina))
    end
end)
