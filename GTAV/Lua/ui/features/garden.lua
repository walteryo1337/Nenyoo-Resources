-- Garden Plot. Shown while you are near your garden. Published fields: active (bool), earned (cash made this session),
-- slots (blob "stage,crop,growth,water;" for each of the six beds: stage 0 empty, 1 growing, 2 ripe, 3 rotten;
-- crop 0 cabbages, 1 corn, 2 pumpkins; growth and water 0..1).
local crop_names = { "CABBAGE", "CORN", "PUMPKIN" }
local crop_col = { { 140, 220, 110 }, { 250, 210, 80 }, { 255, 150, 60 } }

features.on_draw("Garden Plot", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0

    local cw, chh, gap = 92 * s, 78 * s, 8 * s
    local w = cw * 3 + gap * 2 + 28 * s
    local h = chh * 2 + gap + 62 * s
    local x0, y0 = sw - w - 24 * s, sh * 0.5 - h / 2
    draw.rect(x0, y0, x0 + w, y0 + h, 14, 12, 10, 215, 12 * s)
    text.draw(font.small, x0 + 14 * s, y0 + 8 * s, 235, 235, 225, 255, "GARDEN")
    local earned = string.format("$%d", math.floor(f.earned or 0))
    text.draw(font.tiny, x0 + w - 14 * s - text.width(font.tiny, earned), y0 + 12 * s, 130, 255, 160, 240, earned)

    local i = 0
    for stage, crop, growth, water in string.gmatch(f.slots or "", "(%d+),(%d+),([%d%.]+),([%d%.]+);") do
        stage, crop, growth, water = tonumber(stage), tonumber(crop), tonumber(growth), tonumber(water)
        local cx = x0 + 14 * s + (i % 3) * (cw + gap)
        local cy = y0 + 40 * s + math.floor(i / 3) * (chh + gap)
        draw.rect(cx, cy, cx + cw, cy + chh, 60, 42, 26, 255, 8 * s)
        local col = crop_col[crop + 1] or crop_col[1]
        if stage == 0 then
            local e = "EMPTY"
            text.draw(font.tiny, cx + cw / 2 - text.width(font.tiny, e) / 2, cy + chh / 2 - 8 * s, 170, 150, 120, 220, e)
        else
            local name = crop_names[crop + 1] or ""
            text.draw(font.tiny, cx + 8 * s, cy + 6 * s, col[1], col[2], col[3], 255, name)
            if stage == 1 then
                local bx, by, bw = cx + 8 * s, cy + chh - 34 * s, cw - 16 * s
                draw.rect(bx, by, bx + bw, by + 8 * s, 30, 24, 18, 255, 4 * s)
                draw.rect(bx, by, bx + bw * math.min(1, growth), by + 8 * s, col[1], col[2], col[3], 255, 4 * s)
                local wy = cy + chh - 18 * s
                draw.rect(bx, wy, bx + bw, wy + 6 * s, 30, 24, 18, 255, 3 * s)
                local thirsty = water < 0.5
                local wa = thirsty and math.floor(150 + 105 * math.abs(math.sin(t * 4))) or 255
                draw.rect(bx, wy, bx + bw * math.max(0, math.min(1, water)), wy + 6 * s, 80, 160, 255, wa, 3 * s)
                if water <= 0 then
                    local dry = "DRY!"
                    text.draw(font.tiny, cx + cw - 8 * s - text.width(font.tiny, dry), cy + 6 * s, 255, 120, 100, wa, dry)
                end
            elseif stage == 2 then
                local r = "RIPE"
                local a = math.floor(180 + 75 * math.sin(t * 5))
                text.draw(font.small, cx + cw / 2 - text.width(font.small, r) / 2, cy + chh / 2 - 4 * s, 130, 255, 160, a, r)
            else
                local r = "ROTTEN"
                text.draw(font.small, cx + cw / 2 - text.width(font.small, r) / 2, cy + chh / 2 - 4 * s, 150, 120, 90, 230, r)
            end
        end
        i = i + 1
    end
    local hint = "GROWTH  /  WATER"
    text.draw(font.tiny, x0 + w / 2 - text.width(font.tiny, hint) / 2, y0 + h - 20 * s, 170, 170, 160, 200, hint)
end)
