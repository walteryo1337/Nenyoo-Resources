-- GTA5-Mods Browser list: paints the browser page as category chips, a search/sort/time bar and rich
-- result rows (thumbnail, title, type, edition, downloads, install state) over the menu's own rows.
-- The rows underneath stay the live page: the menu's selection, Enter and controller nav all still drive
-- them, and this script only maps the selected row index onto what it draws. Q / E switch the category
-- from any row; left/right step the category, sort and time pickers in place.
--
-- Data comes from previews\gta5mods_browser.lua, which parses the browser's HUD publish each frame and
-- leaves it in __gta5mods_list (feature HUDs run before overlays, so it is always this frame's).
local VK_LEFT, VK_RIGHT, VK_Q, VK_E = 37, 39, 0x51, 0x45
local ROW_CAT, ROW_SEARCH, ROW_SORT, ROW_SINCE = 0, 1, 2, 3

local owned = false          -- we hold menu.set_overlay_active(true)
local scroll, scroll_t = 0, 0
local last_sel = -1
-- Themes that edit text inline keep the typed text to themselves until Enter, and their row is under
-- this overlay. Mirror the edit from the same (non-consuming) key input so the search field shows it.
local mirror = nil
local last_list = nil       -- category/page/query the list was scrolled for
local VK_BACK = 0x08

local KIND_COLORS = {
    addon = { 58, 186, 118 }, replace = { 226, 152, 52 }, skin = { 164, 112, 226 },
    fivem = { 214, 84, 84 }, unverified = { 104, 106, 118 },
}
local STATE_STYLE = {
    lib = { 23, 61, 42, 111, 224, 163 }, other = { 70, 48, 15, 255, 196, 110 },
    queued = { 44, 36, 64, 201, 168, 255 }, installing = { 44, 36, 64, 201, 168, 255 },
    dl = { 44, 36, 64, 228, 212, 255 }, fail = { 70, 24, 28, 255, 140, 140 },
    dlq = { 44, 36, 64, 201, 168, 255 }, upd = { 70, 48, 15, 255, 196, 110 },
}
local STATE_KEYS = { lib = "st_lib", queued = "st_queued", installing = "st_installing", dl = "st_dl", fail = "st_fail", other = "st_other", dlq = "st_dlq" }

local function clampn(v, lo, hi) if v < lo then return lo elseif v > hi then return hi end return v end
local function inside(mx, my, x0, y0, x1, y1) return mx >= x0 and mx <= x1 and my >= y0 and my <= y1 end

local function fmt_count(n)
    if not n or n < 0 then return nil end
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 10000 then return string.format("%.0fK", n / 1000) end
    if n >= 1000 then return string.format("%.1fK", n / 1000) end
    return tostring(math.floor(n))
end

local function cover(path, x1, y1, x2, y2)
    if not path or path == "" then return false end
    local w, h = draw.preview_image_size(path)
    if not w or w <= 0 or h <= 0 then return draw.preview_image(path, x1, y1, x2, y2, 1.0, true) end
    local s = math.max((x2 - x1) / w, (y2 - y1) / h)
    local dw, dh = w * s, h * s
    local ox, oy = x1 + ((x2 - x1) - dw) * 0.5, y1 + ((y2 - y1) - dh) * 0.5
    draw.push_clip(x1, y1, x2, y2)
    local ok = draw.preview_image(path, ox, oy, ox + dw, oy + dh, 1.0)
    draw.pop_clip()
    return ok
end

-- Text pieces separated by small dots (the game font has no middle-dot glyph), clipped to maxw.
local function dotted(fnt, x, y, r, g, b, a, bits, maxw)
    local cx, h = x, text.height(fnt)
    for i, s in ipairs(bits) do
        if i > 1 then
            draw.circle(cx + 7, y + h * 0.55, 1.8, r, g, b, a)
            cx = cx + 14
        end
        local room = x + maxw - cx
        if room <= 12 then break end
        local w = text.width(fnt, s)
        if w > room then text.draw_ellipsis(fnt, cx, y, r, g, b, a, s, room); break end
        text.draw(fnt, cx, y, r, g, b, a, s)
        cx = cx + w
    end
end

local function spinner(cx, cy, radius, r, g, b)
    local t = ctx.time()
    for i = 0, 7 do
        local a = (i / 8) * math.pi * 2
        local alpha = math.floor(60 + 195 * (1 - ((t * 1.6 - i / 8) % 1)))
        draw.circle(cx + math.cos(a) * radius, cy + math.sin(a) * radius, radius * 0.22, r, g, b, alpha)
    end
end

local function release()
    mirror = nil
    if owned then menu.set_overlay_active(false); owned = false end
end

overlay.on_draw("gta5mods_list", function()
    local st = __gta5mods_list
    local f = st and st.frame == ctx.frame() and st.f or nil
    if not f or f.mode ~= "browse" or f.teaser or not f.row_first then release(); return end
    local cx, cy, cw, ch = menu.content_rect()
    if not ch or ch <= 0 then release(); return end
    if not owned then menu.set_overlay_active(true); owned = true end

    local L = str.panel_gta5mods()
    local cards = st.cards
    local ar, ag, ab = theme.accent()
    local mx, my = input.mouse_x(), input.mouse_y()
    local click = input.mouse_clicked(0)
    local sel = menu.selected_index()
    local fi, fs, ft = font.item, font.small, font.tiny
    local hi, hs, ht = text.height(fi), text.height(fs), text.height(ft)
    local pad = 10

    -- Opaque backing: the menu's rows are still there underneath, just not shown.
    draw.rect(cx, cy, cx + cw, cy + ch, 14, 13, 20, 255)

    -- Clicking a row: select it, or activate it when it already is (same as Enter).
    local function pick(row)
        if sel == row then menu.activate() else menu.set_selected(row) end
    end

    -- ---- category chips (row 0) ----
    local values = items.values(menu.handle_at(ROW_CAT)) or {}
    local cat_item = menu.get_item(ROW_CAT)
    local cur_cat = cat_item and cat_item.value_index or 0
    local chip_h = hs + 10
    local y = cy + 8
    local focus_cat = sel == ROW_CAT
    local widths, total = {}, 0
    for i = 1, #values do
        widths[i] = text.width(fs, values[i] or "") + 22
        total = total + widths[i] + 6
    end
    -- Keep the active chip in view when the strip is wider than the menu.
    local strip_w = cw - pad * 2
    local off = 0
    if total > strip_w then
        local before = 0
        for i = 1, cur_cat do before = before + widths[i] + 6 end
        off = clampn(before - (strip_w - widths[cur_cat + 1]) * 0.5, 0, total - strip_w)
    end
    draw.push_clip(cx + pad, y - 2, cx + cw - pad, y + chip_h + 2)
    local x = cx + pad - off
    for i = 1, #values do
        local w = widths[i]
        local on = (i - 1) == cur_cat
        local over = inside(mx, my, x, y, x + w, y + chip_h)
        if on then
            draw.rect(x, y, x + w, y + chip_h, ar, ag, ab, 255, chip_h * 0.5)
        else
            draw.rect(x, y, x + w, y + chip_h, over and 40 or 29, over and 37 or 27, over and 54 or 38, 255, chip_h * 0.5)
        end
        if on and focus_cat then draw.rect_outline(x - 2, y - 2, x + w + 2, y + chip_h + 2, 255, 255, 255, 255, chip_h * 0.5 + 2, 2) end
        local tr = on and 255 or 205
        text.draw(fs, x + 11, y + 5, tr, tr, on and 255 or 214, 255, values[i] or "")
        if over and click then
            menu.set_selected(ROW_CAT)
            if not on then menu.set_value_index(ROW_CAT, i - 1) end
        end
        x = x + w + 6
    end
    draw.pop_clip()
    y = y + chip_h + 8

    -- ---- search / sort / time bar (rows 1-3) ----
    local bar_h = hs + 12
    -- `drop` fields are the Sort / Time pickers: a small caption names them, a chevron marks them, and
    -- left/right on the row cycles them.
    local function field(row, x0, x1, label, dim, drop, cap, icon, editing)
        local on = sel == row
        local over = inside(mx, my, x0, y, x1, y + bar_h)
        if on then
            draw.rect(x0, y, x1, y + bar_h, 255, 255, 255, 255, 4)
        else
            draw.rect(x0, y, x1, y + bar_h, over and 38 or 29, over and 35 or 27, over and 50 or 38, 255, 4)
        end
        local c = on and 20 or (dim and 150 or 225)
        local tail = drop and 22 or 9
        local lx = x0 + 9
        if icon then
            local r_ = hs * 0.28
            local gx, gy = lx + r_, y + bar_h * 0.5 - 1
            draw.circle_outline(gx, gy, r_, c, c, c, 255, 1.5)
            draw.line(gx + r_ * 0.7, gy + r_ * 0.7, gx + r_ * 1.6, gy + r_ * 1.6, c, c, c, 255, 1.5)
            lx = lx + r_ * 2 + 9
        end
        if cap and cap ~= "" then
            local cc = on and 110 or 130
            text.draw(ft, lx, y + (bar_h - ht) * 0.5, cc, cc, on and 120 or 146, 255, cap)
            lx = lx + text.width(ft, cap) + 6
        end
        if editing then
            -- Typing: show the tail of the live buffer with a blinking caret (the theme's own text box is
            -- underneath this overlay).
            local room = x1 - lx - tail - 4
            local shown = label
            while #shown > 0 and text.width(fs, shown) > room do shown = shown:sub(2) end
            text.draw(fs, lx, y + 6, c, c, on and 24 or 232, 255, shown)
            if (ctx.time() % 1) < 0.55 then
                local kx = lx + text.width(fs, shown) + 2
                draw.rect(kx, y + 5, kx + 1.5, y + bar_h - 5, c, c, c, 255)
            end
        else
            text.draw_ellipsis(fs, lx, y + 6, c, c, on and 24 or (dim and 162 or 232), 255, label, x1 - lx - tail)
        end
        if drop then
            local vx, vy = x1 - 15, y + bar_h * 0.5 - 2
            draw.line(vx - 4, vy, vx, vy + 4, c, c, c, 255, 1.5)
            draw.line(vx, vy + 4, vx + 4, vy, c, c, c, 255, 1.5)
        end
        if over and click then pick(row) end
    end
    local sort_item, since_item = menu.get_item(ROW_SORT), menu.get_item(ROW_SINCE)
    local sort_lbl = sort_item and sort_item.current_value or ""
    local since_lbl = since_item and since_item.current_value or ""
    local sort_cap = sort_item and sort_item.name or ""
    local since_cap = since_item and since_item.name or ""
    local x0, x1 = cx + pad, cx + cw - pad
    local popup_typing = sel == ROW_SEARCH and menu.popup_mode() == 1
    local inline_typing = sel == ROW_SEARCH and not popup_typing and menu.is_text_editing()
    if inline_typing then
        if not mirror then
            local it = menu.get_item(ROW_SEARCH)
            mirror = it and it.text or ""
        else
            local chars = input.get_chars()
            if chars ~= "" then
                for ch in chars:gmatch(".") do
                    if #mirror < 63 then mirror = mirror .. ch end
                end
            end
            if input.key_just_pressed(VK_BACK) and #mirror > 0 then mirror = mirror:sub(1, -2) end
        end
    else
        mirror = nil
    end
    if popup_typing then
        field(ROW_SEARCH, x0, x1, menu.get_input_buffer() or "", false, false, nil, true, true)
    elseif inline_typing then
        field(ROW_SEARCH, x0, x1, mirror or "", false, false, nil, true, true)
    else
        field(ROW_SEARCH, x0, x1, f.query or L.search_hint or "", f.query == nil, false, nil, true)
    end
    y = y + bar_h + 6
    local mid = math.floor((x0 + x1) * 0.5)
    field(ROW_SORT, x0, mid - 3, sort_lbl, false, true, sort_cap)
    field(ROW_SINCE, mid + 3, x1, since_lbl, f.query ~= nil, true, since_cap)
    y = y + bar_h + 6

    -- List toggles: a check box chip per row; Enter (or a click) flips it.
    local tog_h = hs + 10
    local function toggle_chip(row, tx)
        local it = row and row >= 0 and menu.get_item(row) or nil
        if not it then return tx end
        local label = it.name or ""
        local w = text.width(fs, label) + 38
        local on = sel == row
        local over = inside(mx, my, tx, y, tx + w, y + tog_h)
        if on then
            draw.rect(tx, y, tx + w, y + tog_h, 255, 255, 255, 255, 4)
        else
            draw.rect(tx, y, tx + w, y + tog_h, over and 38 or 29, over and 35 or 27, over and 50 or 38, 255, 4)
        end
        local bs_ = hs * 0.8
        local bx_, by_ = tx + 9, y + (tog_h - bs_) * 0.5
        if it.on then
            draw.rect(bx_, by_, bx_ + bs_, by_ + bs_, ar, ag, ab, 255, 3)
            draw.line(bx_ + bs_ * 0.22, by_ + bs_ * 0.52, bx_ + bs_ * 0.42, by_ + bs_ * 0.74, 255, 255, 255, 255, 1.8)
            draw.line(bx_ + bs_ * 0.42, by_ + bs_ * 0.74, bx_ + bs_ * 0.8, by_ + bs_ * 0.28, 255, 255, 255, 255, 1.8)
        else
            local c = on and 90 or 140
            draw.rect_outline(bx_, by_, bx_ + bs_, by_ + bs_, c, c, c + 10, 255, 3, 1.5)
        end
        local c = on and 20 or 225
        text.draw(fs, bx_ + bs_ + 8, y + 5, c, c, on and 24 or 232, 255, label)
        if over and click then pick(row) end
        return tx + w + 6
    end
    local tx = toggle_chip(f.row_filter and math.floor(f.row_filter) or nil, x0)
    toggle_chip(f.row_compact and math.floor(f.row_compact) or nil, tx)
    y = y + tog_h + 8
    draw.rect(cx, y - 1, cx + cw, y, 40, 37, 52, 255)

    -- ---- result rows; the page navigation rows are drawn as the pager footer below ----
    local entries = {}
    local first = math.floor(f.row_first)
    local divided = false
    for i = 1, #cards do
        local c = cards[i]
        if c.row and c.row >= first then
            if c.weak and not divided and #entries > 0 then
                entries[#entries + 1] = { row = -1, divider = true }
                divided = true
            end
            entries[#entries + 1] = { row = c.row, card = c }
        end
    end
    local function nav(k)
        local r = f[k] and math.floor(f[k]) or -1
        local it = r >= 0 and menu.get_item(r) or nil
        return it and { row = r, disabled = it.disabled } or nil
    end
    local n_prev, n_next, n_refresh, n_clear = nav("row_prev"), nav("row_next"), nav("row_refresh"), nav("row_clear")

    local compact = f.compact == true
    local thumb_h = compact and (hi + 2) or (hi + hs + 10)
    local rh = thumb_h + (compact and 6 or 10)
    local nh = hi + 14
    local dh = ht + 12
    local pager_h = bar_h + 16
    local ly0, ly1 = y, cy + ch - pager_h
    local view_h = ly1 - ly0

    -- Row tops in list space, the selected entry, and the total height.
    local tops, sel_e, h_total = {}, nil, 0
    local function entry_h(e) return e.card and rh or (e.divider and dh or nh) end
    for i, e in ipairs(entries) do
        tops[i] = h_total
        if e.row == sel then sel_e = i end
        h_total = h_total + entry_h(e)
    end
    local scroll_max = math.max(0, h_total - view_h)
    -- A new page of results starts at the top, wherever the selection is.
    local list_key = tostring(f.cat) .. "|" .. tostring(f.page) .. "|" .. tostring(f.query) .. "|" .. tostring(compact)
    if list_key ~= last_list then
        last_list = list_key
        scroll, scroll_t = 0, 0
        last_sel = -1
    end
    if sel_e and sel ~= last_sel then
        local top, bot = tops[sel_e], tops[sel_e] + entry_h(entries[sel_e])
        -- Keep the "Other matches" divider in view with the first row under it.
        if sel_e > 1 and entries[sel_e - 1].divider then top = tops[sel_e - 1] end
        if top < scroll_t then scroll_t = top elseif bot > scroll_t + view_h then scroll_t = bot - view_h end
    elseif sel < first and sel ~= last_sel then
        scroll_t = 0
    end
    last_sel = sel
    if inside(mx, my, cx, ly0, cx + cw, ly1) then
        local wh = input.mouse_wheel()
        if wh ~= 0 then menu.move_selection(wh > 0 and -1 or 1) end
    end
    scroll_t = clampn(scroll_t, 0, scroll_max)
    scroll = scroll + (scroll_t - scroll) * clampn(ctx.delta() * 18, 0, 1)
    if math.abs(scroll - scroll_t) < 0.5 then scroll = scroll_t end

    -- Q / E: previous / next category from anywhere on the page.
    if #values > 0 and not menu.is_text_editing() then
        local d = 0
        if input.key_just_pressed(VK_E) then d = 1 elseif input.key_just_pressed(VK_Q) then d = -1 end
        if d ~= 0 then menu.set_value_index(ROW_CAT, (cur_cat + d) % #values) end
    end
    -- Left/right on a picker row opens the theme's array popup, which draws underneath this overlay where
    -- nobody can see it. Close it the same frame and step the value in place instead.
    if menu.popup_mode() == 3 and (sel == ROW_CAT or sel == ROW_SORT or sel == ROW_SINCE) then
        local d = input.key_repeat(VK_RIGHT) and 1 or (input.key_repeat(VK_LEFT) and -1 or 0)
        menu.set_popup_mode(0)
        if d ~= 0 then
            local vals = items.values(menu.handle_at(sel)) or {}
            local it = menu.get_item(sel)
            if #vals > 0 and it then menu.set_value_index(sel, (it.value_index + d) % #vals) end
        end
    end

    draw.push_clip(cx, ly0, cx + cw, ly1)
    if #cards == 0 or #entries == 0 then
        local msg = #cards == 0 and (f.status or "") or (L.all_hidden or "")
        local my_ = ly0 + 40
        if f.busy then spinner(cx + cw * 0.5, my_, 12, ar, ag, ab); my_ = my_ + 26 end
        text.draw_ellipsis(fs, cx + math.max(pad, (cw - text.width(fs, msg)) * 0.5), my_, 180, 178, 192, 255, msg, cw - pad * 2)
    end
    for i, e in ipairs(entries) do
        local ry = ly0 + tops[i] - scroll
        local eh = entry_h(e)
        if e.divider then
            if ry + eh >= ly0 and ry <= ly1 then
                local label = string.upper(L.other_matches or "")
                local ty = ry + (eh - ht) * 0.5
                text.draw(ft, cx + pad, ty, 143, 138, 159, 255, label)
                local lx = cx + pad + text.width(ft, label) + 8
                draw.rect(lx, ty + ht * 0.5, cx + cw - pad, ty + ht * 0.5 + 1, 58, 53, 73, 255)
            end
        elseif ry + eh >= ly0 and ry <= ly1 then
            local on = e.row == sel
            local over = inside(mx, my, cx, math.max(ry, ly0), cx + cw, math.min(ry + eh, ly1))
            if on then
                draw.rect(cx, ry, cx + cw, ry + eh, 255, 255, 255, 255)
            elseif over then
                draw.rect(cx, ry, cx + cw, ry + eh, 255, 255, 255, 12)
            end
            if e.card then
                local c = e.card
                local tx0, ty0 = cx + pad, ry + (compact and 3 or 5)
                local tw = math.floor(thumb_h * 1.6)
                draw.rect(tx0, ty0, tx0 + tw, ty0 + thumb_h, 26, 24, 34, 255, 4)
                local shown = c.thumb ~= "" and cover(c.thumb, tx0, ty0, tx0 + tw, ty0 + thumb_h)
                if not shown and c.thumb_loading then spinner(tx0 + tw * 0.5, ty0 + thumb_h * 0.5, 6, ar, ag, ab) end

                -- State pill on the right; the title gets whatever room is left.
                local right = cx + cw - pad
                local skey = c.state
                if skey == "lib" and c.update then skey = "upd" end
                local label = skey == "upd" and L.st_update or (skey ~= "" and STATE_KEYS[skey] and L[STATE_KEYS[skey]] or nil)
                if c.state == "dl" and f.dl_pct and f.dl_pct >= 0 then label = math.floor(f.dl_pct * 100 + 0.5) .. "%" end
                if label then
                    label = string.upper(label)
                    local s = STATE_STYLE[skey] or STATE_STYLE.dl
                    local pw = text.width(ft, label) + 14
                    local py = ry + (eh - (ht + 8)) * 0.5
                    draw.rect(right - pw, py, right, py + ht + 8, s[1], s[2], s[3], 255, 4)
                    text.draw(ft, right - pw + 7, py + 4, s[4], s[5], s[6], 255, label)
                    right = right - pw - 8
                else
                    local chev = ">"
                    local cc = on and 70 or 120
                    text.draw(fi, right - text.width(fi, chev), ry + (eh - hi) * 0.5, cc, cc, cc + 12, 255, chev)
                    right = right - text.width(fi, chev) - 8
                end

                local lx = tx0 + tw + 10
                local t1 = on and 18 or 238
                if compact then
                    -- One line: kind dot, then the title.
                    local kc = KIND_COLORS[c.kind] or KIND_COLORS.unverified
                    draw.circle(lx + 4, ry + eh * 0.5, 4, kc[1], kc[2], kc[3], 255)
                    text.draw_ellipsis(fi, lx + 13, ry + (eh - hi) * 0.5, t1, t1, on and 22 or 244, 255, c.title, right - lx - 13)
                else
                text.draw_ellipsis(fi, lx, ty0 + 1, t1, t1, on and 22 or 244, 255, c.title, right - lx)
                local kc = KIND_COLORS[c.kind] or KIND_COLORS.unverified
                local sy = ty0 + hi + 5
                draw.circle(lx + 4, sy + hs * 0.5, 4, kc[1], kc[2], kc[3], 255)
                local bits = {}
                if L[c.kind] then bits[#bits + 1] = L[c.kind] end
                if c.edition ~= "" and L[c.edition] then bits[#bits + 1] = L[c.edition] end
                local d = fmt_count(c.downloads)
                if d then bits[#bits + 1] = d .. " " .. L.downloads end
                local s2 = on and 85 or 156
                dotted(fs, lx + 13, sy, s2, s2, s2 + 12, 255, bits, right - lx - 13)
                if c.state == "dl" and f.dl_pct and f.dl_pct >= 0 then
                    local by = ty0 + thumb_h - 3
                    draw.rect(lx, by, right, by + 3, 60, 56, 76, 255, 1)
                    draw.rect(lx, by, lx + (right - lx) * clampn(f.dl_pct, 0, 1), by + 3, ar, ag, ab, 255, 1)
                end
                end
            end
            if over and click then pick(e.row) end
        end
    end
    draw.pop_clip()

    if scroll_max > 0 then
        local th = math.max(20, view_h * (view_h / h_total))
        local tp = ly0 + (view_h - th) * (scroll / scroll_max)
        draw.rect(cx + cw - 4, tp, cx + cw - 1, tp + th, ar, ag, ab, 200, 2)
    end

    -- ---- pager footer: [<] Page x / y [>]  ...  [refresh] [clear search] ----
    local py0 = ly1
    draw.rect(cx, py0, cx + cw, cy + ch, 18, 17, 25, 255)
    draw.rect(cx, py0, cx + cw, py0 + 1, 40, 37, 52, 255)
    local bs = bar_h
    local by = py0 + (pager_h - bs) * 0.5
    local function button(e, bx, w, glyph)
        if not e then return end
        local on = sel == e.row
        local over = inside(mx, my, bx, by, bx + w, by + bs)
        if on then
            draw.rect(bx, by, bx + w, by + bs, 255, 255, 255, 255, 4)
        else
            draw.rect(bx, by, bx + w, by + bs, over and 40 or 29, over and 37 or 27, over and 54 or 38, 255, 4)
        end
        local c = on and 20 or (e.disabled and 90 or 225)
        glyph(bx + w * 0.5, by + bs * 0.5, c)
        if over and click and not e.disabled then pick(e.row) end
    end
    local function chevron(dir)
        return function(gx, gy, c)
            draw.line(gx + 2 * dir, gy - 5, gx - 3 * dir, gy, c, c, c, 255, 2)
            draw.line(gx - 3 * dir, gy, gx + 2 * dir, gy + 5, c, c, c, 255, 2)
        end
    end
    local function refresh_glyph(gx, gy, c)
        local r_, steps = 5.5, 10
        local a0, a1 = math.rad(-60), math.rad(220)
        local px, py_
        for k = 0, steps do
            local a = a0 + (a1 - a0) * k / steps
            local qx, qy = gx + math.cos(a) * r_, gy + math.sin(a) * r_
            if px then draw.line(px, py_, qx, qy, c, c, c, 255, 1.6) end
            px, py_ = qx, qy
        end
        local ex, ey = gx + math.cos(a0) * r_, gy + math.sin(a0) * r_
        draw.line(ex, ey, ex - 4, ey - 1, c, c, c, 255, 1.6)
        draw.line(ex, ey, ex + 0.5, ey + 4, c, c, c, 255, 1.6)
    end
    local function clear_glyph(gx, gy, c)
        draw.line(gx - 4, gy - 4, gx + 4, gy + 4, c, c, c, 255, 1.8)
        draw.line(gx + 4, gy - 4, gx - 4, gy + 4, c, c, c, 255, 1.8)
    end

    local bx = cx + pad
    button(n_prev, bx, bs, chevron(1))
    bx = bx + bs + 8
    local pg = ""
    if (f.count or 0) > 0 then pg = (L.page or "") .. " " .. math.floor(f.page or 1) .. " / " .. math.floor(f.max_page or 1) end
    local pgw = math.max(text.width(fs, pg), 40)
    text.draw(fs, bx + (pgw - text.width(fs, pg)) * 0.5, by + (bs - hs) * 0.5, 200, 198, 212, 255, pg)
    bx = bx + pgw + 8
    button(n_next, bx, bs, chevron(-1))
    if f.hidden and f.hidden > 0 then
        local hid = math.floor(f.hidden) .. " " .. (L.hidden or "")
        text.draw(ft, bx + bs + 10, by + (bs - ht) * 0.5, 141, 136, 160, 255, hid)
    end
    local rx = cx + cw - pad
    if n_clear and (f.query ~= nil or sel == n_clear.row) then
        rx = rx - bs
        button(n_clear, rx, bs, clear_glyph)
        rx = rx - 6
    end
    button(n_refresh, rx - bs, bs, refresh_glyph)
end)
