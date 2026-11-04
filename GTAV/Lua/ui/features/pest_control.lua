-- Pest Control. Published fields: active (bool), stage (0 waiting for a call, 1 heading to the job, 2 hunting, 3 job
-- finished), distance (m to the job site), total / killed / escaped / left (rats this job), time_left (s, hunting only),
-- pay (earned so far this job), jobs, earned (this session).
features.on_draw("Pest Control", function(f)
    if not f.active then return end
    local stage = math.floor(f.stage or 0)
    if stage == 0 then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local pw, ph = 300 * s, 100 * s
    local px, py = sw - pw - 30 * s, sh * 0.30
    draw.rect(px, py, px + pw, py + ph, 12, 12, 16, 215, 10 * s)
    draw.rect(px, py, px + 4 * s, py + ph, 200, 160, 90, 255, 2 * s)
    text.draw(font.item, px + 16 * s, py + 10 * s, 245, 245, 250, 255, "PEST CONTROL")

    if stage == 1 then
        text.draw(font.small, px + 16 * s, py + 42 * s, 210, 210, 222, 255, string.format("HEAD TO THE JOB   %dm", math.floor(f.distance or 0)))
        text.draw(font.small, px + 16 * s, py + 66 * s, 170, 170, 185, 255, string.format("JOBS %d   EARNED $%d", math.floor(f.jobs or 0), math.floor(f.earned or 0)))
    elseif stage == 2 then
        local tl = math.floor(f.time_left or 0)
        local tr, tg = 210, 210
        if tl < 20 then tr, tg = 255, 140 end
        text.draw(font.small, px + 16 * s, py + 42 * s, tr, tg, 222, 255, string.format("RATS LEFT %d   %d:%02d", math.floor(f.left or 0), math.floor(tl / 60), tl % 60))
        text.draw(font.small, px + 16 * s, py + 66 * s, 120, 230, 120, 255, string.format("GOT %d   ESCAPED %d   $%d", math.floor(f.killed or 0), math.floor(f.escaped or 0), math.floor(f.pay or 0)))
        local total = math.max(1, math.floor(f.total or 1))
        local bx1, bx2, by = px + 16 * s, px + pw - 16 * s, py + ph - 12 * s
        draw.rect(bx1, by, bx2, by + 5 * s, 40, 40, 48, 255, 2 * s)
        draw.rect(bx1, by, bx1 + (bx2 - bx1) * (math.floor(f.killed or 0) / total), by + 5 * s, 120, 230, 120, 255, 2 * s)
    else
        text.draw(font.small, px + 16 * s, py + 42 * s, 210, 210, 222, 255, "JOB DONE")
        text.draw(font.small, px + 16 * s, py + 66 * s, 170, 170, 185, 255, string.format("JOBS %d   EARNED $%d", math.floor(f.jobs or 0), math.floor(f.earned or 0)))
    end
end)
