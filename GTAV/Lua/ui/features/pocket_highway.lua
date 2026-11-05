-- Pocket Highway. Published fields: active (bool), state (1 driving, 2 crashed), x (your lane position, 0 to
-- lanes - 1, fractional while changing lanes), scroll (0 to 1 road scroll phase), speed (road units per second),
-- score, best (this session), lanes, cars (blob "lane,y,colour;" per car; y runs 0 at the top to 1 at the bottom
-- of the road, colour 0 to 5).
local COLOURS = {
    { 70, 130, 230 }, { 245, 200, 60 }, { 90, 200, 120 }, { 235, 235, 240 }, { 160, 90, 210 }, { 240, 140, 50 },
}
local PLAYER_Y = 0.82
local CAR_H = 0.11

local function draw_car(cx, cy, w, h, r, g, b, s)
    draw.rect(cx - w / 2 + 2 * s, cy - h / 2 + 3 * s, cx + w / 2 + 2 * s, cy + h / 2 + 3 * s, 0, 0, 0, 90, 6 * s)
    draw.rect(cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2, r, g, b, 255, 6 * s)
    draw.rect(cx - w * 0.36, cy - h * 0.30, cx + w * 0.36, cy - h * 0.08, 30, 40, 55, 235, 3 * s)
    draw.rect(cx - w * 0.36, cy + h * 0.18, cx + w * 0.36, cy + h * 0.32, 30, 40, 55, 200, 3 * s)
end

features.on_draw("Pocket Highway", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local lanes = math.floor(f.lanes or 4)
    local lane_w = 92 * s
    local rw, rh = lane_w * lanes, 640 * s
    local x0, y0 = sw / 2 - rw / 2, sh / 2 - rh / 2 + 24 * s
    local state = math.floor(f.state or 0)

    draw.rect(x0 - 40 * s, y0 - 96 * s, x0 + rw + 40 * s, y0 + rh + 56 * s, 12, 12, 16, 225, 12 * s)
    draw.rect(x0 - 16 * s, y0, x0, y0 + rh, 70, 140, 70, 255, 0)
    draw.rect(x0 + rw, y0, x0 + rw + 16 * s, y0 + rh, 70, 140, 70, 255, 0)
    draw.rect(x0, y0, x0 + rw, y0 + rh, 52, 54, 60, 255, 0)
    draw.rect(x0, y0, x0 + 3 * s, y0 + rh, 235, 235, 235, 255, 0)
    draw.rect(x0 + rw - 3 * s, y0, x0 + rw, y0 + rh, 235, 235, 235, 255, 0)

    local period = 0.125
    local phase = (f.scroll or 0) % period
    for l = 1, lanes - 1 do
        local lx = x0 + l * lane_w
        local y = -period + phase
        while y < 1 do
            local a, b = math.max(0, y), math.min(1, y + period * 0.5)
            if b > a then draw.rect(lx - 2 * s, y0 + a * rh, lx + 2 * s, y0 + b * rh, 230, 230, 230, 220, 0) end
            y = y + period
        end
    end

    local cw, ch = lane_w * 0.58, CAR_H * rh
    for lane, y, col in string.gmatch(f.cars or "", "(%-?%d+),(%-?[%d%.]+),(%d+);") do
        local cy = y0 + tonumber(y) * rh
        if cy - ch / 2 >= y0 and cy + ch / 2 <= y0 + rh then
            local c = COLOURS[tonumber(col) + 1] or COLOURS[1]
            draw_car(x0 + (tonumber(lane) + 0.5) * lane_w, cy, cw, ch, c[1], c[2], c[3], s)
        end
    end

    local px = x0 + ((f.x or 1) + 0.5) * lane_w
    local py = y0 + PLAYER_Y * rh
    if state == 2 and math.floor((ctx.time() or 0) * 6) % 2 == 0 then
        draw_car(px, py, cw, ch, 255, 255, 255, s)
    else
        draw_car(px, py, cw, ch, 225, 50, 50, s)
    end

    local score = string.format("%d", math.floor(f.score or 0))
    text.draw(font.display, sw / 2 - text.width(font.display, score) / 2, y0 - 86 * s, 245, 245, 250, 255, score)
    local info = string.format("BEST %d     %d KM/H", math.floor(f.best or 0), math.floor((f.speed or 0) * 120))
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, info) / 2, y0 - 36 * s, 200, 200, 214, 230, info)

    local foot = state == 2 and "CRASHED     E TO DRIVE AGAIN" or "A / D CHANGE LANE     W BOOST     S BRAKE"
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, foot) / 2, y0 + rh + 16 * s, 200, 200, 214, 230, foot)
end)
