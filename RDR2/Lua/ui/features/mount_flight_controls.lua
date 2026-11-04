features.on_draw("Mount Flight Controls", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    if not sw or not sh or sw < 64 or sh < 64 then return end
    local lines = {f.title, f.move, f.look, f.up, f.boost, f.exit}
    local width = 340
    for _, line in ipairs(lines) do width = math.max(width, text.width(font.small, line or "") + 28) end
    width = math.min(width, sw - 32)
    local x, y = 24, math.max(16, sh - 430)
    draw.rect(x, y, width, 176, 12, 12, 18, 210)
    draw.rect(x, y, 3, 176, 185, 65, 255, 240)
    for i, line in ipairs(lines) do
        text.draw(font.small, x + 14, y + 12 + (i - 1) * 25, 245, 245, 250, 245, line or "")
    end
end)
