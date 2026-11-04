-- Pocket Pool. Published fields: active (bool), state (1 aiming, 2 balls rolling, 3 table cleared), angle (radians, 0 =
-- toward the right cushion, positive turns down the table), power (0-1), guide_x / guide_y (0-1 table coordinates where
-- the cue ball would first touch something, aiming only), guide_ball (id of the ball it would hit, absent for a cushion),
-- shots (strokes plus scratch penalties), left (object balls on the table), best (fewest shots to clear, after one
-- clear), racks, event (1 potted, 2 scratch, 3 nothing went down) + event_age (ms), balls (blob "id,x,y;" per ball on
-- the table, 0 = cue ball, 8 = black, 9-15 striped; x / y 0-1 across the 2:1 table).
local colors = {
    [1] = { 245, 200, 40 }, [2] = { 40, 80, 200 }, [3] = { 210, 40, 40 }, [4] = { 110, 40, 150 },
    [5] = { 240, 120, 30 }, [6] = { 30, 140, 70 }, [7] = { 130, 30, 30 }, [8] = { 20, 20, 24 },
}
local events = { { "POTTED!", 120, 240, 140 }, { "SCRATCH  +2", 255, 100, 100 }, { "NO BALL", 200, 200, 212 } }
local BALL_R = 0.028

features.on_draw("Pocket Pool", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local tw = 800 * s
    local th = tw / 2
    local rail = 34 * s
    local x0, y0 = sw / 2 - tw / 2, sh / 2 - th / 2 + 10 * s
    local br = BALL_R / 2 * tw
    draw.rect(x0 - rail, y0 - rail - 44 * s, x0 + tw + rail, y0 + th + rail + 54 * s, 12, 12, 16, 230, 12 * s)
    draw.rect(x0 - rail, y0 - rail, x0 + tw + rail, y0 + th + rail, 95, 55, 30, 255, 14 * s)
    draw.rect(x0, y0, x0 + tw, y0 + th, 25, 110, 60, 255, 0)
    draw.line(x0 + tw * 0.25, y0, x0 + tw * 0.25, y0 + th, 255, 255, 255, 40, 1.5 * s)
    for _, p in ipairs({ { 0, 0 }, { 0.5, 0 }, { 1, 0 }, { 0, 1 }, { 0.5, 1 }, { 1, 1 } }) do
        draw.circle(x0 + p[1] * tw, y0 + p[2] * th, br * 2.0, 8, 8, 10, 255)
    end

    local cue_x, cue_y
    for id, bx, by in string.gmatch(f.balls or "", "(%d+),([%d%.%-]+),([%d%.%-]+);") do
        id = tonumber(id)
        local px, py = x0 + tonumber(bx) * tw, y0 + tonumber(by) * th
        draw.circle(px + 2 * s, py + 2 * s, br, 0, 0, 0, 90)
        if id == 0 then
            cue_x, cue_y = px, py
            draw.circle(px, py, br, 245, 245, 240, 255)
        else
            local c = colors[id > 8 and id - 8 or id]
            if id > 8 then
                draw.circle(px, py, br, 245, 245, 240, 255)
                draw.rect(px - br, py - br * 0.55, px + br, py + br * 0.55, c[1], c[2], c[3], 255, br * 0.4)
            else
                draw.circle(px, py, br, c[1], c[2], c[3], 255)
            end
            draw.circle(px, py, br * 0.42, 250, 250, 250, 255)
            local label = tostring(id)
            text.draw(font.tiny, px - text.width(font.tiny, label) / 2, py - text.height(font.tiny) / 2, 20, 20, 24, 255, label)
        end
        draw.circle(px - br * 0.35, py - br * 0.35, br * 0.25, 255, 255, 255, 70)
    end

    local state = math.floor(f.state or 0)
    if state == 1 and cue_x then
        local a = f.angle or 0
        local ca, sa = math.cos(a), math.sin(a)
        if f.guide_x then
            local gx, gy = x0 + f.guide_x * tw, y0 + f.guide_y * th
            draw.line(cue_x, cue_y, gx, gy, 255, 255, 255, 120, 1.5 * s)
            draw.circle_outline(gx, gy, br, 255, 255, 255, 170, 1.5 * s)
        end
        local pull = (f.power or 0.5) * 60 * s
        local sx1, sy1 = cue_x - ca * (br + 6 * s + pull), cue_y - sa * (br + 6 * s + pull)
        local sx2, sy2 = sx1 - ca * 300 * s, sy1 - sa * 300 * s
        draw.line(sx1, sy1, sx2, sy2, 200, 160, 100, 255, 6 * s)
        draw.line(sx1, sy1, sx1 - ca * 12 * s, sy1 - sa * 12 * s, 90, 140, 220, 255, 6 * s)
    end

    local hud = string.format("SHOTS %d   LEFT %d", math.floor(f.shots or 0), math.floor(f.left or 15))
    if f.best then hud = hud .. string.format("   BEST %d", math.floor(f.best)) end
    text.draw(font.item, x0 - rail + 14 * s, y0 - rail - 38 * s, 245, 245, 250, 255, hud)
    local pw = 160 * s
    local bx2 = x0 + tw + rail - 14 * s
    local by1 = y0 - rail - 30 * s
    draw.rect(bx2 - pw, by1, bx2, by1 + 12 * s, 40, 40, 48, 255, 6 * s)
    draw.rect(bx2 - pw, by1, bx2 - pw + pw * (f.power or 0), by1 + 12 * s, 255, 170, 60, 255, 6 * s)

    local ev = events[math.floor(f.event or 0)]
    if ev and (f.event_age or 99999) < 1200 then
        local w = text.width(font.title, ev[1])
        text.draw(font.title, sw / 2 - w / 2, y0 + th / 2 - text.height(font.title) / 2, ev[2], ev[3], ev[4], 230, ev[1])
    end

    local msg
    if state == 3 then msg = string.format("TABLE CLEARED IN %d   E TO RACK AGAIN", math.floor(f.shots or 0))
    elseif state == 2 then msg = "..."
    else msg = "A / D AIM   W / S POWER   E SHOOT   Q RE-RACK" end
    text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, y0 + th + rail + 16 * s, 220, 220, 232, 255, msg)
end)
