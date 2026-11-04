-- Pocket Pinball. Published fields: active (bool), state (1 plunger, 2 ball in play, 3 drained, 4 game over), state_age
-- (ms), table_h (table is 1 wide and table_h tall, y down), bx / by / ball_r (ball), left_angle / right_angle (flipper
-- angles in radians, 0 points right, y down), flip_len, left_px / right_px / pivot_y (flipper pivots), charge (plunger
-- 0-1), lit (bitmask of the three top rollovers), multiplier, bumper1_age..bumper3_age / sling1_age / sling2_age (ms
-- since last hit), balls (left, including the one in play), score, best, segments (blob "x1,y1,x2,y2,kind;" kind 0
-- wall, 1 left slingshot, 2 right slingshot).
local BUMPERS = { { 0.35, 0.35 }, { 0.62, 0.35 }, { 0.48, 0.56 } }
local LANES = { 0.35, 0.5, 0.65 }

features.on_draw("Pocket Pinball", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local th = f.table_h or 1.7
    local tw = 470 * s
    local x0, y0 = sw / 2 - tw / 2, sh / 2 - tw * th / 2 + 18 * s
    local state = math.floor(f.state or 0)
    local ar, ag, ab = theme.accent()
    local function P(x, y) return x0 + x * tw, y0 + y * tw end

    draw.rect(x0 - 16 * s, y0 - 62 * s, x0 + tw + 16 * s, y0 + tw * th + 44 * s, 12, 10, 22, 240, 12 * s)
    draw.rect_gradient(x0, y0, x0 + tw, y0 + tw * th, 24, 34, 80, 255, 24, 34, 80, 255, 60, 14, 50, 255, 60, 14, 50, 255)
    for k = 1, 12 do
        local px, py = P(0.46, 0.75 + k * 0.035)
        draw.circle(px + 0.04 * tw, py, 2 * s, 255, 255, 255, 18)
    end

    local lit = math.floor(f.lit or 0)
    for i, lx in ipairs(LANES) do
        local px, py = P(lx, 0.10)
        local on = math.floor(lit / 2 ^ (i - 1)) % 2 == 1
        if on then draw.circle(px, py, 13 * s, ar, ag, ab, 70) end
        draw.circle(px, py, 7 * s, on and ar or 70, on and ag or 70, on and ab or 90, 255)
        draw.circle_outline(px, py, 7 * s, 200, 200, 220, 200, 1.5 * s)
    end

    for i, b in ipairs(BUMPERS) do
        local age = f["bumper" .. i .. "_age"] or 99999
        local flash = age < 150 and (1 - age / 150) or 0
        local px, py = P(b[1], b[2])
        local r = 0.055 * tw
        draw.circle(px, py, r * (1 + flash * 0.15), 255, 80 + math.floor(flash * 175), 90, 255)
        draw.circle(px, py, r * 0.62, 255, 230, 120, 255)
        draw.circle(px, py, r * 0.3, 255, 255, 255, 220)
        draw.circle_outline(px, py, r, 255, 255, 255, 180, 2 * s)
    end

    for x1, y1, x2, y2, kind in string.gmatch(f.segments or "", "([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),(%d+);") do
        kind = tonumber(kind)
        local ax, ay = P(tonumber(x1), tonumber(y1))
        local bx, by = P(tonumber(x2), tonumber(y2))
        if kind == 0 then
            draw.line(ax, ay, bx, by, 190, 200, 230, 255, 4 * s)
        else
            local age = f["sling" .. kind .. "_age"] or 99999
            local flash = age < 150 and (1 - age / 150) or 0
            draw.line(ax, ay, bx, by, 255, 120 + math.floor(flash * 135), 60, 255, (5 + flash * 3) * s)
        end
    end

    local mult = string.format("x%d", math.floor(f.multiplier or 1))
    local mx, my = P(0.46, 0.85)
    text.draw(font.title, mx - text.width(font.title, mult) / 2, my, ar, ag, ab, 200, mult)

    local fl = (f.flip_len or 0.16) * tw
    local py = f.pivot_y or 1.52
    for side = 0, 1 do
        local px = side == 0 and (f.left_px or 0.30) or (f.right_px or 0.70)
        local ang = side == 0 and (f.left_angle or 0.52) or (f.right_angle or 2.62)
        local ax, ay = P(px, py)
        local bx, by = ax + math.cos(ang) * fl, ay + math.sin(ang) * fl
        draw.line(ax, ay, bx, by, 240, 240, 250, 255, 0.036 * tw)
        draw.circle(ax, ay, 0.018 * tw, 240, 240, 250, 255)
        draw.circle(bx, by, 0.018 * tw, 240, 240, 250, 255)
        draw.circle(ax, ay, 0.008 * tw, ar, ag, ab, 255)
    end

    local lx1, ly1 = P(0.92, 1.64)
    local lx2 = P(1.0, 1.64)
    local ch = f.charge or 0
    draw.rect(lx1 + 3 * s, ly1, lx2 - 3 * s, ly1 + (0.04 + ch * 0.05) * tw, 180, 180, 200, 255, 2 * s)
    if state == 1 then
        draw.rect(lx2 + 6 * s, ly1 - 90 * s, lx2 + 12 * s, ly1, 40, 40, 60, 255, 3 * s)
        draw.rect(lx2 + 6 * s, ly1 - 90 * s * ch, lx2 + 12 * s, ly1, 255, 200 - math.floor(ch * 150), 60, 255, 3 * s)
    end

    if state == 1 or state == 2 then
        local bx, by = P(f.bx or 0.96, f.by or 1.62)
        local r = (f.ball_r or 0.02) * tw
        draw.circle(bx + 2 * s, by + 3 * s, r, 0, 0, 0, 90)
        draw.circle(bx, by, r, 200, 205, 215, 255)
        draw.circle(bx - r * 0.3, by - r * 0.3, r * 0.4, 255, 255, 255, 230)
    end

    local hy = y0 - 50 * s
    text.draw(font.item, x0, hy - 4 * s, 245, 245, 250, 255, string.format("SCORE %d", math.floor(f.score or 0)))
    local best = string.format("BEST %d", math.floor(f.best or 0))
    text.draw(font.small, x0 + tw - text.width(font.small, best), hy, 255, 200, 60, 255, best)
    for k = 1, math.floor(f.balls or 0) do
        draw.circle(x0 + tw / 2 + (k - 2) * 18 * s, hy + 10 * s, 6 * s, 200, 205, 215, 255)
    end

    local msg, mr, mg, mb = "A / D FLIPPERS   HOLD S TO PULL THE PLUNGER, RELEASE TO LAUNCH", 225, 225, 240
    if state == 2 then msg = "A / D FLIPPERS   LIGHT ALL THREE TOP LANES TO RAISE THE MULTIPLIER"
    elseif state == 3 then msg, mr, mg, mb = "BALL LOST", 255, 120, 100
    elseif state == 4 then
        local blink = math.floor(t * 2) % 2 == 0 and 255 or 160
        msg, mr, mg, mb = string.format("GAME OVER   SCORE %d   E TO PLAY AGAIN", math.floor(f.score or 0)), 255, blink, 100
    end
    text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, y0 + tw * th + 12 * s, mr, mg, mb, 255, msg)
end)
