-- Club Bouncer. Published fields: active (bool), state (1 on the door, 2 shift over), rule1 / rule2 (tonight's dress code:
-- 0 no hats, 1 no glasses, 2 women only, 3 men only), handled / total (guests dealt with), correct, streak, cash (tips minus
-- fines this shift), has_front (bool, someone is at the front), front_vip (bool), verdict (present for a moment after each
-- call: 1 let in correctly, 2 turned away correctly, 3 let in someone who broke the code, 4 turned away someone who was fine,
-- 5 turned away a VIP), verdict_reason (the rule broken, -1 none).
local rules = { "NO HATS", "NO GLASSES", "WOMEN ONLY", "MEN ONLY" }
local reasons = { "WEARING A HAT", "WEARING GLASSES", "NOT A WOMAN", "NOT A MAN" }
local verdicts = {
    { "WELCOME IN", 120, 230, 120 }, { "GOOD CALL", 120, 230, 120 }, { "CODE BROKEN", 240, 90, 80 },
    { "THEY WERE FINE", 240, 140, 80 }, { "THAT WAS A VIP!", 240, 80, 70 },
}

features.on_draw("Club Bouncer", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local state = math.floor(f.state or 0)

    if state == 2 then
        local msg = "SHIFT OVER"
        text.draw(big, sw / 2 - text.width(big, msg) / 2, sh * 0.26, ar, ag, ab, 255, msg)
        local cash = math.floor(f.cash or 0)
        local sub = string.format("%d / %d RIGHT CALLS   %s$%d", math.floor(f.correct or 0), math.floor(f.total or 0), cash < 0 and "-" or "+", math.abs(cash))
        text.draw(font.item, sw / 2 - text.width(font.item, sub) / 2, sh * 0.26 + text.height(big), 245, 245, 250, 255, sub)
        return
    end

    local w = 280 * s
    local x, y = 30 * s, sh * 0.3
    local lh = text.height(font.small) + 6 * s
    local h = 60 * s + lh * 4
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 215, 8 * s)
    draw.rect(x, y, x + w, y + 3 * s, 190, 120, 240, 255, 0)
    text.draw(font.tiny, x + 14 * s, y + 10 * s, 190, 190, 205, 230, "TONIGHT'S DRESS CODE")
    local ry = y + 14 * s + text.height(font.tiny)
    for _, r in ipairs({ f.rule1, f.rule2 }) do
        local label = rules[math.floor(r or 0) + 1] or ""
        text.draw(font.item, x + 14 * s, ry, 245, 245, 250, 255, label)
        ry = ry + text.height(font.item) + 2 * s
    end
    text.draw(font.tiny, x + 14 * s, ry + 4 * s, 255, 205, 60, 230, "VIPS ALWAYS GET IN")
    ry = ry + lh + 4 * s
    local cash = math.floor(f.cash or 0)
    local stat = string.format("GUEST %d / %d   %s$%d", math.min(math.floor(f.handled or 0) + 1, math.floor(f.total or 0)), math.floor(f.total or 0), cash < 0 and "-" or "+", math.abs(cash))
    text.draw(font.small, x + 14 * s, ry, 220, 220, 232, 240, stat)
    if (f.streak or 0) >= 2 then
        local st = string.format("STREAK %d", math.floor(f.streak))
        text.draw(font.small, x + w - 14 * s - text.width(font.small, st), ry, ar, ag, ab, 255, st)
    end

    if f.has_front then
        if f.front_vip then
            local vip = "VIP"
            text.draw(big, sw / 2 - text.width(big, vip) / 2, sh * 0.14, 255, 205, 60, 255, vip)
        end
        local hint = "E LET IN     G TURN AWAY"
        text.draw(font.small, sw / 2 - text.width(font.small, hint) / 2, sh * 0.86, 230, 230, 240, 255, hint)
    end

    if f.verdict then
        local v = verdicts[math.floor(f.verdict)] or verdicts[1]
        text.draw(font.title, sw / 2 - text.width(font.title, v[1]) / 2, sh * 0.22, v[2], v[3], v[4], 255, v[1])
        local reason = math.floor(f.verdict_reason or -1)
        if reason >= 0 and (f.verdict == 3 or f.verdict == 2) then
            local rs = reasons[reason + 1] or ""
            text.draw(font.small, sw / 2 - text.width(font.small, rs) / 2, sh * 0.22 + text.height(font.title), 220, 220, 232, 240, rs)
        end
    end
end)
