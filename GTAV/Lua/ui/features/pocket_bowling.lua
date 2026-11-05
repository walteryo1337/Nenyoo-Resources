-- Pocket Bowling. Published fields: active (bool), state (1 aim, 2 hook meter, 3 power meter, 4 rolling, 5 pins
-- settling, 6 game over), frame (0-based), total (score so far), best (best game this session), aim (ball lane x,
-- -0.5..0.5), spin (0..1, 0.5 = straight), power (0..1), ball_x / ball_y / ball_live (ball in lane units),
-- lane_length (lane units), pins (blob "x,y,live;" per pin), rolls (blob "pins;" per ball), frames (blob
-- "total;" per frame, -1 = not scored yet).
local function split(blob)
    local out = {}
    for item in string.gmatch(blob or "", "([^;]+)") do out[#out + 1] = item end
    return out
end

local function frame_marks(rolls)
    local marks, r = {}, 1
    for fi = 1, 10 do
        local m = {}
        if fi < 10 then
            local a = rolls[r]
            if a == nil then
            elseif a == 10 then
                m[2] = "X"; r = r + 1
            else
                m[1] = a == 0 and "-" or tostring(a)
                local b = rolls[r + 1]
                if b ~= nil then m[2] = (a + b == 10) and "/" or (b == 0 and "-" or tostring(b)) end
                r = r + 2
            end
        else
            local prev = nil
            for k = 0, 2 do
                local v = rolls[r + k]
                if v == nil then break end
                if prev == nil and v == 10 then m[k + 1] = "X"; prev = nil
                elseif prev ~= nil and prev + v == 10 then m[k + 1] = "/"; prev = nil
                else
                    m[k + 1] = v == 0 and "-" or tostring(v)
                    if prev == nil then prev = v else prev = nil end
                end
            end
        end
        marks[fi] = m
    end
    return marks
end

local function meter(x, y, w, h, s, value, label, centred, ar, ag, ab)
    draw.rect(x, y, x + w, y + h, 30, 30, 42, 255, 4 * s)
    if centred then
        draw.rect(x + w / 2 - 1 * s, y - 3 * s, x + w / 2 + 1 * s, y + h + 3 * s, 200, 200, 214, 200)
        local mx = x + w * value
        draw.rect(mx - 3 * s, y - 4 * s, mx + 3 * s, y + h + 4 * s, ar, ag, ab, 255, 2 * s)
    else
        draw.rect_gradient(x, y, x + w * value, y + h, 90, 200, 110, 255, 240, 200, 60, 255, 240, 200, 60, 255, 90, 200, 110, 255)
    end
    text.draw(font.hud_tiny, x, y - 18 * s, 200, 200, 214, 230, label)
end

features.on_draw("Pocket Bowling", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local state = math.floor(f.state or 0)
    local ar, ag, ab = theme.accent()
    ar, ag, ab = ar or 90, ag or 200, ab or 255

    local pw, ph = 760 * s, 720 * s
    local x0, y0 = sw / 2 - pw / 2, sh / 2 - ph / 2
    draw.rect(x0, y0, x0 + pw, y0 + ph, 10, 10, 16, 225, 14 * s)
    text.draw(font.hud_small, x0 + 18 * s, y0 + 12 * s, 235, 235, 245, 255, "POCKET BOWLING")

    local lane_len = f.lane_length or 6
    local lx_scale, ly_scale = 230 * s, (ph - 110 * s) / (lane_len + 0.4)
    local lane_cx = x0 + 40 * s + 0.6 * lx_scale
    local lane_bottom = y0 + ph - 30 * s
    local function to_screen(x, y) return lane_cx + x * lx_scale, lane_bottom - y * ly_scale end

    local gl, gt = to_screen(-0.6, lane_len + 0.3)
    local gr, gb = to_screen(0.6, 0)
    draw.rect(gl, gt, gr, gb, 40, 40, 48, 255, 4 * s)
    local ll, lt = to_screen(-0.5, lane_len + 0.3)
    local lr, lb = to_screen(0.5, 0)
    draw.rect_gradient(ll, lt, lr, lb, 150, 110, 70, 255, 150, 110, 70, 255, 205, 160, 105, 255, 205, 160, 105, 255)
    for i = 1, 4 do
        local bx = ll + (lr - ll) * i / 5
        draw.line(bx, lt, bx, lb, 120, 85, 55, 120, 1 * s)
    end
    local _, foul_y = to_screen(0, 0.5)
    draw.line(ll, foul_y, lr, foul_y, 200, 40, 40, 220, 2 * s)
    for i = -2, 2 do
        local ax, ay = to_screen(i * 0.12, 1.8 + math.abs(i) * 0.15)
        draw.line(ax - 4 * s, ay + 6 * s, ax, ay, 80, 50, 30, 220, 2 * s)
        draw.line(ax, ay, ax + 4 * s, ay + 6 * s, 80, 50, 30, 220, 2 * s)
    end

    local pin_r = 0.04 * lx_scale
    for _, p in ipairs(split(f.pins)) do
        local px, py, live = string.match(p, "([^,]+),([^,]+),([^,]+)")
        px, py = tonumber(px) or 0, tonumber(py) or 0
        local sx, sy = to_screen(px, py)
        if live == "1" then
            draw.circle(sx + 1.5 * s, sy + 2 * s, pin_r, 0, 0, 0, 90)
            draw.circle(sx, sy, pin_r, 245, 245, 245, 255)
            draw.circle_outline(sx, sy, pin_r * 0.55, 210, 40, 40, 255, 1.5 * s)
        end
    end

    if f.ball_live then
        local bx, by = to_screen(f.ball_x or 0, f.ball_y or 0)
        local br = 0.07 * lx_scale
        draw.circle(bx + 2 * s, by + 3 * s, br, 0, 0, 0, 110)
        draw.circle(bx, by, br, ar, ag, ab, 255)
        draw.circle(bx - br * 0.3, by - br * 0.3, br * 0.18, 20, 20, 30, 230)
        draw.circle(bx + br * 0.25, by - br * 0.35, br * 0.15, 20, 20, 30, 230)
        if state == 1 then
            local _, ty = to_screen(0, lane_len - 1.2)
            draw.line(bx, by, bx, ty, 255, 255, 255, 60, 1 * s)
        end
    end

    local rx = x0 + 40 * s + 1.2 * lx_scale + 30 * s
    local rw = x0 + pw - 18 * s - rx
    local rolls = {}
    for _, v in ipairs(split(f.rolls)) do rolls[#rolls + 1] = tonumber(v) or 0 end
    local marks = frame_marks(rolls)
    local totals = split(f.frames)
    local cur = math.floor(f.frame or 0) + 1
    local cell_h = 46 * s
    local sy = y0 + 46 * s
    for fi = 1, 10 do
        local cy = sy + (fi - 1) * (cell_h + 4 * s)
        local hl = fi == cur and state ~= 6
        draw.rect(rx, cy, rx + rw, cy + cell_h, hl and 45 or 26, hl and 45 or 26, hl and 62 or 36, 255, 6 * s)
        if hl then draw.rect_outline(rx, cy, rx + rw, cy + cell_h, ar, ag, ab, 255, 6 * s, 1.5 * s) end
        text.draw(font.hud_tiny, rx + 10 * s, cy + 14 * s, 160, 160, 176, 255, tostring(fi))
        local m = marks[fi]
        local box = 24 * s
        local slots = fi == 10 and 3 or 2
        for k = 1, slots do
            local bx = rx + rw - (slots - k + 1) * (box + 4 * s) - 6 * s
            draw.rect_outline(bx, cy + 4 * s, bx + box, cy + 4 * s + box, 70, 70, 86, 255, 3 * s, 1 * s)
            local mk = m[k]
            if mk then
                local cr, cg, cb = 235, 235, 245
                if mk == "X" or mk == "/" then cr, cg, cb = ar, ag, ab end
                text.draw(font.hud_tiny, bx + box / 2 - text.width(font.hud_tiny, mk) / 2, cy + 7 * s, cr, cg, cb, 255, mk)
            end
        end
        local tv = tonumber(totals[fi] or "-1") or -1
        if tv >= 0 then
            text.draw(font.hud_small, rx + 40 * s, cy + 12 * s, 235, 235, 245, 255, tostring(tv))
        end
    end

    local info_y = sy + 10 * (cell_h + 4 * s) + 8 * s
    local hint = ""
    if state == 1 then hint = "A / D  SLIDE   -   SPACE  LOCK"
    elseif state == 2 then hint = "SPACE  LOCK HOOK"
    elseif state == 3 then hint = "SPACE  LOCK POWER"
    elseif state == 4 or state == 5 then hint = "ROLLING..."
    elseif state == 6 then hint = string.format("FINAL %d   -   SPACE  NEW GAME", math.floor(f.total or 0)) end

    if state == 2 or state == 3 then
        meter(rx, info_y + 22 * s, rw, 12 * s, s, f.spin or 0.5, "HOOK", true, ar, ag, ab)
    end
    if state == 3 then
        meter(rx, info_y + 64 * s, rw, 12 * s, s, f.power or 0, "POWER", false, ar, ag, ab)
    end
    local best = math.floor(f.best or 0)
    local summary = best > 0 and string.format("SCORE %d   BEST %d", math.floor(f.total or 0), best) or string.format("SCORE %d", math.floor(f.total or 0))
    text.draw(font.hud_small, x0 + pw - 18 * s - text.width(font.hud_small, summary), y0 + 12 * s, 235, 235, 245, 255, summary)
    if hint ~= "" then
        text.draw(font.hud_tiny, x0 + pw / 2 - text.width(font.hud_tiny, hint) / 2, y0 + ph - 8 * s - text.height(font.hud_tiny), 200, 200, 214, 230, hint)
    end
end)
