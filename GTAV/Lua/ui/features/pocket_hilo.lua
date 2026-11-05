-- Pocket Hi-Lo. Published fields: active (bool), state (1 guessing, 2 lost, 3 cashed out, 4 cannot afford the
-- stake), card / prev_card (0 to 51, rank = card % 13 with 0 = 2 up to 12 = ace, suit = card // 13; prev_card -1
-- when none), pot, stake, streak (correct guesses this hand), net (session winnings, can be negative),
-- pay_hi / pay_lo (multiplier the pot gets for a correct higher / lower guess; 0 when that guess cannot win).
local RANKS = { "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A" }

local function suit_shape(suit, cx, cy, r, cr, cg, cb)
    if suit == 0 then
        draw.line(cx, cy - r, cx + r * 0.75, cy, cr, cg, cb, 255, r * 0.35)
        draw.line(cx + r * 0.75, cy, cx, cy + r, cr, cg, cb, 255, r * 0.35)
        draw.line(cx, cy + r, cx - r * 0.75, cy, cr, cg, cb, 255, r * 0.35)
        draw.line(cx - r * 0.75, cy, cx, cy - r, cr, cg, cb, 255, r * 0.35)
    elseif suit == 1 then
        draw.circle(cx, cy - r * 0.45, r * 0.42, cr, cg, cb, 255)
        draw.circle(cx - r * 0.45, cy + r * 0.15, r * 0.42, cr, cg, cb, 255)
        draw.circle(cx + r * 0.45, cy + r * 0.15, r * 0.42, cr, cg, cb, 255)
        draw.rect(cx - r * 0.08, cy, cx + r * 0.08, cy + r, cr, cg, cb, 255, 0)
    elseif suit == 2 then
        draw.circle(cx - r * 0.4, cy - r * 0.25, r * 0.45, cr, cg, cb, 255)
        draw.circle(cx + r * 0.4, cy - r * 0.25, r * 0.45, cr, cg, cb, 255)
        for i = 0, 6 do
            local k = i / 6
            draw.line(cx - r * 0.85 * (1 - k), cy + r * (0.05 + 0.9 * k), cx + r * 0.85 * (1 - k), cy + r * (0.05 + 0.9 * k), cr, cg, cb, 255, r * 0.18)
        end
    else
        draw.circle(cx - r * 0.4, cy + r * 0.2, r * 0.45, cr, cg, cb, 255)
        draw.circle(cx + r * 0.4, cy + r * 0.2, r * 0.45, cr, cg, cb, 255)
        for i = 0, 6 do
            local k = i / 6
            draw.line(cx - r * 0.85 * k, cy - r + r * 1.05 * k, cx + r * 0.85 * k, cy - r + r * 1.05 * k, cr, cg, cb, 255, r * 0.18)
        end
        draw.rect(cx - r * 0.08, cy + r * 0.3, cx + r * 0.08, cy + r, cr, cg, cb, 255, 0)
    end
end

local function card(c, x, y, w, h, s, alpha)
    draw.rect(x + 4 * s, y + 5 * s, x + w + 4 * s, y + h + 5 * s, 0, 0, 0, math.floor(90 * alpha), 10 * s)
    draw.rect(x, y, x + w, y + h, 248, 246, 240, math.floor(255 * alpha), 10 * s)
    local rk, suit = c % 13, math.floor(c / 13)
    local red = suit == 0 or suit == 2
    local cr, cg, cb = 30, 30, 36
    if red then cr, cg, cb = 210, 40, 50 end
    local label = RANKS[rk + 1]
    text.draw(font.display, x + 10 * s, y + 6 * s, cr, cg, cb, math.floor(255 * alpha), label)
    suit_shape(suit, x + w / 2, y + h / 2 + 8 * s, w * 0.22, cr, cg, cb)
end

features.on_draw("Pocket Hi-Lo", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local state = math.floor(f.state or 0)
    local pw, ph = 620 * s, 470 * s
    local x0, y0 = sw / 2 - pw / 2, sh / 2 - ph / 2

    draw.rect(x0, y0, x0 + pw, y0 + ph, 12, 12, 16, 225, 12 * s)
    draw.rect(x0 + 16 * s, y0 + 60 * s, x0 + pw - 16 * s, y0 + ph - 70 * s, 20, 90, 50, 255, 10 * s)

    local title = "HI-LO"
    text.draw(font.display, sw / 2 - text.width(font.display, title) / 2, y0 + 12 * s, 245, 245, 250, 255, title)

    local cw, ch = 150 * s, 210 * s
    local cy = y0 + 95 * s
    local prev = math.floor(f.prev_card or -1)
    if prev >= 0 then card(prev, sw / 2 - cw - 40 * s, cy + 15 * s, cw * 0.85, ch * 0.85, s, 0.55) end
    if state ~= 4 then card(math.floor(f.card or 0), sw / 2 + (prev >= 0 and 10 * s or -cw / 2), cy, cw, ch, s, 1) end

    local pot = string.format("POT $%d", math.floor(f.pot or 0))
    text.draw(font.hud, sw / 2 - text.width(font.hud, pot) / 2, cy + ch + 14 * s, 255, 225, 120, 255, pot)

    local msg
    if state == 1 then
        local hi, lo = f.pay_hi or 0, f.pay_lo or 0
        local hs = hi > 0 and string.format("W HIGHER x%.2f", hi) or "W HIGHER -"
        local ls = lo > 0 and string.format("S LOWER x%.2f", lo) or "S LOWER -"
        msg = hs .. "     " .. ls
        if math.floor(f.streak or 0) > 0 then msg = msg .. "     E CASH OUT" end
    elseif state == 2 then msg = "WRONG - YOU LOST THE POT     SPACE TO DEAL"
    elseif state == 3 then msg = "CASHED OUT     SPACE TO DEAL"
    else msg = "YOU CANNOT AFFORD THE STAKE" end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y0 + ph - 58 * s, 220, 220, 230, 240, msg)

    local net = math.floor(f.net or 0)
    local ns = string.format("STAKE $%d     SESSION %s$%d", math.floor(f.stake or 0), net < 0 and "-" or "+", math.abs(net))
    local nr, ng = 140, 220
    if net < 0 then nr, ng = 235, 110 end
    text.draw(font.hud_tiny, sw / 2 - text.width(font.hud_tiny, ns) / 2, y0 + ph - 28 * s, nr, ng, 140, 230, ns)
end)
