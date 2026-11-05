-- Pocket Yahtzee. Published fields: active (bool), state (1 playing, 2 game over), focus (0 dice, 1 scorecard),
-- die_cursor (0-4), cat_cursor (0-12), rolls_left (0-3; 3 means not rolled yet this turn), round (categories filled),
-- upper (upper section sum, 35 bonus at 63), total, best, games, bonus_yahtzees (extra Yahtzees, 100 each), roll_age
-- (ms since the last roll), dice (blob, 5 chars "1"-"6", "0" before the first roll), held (blob, 5 chars "1" held),
-- card (blob "taken,score;" per category in order: ones..sixes, three of a kind, four of a kind, full house, small
-- straight, large straight, yahtzee, chance; score is the locked value when taken, else what the dice would score now).
local names = { "Ones", "Twos", "Threes", "Fours", "Fives", "Sixes", "Three of a Kind", "Four of a Kind",
    "Full House", "Small Straight", "Large Straight", "Yahtzee", "Chance" }
local pips = {
    { { 0, 0 } }, { { -1, -1 }, { 1, 1 } }, { { -1, -1 }, { 0, 0 }, { 1, 1 } },
    { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }, { { -1, -1 }, { 1, -1 }, { 0, 0 }, { -1, 1 }, { 1, 1 } },
    { { -1, -1 }, { 1, -1 }, { -1, 0 }, { 1, 0 }, { -1, 1 }, { 1, 1 } },
}

local function die(cx, cy, size, v, held, s, shake)
    local h = size / 2
    cx = cx + shake
    if held then draw.rect(cx - h - 4 * s, cy - h - 4 * s, cx + h + 4 * s, cy + h + 4 * s, 255, 210, 70, 255, 10 * s) end
    draw.rect(cx - h, cy - h, cx + h, cy + h, 245, 245, 240, 255, 8 * s)
    local p = pips[v]
    if not p then
        text.draw(font.hud, cx - text.width(font.hud, "?") / 2, cy - text.height(font.hud) / 2, 150, 150, 160, 255, "?")
        return
    end
    for _, d in ipairs(p) do draw.circle(cx + d[1] * size * 0.27, cy + d[2] * size * 0.27, size * 0.09, 25, 25, 30, 255) end
end

features.on_draw("Pocket Yahtzee", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local pw, ph = 760 * s, 520 * s
    local x0, y0 = sw / 2 - pw / 2, sh / 2 - ph / 2
    draw.rect(x0, y0, x0 + pw, y0 + ph, 14, 40, 26, 235, 12 * s)
    text.draw(font.hud, x0 + 22 * s, y0 + 16 * s, 245, 245, 250, 255, "YAHTZEE")
    local state = math.floor(f.state or 0)
    local focus = math.floor(f.focus or 0)
    local rolls = math.floor(f.rolls_left or 3)

    local dice, held = f.dice or "00000", f.held or "00000"
    local size = 64 * s
    local dx0, dy = x0 + 40 * s + size / 2, y0 + 120 * s
    local age = f.roll_age or 99999
    for i = 0, 4 do
        local v = tonumber(dice:sub(i + 1, i + 1)) or 0
        local hd = held:sub(i + 1, i + 1) == "1"
        local shake = 0
        if age < 300 and not hd then shake = math.sin(t * 60 + i) * 4 * s end
        local cx = dx0 + i * (size + 16 * s)
        die(cx, dy, size, v, hd, s, shake)
        if focus == 0 and state == 1 and math.floor(f.die_cursor or 0) == i then
            draw.rect(cx - size / 2, dy + size / 2 + 10 * s, cx + size / 2, dy + size / 2 + 14 * s, 255, 255, 255, 230, 2 * s)
        end
        if hd then text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, "HELD") / 2, dy - size / 2 - 22 * s, 255, 210, 70, 255, "HELD") end
    end
    local rl = rolls == 3 and "PRESS E TO ROLL" or string.format("ROLLS LEFT %d", rolls)
    text.draw(font.hud_small, x0 + 40 * s, dy + size / 2 + 30 * s, 220, 230, 220, 255, rl)

    local total = math.floor(f.total or 0)
    text.draw(font.display, x0 + 40 * s, y0 + 300 * s, 245, 245, 250, 255, tostring(total))
    text.draw(font.hud_small, x0 + 40 * s, y0 + 300 * s + text.height(font.display) + 4 * s, 180, 200, 185, 255,
        string.format("UPPER %d/63   ROUND %d/13", math.floor(f.upper or 0), math.min(13, math.floor(f.round or 0) + (state == 1 and 1 or 0))))
    local rec = string.format("BEST %d   GAMES %d", math.floor(f.best or 0), math.floor(f.games or 0))
    if (f.bonus_yahtzees or 0) > 0 then rec = rec .. string.format("   BONUS x%d", math.floor(f.bonus_yahtzees)) end
    text.draw(font.hud_small, x0 + 40 * s, y0 + 300 * s + text.height(font.display) + 26 * s, 160, 180, 165, 255, rec)

    local cx0, cy0 = x0 + 430 * s, y0 + 56 * s
    local rh = 30 * s
    local i = 0
    for taken, score in string.gmatch(f.card or "", "(%d),(%-?%d+);") do
        local y = cy0 + i * rh + (i >= 6 and 10 * s or 0)
        local sel = focus == 1 and state == 1 and math.floor(f.cat_cursor or 0) == i
        if sel then draw.rect(cx0 - 8 * s, y - 3 * s, cx0 + 310 * s, y + rh - 5 * s, 255, 255, 255, 40, 5 * s) end
        local tk = taken == "1"
        local nr, ng, nb = 235, 240, 235
        if tk then nr, ng, nb = 130, 150, 135 end
        text.draw(font.hud_small, cx0, y, nr, ng, nb, 255, names[i + 1])
        local val = tostring(math.floor(tonumber(score) or 0))
        local vr, vg, vb, va = 245, 245, 250, 255
        if not tk then vr, vg, vb, va = 120, 230, 140, rolls < 3 and 200 or 0 end
        text.draw(font.hud_small, cx0 + 300 * s - text.width(font.hud_small, val), y, vr, vg, vb, va, val)
        i = i + 1
    end

    local msg
    if state == 2 then msg = string.format("FINAL SCORE %d   E TO PLAY AGAIN", total)
    elseif focus == 0 then msg = "A / D PICK DIE   W HOLD   E ROLL   S SCORECARD"
    else msg = "W / S PICK A BOX   E SCORE IT   Q BACK TO DICE" end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y0 + ph - 34 * s, 220, 230, 220, 255, msg)
end)
