-- Pocket Air Hockey. Published fields: active (bool), state (1 playing, 2 goal pause, 3 match over), px / py (puck),
-- mx / my (your mallet, bottom half), ax / ay (the phone's mallet, top half), all 0-1 across a 1 x 1.6 table; you /
-- phone (goals), win_score, scorer (1 you, 2 the phone; last goal), state_age (ms in the current state), hit_age (ms
-- since the puck was last struck), wins, played.
local PUCK_R, PADDLE_R, GOAL_W, TW, TH = 0.045, 0.07, 0.36, 1.0, 1.6

features.on_draw("Pocket Air Hockey", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local th = 720 * s
    local tw = th * TW / TH
    local x0, y0 = sw / 2 - tw / 2, sh / 2 - th / 2 + 10 * s
    local rail = 14 * s
    draw.rect(x0 - rail - 110 * s, y0 - rail - 10 * s, x0 + tw + rail + 110 * s, y0 + th + rail + 40 * s, 12, 12, 18, 225, 12 * s)
    draw.rect(x0 - rail, y0 - rail, x0 + tw + rail, y0 + th + rail, 200, 200, 210, 255, 18 * s)
    draw.rect(x0, y0, x0 + tw, y0 + th, 235, 245, 252, 255, 10 * s)
    draw.line(x0, y0 + th / 2, x0 + tw, y0 + th / 2, 220, 60, 60, 200, 3 * s)
    draw.circle_outline(x0 + tw / 2, y0 + th / 2, tw * 0.16, 220, 60, 60, 200, 3 * s)
    local gw = GOAL_W / TW * tw
    draw.rect(x0 + tw / 2 - gw / 2, y0 - rail, x0 + tw / 2 + gw / 2, y0 + 2 * s, 20, 20, 26, 255, 4 * s)
    draw.rect(x0 + tw / 2 - gw / 2, y0 + th - 2 * s, x0 + tw / 2 + gw / 2, y0 + th + rail, 20, 20, 26, 255, 4 * s)
    draw.circle_outline(x0 + tw / 2, y0, gw * 0.6, 80, 120, 220, 160, 2 * s)
    draw.circle_outline(x0 + tw / 2, y0 + th, gw * 0.6, 80, 120, 220, 160, 2 * s)

    local function mallet(nx, ny, r, g, b)
        local x, y = x0 + nx * tw, y0 + ny * th
        local rad = PADDLE_R / TW * tw
        draw.circle(x + 3 * s, y + 4 * s, rad, 0, 0, 0, 70)
        draw.circle(x, y, rad, r, g, b, 255)
        draw.circle(x, y, rad * 0.55, math.min(255, r + 40), math.min(255, g + 40), math.min(255, b + 40), 255)
        draw.circle(x, y, rad * 0.3, r, g, b, 255)
    end
    mallet(f.ax or 0.5, f.ay or 0.1, 230, 70, 70)
    mallet(f.mx or 0.5, f.my or 0.9, 60, 130, 240)
    local state = math.floor(f.state or 0)
    if state ~= 2 then
        local x, y = x0 + (f.px or 0.5) * tw, y0 + (f.py or 0.5) * th
        local rad = PUCK_R / TW * tw
        if (f.hit_age or 99999) < 120 then draw.circle(x, y, rad * 1.5, 255, 230, 120, 120) end
        draw.circle(x + 2 * s, y + 3 * s, rad, 0, 0, 0, 80)
        draw.circle(x, y, rad, 30, 30, 34, 255)
        draw.circle_outline(x, y, rad * 0.7, 70, 70, 80, 255, 2 * s)
    end

    local you, phone = math.floor(f.you or 0), math.floor(f.phone or 0)
    local sx = x0 + tw + rail + 55 * s
    local ys = tostring(phone)
    text.draw(font.title, sx - text.width(font.title, ys) / 2, y0 + th * 0.25, 230, 70, 70, 255, ys)
    text.draw(font.tiny, sx - text.width(font.tiny, "PHONE") / 2, y0 + th * 0.25 - 20 * s, 200, 200, 210, 255, "PHONE")
    local yy = tostring(you)
    text.draw(font.title, sx - text.width(font.title, yy) / 2, y0 + th * 0.7, 60, 130, 240, 255, yy)
    text.draw(font.tiny, sx - text.width(font.tiny, "YOU") / 2, y0 + th * 0.7 - 20 * s, 200, 200, 210, 255, "YOU")
    local rec = string.format("%d/%d", math.floor(f.wins or 0), math.floor(f.played or 0))
    local lx = x0 - rail - 55 * s
    text.draw(font.tiny, lx - text.width(font.tiny, "WINS") / 2, y0 + th / 2 - 30 * s, 200, 200, 210, 255, "WINS")
    text.draw(font.item, lx - text.width(font.item, rec) / 2, y0 + th / 2 - 10 * s, 245, 245, 250, 255, rec)

    local banner, br, bg, bb
    if state == 2 then
        if math.floor(f.scorer or 0) == 1 then banner, br, bg, bb = "GOAL!", 90, 160, 255
        else banner, br, bg, bb = "PHONE SCORES", 255, 100, 100 end
    elseif state == 3 then
        if you > phone then banner, br, bg, bb = "YOU WIN!", 120, 240, 120
        else banner, br, bg, bb = "YOU LOSE", 255, 100, 100 end
    end
    if banner then
        local w = text.width(font.title, banner)
        draw.rect(sw / 2 - w / 2 - 18 * s, y0 + th / 2 - 32 * s, sw / 2 + w / 2 + 18 * s, y0 + th / 2 + 32 * s, 12, 12, 18, 220, 8 * s)
        text.draw(font.title, sw / 2 - w / 2, y0 + th / 2 - text.height(font.title) / 2, br, bg, bb, 255, banner)
    end
    local msg = state == 3 and "E TO PLAY AGAIN" or string.format("W A S D MOVE YOUR MALLET   FIRST TO %d", math.floor(f.win_score or 7))
    text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, y0 + th + rail + 10 * s, 220, 220, 232, 255, msg)
end)
