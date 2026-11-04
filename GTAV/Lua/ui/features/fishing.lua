-- Fishing. Published fields: active (bool, a line is cast), biting (bool), bite_left (seconds left to
-- reel in; present only while biting), caught (fish landed this session), best (heaviest catch in kg).
local flash = 0

features.on_draw("Fishing", function(f)
    if not f.active then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()

    if f.biting then
        flash = (flash + 0.25) % (math.pi * 2)
        local label = "FISH ON!  PRESS E"
        local lw = text.width(font.title, label)
        local pad = 14 * s
        local w, h = lw + pad * 2, text.height(font.title) + pad * 2 + 8 * s
        local x, y = sw * 0.5 - w * 0.5, sh * 0.62
        local a = math.floor(200 + 55 * math.sin(flash))
        draw.rect(x, y, x + w, y + h, 10, 10, 16, 190, 8 * s)
        draw.rect_outline(x, y, x + w, y + h, ar, ag, ab, a, 8 * s, 2)
        text.draw(font.title, x + pad, y + pad, 255, 255, 255, a, label)
        local frac = math.max(0, math.min(1, (f.bite_left or 0) / 1.5))
        draw.rect(x + pad, y + h - 8 * s, x + w - pad, y + h - 5 * s, 0, 0, 0, 150, 0)
        draw.rect(x + pad, y + h - 8 * s, x + pad + (w - pad * 2) * frac, y + h - 5 * s, ar, ag, ab, 255, 0)
        return
    end

    local caught = math.floor(f.caught or 0)
    local line = f.best and string.format("WAITING FOR A BITE   CAUGHT %d   BEST %.1f KG", caught, f.best)
        or string.format("WAITING FOR A BITE   CAUGHT %d", caught)
    local lw = text.width(font.tiny, line)
    local pad = 8 * s
    local x, y = sw * 0.5 - lw * 0.5 - pad, sh - 110 * s
    draw.rect(x, y, x + lw + pad * 2, y + text.height(font.tiny) + pad * 2, 10, 10, 16, 140, 5 * s)
    text.draw(font.tiny, x + pad, y + pad, 200, 200, 210, 230, line)
end)
