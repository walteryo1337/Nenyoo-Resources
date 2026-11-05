-- Fitness Tracker. Published fields: active (bool), steps / goal (today's steps and the daily target),
-- walk / run / swim / cycle (metres today per activity), calories (kcal today), streak (days in a row the goal was hit),
-- activity (0 idle, 1 walking, 2 running, 3 swimming, 4 cycling), goal_hit (bool), goal_age (seconds since the goal was hit).
local activity_names = { [0] = "IDLE", "WALKING", "RUNNING", "SWIMMING", "CYCLING" }

local function km(m)
    m = m or 0
    if m >= 1000 then return string.format("%.2f km", m / 1000) end
    return string.format("%d m", math.floor(m))
end

features.on_draw("Fitness Tracker", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local w, h = 210 * s, 96 * s
    local x, y = sw - w - 28 * s, sh - h - 150 * s
    draw.rect(x, y, x + w, y + h, 12, 12, 18, 190, 10 * s)

    local cx, cy, r = x + 46 * s, y + h / 2, 30 * s
    local goal = math.max(1, f.goal or 1)
    local p = math.min(1, (f.steps or 0) / goal)
    draw.circle_outline(cx, cy, r, 255, 255, 255, 40, 5 * s)
    local segs = 48
    local n = math.floor(segs * p)
    local rr, rg, rb = ar, ag, ab
    if f.goal_hit then rr, rg, rb = 90, 220, 110 end
    for i = 0, n - 1 do
        local a0 = -math.pi / 2 + (i / segs) * math.pi * 2
        local a1 = -math.pi / 2 + ((i + 1) / segs) * math.pi * 2
        draw.line(cx + math.cos(a0) * r, cy + math.sin(a0) * r, cx + math.cos(a1) * r, cy + math.sin(a1) * r, rr, rg, rb, 255, 5 * s)
    end
    local pct = string.format("%d%%", math.floor(p * 100))
    text.draw(font.hud_small, cx - text.width(font.hud_small, pct) / 2, cy - text.height(font.hud_small) / 2, 245, 245, 250, 255, pct)

    local tx = x + 90 * s
    local ty = y + 12 * s
    local steps = string.format("%d", math.floor(f.steps or 0))
    text.draw(font.display, tx, ty, 245, 245, 250, 255, steps)
    ty = ty + text.height(font.display)
    text.draw(font.hud_tiny, tx, ty, 190, 190, 205, 230, string.format("/ %d STEPS", math.floor(goal)))
    ty = ty + text.height(font.hud_tiny) + 4 * s
    text.draw(font.hud_tiny, tx, ty, 225, 225, 235, 240, string.format("%d KCAL  %s", math.floor(f.calories or 0), km((f.walk or 0) + (f.run or 0))))
    ty = ty + text.height(font.hud_tiny) + 2 * s
    local act = activity_names[math.floor(f.activity or 0)] or "IDLE"
    local streak = math.floor(f.streak or 0)
    local line = act
    if streak > 0 then line = line .. string.format("   STREAK %d", streak) end
    text.draw(font.hud_tiny, tx, ty, ar, ag, ab, 255, line)

    local age = f.goal_age or 99
    if f.goal_hit and age < 3 then
        local a = math.floor(255 * math.min(1, (3 - age) * 1.5))
        local msg = "GOAL REACHED"
        local big = font.hud
        text.draw(big, x + w / 2 - text.width(big, msg) / 2, y - text.height(big) - 6 * s, 90, 220, 110, a, msg)
    end
end)
