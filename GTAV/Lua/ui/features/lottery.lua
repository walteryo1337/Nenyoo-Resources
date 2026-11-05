-- Lottery. Published fields: active (bool), jackpot, count (tickets held for the next draw), minutes_to_draw (in-game
-- minutes until the 8 PM draw), draw_age (seconds since the last draw; present only right after one), last_win (paid by
-- the last draw), price (per ticket), tickets (blob "a,b,c,d,e;" per ticket for the next draw), last_tickets (same,
-- tickets that played in the last draw), drawn (blob "a,b,c,d,e", the last winning numbers).
local function parse_tickets(blob)
    local out = {}
    for t in string.gmatch(blob or "", "([^;]+);") do
        local nums = {}
        for n in string.gmatch(t, "(%d+)") do nums[#nums + 1] = tonumber(n) end
        out[#out + 1] = nums
    end
    return out
end

local function parse_nums(blob)
    local out = {}
    for n in string.gmatch(blob or "", "(%d+)") do out[#out + 1] = tonumber(n) end
    return out
end

local function ball(x, y, r, n, hot, s)
    local br, bg, bb = 235, 235, 242
    if hot then br, bg, bb = 255, 205, 60 end
    draw.circle(x, y, r, br, bg, bb, 255)
    local str = tostring(n)
    text.draw(font.hud_small, x - text.width(font.hud_small, str) / 2, y - text.height(font.hud_small) / 2, 20, 20, 26, 255, str)
end

features.on_draw("Lottery", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()

    if f.draw_age then
        local drawn = parse_nums(f.drawn)
        local shown = math.min(#drawn, math.floor(f.draw_age / 1.0))
        local set = {}
        for i = 1, shown do set[drawn[i]] = true end
        local w, h = 460 * s, 150 * s
        local x, y = sw / 2 - w / 2, sh * 0.18
        local tickets = parse_tickets(f.last_tickets)
        local th = (#tickets > 0) and (#tickets * 26 * s + 10 * s) or 0
        draw.rect(x, y, x + w, y + h + th, 12, 12, 16, 225, 10 * s)
        draw.rect(x, y, x + w, y + 3 * s, ar, ag, ab, 255, 0)
        local title = "TONIGHT'S DRAW"
        text.draw(font.hud, sw / 2 - text.width(font.hud, title) / 2, y + 10 * s, 245, 245, 250, 255, title)
        local r = 24 * s
        for i = 1, #drawn do
            local bx = sw / 2 + (i - 3) * (r * 2 + 14 * s)
            local by = y + 70 * s
            if i <= shown then ball(bx, by, r, drawn[i], true, s)
            else draw.circle_outline(bx, by, r, 120, 120, 130, 200, 2 * s) end
        end
        if shown >= #drawn then
            local win = math.floor(f.last_win or 0)
            local msg = win > 0 and string.format("YOU WON $%d", win) or "NO WIN THIS TIME"
            local cr, cg, cb = 120, 230, 120
            if win == 0 then cr, cg, cb = 200, 200, 214 end
            text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y + h - 34 * s, cr, cg, cb, 255, msg)
        end
        local ty = y + h
        for _, t in ipairs(tickets) do
            local tx = sw / 2 - (#t * 34 * s) / 2
            for i, n in ipairs(t) do
                local hot = set[n] == true
                local str = tostring(n)
                local r2, g2, b2 = 170, 170, 185
                if hot then r2, g2, b2 = 255, 205, 60 end
                text.draw(font.hud_small, tx + (i - 1) * 34 * s, ty, r2, g2, b2, 255, str)
            end
            ty = ty + 26 * s
        end
        return
    end

    local tickets = parse_tickets(f.tickets)
    local w = 260 * s
    local lh = text.height(font.hud_small) + 4 * s
    local h = 70 * s + lh * #tickets
    local x, y = sw - w - 30 * s, sh * 0.6
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 210, 8 * s)
    draw.rect(x, y, x + 3 * s, y + h, 255, 205, 60, 255, 0)
    text.draw(font.hud, x + 14 * s, y + 8 * s, 255, 220, 100, 255, string.format("JACKPOT $%d", math.floor(f.jackpot or 0)))
    local m = math.floor(f.minutes_to_draw or 0)
    local next_str = string.format("DRAW IN %dH %02dM   %d TICKETS", math.floor(m / 60), m % 60, #tickets)
    text.draw(font.hud_tiny, x + 14 * s, y + 12 * s + text.height(font.hud), 200, 200, 214, 230, next_str)
    local ty = y + 58 * s
    for _, t in ipairs(tickets) do
        text.draw(font.hud_small, x + 14 * s, ty, 235, 235, 245, 255, table.concat(t, "  "))
        ty = ty + lh
    end
end)
