
-- Nenyoo scripting-API foundation bootstrap. Loaded FIRST. Establishes version + layer registry.
nenyoo = nenyoo or {}
nenyoo.api_version = 1
nenyoo.foundation  = true
-- nenyoo.layers(): the compat-layer descriptors registered by the loader ({ <name> = globals }).
function nenyoo.layers() return __api_layers or {} end

-- The default HUD scripts are published to the CDN ahead of the menu build that runs them. On a build older
-- than the pinned HUD font slots or the arc/ring primitives, fall back to the nearest theme slots and to arcs
-- drawn from line segments so those scripts still draw instead of erroring.
if font then
    font.display = font.display or font.title
    font.hud = font.hud or font.item
    font.hud_small = font.hud_small or font.small
    font.hud_tiny = font.hud_tiny or font.tiny
end
if draw and not draw.arc then
    function draw.arc(cx, cy, r, a0, a1, cr, cg, cb, ca, th)
        local n = math.max(2, math.ceil(math.abs(a1 - a0) / 0.1))
        local px, py = cx + math.cos(a0) * r, cy + math.sin(a0) * r
        for i = 1, n do
            local a = a0 + (a1 - a0) * i / n
            local nx, ny = cx + math.cos(a) * r, cy + math.sin(a) * r
            draw.line(px, py, nx, ny, cr, cg, cb, ca, th or 1)
            px, py = nx, ny
        end
    end
end
if draw and not draw.ring then
    function draw.ring(cx, cy, r_in, r_out, a0, a1, cr, cg, cb, ca)
        draw.arc(cx, cy, (r_in + r_out) / 2, a0, a1, cr, cg, cb, ca, r_out - r_in)
    end
end
