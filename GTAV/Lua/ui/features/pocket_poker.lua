-- Pocket Video Poker. Published fields: active (bool), state (1 place a bet, 2 choose holds, 3 hand paid), cursor (0-4
-- selected card), holds (bitmask of held cards, bit 0 = first card), result (hand rank 0-9, see `hands`), paid (returned
-- to you this hand, stake included), stake, net (session), hands (played), cards (blob "c," x5: c = rank + suit * 13, rank
-- 0 = two .. 12 = ace, suits 0 clubs, 1 diamonds, 2 hearts, 3 spades).
local hands = { "NO WIN", "JACKS OR BETTER", "TWO PAIR", "THREE OF A KIND", "STRAIGHT", "FLUSH", "FULL HOUSE",
    "FOUR OF A KIND", "STRAIGHT FLUSH", "ROYAL FLUSH" }
local pays = { 0, 1, 2, 3, 4, 6, 9, 25, 50, 250 }
local ranks = { "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A" }
local suits = { "C", "D", "H", "S" }

local function has_bit(mask, i)
    return math.floor(mask / 2 ^ i) % 2 == 1
end

features.on_draw("Pocket Video Poker", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local w, h = 820 * s, 560 * s
    local x0, y0 = sw / 2 - w / 2, sh / 2 - h / 2
    draw.rect(x0, y0, x0 + w, y0 + h, 18, 24, 60, 235, 12 * s)
    draw.rect(x0, y0, x0 + w, y0 + 4 * s, ar, ag, ab, 255, 0)
    local state = math.floor(f.state or 0)
    local result = math.floor(f.result or 0)

    -- pay table
    local ty = y0 + 16 * s
    local lh = text.height(font.tiny) + 2 * s
    for i = 10, 2, -1 do
        local hot = state == 3 and result == i - 1
        local r, g, b = 200, 200, 214
        if hot then r, g, b = 255, 220, 90 end
        text.draw(font.tiny, x0 + 24 * s, ty, r, g, b, 255, hands[i])
        local p = tostring(pays[i])
        text.draw(font.tiny, x0 + 260 * s - text.width(font.tiny, p), ty, r, g, b, 255, p)
        ty = ty + lh
    end

    local cards = {}
    for c in string.gmatch(f.cards or "", "(%d+),") do cards[#cards + 1] = tonumber(c) end
    local cw, ch = 130 * s, 182 * s
    local gap = 22 * s
    local cx0 = sw / 2 - (5 * cw + 4 * gap) / 2
    local cy = y0 + h - ch - 90 * s
    local holds = math.floor(f.holds or 0)
    for i = 0, 4 do
        local x = cx0 + i * (cw + gap)
        local c = cards[i + 1]
        if c then
            draw.rect(x, cy, x + cw, cy + ch, 245, 245, 248, 255, 10 * s)
            local rank, suit = c % 13, math.floor(c / 13)
            local red = suit == 1 or suit == 2
            local r, g, b = 25, 25, 30
            if red then r, g, b = 210, 40, 40 end
            local big = font.display or font.title
            local label = ranks[rank + 1]
            text.draw(big, x + cw / 2 - text.width(big, label) / 2, cy + ch * 0.32 - text.height(big) / 2, r, g, b, 255, label)
            local sl = suits[suit + 1]
            text.draw(font.title, x + cw / 2 - text.width(font.title, sl) / 2, cy + ch * 0.72 - text.height(font.title) / 2, r, g, b, 255, sl)
        else
            draw.rect(x, cy, x + cw, cy + ch, 120, 30, 40, 255, 10 * s)
            draw.rect(x + 10 * s, cy + 10 * s, x + cw - 10 * s, cy + ch - 10 * s, 150, 45, 55, 255, 6 * s)
        end
        if state == 2 and i == math.floor(f.cursor or 0) then
            draw.rect(x, cy + ch + 8 * s, x + cw, cy + ch + 12 * s, ar, ag, ab, 255, 0)
        end
        if has_bit(holds, i) then
            local held = "HELD"
            text.draw(font.small, x + cw / 2 - text.width(font.small, held) / 2, cy - text.height(font.small) - 6 * s, 255, 220, 90, 255, held)
        end
    end

    local net = math.floor(f.net or 0)
    local ns = string.format("NET %s$%d", net < 0 and "-" or "+", math.abs(net))
    local nr, ng, nb = 120, 230, 120
    if net < 0 then nr, ng, nb = 240, 90, 80 end
    text.draw(font.item, x0 + w - 24 * s - text.width(font.item, ns), y0 + 16 * s, nr, ng, nb, 255, ns)
    local stake = math.floor(f.stake or 0)
    local bet = stake > 0 and string.format("BET $%d", stake) or "FREE PLAY"
    text.draw(font.small, x0 + w - 24 * s - text.width(font.small, bet), y0 + 20 * s + text.height(font.item), 220, 220, 232, 240, bet)

    if state == 3 then
        local msg = hands[result + 1] or ""
        if (f.paid or 0) > 0 then msg = msg .. string.format("   WIN $%d", math.floor(f.paid)) end
        local r, g, b = 220, 220, 232
        if (f.paid or 0) > 0 then r, g, b = 255, 220, 90 end
        text.draw(font.title, sw / 2 - text.width(font.title, msg) / 2, y0 + h * 0.36, r, g, b, 255, msg)
    end
    local foot
    if state == 2 then foot = "A / D SELECT     W HOLD     E DRAW"
    else foot = "E DEAL" end
    text.draw(font.small, sw / 2 - text.width(font.small, foot) / 2, y0 + h - 40 * s, 230, 230, 240, 255, foot)
end)
