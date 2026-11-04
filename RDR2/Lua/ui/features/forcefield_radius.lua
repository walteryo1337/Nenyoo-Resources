features.on_draw("Forcefield Radius", function(f)
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    if not sw or not sh or sw < 1 or sh < 1 then return end
    local count = math.min(144, math.max(0, tonumber(f.count) or 0))
    for i = 0, count - 1 do
        local prefix = "p" .. i .. "_"
        local ax, ay, bx, by = f[prefix .. "0"], f[prefix .. "1"], f[prefix .. "2"], f[prefix .. "3"]
        if type(ax) == "number" and type(ay) == "number" and type(bx) == "number" and type(by) == "number" then
            draw.line(ax * sw, ay * sh, bx * sw, by * sh, 190, 80, 255, 170, 1.5)
        end
    end
end)
