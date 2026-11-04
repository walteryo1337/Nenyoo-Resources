-- Speed Dating. Published fields: active (bool), state (1 picking a line, 2 their reaction, 3 verdict, 4 strolling
-- together after a match), round / rounds, chemistry (0-100; 60 or more is a match), time_left (seconds to answer, or of
-- the stroll), sel (0-2 highlighted line), opt1 / opt2 / opt3 (lines to say, while picking), reply (their reaction or the
-- verdict), matched (bool), matches / dates (this session).
features.on_draw("Speed Dating", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cx = sw / 2
    local state = math.floor(f.state or 0)
    local chem = math.max(0, math.min(100, f.chemistry or 0))

    if state == 4 then
        local t = math.max(0, f.time_left or 0)
        local msg = string.format("ON A STROLL  %d:%02d", math.floor(t / 60), math.floor(t % 60))
        text.draw(font.small, sw - 30 * s - text.width(font.small, msg), sh * 0.4, 245, 150, 190, 255, msg)
        return
    end

    -- chemistry meter
    local mw = 340 * s
    local mx, my = cx - mw / 2, sh * 0.08
    draw.rect(mx - 12 * s, my - 34 * s, mx + mw + 12 * s, my + 30 * s, 12, 12, 16, 210, 8 * s)
    text.draw(font.small, mx, my - 28 * s, 245, 245, 250, 255, "CHEMISTRY")
    local rs = string.format("ROUND %d / %d", math.min(math.floor(f.round or 0) + (state == 1 and 1 or 0), math.floor(f.rounds or 5)), math.floor(f.rounds or 5))
    text.draw(font.small, mx + mw - text.width(font.small, rs), my - 28 * s, 200, 200, 214, 240, rs)
    draw.rect(mx, my, mx + mw, my + 12 * s, 40, 40, 50, 230, 5 * s)
    draw.rect(mx, my, mx + mw * chem / 100, my + 12 * s, 245, 110, 160, 255, 5 * s)
    draw.rect(mx + mw * 0.6 - 1 * s, my - 4 * s, mx + mw * 0.6 + 1 * s, my + 16 * s, 255, 255, 255, 200, 0)

    local bw = math.min(sw - 60 * s, 760 * s)
    local bx = cx - bw / 2
    local row = text.height(font.item) + 12 * s
    local bh = row * 3 + 40 * s
    local by = sh * 0.70
    draw.rect(bx, by, bx + bw, by + bh, 10, 10, 14, 220, 8 * s)

    if state == 1 then
        local left = f.time_left or 0
        draw.rect(bx, by, bx + bw * math.min(1, left / 15), by + 3 * s, 245, 110, 160, 255, 0)
        local sel = math.floor(f.sel or 0)
        local opts = { f.opt1, f.opt2, f.opt3 }
        for i = 1, 3 do
            local line = opts[i] or ""
            local ry = by + 14 * s + (i - 1) * row
            if sel == i - 1 then
                draw.rect(bx + 10 * s, ry - 4 * s, bx + bw - 10 * s, ry + row - 8 * s, ar, ag, ab, 60, 4 * s)
                text.draw(font.item, bx + 22 * s, ry, 255, 255, 255, 255, line)
            else
                text.draw(font.item, bx + 22 * s, ry, 190, 190, 205, 230, line)
            end
        end
        local hint = "W / S  CHOOSE     E  SAY IT"
        text.draw(font.tiny, cx - text.width(font.tiny, hint) / 2, by + bh - text.height(font.tiny) - 8 * s, 170, 170, 185, 220, hint)
    elseif f.reply then
        local r, g, b = 240, 240, 248
        if state == 3 then
            if f.matched then r, g, b = 245, 150, 190 else r, g, b = 200, 200, 214 end
            local head = f.matched and "IT'S A MATCH" or "NO SPARK"
            local big = font.display or font.title
            text.draw(big, cx - text.width(big, head) / 2, sh * 0.28, r, g, b, 255, head)
        end
        text.draw(font.item, cx - text.width(font.item, f.reply) / 2, by + bh / 2 - text.height(font.item) / 2, r, g, b, 255, f.reply)
    end
end)
