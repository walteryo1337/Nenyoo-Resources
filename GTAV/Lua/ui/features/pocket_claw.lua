-- Pocket Claw Machine. Published fields: active (bool), state (1 ready, 2 dropping, 3 lifting, 4 carrying to the chute,
-- 5 returning), claw_x (0-1 across the cabinet; the prize chute is at the far left), claw_y (0 top .. 1 bottom),
-- held_type (prize in the claw, -1 none), last_won (type of the last prize won), won_flash / slip_flash (bool, a prize
-- just dropped down the chute / slipped out), net (cash won minus plays), cost (per play; 0 outside Story Mode),
-- prizes (blob "x,type;" for prizes in the pit), collection (blob "n," count per prize type).
local prizes = {
    { name = "Pogo Plush", r = 240, g = 120, b = 160, rare = 0 },
    { name = "Space Monkey", r = 150, g = 110, b = 70, rare = 0 },
    { name = "Gnome", r = 90, g = 160, b = 230, rare = 0 },
    { name = "Kitty", r = 245, g = 200, b = 90, rare = 0 },
    { name = "Impotent Rage", r = 200, g = 60, b = 60, rare = 1 },
    { name = "Golden Bear", r = 255, g = 215, b = 60, rare = 2 },
}

local function prize_blob(x, y, r, p, s)
    draw.circle(x, y, r, p.r, p.g, p.b, 255)
    draw.circle(x - r * 0.45, y - r * 0.75, r * 0.38, p.r, p.g, p.b, 255)
    draw.circle(x + r * 0.45, y - r * 0.75, r * 0.38, p.r, p.g, p.b, 255)
    draw.circle(x - r * 0.3, y - r * 0.15, r * 0.12, 20, 20, 24, 255)
    draw.circle(x + r * 0.3, y - r * 0.15, r * 0.12, 20, 20, 24, 255)
    if p.rare == 2 then draw.circle_outline(x, y, r * 1.25, 255, 240, 160, 200, 2 * s) end
end

features.on_draw("Pocket Claw Machine", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local w, h = 560 * s, 520 * s
    local x0, y0 = sw / 2 - w / 2, sh / 2 - h / 2
    draw.rect(x0 - 16 * s, y0 - 60 * s, x0 + w + 16 * s, y0 + h + 90 * s, 12, 12, 16, 230, 12 * s)
    draw.rect(x0, y0, x0 + w, y0 + h, 25, 30, 48, 255, 6 * s)
    draw.rect(x0, y0 + h * 0.86, x0 + w * 0.09, y0 + h, 8, 8, 10, 255, 0)
    draw.rect(x0, y0, x0 + w, y0 + 8 * s, ar, ag, ab, 255, 0)

    local pr = 22 * s
    local floor_y = y0 + h - pr - 6 * s
    for px, ty in string.gmatch(f.prizes or "", "([%d%.]+),(%d+);") do
        local p = prizes[tonumber(ty) + 1]
        if p then prize_blob(x0 + tonumber(px) * w, floor_y, pr, p, s) end
    end

    local cxp = x0 + (f.claw_x or 0.5) * w
    local top = y0 + 8 * s
    local bottom = floor_y - pr * 0.6
    local cy = top + 30 * s + (bottom - top - 30 * s) * (f.claw_y or 0)
    draw.line(cxp, top, cxp, cy, 200, 200, 214, 255, 2 * s)
    draw.rect(cxp - 14 * s, cy - 8 * s, cxp + 14 * s, cy + 4 * s, 180, 180, 195, 255, 3 * s)
    local open = (f.held_type or -1) < 0 and 14 or 6
    draw.line(cxp - 10 * s, cy + 4 * s, cxp - open * s, cy + 26 * s, 210, 210, 225, 255, 3 * s)
    draw.line(cxp + 10 * s, cy + 4 * s, cxp + open * s, cy + 26 * s, 210, 210, 225, 255, 3 * s)
    local held = math.floor(f.held_type or -1)
    if held >= 0 and prizes[held + 1] then prize_blob(cxp, cy + 30 * s, pr, prizes[held + 1], s) end

    local cost = math.floor(f.cost or 0)
    local head = cost > 0 and string.format("$%d A PLAY", cost) or "FREE PLAY"
    text.draw(font.item, x0, y0 - 46 * s, 245, 245, 250, 255, head)
    local net = math.floor(f.net or 0)
    local ns = string.format("NET %s$%d", net < 0 and "-" or "+", math.abs(net))
    local nr, ng, nb = 120, 230, 120
    if net < 0 then nr, ng, nb = 240, 90, 80 end
    text.draw(font.item, x0 + w - text.width(font.item, ns), y0 - 46 * s, nr, ng, nb, 255, ns)

    local counts = {}
    for n in string.gmatch(f.collection or "", "(%d+),") do counts[#counts + 1] = tonumber(n) end
    local cx = x0
    for i, p in ipairs(prizes) do
        local c = counts[i] or 0
        local label = string.format("%d", c)
        prize_blob(cx + 14 * s, y0 + h + 30 * s, 10 * s, p, s)
        text.draw(font.small, cx + 30 * s, y0 + h + 22 * s, c > 0 and 245 or 130, c > 0 and 245 or 130, c > 0 and 250 or 140, 255, label)
        cx = cx + w / #prizes
    end
    local state = math.floor(f.state or 0)
    local foot = state == 1 and "A / D MOVE     E DROP THE CLAW" or "..."
    if f.won_flash then
        local p = prizes[math.floor(f.last_won or 0) + 1]
        foot = "YOU WON " .. string.upper(p and p.name or "A PRIZE") .. "!"
    elseif f.slip_flash then
        foot = "IT SLIPPED!"
    end
    text.draw(font.small, sw / 2 - text.width(font.small, foot) / 2, y0 + h + 54 * s, 220, 220, 232, 240, foot)
end)
