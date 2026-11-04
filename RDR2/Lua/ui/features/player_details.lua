features.on_draw("Player Details", function(f)
    if not __panelkit then return end
    local L, C = str.panel_player(), str.common()
    local function vcol(v)
        if v == C.yes then return 96, 214, 126 end
        if v == C.no then return 128, 134, 150 end
        if v == C.na or v == "-" or v == "" then return 100, 106, 122 end
        return 226, 230, 240
    end
    local sw, shh = ctx.screen_w(), ctx.screen_h()
    local rfont = font.overlay_body or font.small
    local hfont = font.overlay_heading or font.label
    local skin = __panelkit.style
    local ipad = skin.padx
    local rh = math.floor(text.height(rfont) + skin.rgap)
    local th = math.floor(text.height(hfont) + skin.pady * 2)
    local gapx = __panelkit.GUTTER
    local WA, WB, WC = 252, 300, 180
    local W = WA + gapx + WB + gapx + WC
    -- ---- row builders -----------------------------------------------------------------------------
    local function R(t, l, v, c) t[#t + 1] = { "r", l, v, c } end
    local function P(t, l1, v1, l2, v2, c1, c2) t[#t + 1] = { "p", l1, v1, l2, v2, c1, c2 } end
    local function D(t) t[#t + 1] = { "d" } end
    local function rows_h(rows)
        local h = 0
        for _, e in ipairs(rows) do h = h + (e[1] == "d" and 7 or rh) end
        return h
    end

    -- Draw one label/value inside a cell, ellipsising the value against what the label leaves behind.
    local function put(x, w, y, label, value, colr)
        local v = tostring(value == nil and "-" or value)
        text.draw(rfont, x, y, 150, 156, 172, 255, label)
        local lw = text.width(rfont, label)
        local r, g, b
        if colr then r, g, b = colr[1], colr[2], colr[3] else r, g, b = vcol(v) end
        local budget = w - lw - 8
        local vw = text.width(rfont, v)
        if vw > budget then
            text.draw_ellipsis(rfont, x + lw + 8, y, r, g, b, 255, v, budget)
        else
            text.draw(rfont, x + w - vw, y, r, g, b, 255, v)
        end
    end

    -- Compact title band and clipped rows. Each panel measures its own height.
    local function panel(x, y, w, ptitle, rows, extra_h)
        local bodyh = rows_h(rows) + (extra_h or 0)
        local h = th + 3 + bodyh + ipad
        draw.rect(x, y, x + w, y + h, skin.bg_top[1], skin.bg_top[2], skin.bg_top[3], skin.bg_a)
        draw.rect_outline(x, y, x + w, y + h, skin.border[1], skin.border[2], skin.border[3], 255, 0, 1)
        draw.rect(x + 1, y + 1, x + w - 1, y + th, skin.header[1], skin.header[2], skin.header[3], 255)
        text.draw_ellipsis(hfont, x + ipad, y + math.floor((th - text.height(hfont)) / 2),
            232, 236, 246, 255, ptitle, w - ipad * 2)

        local cx, cw = x + ipad, w - ipad * 2
        local half = math.floor((cw - 10) / 2)
        draw.push_clip(x, y + th + 3, x + w, y + h)
        local yy = y + th + 3 + 3
        for _, e in ipairs(rows) do
            if e[1] == "d" then
                draw.rect(cx, yy + 3, cx + cw, yy + 4, skin.border[1], skin.border[2], skin.border[3], 255)
                yy = yy + 7
            elseif e[1] == "p" then
                put(cx, half, yy, e[2], e[3], e[6])
                -- the divider between the two halves is what makes the reference scan cleanly
                draw.rect(cx + half + 5, yy + 1, cx + half + 6, yy + rh - 3, 255, 255, 255, 22)
                if e[4] then put(cx + half + 10, half, yy, e[4], e[5], e[7]) end
                yy = yy + rh
            else
                put(cx, cw, yy, e[2], e[3], e[4])
                yy = yy + rh
            end
        end
        draw.pop_clip()
        return h
    end

    local identity, vitals, details, mount = {}, {}, {}, {}
    local title = f.name or L.title
    R(identity, L.player_slot, f.player)
    if f.valid then
        P(identity, L.gender, f.male and L.male or L.female, L.wanted, f.wanted)
        R(identity, L.hash, string.format("0x%08X", f.model))
        R(identity, L.interior, f.interior == 0 and L.outside or f.interior)
        D(identity)
        P(identity, L.visible, f.visible and C.yes or C.no, L.action,
            ({[0]=L.idle, L.dead, L.ragdoll, L.shooting, L.combat, L.swimming, L.sprinting, L.running, L.walking})[f.action])
        R(vitals, L.health, string.format("%d / %d", f.health, f.maximum))
        R(vitals, L.stamina, string.format("%.0f%%", math.max(0, math.min(1, f.stamina)) * 100))
        D(vitals)
        R(vitals, L.health_core, string.format("%d%%", f.health_core))
        R(vitals, L.stamina_core, string.format("%d%%", f.stamina_core))
        R(vitals, L.deadeye_core, string.format("%d%%", f.deadeye_core))
        R(details, L.transport, ({[0]=L.on_foot, L.horseback, L.in_vehicle})[f.transport])
        P(details, L.distance, string.format("%.0f m", f.distance), L.speed, string.format("%.1f km/h", f.speed * 3.6))
        R(details, L.coords, string.format("%.1f, %.1f, %.1f", f.x, f.y, f.z))
        R(details, L.heading, string.format("%.0f°", f.heading))
        D(details)
        R(details, L.weapon, f.weapon ~= "" and f.weapon or C.na)
        R(details, L.ammo, f.ammo)
        R(details, L.best_weapon, f.best_weapon ~= "" and f.best_weapon or C.na)
        if f.mount_model ~= 0 then
            R(mount, L.hash, string.format("0x%08X", f.mount_model))
            R(mount, L.health, string.format("%d / %d", f.mount_health, f.mount_maximum))
        else
            R(mount, L.status, L.not_mounted)
        end
    else
        R(details, L.status, L.not_streamed)
    end
    local hA = th + 3 + rows_h(identity) + ipad
    local hB = th + 3 + rows_h(vitals) + ipad
    local hC = th + 3 + rows_h(details) + ipad
    local hD = th + 3 + rows_h(mount) + ipad
    local H = math.max(hA + gapx + hB, hC, hD)
    local bx, by, bw = menu.bounds()
    local X0, Y0 = 30, 80
    if bw and bw > 0 then
        if (bx + bw * 0.5) < sw * 0.5 then X0 = bx + bw + 14 else X0 = bx - 14 - W end
        Y0 = by
    end
    X0 = math.max(8, math.min(X0, sw - 8 - W))
    Y0 = math.max(8, math.min(Y0, shh - 8 - H))
    draw.push_clip(8, 8, sw - 8, shh - 8)
    panel(X0, Y0, WA, string.upper(L.identity), identity)
    panel(X0, Y0 + hA + gapx, WA, string.upper(L.vitals), vitals)
    panel(X0 + WA + gapx, Y0, WB, title, details)
    panel(X0 + WA + gapx + WB + gapx, Y0, WC, string.upper(L.mount), mount)
    draw.pop_clip()
end)
