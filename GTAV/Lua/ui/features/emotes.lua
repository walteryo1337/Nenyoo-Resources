-- Emotes. The dance wheel and its messages. Published fields: open (bool, the wheel is showing); slots (slice count,
-- slot 0 at the top, then clockwise; slot 0 is Stop); selected (highlighted slot, missing when the pointer is
-- centred); name0..nameN (slice labels); title (hub text with nothing highlighted); now_playing (tag for the dance
-- playing); hint (help line); dancing (slot of the dance playing, missing when not dancing); toast (message).

-- Animation state survives between frames: the open fade, the pointer angle and each slice's highlight amount.
local anim = { was_open = false, open_t = 0, ang = nil, lit = {} }

local function approach(cur, target, rate, dt)
    return cur + (target - cur) * (1 - math.exp(-rate * dt))
end

-- Shortest signed turn from a to b.
local function turn(a, b)
    return (b - a + math.pi) % (2 * math.pi) - math.pi
end

local function centred(fnt, str, x, y, r, g, b, a)
    text.draw(fnt, x - text.width(fnt, str) / 2, y - text.height(fnt) / 2, r, g, b, a, str)
end

local function pill(cx, y, w, h, s, a)
    draw.rect(cx - w / 2, y, cx + w / 2, y + h, 8, 9, 16, math.floor(215 * a), h / 2)
    draw.rect_outline(cx - w / 2, y, cx + w / 2, y + h, 255, 255, 255, math.floor(22 * a), h / 2, 1 * s)
end

local function draw_toast(f, cx, sh, s, ar, ag, ab)
    local w = text.width(font.hud, f.toast)
    local h = text.height(font.hud) + 22 * s
    local y = sh * 0.11
    local x1 = cx - w / 2 - 34 * s
    pill(cx, y, w + 68 * s, h, s, 1)
    draw.circle(x1 + 18 * s, y + h / 2, 4 * s, ar, ag, ab, 255)
    text.draw(font.hud, x1 + 34 * s, y + 11 * s, 240, 240, 245, 255, f.toast)
end

-- Small stop glyph (rounded square) for the Stop slice.
local function stop_glyph(x, y, s, r, g, b, a)
    local k = 6 * s
    draw.rect(x - k, y - k, x + k, y + k, r, g, b, a, 2.5 * s)
end

features.on_draw("Emotes", function(f)
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx, cy = sw / 2, sh / 2
    local dt = math.min(ctx.delta() or 0.016, 0.1)
    local t = ctx.time() or 0
    local ar, ag, ab = theme.accent()

    if f.toast then draw_toast(f, cx, sh, s, ar, ag, ab) end

    if not f.open then
        anim.was_open = false
        return
    end
    if not anim.was_open then
        anim.was_open, anim.open_t, anim.ang, anim.lit = true, t, nil, {}
    end

    local n = math.max(1, math.floor(f.slots or 5))
    local sel = f.selected and math.floor(f.selected) or -1
    local playing = f.dancing and math.floor(f.dancing) or -1
    local step = 2 * math.pi / n

    -- Open: quick fade and a slight grow from 92%.
    local p = math.min(1, (t - anim.open_t) / 0.18)
    local ease = 1 - (1 - p) ^ 3
    local fa = ease
    local z = (0.92 + 0.08 * ease) * s

    local outer, inner = 252 * z, 112 * z
    local mid = (outer + inner) / 2
    local gap = 7 * z / mid
    local hub = inner - 8 * z

    -- Backdrop: light screen dim plus a soft dark pool behind the wheel.
    draw.rect(0, 0, sw, sh, 0, 0, 0, math.floor(70 * fa))
    for k = 1, 16 do
        draw.circle(cx, cy, outer + 170 * z * (1 - k / 17), 0, 0, 0, math.floor(9 * fa))
    end

    -- Pointer eases toward the highlighted slice along the shortest way round.
    if sel >= 0 then
        local target = -math.pi / 2 + sel * step
        anim.ang = anim.ang and (anim.ang + turn(anim.ang, target) * (1 - math.exp(-22 * dt))) or target
    end

    for i = 0, n - 1 do
        local c = -math.pi / 2 + i * step
        local a0, a1 = c - step / 2 + gap / 2, c + step / 2 - gap / 2
        local h = approach(anim.lit[i] or 0, i == sel and 1 or 0, 20, dt)
        anim.lit[i] = h
        local is_stop = i == 0
        local is_playing = i == playing
        -- Stop lights red so it reads as the end action; dances use the theme accent.
        local hr, hg, hb = ar, ag, ab
        if is_stop then hr, hg, hb = 235, 70, 80 end

        local ro = outer + 14 * z * h
        draw.ring(cx, cy, inner, ro, a0, a1, 10, 12, 20, math.floor(205 * fa))
        if h > 0.01 then
            draw.ring(cx, cy, inner, ro, a0, a1, hr, hg, hb, math.floor(150 * h * fa))
            draw.ring(cx, cy, ro - 5 * z, ro, a0, a1, 255, 255, 255, math.floor(140 * h * fa))
        end
        draw.arc(cx, cy, ro - 0.5 * z, a0, a1, 255, 255, 255, math.floor((28 + 40 * h) * fa), 1 * s)

        if is_playing then
            local pulse = 0.55 + 0.45 * math.abs(math.sin(t * 3))
            draw.ring(cx, cy, inner, inner + 4 * z, a0, a1, ar, ag, ab, math.floor(255 * pulse * fa))
        end

        -- Label sits on the slice's centre line, pushed out a little as the slice grows.
        local lr = mid + 7 * z * h
        local lx, ly = cx + math.cos(c) * lr, cy + math.sin(c) * lr
        local label = f["name" .. i] or ""
        local v = math.floor(190 + 65 * h)
        local la = math.floor(255 * fa)
        local th = text.height(font.hud)
        if is_stop then
            stop_glyph(lx, ly - th * 0.75, s, v, v, v, la)
            centred(font.hud, label, lx, ly + th * 0.45, v, v, v, la)
        elseif is_playing and f.now_playing then
            centred(font.hud, label, lx, ly - th * 0.35, v, v, v, la)
            -- Accent on the dark slice, near-white once the slice itself is lit with the accent.
            local tr, tg, tb = ar + (255 - ar) * h, ag + (255 - ag) * h, ab + (255 - ab) * h
            centred(font.hud_tiny, f.now_playing, lx, ly + th * 0.75, math.floor(tr), math.floor(tg), math.floor(tb), la)
        else
            centred(font.hud, label, lx, ly, v, v, v, la)
        end
    end

    -- Hub: dark disc, thin rim, and a bright notch on the rim facing the highlighted slice.
    draw.circle(cx, cy, hub, 7, 8, 14, math.floor(240 * fa))
    draw.circle_outline(cx, cy, hub, 255, 255, 255, math.floor(26 * fa), 1 * s)
    if sel >= 0 and anim.ang then
        local hr, hg, hb = ar, ag, ab
        if sel == 0 then hr, hg, hb = 235, 70, 80 end
        draw.arc(cx, cy, hub - 2 * z, anim.ang - 0.32, anim.ang + 0.32, hr, hg, hb, math.floor(255 * fa), 3.5 * s)
    end

    -- One size for every name so the hub text does not jump as the pointer moves between slices.
    local name = sel >= 0 and (f["name" .. sel] or "") or (f.title or "Emotes")
    local ih = text.height(font.hud)
    local ny = cy
    if sel >= 0 and sel == playing and f.now_playing then
        ny = cy - ih * 0.45
        centred(font.hud_tiny, f.now_playing, cx, cy + ih * 0.75, ar, ag, ab, math.floor(255 * fa))
    end
    text.draw_scaled(font.hud, cx - text.width(font.hud, name) / 2, ny - ih / 2, 255, 255, 255, math.floor(255 * fa),
        1.35, name)

    if f.hint then
        local w = text.width(font.hud_small, f.hint) + 36 * s
        local h = text.height(font.hud_small) + 16 * s
        local y = cy + outer + 34 * z
        pill(cx, y, w, h, s, fa)
        centred(font.hud_small, f.hint, cx, y + h / 2, 225, 225, 232, math.floor(240 * fa))
    end
end)
