-- Target Practice. Published fields: active (bool, a round is running), remaining (targets left),
-- total (targets per round), time (seconds into the round), best (best round time; absent until set).
features.on_draw("Target Practice", function(f)
    if not f.active then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()

    local remaining = math.floor(f.remaining or 0)
    local total = math.max(1, math.floor(f.total or 1))
    local clock = string.format("%.2f", f.time or 0)
    local left = string.format("%d / %d LEFT", remaining, total)
    local best = f.best and string.format("BEST %.2f", f.best) or "NO BEST YET"

    local pad = 10 * s
    local cw = text.width(font.title, clock)
    local w = math.max(cw, text.width(font.tiny, left), text.width(font.tiny, best)) + pad * 2
    local h = text.height(font.title) + text.height(font.tiny) * 2 + pad * 2 + 6 * s
    local x = sw * 0.5 - w * 0.5
    local y = 70 * s

    draw.rect(x, y, x + w, y + h, 10, 10, 16, 160, 6 * s)
    text.draw(font.title, x + (w - cw) * 0.5, y + pad, 245, 245, 250, 255, clock)

    local ty = y + pad + text.height(font.title) + 2 * s
    local lw = text.width(font.tiny, left)
    text.draw(font.tiny, x + (w - lw) * 0.5, ty, ar, ag, ab, 255, left)
    local bw = text.width(font.tiny, best)
    text.draw(font.tiny, x + (w - bw) * 0.5, ty + text.height(font.tiny) + 2 * s, 170, 170, 180, 230, best)

    local bar_w = w - pad * 2
    local frac = (total - remaining) / total
    draw.rect(x + pad, y + h - 4 * s, x + pad + bar_w, y + h - 2 * s, 0, 0, 0, 140, 0)
    draw.rect(x + pad, y + h - 4 * s, x + pad + bar_w * frac, y + h - 2 * s, ar, ag, ab, 255, 0)
end)
