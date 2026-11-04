-- Getaway Driver. Published fields: active (bool), stage (0 waiting for the next job, 1 driving to the pickup, 2 crew
-- boarding, 3 escaping, 4 job done), distance (m to the pickup or hideout), wanted (stars), crew_alive / crew_total /
-- crew_aboard, time_left (s), pay (your cut if you finished now; the full take before the crew boards), jobs, earned
-- (this session), out_left (s before the crew bails, present only while someone is out of the car).
features.on_draw("Getaway Driver", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local stage = math.floor(f.stage or 0)
    local wanted = math.floor(f.wanted or 0)

    local title, line
    if stage == 0 then title, line = "GETAWAY DRIVER", "Waiting for a call. Sit in a car with passenger seats"
    elseif stage == 1 then title, line = "HEAD TO THE PICKUP", string.format("%dm   Stop by the marker and wait", math.floor(f.distance or 0))
    elseif stage == 2 then title, line = "HOLD STILL", string.format("Crew boarding %d/%d", math.floor(f.crew_aboard or 0), math.floor(f.crew_alive or 0))
    elseif stage == 3 then
        if wanted > 0 then title, line = "LOSE THE COPS", "Get out of the search area"
        else title, line = "TO THE HIDEOUT", string.format("%dm   Stop inside the marker", math.floor(f.distance or 0)) end
    else title, line = "CLEAN GETAWAY", string.format("Jobs %d   Earned $%d", math.floor(f.jobs or 0), math.floor(f.earned or 0)) end

    local pw, ph = 340 * s, 104 * s
    local px, py = sw - pw - 30 * s, sh * 0.30
    draw.rect(px, py, px + pw, py + ph, 12, 12, 16, 215, 10 * s)
    draw.rect(px, py, px + 4 * s, py + ph, ar or 255, ag or 200, ab or 80, 255, 2 * s)
    text.draw(font.item, px + 16 * s, py + 10 * s, 245, 245, 250, 255, title)
    text.draw(font.small, px + 16 * s, py + 40 * s, 200, 200, 212, 255, line)

    if stage >= 1 and stage <= 3 then
        local tl = math.floor(f.time_left or 0)
        local info = string.format("$%d   %d:%02d", math.floor(f.pay or 0), math.floor(tl / 60), tl % 60)
        text.draw(font.small, px + 16 * s, py + 70 * s, 120, 230, 120, 255, info)
        local crew = math.floor(f.crew_total or 0)
        for i = 1, crew do
            local cx = px + pw - 20 * s - (crew - i) * 22 * s
            local alive = i <= math.floor(f.crew_alive or 0)
            if alive then draw.circle(cx, py + 80 * s, 7 * s, 245, 245, 250, 255)
            else draw.circle_outline(cx, py + 80 * s, 7 * s, 200, 80, 80, 255, 2 * s) end
        end
        for i = 1, wanted do
            local cx = px + pw - 20 * s - (i - 1) * 20 * s
            draw.circle(cx, py + 18 * s, 6 * s, 245, 210, 80, 255)
        end
    end

    if f.out_left then
        local msg = string.format("GET THE CREW BACK IN   %ds", math.ceil(f.out_left))
        local w = text.width(font.item, msg)
        draw.rect(sw / 2 - w / 2 - 14 * s, sh * 0.18 - 8 * s, sw / 2 + w / 2 + 14 * s, sh * 0.18 + text.height(font.item) + 8 * s, 12, 12, 16, 220, 8 * s)
        text.draw(font.item, sw / 2 - w / 2, sh * 0.18, 255, 170, 80, 255, msg)
    end
end)
