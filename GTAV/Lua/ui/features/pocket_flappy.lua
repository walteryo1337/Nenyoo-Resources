-- Pocket Flappy. Published fields: active (bool), state (1 ready, 2 playing, 3 crashed), state_age (ms), by (bird
-- height, 0 at the bottom of the view), vy (vertical speed, positive rising), score (pipes passed), best, flap_age (ms
-- since the last flap), scroll (distance travelled, for the scrolling backdrop), view_h (view height in the same units
-- as the 1-wide field), pipes (blob "x,gap_y,gap_h;" with x the pipe centre across the field).
features.on_draw("Pocket Flappy", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local vh = f.view_h or 1.5
    local fh = 760 * s
    local fw = fh / vh
    local x0, y0 = sw / 2 - fw / 2, sh / 2 - fh / 2 + 10 * s
    local scroll = f.scroll or 0
    local function P(x, y) return x0 + x * fw, y0 + fh - y * fw end

    draw.rect(x0 - 12 * s, y0 - 56 * s, x0 + fw + 12 * s, y0 + fh + 44 * s, 12, 12, 18, 235, 10 * s)
    draw.rect_gradient(x0, y0, x0 + fw, y0 + fh, 70, 170, 230, 255, 70, 170, 230, 255, 170, 225, 245, 255, 170, 225, 245, 255)

    for i = 0, 5 do
        local cx = ((i * 0.37 - scroll * 0.1) % 1.3) - 0.15
        local px, py = P(cx, vh * (0.75 + 0.05 * (i % 3)))
        draw.circle(px, py, 24 * s, 255, 255, 255, 200)
        draw.circle(px + 22 * s, py + 6 * s, 18 * s, 255, 255, 255, 200)
        draw.circle(px - 20 * s, py + 8 * s, 16 * s, 255, 255, 255, 200)
    end
    for i = 0, 9 do
        local bx = ((i * 0.13 - scroll * 0.3) % 1.3) - 0.15
        local bh = 0.18 + 0.12 * ((i * 7) % 5) / 5
        local lx, ly = P(bx, 0.08 + bh)
        local rx, ry = P(bx + 0.11, 0.08)
        draw.rect(lx, ly, rx, ry, 120, 160, 190, 255, 0)
    end

    for x, gy, gh in string.gmatch(f.pipes or "", "([%-%d%.]+),([%d%.]+),([%d%.]+);") do
        x, gy, gh = tonumber(x), tonumber(gy), tonumber(gh)
        local hw = 0.07
        local lx, _ = P(x - hw, 0)
        local rx, _ = P(x + hw, 0)
        local _, top_y = P(0, gy + gh / 2)
        local _, bot_y = P(0, gy - gh / 2)
        local _, ground_y = P(0, 0.08)
        draw.rect(lx, y0, rx, top_y, 90, 190, 70, 255, 0)
        draw.rect(lx - 5 * s, top_y - 22 * s, rx + 5 * s, top_y, 110, 215, 90, 255, 3 * s)
        draw.rect(lx, bot_y, rx, ground_y, 90, 190, 70, 255, 0)
        draw.rect(lx - 5 * s, bot_y, rx + 5 * s, bot_y + 22 * s, 110, 215, 90, 255, 3 * s)
        draw.rect(lx + 6 * s, y0, lx + 12 * s, top_y - 22 * s, 160, 240, 140, 200, 0)
        draw.rect(lx + 6 * s, bot_y + 22 * s, lx + 12 * s, ground_y, 160, 240, 140, 200, 0)
    end

    local gl, gt = P(0, 0.08)
    draw.rect(x0, gt, x0 + fw, y0 + fh, 220, 200, 120, 255, 0)
    draw.rect(x0, gt, x0 + fw, gt + 8 * s, 120, 200, 80, 255, 0)
    for i = 0, 12 do
        local sx = x0 + ((i * 0.1 - scroll) % 1.2) * fw
        if sx > x0 and sx < x0 + fw - 10 * s then draw.line(sx, gt + 8 * s, sx + 10 * s, y0 + fh, 200, 180, 100, 255, 2 * s) end
    end

    local bx, by = P(0.3, f.by or 0.8)
    local r = 0.03 * fw
    local tilt = math.max(-1, math.min(1, (f.vy or 0) / 1.2))
    local flap = (f.flap_age or 99999) < 150
    draw.circle(bx, by, r + 2 * s, 60, 40, 20, 255)
    draw.circle(bx, by, r, 255, 210, 60, 255)
    local wy = flap and -r * 0.6 or r * 0.2
    draw.circle(bx - r * 0.4, by + wy, r * 0.45, 255, 245, 200, 255)
    draw.circle(bx + r * 0.35, by - r * 0.3 - tilt * r * 0.2, r * 0.28, 255, 255, 255, 255)
    draw.circle(bx + r * 0.45, by - r * 0.3 - tilt * r * 0.2, r * 0.12, 20, 20, 20, 255)
    draw.rect(bx + r * 0.6, by - tilt * r * 0.3, bx + r * 1.25, by + r * 0.25 - tilt * r * 0.3, 255, 130, 40, 255, 3 * s)

    local score = string.format("%d", math.floor(f.score or 0))
    text.draw(font.display, sw / 2 - text.width(font.display, score) / 2, y0 + 20 * s, 255, 255, 255, 255, score)
    text.draw(font.hud_small, x0, y0 - 44 * s, 235, 235, 245, 255, "POCKET FLAPPY")
    local best = string.format("BEST %d", math.floor(f.best or 0))
    text.draw(font.hud_tiny, x0 + fw - text.width(font.hud_tiny, best), y0 - 40 * s, 255, 220, 90, 230, best)

    local state = math.floor(f.state or 0)
    local hint
    if state == 1 then hint = "PRESS W OR SPACE TO FLAP"
    elseif state == 3 then hint = "PRESS E TO TRY AGAIN"
    else hint = "W / SPACE  FLAP" end
    text.draw(font.hud_tiny, sw / 2 - text.width(font.hud_tiny, hint) / 2, y0 + fh + 14 * s, 200, 200, 214, math.floor(170 + 60 * math.sin(t * 3)), hint)
    if state == 3 then
        local sc = math.floor(f.score or 0)
        local medal, mr, mg, mb = nil, 0, 0, 0
        if sc >= 40 then medal, mr, mg, mb = "PLATINUM", 200, 230, 255
        elseif sc >= 20 then medal, mr, mg, mb = "GOLD", 255, 210, 60
        elseif sc >= 10 then medal, mr, mg, mb = "SILVER", 210, 210, 220
        elseif sc >= 5 then medal, mr, mg, mb = "BRONZE", 210, 140, 70 end
        local cy = y0 + fh * 0.35
        draw.rect(x0 + fw * 0.12, cy, x0 + fw * 0.88, cy + 150 * s, 250, 240, 210, 245, 10 * s)
        local msg = "GAME OVER"
        text.draw(font.display, sw / 2 - text.width(font.display, msg) / 2, cy + 12 * s, 220, 90, 60, 255, msg)
        local line = string.format("SCORE %d   BEST %d", sc, math.floor(f.best or 0))
        text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, line) / 2, cy + 70 * s, 80, 70, 60, 255, line)
        if medal then
            draw.circle(sw / 2, cy + 120 * s, 14 * s, mr, mg, mb, 255)
            text.draw(font.hud_tiny, sw / 2 + 22 * s, cy + 110 * s, 80, 70, 60, 255, medal)
        end
    end
end)
