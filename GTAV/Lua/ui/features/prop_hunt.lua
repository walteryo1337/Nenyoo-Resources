-- Prop Hunt. Published fields: active (bool), state (1 hiding, 2 seekers searching, 3 won, 4 caught), seconds
-- (left in the current phase), suspicion (0..1; at 1 you are found), taunts (times you taunted), moving (bool).
features.on_draw("Prop Hunt", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 1)
    local secs = math.floor(f.seconds or 0)

    local w, h = 340 * s, 78 * s
    local x0, y0 = sw / 2 - w / 2, 40 * s
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 18, 215, 12 * s)
    text.draw(font.hud_small, x0 + 14 * s, y0 + 8 * s, 235, 235, 245, 255, "PROP HUNT")

    local phase, r, g, b
    if state == 1 then phase, r, g, b = string.format("HIDE!  %ds", secs), 140, 210, 255
    elseif state == 2 then phase, r, g, b = string.format("STAY HIDDEN  %d:%02d", math.floor(secs / 60), secs % 60), 255, 225, 120
    elseif state == 3 then phase, r, g, b = "NOBODY FOUND YOU", 130, 255, 160
    else phase, r, g, b = "FOUND!", 255, 110, 110 end
    text.draw(font.hud, x0 + 14 * s, y0 + 30 * s, r, g, b, 255, phase)

    local taunts = math.floor(f.taunts or 0)
    if taunts > 0 then
        local tt = string.format("%d TAUNT%s", taunts, taunts == 1 and "" or "S")
        text.draw(font.hud_tiny, x0 + w - 14 * s - text.width(font.hud_tiny, tt), y0 + 12 * s, 255, 200, 140, 230, tt)
    end

    if state == 2 then
        local sus = math.max(0, math.min(1, f.suspicion or 0))
        local bx, by, bw, bh = x0 + 14 * s, y0 + h - 18 * s, w - 28 * s, 8 * s
        draw.rect(bx, by, bx + bw, by + bh, 40, 40, 52, 255, 4 * s)
        if sus > 0 then
            local a = sus > 0.7 and math.floor(180 + 75 * math.abs(math.sin(t * 8))) or 255
            draw.rect_gradient(bx, by, bx + bw * sus, by + bh, 255, 210, 80, a, 255, 70, 60, a, 255, 70, 60, a, 255, 210, 80, a)
        end
        if f.moving then
            local mv = "MOVING  -  THEY CAN SEE YOU"
            text.draw(font.hud_tiny, sw / 2 - text.width(font.hud_tiny, mv) / 2, y0 + h + 8 * s, 255, 170, 120, math.floor(160 + 80 * math.sin(t * 6)), mv)
        else
            local hint = "KEEP STILL    E  TAUNT"
            text.draw(font.hud_tiny, sw / 2 - text.width(font.hud_tiny, hint) / 2, y0 + h + 8 * s, 200, 200, 214, 200, hint)
        end
    elseif state == 1 then
        local hint = "FIND A SPOT WHERE YOUR DISGUISE FITS IN"
        text.draw(font.hud_tiny, sw / 2 - text.width(font.hud_tiny, hint) / 2, y0 + h + 8 * s, 200, 200, 214, 220, hint)
    end
end)
