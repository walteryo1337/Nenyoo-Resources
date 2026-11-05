-- Street Olympics. Shown while an event is on. Published fields: active (bool), dash (bool, 100m Dash; otherwise Long
-- Jump), countdown / running / marked / result (bool, event phase; marked = a jump was just measured), count (seconds
-- of countdown left), time (dash time in seconds), to_go (metres to the finish line or to the jump board), place
-- (finishing place in the dash), attempt (jump number, 1-3), jump (last jump in metres), foul (bool), set_best (best
-- jump of this set), medal (0 none, 1 bronze, 2 silver, 3 gold), best_time / best_jump (session records; 0 = none yet).
local medals = { "BRONZE", "SILVER", "GOLD" }
local medal_col = { { 205, 127, 50 }, { 200, 205, 215 }, { 255, 210, 80 } }
local places = { "1ST", "2ND", "3RD", "4TH" }

features.on_draw("Street Olympics", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx = sw / 2

    local w, h = 380 * s, 92 * s
    local x0, y0 = cx - w / 2, 40 * s
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 18, 215, 12 * s)
    local title = f.dash and "100M DASH" or string.format("LONG JUMP  -  JUMP %d OF 3", math.floor(f.attempt or 1))
    text.draw(font.hud_small, x0 + 16 * s, y0 + 8 * s, 235, 235, 245, 255, title)

    local big, sub
    if f.dash then
        big = string.format("%.2f", f.time or 0)
        local bt = f.best_time or 0
        sub = bt > 0 and string.format("RECORD %.2f", bt) or "NO RECORD YET"
        if f.running then sub = string.format("%.0fM TO GO   -   %s", math.max(0, f.to_go or 0), sub) end
    else
        big = f.foul and "FOUL" or string.format("%.2fM", f.jump or 0)
        sub = string.format("SET BEST %.2fM   -   RECORD %.2fM", f.set_best or 0, f.best_jump or 0)
        if f.running and (f.to_go or 0) > 0 then sub = string.format("%.0fM TO THE BOARD   -   %s", f.to_go, sub) end
    end
    text.draw(font.display, x0 + 16 * s, y0 + 32 * s, 255, 220, 90, 255, big)
    text.draw(font.hud_tiny, x0 + 16 * s, y0 + h - 22 * s, 190, 190, 205, 230, sub)

    local msg, r, g, b
    if f.countdown then
        local n = math.ceil(f.count or 0)
        msg, r, g, b = n > 0 and tostring(n) or "GO!", 255, 220, 90
    elseif f.marked then
        if f.foul then msg, r, g, b = "FOUL!", 255, 90, 80
        else msg, r, g, b = string.format("%.2f METRES", f.jump or 0), 170, 230, 140 end
    elseif f.result then
        local m = math.floor(f.medal or 0)
        local head = f.dash and (places[math.floor(f.place or 4)] or "4TH") .. " PLACE" or "SET OVER"
        if m > 0 then
            local c = medal_col[m]
            msg, r, g, b = head .. "  -  " .. medals[m], c[1], c[2], c[3]
        else
            msg, r, g, b = head .. "  -  NO MEDAL", 220, 220, 230
        end
    end
    if msg then text.draw(font.display, cx - text.width(font.display, msg) / 2, sh * 0.3, r, g, b, 255, msg) end
end)
