-- Pocket Mastermind. Published fields: active (bool), state (1 playing, 2 cracked it, 3 out of guesses), used (guesses
-- made), tries (10), cursor (0-3 slot being edited), guess (blob, 4 chars "0"-"5" colour or "-" empty), rows (blob
-- "cccc,exact,near;" per submitted guess), secret (blob, 4 chars, only once the round is over), wins, played, streak,
-- best (fewest guesses, absent until the first win), score, flash_age (ms since an incomplete guess was submitted).
local colors = {
    { 235, 70, 70 }, { 245, 160, 50 }, { 245, 225, 70 },
    { 90, 210, 100 }, { 80, 150, 255 }, { 190, 100, 240 },
}

local function peg(x, y, r, c)
    local col = colors[c + 1]
    if col then
        draw.circle(x, y, r, col[1], col[2], col[3], 255)
        draw.circle(x - r * 0.3, y - r * 0.3, r * 0.3, 255, 255, 255, 90)
    else
        draw.circle(x, y, r, 30, 30, 38, 255)
        draw.circle_outline(x, y, r, 70, 70, 82, 255, 1.5)
    end
end

local function code_digit(str, i)
    local ch = str:sub(i, i)
    if ch == "-" or ch == "" then return -1 end
    return tonumber(ch)
end

features.on_draw("Pocket Mastermind", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local tries = math.floor(f.tries or 10)
    local rh = 46 * s
    local pw = 380 * s
    local ph = (tries + 2) * rh + 70 * s
    local x0, y0 = sw / 2 - pw / 2, sh / 2 - ph / 2
    draw.rect(x0, y0, x0 + pw, y0 + ph, 14, 14, 20, 230, 12 * s)
    text.draw(font.hud, x0 + 18 * s, y0 + 14 * s, 245, 245, 250, 255, "MASTERMIND")
    local stats = string.format("WINS %d/%d   STREAK %d", math.floor(f.wins or 0), math.floor(f.played or 0), math.floor(f.streak or 0))
    if f.best then stats = stats .. string.format("   BEST %d", math.floor(f.best)) end
    text.draw(font.hud_small, x0 + pw - 18 * s - text.width(font.hud_small, stats), y0 + 18 * s, 190, 190, 200, 255, stats)

    local pr = 14 * s
    local pegx = function(i) return x0 + 70 * s + i * 44 * s end
    local top = y0 + 56 * s

    local secret = f.secret
    local sy = top + rh / 2
    draw.rect(x0 + 50 * s, top + 4 * s, x0 + 50 * s + 4 * 44 * s, top + rh - 4 * s, 24, 24, 32, 255, 8 * s)
    for i = 0, 3 do
        if secret then peg(pegx(i), sy, pr, code_digit(secret, i + 1))
        else text.draw(font.hud, pegx(i) - text.width(font.hud, "?") / 2, sy - text.height(font.hud) / 2, 150, 150, 165, 255, "?") end
    end

    local rows = {}
    for code, ex, nr in string.gmatch(f.rows or "", "(%d%d%d%d),(%d),(%d);") do
        rows[#rows + 1] = { code, tonumber(ex), tonumber(nr) }
    end
    local state = math.floor(f.state or 0)
    local used = #rows
    for r = 0, tries - 1 do
        local ry = top + (r + 1) * rh + 8 * s
        local cy = ry + rh / 2
        text.draw(font.hud_small, x0 + 18 * s, cy - text.height(font.hud_small) / 2, 110, 110, 125, 255, tostring(r + 1))
        local row = rows[r + 1]
        local current = state == 1 and r == used
        if current then
            draw.rect(x0 + 10 * s, ry + 2 * s, x0 + pw - 10 * s, ry + rh - 2 * s, 40, 40, 54, 255, 8 * s)
        end
        for i = 0, 3 do
            local c = -1
            if row then c = code_digit(row[1], i + 1)
            elseif current then c = code_digit(f.guess or "----", i + 1) end
            peg(pegx(i), cy, pr * (row and 0.85 or 1), c)
            if current and i == math.floor(f.cursor or 0) then
                local pulse = 0.6 + 0.4 * math.sin(t * 8)
                draw.circle_outline(pegx(i), cy, pr + 4 * s, 255, 255, 255, math.floor(255 * pulse), 2 * s)
            end
        end
        if row then
            local fx = x0 + pw - 70 * s
            local k = 0
            for _ = 1, row[2] do
                draw.circle(fx + (k % 2) * 14 * s, cy - 7 * s + math.floor(k / 2) * 14 * s, 5 * s, 20, 20, 20, 255)
                draw.circle_outline(fx + (k % 2) * 14 * s, cy - 7 * s + math.floor(k / 2) * 14 * s, 5 * s, 200, 200, 210, 255, 1.2)
                k = k + 1
            end
            for _ = 1, row[3] do
                draw.circle(fx + (k % 2) * 14 * s, cy - 7 * s + math.floor(k / 2) * 14 * s, 5 * s, 240, 240, 245, 255)
                k = k + 1
            end
            for _ = k, 3 do
                draw.circle_outline(fx + (k % 2) * 14 * s, cy - 7 * s + math.floor(k / 2) * 14 * s, 4 * s, 70, 70, 82, 255, 1.2)
                k = k + 1
            end
        end
    end

    local fy = top + (tries + 1) * rh + 18 * s
    local msg, cr, cg, cb = "W / S COLOUR   A / D SLOT   E GUESS", 200, 200, 212
    if state == 2 then msg, cr, cg, cb = string.format("CRACKED IN %d   E TO PLAY AGAIN", used), 120, 240, 120
    elseif state == 3 then msg, cr, cg, cb = "OUT OF GUESSES   E TO PLAY AGAIN", 255, 100, 100
    elseif (f.flash_age or 99999) < 900 then msg, cr, cg, cb = "FILL ALL FOUR SLOTS FIRST", 255, 180, 80 end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, fy, cr, cg, cb, 255, msg)
end)
