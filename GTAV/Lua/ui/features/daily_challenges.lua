-- Daily Challenges. Published while the panel should show (new day, progress milestones, completions):
-- active (bool), and for n = 1..3: label_n (string), value_n, target_n, reward_n, done_n (bool).
local shown = 0
local rows = {}

local function fmt(v, target)
    if target < 20 and math.floor(target) ~= target then return string.format("%.1f / %.1f", v, target) end
    if target < 20 then return string.format("%.1f / %d", v, math.floor(target)) end
    return string.format("%d / %d", math.floor(v), math.floor(target))
end

features.on_draw("Daily Challenges", function(f)
    local dt = ctx.delta and ctx.delta() or 0.016
    if f.active then
        shown = math.min(1, shown + dt * 5)
        for i = 1, 3 do
            rows[i] = {
                label = f["label_" .. i] or "",
                value = f["value_" .. i] or 0,
                target = math.max(0.001, f["target_" .. i] or 1),
                reward = math.floor(f["reward_" .. i] or 0),
                done = f["done_" .. i] and true or false,
            }
        end
    else
        shown = math.max(0, shown - dt * 3)
    end
    if shown <= 0 or #rows == 0 then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local a = shown
    local pad = 10 * s
    local w = 300 * s
    local th = text.height(font.hud_tiny)
    local row_h = th * 2 + 10 * s
    local h = th + pad * 2 + row_h * 3
    local x = sw - w - 28 * s + (1 - shown) * 40 * s
    local y = sh * 0.16

    draw.rect(x, y, x + w, y + h, 10, 10, 16, math.floor(165 * a), 6 * s)
    draw.rect(x, y, x + 3 * s, y + h, ar, ag, ab, math.floor(255 * a), 0)
    text.draw(font.hud_tiny, x + pad, y + pad, ar, ag, ab, math.floor(255 * a), "DAILY CHALLENGES")

    local cy = y + pad + th + 6 * s
    for i = 1, 3 do
        local r = rows[i]
        local cr, cg, cb = 240, 240, 245
        if r.done then cr, cg, cb = 120, 220, 140 end
        text.draw(font.hud_tiny, x + pad, cy, cr, cg, cb, math.floor(255 * a), r.label)
        local pay = r.done and "DONE" or string.format("$%d", r.reward)
        text.draw(font.hud_tiny, x + w - pad - text.width(font.hud_tiny, pay), cy, cr, cg, cb, math.floor(230 * a), pay)
        local by = cy + th + 3 * s
        local bw = w - pad * 2 - 90 * s
        local p = math.min(1, r.value / r.target)
        draw.rect(x + pad, by + th * 0.35, x + pad + bw, by + th * 0.35 + 4 * s, 0, 0, 0, math.floor(160 * a), 0)
        draw.rect(x + pad, by + th * 0.35, x + pad + bw * p, by + th * 0.35 + 4 * s, r.done and 120 or ar, r.done and 220 or ag, r.done and 140 or ab, math.floor(255 * a), 0)
        local nums = fmt(r.value, r.target)
        text.draw(font.hud_tiny, x + w - pad - text.width(font.hud_tiny, nums), by, 190, 190, 200, math.floor(220 * a), nums)
        cy = cy + row_h
    end
end)
