-- Paramedic Job / Firefighter Job. Published fields (both): active (bool, a call is running),
-- time_left (seconds), distance (metres to the current goal), pay (payout if finished now),
-- done (calls completed this session).
-- Paramedic Job also publishes phase: 1 reach the patient, 2 patient boarding, 3 drive to the hospital.
-- Firefighter Job also publishes fires (fires still burning at the scene).
-- Vigilante Job publishes active, time_left, distance (to the suspect), level, and surrender
-- (0..1 progress of a box-in arrest; present only while the suspect is pinned).
-- Tow Truck Job publishes the shared fields plus phase: 1 reach and hook the car, 2 haul it to the impound.
-- Garbage Truck Job publishes active, time_left, distance (to the next pickup), stop / stops (pickups done / total),
-- pay (earned this route), and loading (0..1, present only while parked at a pickup).
-- Taxi Job publishes the shared fields plus phase: 1 reach the fare, 2 fare boarding, 3 drive to the destination.
-- Repo Man Job publishes the shared fields plus phase: 1 find and steal the car, 2 deliver it to the lot.
-- Trucker Job publishes the shared fields plus hitched (bool, the trailer is on your cab); distance is trailer to destination.
-- Lifeguard Job publishes the shared fields plus phase: 1 reach the swimmer, 2 bring them to shore.
-- Bounty Hunter Job publishes the shared fields plus phase: 1 search the area, 2 catch the fugitive, 3 arrest them; pay is the bounty.
-- Pilot Job publishes the shared fields plus dest (airfield name) and landing (true within 1.2 km of it).
-- Bus Driver Job publishes the shared fields plus phase (1 drive, 2 boarding), stop, stops and riders; time_left is the on-time window.
-- Smuggler Job publishes the shared fields plus phase: 1 pick up the floating cargo, 2 run it to the buyer; pay is the payout.
-- Paper Route publishes the shared fields plus papers (left to throw), houses (doorsteps marked so far) and total; pay is earned so far.
-- Mechanic Job publishes the shared fields plus phase (1 drive to the call-out, 2 fix the car) and progress (0..1 while repairing).
-- Valet Job publishes the shared fields plus phase: 1 waiting for a guest, 2 take the car, 3 park it, 4 back to the stand; pay is the shift so far.
-- Bomb Squad publishes the shared fields plus phase (1 drive to the area, 2 search, 3 defusing), signal (0..1, closer to the bomb)
-- and progress (0..1 while defusing); distance is to the centre of the search area.
-- Lost Pet publishes the shared fields plus phase (1 meet the owner, 2 find the dog, 3 walk it back); pay is the reward.
-- VIP Escort publishes the shared fields plus vip_health (0..1) and waiting (bool, the VIP stopped because you fell behind);
-- distance is VIP to the car.
-- Animal Control publishes the shared fields plus phase (1 find and stun it, 2 cage it) and sedation (0..1 left before it wakes).

local function panel(title, sub, f, progress)
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local pad = 10 * s
    local t = math.max(0, f.time_left or 0)
    local clock = string.format("%d:%02d", math.floor(t / 60), math.floor(t % 60))

    local tw = text.width(font.tiny, title)
    local cw = text.width(font.title, clock)
    local sw2 = text.width(font.tiny, sub)
    local w = math.max(tw, cw, sw2) + pad * 2
    local h = text.height(font.tiny) * 2 + text.height(font.title) + pad * 2 + 4 * s
    local x = sw - w - 28 * s
    local y = sh * 0.42

    draw.rect(x, y, x + w, y + h, 10, 10, 16, 165, 6 * s)
    draw.rect(x, y, x + 3 * s, y + h, ar, ag, ab, 255, 0)
    local cy = y + pad
    text.draw(font.tiny, x + w - pad - tw, cy, ar, ag, ab, 255, title)
    cy = cy + text.height(font.tiny) + 2 * s
    local r, g, b = 245, 245, 250
    if t < 20 then r, g, b = 235, 70, 70 end
    text.draw(font.title, x + w - pad - cw, cy, r, g, b, 255, clock)
    cy = cy + text.height(font.title) + 2 * s
    text.draw(font.tiny, x + w - pad - sw2, cy, 200, 200, 210, 230, sub)
    if progress then
        draw.rect(x + pad, y + h - 5 * s, x + w - pad, y + h - 2 * s, 0, 0, 0, 150, 0)
        draw.rect(x + pad, y + h - 5 * s, x + pad + (w - pad * 2) * progress, y + h - 2 * s, ar, ag, ab, 255, 0)
    end
end

local function metres(d)
    d = d or 0
    if d >= 1000 then return string.format("%.1f KM", d / 1000) end
    return string.format("%d M", math.floor(d))
end

features.on_draw("Paramedic Job", function(f)
    if not f.active then return end
    local phase = math.floor(f.phase or 1)
    local title = phase == 3 and "GET TO THE HOSPITAL" or (phase == 2 and "PATIENT BOARDING" or "REACH THE PATIENT")
    panel(title, string.format("%s   $%d   SAVED %d", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0)), f)
end)

features.on_draw("Firefighter Job", function(f)
    if not f.active then return end
    local close = (f.distance or 0) < 40
    local title = close and "PUT OUT THE FIRE" or "RESPOND TO THE FIRE"
    local sub
    if close then
        sub = string.format("%d FIRES LEFT   $%d", math.floor(f.fires or 0), math.floor(f.pay or 0))
    else
        sub = string.format("%s   $%d   PUT OUT %d", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0))
    end
    panel(title, sub, f)
end)

features.on_draw("Vigilante Job", function(f)
    if not f.active then return end
    local title = f.surrender and "HOLD THEM THERE" or "CHASE THE SUSPECT"
    panel(title, string.format("%s   LEVEL %d", metres(f.distance), math.floor(f.level or 0) + 1), f, f.surrender)
end)

features.on_draw("Tow Truck Job", function(f)
    if not f.active then return end
    local title = math.floor(f.phase or 1) == 2 and "HAUL IT TO THE IMPOUND" or "HOOK THE CAR"
    panel(title, string.format("%s   $%d   TOWED %d", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0)), f)
end)

features.on_draw("Garbage Truck Job", function(f)
    if not f.active then return end
    local title = f.loading and "LOADING THE BAGS" or "NEXT PICKUP"
    local sub = string.format("%s   STOP %d/%d   $%d", metres(f.distance), math.floor(f.stop or 0) + 1, math.floor(f.stops or 6), math.floor(f.pay or 0))
    panel(title, sub, f, f.loading)
end)

features.on_draw("Taxi Job", function(f)
    if not f.active then return end
    local phase = math.floor(f.phase or 1)
    local title = phase == 3 and "DRIVE TO THE DESTINATION" or (phase == 2 and "FARE GETTING IN" or "PICK UP THE FARE")
    panel(title, string.format("%s   METER $%d   RIDES %d", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0)), f)
end)

features.on_draw("Bus Driver Job", function(f)
    if not f.active then return end
    local stop, stops = math.floor(f.stop or 1), math.max(1, math.floor(f.stops or 1))
    local title = math.floor(f.phase or 1) == 2 and "PASSENGERS BOARDING" or string.format("DRIVE TO STOP %d/%d", stop, stops)
    panel(title, string.format("%s   RIDERS %d   $%d   ROUTES %d", metres(f.distance), math.floor(f.riders or 0), math.floor(f.pay or 0), math.floor(f.done or 0)), f, (stop - 1) / stops)
end)

features.on_draw("Trucker Job", function(f)
    if not f.active then return end
    local title = f.hitched and "DELIVER THE LOAD" or "RE-HITCH THE TRAILER"
    panel(title, string.format("%s   $%d   LOADS %d", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0)), f)
end)

features.on_draw("Lifeguard Job", function(f)
    if not f.active then return end
    local title = math.floor(f.phase or 1) == 2 and "BRING THEM TO SHORE" or "REACH THE SWIMMER"
    panel(title, string.format("%s   $%d   RESCUES %d", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0)), f)
end)

features.on_draw("Bounty Hunter Job", function(f)
    if not f.active then return end
    local phase = math.floor(f.phase or 1)
    local title = phase == 3 and "ARREST THE FUGITIVE" or (phase == 2 and "CATCH THE FUGITIVE" or "SEARCH THE AREA")
    panel(title, string.format("%s   BOUNTY $%d   CAUGHT %d", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0)), f)
end)

features.on_draw("Pilot Job", function(f)
    if not f.active then return end
    local title = f.landing and "LAND AND STOP" or ("FLY TO " .. string.upper(f.dest or ""))
    panel(title, string.format("%s   FARE $%d   FLIGHTS %d", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0)), f)
end)

features.on_draw("Repo Man Job", function(f)
    if not f.active then return end
    local title = math.floor(f.phase or 1) == 2 and "DELIVER TO THE LOT" or "REPOSSESS THE CAR"
    panel(title, string.format("%s   $%d   REPOS %d", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0)), f)
end)

features.on_draw("Smuggler Job", function(f)
    if not f.active then return end
    local title = math.floor(f.phase or 1) == 2 and "RUN IT TO THE BUYER" or "PICK UP THE CARGO"
    panel(title, string.format("%s   $%d   RUNS %d", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0)), f)
end)

features.on_draw("Paper Route", function(f)
    if not f.active then return end
    local title = string.format("PAPER ROUTE  %d/%d", math.floor(f.houses or 0), math.floor(f.total or 0))
    panel(title, string.format("%s   PAPERS %d   DELIVERED %d   $%d", metres(f.distance), math.floor(f.papers or 0), math.floor(f.done or 0), math.floor(f.pay or 0)), f)
end)

features.on_draw("Mechanic Job", function(f)
    if not f.active then return end
    local fixing = math.floor(f.phase or 1) == 2
    local progress = (f.progress or 0) > 0 and f.progress or nil
    local title = progress and "REPAIRING" or (fixing and "FIX THE CAR" or "REACH THE CALL-OUT")
    panel(title, string.format("%s   $%d   JOBS %d", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0)), f, progress)
end)

features.on_draw("Valet Job", function(f)
    if not f.active then return end
    local titles = { "WAITING FOR A GUEST", "TAKE THE CAR", "PARK IN THE BAY", "BACK TO THE STAND" }
    local title = titles[math.floor(f.phase or 1)] or titles[1]
    panel(title, string.format("%s   $%d   PARKED %d/6", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0)), f)
end)

features.on_draw("Bomb Squad", function(f)
    if not f.active then return end
    local phase = math.floor(f.phase or 1)
    local stats = string.format("$%d   DEFUSED %d", math.floor(f.pay or 0), math.floor(f.done or 0))
    if phase == 1 then
        panel("REACH THE AREA", metres(f.distance) .. "   " .. stats, f)
    elseif phase == 2 then
        panel("FIND THE BOMB", string.format("SIGNAL %d%%   ", math.floor((f.signal or 0) * 100)) .. stats, f, math.max(0.02, f.signal or 0))
    else
        panel("DEFUSING", stats, f, f.progress or 0)
    end
end)

features.on_draw("Lost Pet", function(f)
    if not f.active then return end
    local titles = { "MEET THE OWNER", "FIND THE DOG", "WALK IT BACK" }
    local title = titles[math.floor(f.phase or 1)] or titles[1]
    panel(title, string.format("%s   $%d   FOUND %d", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0)), f)
end)

features.on_draw("VIP Escort", function(f)
    if not f.active then return end
    local title = f.waiting and "STAY CLOSE TO THE VIP" or "ESCORT THE VIP"
    local hp = math.floor((f.vip_health or 0) * 100)
    panel(title, string.format("%s   VIP %d%%   $%d   JOBS %d", metres(f.distance), hp, math.floor(f.pay or 0), math.floor(f.done or 0)), f, math.max(0.01, f.vip_health or 0))
end)

features.on_draw("Animal Control", function(f)
    if not f.active then return end
    local caging = math.floor(f.phase or 1) == 2
    local title = caging and "CAGE IT BEFORE IT WAKES" or "STUN THE ANIMAL"
    panel(title, string.format("%s   $%d   CAUGHT %d", metres(f.distance), math.floor(f.pay or 0), math.floor(f.done or 0)), f, caging and (f.sedation or 0) or nil)
end)
