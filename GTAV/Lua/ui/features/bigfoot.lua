-- Bigfoot Hunt. Published fields: active (bool), fleeing (bool, he has spotted you), distance (metres to Bigfoot),
-- photos (shots taken), best (best photo so far: 0 none, 1 blurry, 2 decent, 3 front page), earned (cash from
-- photos), flash (1..0 right after the shutter), grade (grade of the last shot, same scale as best).
local grades = { [0] = "NO SHOT YET", "BLURRY", "DECENT", "FRONT PAGE" }

features.on_draw("Bigfoot Hunt", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0

    local fl = f.flash or 0
    if fl > 0 then draw.rect(0, 0, sw, sh, 255, 255, 255, math.floor(200 * fl * fl), 0) end

    local d = f.distance or 999
    local hint, r, g, b
    if f.fleeing then hint, r, g, b = "HE IS RUNNING!", 255, 90, 80
    elseif d < 45 then hint, r, g, b = "HE IS RIGHT THERE. CROUCH AND STAY QUIET", 255, 200, 80
    elseif d < 90 then hint, r, g, b = "THE PRINTS ARE FRESH", 170, 230, 140
    else hint, r, g, b = "FOLLOW THE FOOTPRINTS", 200, 200, 214 end

    local w, h = 270 * s, 104 * s
    local x0, y0 = 30 * s, sh * 0.5 - h / 2
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 18, 210, 12 * s)
    text.draw(font.hud_small, x0 + 14 * s, y0 + 8 * s, 235, 235, 245, 255, "BIGFOOT HUNT")
    text.draw(font.hud_tiny, x0 + 14 * s, y0 + 38 * s, r, g, b, math.floor(180 + 70 * math.sin(t * 3)), hint)
    local best = grades[math.floor(f.best or 0)] or ""
    text.draw(font.hud_tiny, x0 + 14 * s, y0 + 62 * s, 255, 220, 90, 230, "BEST PHOTO  " .. best)
    local tally = string.format("%d SHOTS   $%d", math.floor(f.photos or 0), math.floor(f.earned or 0))
    text.draw(font.hud_tiny, x0 + 14 * s, y0 + 82 * s, 190, 190, 205, 230, tally)

    if fl > 0 then
        local gr = math.floor(f.grade or 0)
        local msg = gr == 0 and "MISSED HIM" or grades[gr]
        local mr, mg, mb = 255, 90, 80
        if gr == 3 then mr, mg, mb = 255, 215, 90 elseif gr == 2 then mr, mg, mb = 170, 230, 140 elseif gr == 1 then mr, mg, mb = 200, 200, 214 end
        text.draw(font.display, sw / 2 - text.width(font.display, msg) / 2, sh * 0.3, mr, mg, mb, math.floor(255 * fl), msg)
    end
end)
