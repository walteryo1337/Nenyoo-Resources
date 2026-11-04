-- Pocket 2048. Published fields: active (bool), state (1 playing, 2 no moves left), score, best, won (bool, a 2048 tile
-- has been made), spawned (0-based cell of the newest tile), spawn_age (0..1 pop-in animation), grid (blob of 16 "v;"
-- values row by row, 0 = empty).
local palette = {
    [2] = { 238, 228, 218 }, [4] = { 237, 224, 200 }, [8] = { 242, 177, 121 }, [16] = { 245, 149, 99 },
    [32] = { 246, 124, 95 }, [64] = { 246, 94, 59 }, [128] = { 237, 207, 114 }, [256] = { 237, 204, 97 },
    [512] = { 237, 200, 80 }, [1024] = { 237, 197, 63 }, [2048] = { 237, 194, 46 },
}

features.on_draw("Pocket 2048", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local big = font.display or font.title
    local cell = 92 * s
    local gap = 10 * s
    local size = 4 * cell + 5 * gap
    local cx = sw / 2
    local x0, y0 = cx - size / 2, sh * 0.5 - size / 2 + 20 * s

    local vals = {}
    for v in string.gmatch(f.grid or "", "(%d+);") do vals[#vals + 1] = tonumber(v) end

    local score = string.format("SCORE %d", math.floor(f.score or 0))
    local best = string.format("BEST %d", math.floor(f.best or 0))
    text.draw(font.item, x0, y0 - text.height(font.item) - 10 * s, 245, 245, 250, 255, score)
    text.draw(font.item, x0 + size - text.width(font.item, best), y0 - text.height(font.item) - 10 * s, 200, 200, 212, 255, best)

    draw.rect(x0, y0, x0 + size, y0 + size, 187, 173, 160, 245, 8 * s)
    local spawned = math.floor(f.spawned or -1)
    local age = f.spawn_age or 1
    for i = 0, 15 do
        local r, c = math.floor(i / 4), i % 4
        local x = x0 + gap + c * (cell + gap)
        local y = y0 + gap + r * (cell + gap)
        local v = vals[i + 1] or 0
        if v == 0 then
            draw.rect(x, y, x + cell, y + cell, 205, 193, 180, 255, 6 * s)
        else
            local col = palette[v] or { 60, 58, 50 }
            local inset = 0
            if i == spawned and age < 1 then inset = cell * 0.35 * (1 - age) end
            draw.rect(x + inset, y + inset, x + cell - inset, y + cell - inset, col[1], col[2], col[3], 255, 6 * s)
            local label = tostring(v)
            local fnt = v >= 1024 and font.item or font.title
            local tr, tg, tb = 249, 246, 242
            if v <= 4 then tr, tg, tb = 119, 110, 101 end
            text.draw(fnt, x + cell / 2 - text.width(fnt, label) / 2, y + cell / 2 - text.height(fnt) / 2, tr, tg, tb, 255, label)
        end
    end

    local hint = "W A S D TO SLIDE   TURN OFF TO QUIT"
    text.draw(font.tiny, cx - text.width(font.tiny, hint) / 2, y0 + size + 10 * s, 190, 190, 205, 230, hint)

    if math.floor(f.state or 0) == 2 then
        draw.rect(x0, y0, x0 + size, y0 + size, 238, 228, 218, 170, 8 * s)
        local msg = "NO MOVES LEFT"
        text.draw(big, cx - text.width(big, msg) / 2, y0 + size / 2 - text.height(big), 119, 110, 101, 255, msg)
        local again = "PRESS ANY DIRECTION FOR A NEW GAME"
        text.draw(font.small, cx - text.width(font.small, again) / 2, y0 + size / 2 + 6 * s, 119, 110, 101, 255, again)
    elseif f.won then
        local msg = "2048!"
        text.draw(font.title, cx - text.width(font.title, msg) / 2, y0 - text.height(font.item) - text.height(font.title) - 14 * s, 237, 194, 46, 255, msg)
    end
end)
