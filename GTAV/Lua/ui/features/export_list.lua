-- Export List. Published fields: active (bool), car1..car3 (names), price1..price3 (full-condition
-- prices), done1..done3 (bool, delivered), listed (1..3 = the car you are driving is on the list, 0 = not),
-- distance (metres to the drop-off), earned (this session), wait (seconds until the next list, 0 while one
-- is open).
features.on_draw("Export List", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local pad = 10 * s
    local th = text.height(font.tiny)
    local ih = text.height(font.small)
    local listed = math.floor(f.listed or 0)
    local wait = f.wait or 0

    local rows = {}
    for i = 1, 3 do
        rows[i] = { name = f["car" .. i] or "", price = math.floor(f["price" .. i] or 0), done = f["done" .. i] }
    end

    local w = 250 * s
    for i = 1, 3 do
        w = math.max(w, text.width(font.small, rows[i].name) + text.width(font.small, "$0000") + pad * 4 + 14 * s)
    end
    local h = pad * 2 + th + 4 * s + ih * 3 + th + 6 * s
    local x = sw - w - 28 * s
    local y = sh * 0.24

    draw.rect(x, y, x + w, y + h, 10, 10, 16, 175, 6 * s)
    draw.rect(x, y, x + 3 * s, y + h, ar, ag, ab, 255, 0)
    local cy = y + pad
    text.draw(font.tiny, x + pad * 1.5, cy, ar, ag, ab, 255, "EXPORT LIST")
    local tag = string.format("$%d", math.floor(f.earned or 0))
    text.draw(font.tiny, x + w - pad - text.width(font.tiny, tag), cy, 170, 170, 185, 230, tag)
    cy = cy + th + 4 * s

    for i = 1, 3 do
        local row = rows[i]
        local r, g, b, a = 240, 240, 245, 255
        if row.done then r, g, b, a = 120, 200, 120, 200 end
        if listed == i then r, g, b = ar, ag, ab end
        local box = 9 * s
        local bx, by = x + pad * 1.5, cy + (ih - box) / 2
        if row.done then
            draw.rect(bx, by, bx + box, by + box, 120, 200, 120, 255, 2 * s)
        else
            draw.rect(bx, by, bx + box, by + box, 80, 80, 92, 220, 2 * s)
        end
        text.draw(font.small, bx + box + 8 * s, cy, r, g, b, a, row.name)
        local price = string.format("$%d", row.price)
        text.draw(font.small, x + w - pad - text.width(font.small, price), cy, r, g, b, a, price)
        cy = cy + ih
    end

    local foot
    if wait > 0 then
        foot = string.format("NEW LIST IN %d:%02d", math.floor(wait / 60), math.floor(wait % 60))
    elseif listed > 0 then
        local d = f.distance or 0
        foot = d >= 1000 and string.format("DELIVER IT - %.1f KM", d / 1000) or string.format("DELIVER IT - %d M", math.floor(d))
    else
        foot = "FIND A CAR ON THE LIST"
    end
    text.draw(font.tiny, x + pad * 1.5, cy + 6 * s, 185, 185, 200, 230, foot)
end)
