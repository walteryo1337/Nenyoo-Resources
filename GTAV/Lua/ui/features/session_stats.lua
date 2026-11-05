-- Session Stats. Published fields: active (bool), metric (bool), seconds, kills, headshots, deaths,
-- foot_m (metres walked/run), driven_m (metres in vehicles), top_speed (m/s, vehicles only).
local function clock(sec)
    sec = math.floor(sec or 0)
    local h, m, s = math.floor(sec / 3600), math.floor(sec / 60) % 60, sec % 60
    if h > 0 then return string.format("%d:%02d:%02d", h, m, s) end
    return string.format("%d:%02d", m, s)
end

local function distance(m, metric)
    if metric then return string.format("%.1f km", (m or 0) / 1000) end
    return string.format("%.1f mi", (m or 0) / 1609.344)
end

features.on_draw("Session Stats", function(f)
    if not f.active then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local metric = f.metric
    local kills, deaths = math.floor(f.kills or 0), math.floor(f.deaths or 0)
    local kd = deaths > 0 and kills / deaths or kills
    local speed = (f.top_speed or 0) * (metric and 3.6 or 2.236936)

    local lines = {
        { "TIME", clock(f.seconds) },
        { "KILLS", tostring(kills) },
        { "HEADSHOTS", tostring(math.floor(f.headshots or 0)) },
        { "DEATHS", tostring(deaths) },
        { "K/D", string.format("%.2f", kd) },
        { "ON FOOT", distance(f.foot_m, metric) },
        { "DRIVEN", distance(f.driven_m, metric) },
        { "TOP SPEED", string.format(metric and "%d km/h" or "%d mph", math.floor(speed + 0.5)) },
    }

    local pad = 10 * s
    local lh = text.height(font.hud_small) + 4 * s
    local title_h = text.height(font.hud_tiny) + 6 * s
    local w = 210 * s
    local h = title_h + lh * #lines + pad * 2
    local x = sw - w - 18 * s
    local y = sh * 0.30

    draw.rect(x, y, x + w, y + h, 10, 10, 16, 150, 6 * s)
    draw.rect(x, y, x + 3 * s, y + h, ar, ag, ab, 230, 0)
    text.draw(font.hud_tiny, x + pad, y + pad, ar, ag, ab, 255, "SESSION")

    for i, l in ipairs(lines) do
        local ly = y + pad + title_h + (i - 1) * lh
        text.draw(font.hud_tiny, x + pad, ly + 2 * s, 170, 170, 180, 230, l[1])
        local vw = text.width(font.hud_small, l[2])
        text.draw(font.hud_small, x + w - pad - vw, ly, 240, 240, 245, 255, l[2])
    end
end)
