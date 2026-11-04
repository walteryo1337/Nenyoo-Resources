features.on_draw("Teleport Preview", function(f)
    if type(f.x) ~= "number" or type(f.y) ~= "number" then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    if not sw or not sh or sw < 1 or sh < 1 then return end
    local x, y = f.x * sw, f.y * sh
    local r, g, b, a = 190, 80, 255, 235
    if f.on_screen and f.corners_visible then
        for i = 0, 3 do
            local j = (i + 1) % 4
            local ax, ay = f["corner_x" .. i], f["corner_y" .. i]
            local bx, by = f["corner_x" .. j], f["corner_y" .. j]
            if type(ax) == "number" and type(ay) == "number" and type(bx) == "number" and type(by) == "number" then
                draw.line(ax * sw, ay * sh, bx * sw, by * sh, r, g, b, a, 2)
            end
        end
    end
    if f.on_screen and f.top_visible then
        draw.line(x, y, f.top_x * sw, f.top_y * sh, r, g, b, 150, 2)
    end
    draw.circle_outline(x, y, 10, r, g, b, a, 2)
    draw.line(x - 15, y, x - 5, y, r, g, b, a, 2)
    draw.line(x + 5, y, x + 15, y, r, g, b, a, 2)
    draw.line(x, y - 15, x, y - 5, r, g, b, a, 2)
    draw.line(x, y + 5, x, y + 15, r, g, b, a, 2)
    local label = tostring(f.label or "") .. string.format("  %.1fm", f.distance or 0)
    if not f.on_screen then label = label .. "  (" .. tostring(f.offscreen_label or "") .. ")" end
    local width = text.width(font.small, label)
    text.draw(font.small, math.max(8, math.min(sw - width - 8, x - width * 0.5)), y + 18, 255, 255, 255, 240, label)
end)
