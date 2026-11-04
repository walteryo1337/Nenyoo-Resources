-- Boat Cannons. Shown while you drive a boat with Boat Cannons on. Published fields: active (bool), left / right (0..1,
-- reload progress of each broadside; 1 = loaded), side (-1 left, 1 right: the side your camera is looking at).
local function battery(x, y, s, k, aimed, label)
    local w, h = 110 * s, 34 * s
    local ready = k >= 1
    local r, g, b = 120, 120, 130
    if ready then r, g, b = 255, 200, 80 end
    draw.rect(x, y, x + w, y + h, 14, 12, 10, aimed and 230 or 170, 8 * s)
    if aimed then draw.rect(x, y + h - 3 * s, x + w, y + h, 255, 200, 80, 255, 0) end
    text.draw(font.tiny, x + 10 * s, y + 4 * s, r, g, b, 255, label)
    draw.rect(x + 10 * s, y + 22 * s, x + w - 10 * s, y + 27 * s, 40, 36, 30, 255, 2 * s)
    draw.rect(x + 10 * s, y + 22 * s, x + 10 * s + (w - 20 * s) * math.max(0, math.min(1, k)), y + 27 * s, r, g, b, 255, 2 * s)
end

features.on_draw("Boat Cannons", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx, y = sw / 2, sh - 150 * s
    local side = f.side or 1
    battery(cx - 120 * s, y, s, f.left or 1, side < 0, "PORT")
    battery(cx + 10 * s, y, s, f.right or 1, side > 0, "STARBOARD")
    local hint = "LOOK LEFT OR RIGHT  -  CLICK TO FIRE A BROADSIDE"
    text.draw(font.tiny, cx - text.width(font.tiny, hint) / 2, y + 42 * s, 220, 210, 190, 200, hint)
end)
