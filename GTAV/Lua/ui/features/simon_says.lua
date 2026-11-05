-- Simon Says. Published fields: active (bool), state (1 get ready, 2 command live, 3 round passed, 4 out), command (0 jump,
-- 1 crouch, 2 sprint, 3 aim, 4 turn around), simon (bool, "Simon says" was said), window_left / window_total (seconds),
-- last_ok (bool), round (rounds survived), best (this session), paid, fail_reason (1 too slow, 2 no "Simon says").
local commands = { "JUMP!", "CROUCH!", "SPRINT!", "AIM!", "TURN AROUND!" }

features.on_draw("Simon Says", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)
    local y = sh * 0.18

    if state == 4 then
        local why = math.floor(f.fail_reason or 0) == 2 and "SIMON DIDN'T SAY!" or "TOO SLOW!"
        text.draw(big, cx - text.width(big, why) / 2, y, 240, 80, 70, 255, why)
        local sub = string.format("%d ROUNDS   BEST %d", math.floor(f.round or 0), math.floor(f.best or 0))
        if (f.paid or 0) > 0 then sub = sub .. string.format("   +$%d", math.floor(f.paid)) end
        text.draw(font.hud, cx - text.width(font.hud, sub) / 2, y + text.height(big), 245, 245, 250, 255, sub)
        return
    end

    local round = string.format("ROUND %d", math.floor(f.round or 0) + 1)
    text.draw(font.hud_small, cx - text.width(font.hud_small, round) / 2, y - 30 * s, 200, 200, 214, 230, round)

    if state == 2 then
        local cmd = commands[math.floor(f.command or 0) + 1] or ""
        local line = f.simon and ("SIMON SAYS " .. cmd) or cmd
        local r, g, b = 245, 245, 250
        if f.simon then r, g, b = ar, ag, ab end
        text.draw(big, cx - text.width(big, line) / 2, y, r, g, b, 255, line)
        local total = math.max(0.1, f.window_total or 1)
        local frac = math.max(0, math.min(1, (f.window_left or 0) / total))
        local bw = 420 * s
        local by = y + text.height(big) + 10 * s
        draw.rect(cx - bw / 2, by, cx + bw / 2, by + 6 * s, 40, 40, 50, 220, 3 * s)
        draw.rect(cx - bw / 2, by, cx - bw / 2 + bw * frac, by + 6 * s, r, g, b, 255, 3 * s)
    elseif state == 3 then
        local msg = f.last_ok and "GOOD" or ""
        text.draw(font.display, cx - text.width(font.display, msg) / 2, y, 120, 230, 120, 255, msg)
    elseif state == 1 then
        local msg = "GET READY..."
        text.draw(font.display, cx - text.width(font.display, msg) / 2, y, 200, 200, 214, 230, msg)
    end
end)
