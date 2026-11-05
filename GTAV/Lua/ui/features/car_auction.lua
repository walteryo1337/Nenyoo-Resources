-- Car Auction. Published fields: active (bool), state (1 bidding, 2 sold), lot, name (car, may be missing), value
-- (estimate), bid (current bid), next_bid, leader (-1 nobody, 0 you, 1..3 rival bidders), countdown (seconds until the
-- hammer), cash (your story cash), won (bool, sold to you), bought (cars won this session).
local function money(v)
    local s = tostring(math.floor(v or 0))
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if out:sub(1, 1) == "," then out = out:sub(2) end
    return "$" .. out
end

features.on_draw("Car Auction", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local pad = 12 * s
    local w, h = 300 * s, 190 * s
    local x, y = sw - w - 28 * s, sh * 0.3

    draw.rect(x, y, x + w, y + h, 12, 10, 8, 205, 8 * s)
    draw.rect(x, y, x + w, y + 3 * s, 220, 180, 90, 255, 0)
    local cy = y + pad
    text.draw(font.hud_tiny, x + pad, cy, 220, 180, 90, 255, string.format("LOT %d", math.floor(f.lot or 0)))
    local est = "EST. " .. money(f.value)
    text.draw(font.hud_tiny, x + w - pad - text.width(font.hud_tiny, est), cy, 190, 180, 160, 230, est)
    cy = cy + text.height(font.hud_tiny) + 2 * s
    text.draw(font.hud, x + pad, cy, 245, 240, 230, 255, f.name or "MYSTERY LOT")
    cy = cy + text.height(font.hud) + 8 * s

    local leader = math.floor(f.leader or -1)
    local who = "OPENING BID"
    local lr, lg, lb = 200, 200, 210
    if leader == 0 then who, lr, lg, lb = "YOU LEAD", 90, 230, 110
    elseif leader > 0 then who, lr, lg, lb = string.format("BIDDER %d LEADS", leader), 240, 140, 80 end
    text.draw(font.hud_tiny, x + pad, cy, lr, lg, lb, 255, who)
    cy = cy + text.height(font.hud_tiny)
    text.draw(font.display, x + pad, cy, 255, 255, 255, 255, money(f.bid))
    cy = cy + text.height(font.display) + 6 * s

    local state = math.floor(f.state or 1)
    if state == 1 then
        local t = f.countdown or 0
        local call = ""
        if t <= 3 then call = "GOING TWICE" elseif t <= 6 then call = "GOING ONCE" end
        local frac = math.max(0, math.min(1, t / 12))
        draw.rect(x + pad, cy, x + w - pad, cy + 4 * s, 0, 0, 0, 150, 2 * s)
        draw.rect(x + pad, cy, x + pad + (w - pad * 2) * frac, cy + 4 * s, 220, 180, 90, 255, 2 * s)
        cy = cy + 10 * s
        local nb = "NEXT " .. money(f.next_bid) .. "   CASH " .. money(f.cash)
        text.draw(font.hud_tiny, x + pad, cy, 190, 190, 200, 230, nb)
        if call ~= "" then
            local pulse = 160 + math.floor(95 * math.abs(math.sin(ctx.time() * 5)))
            text.draw(big, sw / 2 - text.width(big, call) / 2, sh * 0.22, 240, 200, 90, pulse, call)
        end
    else
        local msg = f.won and "SOLD TO YOU!" or (leader < 0 and "NO SALE" or "SOLD")
        local r, g, b = 240, 140, 80
        if f.won then r, g, b = ar, ag, ab end
        text.draw(big, sw / 2 - text.width(big, msg) / 2, sh * 0.22, r, g, b, 255, msg)
    end
end)
