-- Tire wear gauge. Published fields: active (bool), tread (0..1), low_grip (bool, worn enough to slide),
-- wearing (bool, burning out or drifting right now). Sits just above the fuel gauge.
features.on_draw("Tire Wear", function(f)
    if not f.active then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local tread = math.max(0, math.min(1, f.tread or 0))
    local w = sw * 0.14
    local h = 8
    local x = sw * 0.015
    local y = sh * 0.735
    local lh = text.height(font.hud_small)
    local t = ctx.time and ctx.time() or 0

    local r, g, b = 200, 200, 210
    if tread <= 0 then
        r, g, b = 235, 60, 60
    elseif tread < 0.25 then
        r, g, b = 240, 170, 50
    end
    local a = 255
    if tread <= 0 then a = 120 + math.floor(135 * (0.5 + 0.5 * math.sin(t * 10))) end

    draw.rect(x - 4, y - lh - 8, x + w + 4, y + h + 4, 12, 12, 18, 170, 4)
    local label = "TIRES"
    if tread <= 0 then label = "TIRES  BALD"
    elseif f.low_grip then label = "TIRES  LOW GRIP" end
    text.draw(font.hud_small, x, y - lh - 4, 230, 230, 235, 255, label)
    local pct = string.format("%d%%", math.floor(tread * 100 + 0.5))
    if f.wearing and math.floor(t * 8) % 2 == 0 then pct = "- " .. pct end
    text.draw(font.hud_small, x + w - text.width(font.hud_small, pct), y - lh - 4, r, g, b, a, pct)

    draw.rect(x, y, x + w, y + h, 40, 40, 48, 220, 3)
    if tread > 0 then
        draw.rect(x, y, x + w * tread, y + h, r, g, b, a, 3)
    end
    for k = 1, 7 do
        local tx = x + w * k / 8
        draw.rect(tx - 1, y, tx + 1, y + h, 12, 12, 18, 160, 0)
    end
end)
