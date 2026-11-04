-- Blackjack. Published fields: active (bool), state (1 your turn, 2 dealer's turn, 3 result), player / dealer (cards as
-- "n,n,n" where n = suit * 13 + rank - 1, rank 1 = ace), player_total, dealer_total, hole_hidden (dealer's second card
-- is face down), stake, result (1 win, 2 lose, 3 push, 4 blackjack, 5 bust, 6 dealer bust), amount (net cash this
-- hand), net (session winnings, can be negative), hands (hands played).
local ranks = { "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" }
local suits = { "S", "H", "D", "C" }

local function parse(str)
    local out = {}
    for n in string.gmatch(str or "", "%d+") do out[#out + 1] = tonumber(n) end
    return out
end

local function card(x, y, w, h, c, s)
    draw.rect(x, y, x + w, y + h, 248, 246, 240, 255, 6 * s)
    if c == nil then
        draw.rect(x + 4 * s, y + 4 * s, x + w - 4 * s, y + h - 4 * s, 150, 30, 40, 255, 4 * s)
        return
    end
    local suit = math.floor(c / 13) + 1
    local rank = ranks[c % 13 + 1]
    local r, g, b = 25, 25, 30
    if suit == 2 or suit == 3 then r, g, b = 200, 30, 40 end
    text.draw(font.item, x + 6 * s, y + 4 * s, r, g, b, 255, rank)
    local sy = suits[suit]
    text.draw(font.title, x + w / 2 - text.width(font.title, sy) / 2, y + h / 2 - text.height(font.title) / 2 + 6 * s, r, g, b, 255, sy)
end

local function row(label, cards, hidden, total, y, cx, s)
    local w, h, gap = 54 * s, 76 * s, 8 * s
    local count = #cards + (hidden and 1 or 0)
    local width = count * w + (count - 1) * gap
    local x = cx - width / 2
    for i, c in ipairs(cards) do card(x + (i - 1) * (w + gap), y, w, h, c, s) end
    if hidden then card(x + #cards * (w + gap), y, w, h, nil, s) end
    local tag = string.format("%s  %d", label, total)
    text.draw(font.small, cx - text.width(font.small, tag) / 2, y + h + 4 * s, 220, 220, 232, 240, tag)
end

features.on_draw("Blackjack", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cx = sw / 2
    local state = math.floor(f.state or 0)

    local w, h = 460 * s, 290 * s
    local x, y = cx - w / 2, sh * 0.52
    draw.rect(x, y, x + w, y + h, 16, 70, 44, 225, 10 * s)
    draw.rect(x, y, x + w, y + 3 * s, ar, ag, ab, 255, 0)

    row("DEALER", parse(f.dealer), f.hole_hidden, math.floor(f.dealer_total or 0), y + 14 * s, cx, s)
    row("YOU", parse(f.player), false, math.floor(f.player_total or 0), y + 150 * s, cx, s)

    local msg, r, g, b
    if state == 1 then
        msg, r, g, b = "E HIT    G STAND", 235, 235, 245
    elseif state == 2 then
        msg, r, g, b = "DEALER DRAWS", 235, 235, 245
    else
        local result = math.floor(f.result or 0)
        local msgs = { "YOU WIN", "DEALER WINS", "PUSH", "BLACKJACK", "BUST", "DEALER BUSTS" }
        msg = msgs[result] or ""
        r, g, b = 220, 220, 230
        local amount = math.floor(f.amount or 0)
        if amount > 0 then
            r, g, b = 120, 230, 120
            msg = string.format("%s  +$%d", msg, amount)
        elseif amount < 0 then
            r, g, b = 240, 80, 70
            msg = string.format("%s  -$%d", msg, -amount)
        end
        if result == 4 then r, g, b = 255, 205, 60 end
    end
    text.draw(font.title, cx - text.width(font.title, msg) / 2, y - text.height(font.title) - 6 * s, r, g, b, 255, msg)

    local net = math.floor(f.net or 0)
    local foot = string.format("BET $%d   SESSION %s$%d", math.floor(f.stake or 0), net < 0 and "-" or "+", math.abs(net))
    text.draw(font.tiny, x + 12 * s, y + h - 8 * s - text.height(font.tiny), 220, 235, 225, 230, foot)
end)
