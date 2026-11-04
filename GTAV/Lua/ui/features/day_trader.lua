-- Day Trader. Published fields: active (bool), sel (0-5 selected stock), lot (shares per trade), shares (owned of the
-- selected stock), avg_cost (per share, selected stock), holdings_value (all shares at current prices), realized (profit
-- or loss from sales this session), cash (your money; missing outside Story Mode), news_stock / news_good (present for a
-- few seconds after a headline: which stock and whether it is good news), table (blob "price|change%|shares;" per stock,
-- in stock order), hist (blob "price," x48, oldest first, selected stock).
local stocks = {
    { sym = "FLC", name = "Fleeca" },
    { sym = "MAZ", name = "Maze Bank" },
    { sym = "BEN", name = "Bean Machine" },
    { sym = "LFI", name = "Lifeinvader" },
    { sym = "CLK", name = "Cluckin' Bell" },
    { sym = "GOP", name = "GoPostal" },
}
local good_news = {
    "%s smashes quarterly earnings forecasts",
    "Analysts upgrade %s to a strong buy",
    "%s announces a surprise share buyback",
}
local bad_news = {
    "%s hit by a regulatory investigation",
    "%s CEO caught in a tabloid scandal",
    "%s recalls its flagship product",
}

local function parse_table(blob)
    local out = {}
    for p, c, sh in string.gmatch(blob or "", "([%d%.%-]+)|([%d%.%-]+)|(%d+);") do
        out[#out + 1] = { price = tonumber(p) or 0, pct = tonumber(c) or 0, shares = tonumber(sh) or 0 }
    end
    return out
end

local function parse_hist(blob)
    local out = {}
    for v in string.gmatch(blob or "", "([%d%.%-]+),") do out[#out + 1] = tonumber(v) or 0 end
    return out
end

local last_news_stock, last_news_line = nil, nil

features.on_draw("Day Trader", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local rows = parse_table(f.table)
    local sel = math.floor(f.sel or 0) + 1

    local w = 330 * s
    local x = 30 * s
    local y = sh * 0.22
    local lh = text.height(font.small) + 6 * s
    local panel_h = 34 * s + lh * #stocks + 120 * s + lh * 3
    draw.rect(x, y, x + w, y + panel_h, 12, 12, 16, 215, 8 * s)
    draw.rect(x, y, x + w, y + 3 * s, ar, ag, ab, 255, 0)
    text.draw(font.item, x + 12 * s, y + 8 * s, 245, 245, 250, 255, "LS EXCHANGE")

    local ry = y + 34 * s
    for i, st in ipairs(stocks) do
        local r = rows[i]
        if i == sel then draw.rect(x + 6 * s, ry - 2 * s, x + w - 6 * s, ry + lh - 4 * s, ar, ag, ab, 50, 4 * s) end
        text.draw(font.small, x + 12 * s, ry, 235, 235, 245, 255, st.sym)
        if r then
            local price = string.format("$%.2f", r.price)
            text.draw(font.small, x + 70 * s, ry, 220, 220, 232, 255, price)
            local pct = string.format("%+.1f%%", r.pct)
            local cr, cg, cb = 120, 220, 120
            if r.pct < 0 then cr, cg, cb = 240, 90, 80 end
            text.draw(font.small, x + w - 12 * s - text.width(font.small, pct), ry, cr, cg, cb, 255, pct)
            if r.shares > 0 then
                local own = tostring(r.shares)
                text.draw(font.tiny, x + 170 * s, ry + 2 * s, 190, 190, 205, 230, own)
            end
        end
        ry = ry + lh
    end

    -- sparkline for the selected stock
    local hist = parse_hist(f.hist)
    local gx1, gx2 = x + 12 * s, x + w - 12 * s
    local gy1, gy2 = ry + 8 * s, ry + 108 * s
    draw.rect(gx1, gy1, gx2, gy2, 22, 22, 28, 230, 4 * s)
    if #hist > 1 then
        local lo, hi = math.huge, -math.huge
        for _, v in ipairs(hist) do
            if v < lo then lo = v end
            if v > hi then hi = v end
        end
        if hi - lo < 0.01 then hi = lo + 0.01 end
        local up = hist[#hist] >= hist[1]
        local lr, lg, lb = 120, 220, 120
        if not up then lr, lg, lb = 240, 90, 80 end
        local function pt(i)
            local px = gx1 + 4 * s + (gx2 - gx1 - 8 * s) * (i - 1) / (#hist - 1)
            local py = gy2 - 4 * s - (gy2 - gy1 - 8 * s) * (hist[i] - lo) / (hi - lo)
            return px, py
        end
        local px, py = pt(1)
        for i = 2, #hist do
            local nx, ny = pt(i)
            draw.line(px, py, nx, ny, lr, lg, lb, 255, 2 * s)
            px, py = nx, ny
        end
    end
    ry = gy2 + 10 * s

    local st = stocks[sel]
    local own = math.floor(f.shares or 0)
    local pos = own > 0 and string.format("%s  %d @ $%.2f", st.name, own, f.avg_cost or 0) or string.format("%s  no position", st.name)
    text.draw(font.small, x + 12 * s, ry, 235, 235, 245, 255, pos)
    ry = ry + lh
    local pl = math.floor(f.realized or 0)
    local plr, plg, plb = 120, 220, 120
    if pl < 0 then plr, plg, plb = 240, 90, 80 end
    text.draw(font.small, x + 12 * s, ry, 200, 200, 214, 240, string.format("PORTFOLIO $%d", math.floor(f.holdings_value or 0)))
    local pls = string.format("P/L %+d", pl)
    text.draw(font.small, x + w - 12 * s - text.width(font.small, pls), ry, plr, plg, plb, 255, pls)
    ry = ry + lh
    local lot = string.format("TRADE SIZE %d", math.floor(f.lot or 1))
    text.draw(font.tiny, x + 12 * s, ry, 180, 180, 195, 230, lot)
    if f.cash then
        local c = string.format("CASH $%d", math.floor(f.cash))
        text.draw(font.tiny, x + w - 12 * s - text.width(font.tiny, c), ry, 180, 180, 195, 230, c)
    end

    if f.news_stock then
        local k = math.floor(f.news_stock) + 1
        if last_news_stock ~= k then
            local pool = f.news_good and good_news or bad_news
            last_news_line = string.format(pool[math.random(#pool)], (stocks[k] or stocks[1]).name)
            last_news_stock = k
        end
        local nr, ng, nb = 120, 220, 120
        if not f.news_good then nr, ng, nb = 240, 90, 80 end
        local ny = y + panel_h + 8 * s
        local nw = math.max(w, text.width(font.small, last_news_line) + 24 * s)
        draw.rect(x, ny, x + nw, ny + lh + 8 * s, 12, 12, 16, 215, 6 * s)
        draw.rect(x, ny, x + 3 * s, ny + lh + 8 * s, nr, ng, nb, 255, 0)
        text.draw(font.small, x + 12 * s, ny + 6 * s, 240, 240, 248, 255, last_news_line)
    else
        last_news_stock = nil
    end
end)
