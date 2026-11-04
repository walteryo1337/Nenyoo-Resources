-- Hold Breath. Published fields: active (bool, looking down a sniper scope), holding (bool, breath held and
-- the scope steady), winded (bool, ran out of breath and the sway is worse until it recovers), breath (0 to 1).
-- Drawn as a thin breath bar below the scope centre with a short hint.
local shown = 0

features.on_draw("Hold Breath", function(f)
    local dt = ctx.delta and ctx.delta() or 0.016
    if f.active then shown = math.min(1, shown + dt * 6) else shown = math.max(0, shown - dt * 6) end
    if shown <= 0 then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local a = shown
    local breath = math.max(0, math.min(1, f.breath or 1))
    local w, h = 220 * s, 6 * s
    local x, y = sw / 2 - w / 2, sh / 2 + 150 * s

    local r, g, b = 210, 230, 255
    if f.winded then
        if math.floor((ctx.time() or 0) * 4) % 2 == 0 then r, g, b = 235, 80, 70 else r, g, b = 200, 120, 110 end
    elseif f.holding then
        r, g, b = 120, 220, 255
    end

    draw.rect(x, y, x + w, y + h, 0, 0, 0, math.floor(150 * a), h / 2)
    if breath > 0 then draw.rect(x, y, x + w * breath, y + h, r, g, b, math.floor(230 * a), h / 2) end

    local hint
    if f.winded then hint = "CATCHING YOUR BREATH"
    elseif f.holding then hint = "HOLDING BREATH"
    else hint = "HOLD SHIFT TO STEADY YOUR AIM" end
    text.draw(font.tiny, sw / 2 - text.width(font.tiny, hint) / 2, y + h + 6 * s, 230, 230, 240, math.floor(220 * a), hint)
end)
