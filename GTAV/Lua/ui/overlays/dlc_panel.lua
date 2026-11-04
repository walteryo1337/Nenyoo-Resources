-- Custom DLC side panel. On a pack's page it leads with that pack (type, which game version it is for,
-- whether it was converted from Legacy, whether it is loaded, auto-load); everywhere else in Custom DLC it
-- shows what the inbox is doing, the library at a glance and how to install mods. Laid out once as a list
-- of draw ops so the height is known before the panel is placed next to the menu.
local DLC_PAGES = {
    [0x09272D6A] = true,
    [0x75022233] = true,
    [0xDD98E9C5] = true,
    [0x67D5C10C] = true,
    [0xA58BEE9F] = true,
    [0x0473EABE] = true,
    [0x801AC191] = true,
}

local TYPE_STYLE = {
    ped      = { key = "peds",      c = { 164, 112, 226 } },
    vehicle  = { key = "vehicles",  c = { 58, 186, 118 } },
    weapon   = { key = "weapons",   c = { 214, 84, 84 } },
    prop     = { key = "maps",      c = { 80, 150, 230 } },
    override = { key = "overrides", c = { 226, 152, 52 } },
    sound    = { key = "sounds",    c = { 60, 190, 200 } },
    anim     = { key = "anims",     c = { 230, 110, 170 } },
}
local BREAKDOWN = { "ped", "vehicle", "weapon", "prop", "anim", "override", "sound" }
local COUNT_KEY = { ped = "peds", vehicle = "vehicles", weapon = "weapons", prop = "props", override = "overrides", sound = "sounds" }

-- Tones: foreground + tinted background.
local GOOD    = { fg = { 111, 224, 163 }, bg = { 23, 61, 42 } }
local WARN    = { fg = { 255, 196, 110 }, bg = { 70, 48, 15 } }
local BAD     = { fg = { 255, 150, 150 }, bg = { 70, 24, 28 } }
local NEUTRAL = { fg = { 190, 190, 200 }, bg = { 44, 43, 54 } }
local CARD    = { 26, 25, 34 }

local function wrap(fnt, value, max_width)
    local lines = {}
    local line = ""
    for word in tostring(value or ""):gmatch("%S+") do
        local candidate = line == "" and word or line .. " " .. word
        if line ~= "" and text.width(fnt, candidate) > max_width then
            lines[#lines + 1] = line
            line = word
        else
            line = candidate
        end
    end
    if line ~= "" then lines[#lines + 1] = line end
    return lines
end

local function pill(ops, x, y, label, bg, fg)
    local w = text.width(font.tiny, label) + 16
    local h = text.height(font.tiny) + 8
    ops[#ops + 1] = function(ox, oy)
        draw.rect(ox + x, oy + y, ox + x + w, oy + y + h, bg[1], bg[2], bg[3], 255, h * 0.5)
        text.draw(font.tiny, ox + x + 8, oy + y + 4, fg[1], fg[2], fg[3], 255, label)
    end
    return w, h
end

local function ago_text(L, s)
    s = math.floor(s or 0)
    if s < 60 then return L.just_now or "" end
    if s < 3600 then return tostring(math.floor(s / 60)) .. " " .. (L.min_ago or "") end
    return tostring(math.floor(s / 3600)) .. " " .. (L.h_ago or "")
end

-- Player-facing sentence + tone for the latest install round's problem.
local function problem_info(L, key, enh)
    if key == "failed" then return L.p_failed, BAD end
    if key == "several_packs" then return L.p_several, BAD end
    if key == "other_only" then return enh and L.p_other_only_enh or L.p_other_only_leg, BAD end
    if key == "encrypted" then return L.p_encrypted, WARN end
    if key == "unconvertible" or key == "convert_failed" then return L.p_unconvertible, WARN end
    if key == "other_edition" then return enh and L.p_unconvertible or L.p_other_edition, WARN end
    return nil, nil
end

overlay.on_draw("dlc_panel", function()
    if not menu.is_visible() or not DLC_PAGES[menu.page_id()] then return end
    if __gta5mods_panel_frame == ctx.frame() then return end   -- the GTA5-Mods browser preview owns the side this frame
    local data = dlc.info()
    if not data then return end
    local pack = dlc.pack and dlc.pack() or nil

    local L = str.panel_dlc()
    local ar, ag, ab = theme.accent()
    local fi, fs, ft = font.item, font.small, font.tiny
    local hi, hs, ht = text.height(fi), text.height(fs), text.height(ft)
    local enh = data.edition == "Enhanced"
    local now = ctx.time and ctx.time() or 0
    local pulse = 0.55 + 0.45 * math.sin(now * 5)

    local width = 370
    local pad = 16
    local inner = width - pad * 2
    local title_h = 40
    local ops = {}
    local y = title_h + 14

    local function section(label)
        local yy = y
        ops[#ops + 1] = function(ox, oy)
            text.draw(ft, ox + pad, oy + yy, ar, ag, ab, 255, string.upper(label or ""))
            local lw = text.width(ft, string.upper(label or "")) + 10
            draw.rect(ox + pad + lw, oy + yy + ht * 0.5, ox + pad + inner, oy + yy + ht * 0.5 + 1, ar, ag, ab, 40)
        end
        y = y + ht + 10
    end

    -- Tinted note box with an accent bar; optional bold first line.
    local function note_box(title, body, tone)
        local lines = wrap(fs, body, inner - 26)
        local th_ = title and (hs + 4) or 0
        local nh = th_ + #lines * (hs + 3) + 16
        local ny = y
        ops[#ops + 1] = function(ox, oy)
            local fg, bg = tone.fg, tone.bg
            draw.rect(ox + pad, oy + ny, ox + pad + inner, oy + ny + nh, bg[1], bg[2], bg[3], 210, 6)
            draw.rect(ox + pad, oy + ny, ox + pad + 3, oy + ny + nh, fg[1], fg[2], fg[3], 255, 1)
            if title then text.draw(fs, ox + pad + 14, oy + ny + 8, fg[1], fg[2], fg[3], 255, title) end
            for i, line in ipairs(lines) do
                text.draw(fs, ox + pad + 14, oy + ny + 8 + th_ + (i - 1) * (hs + 3), 235, 235, 240, 235, line)
            end
        end
        y = y + nh + 10
    end

    local function kv(label, value, vc)
        local yy = y
        ops[#ops + 1] = function(ox, oy)
            text.draw(fs, ox + pad, oy + yy, 255, 255, 255, 140, label or "")
            local v = tostring(value or "")
            text.draw(fs, ox + width - pad - text.width(fs, v), oy + yy, vc[1], vc[2], vc[3], 255, v)
        end
        y = y + hs + 8
    end

    -- ---- this pack ----
    if pack then
        section(L.this_pack)
        for _, line in ipairs(wrap(fi, pack.name, inner)) do
            local yy = y
            ops[#ops + 1] = function(ox, oy) text.draw(fi, ox + pad, oy + yy, 245, 245, 250, 255, line) end
            y = y + hi + 2
        end
        y = y + 6

        local ts = TYPE_STYLE[pack.type]
        local px = pad
        local ph = 0
        if ts then
            local c = ts.c
            local w, h = pill(ops, px, y, string.upper(L[ts.key] or ""), { c[1] * 0.28, c[2] * 0.28, c[3] * 0.28 }, c)
            px, ph = px + w + 6, h
        end
        local ed_label = pack.edition == "legacy" and L.legacy or (pack.edition == "enhanced" and L.enhanced or L.unknown)
        local good = pack.runs and pack.edition ~= "unknown"
        local tone = good and GOOD or (pack.runs and NEUTRAL or WARN)
        local w2, h2 = pill(ops, px, y, string.upper(ed_label or ""), tone.bg, tone.fg)
        px = px + w2 + 6
        ph = math.max(ph, h2)
        if pack.converted then
            local _, h3 = pill(ops, px, y, string.upper(L.conv_pill or ""), GOOD.bg, GOOD.fg)
            ph = math.max(ph, h3)
        end
        y = y + ph + 10

        -- Which version it is for: green runs here, amber made for the other version, grey unknown.
        note_box(nil, pack.converted and L.conv_note or pack.note, tone)

        if (pack.entries or 0) > 0 and (pack.type == "ped" or pack.type == "vehicle" or pack.type == "weapon") then
            kv(L.models, pack.entries, { 245, 245, 248 })
        end
        if pack.loaded ~= nil then
            kv(L.status, pack.loaded and L.loaded or L.not_loaded, pack.loaded and GOOD.fg or NEUTRAL.fg)
        end
        kv(L.autoload, pack.enabled and L.yes or L.no, pack.enabled and GOOD.fg or { 160, 160, 170 })
        y = y + 8
    end

    -- ---- activity: what the inbox is doing, and how the latest install went ----
    local last = data.last
    local busy = data.unpacking or (data.pending or 0) > 0
    if not pack and (busy or last) then
        section(L.activity)
        local cy = y
        local inner_ops = {}
        local yy = 12

        if busy then
            local label = data.unpacking and L.unpacking or L.pending
            local n = (not data.unpacking) and tostring(math.floor(data.pending or 0)) or nil
            local ry = yy
            inner_ops[#inner_ops + 1] = function(x0, y0)
                draw.circle(x0 + 16, y0 + ry + hs * 0.5, 4, ar, ag, ab, math.floor(255 * pulse))
                text.draw(fs, x0 + 28, y0 + ry, 245, 245, 248, 255, label or "")
                if n then text.draw(fs, x0 + inner - 12 - text.width(fs, n), y0 + ry, ar, ag, ab, 255, n) end
            end
            yy = yy + hs + 10
        end

        if last then
            local ry = yy
            local when = ago_text(L, last.ago)
            inner_ops[#inner_ops + 1] = function(x0, y0)
                text.draw(ft, x0 + 12, y0 + ry + 1, 255, 255, 255, 130, string.upper(L.last_install or ""))
                text.draw(ft, x0 + inner - 12 - text.width(ft, when), y0 + ry + 1, 255, 255, 255, 130, when)
            end
            yy = yy + ht + 6
            if last.name then
                local ny = yy
                inner_ops[#inner_ops + 1] = function(x0, y0)
                    text.draw_ellipsis(fi, x0 + 12, y0 + ny, 245, 245, 250, 255, last.name, inner - 24)
                end
                yy = yy + hi + 6
            end

            -- Count chips, only the ones that happened.
            local chips = {}
            local function chip(n, label, tone)
                if (n or 0) > 0 then chips[#chips + 1] = { tostring(math.floor(n)) .. " " .. (label or ""), tone } end
            end
            chip(last.installed, L.c_installed, NEUTRAL)
            chip(last.converted, L.c_converted, GOOD)
            chip(last.other, L.c_other, WARN)
            chip(last.skipped, L.c_skipped, BAD)
            if #chips > 0 then
                local cx = 12
                local chh = ht + 8
                for _, c in ipairs(chips) do
                    local cw = text.width(ft, c[1]) + 16
                    if cx > 12 and cx + cw > inner - 12 then cx = 12; yy = yy + chh + 6 end
                    local px_, py_ = cx, yy
                    inner_ops[#inner_ops + 1] = function(x0, y0)
                        local fg, bg = c[2].fg, c[2].bg
                        draw.rect(x0 + px_, y0 + py_, x0 + px_ + cw, y0 + py_ + chh, bg[1], bg[2], bg[3], 255, chh * 0.5)
                        text.draw(ft, x0 + px_ + 8, y0 + py_ + 4, fg[1], fg[2], fg[3], 255, c[1])
                    end
                    cx = cx + cw + 6
                end
                yy = yy + chh + 8
            end

            local msg, tone = problem_info(L, last.problem, enh)
            if msg then
                -- Name the drop, unless it is the pack already shown above.
                local pn = last.problem_name
                local head = pn and pn ~= "" and pn ~= last.name and pn or nil
                local lines = wrap(fs, msg, inner - 36)
                local by = yy
                local hh = head and (hs + 3) or 0
                inner_ops[#inner_ops + 1] = function(x0, y0)
                    draw.rect(x0 + 12, y0 + by + 1, x0 + 14, y0 + by + hh + #lines * (hs + 3) - 2, tone.fg[1], tone.fg[2], tone.fg[3], 255, 1)
                    if head then text.draw_ellipsis(fs, x0 + 22, y0 + by, tone.fg[1], tone.fg[2], tone.fg[3], 255, head, inner - 36) end
                    for i, line in ipairs(lines) do
                        text.draw(fs, x0 + 22, y0 + by + hh + (i - 1) * (hs + 3), 235, 235, 240, 225, line)
                    end
                end
                yy = yy + hh + #lines * (hs + 3) + 6
            end
        end

        local ch = yy + 6
        ops[#ops + 1] = function(ox, oy)
            local x0, y0 = ox + pad, oy + cy
            draw.rect(x0, y0, x0 + inner, y0 + ch, CARD[1], CARD[2], CARD[3], 255, 6)
            for _, op in ipairs(inner_ops) do op(x0, y0) end
        end
        y = y + ch + 14
    end

    -- ---- library: three tiles, load state, then the per-type breakdown ----
    section(L.library)
    local packs, enabled, loaded = data.packs or 0, data.enabled or 0, data.mounted or 0
    local tiles = {
        { L.installed, packs },
        { L.on, enabled },
        { L.loaded, loaded, true },
    }
    local tg = 8
    local tw = (inner - tg * 2) / 3
    local th = hi + ht + 24
    local ty = y
    ops[#ops + 1] = function(ox, oy)
        for i, t in ipairs(tiles) do
            local x0 = ox + pad + (i - 1) * (tw + tg)
            draw.rect(x0, oy + ty, x0 + tw, oy + ty + th, CARD[1], CARD[2], CARD[3], 255, 6)
            local v = tostring(math.floor(t[2]))
            text.draw(fi, x0 + 12, oy + ty + 8, 250, 250, 252, 255, v)
            text.draw_ellipsis(ft, x0 + 12, oy + ty + 12 + hi, 255, 255, 255, 130, t[1] or "", tw - 20)
            if t[3] and enabled > 0 then
                -- Loaded out of enabled, as a thin bar along the bottom of the tile.
                local frac = math.max(0, math.min(1, loaded / enabled))
                local bx0, bx1, by0 = x0 + 10, x0 + tw - 10, oy + ty + th - 6
                draw.rect(bx0, by0, bx1, by0 + 2, 255, 255, 255, 30, 1)
                if frac > 0 then draw.rect(bx0, by0, bx0 + (bx1 - bx0) * frac, by0 + 2, ar, ag, ab, 255, 1) end
            end
        end
    end
    y = y + th + 10

    local waiting = math.floor(data.waiting or 0)
    if waiting > 0 then
        local yy = y
        if data.autoloading then
            ops[#ops + 1] = function(ox, oy)
                draw.circle(ox + pad + 4, oy + yy + hs * 0.5, 3.5, ar, ag, ab, math.floor(255 * pulse))
                text.draw(fs, ox + pad + 14, oy + yy, 245, 245, 248, 230, L.loading_now or "")
            end
            y = y + hs + 10
        else
            local v = tostring(waiting)
            local hint = wrap(ft, L.waiting_hint, inner - 14)
            ops[#ops + 1] = function(ox, oy)
                draw.circle(ox + pad + 4, oy + yy + hs * 0.5, 3.5, WARN.fg[1], WARN.fg[2], WARN.fg[3], 255)
                text.draw(fs, ox + pad + 14, oy + yy, 255, 255, 255, 200, L.not_loaded or "")
                text.draw(fs, ox + width - pad - text.width(fs, v), oy + yy, WARN.fg[1], WARN.fg[2], WARN.fg[3], 255, v)
                for i, line in ipairs(hint) do
                    text.draw(ft, ox + pad + 14, oy + yy + hs + 3 + (i - 1) * (ht + 2), 255, 255, 255, 120, line)
                end
            end
            y = y + hs + 3 + #hint * (ht + 2) + 10
        end
    end

    local cw2 = (inner - 16) / 2
    for i, k in ipairs(BREAKDOWN) do
        local col = (i - 1) % 2
        local yy = y
        local by = data.packs_by_type
        local n = math.floor((by and by[k]) or data[COUNT_KEY[k]] or 0)
        local c = TYPE_STYLE[k].c
        local label = L[TYPE_STYLE[k].key] or ""
        ops[#ops + 1] = function(ox, oy)
            local x0 = ox + pad + col * (cw2 + 16)
            local a = n > 0 and 255 or 110
            draw.circle(x0 + 4, oy + yy + hs * 0.5, 3.5, c[1], c[2], c[3], a)
            text.draw(fs, x0 + 14, oy + yy, 255, 255, 255, n > 0 and 200 or 100, label)
            local v = tostring(n)
            text.draw(fs, x0 + cw2 - text.width(fs, v), oy + yy, 245, 245, 248, n > 0 and 255 or 100, v)
        end
        if col == 1 then y = y + hs + 8 end
    end
    if #BREAKDOWN % 2 == 1 then y = y + hs + 8 end
    if enh and (data.converted or 0) > 0 then
        y = y + 2
        kv(L.converted, math.floor(data.converted), GOOD.fg)
    end
    y = y + 6

    -- ---- how to install (not on a pack page) ----
    if not pack then
        y = y + 4
        section(L.how_to)
        local steps = {}
        for _, step in ipairs({ L.step1, L.step2, L.step3, L.step4 }) do
            if step and step ~= "" then steps[#steps + 1] = step end
        end
        local r = 9
        local tx = pad + r * 2 + 10
        local rows = {}
        for _, step in ipairs(steps) do
            local lines = wrap(fs, step, inner - (tx - pad))
            rows[#rows + 1] = { y = y, lines = lines }
            y = y + math.max(#lines, 1) * (hs + 3) + 9
        end
        ops[#ops + 1] = function(ox, oy)
            for i, row in ipairs(rows) do
                local cx_, cy_ = ox + pad + r, oy + row.y + hs * 0.5
                local nxt = rows[i + 1]
                if nxt then
                    -- Thin rail joining this step's marker to the next one.
                    draw.rect(cx_ - 0.75, cy_ + r + 2, cx_ + 0.75, oy + nxt.y + hs * 0.5 - r - 2, ar, ag, ab, 70)
                end
                draw.circle(cx_, cy_, r, ar, ag, ab, 70)
                draw.circle_outline(cx_, cy_, r, ar, ag, ab, 200, 1.2)
                local num = tostring(i)
                text.draw(ft, cx_ - text.width(ft, num) * 0.5, cy_ - ht * 0.5, 255, 255, 255, 255, num)
                for j, line in ipairs(row.lines) do
                    text.draw(fs, ox + tx, oy + row.y + (j - 1) * (hs + 3), 232, 232, 238, 230, line)
                end
            end
        end
        y = y + 2

        -- What happens to mods made for the other game version.
        local cb = enh and L.conv_body_enh or L.conv_body_leg
        if cb and cb ~= "" then
            note_box(enh and L.conv_title_enh or L.conv_title_leg, cb, enh and GOOD or NEUTRAL)
        end
    end

    if data.disabled then
        y = y + 4
        note_box(nil, L.disabled, BAD)
    end
    local height = y + pad - 10

    -- ---- place next to the menu ----
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local bx, by, bw = menu.bounds()
    local gap = 12
    local x, top = bx and bw and (bx + bw + gap) or 0, by or 80
    if not bw or bw <= 0 then x, top = sw - width - 24, 80 end
    if x + width > sw - 8 then x = bx - gap - width end
    if x < 8 then x = 8 end
    if top < 8 then top = 8 elseif top + height > sh - 8 then top = sh - 8 - height end

    draw.rect(x, top, x + width, top + height, 13, 13, 18, 244, 10)
    draw.rect(x, top, x + width, top + title_h, ar, ag, ab, 255, 10)
    draw.rect(x, top + title_h - 10, x + width, top + title_h, ar, ag, ab, 255)
    draw.rect_gradient(x, top, x + width, top + title_h,
        255, 255, 255, 42, 255, 255, 255, 42, 255, 255, 255, 0, 255, 255, 255, 0)
    draw.rect_outline(x, top, x + width, top + height, ar, ag, ab, 120, 10)
    text.draw(fi, x + pad, top + (title_h - hi) * 0.5, 255, 255, 255, 255, string.upper(L.title or ""))

    -- Running game version, top right of the header.
    local run = enh and L.enhanced or L.legacy
    if run and run ~= "" then
        local rl = string.upper(run)
        local rw = text.width(ft, rl) + 16
        local rh = ht + 8
        local rx, ry = x + width - pad - rw, top + (title_h - rh) * 0.5
        draw.rect(rx, ry, rx + rw, ry + rh, 0, 0, 0, 90, rh * 0.5)
        text.draw(ft, rx + 8, ry + 4, 255, 255, 255, 255, rl)
    end

    for _, op in ipairs(ops) do op(x, top) end
end)
