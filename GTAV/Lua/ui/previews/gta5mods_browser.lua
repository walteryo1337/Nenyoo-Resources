-- GTA5-Mods Browser details panel, docked beside the menu. Published by gta5mods_browser::draw only
-- while the menu is on the "GTA5-Mods Browser" page or a mod's page (or the Custom DLCs row that opens
-- it), so no page check is needed here. The result list itself is overlays\gta5mods_list.lua, which
-- reads what this script parses from __gta5mods_list.
--   mode        : "browse" | "mod";  teaser : true on the Custom DLCs row
--   status      : translated status line;  status_kind : "busy" | "ok" | "err" | "idle";  busy : bool
--   count, sel  : result count and the highlighted card (1-based);  page, max_page
--   cat, sort, since, query : current filters (since/query only when set);  running : "legacy" | "enhanced"
--   row_first, row_next, row_prev, row_refresh, row_clear, rows : menu row layout (browse page only)
--   detail      : "loading" | "ok" | "failed" for the highlighted card;  file_count, file_sel (1-based)
--   install, install_kind : install status of the highlighted card (only when known; a failure carries its reason)
--   update      : "Update available: 1.0 -> 1.1" when the installed version is older than the site's
--   shot_n, shot_sel, shot_path, shot_loading : screenshot gallery of a mod's page (shot_path once downloaded)
--   row_filter, row_compact, compact, hidden : list toggles (browse page; read by overlays\gta5mods_list.lua)
--   dl_active, dl_title, dl_text, dl_kind ("busy"|"ok"|"err"), dl_pct (0..1, -1 = unknown) : download box
--   q_count     : downloads waiting behind the running one
--   blob        : one record per line, tab separated:
--                 C idx title author thumb kind edition state downloads likes rating version tags thumb_loading
--                   row weak update        (row = menu row, -1 = hidden by the filter; weak = "Other matches")
--                 D description ("\r" = line break)      F idx file_label      Q queued_title
local VK_PRIOR, VK_NEXT = 0x21, 0x22
local cache_blob, cards, desc, files, queue = nil, {}, nil, {}, {}
local wrap_cache = {}
local desc_scroll, desc_key = 0, nil

local function split_tabs(line)
    local out = {}
    for field in (line .. "\t"):gmatch("([^\t]*)\t") do out[#out + 1] = field end
    return out
end

local function parse(blob)
    if blob == cache_blob then return end
    cache_blob = blob
    cards, desc, files, queue = {}, nil, {}, {}
    for line in (blob or ""):gmatch("[^\n]+") do
        local t = line:sub(1, 1)
        if t == "C" then
            local f = split_tabs(line)
            cards[#cards + 1] = {
                title = f[3] or "", author = f[4] or "", thumb = f[5] or "", kind = f[6] or "",
                edition = f[7] or "", state = f[8] or "", downloads = tonumber(f[9]) or -1,
                likes = tonumber(f[10]) or -1, rating = tonumber(f[11]) or -1, version = f[12] or "",
                tags = f[13] or "", thumb_loading = f[14] == "1",
                row = tonumber(f[15]) or -1, weak = f[16] == "1", update = f[17] == "1",
            }
        elseif t == "D" then
            desc = line:sub(3):gsub("\r", "\n")
        elseif t == "F" then
            local f = split_tabs(line)
            files[#files + 1] = f[3] or ""
        elseif t == "Q" then
            queue[#queue + 1] = line:sub(3)
        end
    end
end

local function wrap(fnt, value, max_width, max_lines)
    local key = tostring(fnt) .. "|" .. max_width .. "|" .. (max_lines or 0) .. "|" .. (value or "")
    local hit = wrap_cache[key]
    if hit then return hit end
    local lines = {}
    for para in tostring(value or ""):gmatch("[^\n]+") do
        local line = ""
        for word in para:gmatch("%S+") do
            local candidate = line == "" and word or line .. " " .. word
            if line ~= "" and text.width(fnt, candidate) > max_width then
                lines[#lines + 1] = line
                line = word
            else
                line = candidate
            end
        end
        if line ~= "" then lines[#lines + 1] = line end
        if max_lines and #lines > max_lines then break end
    end
    if max_lines and #lines > max_lines then
        while #lines > max_lines do table.remove(lines) end
        lines[max_lines] = lines[max_lines] .. " ..."
    end
    local n = 0
    for _ in pairs(wrap_cache) do n = n + 1 end
    if n > 64 then wrap_cache = {} end
    wrap_cache[key] = lines
    return lines
end

local function fmt_count(n)
    if not n or n < 0 then return nil end
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 10000 then return string.format("%.0fK", n / 1000) end
    if n >= 1000 then return string.format("%.1fK", n / 1000) end
    return tostring(math.floor(n))
end

-- Image scaled to COVER the box (aspect kept, overflow clipped). Returns false until the bitmap is ready.
local function cover(path, x1, y1, x2, y2, alpha)
    if not path or path == "" then return false end
    local w, h = draw.preview_image_size(path)
    if not w or w <= 0 or h <= 0 then
        return draw.preview_image(path, x1, y1, x2, y2, alpha or 1.0, true)
    end
    local bw, bh = x2 - x1, y2 - y1
    local s = math.max(bw / w, bh / h)
    local dw, dh = w * s, h * s
    local ox, oy = x1 + (bw - dw) * 0.5, y1 + (bh - dh) * 0.5
    draw.push_clip(x1, y1, x2, y2)
    local ok = draw.preview_image(path, ox, oy, ox + dw, oy + dh, alpha or 1.0)
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
        local phase = (t * 1.6 - i / 8) % 1
        local alpha = math.floor(60 + 195 * (1 - phase))
        draw.circle(cx + math.cos(a) * radius, cy + math.sin(a) * radius, radius * 0.22, r, g, b, alpha)
    end
end

local KIND_COLORS = {
    addon = { 58, 186, 118 }, replace = { 226, 152, 52 }, skin = { 164, 112, 226 },
    fivem = { 214, 84, 84 }, unverified = { 104, 106, 118 },
}
local EDITION_COLORS = { legacy = { 74, 132, 224 }, enhanced = { 46, 178, 190 }, both = { 60, 158, 207 } }
local STATE_STYLE = {
    lib = { 23, 61, 42, 111, 224, 163 }, other = { 70, 48, 15, 255, 196, 110 },
    queued = { 44, 36, 64, 201, 168, 255 }, installing = { 44, 36, 64, 201, 168, 255 },
    dl = { 44, 36, 64, 228, 212, 255 }, fail = { 70, 24, 28, 255, 140, 140 },
    dlq = { 44, 36, 64, 201, 168, 255 }, upd = { 70, 48, 15, 255, 196, 110 },
}
local STATE_KEYS = { lib = "st_lib", queued = "st_queued", installing = "st_installing", dl = "st_dl", fail = "st_fail", other = "st_other", dlq = "st_dlq" }

local function pill(fnt, x, y, label, r, g, b, a)
    local h = text.height(fnt) + 6
    local w = text.width(fnt, label) + 14
    draw.rect(x, y, x + w, y + h, r, g, b, a or 225, h * 0.5)
    text.draw(fnt, x + 7, y + 3, 255, 255, 255, 255, label)
    return w, h
end

local function kind_color(f, ar, ag, ab)
    if f.status_kind == "err" then return 214, 84, 84 end
    if f.status_kind == "ok" then return 58, 186, 118 end
    if f.status_kind == "busy" then return ar, ag, ab end
    return 140, 140, 150
end

-- Which game version the mod is for, against the one running: text plus true when it will not load here.
-- Enhanced converts Legacy mods while they install, so only one that was filed in the Legacy library
-- (state "other", e.g. an encrypted pack) is a warning.
local function edition_note(L, card, running)
    if not card then return nil end
    local ed = card.edition
    local other = card.state == "other"
    if other then ed = running == "enhanced" and "legacy" or "enhanced" end
    if ed == "both" then return L.ed_both, false end
    if ed == "legacy" then
        if running == "legacy" then return L.ed_legacy_here, false end
        if not other then return L.ed_legacy_convert, false end
        return L.ed_legacy_away, true
    end
    if ed == "enhanced" then
        if running == "enhanced" then return L.ed_enh_here, false end
        return L.ed_enh_away, true
    end
    return nil
end

features.on_draw("GTA5-Mods Browser", function(f)
    if not f.mode then return end
    -- Feature HUDs draw before overlays: this tells overlays\dlc_panel.lua to step aside this frame.
    __gta5mods_panel_frame = ctx.frame()
    parse(f.blob)
    __gta5mods_list = { frame = ctx.frame(), f = f, cards = cards, queue = queue }
    local L = str.panel_gta5mods()
    local ar, ag, ab = theme.accent()

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local W, pad, gap = 460, 14, 8
    local inner = W - pad * 2
    local is_mod = f.mode == "mod"
    local sel = math.floor(f.sel or 0)
    local card = cards[sel]

    local fh_item, fh_small, fh_tiny = text.height(font.item), text.height(font.small), text.height(font.tiny)
    local header_h = fh_small + 18
    local hero_h = math.floor(inner * (card and 0.5625 or 0.32))
    local desc_lines = card and (is_mod and 8 or 4) or 0
    local file_rows = 0
    if is_mod then file_rows = math.min(#files, 4) end
    local has_dl = f.dl_text ~= nil
    local note, note_warn = edition_note(L, card, f.running)
    local note_lines = note and wrap(font.small, note, inner - 20, 3) or {}
    local upd_lines = f.update and wrap(font.small, f.update, inner - 20, 2) or {}
    local inst_lines = f.install and wrap(font.small, f.install, inner - 14, f.install_kind == "err" and 4 or 1) or {}
    local title_lines = card and wrap(font.item, card.title, inner, 2) or {}
    local has_queue = #queue > 0

    local function total_height()
        local h = 3 + header_h + hero_h + gap
        if card then h = h + math.max(1, #title_lines) * (fh_item + 2) + 4 + fh_small + gap end
        if #note_lines > 0 then h = h + #note_lines * (fh_small + 2) + 14 + gap end
        if #upd_lines > 0 then h = h + #upd_lines * (fh_small + 2) + 14 + gap end
        if #inst_lines > 0 then h = h + #inst_lines * (fh_small + 2) + gap end
        if desc_lines > 0 then h = h + desc_lines * (fh_small + 3) + gap end
        if file_rows > 0 then h = h + fh_tiny + 6 + file_rows * (fh_small + 8) + gap
        elseif not is_mod and card then h = h + fh_small + 14 end
        if has_dl then h = h + fh_small * 2 + 26 + (has_queue and fh_small + 4 or 0) end
        h = h + fh_small + pad * 2
        return h
    end

    -- Fit tall layouts on short screens: shrink the hero, then the description.
    local hints = not is_mod and not f.teaser
    local hint_h = hints and (4 * (fh_tiny + 8) + 10) or 0
    local H = total_height()
    local room = sh - 16 - hint_h
    if H > room then hero_h = math.max(140, hero_h - (H - room)); H = total_height() end
    if H > room and desc_lines > 2 then desc_lines = 2; H = total_height() end

    local bx, by, bw = menu.bounds()
    local x, y
    if bw and bw > 0 then
        if (bx + bw * 0.5) < sw * 0.5 then x = bx + bw + 12 else x = bx - 12 - W end
        y = by
    else
        x, y = sw - W - 24, 80
    end
    if x < 8 then x = 8 elseif x + W > sw - 8 then x = sw - 8 - W end
    if y < 8 then y = 8 elseif y + H + hint_h > sh - 8 then y = math.max(8, sh - 8 - H - hint_h) end

    -- Frame + header: category on the left, page on the right.
    draw.rect(x, y, x + W, y + H, 13, 12, 19, 240)
    draw.rect(x, y, x + W, y + 3, ar, ag, ab, 255)
    local hy = y + 3 + math.floor((header_h - fh_small) * 0.5)
    local head = string.upper(f.cat or L.title)
    if f.query then head = head .. "  /  \"" .. f.query .. "\"" end
    local pg = ""
    if (f.count or 0) > 0 then pg = L.page .. " " .. math.floor(f.page or 1) .. " / " .. math.floor(f.max_page or 1) end
    local pgw = text.width(font.small, pg)
    text.draw_ellipsis(font.small, x + pad, hy, 236, 234, 242, 255, head, inner - pgw - 12)
    text.draw(font.small, x + W - pad - pgw, hy, 156, 153, 168, 255, pg)
    local cy = y + 3 + header_h

    -- Hero image with type / edition badges and the install state.
    local hx1, hy1, hx2, hy2 = x + pad, cy, x + W - pad, cy + hero_h
    draw.rect(hx1, hy1, hx2, hy2, 24, 22, 31, 255, 6)
    local shown = false
    if is_mod and f.shot_path then shown = cover(f.shot_path, hx1, hy1, hx2, hy2, 1.0) end
    if not shown and card and card.thumb ~= "" then shown = cover(card.thumb, hx1, hy1, hx2, hy2, 1.0) end
    if not shown then
        local mx, my = (hx1 + hx2) * 0.5, (hy1 + hy2) * 0.5
        if not card then
            if f.busy or f.status_kind == "busy" then spinner(mx, my - 14, 14, ar, ag, ab) end
            local lines = wrap(font.small, f.status or L.empty, inner - 60, 3)
            local ty = my + 10
            for _, ln in ipairs(lines) do
                text.draw(font.small, mx - text.width(font.small, ln) * 0.5, ty, 210, 210, 218, 255, ln)
                ty = ty + fh_small + 3
            end
        elseif card.thumb_loading then
            spinner(mx, my, 12, ar, ag, ab)
        else
            text.draw(font.small, mx - text.width(font.small, L.no_preview) * 0.5, my - fh_small * 0.5, 150, 150, 160, 255, L.no_preview)
        end
    end
    if card then
        draw.rect_gradient(hx1, hy2 - 46, hx2, hy2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 190, 0, 0, 0, 190)
        local bxp = hx1 + 8
        local kc = KIND_COLORS[card.kind] or KIND_COLORS.unverified
        if card.kind ~= "" and L[card.kind] then
            local w = pill(font.tiny, bxp, hy2 - fh_tiny - 14, string.upper(L[card.kind]), kc[1], kc[2], kc[3])
            bxp = bxp + w + 6
        end
        if card.edition ~= "" then
            local ec = EDITION_COLORS[card.edition] or { ar, ag, ab }
            pill(font.tiny, bxp, hy2 - fh_tiny - 14, string.upper(L[card.edition] or card.edition), ec[1], ec[2], ec[3])
        end
        if is_mod and (f.shot_n or 0) > 1 then
            -- Screenshot position, bottom right; a spinner while the picked one downloads.
            local lbl = math.floor(f.shot_sel or 1) .. " / " .. math.floor(f.shot_n)
            local w = text.width(font.tiny, lbl) + 14
            local py = hy2 - fh_tiny - 14
            draw.rect(hx2 - 8 - w, py, hx2 - 8, py + fh_tiny + 6, 0, 0, 0, 150, (fh_tiny + 6) * 0.5)
            text.draw(font.tiny, hx2 - 1 - w, py + 3, 255, 255, 255, 255, lbl)
            if f.shot_loading then spinner(hx2 - 8 - w - 12, py + (fh_tiny + 6) * 0.5, 5, ar, ag, ab) end
        end
        local skey = card.state
        if skey == "lib" and card.update then skey = "upd" end
        if skey ~= "" and (STATE_KEYS[skey] or skey == "upd") then
            local label = string.upper(skey == "upd" and (L.st_update or "") or L[STATE_KEYS[skey]])
            local s = STATE_STYLE[skey] or STATE_STYLE.dl
            local w = text.width(font.tiny, label) + 14
            draw.rect(hx2 - 8 - w, hy1 + 8, hx2 - 8, hy1 + 14 + fh_tiny, s[1], s[2], s[3], 245, 4)
            text.draw(font.tiny, hx2 - 1 - w, hy1 + 11, s[4], s[5], s[6], 255, label)
        end
    end
    draw.rect_outline(hx1, hy1, hx2, hy2, 255, 255, 255, 24, 6)
    cy = hy2 + gap

    -- Title (two lines) and stats.
    if card then
        for _, ln in ipairs(title_lines) do
            text.draw(font.item, x + pad, cy, 245, 244, 250, 255, ln)
            cy = cy + fh_item + 2
        end
        cy = cy + 4
        local stats = {}
        if card.author ~= "" then stats[#stats + 1] = L.by .. " " .. card.author end
        local d, l = fmt_count(card.downloads), fmt_count(card.likes)
        if d then stats[#stats + 1] = d .. " " .. L.downloads end
        if l then stats[#stats + 1] = l .. " " .. L.likes end
        if card.rating and card.rating > 0 then stats[#stats + 1] = string.format("%s %.1f", L.rating, card.rating) end
        if card.version ~= "" then stats[#stats + 1] = "v" .. card.version end
        dotted(font.small, x + pad, cy, 158, 155, 170, 255, stats, inner)
        cy = cy + fh_small + gap
    end

    -- Game version note: green when it runs here, amber when it goes to the other version's library.
    if #note_lines > 0 then
        local nh = #note_lines * (fh_small + 2) + 14
        if note_warn then draw.rect(x + pad, cy, x + W - pad, cy + nh, 58, 42, 16, 255, 4)
        else draw.rect(x + pad, cy, x + W - pad, cy + nh, 20, 48, 31, 255, 4) end
        local ty = cy + 7
        for _, ln in ipairs(note_lines) do
            if note_warn then text.draw(font.small, x + pad + 10, ty, 255, 208, 138, 255, ln)
            else text.draw(font.small, x + pad + 10, ty, 159, 232, 191, 255, ln) end
            ty = ty + fh_small + 2
        end
        cy = cy + nh + gap
    end

    -- A newer upload than the installed one.
    if #upd_lines > 0 then
        local nh = #upd_lines * (fh_small + 2) + 14
        draw.rect(x + pad, cy, x + W - pad, cy + nh, 58, 42, 16, 255, 4)
        local ty = cy + 7
        for _, ln in ipairs(upd_lines) do
            text.draw(font.small, x + pad + 10, ty, 255, 208, 138, 255, ln)
            ty = ty + fh_small + 2
        end
        cy = cy + nh + gap
    end

    -- Install status of this mod (a failure explains why, over several lines).
    if #inst_lines > 0 then
        local kr, kg, kb = 222, 178, 62
        if f.install_kind == "ok" then kr, kg, kb = 58, 186, 118 elseif f.install_kind == "err" then kr, kg, kb = 214, 84, 84 end
        draw.circle(x + pad + 4, cy + fh_small * 0.5 + 1, 4, kr, kg, kb, 255)
        for i, ln in ipairs(inst_lines) do
            if #inst_lines == 1 then text.draw_ellipsis(font.small, x + pad + 14, cy, kr, kg, kb, 255, f.install, inner - 14)
            else text.draw(font.small, x + pad + 14, cy, kr, kg, kb, 255, ln) end
            cy = cy + fh_small + 2
        end
        cy = cy + gap - 2
    end

    -- Description.
    local dtext
    if card then
        if desc and desc ~= "" then dtext = desc
        elseif f.detail == "failed" then dtext = L.no_details
        else dtext = L.loading_details end
    end
    local lines
    local first_line = 0
    if is_mod and desc and desc ~= "" then
        lines = wrap(font.small, dtext, inner - 10, nil)
        local key = (card and card.title or "") .. "|" .. #lines
        if key ~= desc_key then desc_key, desc_scroll = key, 0 end
        local max_first = math.max(0, #lines - desc_lines)
        if max_first > 0 then
            local d = 0
            if input.key_repeat(VK_NEXT) then d = desc_lines - 1 elseif input.key_repeat(VK_PRIOR) then d = -(desc_lines - 1) end
            local mx, my = input.mouse_x(), input.mouse_y()
            if mx >= x and mx <= x + W and my >= cy and my <= cy + desc_lines * (fh_small + 3) then
                local wh = input.mouse_wheel()
                if wh ~= 0 then d = wh > 0 and -2 or 2 end
            end
            desc_scroll = math.max(0, math.min(max_first, desc_scroll + d))
        else
            desc_scroll = 0
        end
        first_line = desc_scroll
        if max_first > 0 then
            -- Scroll bar beside the text.
            local th = desc_lines * (fh_small + 3) - 3
            local bh = math.max(14, th * desc_lines / #lines)
            local by0 = cy + (th - bh) * (desc_scroll / max_first)
            draw.rect(x + W - pad - 3, cy, x + W - pad, cy + th, 255, 255, 255, 18, 1)
            draw.rect(x + W - pad - 3, by0, x + W - pad, by0 + bh, ar, ag, ab, 220, 1)
        end
    else
        lines = dtext and wrap(font.small, dtext, inner, desc_lines) or {}
    end
    for i = 1, desc_lines do
        local ln = lines[first_line + i]
        if ln then text.draw(font.small, x + pad, cy, 207, 204, 216, desc and 235 or 150, ln) end
        cy = cy + fh_small + 3
    end
    if desc_lines > 0 then cy = cy + gap end

    -- Files: the list on a mod's page (the picked one is what Download fetches), the newest one otherwise.
    if file_rows > 0 then
        text.draw(font.tiny, x + pad, cy, ar, ag, ab, 255, string.upper(L.files))
        cy = cy + fh_tiny + 6
        local fsel = math.floor(f.file_sel or 1)
        local first = math.max(1, math.min(fsel - file_rows + 1, #files - file_rows + 1))
        for i = first, first + file_rows - 1 do
            local active = i == fsel
            local ry2 = cy + fh_small + 6
            draw.rect(x + pad, cy, x + W - pad, ry2, active and 34 or 22, active and 32 or 21, active and 46 or 29, 255, 4)
            if active then draw.rect(x + pad, cy, x + pad + 3, ry2, ar, ag, ab, 255, 1) end
            text.draw_ellipsis(font.small, x + pad + 10, cy + 3, 230, 230, 236, active and 255 or 190, files[i] or "", inner - 20)
            cy = ry2 + 2
        end
        cy = cy + gap
    elseif not is_mod and card then
        draw.line(x + pad, cy, x + W - pad, cy, 255, 255, 255, 22, 1)
        cy = cy + 7
        local fl = files[1] or L.newest_file
        local fw = text.width(font.small, L.file)
        text.draw(font.small, x + pad, cy, 156, 153, 168, 255, L.file)
        text.draw_ellipsis(font.small, x + pad + fw + 16, cy, 228, 226, 236, 255, fl, inner - fw - 16)
        cy = cy + fh_small + 7
    end

    -- Download box.
    if has_dl then
        local kr, kg, kb = ar, ag, ab
        if f.dl_kind == "ok" then kr, kg, kb = 58, 186, 118 elseif f.dl_kind == "err" then kr, kg, kb = 214, 84, 84 end
        local box_h = fh_small * 2 + 20
        draw.rect(x + pad, cy, x + W - pad, cy + box_h, 22, 21, 29, 255, 6)
        draw.rect(x + pad, cy, x + pad + 3, cy + box_h, kr, kg, kb, 255, 1)
        text.draw_ellipsis(font.small, x + pad + 12, cy + 5, 240, 240, 245, 255, f.dl_title or "", inner - 24)
        local bar_y = cy + fh_small + 9
        local bx1, bx2 = x + pad + 12, x + W - pad - 12
        local pct = f.dl_pct or -1
        draw.rect(bx1, bar_y, bx2, bar_y + 4, 44, 42, 56, 255, 2)
        if pct >= 0 then
            draw.rect(bx1, bar_y, bx1 + (bx2 - bx1) * math.min(1, pct), bar_y + 4, kr, kg, kb, 255, 2)
        elseif f.dl_active then
            local seg = (bx2 - bx1) * 0.25
            local p = (ctx.time() * 0.8) % 1
            local s1 = bx1 + (bx2 - bx1 - seg) * p
            draw.rect(s1, bar_y, s1 + seg, bar_y + 4, kr, kg, kb, 255, 2)
        end
        local tline = f.dl_text or ""
        if pct >= 0 and f.dl_active then tline = string.format("%d%%   %s", math.floor(pct * 100 + 0.5), tline) end
        text.draw_ellipsis(font.small, bx1, bar_y + 8, 200, 200, 210, 255, tline, bx2 - bx1)
        cy = cy + box_h + 6
    end
    if has_queue then
        local ql = #queue .. " " .. (L.in_queue or "") .. ":  " .. table.concat(queue, ",  ")
        text.draw_ellipsis(font.small, x + pad + 12, cy, 166, 161, 180, 255, ql, inner - 24)
        cy = cy + fh_small + 4
    end

    -- Status line.
    local sr, sg, sb = kind_color(f, ar, ag, ab)
    local sy = y + H - pad - fh_small
    draw.line(x + pad, sy - 8, x + W - pad, sy - 8, 255, 255, 255, 18, 1)
    if f.status_kind == "busy" then
        spinner(x + pad + 5, sy + fh_small * 0.5, 5, sr, sg, sb)
    else
        draw.circle(x + pad + 5, sy + fh_small * 0.5, 4, sr, sg, sb, 255)
    end
    local footer = f.status or ""
    if f.teaser and f.status_kind ~= "err" and f.status_kind ~= "busy" then footer = L.open_hint end
    text.draw_ellipsis(font.small, x + pad + 16, sy, 205, 205, 214, 255, footer, inner - 16)

    -- Key hints under the panel (browse page): white key caps like the game's own prompts.
    if hints then
        local ky = y + H + 10
        local rows = {
            { { "Up", "Down" }, L.k_move }, { { "Enter" }, L.k_open },
            { { "Q", "E" }, L.k_category }, { { "Backspace" }, L.k_back },
        }
        for _, r in ipairs(rows) do
            local kx = x + 2
            for _, k in ipairs(r[1]) do
                local kw = text.width(font.tiny, k) + 12
                draw.rect(kx, ky, kx + kw, ky + fh_tiny + 6, 233, 232, 238, 255, 3)
                text.draw(font.tiny, kx + 6, ky + 3, 17, 17, 17, 255, k)
                kx = kx + kw + 4
            end
            text.draw(font.tiny, kx + 6, ky + 3, 215, 213, 222, 255, r[2] or "")
            ky = ky + fh_tiny + 8
        end
    end
end)
