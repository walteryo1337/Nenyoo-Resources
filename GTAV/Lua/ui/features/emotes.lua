-- Emotes. The dance wheel and its messages. Published fields: open (bool, the wheel is showing); slots (slice count,
-- slot 0 at the top, then clockwise); selected (highlighted slot, missing when the pointer is centred); name0..nameN
-- (slice labels); hint (help line); dancing (slot of the dance playing, missing when not dancing); toast (message).
features.on_draw("Emotes", function(f)
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx, cy = sw / 2, sh / 2

    if f.toast then
        local w = text.width(font.item, f.toast)
        local y = sh * 0.12
        draw.rect(cx - w / 2 - 18 * s, y - 10 * s, cx + w / 2 + 18 * s, y + text.height(font.item) + 10 * s, 0, 0, 0, 180, 6 * s)
        text.draw(font.item, cx - w / 2, y, 255, 220, 120, 250, f.toast)
    end

    if not f.open then return end
    local n = math.max(1, math.floor(f.slots or 5))
    local sel = f.selected and math.floor(f.selected) or -1
    local playing = f.dancing and math.floor(f.dancing) or -1
    local outer, inner = 230 * s, 92 * s
    local mid = (outer + inner) / 2
    local step = 2 * math.pi / n
    local t = ctx.time() or 0

    draw.circle(cx, cy, outer, 8, 10, 22, 175)
    draw.circle_outline(cx, cy, outer, 120, 90, 255, 200, 2.5 * s)

    if sel >= 0 then
        local a = -math.pi / 2 + sel * step
        local hx, hy = cx + math.cos(a) * mid, cy + math.sin(a) * mid
        draw.circle(hx, hy, 72 * s, 120, 90, 255, 120)
        draw.circle_outline(hx, hy, 72 * s, 200, 170, 255, 240, 2 * s)
    end

    for i = 0, n - 1 do
        local a = -math.pi / 2 + (i + 0.5) * step
        draw.line(cx + math.cos(a) * inner, cy + math.sin(a) * inner, cx + math.cos(a) * outer, cy + math.sin(a) * outer,
            120, 90, 255, 110, 1.5 * s)

        local la = -math.pi / 2 + i * step
        local lx, ly = cx + math.cos(la) * mid, cy + math.sin(la) * mid
        local label = f["name" .. i] or ""
        local lit = i == sel
        local c = lit and 255 or 205
        text.draw(font.item, lx - text.width(font.item, label) / 2, ly - text.height(font.item) / 2, c, c, lit and 255 or 215, 250, label)
        if i == playing then
            local pulse = 0.6 + 0.4 * math.abs(math.sin(t * 3))
            draw.circle(lx, ly + text.height(font.item) * 0.5 + 10 * s, 4 * s, 255, 210, 90, math.floor(255 * pulse))
        end
    end

    draw.circle(cx, cy, inner, 14, 16, 32, 235)
    draw.circle_outline(cx, cy, inner, 120, 90, 255, 220, 2 * s)
    local center = sel >= 0 and (f["name" .. sel] or "") or "Emotes"
    text.draw(font.item, cx - text.width(font.item, center) / 2, cy - text.height(font.item) / 2, 255, 255, 255, 255, center)

    if f.hint then
        local w = text.width(font.small, f.hint)
        text.draw(font.small, cx - w / 2, cy + outer + 16 * s, 220, 220, 230, 230, f.hint)
    end
end)
