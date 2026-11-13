
-- nenyoo_builtin_theme_version=9
theme_full = true
menu.set_navigation_style("tabs")
local logo_font=font.logo or font.title

local palette = {
    bg={17,17,22,250}, panel={23,23,30,255}, card={23,23,30,255},
    input={14,14,19,255}, side={34,33,44,255}, border={255,255,255,16},
    text={233,232,240,255}, dim={138,136,152,255}, faint={104,102,118,255},
    accent={168,139,255,255}, accentHi={194,176,255,255},
    accentLo={124,95,235,255}, green={168,139,255,255},
    logoNen={168,139,255,255}, logoYoo={255,255,255,255},
    sidebar={12,12,17,250}, header={17,17,22,250}, groupHeader={23,23,30,255}
}

-- One definition drives registration, persistence, reset, and the settings cards.
local color_settings={
    {"Accent","accent","accent"},{"Background","background","bg"},{"Panel","panel","panel"},
    {"Nen Color","logo_nen","logoNen"},{"yoo Color","logo_yoo","logoYoo"},
    {"Sidebar","sidebar_color","sidebar"},{"Header","header_color","header"},
    {"Group Header","group_header","groupHeader","group_header"},
    {"Input","input_color","input","input"},{"Selection","selection_color","side","selection"},
    {"Text","text_color","text","text"},{"Muted Text","muted_text","dim","muted_text"},
    {"Section Text","section_text","faint","section_text"},{"Border","border_color","border","border"}
}
for _,entry in ipairs(color_settings) do entry.default={table.unpack(palette[entry[3]])} end
local layout_sliders={
    {"Group Columns","columns",3,1,3,"Maximum columns; adapts to available width"},
    {"Group Spacing","group_spacing",16,8,28,"Space between groups"},
    {"Row Spacing","row_spacing",0,0,12,"Extra space between feature controls"},
    {"Scroll Speed","scroll_speed",70,20,140,"Scroll distance per wheel step"}
}
local navigation_toggles={
    {"Sidebar Labels","sidebar_labels",true},{"Sidebar Icons","sidebar_icons",true},
    {"Collapse Sidebar","sidebar_collapsed",false}
}
local ui_options={columns=3,group_spacing=16,row_spacing=0,scroll_speed=70,
    sidebar_labels=true,sidebar_icons=true,sidebar_collapsed=false}
-- Halo layout metrics shared by the window, sidebar, header, and cards.
local halo={header=100,card_head=36,card_pad=14,card_bottom=10,page_title="",page_section="",
    sidebar_compact=68,sidebar_full=216,tooltip=nil}
local function read_config()
    local out, raw = {}, file.read("theme_settings.ini")
    if type(raw) ~= "string" then return out end
    for key,value in raw:gmatch("([%w_]+)=([^\r\n]+)") do out[key]=value end
    return out
end
local saved=read_config()
-- Put both games on the same FiveM reference appearance once. This only
-- resets visual settings; language, menu keys, and gameplay state live in
-- their own stores and remain untouched.
local appearance_revision="halo_1"
if saved.appearance_revision~=appearance_revision then
    for _,entry in ipairs(color_settings) do saved[entry[2]]=nil end
    for _,entry in ipairs(layout_sliders) do saved[entry[2]]=nil end
    for _,entry in ipairs(navigation_toggles) do saved[entry[2]]=nil end
    for _,key in ipairs({"sidebar","sidebar_layout","radius","title_size","item_size","small_size",
        "value_size","desc_size","label_size","tagline_size","tiny_size","motion_enabled","motion_speed"}) do
        saved[key]=nil
    end
end
-- Typography defaults revision; a new value re-applies the defaults once over saved values.
local typography_revision="halo_1"
if saved.typography_revision~=typography_revision then
    for _,key in ipairs({"title_size","item_size","small_size","value_size","desc_size","label_size","tagline_size",
        "tiny_size","title_weight","item_weight","small_weight","value_weight","desc_weight","label_weight",
        "tagline_weight","tiny_weight","tab_weight"}) do saved[key]=nil end
end
local function num(key,fallback) return tonumber(saved[key]) or fallback end
local function saved_color(key,fallback)
    local value=saved[key]
    if not value then return table.unpack(fallback) end
    local r,g,b,a=value:match("(%d+),(%d+),(%d+),(%d+)")
    if not r then return table.unpack(fallback) end
    local function channel(v) return math.max(0,math.min(255,tonumber(v))) end
    return channel(r),channel(g),channel(b),channel(a)
end

menu.clear_settings()
menu.add_setting_submenu("Nenyoo Appearance","Layout and complete Lua palette")
for _,entry in ipairs(color_settings) do
    menu.add_sub_color(entry[1],saved_color(entry[2],entry.default))
end
menu.add_sub_slider("Sidebar Width",math.max(180,math.min(260,num("sidebar",216))),180,260,1,"Left navigation width")
menu.add_sub_slider("Corner Radius",num("radius",10),0,18,1,"Cards and controls")
menu.add_setting_submenu("UI Layout","Spacing, scrolling, and navigation")
for _,entry in ipairs(layout_sliders) do
    menu.add_sub_slider(entry[1],math.max(entry[4],math.min(entry[5],num(entry[2],entry[3]))),entry[4],entry[5],1,entry[6])
end
for _,entry in ipairs(navigation_toggles) do
    menu.add_sub_toggle(entry[1],num(entry[2],entry[3] and 1 or 0)~=0)
end
menu.add_setting_submenu("Typography","Font sizes are controlled by Lua")
menu.add_sub_slider("Title Size",num("title_size",20),16,32,1)
menu.add_sub_slider("Item Size",num("item_size",12),10,20,1)
menu.add_sub_slider("Small Size",num("small_size",10),8,16,1)
menu.add_sub_slider("Value Size",num("value_size",11),9,18,1)
menu.add_sub_slider("Description Size",num("desc_size",9),8,16,1)
menu.add_sub_slider("Section Label Size",num("label_size",12),8,14,1)
menu.add_sub_slider("Tagline Size",num("tagline_size",9),8,16,1)
menu.add_sub_slider("Overlay Text Size",num("tiny_size",8),7,14,1)
-- Weight per text group: {setting, saved key, font, default, card label}.
-- Inter is embedded at 400/500/600/700/800, so weights snap to hundreds.
local font_weights={
    {"Title Weight","title_weight","title",600,"Brand"},
    {"Item Weight","item_weight","item",500,"Menu Items"},
    {"Small Weight","small_weight","small",400,"Small Text"},
    {"Value Weight","value_weight","value",600,"Values"},
    {"Description Weight","desc_weight","desc",400,"Descriptions"},
    {"Section Label Weight","label_weight","label",700,"Group Titles"},
    {"Tagline Weight","tagline_weight","tagline",500,"Tagline"},
    {"Overlay Text Weight","tiny_weight","tiny",600,"Overlay Text"},
    {"Tab Weight","tab_weight","breadcrumb",600,"Header Tabs"}
}
for _,entry in ipairs(font_weights) do
    menu.add_sub_slider(entry[1],num(entry[2],entry[4]),400,800,100,"Text thickness, 400 Regular to 800 Extra Bold")
end
menu.add_setting_submenu("Motion","Restrained interface animation")
menu.add_sub_toggle("Animations Enabled",num("motion_enabled",1)~=0,"Enable interface transitions")
menu.add_sub_slider("Motion Speed",num("motion_speed",1),.5,2,.05,"Animation speed multiplier")

local motion_enabled=true
local motion_speed=1
local combat_tab=1
local aim_keybind_id,aim_keybind_seen=0xD005,false
local visual_tabs={Visuals="ESP",["VFX's"]="Sky"}
local visuals_header_scroll=0
local visuals_header_last_tab=nil
local visuals_header_drag=false
local search_target=nil
local settings_tab="General"
local settings_tab_names={"General","Layout","Colors","Config"}
local fv={focus=nil,events_tab="Live",events_tab_names={"Live","Trigger","Scanner"}}
local function settings_section_for(page_id,handle)
    local item=handle and items.at(handle)
    if page_id==items.joaat("Settings") then
        if not item then return settings_tab end
        if item.name=="Theme" or item.name=="Choose Theme" or item.name=="Reload Lua Theme" or
           item.name=="Reset Theme" or item.name=="Open Themes Folder" then return "Config" end
        if item.name=="Auto UI Scale" or item.name=="UI Scale" or
           item.name=="Overlays/Panels Scale" or item.name=="Streamer Mode" then return "General" end
        return "Layout"
    end
    if page_id==items.joaat("Load Theme") then return "Config" end
    if page_id==items.joaat("Streamer Mode") then return "General" end
    if page_id==items.joaat("Nenyoo Appearance") then
        return (not item or item.type==item_type.color) and "Colors" or "Layout"
    end
    for _,name in ipairs({"UI Layout","Typography","Motion","Theme Settings"}) do
        if page_id==items.joaat(name) then return "Layout" end
    end
end
local preview_recenter=false
local search_popup_bounds=nil
local search_popup_click=false

local function setting(name)
    local value=menu.get_setting(name)
    return type(value)=="table" and value or nil
end
local last_config=""
local function sync_settings()
    for _,entry in ipairs(color_settings) do
        local color=setting(entry[1])
        if color then palette[entry[3]]={color.r,color.g,color.b,color.a} end
        if entry[4] and theme.set_palette_color then theme.set_palette_color(entry[4],table.unpack(palette[entry[3]])) end
    end
    for _,entry in ipairs(layout_sliders) do
        local item=setting(entry[1])
        ui_options[entry[2]]=math.max(entry[4],math.min(entry[5],math.floor((item and item.f_val or entry[3])+.5)))
    end
    for _,entry in ipairs(navigation_toggles) do
        local item=setting(entry[1]); ui_options[entry[2]]=not item or item.on
    end
    local sidebar,radius=setting("Sidebar Width"),setting("Corner Radius")
    local title,item,small=setting("Title Size"),setting("Item Size"),setting("Small Size")
    local value,desc,label,tagline,tiny=setting("Value Size"),setting("Description Size"),setting("Section Label Size"),setting("Tagline Size"),setting("Overlay Text Size")
    local enabled_setting,speed_setting=setting("Animations Enabled"),setting("Motion Speed")
    local sv=sidebar and sidebar.f_val or 216
    local rv=radius and radius.f_val or 10
    if theme.set_panel_radius then theme.set_panel_radius(rv) end
    local tv=title and title.f_val or 20
    local iv=item and item.f_val or 12
    local sm=small and small.f_val or 10
    local vv=value and value.f_val or 11
    local dv=desc and desc.f_val or 9
    local lv=label and label.f_val or 12
    local gv=tagline and tagline.f_val or 9
    local nv=tiny and tiny.f_val or 8
    motion_enabled=not enabled_setting or enabled_setting.on
    motion_speed=speed_setting and speed_setting.f_val or 1
    if ui.set_motion then ui.set_motion(motion_enabled,motion_speed) end
    local ar,ag,ab=palette.accent[1],palette.accent[2],palette.accent[3]
    palette.accentHi={math.floor(ar+(255-ar)*.18),math.floor(ag+(255-ag)*.18),math.floor(ab+(255-ab)*.18),palette.accent[4]}
    palette.accentLo={math.floor(ar*.74),math.floor(ag*.68),math.floor(ab*.96),palette.accent[4]}
    theme.set_accent_palette(ar,ag,ab,palette.accent[4])
    theme.set_body_bg(table.unpack(palette.bg)); theme.set_menu_bg(table.unpack(palette.panel))
    text.set_size(font.title,tv); text.set_size(font.item,iv)
    text.set_size(font.value,vv); text.set_size(font.small,sm)
    text.set_size(font.breadcrumb,12); text.set_size(font.desc,dv); text.set_size(font.icon,14)
    text.set_size(font.label,lv); text.set_size(font.tagline,gv); text.set_size(font.tiny,nv)
    text.set_size(logo_font,tv); text.set_weight(logo_font,300)
    local weight_parts={}
    for _,entry in ipairs(font_weights) do
        local weight_item=setting(entry[1])
        local raw=weight_item and weight_item.f_val or entry[4]
        local weight=math.max(400,math.min(800,math.floor(raw/100+.5)*100))
        if weight_item and raw~=weight and not input.mouse_down(0) then
            local handle=items.get("Typography",entry[1])
            if handle then items.set_f_val(handle,weight) end
        end
        text.set_weight(font[entry[3]],weight)
        weight_parts[#weight_parts+1]=entry[2].."="..weight.."\r\n"
    end
    local encoded=string.format(
        "appearance_revision=%s\r\ndesign_revision=midnight_1\r\npalette_revision=lavender_1\r\nsidebar_layout=3\r\nsidebar=%.0f\r\nradius=%.0f\r\ntitle_size=%.0f\r\nitem_size=%.0f\r\nsmall_size=%.0f\r\nvalue_size=%.0f\r\ndesc_size=%.0f\r\nlabel_size=%.0f\r\ntagline_size=%.0f\r\ntiny_size=%.0f\r\nmotion_enabled=%d\r\nmotion_speed=%.2f\r\n",
        appearance_revision,
        sv,rv,tv,iv,sm,vv,dv,lv,gv,nv,motion_enabled and 1 or 0,motion_speed)
    local parts={encoded}
    for _,entry in ipairs(color_settings) do
        parts[#parts+1]=entry[2].."="..table.concat(palette[entry[3]],",").."\r\n"
    end
    for _,entry in ipairs(layout_sliders) do parts[#parts+1]=entry[2].."="..ui_options[entry[2]].."\r\n" end
    for _,entry in ipairs(navigation_toggles) do parts[#parts+1]=entry[2].."="..(ui_options[entry[2]] and "1" or "0").."\r\n" end
    for _,part in ipairs(weight_parts) do parts[#parts+1]=part end
    parts[#parts+1]="typography_revision="..typography_revision.."\r\n"
    encoded=table.concat(parts)
    if encoded~=last_config then last_config=encoded; file.write("theme_settings.ini",encoded) end
    return sv,rv
end

local function reset_appearance()
    for _,entry in ipairs(color_settings) do
        local handle=items.get("Nenyoo Appearance",entry[1])
        if handle then items.set_color(handle,table.unpack(entry.default)) end
    end
    local sliders={{"Nenyoo Appearance","Sidebar Width",216},{"Nenyoo Appearance","Corner Radius",10},
        {"Motion","Motion Speed",1},{"Typography","Title Size",20},{"Typography","Item Size",12},
        {"Typography","Small Size",10},{"Typography","Value Size",11},{"Typography","Description Size",9},
        {"Typography","Section Label Size",12},{"Typography","Tagline Size",9},{"Typography","Overlay Text Size",8}}
    for _,entry in ipairs(layout_sliders) do sliders[#sliders+1]={"UI Layout",entry[1],entry[3]} end
    for _,entry in ipairs(font_weights) do sliders[#sliders+1]={"Typography",entry[1],entry[4]} end
    for _,entry in ipairs(sliders) do
        local handle=items.get(entry[1],entry[2]); if handle then items.set_f_val(handle,entry[3]) end
    end
    local toggles={{"Motion","Animations Enabled",true}}
    for _,entry in ipairs(navigation_toggles) do toggles[#toggles+1]={"UI Layout",entry[1],entry[3]} end
    for _,entry in ipairs(toggles) do
        local handle=items.get(entry[1],entry[2]); local item=handle and items.at(handle)
        if item and item.on~=entry[3] then items.toggle(handle) end
    end
    sync_settings()
end

local function rgba(c,a) return c[1],c[2],c[3],a or c[4] end
local function txt(face,x,y,color,value)
    text.draw(face,x,y,color[1],color[2],color[3],color[4],tostring(value or ""))
end
local function txt_wrap(face,x,y,color,value,max_w)
    text.draw(face,x,y,color[1],color[2],color[3],color[4],tostring(value or ""),max_w)
end
local function txt_ellipsis(face,x,y,color,value,max_w)
    text.draw_ellipsis(face,x,y,color[1],color[2],color[3],color[4],tostring(value or ""),max_w)
end
local function inside(x,y,w,h)
    local mx,my=input.mouse_x(),input.mouse_y()
    return mx>=x and mx<=x+w and my>=y and my<=y+h
end
local function clicked(x,y,w,h) return inside(x,y,w,h) and input.mouse_clicked(0) end
local motion_values={}
local function motion_to(key,target,speed,initial)
    if not motion_enabled then motion_values[key]=target; return target end
    local value=motion_values[key]
    if value==nil then value=initial~=nil and initial or target end
    local ease=1-math.exp(-(speed or 16)*motion_speed*math.min(.1,ctx.delta()))
    value=value+(target-value)*ease
    if math.abs(target-value)<.0005 then value=target end
    motion_values[key]=value
    return value
end
local function motion_reset(key,value) motion_values[key]=value end
local function smooth_scroll(id,current,maximum,hovered,step,speed)
    step=step*ui_options.scroll_speed/70
    if motion_enabled then
        return ui.scroll_smooth(id,current,maximum,hovered,step,speed*motion_speed)
    end
    if hovered then current=current-input.mouse_wheel()*step end
    return math.max(0,math.min(maximum,current))
end
local function mix_color(a,b,t)
    t=math.max(0,math.min(1,t))
    return {
        math.floor(a[1]+(b[1]-a[1])*t+.5),math.floor(a[2]+(b[2]-a[2])*t+.5),
        math.floor(a[3]+(b[3]-a[3])*t+.5),math.floor(a[4]+(b[4]-a[4])*t+.5)
    }
end
local transition={stage="idle",phase=1,pending=nil,serial=0}
local function perform_navigation(request)
    if not request then return end
    if ui.cancel_menu_keybind then
        ui.cancel_menu_keybind(0xD001); ui.cancel_menu_keybind(0xD003)
        ui.cancel_menu_keybind(aim_keybind_id)
    end
    if request.kind=="settings" then
        settings_tab=request.target
        menu.replace_page(items.joaat("Settings"))
    elseif request.kind=="tab" then menu.switch_tab(request.target)
    elseif request.kind=="combat" then combat_tab=request.target
    elseif request.kind=="events" then
        fv.events_tab=request.target
        if menu.page_id()~=items.joaat("Events") then menu.replace_page(items.joaat("Events")) end
    elseif request.kind=="visuals" or request.kind=="vfx" then
        local root=request.kind=="vfx" and "VFX's" or "Visuals"
        visual_tabs[root]=request.target
        if menu.page_id()~=items.joaat(root) then menu.replace_page(items.joaat(root)) end
    elseif request.kind=="search" then
        local target=request.target
        search_target=target.handle and {
            handle=target.handle,page_id=target.page_id,
            pending=true,expires=ctx.time()+3
        } or nil
        local section=settings_section_for(target.page_id,target.handle)
        if section then settings_tab=section; menu.navigate(items.joaat("Settings"))
        else menu.navigate(target.page_id) end
    elseif request.kind=="page" then menu.navigate(request.target) end
end
local function request_navigation(kind,target)
    if not motion_enabled then perform_navigation({kind=kind,target=target}); return end
    transition.pending={kind=kind,target=target}
    transition.stage="out"
    transition.phase=0
    transition.serial=transition.serial+1
end
local function ease_out_expo(t) if t>=1 then return 1 end; return 1-2^(-10*t) end

local function update_transition()
    if not motion_enabled then
        perform_navigation(transition.pending)
        transition.pending=nil; transition.stage="idle"; transition.phase=1
        return 1,0,1
    end
    local dt=math.min(.1,ctx.delta())*motion_speed
    if transition.stage=="out" then
        -- Skip the out fade — navigate immediately, let the new content fade
        -- in over the old. Feels like a smooth crossfade rather than a
        -- flash-to-nothing-then-fade-back.
        perform_navigation(transition.pending)
        transition.pending=nil
        transition.stage="in"
        transition.phase=0
        return 1,0,0
    elseif transition.stage=="in" then
        -- Single long ease-out-expo fade — decelerates deep into the tail so
        -- there's no visible snap at the end.
        transition.phase=math.min(1,transition.phase+dt/.55)
        local eased=ease_out_expo(transition.phase)
        if transition.phase>=1 then transition.stage="idle" end
        return eased,0,eased
    end
    return 1,0,1
end
local content_alpha,content_offset,content_progress=1,0,1
local function card_entry_offset(index)
    -- No cascade offset — cards fade in together as one calm crossfade.
    return 0
end
local function fill(x,y,w,h,color,radius,alpha)
    draw.rect(x,y,x+w,y+h,color[1],color[2],color[3],alpha or color[4],radius or 0)
end
local function outline(x,y,w,h,color,radius,thickness)
    draw.rect_outline(x,y,x+w,y+h,color[1],color[2],color[3],color[4],radius or 0,thickness or 1)
end
local function line(x1,y1,x2,y2,color,thickness)
    draw.line(x1,y1,x2,y2,color[1],color[2],color[3],color[4],thickness or 1)
end
local function draw_window_surfaces(x,y,w,h,sidebar,radius)
    local function same(a,b)
        for i=1,4 do if a[i]~=b[i] then return false end end
        return true
    end
    if same(palette.bg,palette.sidebar) and same(palette.bg,palette.header) then
        fill(x,y,w,h,palette.bg,radius)
        line(x+sidebar,y,x+sidebar,y+h,palette.border,1)
        outline(x,y,w,h,palette.border,radius)
        return
    end
    -- Each region gets a single translucent fill, with one shared outer shape.
    -- This also keeps independent sidebar/header alpha edits from stacking on bg.
    local regions={
        {x,y,x+sidebar,y+h,palette.sidebar},
        {x+sidebar,y,x+w,y+halo.header,palette.header},
        {x+sidebar,y+halo.header,x+w,y+h,palette.bg}
    }
    for _,region in ipairs(regions) do
        draw.push_clip(region[1],region[2],region[3],region[4])
        fill(x,y,w,h,region[5],radius)
        draw.pop_clip()
    end
    line(x+sidebar,y,x+sidebar,y+h,palette.border,1)
    outline(x,y,w,h,palette.border,radius)
end
local function button(x,y,w,h,label,primary,radius)
    local hover=inside(x,y,w,h)
    local r=8
    fill(x,y,w,h,hover and palette.side or palette.input,r)
    outline(x,y,w,h,primary and {palette.accent[1],palette.accent[2],palette.accent[3],110} or palette.border,r)
    local tw=text.width(font.value,label)
    txt_ellipsis(font.value,x+math.max(6,(w-tw)*.5),y+(h-text.height(font.value))*.5,
        primary and palette.accentHi or palette.text,label,w-12)
    return clicked(x,y,w,h)
end

-- Halo card: one rounded surface, bold title row, optional count on the right.
local function panel(x,y,w,h,title,count,radius)
    local head=math.min(h,halo.card_head)
    fill(x,y,w,h,palette.groupHeader,radius)
    if h>head then
        fill(x,y+head,w,h-head,palette.panel,radius)
        fill(x,y+head,w,math.min(radius,h-head),palette.panel,0)
    end
    outline(x,y,w,h,palette.border,radius)
    local right=0
    if count and count~="" then
        right=text.width(font.small,count)+30
        txt(font.small,x+w-right+4,y+(head-text.height(font.small))*.5,palette.faint,count)
    end
    txt_ellipsis(font.label,x+halo.card_pad,y+(head-text.height(font.label))*.5,palette.text,title,w-halo.card_pad*2-right)
    local pad=halo.card_pad
    return x+pad,y+head,w-pad*2,math.max(0,h-head-halo.card_bottom)
end
-- Loader-style edge fades: subtle gradient at the top/bottom of a scrollable
-- viewport, showing when there is more content in that direction.
local function scroll_fades(x,y,w,h,current,max_scroll,depth,corner_radius)
    depth=depth or 34
    local br,bgc,bb=palette.bg[1],palette.bg[2],palette.bg[3]
    local ta=math.min(1,current/30)
    local ba=math.min(1,math.max(0,(max_scroll-current)/30))
    if ta>0.01 then
        local op=math.floor(ta*255)
        draw.rect_gradient(x,y,x+w,y+depth,
            br,bgc,bb,op, br,bgc,bb,op,
            br,bgc,bb,0,  br,bgc,bb,0)
    end
    if ba>0.01 then
        local op=math.floor(ba*255)
        -- A square gradient would paint over the window's rounded bottom
        -- corners whenever there is more content below the viewport.
        local corner=math.min(math.max(0,math.ceil(corner_radius or 0)),depth-1)
        if corner==0 then
            draw.rect_gradient(x,y+h-depth,x+w,y+h,
                br,bgc,bb,0, br,bgc,bb,0,
                br,bgc,bb,op, br,bgc,bb,op)
        else
            local upper_alpha=math.floor(op*(depth-corner)/depth)
            draw.rect_gradient(x,y+h-depth,x+w,y+h-corner,
                br,bgc,bb,0, br,bgc,bb,0,
                br,bgc,bb,upper_alpha, br,bgc,bb,upper_alpha)
            for row=0,corner-1 do
                local inset=corner-math.sqrt(corner*corner-(row+.5)*(row+.5))
                local alpha=math.floor(op*(depth-corner+row+1)/depth)
                draw.rect(x+inset,y+h-corner+row,x+w-inset,y+h-corner+row+1,
                    br,bgc,bb,alpha)
            end
        end
    end
end

-- Font Awesome Free Solid glyphs (embedded). Keyed by page/tab name.
halo.fa={["Home"]="\239\128\149",["Self"]="\239\128\135",["Player"]="\239\131\128",["Online"]="\239\130\172",["Combat"]="\239\129\155",["Weapon"]="\238\134\155",["Vehicle"]="\239\134\185",["Teleport"]="\239\143\133",["Domain"]="\239\136\179",["Visuals"]="\239\129\174",["VFX's"]="\238\139\138",["UI"]="\239\148\191",["Lua Executor"]="\239\132\161",["Events"]="\239\149\130",["Misc"]="\239\135\158",["Cloud"]="\239\131\130",["Settings"]="\239\128\147",["Search"]="\239\128\130",["Sidebar"]="\239\131\155",["language"]="\239\130\172",["animations"]="\239\128\136",["display"]="\239\142\144"}
-- Draws a Font Awesome glyph centred on (x,y); false when the font is unavailable.
function halo.glyph(name,x,y,color)
    local glyph=halo.fa[name]
    if not glyph then return false end
    local w=text.width(font.icon,glyph)
    if w<=0 then return false end
    txt(font.icon,x-w*.5,y-text.height(font.icon)*.5,color,glyph)
    return true
end
local function nav_icon(name,x,y,color)
    if halo.glyph(name,x,y,color) then return end
    local function stroke(x1,y1,x2,y2) line(x1,y1,x2,y2,color,1.6) end
    if name=="Home" then
        stroke(x-8,y-1,x,y-7); stroke(x,y-7,x+8,y-1)
        stroke(x-6,y-2,x-6,y+7); stroke(x+6,y-2,x+6,y+7)
        stroke(x-6,y+7,x+6,y+7); stroke(x-2,y+7,x-2,y+2)
        stroke(x-2,y+2,x+2,y+2); stroke(x+2,y+2,x+2,y+7)
    elseif name=="Combat" then
        draw.circle_outline(x,y,6,color[1],color[2],color[3],color[4],1.6)
        draw.circle(x,y,2,rgba(color))
        stroke(x-9,y,x-6,y); stroke(x+6,y,x+9,y)
        stroke(x,y-9,x,y-6); stroke(x,y+6,x,y+9)
    elseif name=="Visuals" then
        stroke(x-9,y,x-4,y-5); stroke(x-4,y-5,x+4,y-5)
        stroke(x+4,y-5,x+9,y); stroke(x+9,y,x+4,y+5)
        stroke(x+4,y+5,x-4,y+5); stroke(x-4,y+5,x-9,y)
        draw.circle_outline(x,y,2.6,color[1],color[2],color[3],color[4],1.5)
    elseif name=="VFX's" then
        stroke(x-3,y-8,x-1,y-2); stroke(x-1,y-2,x+5,y)
        stroke(x+5,y,x-1,y+2); stroke(x-1,y+2,x-3,y+8)
        stroke(x-3,y+8,x-5,y+2); stroke(x-5,y+2,x-11,y)
        stroke(x-11,y,x-5,y-2); stroke(x-5,y-2,x-3,y-8)
        stroke(x+5,y-7,x+9,y-7); stroke(x+7,y-9,x+7,y-5)
    elseif name=="Misc" then
        stroke(x-8,y-6,x+8,y-6); stroke(x-8,y,x+8,y)
        stroke(x-8,y+6,x+8,y+6)
        draw.circle(x-3,y-6,2,rgba(color))
        draw.circle(x+4,y,2,rgba(color))
        draw.circle(x-1,y+6,2,rgba(color))
    elseif name=="Settings" then
        -- Cog: solid ring with a centre hole and eight square teeth.
        draw.circle_outline(x,y,4.4,color[1],color[2],color[3],color[4],3)
        for i=0,7 do
            local a=i*math.pi/4+math.pi/8; local c,s=math.cos(a),math.sin(a)
            line(x+c*5,y+s*5,x+c*8.4,y+s*8.4,color,3.2)
        end
    elseif name=="Lua Executor" then
        stroke(x-4,y-6,x-9,y); stroke(x-9,y,x-4,y+6)
        stroke(x+4,y-6,x+9,y); stroke(x+9,y,x+4,y+6)
        stroke(x+2,y-8,x-2,y+8)
    elseif name=="Events" then
        stroke(x-5,y-4,x+5,y-4)
        stroke(x-5,y-4,x,y+6); stroke(x+5,y-4,x,y+6)
        draw.circle(x-6,y-5,2,rgba(color))
        draw.circle(x+6,y-5,2,rgba(color))
        draw.circle(x,y+7,2,rgba(color))
    else
        draw.circle_outline(x,y,6,color[1],color[2],color[3],color[4],1.6)
    end
end



local function flag(code,x,y,w,h)
    ui.language_flag(code,x,y,w,h)
end

local language_open=false

local scroll,search,search_focus={},"",false
local search_expanded=false
local search_popup_query=""
local quick_open,quick_section,quick_anchor,quick_color=false,nil,nil,false
local quick_scroll=0
local slider_visual,slider_drag={},nil
local function focus_scroll(page_id,center,viewport,max_scroll)
    if search_target and search_target.pending and search_target.page_id==page_id then
        scroll[page_id]=math.max(0,math.min(max_scroll,center-viewport*.5))
        search_target.pending=false
    end
end
local option_visual={}
local option_open,option_anchor,option_seen=nil,nil,false
local color_open,color_anchor,color_seen=nil,nil,false
local function color_popup_rect(anchor)
    local screen_w,screen_h=ctx.screen_w()/ctx.ui_scale(),ctx.screen_h()/ctx.ui_scale()
    local width,height=math.min(280,screen_w-16),math.min(330,screen_h-16)
    local x=math.max(8,math.min(screen_w-width-8,anchor.x+anchor.w-width))
    local y=anchor.y+anchor.h+4
    if y+height>screen_h-8 then y=anchor.y-height-4 end
    return x,math.max(8,math.min(screen_h-height-8,y)),width,height
end
local color_pointer_capture=false
local function close_color_popup()
    color_open,color_anchor=nil,nil
    color_pointer_capture=false
    ui.close_color_picker()
end
local function color_swatch(handle,x,y,w,h)
    if not handle then return end
    if color_open==handle then
        color_seen=true
        color_anchor={x=x,y=y,w=w,h=h}
    end
    if clicked(x,y,w,h) then
        if color_open==handle then close_color_popup()
        else
            option_open,option_anchor=nil,nil
            color_open=handle
            color_anchor={x=x,y=y,w=w,h=h}
            color_seen=true
        end
        input.consume_mouse_click()
    end
end
local function color_popup_input()
    if not input.mouse_down(0) then color_pointer_capture=false end
    if not color_open or not color_anchor then return false end
    if input.key_just_pressed(VK.ESCAPE) then
        close_color_popup()
        color_pointer_capture=false
        return false
    end
    local x,y,w,h=color_popup_rect(color_anchor)
    local over=inside(x,y,w,h)
    if input.mouse_clicked(0) then
        if over then color_pointer_capture=true
        elseif not inside(color_anchor.x,color_anchor.y,color_anchor.w,color_anchor.h) then
            close_color_popup()
            return false
        end
    end
    return over or color_pointer_capture
end
local function draw_color_popup(radius)
    if not color_open or not color_anchor then return end
    local item=items.at(color_open)
    if not item then close_color_popup(); return end
    local x,y,w,h=color_popup_rect(color_anchor)
    -- The editor must remain usable when the panel color itself is transparent.
    fill(x,y,w,h,{palette.panel[1],palette.panel[2],palette.panel[3],255},radius)
    outline(x,y,w,h,palette.border,radius)
    txt(font.item,x+12,y+10,palette.text,item.name)
    local r,g,b,a,changed=ui.color_picker(0xC500+color_open,x+12,y+34,w-24,item.r,item.g,item.b,item.a,h-46)
    if changed then
        items.set_color(color_open,r,g,b,a)
        local accent_handle=items.get("Nenyoo Appearance","Accent")
        if color_open==accent_handle then
            local nen_handle=items.get("Nenyoo Appearance","Nen Color")
            if nen_handle then items.set_color(nen_handle,r,g,b,a) end
            palette.logoNen={r,g,b,a}
        end
    end
end
local function option_popup_rect(anchor,count)
    local width=math.max(150,anchor.w)
    local height=count*30+8
    local screen_w,screen_h=ctx.screen_w()/ctx.ui_scale(),ctx.screen_h()/ctx.ui_scale()
    local x=math.max(8,math.min(screen_w-width-8,anchor.x+anchor.w-width))
    local y=anchor.y+anchor.h+4
    if y+height>screen_h-8 then y=anchor.y-height-4 end
    return x,math.max(8,y),width,height
end
local function option_popup_input()
    if not option_open or not option_anchor or not input.mouse_clicked(0) then return end
    local values=items.values(option_open)
    local x,y,w,h=option_popup_rect(option_anchor,#values)
    if inside(x,y,w,h) then
        local index=math.floor((input.mouse_y()-y-4)/30)+1
        if index>=1 and index<=#values then items.set_value_index(option_open,index-1) end
        option_open,option_anchor=nil,nil
        input.consume_mouse_click()
    elseif not inside(option_anchor.x,option_anchor.y,option_anchor.w,option_anchor.h) then
        option_open,option_anchor=nil,nil
    end
end
local function draw_option_popup(radius)
    if not option_open or not option_anchor then return end
    local values=items.values(option_open)
    if #values==0 then option_open,option_anchor=nil,nil; return end
    local x,y,w,h=option_popup_rect(option_anchor,#values)
    fill(x+2,y+5,w,h,{0,0,0,125},radius)
    fill(x,y,w,h,palette.panel,radius)
    outline(x,y,w,h,palette.border,radius)
    local item=items.at(option_open)
    for i,value in ipairs(values) do
        local ry=y+4+(i-1)*30
        local hovered=inside(x+4,ry,w-8,30)
        local active=item and item.value_index==i-1
        if hovered or active then fill(x+4,ry,w-8,30,active and {palette.accent[1],palette.accent[2],palette.accent[3],36} or palette.side,7) end
        txt_ellipsis(font.value,x+15,ry+8,active and palette.accentHi or palette.text,value,w-38)
        if active then txt(font.value,x+w-20,ry+8,palette.accentHi,"✓") end
    end
end
local combat_definitions={
    {name="Lock-on Aimbot",
     left={{title="Aim",first=1,last=5},{title="Target Selection",first=6,last=10},{title="Lock Behavior",first=11,last=13}},
     right={{title="Prediction",first=14,last=15},{title="Response",first=16,last=20},{title="Friends & Overlay",first=21,last=24}}},
    {name="Silent Aim",
     left={{title="Aim",first=1,last=5}},
     right={{title="Shot Behavior",first=6,last=9}}},
    {name="Magic Bullet",
     left={{title="Aim",first=1,last=3}},
     right={{title="Targeting",first=4,last=5}}}
}
local function combat_tabs_list()
    local tabs={}
    local selected_available=false
    for index,tab in ipairs(combat_definitions) do
        local link=items.get("Combat",tab.name)
        if link and items.submenu_page_id(link)~=0 then
            tab.index=index
            tabs[#tabs+1]=tab
            if combat_tab==index then selected_available=true end
        end
    end
    if not selected_available then combat_tab=tabs[1] and tabs[1].index or 1 end
    return tabs
end
local visuals_definition={
    left={
        {title="Ped Display",items={"Enable Ped ESP","ESP Distance","Color Mode","Show Friends","Friend Color","Off-screen Indicators"}},
        {title="Boxes",items={"Enable Boxes","Box Style","Box Color","Gradient End","Rainbow Speed","Box Thickness"}},
        {title="Labels",items={"Model Names","Weapon Names","Distance Text","Vitals Text"}}
    },
    right={
        {title="Markers & Bars",items={"Basic Skeleton","Head Dot","Marker Color","Health Bars","Armor Bars"}},
        {title="Snaplines",items={"Enable Snaplines","Snapline Origin","Snapline End","Snapline Color","Snapline Thickness"}},
        {title="Vehicles",items={"Enable Vehicle ESP","Vehicle Health","Vehicle Names","Vehicle Distance"}},
        {title="Objects",items={"Enable Object ESP","Object Names","Object Distance"}}
    }
}
local misc_definition={
    left={{title="FOV Editor",items={"Override FOV","Field of View"}}},
    right={}
}
local vfx_definitions={
    Sky={
        left={{title="Sky Override",items={"Sky Intensity","Intensity"}},
              {title="Field Colour Animation",items={"Color Rainbow Speed"}}},
        right={{title="Rainbow Sky",items={"Rainbow Sky","Rainbow Sky Speed","Rainbow Sky Alpha"}}}
    },
    ["Post Processing"]={
        left={{title="Lighting & Reflection",items={"Shadow Light","Shadow Light Strength","Reflection","Reflection Strength","Gamma","Gamma Strength"}}},
        right={{title="Image Effects",items={"Blur","Blur Strength","Blur 2","Blur 2 Strength","Saturation","Saturation Strength"}}}
    },
    Weather={
        left={{title="Rain & Snow",items={"Rainstorm","Thunder","Snow Light","Snow Heavy","Blizzard"}}},
        right={{title="Ambient Effects",items={"Underwater","Lake Fog","Woodland Pollen","Woodland Firefly","Wetland Flies"}}}
    },
    Lightning={
        left={{title="Strike Control",items={"Enabled","Force Lightning","Strike Frequency"}}},
        right={{title="Lightning Colours",items={"Main Color","Corona Color","Rainbow","Rainbow Speed"}}}
    },
    Lighting={
        left={{title="Weather Lighting",items={"Lightning","Fog","Traffic Signals"}}},
        right={{title="World Lighting",items={"Ped Light","Street Light","Scene Lights"}}}
    },
    Fog={
        left={{title="Fog Colour",items={"Enabled","Color"}}},
        right={{title="Animation",items={"Rainbow","Rainbow Speed"}}}
    },
    ["Ped Light"]={
        left={{title="Ped Light Colour",items={"Enabled","Color"}}},
        right={{title="Animation",items={"Rainbow","Rainbow Speed"}}}
    },
    Water={
        left={{title="Ocean",items={"Ocean Height","Height","Transparent Ocean"}}},
        right={{title="Wetness",items={"Puddles","Puddle Amount"}}}
    },
    ["Water Color"]={
        left={{title="Directional Water",items={"Enabled","Override Directional","Directional Color","Directional Intensity"}}},
        right={{title="Ambient Water",items={"Override Ambient","Ambient Color","Ambient Intensity"}}}
    },
    Liquid={
        left={{title="Petrol Duration",items={"Petrol VFX","Foot Duration","Wheel Duration"}}},
        right={{title="Petrol Appearance",items={"Foot Lifetime","Wheel Lifetime","Petrol Color","Rainbow","Rainbow Speed"}}}
    },
    Particles={
        left={{title="Particle Tint",items={"Enabled","Color"}}},
        right={{title="Animation",items={"Rainbow","Rainbow Speed"}}}
    },
    Fire={
        left={{title="Fire Tint",items={"Enabled","Color","Rainbow","Rainbow Speed"}}},
        right={{title="Fire Types",items={"Petrol Tank Fires","Vehicle Wreck Fires","Peds On Fire","Environmental Fires"}}}
    },
    Decals={left={},right={}},
    Footprints={
        left={{title="Footprint Colour",items={"Enabled","Color"}}},
        right={{title="Animation",items={"Rainbow","Rainbow Speed"}}}
    },
    ["Bullet Impact"]={
        left={{title="Impact Colour",items={"Enabled","Color"}}},
        right={{title="Animation",items={"Rainbow","Rainbow Speed"}}}
    },
    ["Vehicle Lighting"]={
        left={{title="Neon Lighting",items={"Neon"}}},
        right={{title="Vehicle Lights",items={"Vehicle Lights"}}}
    },
    Neon={
        left={{title="Neon Glow",items={"Enabled","Intensity","Radius","Falloff Exponent"}}},
        right={{title="Neon Shape",items={"Capsule Sides","Capsule Front/Back","Clip Plane Height","Bike Clip Height"}}}
    },
    ["Vehicle Lights"]={
        left={{title="Cabin & Plate",items={"Enabled","Interior Light","Plate Light"}}},
        right={{title="Dash & Door",items={"Dash Light","Door Light","Rainbow","Rainbow Speed"}}}
    },
    ["Traffic Signals"]={
        left={{title="Signal Colours",items={"Enabled","Red","Amber","Green","Walk","Don't Walk","Rainbow","Rainbow Speed"}}},
        right={{title="Fade Distances",items={"Far Fade Start","Far Fade End","Near Fade Start","Near Fade End"}}}
    },
    ["Street Light"]={
        left={{title="Light Colour",items={"Enabled","Mode","Hue","Saturation","Intensity","Custom Color"}}},
        right={{title="Rainbow Motion",items={"Frequency","Update Delay","Update Value","Min Value","Max Value"}}}
    },
    ["Scene Lights"]={
        left={{title="Light Colour",items={"Enabled","Mode","Hue","Saturation","Intensity","Custom Color"}}},
        right={{title="Rainbow Motion",items={"Frequency","Update Delay","Update Value","Min Value","Max Value"}}}
    },
    weather_effect={
        left={{title="Particle Motion",items={"Enabled","Velocity","Gravity","Box Size X","Box Size Y","Box Size Z","Life Min","Life Max"}}},
        right={{title="Particle Appearance",items={"Size Min","Size Max","Edge Softness","Local Lights","Particle Color %","Color","Luminance","Rainbow","Rainbow Speed"}}}
    }
}
local weather_effect_names={
    Rainstorm=true,Thunder=true,["Snow Light"]=true,["Snow Heavy"]=true,Blizzard=true,
    Underwater=true,["Lake Fog"]=true,["Woodland Pollen"]=true,
    ["Woodland Firefly"]=true,["Wetland Flies"]=true
}
local sky_child_names={
    ["Sky Colors"]=true,Sun=true,Moon=true,Clouds=true,Atmosphere=true
}
local lighting_child_names={Lightning=true,Fog=true,["Ped Light"]=true,
    ["Traffic Signals"]=true,["Street Light"]=true,["Scene Lights"]=true}
local decal_child_names={Footprints=true,["Bullet Impact"]=true}
local vehicle_lighting_child_names={Neon=true,["Vehicle Lights"]=true}
local water_child_names={["Water Color"]=true}
local function sky_child_definition(page_id,page_name)
    local blocks={}
    for _,handle in ipairs(items.page_items(page_id)) do
        local item=items.at(handle)
        if item then
            if item.name:sub(1,9)=="Override " then blocks[#blocks+1]={} end
            if #blocks>0 then blocks[#blocks][#blocks[#blocks]+1]=item.name end
        end
    end
    local left,right={},{}
    local split=math.ceil(#blocks*.5)
    for index,block in ipairs(blocks) do
        local target=index<=split and left or right
        for _,name in ipairs(block) do target[#target+1]=name end
    end
    return {left={{title=page_name.." Colours",items=left}},
            right={{title=page_name.." Properties",items=right}}}
end
local function visuals_tabs_list(root)
    local tabs={}
    for _,handle in ipairs(items.page_items(items.joaat(root or "Visuals"))) do
        local item=items.at(handle)
        if item and item.type==item_type.sub_menu then
            tabs[#tabs+1]={name=item.name,id=items.submenu_page_id(handle)}
        end
    end
    return tabs
end
-- Keep root selection and search results in the same category, including
-- effects exposed as flattened cards from a nested native page.
local function visual_section_for(page_id,page_name)
    for _,root in ipairs({"Visuals","VFX's"}) do
        if page_id==items.joaat(root) then return root end
        for _,tab in ipairs(visuals_tabs_list(root)) do
            if page_id==tab.id then return root,tab.name end
        end
    end
    local parent
    if weather_effect_names[page_name] then parent="Weather"
    elseif sky_child_names[page_name] then parent="Sky"
    elseif lighting_child_names[page_name] then parent="Lighting"
    elseif decal_child_names[page_name] then parent="Decals"
    elseif vehicle_lighting_child_names[page_name] then parent="Vehicle Lighting"
    elseif water_child_names[page_name] then parent="Water" end
    if parent then return "VFX's",parent end
end
local function control_height(handle)
    local item=items.at(handle)
    if not item then return 0 end
    if item.type==item_type.keybind then return 36+ui_options.row_spacing end
    if item.type==item_type.slider then return 44+ui_options.row_spacing end
    if item.type==item_type.loop_option or item.type==item_type.array_option then return 36+ui_options.row_spacing end
    if item.type==item_type.action or item.type==item_type.sub_menu or item.type==item_type.selected_tick then return 36+ui_options.row_spacing end
    return 32+ui_options.row_spacing
end
local function slider_control(id,x,y,w,value,vmin,vmax,format,label,disabled)
    local span=math.max(.0001,vmax-vmin)
    local target=math.max(0,math.min(1,(value-vmin)/span))
    local sx,sy,sw=x+4,y+28,w-8
    local hot=not disabled and inside(sx-4,sy-8,sw+8,16)
    if hot and input.mouse_clicked(0) then slider_drag=id end
    local changed=false
    if slider_drag==id and input.mouse_down(0) and not disabled then
        target=math.max(0,math.min(1,(input.mouse_x()-sx)/sw))
        local next_value=vmin+target*span
        changed=next_value~=value; value=next_value
    end
    if slider_drag==id and not input.mouse_down(0) then slider_drag=nil end
    local shown=motion_to("slider_value_"..id,target,24,target)
    local value_text=string.format(format or "%.2f",value)
    local value_w=text.width(font.value,value_text)
    local chip_h=text.height(font.value)+4
    txt_ellipsis(font.item,x,y+2,disabled and palette.faint or palette.text,label,w-value_w-22)
    fill(x+w-value_w-12,y+1,value_w+12,chip_h,{255,255,255,10},6)
    txt(font.value,x+w-value_w-6,y+3,disabled and palette.faint or palette.text,value_text)
    local hover_a=motion_to("slider_hot_"..id,(hot or slider_drag==id) and 1 or 0,20,0)
    fill(sx,sy-2,sw,4,{palette.text[1],palette.text[2],palette.text[3],22},2)
    fill(sx,sy-2,math.max(4,sw*shown),4,disabled and palette.faint or palette.accent,2)
    local kx=sx+sw*shown
    local knob=disabled and palette.faint or palette.accent
    draw.circle(kx,sy,7+hover_a,rgba(knob))
    draw.circle(kx,sy,4,255,255,255,disabled and 150 or 255)
    return value,changed
end
-- Boxed toggle: embedded white icons tinted grey (off) or accent (on), crossfaded.
function halo.checkbox(x,y,size,on,hot)
    x,y=math.floor(x+.5),math.floor(y+.5)
    local off_col=hot and palette.text or {palette.text[1],palette.text[2],palette.text[3],140}
    if on<1 then draw.checkbox(false,x,y,size,off_col[1],off_col[2],off_col[3],math.floor(off_col[4]*(1-on))) end
    if on>0 then draw.checkbox(true,x,y,size,palette.accent[1],palette.accent[2],palette.accent[3],math.floor(palette.accent[4]*on)) end
end
local function row(handle,x,y,w,h,radius,label)
    local item=items.at(handle); if not item then return end
    local color_blocked=false
    if color_open and color_anchor then
        local px,py,pw,ph=color_popup_rect(color_anchor)
        color_blocked=inside(px,py,pw,ph)
    end
    local hover=inside(x,y,w,h) and not color_blocked and not item.disabled
    local name=label or item.name
    local name_color=item.disabled and palette.faint or palette.text
    if search_target and search_target.handle==handle and ctx.time()<search_target.expires then
        fill(x-5,y+2,2,math.max(10,h-4),palette.accent,1)
    end
    if item.type==item_type.toggle or item.type==item_type.float_toggle or
       item.type==item_type.int_toggle or item.type==item_type.array_toggle then
        local box=25
        local on=motion_to("toggle_on_"..handle,item.on and 1 or 0,22,item.on and 1 or 0)
        halo.checkbox(x+w-box+2,y+(h-box)*.5,box,on,hover)
        txt_ellipsis(font.item,x,y+(h-text.height(font.item))*.5,name_color,name,w-box-14)
        if hover and input.mouse_clicked(0) then items.toggle(handle) end
    elseif item.type==item_type.slider then
        local value,changed=slider_control(handle,x,y,w,item.f_val,item.f_min,item.f_max,"%.2f",name,item.disabled or color_blocked)
        if changed then items.set_f_val(handle,value) end
    elseif item.type==item_type.keybind then
        aim_keybind_seen=true
        ui.row_aim_keybind_values(aim_keybind_id,x,y,w,name)
    elseif item.type==item_type.loop_option or item.type==item_type.array_option then
        local bw=math.max(96,math.min(136,w*.46))
        local bx,sy,bh=x+w-bw,y+(h-28)*.5,28
        txt_ellipsis(font.item,x,y+(h-text.height(font.item))*.5,name_color,name,w-bw-10)
        local open=option_open==handle
        local box_hot=hover and inside(bx,sy,bw,bh)
        fill(bx,sy,bw,bh,box_hot and palette.side or palette.input,8)
        outline(bx,sy,bw,bh,open and {palette.accent[1],palette.accent[2],palette.accent[3],150} or palette.border,8)
        txt_ellipsis(font.value,bx+10,sy+(bh-text.height(font.value))*.5,palette.text,item.current_value or "",bw-32)
        local cx,cy=bx+bw-14,sy+bh*.5
        if open then line(cx-4,cy+2,cx,cy-2,palette.dim,1.4); line(cx,cy-2,cx+4,cy+2,palette.dim,1.4)
        else line(cx-4,cy-2,cx,cy+2,palette.dim,1.4); line(cx,cy+2,cx+4,cy-2,palette.dim,1.4) end
        if open then option_seen=true; option_anchor={x=bx,y=sy,w=bw,h=bh} end
        if hover and clicked(x,y,w,h) and item.value_count>0 then
            if open then option_open,option_anchor=nil,nil
            else close_color_popup(); option_open=handle; option_anchor={x=bx,y=sy,w=bw,h=bh}; option_seen=true end
        end
    elseif item.type==item_type.color then
        txt_ellipsis(font.item,x,y+(h-text.height(font.item))*.5,name_color,name,w-26)
        local sx,sy=x+w-20,y+(h-20)*.5
        fill(sx,sy,20,20,{item.r,item.g,item.b,item.a},6)
        outline(sx,sy,20,20,palette.border,6)
        color_swatch(handle,sx,sy,20,20)
    elseif item.type==item_type.action or item.type==item_type.sub_menu or item.type==item_type.selected_tick then
        fill(x,y,w,h-4,hover and palette.side or palette.input,8)
        outline(x,y,w,h-4,palette.border,8)
        local tw=text.width(font.item,name)
        txt_ellipsis(font.item,x+math.max(8,(w-tw)*.5),y+(h-4-text.height(font.item))*.5,name_color,name,w-16)
        if item.type==item_type.sub_menu then txt(font.small,x+w-14,y+8,palette.dim,">") end
        if hover and input.mouse_clicked(0) then
            if item.type==item_type.sub_menu then
                local target=items.submenu_page_id(handle)
                if target and target~=0 then request_navigation("page",target) else items.activate(handle) end
            else
                items.activate(handle)
                if ui.preview_canvas and item.page=="Settings" and item.name=="Reset Menu Position" then
                    preview_recenter=true
                end
            end
        end
    else
        txt_ellipsis(font.item,x,y+(h-text.height(font.item))*.5,name_color,name,w)
    end
end

local collapsed_groups={}
local function grouped_page(x,y,w,h,radius,page_id,groups,column_count)
    local pad,gap,vgap=20,ui_options.group_spacing,ui_options.group_spacing
    local min_width=column_count and 160 or 220
    local columns=math.max(1,math.min(column_count or ui_options.columns,math.floor((w-pad*2+gap)/(min_width+gap))))
    local col_w=(w-pad*2-gap*(columns-1))/columns
    local heights,expanded_heights,layouts={},{},{}
    for i=1,columns do heights[i],expanded_heights[i]=0,0 end
    for index,group in ipairs(groups) do
        if #group.items>0 then
            local key=tostring(page_id)..":"..index..":"..group.title
            if search_target and search_target.pending then
                for _,handle in ipairs(group.items) do
                    if handle==search_target.handle then collapsed_groups[key]=nil end
                end
            end
            local expanded_h=halo.card_head+halo.card_bottom
            for _,handle in ipairs(group.items) do expanded_h=expanded_h+control_height(handle) end
            local collapsed=not not collapsed_groups[key]
            local ch=collapsed and halo.card_head or expanded_h
            -- Balance using expanded sizes so collapsing a card never changes columns.
            local column=1
            for i=2,columns do if expanded_heights[i]<expanded_heights[column] then column=i end end
            layouts[#layouts+1]={group=group,key=key,column=column,y=heights[column],h=ch,collapsed=collapsed}
            heights[column]=heights[column]+ch+vgap
            expanded_heights[column]=expanded_heights[column]+expanded_h+vgap
        end
    end
    local total=0
    for _,height in ipairs(heights) do total=math.max(total,height) end
    local page_h=total+pad*2-vgap
    local maximum=math.max(0,page_h-h)
    if search_target and search_target.pending then
        for _,layout in ipairs(layouts) do
            local ry=pad+layout.y+halo.card_head
            for _,handle in ipairs(layout.group.items) do
                if handle==search_target.handle then
                    scroll[page_id]=math.max(0,math.min(maximum,ry+control_height(handle)*.5-h*.5))
                    search_target.pending=false
                end
                ry=ry+control_height(handle)
            end
        end
    end
    local current=smooth_scroll(0xA300+page_id%512,scroll[page_id] or 0,maximum,inside(x,y,w-12,h),70,14)
    current=math.max(0,math.min(maximum,current)); scroll[page_id]=current
    draw.push_clip(x,y,x+w,y+h)
    for _,layout in ipairs(layouts) do
        local gx=x+pad+(layout.column-1)*(col_w+gap)
        local gy=y+pad+layout.y-current
        if gy+layout.h>=y and gy<=y+h then
            local bx,by,bw=panel(gx,gy,col_w,layout.h,layout.group.title,tostring(#layout.group.items),radius)
            local cx,cy=gx+col_w-16,gy+halo.card_head*.5
            if layout.collapsed then
                line(cx-2,cy-3,cx+2,cy,palette.faint,1.2); line(cx+2,cy,cx-2,cy+3,palette.faint,1.2)
            else
                line(cx-3,cy-2,cx,cy+2,palette.faint,1.2); line(cx,cy+2,cx+3,cy-2,palette.faint,1.2)
            end
            if inside(x,y,w,h) and clicked(gx,gy,col_w,halo.card_head) then
                collapsed_groups[layout.key]=not collapsed_groups[layout.key]
                input.consume_mouse_click()
            end
            -- Apply header changes on the next layout pass: body and bounds stay in sync.
            if not layout.collapsed then
                for _,handle in ipairs(layout.group.items) do
                    local rh=control_height(handle)
                    if by+rh>=y and by<=y+h then row(handle,bx,by,bw,rh-2,radius) end
                    by=by+rh
                end
            end
        end
    end
    draw.pop_clip()
    if maximum>0 then scroll[page_id]=ui.scrollbar(0xA600+page_id%512,x+w-7,y+8,y+h-8,current,maximum,page_h) end
end
local function registry_groups(page_id,page_name)
    local groups,current={},nil
    for _,handle in ipairs(items.page_items(page_id)) do
        local item=items.at(handle)
        if item and item.type==item_type.label then
            current={title=item.name,items={}}; groups[#groups+1]=current
        elseif item then
            if not current or #current.items>=9 then
                current={title=#groups==0 and page_name or (page_name.." / "..(#groups+1)),items={}}
                groups[#groups+1]=current
            end
            current.items[#current.items+1]=handle
        end
    end
    return groups
end

local function named_row(page,name,x,y,w,h,radius)
    local handle=items.get(page,name)
    if handle then row(handle,x,y,w,h,radius) end
end

local function compact_toggle(page,name,id,x,w,y,label)
    local handle=items.get(page,name)
    if handle then row(handle,x,y,w,22,2,label) end
end
local pending_ui_scale=nil
local function compact_slider(page,name,id,x,w,y,label,format)
    local handle=items.get(page,name); if not handle then return end
    local item=items.at(handle); if not item then return end
    local defer_scale=page=="Settings" and name=="UI Scale"
    local displayed=defer_scale and (pending_ui_scale or item.f_val) or item.f_val
    local value,changed=slider_control(id,x,y,w,displayed,item.f_min,item.f_max,format,label or name,item.disabled)
    if defer_scale then
        if changed then pending_ui_scale=value end
        if pending_ui_scale and not input.mouse_down(0) then
            local auto=items.get("Settings","Auto UI Scale")
            local auto_item=auto and items.at(auto)
            if auto_item and auto_item.on then items.toggle(auto) end
            items.set_f_val(handle,pending_ui_scale)
            pending_ui_scale=nil
        end
    elseif changed then items.set_f_val(handle,value) end
end

local function theme_row(handle,x,y,w,active,radius)
    local item=items.at(handle); if not item then return end
    fill(x,y,w,26,active and {palette.accent[1],palette.accent[2],palette.accent[3],36} or palette.input,7)
    txt_ellipsis(font.value,x+10,y+(26-text.height(font.value))*.5,active and palette.accentHi or palette.dim,item.name,w-30)
    if active then
        line(x+w-20,y+12,x+w-17,y+15,palette.accentHi,1.2)
        line(x+w-17,y+15,x+w-11,y+8,palette.accentHi,1.2)
    end
    if clicked(x,y,w,26) and not active then items.activate(handle) end
end

-- Native settings not explicitly laid out below stay visible as the project grows.
local settings_presented={
    ["Auto UI Scale"]=true,["UI Scale"]=true,["Overlays/Panels Scale"]=true,
    ["Theme"]=true,["Choose Theme"]=true,["Streamer Mode"]=true,
    ["Reload Lua Theme"]=true,["Reset Theme"]=true,["Open Themes Folder"]=true,
}
local function additional_settings()
    local result={}
    for _,handle in ipairs(items.page_items(items.joaat("Settings"))) do
        local item=items.at(handle)
        if item and item.type~=item_type.label and not settings_presented[item.name] then
            result[#result+1]=handle
        end
    end
    return result
end
local settings_scroll={}
local config_name,config_status,config_delete_confirm="","",false
local config_seen_active=""
local function settings_columns(x,y,w,h,radius)
    local cards={}
    local function add_card(title,height,render,targets)
        cards[#cards+1]={title=title,h=height+halo.card_head-28,render=render,targets=targets or {}}
    end
    local function target(page,name,offset)
        return {handle=items.get(page,name),offset=offset or 0}
    end
    if settings_tab=="General" then
        add_card("UI Scale",140,function(bx,by,bw,bh)
        compact_toggle("Settings","Auto UI Scale",0xC001,bx,bw,by,"Auto UI Scale")
        compact_slider("Settings","UI Scale",0xC002,bx,bw,by+26,"UI Scale","%.2f x")
        compact_slider("Settings","Overlays/Panels Scale",0xC003,bx,bw,by+68,"Overlays","%.2f x")
        end,{target("Settings","Auto UI Scale"),target("Settings","UI Scale",26),target("Settings","Overlays/Panels Scale",68)})
        add_card("Open Menu Keys",164,function(kx,ky,kw)
        ui.row_menu_keybind_values(0xD001,kx,ky,kw,"Open menu")
        ui.row_menu_keybind_values(0xD003,kx,ky+36,kw,"Alternate key",true)
        txt_ellipsis(font.small,kx,ky+78,palette.dim,"Click the key, then press a new one.",kw)
        txt(font.small,kx,ky+98,palette.faint,"Esc cancels key capture.")
        end)
        if items.get("Streamer Mode","Enabled") then
            add_card("Streamer Mode",60,function(sx,sy,sw,sh)
                compact_toggle("Streamer Mode","Enabled",0xC100,sx,sw,sy,"Enabled")
            end,{target("Streamer Mode","Enabled"),target("Settings","Streamer Mode")})
        end
    elseif settings_tab=="Layout" then
        local layout_targets={target("Nenyoo Appearance","Sidebar Width"),target("Nenyoo Appearance","Corner Radius",42)}
        for index,entry in ipairs(layout_sliders) do layout_targets[#layout_targets+1]=target("UI Layout",entry[1],(index+1)*42) end
        add_card("UI Layout",290,function(mx,my,mw,mh)
        compact_slider("Nenyoo Appearance","Sidebar Width",0xC110,mx,mw,my,"Sidebar Width","%.0f px")
        compact_slider("Nenyoo Appearance","Corner Radius",0xC111,mx,mw,my+42,"Corner Radius","%.0f px")
        for index,entry in ipairs(layout_sliders) do
            compact_slider("UI Layout",entry[1],0xC120+index,mx,mw,my+(index+1)*42,entry[1],entry[2]=="columns" and "%.0f" or "%.0f px")
        end
        end,layout_targets)
        local font_targets={}
        for index,name in ipairs({"Title Size","Item Size","Small Size","Value Size","Description Size","Section Label Size","Tagline Size","Overlay Text Size"}) do
            font_targets[#font_targets+1]=target("Typography",name,(index-1)*42)
        end
        add_card("Typography",378,function(fx,fy,fw,fh)
        local fonts={{"Title Size","Brand"},{"Item Size","Menu Items"},{"Small Size","Small Text"},
            {"Value Size","Values"},{"Description Size","Descriptions"},{"Section Label Size","Group Titles"},
            {"Tagline Size","Tagline"},{"Overlay Text Size","Overlay Text"}}
        for index,entry in ipairs(fonts) do
            compact_slider("Typography",entry[1],0xC010+index,fx,fw,fy+(index-1)*42,entry[2],"%.0f px")
        end
        end,font_targets)
        local weight_targets={}
        for index,entry in ipairs(font_weights) do weight_targets[#weight_targets+1]=target("Typography",entry[1],(index-1)*42) end
        add_card("Font Weight",#font_weights*42+42,function(wx,wy,ww,wh)
        for index,entry in ipairs(font_weights) do
            compact_slider("Typography",entry[1],0xC150+index,wx,ww,wy+(index-1)*42,entry[5],"%.0f")
        end
        end,weight_targets)
        local navigation_targets={}
        for index,entry in ipairs(navigation_toggles) do navigation_targets[#navigation_targets+1]=target("UI Layout",entry[1],(index-1)*24) end
        add_card("Navigation",110,function(nx,ny,nw,nh)
        for index,entry in ipairs(navigation_toggles) do
            compact_toggle("UI Layout",entry[1],0xC130+index,nx,nw,ny+(index-1)*24,entry[1])
        end
        end,navigation_targets)
        add_card("Motion",106,function(ax,ay,aw,ah)
        compact_toggle("Motion","Animations Enabled",0xC112,ax,aw,ay,"Animations")
        compact_slider("Motion","Motion Speed",0xC113,ax,aw,ay+26,"Motion Speed","%.2f x")
        end,{target("Motion","Animations Enabled"),target("Motion","Motion Speed",26)})
        local extra=additional_settings()
        if #extra>0 then
            local height,targets=38,{}
            for _,handle in ipairs(extra) do
                targets[#targets+1]={handle=handle,offset=height-38}
                height=height+control_height(handle)
            end
            add_card("More Settings",height,function(ex,ey,ew)
                for _,handle in ipairs(extra) do
                    local rh=control_height(handle)
                    row(handle,ex,ey,ew,rh,radius)
                    ey=ey+rh
                end
            end,targets)
        end
    elseif settings_tab=="Colors" then
        local function color_group(title,first,last)
            local targets={}
            for index=first,last do targets[#targets+1]=target("Nenyoo Appearance",color_settings[index][1],(index-first)*30) end
            add_card(title,42+(last-first+1)*30,function(ax,ay,aw)
                for index=first,last do
                    local entry=color_settings[index]; local name,color=entry[1],palette[entry[3]]
                    local cy=ay+(index-first)*30
                    local hex=string.format("#%02X%02X%02X%02X",table.unpack(color))
                    local hex_w=text.width(font.value,hex)
                    txt_ellipsis(font.item,ax,cy+6,palette.text,name,aw-hex_w-42)
                    txt(font.value,ax+aw-32-hex_w,cy+6,palette.dim,hex)
                    fill(ax+aw-22,cy+2,22,22,color,6)
                    outline(ax+aw-22,cy+2,22,22,palette.border,6)
                    color_swatch(items.get("Nenyoo Appearance",name),ax+aw-22,cy+2,22,22)
                end
            end,targets)
        end
        color_group("Colors",1,5)
        color_group("Surface Colors",6,10)
        color_group("Text & Borders",11,14)
    elseif settings_tab=="Config" then
        local profiles=ui.config_profiles()
        local active_profile=ui.config_active()
        if config_seen_active~=active_profile then config_delete_confirm=false; config_seen_active=active_profile end
        local choose=items.get("Settings","Choose Theme")
        local themes=choose and items.page_items(items.submenu_page_id(choose)) or {}
        local theme_targets={target("Settings","Theme"),target("Settings","Choose Theme")}
        for index,handle in ipairs(themes) do theme_targets[#theme_targets+1]={handle=handle,offset=(index-1)*28} end
        for _,name in ipairs({"Reload Lua Theme","Reset Theme","Open Themes Folder"}) do
            theme_targets[#theme_targets+1]=target("Settings",name,28*math.max(1,#themes)+8)
        end
        add_card("Theme",76+28*math.max(1,#themes),function(tx,ty,tw,th)
        local active_path=theme.active_path()
        for index,handle in ipairs(themes) do
            local item=items.at(handle)
            theme_row(handle,tx,ty+(index-1)*28,tw,item and (item.type==item_type.selected_tick or item.desc==active_path),2)
        end
        if #themes==0 then txt(font.small,tx+4,ty+6,palette.dim,"Default theme") end
        local action_y=ty+28*math.max(1,#themes)+8
        local action_w=(tw-12)/3
        for index,entry in ipairs({{"Reload","Reload Lua Theme"},{"Reset","Reset Theme"},{"Open","Open Themes Folder"}}) do
            local handle=items.get("Settings",entry[2])
            if button(tx+(index-1)*(action_w+6),action_y,action_w,28,entry[1],false,2) and handle then items.activate(handle) end
        end
        end,theme_targets)
        add_card("Configs",264+30*math.max(1,#profiles),function(px,py,pw)
        txt_ellipsis(font.item,px,py+2,palette.text,i18n.tr("Active: ")..active_profile,pw)
        txt(font.small,px,py+24,palette.dim,"Config name")
        local submitted
        config_name,submitted=ui.field(0xC510,px,py+42,pw,28,config_name,"Enter a name",false)
        local action_w=(pw-12)/3
        local function create_config()
            if ui.config_create(config_name) then config_status="Config created"; config_name=""
            else config_status="Choose a unique valid name" end
        end
        if submitted then create_config() end
        if button(px,py+78,action_w,28,"Create",true,radius) then create_config() end
        if button(px+action_w+6,py+78,action_w,28,"Save",false,radius) then
            config_status=ui.config_save() and "Config saved" or "Could not save config"
        end
        if button(px+(action_w+6)*2,py+78,action_w,28,"Rename",false,radius) then
            if ui.config_rename(config_name) then config_status="Config renamed"; config_name=""
            else config_status="Cannot rename; check the name" end
        end
        if active_profile~="Default" then
            if config_delete_confirm then
                if button(px,py+112,(pw-6)*.5,28,"Confirm Delete",false,radius) then
                    config_status=ui.config_delete() and "Config deleted" or "Could not delete config"
                    config_delete_confirm=false
                end
                if button(px+(pw+6)*.5,py+112,(pw-6)*.5,28,"Cancel",false,radius) then config_delete_confirm=false end
            elseif button(px,py+112,pw,28,"Delete Current Config",false,radius) then config_delete_confirm=true end
        else txt_ellipsis(font.small,px,py+120,palette.faint,"Default cannot be renamed or deleted.",pw) end
        txt_ellipsis(font.small,px,py+156,palette.dim,config_status~="" and config_status or "Changes save automatically.",pw)
        for index,name in ipairs(profiles) do
            local cy=py+186+(index-1)*30
            local selected=name==active_profile
            fill(px,cy,pw,26,selected and {palette.accent[1],palette.accent[2],palette.accent[3],36} or palette.input,7)
            txt_ellipsis(font.value,px+8,cy+7,selected and palette.accentHi or palette.text,name,pw-56)
            if selected then txt(font.small,px+pw-42,cy+8,palette.accentHi,"Active") end
            if clicked(px,cy,pw,26) and not selected then
                config_status=ui.config_load(name) and (i18n.tr("Loaded ")..name) or "Could not load config"
                config_delete_confirm=false
            end
        end
        end)
        add_card("Appearance Defaults",98,function(rx,ry,rw)
        txt_ellipsis(font.small,rx,ry+2,palette.dim,"Restore colours, layout, and fonts.",rw)
        -- Keep the recovery button legible even after making text fully transparent.
        fill(rx,ry+28,rw,28,{34,33,44,255},8)
        local reset_label=i18n.tr("Reset Appearance")
        txt_ellipsis(font.value,rx+8,ry+36,{211,216,219,255},reset_label,rw-16)
        if clicked(rx,ry+28,rw,28) then
            close_color_popup(); reset_appearance(); settings_scroll={}
            input.consume_mouse_click()
        end
        end)
    end

    local pad,gap=20,ui_options.group_spacing
    local columns=math.max(1,math.min(ui_options.columns,#cards,math.floor((w-pad*2+gap)/(220+gap))))
    local cw=(w-pad*2-gap*(columns-1))/columns
    local heights,total={},0
    for i=1,columns do heights[i]=0 end
    for _,card in ipairs(cards) do
        local column=1
        for i=2,columns do if heights[i]<heights[column] then column=i end end
        card.x=x+pad+(column-1)*(cw+gap)
        card.y=heights[column]
        heights[column]=heights[column]+card.h+gap
        total=math.max(total,heights[column]-gap)
    end
    local page_h=total+pad*2
    local maximum=math.max(0,page_h-h)
    local current=settings_scroll[settings_tab] or 0
    if search_target and search_target.pending then
        current=0
        for _,card in ipairs(cards) do
            for _,entry in ipairs(card.targets) do
                if entry.handle==search_target.handle then current=pad+card.y+halo.card_head+entry.offset-h*.4 end
            end
        end
        search_target.pending=false
    end
    local tab_id=0
    for index,name in ipairs(settings_tab_names) do
        if name==settings_tab then tab_id=(index-1)*2; break end
    end
    current=smooth_scroll(0xA200+tab_id,current,maximum,inside(x,y,w-12,h),70,14)
    current=math.max(0,math.min(maximum,current)); settings_scroll[settings_tab]=current
    draw.push_clip(x,y,x+w,y+h)
    local function render_controls()
        for _,card in ipairs(cards) do
            local cy=y+pad+card.y-current
            if cy+card.h>=y and cy<=y+h then
                local bx,by,bw,bh=panel(card.x,cy,cw,card.h,card.title,"",radius)
                card.render(bx,by,bw,bh)
            end
        end
    end
    if inside(x,y,w,h) or slider_drag then render_controls()
    else input.with_pointer_blocked(render_controls) end
    draw.pop_clip()
    if maximum>0 then settings_scroll[settings_tab]=ui.scrollbar(0xA201+tab_id,x+w-7,y+8,y+h-8,current,maximum,page_h) end
end

local function combat_tabs(x,y,w,h,radius,selected)
    if selected then combat_tab=selected end
    if #combat_tabs_list()==0 then return end
    local active=combat_definitions[combat_tab]
    local page_id=items.joaat(active.name)
    local handles=items.page_items(page_id)
    local groups,shown={},{}
    for _,side in ipairs({active.left,active.right}) do
        for _,group in ipairs(side) do
            local entry={title=group.title,items={}}
            for index=group.first,math.min(group.last,#handles) do
                entry.items[#entry.items+1]=handles[index]; shown[handles[index]]=true
            end
            groups[#groups+1]=entry
        end
    end
    local extra={title="Other Controls",items={}}
    for _,handle in ipairs(handles) do if not shown[handle] then extra.items[#extra.items+1]=handle end end
    groups[#groups+1]=extra
    grouped_page(x,y,w,h,radius,page_id,groups)
end
local function visuals_cards(x,y,w,h,radius,page_id,definition,all_handles,column_count)
    local handles=all_handles or items.page_items(page_id)
    local by_name,shown,groups={},{},{}
    for _,handle in ipairs(handles) do local item=items.at(handle); if item then by_name[item.name]=handle end end
    for _,side in ipairs({definition.left,definition.right}) do
        for _,group in ipairs(side) do
            local entry={title=group.title,items={}}
            for _,name in ipairs(group.items) do
                local handle=type(name)=="number" and name or by_name[name]
                if handle then entry.items[#entry.items+1]=handle; shown[handle]=true end
            end
            groups[#groups+1]=entry
        end
    end
    local extra={title="Other Controls",items={}}
    for _,handle in ipairs(handles) do
        local item=items.at(handle)
        if item and item.type~=item_type.label and not shown[handle] then extra.items[#extra.items+1]=handle end
    end
    groups[#groups+1]=extra
    grouped_page(x,y,w,h,radius,page_id,groups,column_count)
end

local function flattened_vfx_definition(parent,parent_id)
    local definition={left={},right={}}
    local handles,seen={},{}
    local function add_page(page_id,source,page_name)
        local page_handles=items.page_items(page_id)
        local by_name={}
        for _,handle in ipairs(page_handles) do
            local item=items.at(handle)
            if item then
                by_name[item.name]=handle
                if item.type~=item_type.sub_menu and not seen[handle] then
                    handles[#handles+1]=handle
                    seen[handle]=true
                end
            end
        end
        if not source then return end
        for _,side in ipairs({"left","right"}) do
            for _,group in ipairs(source[side] or {}) do
                local controls={}
                for _,entry in ipairs(group.items or {}) do
                    local handle=type(entry)=="number" and entry or by_name[entry]
                    local item=handle and items.at(handle)
                    if item and item.type~=item_type.sub_menu and item.type~=item_type.label then
                        controls[#controls+1]=handle
                    end
                end
                if #controls>0 then
                    local title=page_name and (page_name.." / "..group.title) or group.title
                    definition[side][#definition[side]+1]={title=title,items=controls}
                end
            end
        end
    end
    add_page(parent_id,parent=="ESP" and visuals_definition or vfx_definitions[parent])
    for _,link in ipairs(items.page_items(parent_id)) do
        local item=items.at(link)
        if item and item.type==item_type.sub_menu then
            local child_id=items.submenu_page_id(link)
            if child_id and child_id~=0 then
                local child_definition
                if parent=="Sky" then child_definition=sky_child_definition(child_id,item.name)
                elseif parent=="Weather" then child_definition=vfx_definitions.weather_effect
                else child_definition=vfx_definitions[item.name] end
                add_page(child_id,child_definition,item.name)
            end
        end
    end
    return definition,handles
end

local function draw_vfx_group(x,y,w,h,radius,parent,parent_id,column_count)
    local definition,handles=flattened_vfx_definition(parent,parent_id)
    visuals_cards(x,y,w,h,radius,parent_id,definition,handles,column_count)
end

local function draw_visuals_tab(x,y,w,h,radius,root)
    local tabs=visuals_tabs_list(root)
    local selected=nil
    for _,tab in ipairs(tabs) do
        if tab.name==visual_tabs[root] then selected=tab; break end
    end
    if not selected then selected=tabs[1] end
    if not selected or not selected.id or selected.id==0 then return end
    visual_tabs[root]=selected.name
    draw_vfx_group(x,y,w,h,radius,selected.name,selected.id,root=="VFX's" and 4 or nil)
end

local welcome_open,welcome_anchor,welcome_scroll=nil,nil,0
local welcome_bounds,welcome_resize=nil,nil
local welcome_keybind_id,welcome_alt_keybind_id=0xD002,0xD004
local welcome_return_tab=nil
local function enter_main_ui()
    if menu.build_tabs then menu.build_tabs() end
    local destination=welcome_return_tab
    if not destination or menu.tab_name(destination)=="Home" or menu.tab_name(destination)=="" then
        destination=nil
        for tab=0,(menu.tab_count and menu.tab_count() or 0)-1 do
            if menu.tab_name(tab)~="Home" then destination=tab; break end
        end
    end
    if destination then request_navigation("tab",destination) end
end
local function close_welcome_dropdown()
    welcome_open,welcome_anchor=nil,nil
    if ui.cancel_menu_keybind then
        ui.cancel_menu_keybind(welcome_keybind_id)
        ui.cancel_menu_keybind(welcome_alt_keybind_id)
    end
end
local function welcome_choices()
    local entries={}
    if welcome_open=="language" then
        for i=1,i18n.count() do
            entries[#entries+1]={label=i18n.label(i),code=i18n.code(i),selected=i18n.code(i)==i18n.active()}
        end
    elseif welcome_open=="menu_scale" then
        local auto=items.get("Settings","Auto UI Scale")
        local automatic=auto and items.at(auto)
        local handle=items.get("Settings","UI Scale")
        local item=handle and items.at(handle)
        if automatic then entries[#entries+1]={label="Auto",auto=auto,selected=automatic.on} end
        if item then
            for _,value in ipairs({.5,.75,1,1.25,1.5,1.75,2}) do
                if value>=item.f_min and value<=item.f_max then
                    entries[#entries+1]={label=string.format("%.0f%%",value*100),value=value,handle=handle,
                        selected=not (automatic and automatic.on) and math.abs(item.f_val-value)<.001}
                end
            end
        end

    end
    return entries
end
local function welcome_popup_rect()
    if not welcome_anchor then return end
    local vw,vh=ctx.screen_w()/ctx.ui_scale(),ctx.screen_h()/ctx.ui_scale()
    local w=math.min(math.max(220,welcome_anchor.w),vw-16)
    local h=math.min(8,#welcome_choices())*30+12
    h=math.min(h,vh-16)
    local x=math.max(8,math.min(vw-w-8,welcome_anchor.x+welcome_anchor.w-w))
    local y=welcome_anchor.y+welcome_anchor.h+5
    if y+h>vh-8 then y=welcome_anchor.y-h-5 end
    return x,math.max(8,math.min(vh-h-8,y)),w,h
end
local function welcome_popup_input()
    if not welcome_open then return false end
    if menu.page_id()~=items.joaat("Home") then close_welcome_dropdown(); return false end
    if input.key_just_pressed(VK.ESCAPE) then close_welcome_dropdown(); return true end
    local x,y,w,h=welcome_popup_rect()
    if input.mouse_clicked(0) and not inside(x,y,w,h) then
        close_welcome_dropdown(); input.consume_mouse_click()
    end
    return true
end
local function welcome_field(id,label,value,x,y,w)
    txt(font.item,x,y+(30-text.height(font.item))*.5,palette.text,label)
    local fw=math.min(220,w*.58)
    local fx=x+w-fw
    local hot=inside(fx,y,fw,30)
    fill(fx,y,fw,30,hot and palette.side or palette.input,4)
    txt_ellipsis(font.value,fx+12,y+(30-text.height(font.value))*.5,palette.text,value,fw-40)
    line(fx+fw-18,y+12,fx+fw-14,y+16,palette.dim,1.2)
    line(fx+fw-14,y+16,fx+fw-10,y+12,palette.dim,1.2)
    if welcome_open==id then welcome_anchor={x=fx,y=y,w=fw,h=30} end
    if clicked(fx,y,fw,30) then
        close_welcome_dropdown()
        welcome_open=id; welcome_anchor={x=fx,y=y,w=fw,h=30}; welcome_scroll=0
        close_color_popup(); option_open,option_anchor=nil,nil
        for index,entry in ipairs(welcome_choices()) do
            if entry.selected then welcome_scroll=math.max(0,index-4); break end
        end
        input.consume_mouse_click()
    end
end
local function welcome_layout()
    local layout={greeting=22}
    layout.subtitle=layout.greeting+text.height(font.title)+6
    layout.setup=layout.subtitle+text.height(font.desc)+16
    layout.button=layout.setup+184
    layout.height=layout.button+34+22
    return layout
end
local function draw_welcome(x,y,w,h,radius)
    local layout=welcome_layout()
    local left,width=x+22,w-44
    local username=ui.username()
    local greeting=username=="Guest" and "Welcome to Nenyoo." or (i18n.tr("Welcome back, ")..username..".")
    txt_ellipsis(font.title,left,y+layout.greeting,palette.text,greeting,width)
    txt_ellipsis(font.desc,left,y+layout.subtitle,palette.dim,"Set up your menu, then get started.",width)
    -- Share the welcome surface without layering another translucent fill.
    txt_ellipsis(font.label,left+12,y+layout.setup+8,palette.faint,i18n.tr("Quick Setup"),width-36)
    local bx,by,bw=left+10,y+layout.setup+28,width-20
    local auto=items.get("Settings","Auto UI Scale")
    local automatic=auto and items.at(auto)
    local scale=items.get("Settings","UI Scale")
    local value=scale and items.at(scale)
    local scale_label=automatic and automatic.on and "Auto" or (value and string.format("%.0f%%",value.f_val*100) or "Auto")
    local language="English"
    for i=1,i18n.count() do if i18n.code(i)==i18n.active() then language=i18n.label(i); break end end
    welcome_field("menu_scale","Menu scale",scale_label,bx+4,by,bw-8)
    welcome_field("language","Language",language,bx+4,by+36,bw-8)
    ui.row_menu_keybind_values(welcome_keybind_id,bx+4,by+74,bw-8,"Open key")
    ui.row_menu_keybind_values(welcome_alt_keybind_id,bx+4,by+108,bw-8,"Alternate key",true)
    local button_y=y+h-56
    local hot=inside(left,button_y,width,34)
    fill(left,button_y,width,34,hot and palette.accentHi or palette.accent,5)
    local label=i18n.tr("Enter")
    local label_w=text.width(font.item,label)
    txt_ellipsis(font.item,left+math.max(12,(width-label_w)*.5),button_y+(34-text.height(font.item))*.5,
        {21,24,27,255},label,width-24)
    if clicked(left,button_y,width,34) then
        close_welcome_dropdown(); enter_main_ui(); input.consume_mouse_click()
    end
end
local function welcome_surface_rect()
    local vw,vh=ctx.screen_w()/ctx.ui_scale(),ctx.screen_h()/ctx.ui_scale()
    local max_w,max_h=math.max(1,vw-32),math.max(1,vh-32)
    local min_w,min_h=math.min(360,max_w),math.min(welcome_layout().height,max_h)
    if not welcome_bounds then
        local w,h=math.min(480,max_w),min_h
        welcome_bounds={x=(vw-w)*.5,y=(vh-h)*.5,w=w,h=h,vw=vw,vh=vh}
    end
    local bounds=welcome_bounds
    if bounds.vw~=vw or bounds.vh~=vh then
        bounds.x=(bounds.x+bounds.w*.5)*vw/bounds.vw-bounds.w*.5
        bounds.y=(bounds.y+bounds.h*.5)*vh/bounds.vh-bounds.h*.5
        bounds.vw,bounds.vh=vw,vh
        welcome_resize=nil
    end
    bounds.w=math.max(min_w,math.min(max_w,bounds.w))
    bounds.h=math.max(min_h,math.min(max_h,bounds.h))
    bounds.x=math.max(16,math.min(vw-16-bounds.w,bounds.x))
    bounds.y=math.max(16,math.min(vh-16-bounds.h,bounds.y))
    return bounds.x,bounds.y,bounds.w,bounds.h
end
local function resize_welcome_surface()
    local x,y,w,h=welcome_surface_rect()
    if not welcome_resize and not welcome_open and clicked(x+w-20,y+h-20,20,20) then
        welcome_resize={x=input.mouse_x(),y=input.mouse_y(),w=w,h=h}
        close_welcome_dropdown()
        input.consume_mouse_click()
    end
    if welcome_resize then
        if input.mouse_down(0) then
            local max_w=welcome_bounds.vw-16-x
            local max_h=welcome_bounds.vh-16-y
            welcome_bounds.w=math.max(math.min(360,max_w),math.min(max_w,welcome_resize.w+input.mouse_x()-welcome_resize.x))
            welcome_bounds.h=math.max(math.min(welcome_layout().height,max_h),math.min(max_h,welcome_resize.h+input.mouse_y()-welcome_resize.y))
        else welcome_resize=nil end
    end
    return welcome_resize~=nil
end
local function draw_welcome_surface(radius)
    local vw,vh=ctx.screen_w()/ctx.ui_scale(),ctx.screen_h()/ctx.ui_scale()
    if ui.preview_canvas then fill(0,0,vw,vh,{51,65,85,255},0) end
    local resizing=resize_welcome_surface()
    local x,y,w,h=welcome_surface_rect()
    fill(x,y,w,h,palette.bg,math.max(6,radius))
    menu.drag_header(x,y,w,62,false)
    menu.set_content_rect(x,y,w,h)
    -- The resize corner has no grip, hover fill, border, or highlight.
    if resizing then input.with_pointer_blocked(function() draw_welcome(x,y,w,h,radius) end)
    else draw_welcome(x,y,w,h,radius) end
end

local function draw_welcome_dropdown()
    if not welcome_open then return end
    local x,y,w,h=welcome_popup_rect()
    fill(x,y,w,h,{23,26,30,255},5)
    local choices=welcome_choices()
    local visible=math.max(1,math.floor((h-12)/30))
    local maximum=math.max(0,#choices-visible)
    if inside(x,y,w,h) then welcome_scroll=welcome_scroll-input.mouse_wheel()*2 end
    welcome_scroll=math.floor(math.max(0,math.min(maximum,welcome_scroll)))
    for i=welcome_scroll+1,math.min(#choices,welcome_scroll+visible) do
        local entry=choices[i]; local ry=y+6+(i-welcome_scroll-1)*30
        if inside(x+5,ry,w-10,28) or entry.selected then fill(x+5,ry,w-10,28,palette.side,3) end
        local label_x=x+12
        if entry.code then flag(entry.code,x+12,ry+7,21,14); label_x=x+42 end
        txt_ellipsis(font.item,label_x,ry+(28-text.height(font.item))*.5,
            entry.selected and palette.accentHi or palette.text,entry.label,w-(label_x-x)-28)
        if entry.selected then
            line(x+w-23,ry+14,x+w-20,ry+17,palette.accentHi,1.2)
            line(x+w-20,ry+17,x+w-14,ry+10,palette.accentHi,1.2)
        end
        if clicked(x+5,ry,w-10,28) then
            if entry.code then i18n.set_active(entry.code)
            elseif entry.auto then
                if not items.at(entry.auto).on then items.toggle(entry.auto) end
            else
                local auto=items.get("Settings","Auto UI Scale")
                if auto and items.at(auto).on then items.toggle(auto) end
                items.set_f_val(entry.handle,entry.value)
            end
            close_welcome_dropdown()
            input.consume_mouse_click(); break
        end
    end
    if maximum>0 then
        local track=h-12; local thumb=math.max(16,track*visible/#choices)
        fill(x+w-3,y+6+(track-thumb)*welcome_scroll/maximum,2,thumb,palette.dim,1,130)
    end
end

-- FiveM tools: Lua Executor and Events. State lives on `fv` (declared with
-- the other navigation state) to keep the main chunk under Lua's local limit.
-- Data comes from the native `fivem.*` table.
fv.live_filter,fv.scan_filter,fv.block_input="","",""
fv.trigger={name="",kind=0,args=""}
fv.editor={lines={""},row=1,col=0,scroll=0,hscroll=0,follow=false,loaded=false,
    undo={},redo={},blink=0,clicks=0,page=15}
fv.cache,fv.list_scroll={},{}
fv.console_follow,fv.console_scroll=true,0
fv.script_file="executor_script.lua"
fv.kind_names={[0]="Client",[1]="Server",[2]="Latent"}
fv.scan_kinds={[0]={"HANDLER",0},[1]={"LOCAL",0},[2]={"SERVER",1},[3]={"LATENT",2},[4]={"CLIENT",0}}
function fv.available() return fivem~=nil end
function fv.set_focus(id)
    if fv.focus=="editor" and id~="editor" then fv.editor_save() end
    fv.focus=id
    if id then search_focus=false end
    if menu.set_text_editing then menu.set_text_editing(id~=nil) end
end
function fv.notify(message,good)
    fv.notice={text=message,good=good,expires=ctx.time()+4}
end
function fv.cached(key,interval,fetch)
    local entry=fv.cache[key]
    if not entry or ctx.time()-entry.at>=interval then
        entry={at=ctx.time(),value=fetch()}; fv.cache[key]=entry
    end
    return entry.value
end
function fv.refresh(key) fv.cache[key]=nil end
function fv.age(ms)
    local now=fivem.now_ms()
    if not ms or ms<=0 or ms>now or now-ms>86400000 then return "" end
    local s=math.floor((now-ms)/1000)
    if s<60 then return s.."s ago" elseif s<3600 then return math.floor(s/60).."m ago" end
    return math.floor(s/3600).."h ago"
end
function fv.button(x,y,w,h,label,primary,enabled)
    if enabled==nil then enabled=true end
    local hover=enabled and inside(x,y,w,h)
    local base=primary and enabled and palette.accent or palette.input
    fill(x,y,w,h,hover and (primary and palette.accentHi or palette.side) or base,2)
    local color=not enabled and palette.faint or (primary and {12,14,16,255} or palette.text)
    local tw=text.width(font.value,label)
    txt_ellipsis(font.value,x+math.max(6,(w-tw)*.5),y+(h-text.height(font.value))*.5,color,label,w-12)
    if hover and input.mouse_clicked(0) then input.consume_mouse_click(); return true end
    return false
end
function fv.toggle(x,y,w,label,on)
    local hover=inside(x,y,w,22)
    local sy=y+4
    local a=motion_to("fv_toggle_"..label,on and 1 or 0,22,on and 1 or 0)
    fill(x,sy,14,14,mix_color(palette.input,palette.accent,a),2)
    if a>.01 then
        local ink={12,28,34,math.floor(255*a)}
        line(x+3,sy+7,x+6,sy+10,ink,1.2); line(x+6,sy+10,x+11,sy+4,ink,1.2)
    end
    txt_ellipsis(font.item,x+19,y+(22-text.height(font.item))*.5,palette.text,label,w-19)
    if hover and input.mouse_clicked(0) then return not on end
    return on
end
function fv.badge(x,y,label,color)
    local w=text.width(font.tiny,label)+10
    fill(x,y,w,15,{color[1],color[2],color[3],40},2)
    txt(font.tiny,x+5,y+(15-text.height(font.tiny))*.5,color,label)
    return w
end
function fv.kind_color(kind)
    if kind==-1 then return palette.dim end
    if kind==1 then return palette.accentHi elseif kind==2 then return {235,180,90,255} end
    return {110,190,235,255}
end
function fv.status_line(x,y,w)
    local message,color
    if fivem.preview() then message,color="Preview: sample data, nothing runs",palette.dim
    elseif not fivem.attached() then message,color="Not attached to a FiveM client",{235,120,110,255}
    elseif fivem.is_running() then message,color="Attached, script resource running",palette.accentHi
    else message,color="Attached",palette.accentHi end
    txt_ellipsis(font.small,x,y+2,color,message,w)
end
function fv.draw_notice(x,y,w)
    local n=fv.notice
    if not n or ctx.time()>n.expires then fv.notice=nil; return end
    txt_ellipsis(font.small,x,y,n.good and palette.accentHi or {235,120,110,255},n.text,w)
end

-- Single-line text field. Returns the new value and whether Enter was pressed.
function fv.field(id,x,y,w,h,value,placeholder)
    local focused=fv.focus==id
    if clicked(x,y,w,h) then fv.set_focus(id); focused=true
    elseif focused and input.mouse_clicked(0) and not inside(x,y,w,h) then fv.set_focus(nil); focused=false end
    local submitted=false
    if focused then
        if input.key_down(VK.CONTROL) and input.key_just_pressed(VK.V) then
            value=value..(input.get_clipboard():gsub("[\r\n\t]+"," "))
        end
        value=value..input.get_chars()
        if input.key_pressed(VK.BACK) and #value>0 then
            value=input.key_down(VK.CONTROL) and "" or value:sub(1,-2)
        end
        if input.key_just_pressed(VK.RETURN) then submitted=true end
        if input.key_just_pressed(VK.ESCAPE) then fv.set_focus(nil); focused=false end
    end
    local a=motion_to("fv_field_"..id,focused and 1 or 0,22,0)
    fill(x,y,w,h,mix_color(palette.input,palette.side,a*.3),2)
    if a>.01 then outline(x,y,w,h,{palette.accent[1],palette.accent[2],palette.accent[3],math.floor(110*a)},2) end
    local th=text.height(font.value)
    local ty=y+(h-th)*.5
    draw.push_clip(x+6,y,x+w-6,y+h)
    local tw=value=="" and 0 or text.width(font.value,value)
    local tx=x+10-math.max(0,tw-(w-24))
    if value=="" then txt(font.value,x+10,ty,palette.faint,placeholder or "")
    else txt(font.value,tx,ty,palette.text,value) end
    if focused and ctx.time()%1<.6 then fill(tx+tw+1,ty,1,th,palette.accentHi) end
    draw.pop_clip()
    return value,submitted
end

-- Multi-line code editor with VS Code key bindings -------------------------
-- The cursor is (row, col); a selection runs from the anchor (arow, acol) to
-- the cursor. Columns are byte offsets: 0 = before the first character.
fv.pairs_open={["("]=")",["["]="]",["{"]="}",['"']='"',["'"]="'"}
fv.pairs_close={[")"]=true,["]"]=true,["}"]=true,['"']=true,["'"]=true}
function fv.editor_text() return table.concat(fv.editor.lines,"\n") end
function fv.ed_split(value)
    value=value:gsub("\r\n","\n"):gsub("\r","\n"):gsub("\t","    ")
    local parts={}
    for part in (value.."\n"):gmatch("(.-)\n") do parts[#parts+1]=part end
    return parts
end
function fv.ed_touch() fv.editor.follow=true; fv.editor.blink=ctx.time() end
function fv.ed_snapshot(kind)
    local e=fv.editor
    local now=ctx.time()
    if kind and kind==e.last_kind and now-e.last_time<1 and #e.undo>0 then e.last_time=now; return end
    local copy={}
    for i=1,#e.lines do copy[i]=e.lines[i] end
    e.undo[#e.undo+1]={lines=copy,row=e.row,col=e.col,arow=e.arow,acol=e.acol}
    if #e.undo>300 then table.remove(e.undo,1) end
    e.redo={}
    e.last_kind,e.last_time=kind,now
end
function fv.ed_restore(from,to)
    local e=fv.editor
    local state=table.remove(from)
    if not state then return end
    to[#to+1]={lines=e.lines,row=e.row,col=e.col,arow=e.arow,acol=e.acol}
    e.lines,e.row,e.col,e.arow,e.acol=state.lines,state.row,state.col,state.arow,state.acol
    e.last_kind=nil
    fv.ed_touch()
end
function fv.ed_selection()
    local e=fv.editor
    if not e.arow then return nil end
    local ar,ac,br,bc=e.arow,e.acol,e.row,e.col
    if ar==br and ac==bc then return nil end
    if ar>br or (ar==br and ac>bc) then ar,ac,br,bc=br,bc,ar,ac end
    return ar,ac,br,bc
end
function fv.ed_range_text(sr,sc,er,ec)
    local lines=fv.editor.lines
    if sr==er then return lines[sr]:sub(sc+1,ec) end
    local parts={lines[sr]:sub(sc+1)}
    for r=sr+1,er-1 do parts[#parts+1]=lines[r] end
    parts[#parts+1]=lines[er]:sub(1,ec)
    return table.concat(parts,"\n")
end
function fv.ed_delete_range(sr,sc,er,ec)
    local e=fv.editor
    local head,tail=e.lines[sr]:sub(1,sc),e.lines[er]:sub(ec+1)
    for _=sr+1,er do table.remove(e.lines,sr+1) end
    e.lines[sr]=head..tail
    e.row,e.col,e.arow,e.acol=sr,sc,nil,nil
    fv.ed_touch()
end
function fv.ed_delete_selection()
    local sr,sc,er,ec=fv.ed_selection()
    fv.editor.arow,fv.editor.acol=nil,nil
    if not sr then return false end
    fv.ed_delete_range(sr,sc,er,ec)
    return true
end
function fv.ed_insert_raw(value)
    local e=fv.editor
    fv.ed_delete_selection()
    local parts=fv.ed_split(value)
    local current=e.lines[e.row]
    local before,after=current:sub(1,e.col),current:sub(e.col+1)
    if #parts==1 then
        e.lines[e.row]=before..parts[1]..after; e.col=e.col+#parts[1]
    else
        e.lines[e.row]=before..parts[1]
        for i=2,#parts do table.insert(e.lines,e.row+i-1,parts[i]) end
        e.row=e.row+#parts-1
        e.col=#e.lines[e.row]
        e.lines[e.row]=e.lines[e.row]..after
    end
    fv.ed_touch()
end
function fv.ed_insert(value,kind) fv.ed_snapshot(kind); fv.ed_insert_raw(value) end
function fv.editor_set(value)
    local e=fv.editor
    if e.loaded then fv.ed_snapshot() end
    e.lines=fv.ed_split(value or "")
    e.row,e.col,e.arow,e.acol=#e.lines,#e.lines[#e.lines],nil,nil
    fv.ed_touch()
end
function fv.editor_load()
    local e=fv.editor
    if e.loaded then return end
    local saved_script=file.read(fv.script_file)
    fv.editor_set(type(saved_script)=="string" and saved_script~="" and saved_script or "print('Hello from Nenyoo')")
    e.loaded=true
    e.row,e.col,e.scroll=1,0,0
end
function fv.editor_save() file.write(fv.script_file,fv.editor_text()) end

-- Words, positions and movement ---------------------------------------------
function fv.ed_class(ch)
    if ch=="" then return 0 elseif ch:match("[%w_]") then return 1 elseif ch:match("%s") then return 2 end
    return 3
end
function fv.ed_word_left(row,col)
    local lines=fv.editor.lines
    if col==0 then if row>1 then return row-1,#lines[row-1] end; return row,0 end
    local s=lines[row]
    while col>0 and fv.ed_class(s:sub(col,col))==2 do col=col-1 end
    local cls=fv.ed_class(s:sub(col,col))
    while col>0 and fv.ed_class(s:sub(col,col))==cls do col=col-1 end
    return row,col
end
function fv.ed_word_right(row,col)
    local lines=fv.editor.lines
    local s=lines[row]
    if col>=#s then if row<#lines then return row+1,0 end; return row,col end
    while col<#s and fv.ed_class(s:sub(col+1,col+1))==2 do col=col+1 end
    local cls=fv.ed_class(s:sub(col+1,col+1))
    while col<#s and fv.ed_class(s:sub(col+1,col+1))==cls do col=col+1 end
    return row,col
end
function fv.ed_word_at(row,col)
    local s=fv.editor.lines[row]
    local cls=fv.ed_class(s:sub(col+1,col+1))
    if cls~=1 and col>0 and fv.ed_class(s:sub(col,col))==1 then cls=1 end
    if cls==0 then return col,col end
    local a,b=col,col
    while a>0 and fv.ed_class(s:sub(a,a))==cls do a=a-1 end
    while b<#s and fv.ed_class(s:sub(b+1,b+1))==cls do b=b+1 end
    return a,b
end
function fv.ed_col_at(row,x)
    local s=fv.editor.lines[row]
    if x<=0 or s=="" then return 0 end
    local previous=0
    for i=1,#s do
        local width=text.width(font.value,s:sub(1,i))
        if width>=x then return (x-previous<width-x) and i-1 or i end
        previous=width
    end
    return #s
end
function fv.ed_move(row,col,extend,keep_goal)
    local e=fv.editor
    if extend then
        if not e.arow then e.arow,e.acol=e.row,e.col end
    else e.arow,e.acol=nil,nil end
    e.row=math.max(1,math.min(#e.lines,row))
    e.col=math.max(0,math.min(#e.lines[e.row],col))
    if not keep_goal then e.goal=nil end
    e.last_kind=nil
    fv.ed_touch()
end
function fv.ed_vertical(delta,extend)
    local e=fv.editor
    local sr,sc,er,ec=fv.ed_selection()
    if sr and not extend then
        if delta<0 then e.row,e.col=sr,sc else e.row,e.col=er,ec end
    end
    if not e.goal then e.goal=text.width(font.value,e.lines[e.row]:sub(1,e.col)) end
    local row=math.max(1,math.min(#e.lines,e.row+delta))
    local col=row==e.row and (delta<0 and 0 or #e.lines[row]) or fv.ed_col_at(row,e.goal)
    fv.ed_move(row,col,extend,true)
end

-- Line operations -------------------------------------------------------------
function fv.ed_line_span()
    local e=fv.editor
    local sr,_,er,ec=fv.ed_selection()
    if not sr then return e.row,e.row end
    if ec==0 and er>sr then er=er-1 end
    return sr,er
end
function fv.ed_shift_cols(row,delta)
    local e=fv.editor
    if e.row==row then e.col=math.max(0,e.col+delta) end
    if e.arow==row then e.acol=math.max(0,e.acol+delta) end
end
function fv.ed_indent(delta)
    local e=fv.editor
    fv.ed_snapshot()
    local a,b=fv.ed_line_span()
    for r=a,b do
        if delta>0 then
            if e.lines[r]~="" or a==b then e.lines[r]="    "..e.lines[r]; fv.ed_shift_cols(r,4) end
        else
            local n=math.min(4,#(e.lines[r]:match("^ *")))
            e.lines[r]=e.lines[r]:sub(n+1); fv.ed_shift_cols(r,-n)
        end
    end
    fv.ed_touch()
end
function fv.ed_toggle_comment()
    local e=fv.editor
    fv.ed_snapshot()
    local a,b=fv.ed_line_span()
    local all,indent=true,nil
    for r=a,b do
        local line=e.lines[r]
        if line:match("%S") then
            local lead=#line:match("^ *")
            indent=math.min(indent or lead,lead)
            if not line:match("^ *%-%-") then all=false end
        end
    end
    if not indent then return end
    for r=a,b do
        local line=e.lines[r]
        if line:match("%S") then
            if all then
                local lead,marker=line:match("^( *)(%-%- ?)")
                e.lines[r]=lead..line:sub(#lead+#marker+1); fv.ed_shift_cols(r,-#marker)
            else
                e.lines[r]=line:sub(1,indent).."-- "..line:sub(indent+1); fv.ed_shift_cols(r,3)
            end
        end
    end
    fv.ed_touch()
end
function fv.ed_move_lines(delta)
    local e=fv.editor
    local a,b=fv.ed_line_span()
    if (delta<0 and a==1) or (delta>0 and b==#e.lines) then return end
    fv.ed_snapshot("move")
    if delta<0 then table.insert(e.lines,b,table.remove(e.lines,a-1))
    else table.insert(e.lines,a,table.remove(e.lines,b+1)) end
    e.row=e.row+delta
    if e.arow then e.arow=e.arow+delta end
    fv.ed_touch()
end
function fv.ed_duplicate_lines(delta)
    local e=fv.editor
    fv.ed_snapshot()
    local a,b=fv.ed_line_span()
    for i=0,b-a do table.insert(e.lines,b+1+i,e.lines[a+i]) end
    if delta>0 then
        local count=b-a+1
        e.row=e.row+count
        if e.arow then e.arow=e.arow+count end
    end
    fv.ed_touch()
end
function fv.ed_delete_lines()
    local e=fv.editor
    fv.ed_snapshot()
    local a,b=fv.ed_line_span()
    for _=a,b do table.remove(e.lines,a) end
    if #e.lines==0 then e.lines={""} end
    e.row=math.min(a,#e.lines)
    e.col=math.min(e.col,#e.lines[e.row])
    e.arow,e.acol=nil,nil
    fv.ed_touch()
end
function fv.ed_select_next()
    local e=fv.editor
    local sr,sc,er,ec=fv.ed_selection()
    if not sr then
        local a,b=fv.ed_word_at(e.row,e.col)
        if b>a then e.arow,e.acol,e.col=e.row,a,b; fv.ed_touch() end
        return
    end
    if sr~=er then return end
    local needle=fv.ed_range_text(sr,sc,er,ec)
    for step=0,#e.lines do
        local r=(er-1+step)%#e.lines+1
        local from=(step==0) and ec+1 or 1
        local s=e.lines[r]:find(needle,from,true)
        if s then
            e.arow,e.acol,e.row,e.col=r,s-1,r,s-1+#needle
            fv.ed_touch()
            return
        end
    end
end

-- Typing ---------------------------------------------------------------------
function fv.ed_type_char(c)
    local e=fv.editor
    local line=e.lines[e.row]
    local next_char=line:sub(e.col+1,e.col+1)
    local sr,sc,er,ec=fv.ed_selection()
    local close=fv.pairs_open[c]
    if sr and close then
        fv.ed_snapshot()
        local inner=fv.ed_range_text(sr,sc,er,ec)
        fv.ed_delete_selection()
        fv.ed_insert_raw(c..inner)
        local end_row,end_col=e.row,e.col
        fv.ed_insert_raw(close)
        e.arow,e.acol,e.row,e.col=sr,sc+1,end_row,end_col
        return
    end
    if not sr and fv.pairs_close[c] and next_char==c then
        fv.ed_move(e.row,e.col+1,false); return
    end
    if not sr and close then
        local previous=line:sub(e.col,e.col)
        local free=next_char=="" or next_char:match("[%s%)%]%},;]")
        local quote=c=='"' or c=="'"
        if free and not (quote and previous:match("[%w_]")) then
            fv.ed_insert(c..close,"type")
            e.col=e.col-1
            return
        end
    end
    fv.ed_insert(c,c:match("[%w_]") and "type" or "punct")
    -- Outdent a block closer typed as the only thing on its line.
    line=e.lines[e.row]
    local lead,word=line:match("^( *)(%S+)$")
    if lead and e.col==#line and #lead>=4 and (word=="end" or word=="else" or word=="until" or
        word=="}" or word==")" or word=="]") then
        local previous_indent,previous_line=nil,nil
        for r=e.row-1,1,-1 do
            if e.lines[r]:match("%S") then previous_line=e.lines[r]; previous_indent=#previous_line:match("^ *"); break end
        end
        if previous_indent and (#lead==previous_indent or #lead==previous_indent+4) then
            e.lines[e.row]=line:sub(5); e.col=e.col-4
        end
    end
end
function fv.ed_newline()
    local e=fv.editor
    fv.ed_snapshot()
    fv.ed_delete_selection()
    local line=e.lines[e.row]
    local before,after=line:sub(1,e.col),line:sub(e.col+1)
    local indent=before:match("^ *")
    local trimmed=before:gsub("%s+$","")
    local opens=trimmed:match("[%(%[{]$") or trimmed:match("%f[%w_]then$") or trimmed:match("%f[%w_]do$") or
        trimmed:match("%f[%w_]else$") or trimmed:match("%f[%w_]repeat$") or
        (trimmed:match("%f[%w_]function%f[^%w_]") and trimmed:match("%)$"))
    if opens and after:match("^%s*[%)%]}]") then
        fv.ed_insert_raw("\n"..indent.."    ".."\n"..indent)
        e.row,e.col=e.row-1,#indent+4
    else
        fv.ed_insert_raw("\n"..indent..(opens and "    " or ""))
    end
    e.last_kind=nil
end
function fv.ed_backspace(word)
    local e=fv.editor
    if fv.ed_selection() then fv.ed_snapshot(); fv.ed_delete_selection(); return end
    fv.ed_snapshot("delete")
    if word then
        local r,c=fv.ed_word_left(e.row,e.col)
        fv.ed_delete_range(r,c,e.row,e.col); return
    end
    local line=e.lines[e.row]
    if e.col==0 then
        if e.row>1 then fv.ed_delete_range(e.row-1,#e.lines[e.row-1],e.row,0) end
        return
    end
    local before=line:sub(1,e.col)
    local open=line:sub(e.col,e.col)
    if not before:match("%S") then
        local n=(e.col-1)%4+1
        fv.ed_delete_range(e.row,e.col-n,e.row,e.col)
    elseif fv.pairs_open[open] and line:sub(e.col+1,e.col+1)==fv.pairs_open[open] then
        fv.ed_delete_range(e.row,e.col-1,e.row,e.col+1)
    else
        fv.ed_delete_range(e.row,e.col-1,e.row,e.col)
    end
end
function fv.ed_delete(word)
    local e=fv.editor
    if fv.ed_selection() then fv.ed_snapshot(); fv.ed_delete_selection(); return end
    fv.ed_snapshot("delete")
    local r,c=e.row,e.col
    if word then r,c=fv.ed_word_right(e.row,e.col)
    elseif e.col<#e.lines[e.row] then c=e.col+1
    elseif e.row<#e.lines then r,c=e.row+1,0 end
    if r~=e.row or c~=e.col then fv.ed_delete_range(e.row,e.col,r,c) end
end
function fv.ed_copy(cut)
    local e=fv.editor
    local sr,sc,er,ec=fv.ed_selection()
    local clip
    if sr then clip=fv.ed_range_text(sr,sc,er,ec); e.clip_line=nil
    else clip=e.lines[e.row].."\n"; e.clip_line=clip end
    input.set_clipboard(clip)
    if cut then
        if sr then fv.ed_snapshot(); fv.ed_delete_selection()
        else
            fv.ed_snapshot()
            if #e.lines==1 then e.lines[1]=""; e.col=0
            else table.remove(e.lines,e.row); e.row=math.min(e.row,#e.lines); e.col=math.min(e.col,#e.lines[e.row]) end
            fv.ed_touch()
        end
    end
end
function fv.ed_paste()
    local e=fv.editor
    local clip=input.get_clipboard()
    if clip=="" then return end
    fv.ed_snapshot()
    if not fv.ed_selection() and e.clip_line and clip:gsub("\r\n","\n")==e.clip_line then
        local col=e.col
        e.col=0
        fv.ed_insert_raw(clip)
        e.col=math.min(col,#e.lines[e.row])
    else fv.ed_insert_raw(clip) end
    e.last_kind=nil
end

function fv.editor_keys()
    local e=fv.editor
    local ctrl,shift,alt=input.key_down(VK.CONTROL),input.key_down(VK.SHIFT),input.key_down(VK.MENU)
    local function hit(vk) return input.key_pressed(vk) end
    if ctrl and not alt then
        if input.key_just_pressed(VK.A) then e.arow,e.acol=1,0; fv.ed_move(#e.lines,#e.lines[#e.lines],true) end
        if input.key_just_pressed(VK.C) then fv.ed_copy(false) end
        if input.key_just_pressed(VK.X) then fv.ed_copy(true) end
        if input.key_just_pressed(VK.V) then fv.ed_paste() end
        if hit(VK.Z) then if shift then fv.ed_restore(e.redo,e.undo) else fv.ed_restore(e.undo,e.redo) end end
        if hit(VK.Y) then fv.ed_restore(e.redo,e.undo) end
        if input.key_just_pressed(VK.D) then fv.ed_select_next() end
        if input.key_just_pressed(VK.L) then
            local sr,sc=fv.ed_selection()
            if not sr then e.arow,e.acol=e.row,0 end
            if e.row<#e.lines then fv.ed_move(e.row+1,0,true) else fv.ed_move(e.row,#e.lines[e.row],true) end
        end
        if shift and input.key_just_pressed(VK.K) then fv.ed_delete_lines() end
        if input.key_just_pressed(0xBF) then fv.ed_toggle_comment() end
        if input.key_just_pressed(VK.S) then fv.editor_save(); fv.notify("Script saved",true) end
        if input.key_just_pressed(VK.RETURN) then fv.run(); return end
    end
    if input.key_just_pressed(VK.F5) then fv.run(); return end
    local chars=input.get_chars()
    if chars~="" and not (ctrl and not alt) then
        for c in chars:gmatch(".") do fv.ed_type_char(c) end
    end
    if hit(VK.TAB) then
        local sr,_,er=fv.ed_selection()
        if shift then fv.ed_indent(-1)
        elseif sr and sr~=er then fv.ed_indent(1)
        else fv.ed_insert(string.rep(" ",4-e.col%4),"type") end
    end
    if hit(VK.RETURN) and not ctrl then fv.ed_newline() end
    if hit(VK.BACK) then fv.ed_backspace(ctrl) end
    if hit(VK.DELETE) then fv.ed_delete(ctrl) end
    if alt and hit(VK.UP) then if shift then fv.ed_duplicate_lines(-1) else fv.ed_move_lines(-1) end
    elseif alt and hit(VK.DOWN) then if shift then fv.ed_duplicate_lines(1) else fv.ed_move_lines(1) end
    elseif hit(VK.UP) then fv.ed_vertical(-1,shift)
    elseif hit(VK.DOWN) then fv.ed_vertical(1,shift) end
    if hit(VK.LEFT) then
        local sr,sc=fv.ed_selection()
        if sr and not shift then fv.ed_move(sr,sc,false)
        elseif ctrl then local r,c=fv.ed_word_left(e.row,e.col); fv.ed_move(r,c,shift)
        elseif e.col>0 then fv.ed_move(e.row,e.col-1,shift)
        elseif e.row>1 then fv.ed_move(e.row-1,#e.lines[e.row-1],shift) end
    end
    if hit(VK.RIGHT) then
        local sr,_,er,ec=fv.ed_selection()
        if sr and not shift then fv.ed_move(er,ec,false)
        elseif ctrl then local r,c=fv.ed_word_right(e.row,e.col); fv.ed_move(r,c,shift)
        elseif e.col<#e.lines[e.row] then fv.ed_move(e.row,e.col+1,shift)
        elseif e.row<#e.lines then fv.ed_move(e.row+1,0,shift) end
    end
    if hit(VK.HOME) then
        if ctrl then fv.ed_move(1,0,shift)
        else
            local first=#e.lines[e.row]:match("^ *")
            fv.ed_move(e.row,e.col==first and 0 or first,shift)
        end
    end
    if hit(VK.END) then
        if ctrl then fv.ed_move(#e.lines,#e.lines[#e.lines],shift) else fv.ed_move(e.row,#e.lines[e.row],shift) end
    end
    if hit(VK.PRIOR) then fv.ed_vertical(-(e.page or 15),shift) end
    if hit(VK.NEXT) then fv.ed_vertical(e.page or 15,shift) end
    if input.key_just_pressed(VK.ESCAPE) then
        if fv.ed_selection() then e.arow,e.acol=nil,nil else fv.set_focus(nil) end
    end
end

-- Lua syntax colouring for the editor. A line's tokens depend on the text and
-- the block comment / long string state carried in from the line above.
fv.syntax_colors={
    keyword={199,146,234,255},string={152,195,121,255},number={209,154,102,255},
    comment={106,115,125,255},call={97,175,239,255},builtin={86,182,194,255},
    constant={209,154,102,255}
}
fv.syntax_keywords={}
for word in ("and break do else elseif end for function goto if in local not or repeat return then until while")
    :gmatch("%a+") do fv.syntax_keywords[word]=true end
fv.syntax_constants={["true"]=true,["false"]=true,["nil"]=true}
fv.syntax_builtins={}
for word in ("print pairs ipairs next type tostring tonumber select error assert pcall xpcall require "..
    "setmetatable getmetatable rawget rawset unpack table string math os json self source exports "..
    "Citizen Wait CreateThread SetTimeout TriggerEvent TriggerServerEvent TriggerLatentServerEvent "..
    "RegisterNetEvent AddEventHandler RemoveEventHandler RegisterCommand PlayerPedId PlayerId "..
    "GetPlayerServerId GetEntityCoords vector2 vector3 vector4 vec vec2 vec3 vec4 quat")
    :gmatch("[%w_]+") do fv.syntax_builtins[word]=true end
fv.syntax_cache,fv.syntax_cache_size={},0

function fv.syntax_tokenize(source,state)
    local tokens,i,n=({}),1,#source
    local function push(kind,piece)
        local last=tokens[#tokens]
        if last and last.kind==kind then last.text=last.text..piece
        else tokens[#tokens+1]={kind=kind,text=piece} end
    end
    while i<=n do
        if state then
            local close="]"..state.eq.."]"
            local s,e=source:find(close,i,true)
            local kind=state.kind
            if s then push(kind,source:sub(i,e)); i=e+1; state=nil
            else push(kind,source:sub(i)); i=n+1 end
        else
            local rest=source:sub(i)
            local eq=rest:match("^%-%-%[(=*)%[")
            local long=not eq and rest:match("^%[(=*)%[")
            if eq then
                push("comment",rest:sub(1,#eq+4)); i=i+#eq+4; state={kind="comment",eq=eq}
            elseif rest:sub(1,2)=="--" then
                push("comment",rest); i=n+1
            elseif long then
                push("string",rest:sub(1,#long+2)); i=i+#long+2; state={kind="string",eq=long}
            elseif rest:match("^[\"']") then
                local quote,j=rest:sub(1,1),2
                while j<=#rest do
                    local c=rest:sub(j,j)
                    if c=="\\" then j=j+2 elseif c==quote then break else j=j+1 end
                end
                push("string",rest:sub(1,math.min(j,#rest))); i=i+math.min(j,#rest)
            elseif rest:match("^%d") or rest:match("^%.%d") then
                local number=rest:match("^0[xX]%x+") or rest:match("^%d*%.?%d+[eE][%+%-]?%d+") or rest:match("^%d*%.?%d*")
                push("number",number); i=i+#number
            elseif rest:match("^[%a_]") then
                local word=rest:match("^[%a_][%w_]*")
                local before=source:sub(1,i-1):match("([%.:]?)%s*$")
                local after=source:sub(i+#word):match("^%s*(.)")
                local kind="plain"
                if fv.syntax_keywords[word] then kind="keyword"
                elseif fv.syntax_constants[word] then kind="constant"
                elseif before=="" and fv.syntax_builtins[word] then kind="builtin"
                elseif after=="(" or after=="\"" or after=="'" or after=="{" then kind="call"
                elseif source:sub(1,i-1):match("function%s+[%w_%.:]*$") then kind="call" end
                push(kind,word); i=i+#word
            else
                local run=rest:match("^[^%w_\"'%-%[%.]+") or rest:sub(1,1)
                push("plain",run); i=i+#run
            end
        end
    end
    return tokens,state
end

-- Tokens with x offsets (measured on the whole prefix, like the caret) plus the
-- state handed to the next line. Cached per (text, incoming state).
function fv.syntax_line(source,state)
    local key=(state and (state.kind:sub(1,1)..state.eq) or "-").."\1"..source
    local hit=fv.syntax_cache[key]
    if hit then return hit end
    local tokens,out=fv.syntax_tokenize(source,state)
    local offset=0
    for _,token in ipairs(tokens) do
        token.x=offset>0 and text.width(font.value,source:sub(1,offset)) or 0
        offset=offset+#token.text
    end
    if fv.syntax_cache_size>3000 then fv.syntax_cache,fv.syntax_cache_size={},0 end
    hit={tokens=tokens,state=out}
    fv.syntax_cache[key]=hit; fv.syntax_cache_size=fv.syntax_cache_size+1
    return hit
end
function fv.ed_match_bracket()
    local e=fv.editor
    local pairs_fwd={["("]=")",["["]="]",["{"]="}"}
    local pairs_back={[")"]="(",["]"]="[",["}"]="{"}
    local line=e.lines[e.row]
    local candidates={{e.col+1,line:sub(e.col+1,e.col+1)},{e.col,line:sub(e.col,e.col)}}
    for _,candidate in ipairs(candidates) do
        local col,ch=candidate[1],candidate[2]
        local forward=pairs_fwd[ch]
        local back=pairs_back[ch]
        if col>=1 and (forward or back) then
            local depth,r,c=0,e.row,col
            local steps=0
            while r>=1 and r<=#e.lines and steps<20000 do
                local s=e.lines[r]
                while c>=1 and c<=#s do
                    local x=s:sub(c,c)
                    if x==ch then depth=depth+1
                    elseif x==(forward or back) then
                        depth=depth-1
                        if depth==0 then return e.row,col,r,c end
                    end
                    c=c+(forward and 1 or -1); steps=steps+1
                end
                r=r+(forward and 1 or -1)
                if r>=1 and r<=#e.lines then c=forward and 1 or #e.lines[r] end
            end
        end
    end
end
function fv.editor_draw(x,y,w,h)
    local e=fv.editor
    fv.editor_load()
    local focused=fv.focus=="editor"
    local lh=text.height(font.value)+5
    local gutter=math.max(34,text.width(font.small,tostring(#e.lines))+20)
    local tx,tw=x+gutter,w-gutter-14
    local origin_y=y+6
    e.page=math.max(1,math.floor((h-12)/lh)-1)
    local function mouse_pos()
        local row=math.floor((input.mouse_y()-origin_y+e.scroll)/lh)+1
        row=math.max(1,math.min(#e.lines,row))
        return row,fv.ed_col_at(row,input.mouse_x()-(tx+6)+e.hscroll)
    end
    if input.mouse_clicked(0) then
        if inside(x,y,w-10,h) then
            if not focused then fv.set_focus("editor"); focused=true end
            local row,col=mouse_pos()
            local now=ctx.time()
            if now-(e.last_click or 0)<.4 and e.click_row==row and math.abs((e.click_col or 0)-col)<=1 then
                e.clicks=e.clicks%3+1
            else e.clicks=1 end
            e.last_click,e.click_row,e.click_col=now,row,col
            if input.mouse_x()<tx then
                e.arow,e.acol=row,0
                if row<#e.lines then e.row,e.col=row+1,0 else e.row,e.col=row,#e.lines[row] end
                e.drag="line"; e.drag_row=row
            elseif e.clicks==2 then
                local a,b=fv.ed_word_at(row,col)
                e.arow,e.acol,e.row,e.col=row,a,row,b
                e.drag=nil
            elseif e.clicks==3 then
                e.arow,e.acol=row,0
                if row<#e.lines then e.row,e.col=row+1,0 else e.row,e.col=row,#e.lines[row] end
                e.drag=nil
            else
                fv.ed_move(row,col,input.key_down(VK.SHIFT))
                if not e.arow then e.arow,e.acol=row,col end
                e.drag="char"
            end
            e.goal,e.last_kind=nil,nil
            e.blink=ctx.time()
        elseif focused and not inside(x,y,w,h) then
            fv.set_focus(nil); focused=false
        end
    end
    if e.drag and input.mouse_down(0) then
        local my=input.mouse_y()
        if my<y then e.scroll=math.max(0,e.scroll-lh*.5) elseif my>y+h then e.scroll=e.scroll+lh*.5 end
        local row,col=mouse_pos()
        if e.drag=="line" then
            if row>=e.drag_row then
                e.arow,e.acol=e.drag_row,0
                if row<#e.lines then e.row,e.col=row+1,0 else e.row,e.col=row,#e.lines[row] end
            else
                e.arow,e.acol=e.drag_row<#e.lines and e.drag_row+1 or e.drag_row,
                    e.drag_row<#e.lines and 0 or #e.lines[e.drag_row]
                e.row,e.col=row,0
            end
        else e.row,e.col=row,col end
        e.blink=ctx.time()
    elseif e.drag then
        e.drag=nil
        if not fv.ed_selection() then e.arow,e.acol=nil,nil end
    end
    if focused then fv.editor_keys() end

    local total=#e.lines*lh+12
    local maximum=math.max(0,total-h)
    if e.follow then
        local top=(e.row-1)*lh
        if top<e.scroll then e.scroll=top end
        if top+lh+12>e.scroll+h then e.scroll=top+lh+12-h end
    end
    e.scroll=smooth_scroll(0xF500,e.scroll,maximum,inside(x,y,w,h),lh*3,16)
    e.scroll=math.max(0,math.min(maximum,e.scroll))
    local caret_x=text.width(font.value,e.lines[e.row]:sub(1,e.col))
    if e.follow or e.drag then
        if caret_x<e.hscroll then e.hscroll=math.max(0,caret_x-40) end
        if caret_x>e.hscroll+tw-8 then e.hscroll=caret_x-tw+40 end
        e.follow=false
    end

    fill(x,y,w,h,palette.input,2)
    local a=motion_to("fv_editor_focus",focused and 1 or 0,22,0)
    if a>.01 then outline(x,y,w,h,{palette.accent[1],palette.accent[2],palette.accent[3],math.floor(90*a)},2) end
    fill(x,y,gutter-6,h,{0,0,0,40},2)
    local sr,sc,er,ec=fv.ed_selection()
    draw.push_clip(x,y,x+w,y+h)
    local first=math.max(1,math.floor(e.scroll/lh)+1)
    local last=math.min(#e.lines,first+math.ceil(h/lh)+1)
    local origin=tx+6-e.hscroll
    for i=first,last do
        local ly=origin_y+(i-1)*lh-e.scroll
        if focused and i==e.row and not sr then fill(x+gutter-6,ly,w-gutter+6,lh,{255,255,255,8}) end
        local number=tostring(i)
        local active=i==e.row and focused
        txt(font.small,x+gutter-14-text.width(font.small,number),ly+(lh-text.height(font.small))*.5,
            active and palette.dim or palette.faint,number)
    end
    draw.push_clip(tx,y,tx+tw+8,y+h)
    if sr then
        local alpha=focused and 70 or 40
        for i=math.max(first,sr),math.min(last,er) do
            local ly=origin_y+(i-1)*lh-e.scroll
            local line=e.lines[i]
            local from=i==sr and sc or 0
            local to=i==er and ec or #line
            local x1=from>0 and text.width(font.value,line:sub(1,from)) or 0
            local x2=to>0 and text.width(font.value,line:sub(1,to)) or 0
            if i<er then x2=x2+6 end
            if x2>x1 then fill(origin+x1,ly,x2-x1,lh,{palette.accent[1],palette.accent[2],palette.accent[3],alpha}) end
        end
    end
    if focused and not sr then
        local br,bc,mr,mc=fv.ed_match_bracket()
        if br then
            for _,spot in ipairs({{br,bc},{mr,mc}}) do
                local r,c=spot[1],spot[2]
                if r>=first and r<=last then
                    local line=e.lines[r]
                    local x1=c>1 and text.width(font.value,line:sub(1,c-1)) or 0
                    local x2=text.width(font.value,line:sub(1,c))
                    outline(origin+x1-1,origin_y+(r-1)*lh-e.scroll+1,x2-x1+2,lh-2,{palette.dim[1],palette.dim[2],palette.dim[3],150},2)
                end
            end
        end
    end
    local states,state={},nil
    for i=1,last do states[i]=state; state=fv.syntax_line(e.lines[i],state).state end
    for i=first,last do
        local ly=origin_y+(i-1)*lh-e.scroll
        if e.lines[i]~="" then
            for _,token in ipairs(fv.syntax_line(e.lines[i],states[i]).tokens) do
                local tx0=origin+token.x
                if tx0>tx+tw+8 then break end
                txt(font.value,tx0,ly+2,fv.syntax_colors[token.kind] or palette.text,token.text)
            end
        end
    end
    if focused and (ctx.time()-(e.blink or 0))%1<.6 then
        fill(origin+caret_x,origin_y+(e.row-1)*lh-e.scroll+2,1.2,lh-4,palette.accentHi)
    end
    draw.pop_clip()
    draw.pop_clip()
    if maximum>0 then e.scroll=ui.scrollbar(0xF501,x+w-7,y+6,y+h-6,e.scroll,maximum,total) end
end
function fv.run()
    fv.editor_save()
    local code=fv.editor_text()
    if code:match("^%s*$") then fv.notify("Script is empty",false); return end
    if fivem.preview() then fv.notify("Preview only: attach to FiveM to run scripts",false); return end
    if not fivem.attached() then fv.notify("Not attached to a FiveM client",false); return end
    if fivem.random_each_run() then fivem.randomize_resource_name() end
    if fivem.execute(code) then
        fv.notify("Script queued",true); fv.console_follow=true; fv.refresh("console")
    else fv.notify("Script could not be queued",false) end
end

-- Scrolling console shared by the executor and the Trigger tab.
function fv.console_draw(x,y,w,h)
    local lines=fv.cached("console",.2,fivem.console)
    local lh=text.height(font.small)+4
    local total=#lines*lh+12
    local maximum=math.max(0,total-h)
    local hovered=inside(x,y,w,h)
    local wheel=hovered and input.mouse_wheel() or 0
    if wheel>0 then fv.console_follow=false end
    if fv.console_follow then fv.console_scroll=maximum end
    fv.console_scroll=smooth_scroll(0xF510,fv.console_scroll,maximum,hovered,lh*3,16)
    if not fv.console_follow and wheel<=0 and fv.console_scroll>=maximum-1 then fv.console_follow=true end
    fill(x,y,w,h,palette.input,2)
    draw.push_clip(x,y,x+w,y+h)
    if #lines==0 then
        txt(font.small,x+10,y+10,palette.faint,"Output from scripts and triggers appears here")
    end
    local first=math.max(1,math.floor(fv.console_scroll/lh)+1)
    local last=math.min(#lines,first+math.ceil(h/lh)+1)
    for i=first,last do
        local value=lines[i]
        local color=palette.text
        if value:find("%[error%]") or value:find("[Ee]rror") then color={235,120,110,255}
        elseif value:find("^%[") then color=palette.dim end
        txt_ellipsis(font.small,x+10,y+6+(i-1)*lh-fv.console_scroll,color,value,w-24)
    end
    draw.pop_clip()
    if maximum>0 then
        local value=ui.scrollbar(0xF511,x+w-7,y+6,y+h-6,fv.console_scroll,maximum,total)
        if value~=fv.console_scroll then fv.console_scroll=value; fv.console_follow=value>=maximum-1 end
    end
end

function fv.draw_executor(x,y,w,h,radius)
    local pad,gap=18,16
    local side=math.min(260,math.max(210,w*.3))
    local lw=w-pad*2-side-gap
    local script_h=math.floor((h-pad*2-gap)*.62)
    local bx,by,bw,bh=panel(x+pad,y+pad,lw,script_h,"Script","",radius)
    fv.editor_draw(bx,by,bw,bh-4)
    local oy=y+pad+script_h+gap
    bx,by,bw,bh=panel(x+pad,oy,lw,y+h-pad-oy,"Output","",radius)
    fv.console_draw(bx,by,bw,bh-4)

    local sx=x+pad+lw+gap
    bx,by,bw,bh=panel(sx,y+pad,side,176,"Run","",radius)
    fv.status_line(bx,by,bw)
    local can_run=fivem.attached()
    if fv.button(bx,by+26,bw,32,"Execute",true,can_run or fivem.preview()) then fv.run() end
    txt(font.small,bx,by+64,palette.faint,"Ctrl+Enter runs from the editor")
    if fv.button(bx,by+84,bw,28,"Stop Script",false,can_run and fivem.is_running()) then
        fivem.stop(); fv.notify("Stop requested",true)
    end
    fv.draw_notice(bx,by+120,bw)

    local ry=y+pad+176+gap
    bx,by,bw,bh=panel(sx,ry,side,150,"Resource","",radius)
    txt(font.small,bx,by,palette.dim,"Resource name")
    local current=fivem.resource_name()
    if fv.focus~="resource" then fv.resource_edit=current end
    local value,submitted=fv.field("resource",bx,by+16,bw,28,fv.resource_edit or current,"Random name")
    fv.resource_edit=value
    if submitted or (fv.focus~="resource" and value~=current) then
        fivem.set_resource_name(value); fv.resource_edit=fivem.resource_name()
        if submitted then fv.set_focus(nil) end
    end
    local random_each=fivem.random_each_run()
    local next_value=fv.toggle(bx,by+52,bw,"New Name Each Run",random_each)
    if next_value~=random_each then fivem.set_random_each_run(next_value) end
    if fv.button(bx,by+82,bw,28,"Randomize Name",false,true) then
        fv.resource_edit=fivem.randomize_resource_name()
    end

    local cy=ry+150+gap
    bx,by,bw,bh=panel(sx,cy,side,math.max(96,y+h-pad-cy),"Clean Up","",radius)
    if fv.button(bx,by,bw,28,"Clear Output",false,true) then fivem.console_clear(); fv.refresh("console") end
    if fv.button(bx,by+36,bw,28,"Clear Script",false,true) then fv.editor_set(""); fv.editor_save() end
end

-- Virtualized row list inside a panel body. draw_row(item,x,y,w,h) draws one row.
function fv.list(id,x,y,w,h,rows,row_h,empty,draw_row)
    local total=#rows*row_h
    local maximum=math.max(0,total-h)
    local current=smooth_scroll(0xF520+id,fv.list_scroll[id] or 0,maximum,inside(x,y,w,h),row_h*2,16)
    current=math.max(0,math.min(maximum,current)); fv.list_scroll[id]=current
    draw.push_clip(x,y,x+w,y+h)
    if #rows==0 then txt_wrap(font.small,x+4,y+6,palette.faint,empty,w-8) end
    local first=math.max(1,math.floor(current/row_h)+1)
    local last=math.min(#rows,first+math.ceil(h/row_h)+1)
    for i=first,last do
        local ry=y+(i-1)*row_h-current
        if i>1 then fill(x,ry,w-10,1,palette.border) end
        draw_row(rows[i],x,ry,w-10,row_h)
    end
    draw.pop_clip()
    if maximum>0 then fv.list_scroll[id]=ui.scrollbar(0xF530+id,x+w-7,y,y+h,current,maximum,total) end
end
function fv.matches(filter,...)
    if filter=="" then return true end
    local needle=filter:lower()
    for _,value in ipairs({...}) do
        if value and value:lower():find(needle,1,true) then return true end
    end
    return false
end
function fv.use_trigger(name,kind)
    fv.trigger.name,fv.trigger.kind=name,kind or 0
    request_navigation("events","Trigger")
end
function fv.small_button(x,y,label,active)
    local w=text.width(font.small,label)+14
    local hover=inside(x,y,w,20)
    fill(x,y,w,20,(hover or active) and palette.side or palette.input,2)
    txt(font.small,x+7,y+(20-text.height(font.small))*.5,active and palette.accentHi or palette.text,label)
    if hover and input.mouse_clicked(0) then input.consume_mouse_click(); return true,w end
    return false,w
end

function fv.draw_live(x,y,w,h,radius)
    local pad,gap=18,16
    local side=math.min(240,math.max(200,w*.28))
    local lw=w-pad*2-side-gap
    local rows=fv.cached("events",.25,fivem.events)
    local shown={}
    for i=#rows,1,-1 do
        local row_data=rows[i]
        if fv.matches(fv.live_filter,row_data.name,row_data.resource,row_data.args) then shown[#shown+1]=row_data end
    end
    fv.live_filter=fv.field("live_filter",x+pad,y+pad,math.min(320,lw-120),30,fv.live_filter,"Filter by name, resource or arguments")
    local count=string.format("%d shown, %d total",#shown,fivem.event_total())
    txt(font.small,x+pad+math.min(320,lw-120)+12,y+pad+9,palette.dim,count)
    if fv.button(x+pad+lw-80,y+pad,80,30,"Clear",false,#rows>0) then fivem.events_clear(); fv.refresh("events") end
    local ly=y+pad+42
    local bx,by,bw,bh=panel(x+pad,ly,lw,y+h-pad-ly,"Event Log","",radius)
    local empty=fivem.hook_installed() and "No events captured yet" or
        "Waiting for a FiveM session. Events appear here once the event hook is active."
    if fivem.preview() then empty="No sample events left" end
    fv.list(1,bx,by,bw,bh-4,shown,46,empty,function(row_data,rx,ry,rw,rh)
        local badge=fv.kind_names[row_data.kind] or "Client"
        local bwid=fv.badge(rx,ry+7,string.upper(badge),fv.kind_color(row_data.kind))
        local blocked=fivem.is_blocked(row_data.name)
        local actions_w=112
        txt_ellipsis(font.item,rx+bwid+8,ry+5,blocked and palette.faint or palette.text,row_data.name,rw-bwid-actions_w-60)
        local detail=row_data.resource~="" and row_data.resource or "unknown resource"
        if row_data.args~="" then detail=detail.."  "..row_data.args end
        txt_ellipsis(font.small,rx,ry+26,palette.dim,detail,rw-actions_w-60)
        local age=fv.age(row_data.time)
        txt(font.small,rx+rw-actions_w-8-text.width(font.small,age),ry+8,palette.faint,age)
        local use,uw=fv.small_button(rx+rw-actions_w,ry+5,"Use",false)
        if use then fv.use_trigger(row_data.name,row_data.kind) end
        local block=fv.small_button(rx+rw-actions_w+uw+6,ry+5,blocked and "Unblock" or "Block",blocked)
        if block then fivem.set_blocked(row_data.name,not blocked); fv.refresh("blocked") end
    end)

    local sx=x+pad+lw+gap
    bx,by,bw,bh=panel(sx,y+pad,side,h-pad*2,"Blocked Events","",radius)
    txt_wrap(font.small,bx,by,palette.dim,"Blocked events are swallowed before they reach scripts.",bw)
    local value,submitted=fv.field("block_input",bx,by+34,bw,28,fv.block_input,"Event name to block")
    fv.block_input=value
    if submitted and value~="" then fivem.set_blocked(value,true); fv.block_input=""; fv.refresh("blocked") end
    local blocked=fv.cached("blocked",.5,fivem.blocklist)
    fv.list(2,bx,by+72,bw,bh-76,blocked,30,"Nothing blocked",function(name,rx,ry,rw,rh)
        txt_ellipsis(font.value,rx,ry+(rh-text.height(font.value))*.5,palette.text,name,rw-70)
        local unblock=fv.small_button(rx+rw-62,ry+5,"Unblock",false)
        if unblock then fivem.set_blocked(name,false); fv.refresh("blocked") end
    end)
end

function fv.draw_trigger(x,y,w,h,radius)
    local pad,gap=18,16
    local lw=math.min(380,math.max(300,w*.45))
    local bx,by,bw,bh=panel(x+pad,y+pad,lw,h-pad*2,"Fire Event","",radius)
    fv.status_line(bx,by,bw)
    local t=fv.trigger
    local fy=by+28
    txt(font.small,bx,fy,palette.dim,"Event name")
    local submitted
    t.name,submitted=fv.field("trigger_name",bx,fy+16,bw,30,t.name,"resource:eventName")
    fy=fy+60
    txt(font.small,bx,fy,palette.dim,"Send as")
    local segment_w=(bw-8)/3
    for kind=0,2 do
        local sx=bx+kind*(segment_w+4)
        local active=t.kind==kind
        local hover=inside(sx,fy+16,segment_w,28)
        fill(sx,fy+16,segment_w,28,active and palette.side or (hover and palette.side or palette.input),2)
        if active then fill(sx,fy+42,segment_w,2,palette.accent,1) end
        local label=fv.kind_names[kind]
        txt(font.value,sx+(segment_w-text.width(font.value,label))*.5,fy+16+(28-text.height(font.value))*.5,
            active and palette.accentHi or palette.text,label)
        if hover and input.mouse_clicked(0) then t.kind=kind end
    end
    local hints={[0]="TriggerEvent: runs handlers in this client",
        [1]="TriggerServerEvent: sends the event to the server",
        [2]="TriggerLatentServerEvent: throttled send for large payloads"}
    txt_ellipsis(font.small,bx,fy+50,palette.faint,hints[t.kind],bw)
    fy=fy+76
    txt(font.small,bx,fy,palette.dim,"Arguments (Lua expression)")
    local args_submitted
    t.args,args_submitted=fv.field("trigger_args",bx,fy+16,bw,30,t.args,"{1, 'text', vector3(0, 0, 0)}")
    fy=fy+60
    local can_fire=fivem.attached() and t.name~=""
    if fv.button(bx,fy,bw,34,"Fire Event",true,can_fire or fivem.preview()) or
       ((submitted or args_submitted) and can_fire) then
        if fivem.preview() then fv.notify("Preview only: attach to FiveM to fire events",false)
        elseif t.name=="" then fv.notify("Enter an event name",false)
        elseif fivem.trigger(t.kind,t.name,t.args) then
            fv.notify("Fired "..t.name,true); fv.console_follow=true; fv.refresh("console")
        else fv.notify("Event could not be fired",false) end
    end
    fv.draw_notice(bx,fy+42,bw)
    txt_wrap(font.small,bx,fy+66,palette.faint,
        "Tip: pick Use on a live or scanned event to fill this form.",bw)

    local ox=x+pad+lw+gap
    bx,by,bw,bh=panel(ox,y+pad,w-pad*2-lw-gap,h-pad*2,"Output","",radius)
    fv.console_draw(bx,by,bw,bh-4)
end

function fv.draw_scanner(x,y,w,h,radius)
    local pad=18
    local lw=w-pad*2
    local scanning=fivem.scanning()
    if scanning then
        if fv.button(x+pad,y+pad,130,30,"Cancel Scan",false,true) then fivem.scan_cancel() end
        local progress=math.max(0,math.min(1,fivem.scan_progress()))
        local px,pw=x+pad+142,math.min(260,lw-300)
        fill(px,y+pad+13,pw,4,palette.input,2)
        fill(px,y+pad+13,pw*progress,4,palette.accent,2)
        txt(font.small,px+pw+10,y+pad+8,palette.dim,string.format("Scanning %.0f%%",progress*100))
        fv.scan_was_running=true
    else
        if fv.scan_was_running then fv.scan_was_running=false; fv.refresh("scan") end
        if fv.button(x+pad,y+pad,130,30,"Scan Resources",true,true) then fivem.scan_start(); fv.refresh("scan") end
    end
    local rows=fv.cached("scan",scanning and .5 or 5,fivem.scan_results)
    local shown={}
    for _,row_data in ipairs(rows) do
        if fv.matches(fv.scan_filter,row_data.name,row_data.resource,row_data.code) then shown[#shown+1]=row_data end
    end
    local fw=math.min(300,lw-460)
    fv.scan_filter=fv.field("scan_filter",x+pad+lw-fw,y+pad,fw,30,fv.scan_filter,"Filter results")
    if not scanning then
        local summary=#rows>0 and string.format("%d events in %d resources",#rows,fivem.scan_resource_count()) or
            "Finds every event a server's client scripts register or trigger"
        txt_ellipsis(font.small,x+pad+142,y+pad+9,palette.dim,summary,lw-fw-160)
    end
    local ly=y+pad+42
    local bx,by,bw,bh=panel(x+pad,ly,lw,y+h-pad-ly,"Scan Results","",radius)
    local empty=#rows==0 and "Run a scan to list events from the server's downloaded resources." or "No results match the filter"
    fv.list(3,bx,by,bw,bh-4,shown,46,empty,function(row_data,rx,ry,rw,rh)
        local kind=fv.scan_kinds[row_data.kind] or fv.scan_kinds[0]
        local bwid=fv.badge(rx,ry+7,kind[1],fv.kind_color(row_data.kind==0 and -1 or kind[2]))
        txt_ellipsis(font.item,rx+bwid+8,ry+5,palette.text,row_data.name,rw-bwid-190)
        local file_name=row_data.file:match("([^\\/]+)$") or row_data.file
        txt_ellipsis(font.small,rx,ry+26,palette.dim,
            string.format("%s  %s:%d  %s",row_data.resource,file_name,row_data.line,row_data.code),rw-130)
        local use,uw=fv.small_button(rx+rw-112,ry+5,"Use",false)
        if use then fv.use_trigger(row_data.name,kind[2]) end
        local blocked=fivem.is_blocked(row_data.name)
        if fv.small_button(rx+rw-112+uw+6,ry+5,blocked and "Unblock" or "Block",blocked) then
            fivem.set_blocked(row_data.name,not blocked); fv.refresh("blocked")
        end
    end)
end

function fv.draw_events(x,y,w,h,radius)
    if fv.events_tab=="Trigger" then fv.draw_trigger(x,y,w,h,radius)
    elseif fv.events_tab=="Scanner" then fv.draw_scanner(x,y,w,h,radius)
    else fv.draw_live(x,y,w,h,radius) end
end
function fv.draw_unavailable(x,y,w,h)
    txt(font.item,x+18,y+18,palette.dim,"FiveM tools are not available in this build")
end

local function draw_page(x,y,w,h,radius)
    local page_id,page_name=menu.page_id(),menu.page_name()
    local home_id,settings_id=items.joaat("Home"),items.joaat("Settings")
    local misc_id=items.joaat("Misc")
    local combat_id=items.joaat("Combat")
    local lock_id=items.joaat("Lock-on Aimbot")
    local silent_id=items.joaat("Silent Aim")
    local magic_id=items.joaat("Magic Bullet")
    local executor_id,events_id=items.joaat("Lua Executor"),items.joaat("Events")
    if fv.focus and (search_focus or (page_id~=executor_id and page_id~=events_id)) then fv.set_focus(nil) end
    if page_id==menu.root_page() or page_name=="" then
        menu.replace_page(home_id); page_id,page_name=home_id,"Home"
    end
    if page_id==home_id then
        draw_welcome(x,y,w,h,radius)
        return
    end
    -- Keep the same compact Settings surface on both targets.
    -- Target-specific pages are still available through their own registry routes.
    local section=settings_section_for(page_id)
    if section then
        if search_target and search_target.pending then
            section=settings_section_for(search_target.page_id,search_target.handle) or section
        end
        settings_tab=section
        if page_id~=settings_id then menu.replace_page(settings_id) end
        settings_columns(x,y,w,h,radius); return
    end
    if page_id==executor_id or page_id==events_id then
        if not fv.available() then fv.draw_unavailable(x,y,w,h)
        elseif page_id==executor_id then fv.draw_executor(x,y,w,h,radius)
        else fv.draw_events(x,y,w,h,radius) end
        return
    end
    if page_id==misc_id then visuals_cards(x,y,w,h,radius,misc_id,misc_definition); return end
    local visual_root,selected=visual_section_for(page_id,page_name)
    if visual_root then
        if selected then visual_tabs[visual_root]=selected end
        if page_id~=items.joaat(visual_root) then menu.replace_page(items.joaat(visual_root)) end
        draw_visuals_tab(x,y,w,h,radius,visual_root); return
    end
    if page_id==combat_id then combat_tabs(x,y,w,h,radius); return end
    if page_id==lock_id or page_id==silent_id or page_id==magic_id then
        local selected=page_id==lock_id and 1 or (page_id==silent_id and 2 or 3)
        menu.replace_page(combat_id)
        combat_tabs(x,y,w,h,radius,selected)
        return
    end
    grouped_page(x,y,w,h,radius,page_id,registry_groups(page_id,page_name))
end

local function search_box(x,y,w,h,radius,interactive)
    if interactive and clicked(x,y,w,h) then search_focus=true end
    if search_focus and input.mouse_clicked(0) and not inside(x,y,w,h) and
        not (search_popup_bounds and inside(search_popup_bounds.x,search_popup_bounds.y,
            search_popup_bounds.w,search_popup_bounds.h)) then search_focus=false end
    if search_focus then
        local chars=input.get_chars(); if chars~="" then search=search..chars end
        if input.key_just_pressed(VK.BACK) then search=search:sub(1,math.max(0,#search-1)) end
        if input.key_just_pressed(VK.ESCAPE) then search_focus=false end
    end
    local focus_a=motion_to("search_focus",search_focus and 1 or 0,22,0)
    fill(x,y,w,h,{palette.text[1],palette.text[2],palette.text[3],math.floor(8+8*focus_a)},radius)
    outline(x,y,w,h,mix_color(palette.border,{palette.accent[1],palette.accent[2],palette.accent[3],150},focus_a),radius)
    if not halo.glyph("Search",x+16,y+h*.5,palette.dim) then
        draw.circle_outline(x+15,y+h*.5-1,4.5,palette.dim[1],palette.dim[2],palette.dim[3],palette.dim[4],1.5)
        line(x+18.5,y+h*.5+2.5,x+22,y+h*.5+6,palette.dim,1.5)
    end
    txt_ellipsis(font.small,x+30,y+(h-text.height(font.small))*.5,search=="" and palette.dim or palette.text,
        search=="" and "Search features..." or search,w-40)
    -- Results are wider than the sidebar field so feature and page names stay readable.
    w=math.max(w,300)
    local show=interactive and search_focus and search~=""
    if show then search_popup_query=search end
    local popup=motion_to("search_popup",show and 1 or 0,22,0)
    if popup<.01 or search_popup_query=="" then search_popup_bounds=nil; return end
    local results=items.search(search_popup_query)
    local count=math.min(#results,6)
    local oh=math.max(1,count)*40+8
    search_popup_bounds=show and {x=x,y=y+h+6,w=w,h=oh} or nil
    local function open_result(handle,item)
        local destination=item.page_id
        local focus_handle=handle
        if item.type==item_type.sub_menu then
            local child=items.submenu_page_id(handle)
            if child and child~=0 then
                destination=child
                focus_handle=nil
            end
        end
        request_navigation("search",{
            page_id=destination,handle=focus_handle
        })
        search,search_focus="",false
        search_popup_bounds=nil
    end
    if show and count>0 and input.key_just_pressed(VK.RETURN) then
        local handle=results[1]
        local item=items.at(handle)
        if item then open_result(handle,item) end
    end
    draw.push_motion(0,-5*(1-popup),popup)
    fill(x,y+h+6,w,oh,palette.panel,radius); outline(x,y+h+6,w,oh,palette.border,radius)
    if count==0 then txt(font.small,x+14,y+h+22,palette.dim,"No matching features") end
    for i=1,count do
        local handle,item=results[i],items.at(results[i]); local ry=y+h+10+(i-1)*40
        local hov=show and item and inside(x+4,ry,w-8,36)
        local row_a=motion_to("search_row_"..handle,hov and 1 or 0,26,0)
        if row_a>.01 then fill(x+4,ry,w-8,36,palette.side,radius,math.floor(190*row_a)) end
        if item then
            txt_ellipsis(font.small,x+14,ry+5,palette.text,item.name,w-28)
            txt_ellipsis(font.small,x+14,ry+20,palette.dim,item.page,w-28)
            if show and search_popup_click and hov then open_result(handle,item) end
        end
    end
    draw.pop_motion()
end

local function compact_search(x,y,w,h,radius)
    local hover=inside(x,y,32,h)
    if clicked(x,y,32,h) then
        search_expanded=not search_expanded
        search_focus=search_expanded
        if search_expanded then
            language_open=false
            search,search_popup_query="",""
            motion_reset("search_popup",0)
        end
        input.consume_mouse_click()
    end
    if search_expanded and input.key_just_pressed(VK.ESCAPE) then
        search_expanded,search_focus=false,false
    end
    local active=motion_to("search_icon",(search_expanded or hover) and 1 or 0,22,0)
    local tint=mix_color(palette.dim,palette.accentHi,active)
    local rounding=math.max(radius,6)
    if active>.01 then fill(x,y,32,h,palette.side,rounding,math.floor(palette.side[4]*active)) end
    draw.circle_outline(x+14,y+h*.5-1,5,tint[1],tint[2],tint[3],tint[4],1.5)
    line(x+18,y+h*.5+3,x+22,y+h*.5+7,tint,1.5)
    local reveal=motion_to("search_reveal",search_expanded and 1 or 0,20,0)
    if reveal>.01 then
        local box_w=w*(.92+.08*reveal)
        draw.push_motion(0,0,reveal)
        search_box(x-box_w-8,y,box_w,h,rounding,search_expanded)
        draw.pop_motion()
        if not search_focus then search_expanded=false end
    end
    if not search_expanded then
        search_popup_bounds=nil
        if reveal<=.01 then
            search,search_popup_query="",""
            motion_reset("search_popup",0)
        end
    end
end
__overlay_draws = __overlay_draws or {}
__overlay_draws.story_features = function()
    if type(story) ~= "table" then return end
    local any_enabled=story.aim_enabled() or story.esp_enabled() or story.vehicle_esp() or story.object_esp() or story.diagnostics() or story.silent_enabled() or story.magic_enabled()
    if any_enabled and not story.ready() then
        -- World data can legitimately be absent on FiveM's home screen.
        -- Keep this persistent banner for the explicit Diagnostics mode.
        if not story.diagnostics() then return end
        draw.rect(18,18,390,52,palette.panel[1],palette.panel[2],palette.panel[3],235,6)
        draw.rect_outline(18,18,390,52,palette.accent[1],palette.accent[2],palette.accent[3],130,6,1,true)
        text.draw(font.small,30,28,palette.text[1],palette.text[2],palette.text[3],235,story.status())
        return
    end
    if (story.silent_enabled() or story.magic_enabled()) and not story.weapon_redirect_ready() then
        draw.rect(18,18,440,52,palette.panel[1],palette.panel[2],palette.panel[3],235,6)
        draw.rect_outline(18,18,440,52,palette.accent[1],palette.accent[2],palette.accent[3],130,6,1,true)
        text.draw(font.small,30,28,palette.text[1],palette.text[2],palette.text[3],235,
            "Weapon redirect unavailable: FireDelayedHit signature missing")
        return
    end
    if story.aim_enabled() and story.show_fov() then
        draw.circle_outline(ctx.screen_w()*.5,ctx.screen_h()*.5,story.aim_fov(),
            palette.accent[1],palette.accent[2],palette.accent[3],150,1.25)
    end
    if story.silent_enabled() and story.silent_show_fov() then
        draw.circle_outline(ctx.screen_w()*.5,ctx.screen_h()*.5,story.silent_fov(),
            palette.accentHi[1],palette.accentHi[2],palette.accentHi[3],130,1)
    end
    if story.magic_enabled() then
        draw.circle_outline(ctx.screen_w()*.5,ctx.screen_h()*.5,story.magic_fov(),
            palette.green[1],palette.green[2],palette.green[3],130,1)
    end
    local targets=story.targets()
    if story.silent_enabled() or story.magic_enabled() then
        local aim_indices={1,8,9}
        local chosen=story.magic_enabled() and story.magic_bone() or story.silent_bone()
        local redirect_index=aim_indices[(chosen or 0)+1] or 1
        for _,target in ipairs(targets) do
            if target.selected and target.bones and target.bones[redirect_index] then
                local point=target.bones[redirect_index]
                if point.visible then
                    local color=story.magic_enabled() and palette.green or palette.accentHi
                    draw.circle_outline(point.x,point.y,6,color[1],color[2],color[3],230,1.5)
                end
            end
        end
    end
    if story.aim_enabled() and (story.aim_target_line() or story.aim_target_marker()) then
        local aim_indices={1,8,9}
        local aim_index=aim_indices[(story.aim_bone() or 0)+1] or 1
        for _,target in ipairs(targets) do
            if target.selected and target.bones and target.bones[aim_index] then
                local point=target.bones[aim_index]
                if point.visible then
                    if story.aim_target_line() then
                        draw.line(ctx.screen_w()*.5,ctx.screen_h()*.5,point.x,point.y,
                            palette.accent[1],palette.accent[2],palette.accent[3],190,1.25)
                    end
                    if story.aim_target_marker() then
                        draw.circle(point.x,point.y,3.25,
                            palette.accentHi[1],palette.accentHi[2],palette.accentHi[3],240)
                    end
                end
            end
        end
    end
    if story.esp_enabled() then
    local pr,pg,pb,pa=story.esp_primary_color()
    local sr,sg,sb,sa=story.esp_secondary_color()
    local fr,fg,fb,fa=story.esp_friend_color()
    local mr,mg,mb,ma=story.esp_marker_color()
    local nr,ng,nb,na=story.esp_snapline_color()
    local primary,secondary,friend,marker,snap_color={pr,pg,pb,pa},{sr,sg,sb,sa},{fr,fg,fb,fa},{mr,mg,mb,ma},{nr,ng,nb,na}
    local mode=story.esp_color_mode()
    local rainbow_phase=ctx.time()*math.max(.05,story.esp_rainbow_speed())*.18
    local function esp_color(target,t)
        if target.friend then return friend end
        if mode==1 then
            local r,g,b=util.hsv_to_rgb((rainbow_phase+t*.22)%1,1,1)
            return {r,g,b,primary[4]}
        end
        if mode==2 then return mix_color(primary,secondary,t) end
        return primary
    end
    local function esp_line(x1,y1,x2,y2,target,t1,t2,alpha,thickness)
        if target.friend or mode==0 then
            local c=esp_color(target,0)
            draw.line(x1,y1,x2,y2,c[1],c[2],c[3],math.floor(c[4]*alpha),thickness)
            return
        end
        for segment=0,7 do
            local a,b=segment/8,(segment+1)/8
            local c=esp_color(target,t1+(t2-t1)*(a+b)*.5)
            draw.line(x1+(x2-x1)*a,y1+(y2-y1)*a,x1+(x2-x1)*b,y1+(y2-y1)*b,
                c[1],c[2],c[3],math.floor(c[4]*alpha),thickness)
        end
    end
    local function bone_line(bones,a,b,color)
        local p1,p2=bones[a],bones[b]
        if p1 and p2 and p1.visible and p2.visible then
            draw.line(p1.x,p1.y,p2.x,p2.y,color[1],color[2],color[3],color[4],1.25)
        end
    end
    for _,target in ipairs(targets) do
      if not target.friend or story.esp_show_friends() then
        local joint_height=math.abs(target.feet_y-target.head_y)
        local on_screen=target.head_x>=0 and target.head_x<=ctx.screen_w() and target.head_y>=0 and target.head_y<=ctx.screen_h()
        if not on_screen and story.esp_offscreen() then
            local edge_x=math.max(16,math.min(ctx.screen_w()-16,target.head_x))
            local edge_y=math.max(16,math.min(ctx.screen_h()-16,target.head_y))
            local edge_color=target.friend and friend or marker
            draw.circle_outline(edge_x,edge_y,6,edge_color[1],edge_color[2],edge_color[3],edge_color[4],1.5)
        elseif joint_height>4 and joint_height<ctx.screen_h()*1.5 then
            -- The stored head joint projects near the face/neck, not the top
            -- of the skull. Extend the box by a fraction of projected stature
            -- so its upper edge actually encloses the visible head.
            local top=math.min(target.head_y,target.feet_y)-joint_height*.095
            local bottom=math.max(target.head_y,target.feet_y)+joint_height*.015
            local height=bottom-top
            local width=math.max(height*.40,math.abs(target.feet_x-target.head_x)+height*.28)
            local center_x=(target.head_x+target.feet_x)*.5
            local left=center_x-width*.5
            local color=target.friend and friend or marker
            if story.esp_snaplines() then
                local origin=story.esp_snapline_origin()
                local start_y=origin==1 and ctx.screen_h()*.5 or (origin==2 and 2 or ctx.screen_h()-2)
                local endpoint=story.esp_snapline_end()
                local end_x=endpoint==2 and target.head_x or (endpoint==1 and center_x or target.feet_x)
                local end_y=endpoint==2 and target.head_y or (endpoint==1 and (top+bottom)*.5 or bottom)
                local start_x=ctx.screen_w()*.5
                local line_weight=story.esp_snapline_thickness()
                if mode==2 and not target.friend then
                    for segment=0,7 do
                        local a,b=segment/8,(segment+1)/8
                        local sc=mix_color(snap_color,secondary,(a+b)*.5)
                        draw.line(start_x+(end_x-start_x)*a,start_y+(end_y-start_y)*a,
                            start_x+(end_x-start_x)*b,start_y+(end_y-start_y)*b,
                            sc[1],sc[2],sc[3],math.floor(sc[4]*.75),line_weight)
                    end
                else
                    local sc=target.friend and friend or (mode==1 and esp_color(target,.5) or snap_color)
                    draw.line(start_x,start_y,end_x,end_y,
                        sc[1],sc[2],sc[3],math.floor(sc[4]*.75),line_weight)
                end
            end
            if story.esp_boxes() then
                local style=story.esp_box_style()
                local thick=story.esp_box_thickness()
                if style==1 then
                    local cw,ch=width*.25,(bottom-top)*.18
                    esp_line(left,top,left+cw,top,target,0,0,.85,thick)
                    esp_line(left,top,left,top+ch,target,0,.18,.85,thick)
                    esp_line(left+width,top,left+width-cw,top,target,0,0,.85,thick)
                    esp_line(left+width,top,left+width,top+ch,target,0,.18,.85,thick)
                    esp_line(left,bottom,left+cw,bottom,target,1,1,.85,thick)
                    esp_line(left,bottom,left,bottom-ch,target,1,.82,.85,thick)
                    esp_line(left+width,bottom,left+width-cw,bottom,target,1,1,.85,thick)
                    esp_line(left+width,bottom,left+width,bottom-ch,target,1,.82,.85,thick)
                elseif style==2 then
                    local upper,lower=esp_color(target,0),esp_color(target,1)
                    draw.rect_gradient(left,top,left+width,bottom,
                        upper[1],upper[2],upper[3],math.floor(upper[4]*.15),upper[1],upper[2],upper[3],math.floor(upper[4]*.15),
                        lower[1],lower[2],lower[3],math.floor(lower[4]*.15),lower[1],lower[2],lower[3],math.floor(lower[4]*.15))
                    esp_line(left,top,left+width,top,target,0,0,.85,thick)
                    esp_line(left,bottom,left+width,bottom,target,1,1,.85,thick)
                    esp_line(left,top,left,bottom,target,0,1,.85,thick)
                    esp_line(left+width,top,left+width,bottom,target,0,1,.85,thick)
                else
                    esp_line(left,top,left+width,top,target,0,0,.85,thick)
                    esp_line(left,bottom,left+width,bottom,target,1,1,.85,thick)
                    esp_line(left,top,left,bottom,target,0,1,.85,thick)
                    esp_line(left+width,top,left+width,bottom,target,0,1,.85,thick)
                end
            end
            if story.esp_head_dot() then draw.circle(target.head_x,target.head_y,2.75,color[1],color[2],color[3],230) end
            if story.esp_health() then
                local bar_x=left-5
                draw.rect(bar_x,top,bar_x+3,bottom,12,10,18,210,1)
                local filled=(bottom-top)*math.max(0,math.min(1,target.health))
                draw.rect(bar_x,bottom-filled,bar_x+3,bottom,
                    palette.green[1],palette.green[2],palette.green[3],240,1)
            end
            if story.esp_armor() and target.armor>0 then
                local bar_x=left+width+2
                draw.rect(bar_x,top,bar_x+3,bottom,12,10,18,210,1)
                local filled=(bottom-top)*math.max(0,math.min(1,target.armor))
                draw.rect(bar_x,bottom-filled,bar_x+3,bottom,80,160,255,235,1)
            end
            if story.esp_skeleton() and target.bones then
                local b=target.bones
                -- Direct CPed bone array: head, feet, ankles, hands, neck, abdomen.
                bone_line(b,1,8,color); bone_line(b,8,9,color)
                bone_line(b,9,6,color); bone_line(b,9,7,color)
                bone_line(b,9,4,color); bone_line(b,9,5,color)
                bone_line(b,4,2,color); bone_line(b,5,3,color)
            end
            if story.esp_distance_text() then
                local label=string.format("%.0fm",target.distance)
                text.draw_centered(font.tiny,left,bottom+3,left+width,
                    palette.dim[1],palette.dim[2],palette.dim[3],220,label)
            end
            if story.esp_names() and target.label then
                local prefix=target.friend and "[FRIEND] " or ""
                local name_color=target.friend and friend or palette.text
                text.draw_centered(font.tiny,left,top-13,left+width,
                    name_color[1],name_color[2],name_color[3],225,prefix..target.label)
            end
            if story.esp_weapon() and target.weapon_label and target.weapon_label~="" then
                text.draw_centered(font.tiny,left,bottom+14,left+width,
                    palette.faint[1],palette.faint[2],palette.faint[3],210,target.weapon_label)
            end
            if story.esp_vitals_text() then
                local vitals=string.format("HP %d  AR %d",math.floor(target.health*100),math.floor(target.armor*100))
                text.draw(font.tiny,left+width+7,top,
                    palette.dim[1],palette.dim[2],palette.dim[3],210,vitals)
            end
        end
      end
    end
    end
    if story.vehicle_esp() then
        for _,vehicle in ipairs(story.vehicles()) do
            local height=math.abs(vehicle.bottom_y-vehicle.top_y)
            if height>3 and height<ctx.screen_h()*1.5 then
                local width=height*1.35
                local left=vehicle.top_x-width*.5
                local top=math.min(vehicle.top_y,vehicle.bottom_y)
                local bottom=math.max(vehicle.top_y,vehicle.bottom_y)
                draw.rect_outline(left,top,left+width,bottom,
                    palette.accent[1],palette.accent[2],palette.accent[3],190,2,1.2,true)
                if story.vehicle_health() then
                    local filled=width*math.max(0,math.min(1,vehicle.health))
                    draw.rect(left,bottom+2,left+width,bottom+5,12,10,18,210,1)
                    draw.rect(left,bottom+2,left+filled,bottom+5,
                        palette.green[1],palette.green[2],palette.green[3],230,1)
                end
                if story.vehicle_names() then
                    text.draw_centered(font.tiny,left,top-13,left+width,
                        palette.accentHi[1],palette.accentHi[2],palette.accentHi[3],220,vehicle.label)
                end
            end
        end
    end
    if story.object_esp() then
        for _,object in ipairs(story.objects()) do
            draw.circle_outline(object.x,object.y,3,
                palette.accentHi[1],palette.accentHi[2],palette.accentHi[3],190,1)
            if story.object_names() then
                local label=object.label..string.format("  %.0fm",object.distance)
                text.draw(font.tiny,object.x+6,object.y-6,
                    palette.dim[1],palette.dim[2],palette.dim[3],205,label)
            end
        end
    end
    if story.diagnostics() then
        local vehicles=story.vehicle_esp() and story.vehicles() or {}
        local objects=story.object_esp() and story.objects() or {}
        local line=string.format("Peds %d  Vehicles %d  Objects %d  Friends %d  Redirects %d",
            #targets,#vehicles,#objects,story.friend_count(),story.redirect_count())
        draw.rect(18,ctx.screen_h()-48,560,ctx.screen_h()-16,
            palette.panel[1],palette.panel[2],palette.panel[3],225,6)
        text.draw(font.small,28,ctx.screen_h()-39,
            palette.text[1],palette.text[2],palette.text[3],225,line)
    end
end

local sidebar_nav_scroll=0
local sidebar_last_active=-1
local function sidebar_entries()
    if menu.build_tabs then menu.build_tabs() end
    local sections={{title="Combat",entries={}},{title="World",entries={}},{title="Visuals",entries={}},
        {title="FiveM",entries={}},{title="Misc",entries={}}}
    local categories={Home=1,Self=1,Player=1,Online=1,Combat=1,Weapon=1,Vehicle=1,
        Teleport=2,Domain=2,Visuals=3,["VFX's"]=3,UI=3,["Lua Executor"]=4,Events=4,Misc=5,Cloud=5,Settings=5}
    for index=0,(menu.tab_count and menu.tab_count() or 0)-1 do
        local name=menu.tab_name(index)
        if name~="Home" then
            local section=sections[categories[name] or 5]
            section.entries[#section.entries+1]={name=name,label=name=="Combat" and "Aimbot" or name,index=index}
        end
    end
    local entries,offset={},0
    for _,section in ipairs(sections) do
        if #section.entries>0 then
            if offset>0 then offset=offset+10 end
            if ui_options.sidebar_labels then entries[#entries+1]={title=section.title,y=offset}; offset=offset+26 end
            for _,entry in ipairs(section.entries) do
                entry.y=offset; entry.section=section.title
                entries[#entries+1]=entry; offset=offset+38
            end
        end
    end
    return entries,offset
end
-- 0 when the sidebar is at its full width, 1 when collapsed to icons.
local function sidebar_compactness(sidebar)
    local span=math.max(1,halo.sidebar_full-halo.sidebar_compact)
    return math.max(0,math.min(1,(halo.sidebar_full-sidebar)/span))
end
local function set_sidebar_collapsed(collapsed)
    local handle=items.get("UI Layout","Collapse Sidebar")
    local item=handle and items.at(handle)
    if item and item.on~=collapsed then items.toggle(handle) end
end
local function sidebar_toggle_rect(ox,oy,sidebar)
    if sidebar_compactness(sidebar)>.5 then return ox+(sidebar-36)*.5,oy+11,36,36 end
    return ox+sidebar-40,oy+15,28,28
end
local function sidebar_glyph(x,y,color)
    if halo.glyph("Sidebar",x,y,color) then return end
    outline(x-7,y-6,14,12,color,3,1.4)
    line(x-2.5,y-6,x-2.5,y+6,color,1.4)
end
local function render_sidebar(ox,oy,sidebar,height,radius)
    local t=sidebar_compactness(sidebar)
    local label_a=math.max(0,1-t*1.6)
    local function faded(color) return {color[1],color[2],color[3],math.floor(color[4]*label_a)} end
    draw.push_clip(ox,oy,ox+sidebar,oy+height)
    local bx,by,bw,bh=sidebar_toggle_rect(ox,oy,sidebar)
    local toggle_hot=inside(bx,by,bw,bh)
    if t>.5 then
        if toggle_hot then fill(bx,by,bw,bh,{palette.text[1],palette.text[2],palette.text[3],12},9) end
        if toggle_hot then sidebar_glyph(bx+bw*.5,by+bh*.5,palette.text)
        else
            local mark_w=text.width(logo_font,"N")
            txt(logo_font,bx+(bw-mark_w)*.5,by+(bh-text.height(logo_font))*.5,palette.logoNen,"N")
        end
    else
        local logo_x,logo_y=ox+22,oy+(58-text.height(logo_font))*.5
        txt(logo_font,logo_x,logo_y,faded(palette.logoNen),"Nen")
        txt(logo_font,logo_x+text.width(logo_font,"Nen"),logo_y,faded(palette.logoYoo),"yoo")
        if toggle_hot then fill(bx,by,bw,bh,{palette.text[1],palette.text[2],palette.text[3],12},8) end
        sidebar_glyph(bx+bw*.5,by+bh*.5,toggle_hot and palette.text or palette.dim)
    end
    if toggle_hot then
        halo.tooltip={x=bx+bw,y=by+bh*.5,text=ui_options.sidebar_collapsed and "Expand sidebar" or "Collapse sidebar"}
        if input.mouse_clicked(0) then
            set_sidebar_collapsed(not ui_options.sidebar_collapsed)
            input.consume_mouse_click()
        end
    end
    local entries,total=sidebar_entries()
    local active=menu.tab_active and menu.tab_active() or 0
    local row_h=38
    local nav_top,nav_bottom=oy+108,oy+height-16
    local nav_h=nav_bottom-nav_top
    local maximum=math.max(0,total-nav_h)
    local selected=nil
    for _,entry in ipairs(entries) do if entry.index==active then selected=entry end end
    halo.page_title=selected and selected.label or ""
    halo.page_section=selected and selected.section or ""
    if active~=sidebar_last_active and selected then
        if selected.y<sidebar_nav_scroll then sidebar_nav_scroll=selected.y end
        if selected.y+row_h>sidebar_nav_scroll+nav_h then sidebar_nav_scroll=selected.y+row_h-nav_h end
        sidebar_last_active=active
    end
    if inside(ox,nav_top,sidebar,nav_h) then sidebar_nav_scroll=sidebar_nav_scroll-input.mouse_wheel()*row_h*ui_options.scroll_speed/70 end
    sidebar_nav_scroll=math.max(0,math.min(maximum,sidebar_nav_scroll))
    draw.push_clip(ox,nav_top,ox+sidebar,nav_bottom)
    if selected then
        local target=selected.y-sidebar_nav_scroll
        local sy=nav_top+motion_to("sidebar_active_y",target,20,target)
        fill(ox+10,sy,sidebar-20,row_h,{palette.accent[1],palette.accent[2],palette.accent[3],36},9)
    end
    local show_icons=ui_options.sidebar_icons or t>0
    local tile_x=ox+16+5*t
    for _,entry in ipairs(entries) do
        local y=nav_top+entry.y-sidebar_nav_scroll
        if entry.title then
            if label_a>0 then
                txt(font.small,ox+22,y+(26-text.height(font.small))*.5+3,faded(palette.faint),string.upper(i18n.tr(entry.title)))
            end
            if t>0 then
                local c=palette.border
                line(tile_x+3,y+15,tile_x+23,y+15,{c[1],c[2],c[3],math.floor(c[4]*t)},1)
            end
        else
            local active_row=entry.index==active
            local hovered=inside(ox+10,y,sidebar-20,row_h) and inside(ox,nav_top,sidebar,nav_h)
            if hovered and not active_row then fill(ox+10,y,sidebar-20,row_h,{palette.text[1],palette.text[2],palette.text[3],9},9) end
            local tint=(active_row or hovered) and palette.text or palette.dim
            local label_x=ox+22
            if show_icons then
                local tile_y=y+(row_h-26)*.5
                fill(tile_x,tile_y,26,26,active_row and palette.accent or {palette.text[1],palette.text[2],palette.text[3],10},7)
                nav_icon(entry.name,tile_x+13,tile_y+13,active_row and {22,18,34,255} or tint)
                label_x=tile_x+37
            end
            if label_a>0 then
                txt_ellipsis(font.item,label_x,y+(row_h-text.height(font.item))*.5,faded(tint),entry.label,math.max(0,ox+sidebar-14-label_x))
            end
            if hovered and t>.5 then halo.tooltip={x=ox+sidebar-6,y=y+row_h*.5,text=entry.label} end
            if hovered and input.mouse_clicked(0) and not active_row then request_navigation("tab",entry.index) end
        end
    end
    draw.pop_clip()
    if maximum>0 then
        local thumb=math.max(24,nav_h*nav_h/total)
        fill(ox+sidebar-4,nav_top+(nav_h-thumb)*sidebar_nav_scroll/maximum,2,thumb,palette.dim,1,100)
    end
    draw.pop_clip()
end
-- Sidebar labels for the collapsed rail; drawn last so they float above the page.
local function draw_sidebar_tooltip()
    local tip=halo.tooltip
    halo.tooltip=nil
    if not tip then return end
    local w=text.width(font.small,tip.text)+18
    local h=text.height(font.small)+12
    local x,y=tip.x+8,tip.y-h*.5
    fill(x,y+2,w,h,{0,0,0,90},7)
    fill(x,y,w,h,palette.side,7)
    outline(x,y,w,h,palette.border,7)
    txt(font.small,x+9,y+6,palette.text,tip.text)
end
local header_scroll,header_last={},{ }
local function header_tabs()
    local page_id,page_name=menu.page_id(),menu.page_name()
    -- Home is the opening welcome screen, without a navigation tab.
    if page_id==items.joaat("Home") then return {} end
    local tabs={}
    if settings_section_for(page_id) then
        for _,name in ipairs(settings_tab_names) do
            tabs[#tabs+1]={name=name,kind="settings",target=name,active=settings_tab==name}
        end
        return tabs
    end
    if page_name=="Combat" or page_name=="Lock-on Aimbot" or page_name=="Silent Aim" or page_name=="Magic Bullet" then
        if page_name=="Lock-on Aimbot" then combat_tab=1 elseif page_name=="Silent Aim" then combat_tab=2 elseif page_name=="Magic Bullet" then combat_tab=3 end
        for _,tab in ipairs(combat_tabs_list()) do
            tabs[#tabs+1]={name=tab.name,kind="combat",target=tab.index,active=combat_tab==tab.index}
        end
        return tabs
    end
    if page_name=="Events" then
        for _,name in ipairs(fv.events_tab_names) do
            tabs[#tabs+1]={name=name,kind="events",target=name,active=fv.events_tab==name}
        end
        return tabs
    end
    local visual_root,selected=visual_section_for(page_id,page_name)
    if visual_root then
        if selected then visual_tabs[visual_root]=selected end
        for _,tab in ipairs(visuals_tabs_list(visual_root)) do
            tabs[#tabs+1]={name=tab.name,kind=visual_root=="VFX's" and "vfx" or "visuals",
                target=tab.name,active=visual_tabs[visual_root]==tab.name}
        end
        return tabs
    end
    local active=menu.tab_active and menu.tab_active() or 0
    local root_name=menu.tab_name(active)
    local root_id=items.joaat(root_name)
    tabs[1]={name=page_name=="Home" and "Main" or root_name,kind="page",target=root_id,active=page_id==root_id}
    if root_name~="Settings" then
        for _,handle in ipairs(items.page_items(root_id)) do
            local item=items.at(handle)
            if item and item.type==item_type.sub_menu then
                local child=items.submenu_page_id(handle)
                if child and child~=0 then tabs[#tabs+1]={name=item.name,kind="page",target=child,active=page_id==child} end
            end
        end
    end
    return tabs
end
local function header_layout(ox,oy,width,sidebar)
    local tabs=header_tabs()
    local key=tostring(menu.tab_active and menu.tab_active() or 0)
    local title=halo.page_title~="" and halo.page_title or menu.page_name()
    local account_x=halo.account_rect(ox,oy,width)
    local title_w=math.max(40,math.min(text.width(font.title,title),account_x-ox-sidebar-48))
    -- Tab row under the title: labels line up with the title, 12px hit padding each side.
    local h=36
    local y=oy+halo.header-h
    local x,w=ox+sidebar+12,width-sidebar-24
    local offset,selected=0,nil
    for _,tab in ipairs(tabs) do
        tab.label=tab.name
        tab.tw=text.width(font.breadcrumb,tab.label)
        tab.x=offset; tab.w=tab.tw+24
        if tab.active then selected=tab end
        offset=offset+tab.w
    end
    local overflowing=offset>w
    local arrow=overflowing and 16 or 0
    local vx,vw=x+arrow,w-arrow*2
    local maximum=math.max(0,offset-vw)
    local current=math.max(0,math.min(maximum,header_scroll[key] or 0))
    if selected and header_last[key]~=selected.name then
        if selected.x<current then current=selected.x end
        if selected.x+selected.w>current+vw then current=selected.x+selected.w-vw end
    end
    return tabs,key,x,y,w,h,vx,vw,current,maximum,overflowing,selected,title,title_w
end
local function header_tools_hit(ox,oy,width,sidebar)
    local qx,qy,qw,qh=halo.account_rect(ox,oy,width)
    if inside(qx,qy,qw,qh) then return true end
    local tx,ty,tw,th=sidebar_toggle_rect(ox,oy,sidebar)
    if inside(tx,ty,tw,th) then return true end
    return inside(ox+10,oy+60,sidebar-20,34)
end
local function header_can_drag(ox,oy,width,sidebar)
    if not inside(ox,oy,width,halo.header) or header_tools_hit(ox,oy,width,sidebar) then return false end
    local tabs,_,x,y,w,h,vx,vw,current,_,overflowing=header_layout(ox,oy,width,sidebar)
    if overflowing and (inside(x,y,18,h) or inside(x+w-18,y,18,h)) then return false end
    if inside(vx,y,vw,h) then
        for _,tab in ipairs(tabs) do
            if inside(vx+tab.x-current,y,tab.w,h) then return false end
        end
    end
    return true
end
local preview_position,preview_drag,preview_viewport=nil,nil,nil
local preview_offsets=nil
local function preview_menu_origin(sidebar,width,height)
    local scale=ctx.ui_scale()
    local viewport_w,viewport_h=ctx.screen_w()/scale,ctx.screen_h()/scale
    local left,top,bottom=16/scale,40/scale,16/scale
    local right=math.max(left,viewport_w-width-left)
    local lower=math.max(top,viewport_h-height-bottom)
    local function clamp(value,low,high) return math.max(low,math.min(high,value)) end
    local function offset(name)
        local handle=items.get("Settings",name)
        local item=handle and items.at(handle)
        return item and item.f_val or 0
    end
    local offsets={x=offset("Menu Offset X"),y=offset("Menu Offset Y")}
    if preview_recenter then
        preview_position,preview_drag,preview_offsets=nil,nil,nil
        preview_recenter=false
    end
    if not preview_position then
        preview_position={x=(viewport_w-width)*.5+offsets.x,y=(viewport_h-height)*.5+offsets.y}
    elseif preview_viewport and (viewport_w~=preview_viewport.w or viewport_h~=preview_viewport.h) then
        -- Preserve the menu's relative centre when its scale or workspace changes.
        preview_position.x=(preview_position.x+width*.5)*viewport_w/preview_viewport.w-width*.5
        preview_position.y=(preview_position.y+height*.5)*viewport_h/preview_viewport.h-height*.5
        preview_drag=nil
    end
    if preview_offsets then
        if offsets.x~=preview_offsets.x then preview_position.x=(viewport_w-width)*.5+offsets.x end
        if offsets.y~=preview_offsets.y then preview_position.y=(viewport_h-height)*.5+offsets.y end
    end
    preview_offsets=offsets
    preview_viewport={w=viewport_w,h=viewport_h}
    preview_position.x=clamp(preview_position.x,left,right)
    preview_position.y=clamp(preview_position.y,top,lower)
    if input.mouse_clicked(0) and header_can_drag(preview_position.x,preview_position.y,width,sidebar) then
        preview_drag={x=input.mouse_x()-preview_position.x,y=input.mouse_y()-preview_position.y}
        input.consume_mouse_click()
    end
    if preview_drag then
        if input.mouse_down(0) then
            preview_position.x=clamp(input.mouse_x()-preview_drag.x,left,right)
            preview_position.y=clamp(input.mouse_y()-preview_drag.y,top,lower)
        else preview_drag=nil end
    end
    -- Keep the existing menu bounds in sync without altering game offsets.
    menu.drag_header(preview_position.x,preview_position.y,width,halo.header,false)
    return preview_position.x,preview_position.y
end
local function menu_display_scale()
    return ctx.ui_scale()/(ctx.ui_dpi_scale and ctx.ui_dpi_scale() or 1)
end
local function close_quick_settings()
    quick_open=false; quick_section=nil
    if quick_color then close_color_popup(); quick_color=false end
end
local function quick_rects()
    if not quick_anchor then return end
    local vw,vh=ctx.screen_w()/ctx.ui_scale(),ctx.screen_h()/ctx.ui_scale()
    local w,h=280,364
    local x=math.max(8,math.min(vw-w-8,quick_anchor.x+quick_anchor.w-w))
    local y=math.max(8,math.min(vh-h-8,quick_anchor.y+quick_anchor.h+9))
    local sub_w=232
    local sub_h=quick_section=="language" and math.min(10,i18n.count())*30+38 or 256
    sub_h=math.min(sub_h,vh-16)
    local sub_x=x+w+6
    if sub_x+sub_w>vw-8 then sub_x=x-sub_w-6 end
    sub_x=math.max(8,math.min(vw-sub_w-8,sub_x))
    local offset=quick_section=="language" and 78 or (quick_section=="menu_scale" and 114 or 150)
    local sub_y=math.max(8,math.min(vh-sub_h-8,y+offset))
    return x,y,w,h,sub_x,sub_y,sub_w,sub_h
end
local function quick_input()
    if not quick_open then return false end
    if color_open then return true end
    if input.key_just_pressed(VK.ESCAPE) then
        if quick_section then quick_section=nil else close_quick_settings() end
        return true
    end
    local x,y,w,h,sx,sy,sw,sh=quick_rects()
    if not x then close_quick_settings(); return true end
    if input.mouse_clicked(0) then
        if inside(quick_anchor.x,quick_anchor.y,quick_anchor.w,quick_anchor.h) then
            close_quick_settings(); input.consume_mouse_click()
        elseif not inside(x,y,w,h) and not (quick_section and inside(sx,sy,sw,sh)) then
            close_quick_settings(); input.consume_mouse_click()
        end
    end
    return true
end
-- Header account chip: avatar, name, and the settings gear. Opens quick settings.
function halo.account_rect(ox,oy,width)
    local username=ui.username and ui.username() or ""
    if username=="" then username="Nenyoo" end
    local w=36+math.min(140,text.width(font.item,username))+42
    return ox+width-18-w,oy+22,w,34,username
end
local function quick_icon(ox,oy,width)
    local x,y,w,h,username=halo.account_rect(ox,oy,width)
    quick_anchor={x=x,y=y,w=w,h=h}
    local hot=inside(x,y,w,h)
    fill(x,y,w,h,{palette.text[1],palette.text[2],palette.text[3],(hot or quick_open) and 14 or 7},10)
    outline(x,y,w,h,quick_open and {palette.accent[1],palette.accent[2],palette.accent[3],130} or palette.border,10)
    local ax,ay=x+18,y+h*.5
    draw.circle(ax,ay,12,rgba(palette.accentLo))
    local initial=string.upper(username:sub(1,1))
    txt(font.small,ax-text.width(font.small,initial)*.5,ay-text.height(font.small)*.5,{255,255,255,255},initial)
    txt_ellipsis(font.item,x+36,y+(h-text.height(font.item))*.5,palette.text,username,140)
    line(x+w-36,y+9,x+w-36,y+h-9,palette.border,1)
    nav_icon("Settings",x+w-18,ay,quick_open and palette.accentHi or (hot and palette.text or palette.dim))
    if clicked(x,y,w,h) then
        quick_open=not quick_open; quick_section=nil
        if quick_open then
            search_expanded,search_focus=false,false; search,search_popup_query="",""
            search_popup_bounds=nil; option_open,option_anchor=nil,nil
            close_color_popup(); quick_color=false
        end
        input.consume_mouse_click()
    end
end
local function quick_glyph(kind,x,y,color)
    local names={settings="Settings",welcome="Home",menu_scale="display",overlay_scale="display"}
    if kind~="style" and halo.glyph(names[kind] or kind,x,y,color) then return end
    if kind=="language" then
        draw.circle_outline(x,y,6,color[1],color[2],color[3],color[4],1)
        line(x-6,y,x+6,y,color,1); line(x,y-6,x,y+6,color,1)
        line(x-4,y-4,x+4,y-4,color,1); line(x-4,y+4,x+4,y+4,color,1)
    elseif kind=="style" then
        fill(x-6,y-6,12,12,palette.accent,3)
    elseif kind=="animations" then
        line(x-4,y-6,x+4,y,color,1.3); line(x+4,y,x-4,y+6,color,1.3)
    elseif kind=="settings" then nav_icon("Settings",x,y,color)
    elseif kind=="welcome" then nav_icon("Home",x,y,color)
    else
        outline(x-6,y-5,12,10,color,1,1)
        line(x-3,y+8,x+3,y+8,color,1)
    end
end
local function draw_quick_settings(radius)
    if not quick_open then return end
    local x,y,w,h,sx,sy,sw,sh=quick_rects()
    if not x then return end
    local popup_bg={19,22,26,255}
    fill(x+2,y+5,w,h,{0,0,0,90},12)
    fill(x,y,w,h,popup_bg,12)
    outline(x,y,w,h,{255,255,255,14},12)
    local username=ui.username()
    fill(x+16,y+16,38,38,palette.side,19)
    txt(font.item,x+30,y+28,palette.accentHi,string.upper(username:sub(1,1)))
    txt_ellipsis(font.item,x+66,y+19,palette.text,username,w-82)
    txt(font.small,x+66,y+39,palette.dim,"Nenyoo")
    line(x+12,y+66,x+w-12,y+66,palette.border,1)
    local language="English"
    for index=1,i18n.count() do if i18n.code(index)==i18n.active() then language=i18n.label(index); break end end
    local auto=items.get("Settings","Auto UI Scale")
    local menu_scale=items.get("Settings","UI Scale")
    local overlay_scale=items.get("Settings","Overlays/Panels Scale")
    local function scale_text(handle)
        local item=handle and items.at(handle)
        if item and handle==menu_scale and ui.preview_canvas and menu_display_scale()+.005<item.f_val then
            return string.format("Fit: %.0f%%",menu_display_scale()*100)
        end
        return item and string.format("%.0f%%",item.f_val*100) or "Unavailable"
    end
    local auto_item=auto and items.at(auto)
    local rows={
        {id="language",label="Language",value=language},
        {id="menu_scale",label="Menu Scale",value=auto_item and auto_item.on and "Auto" or scale_text(menu_scale)},
        {id="overlay_scale",label="Overlay Scale",value=scale_text(overlay_scale)},
        {id="style",label="Style",value="Accent"},
        {id="animations",label="Animations",value=motion_enabled and "On" or "Off"},
        {id="settings",label="All Settings",value=""},
        {id="welcome",label="Welcome",value=""}
    }
    for index,entry in ipairs(rows) do
        local ry=y+78+(index-1)*38
        local hot=inside(x+8,ry,w-16,34)
        if hot or quick_section==entry.id then fill(x+8,ry,w-16,34,palette.side,6) end
        quick_glyph(entry.id,x+26,ry+17,palette.dim)
        txt_ellipsis(font.item,x+46,ry+(34-text.height(font.item))*.5,palette.text,entry.label,112)
        if entry.id=="style" then
            local handle=items.get("Nenyoo Appearance","Accent")
            fill(x+w-40,ry+8,18,18,palette.accent,4)
            color_swatch(handle,x+w-40,ry+8,18,18)
            if color_open==handle then quick_color=true; quick_section=nil end
        else
            local value_w=math.min(90,text.width(font.value,entry.value))
            txt_ellipsis(font.value,x+w-32-value_w,ry+(34-text.height(font.value))*.5,palette.dim,entry.value,90)
            line(x+w-21,ry+13,x+w-17,ry+17,palette.dim,1.2)
            line(x+w-17,ry+17,x+w-21,ry+21,palette.dim,1.2)
        end
        if hot and input.mouse_clicked(0) then
            if entry.id=="animations" then
                local handle=items.get("Motion","Animations Enabled"); if handle then items.toggle(handle) end
                quick_section=nil
            elseif entry.id=="settings" or entry.id=="welcome" then
                close_quick_settings()
                local destination=entry.id=="welcome" and "Home" or "Settings"
                for tab=0,(menu.tab_count and menu.tab_count() or 0)-1 do
                    if menu.tab_name(tab)==destination then request_navigation("tab",tab); break end
                end
            elseif entry.id=="style" then
                local handle=items.get("Nenyoo Appearance","Accent")
                if handle and not color_open then
                    color_open=handle; color_anchor={x=x+w-40,y=ry+8,w=18,h=18}; color_seen=true; quick_color=true
                end
                quick_section=nil
            else
                quick_section=quick_section==entry.id and nil or entry.id
                quick_scroll=0
                if quick_section=="language" then
                    for i=1,i18n.count() do if i18n.code(i)==i18n.active() then quick_scroll=math.max(0,i-5); break end end
                end
            end
            input.consume_mouse_click()
        end
    end
    if not quick_section then return end
    -- Recompute after opening a different flyout this frame.
    x,y,w,h,sx,sy,sw,sh=quick_rects()
    local entries={}
    if quick_section=="language" then
        for i=1,i18n.count() do entries[#entries+1]={label=i18n.label(i),code=i18n.code(i),selected=i18n.code(i)==i18n.active()} end
    else
        local handle=quick_section=="menu_scale" and menu_scale or overlay_scale
        local item=handle and items.at(handle)
        if quick_section=="menu_scale" and auto_item then entries[#entries+1]={label="Auto",auto=true,selected=auto_item.on} end
        if item then
            for _,value in ipairs({.5,.75,1,1.25,1.5,1.75,2}) do
                if value>=item.f_min and value<=item.f_max then
                    entries[#entries+1]={label=string.format("%.0f%%",value*100),value=value,handle=handle,
                        selected=math.abs(item.f_val-value)<.001 and not (quick_section=="menu_scale" and auto_item and auto_item.on)}
                end
            end
        end
    end
    local visible=math.max(1,math.floor((sh-38)/30))
    local maximum=math.max(0,#entries-visible)
    if inside(sx,sy,sw,sh) then quick_scroll=quick_scroll-input.mouse_wheel()*2 end
    quick_scroll=math.floor(math.max(0,math.min(maximum,quick_scroll)))
    fill(sx+2,sy+4,sw,sh,{0,0,0,85},10); fill(sx,sy,sw,sh,popup_bg,10)
    outline(sx,sy,sw,sh,{255,255,255,14},10)
    txt(font.small,sx+14,sy+12,palette.dim,quick_section=="language" and "Language" or (quick_section=="menu_scale" and "Menu Scale" or "Overlay Scale"))
    for i=quick_scroll+1,math.min(#entries,quick_scroll+visible) do
        local entry=entries[i]; local ry=sy+30+(i-quick_scroll-1)*30
        if inside(sx+6,ry,sw-12,28) or entry.selected then fill(sx+6,ry,sw-12,28,palette.side,5) end
        local label_x=sx+14
        if entry.code then flag(entry.code,sx+14,ry+7,21,14); label_x=sx+44 end
        txt_ellipsis(font.item,label_x,ry+(28-text.height(font.item))*.5,entry.selected and palette.accentHi or palette.text,entry.label,sw-(label_x-sx)-32)
        if entry.selected then
            line(sx+sw-23,ry+14,sx+sw-20,ry+17,palette.accentHi,1.2)
            line(sx+sw-20,ry+17,sx+sw-14,ry+10,palette.accentHi,1.2)
        end
        if clicked(sx+6,ry,sw-12,28) then
            if entry.code then i18n.set_active(entry.code)
            elseif entry.auto then if auto_item and not auto_item.on then items.toggle(auto) end
            else
                if quick_section=="menu_scale" and auto_item and auto_item.on then items.toggle(auto) end
                items.set_f_val(entry.handle,entry.value)
            end
            local resizing=quick_section=="menu_scale"
            quick_section=nil
            if resizing then close_quick_settings() end
            input.consume_mouse_click(); break
        end
    end
    if maximum>0 then
        local track=sh-42; local thumb=math.max(16,track*visible/#entries)
        fill(sx+sw-4,sy+34+(track-thumb)*quick_scroll/maximum,2,thumb,palette.dim,1,130)
    end
end

local function draw_topbar(ox,oy,width,sidebar,radius)
    local tabs,key,x,y,w,h,vx,vw,current,maximum,overflowing,selected,title,title_w=header_layout(ox,oy,width,sidebar)
    if selected then header_last[key]=selected.name end
    local tools_hovered=header_tools_hit(ox,oy,width,sidebar)
    local tx=ox+sidebar+24
    if halo.page_section~="" then txt(font.small,tx,oy+17,palette.dim,halo.page_section) end
    txt_ellipsis(font.title,tx,oy+33,palette.text,title,title_w+4)
    if #tabs>0 then
        if not tools_hovered and inside(vx,y,vw,h) then current=math.max(0,math.min(maximum,current-input.mouse_wheel()*75*ui_options.scroll_speed/70)) end
        line(ox+sidebar,y+h-.5,ox+width,y+h-.5,palette.border,1)
        if overflowing then
            txt(font.small,x+6,y+(h-text.height(font.small))*.5,palette.dim,"<")
            txt(font.small,x+w-13,y+(h-text.height(font.small))*.5,palette.dim,">")
            if not tools_hovered and clicked(x,y,19,h) then current=math.max(0,current-vw*.65) end
            if not tools_hovered and clicked(x+w-19,y,19,h) then current=math.min(maximum,current+vw*.65) end
        end
        header_scroll[key]=current
        draw.push_clip(vx,y,vx+vw,y+h)
        if selected then
            local px=vx+12+motion_to("tab_line_x_"..key,selected.x-current,20,selected.x-current)
            local pw=motion_to("tab_line_w_"..key,selected.tw,20,selected.tw)
            fill(px,y+h-2,pw,2,palette.accent,1)
        end
        for _,tab in ipairs(tabs) do
            local bx=vx+tab.x-current
            local hovered=not tools_hovered and inside(bx,y,tab.w,h) and inside(vx,y,vw,h)
            txt(font.breadcrumb,bx+12,y+(h-2-text.height(font.breadcrumb))*.5,
                (tab.active or hovered) and palette.text or palette.dim,tab.label)
            if hovered and input.mouse_clicked(0) and not tab.active then request_navigation(tab.kind,tab.target) end
        end
        draw.pop_clip()
    end
    -- Drawn after the page so its result list floats above the cards.
    if sidebar_compactness(sidebar)<.5 then
        search_box(ox+12,oy+60,sidebar-24,34,9,true)
    else
        local sx,sy,sw,sh=ox+10,oy+60,sidebar-20,34
        local hot=inside(sx,sy,sw,sh)
        fill(sx,sy,sw,sh,{palette.text[1],palette.text[2],palette.text[3],hot and 16 or 8},9)
        outline(sx,sy,sw,sh,palette.border,9)
        local icon=hot and palette.text or palette.dim
        local cx,cy=sx+sw*.5-1,sy+sh*.5-1
        if not halo.glyph("Search",sx+sw*.5,sy+sh*.5,icon) then
            draw.circle_outline(cx,cy,4.5,icon[1],icon[2],icon[3],icon[4],1.5)
            line(cx+3.5,cy+3.5,cx+7,cy+7,icon,1.5)
        end
        if hot then
            halo.tooltip={x=ox+sidebar-6,y=sy+sh*.5,text="Search features..."}
            if input.mouse_clicked(0) then
                set_sidebar_collapsed(false)
                search_focus=true
                input.consume_mouse_click()
            end
        end
    end
    quick_icon(ox,oy,width)
    draw_sidebar_tooltip()
end
local function draw_menu_body(sidebar,radius)
    content_alpha,content_offset,content_progress=update_transition()
    if menu.page_id()==items.joaat("Home") or menu.page_name()=="" then
        draw_welcome_surface(radius)
        return
    end
    welcome_resize=nil
    local active_tab=menu.tab_active and menu.tab_active()
    if active_tab and menu.tab_name(active_tab)~="Home" then welcome_return_tab=active_tab end
    local width,height=ui.win_w,ui.win_h
    local ox,oy
    if ui.preview_canvas then
        local scale=ctx.ui_scale()
        fill(0,0,ctx.screen_w()/scale,ctx.screen_h()/scale,{51,65,85,255},0)
        local hint="Drag empty space in the top bar to move the menu"
        local scale_handle=items.get("Settings","UI Scale")
        local scale_item=scale_handle and items.at(scale_handle)
        local auto_handle=items.get("Settings","Auto UI Scale")
        local auto_item=auto_handle and items.at(auto_handle)
        if auto_item and not auto_item.on and scale_item and menu_display_scale()+.005<scale_item.f_val then
            hint=string.format("Menu fitted to %.0f%% (%.0f%% selected). Enlarge the preview for more space.",menu_display_scale()*100,scale_item.f_val*100)
        end
        txt_ellipsis(font.small,16/scale,14/scale,palette.faint,hint,(ctx.screen_w()-32)/scale)
        ox,oy=preview_menu_origin(sidebar,width,height)
    else
        local base_x,base_y=0,0
        if not ui.windowed then
            base_x=math.max(20,(ctx.screen_w()/ctx.ui_scale()-width)*.5)
            base_y=math.max(20,(ctx.screen_h()/ctx.ui_scale()-height)*.5)
        end
        local current_x,current_y=base_x,base_y
        if menu.drag_origin then current_x,current_y=menu.drag_origin(base_x,base_y,not ui.windowed) end
        local allow_drag=header_can_drag(current_x,current_y,width,sidebar)
        local off_x,off_y=menu.drag_header(base_x,base_y,width,halo.header,not ui.windowed,allow_drag)
        ox,oy=base_x+off_x,base_y+off_y
    end
    draw_window_surfaces(ox,oy,width,height,sidebar,radius+4)
    render_sidebar(ox,oy,sidebar,height,radius)
    draw.push_motion(content_offset,0,content_alpha)
    draw_page(ox+sidebar,oy+halo.header,width-sidebar,height-halo.header,radius)
    draw.pop_motion()
    draw_topbar(ox,oy,width,sidebar,radius)
    menu.set_content_rect(ox+sidebar,oy+halo.header,width-sidebar,height-halo.header)
end
function draw_menu()
    if ui.preview_canvas and ui.preview_export_tab then
        local requested=ui.preview_export_tab
        if menu.page_id()==items.joaat("Settings") then
            for _,name in ipairs(settings_tab_names) do if name==requested then settings_tab=name end end
        elseif menu.page_id()==items.joaat("Events") then
            for _,name in ipairs(fv.events_tab_names) do if name==requested then fv.events_tab=name end end
        end
    end
    local color_blocks_pointer=color_popup_input()
    local quick_blocks_pointer=quick_input()
    local welcome_blocks_pointer=welcome_popup_input()
    search_popup_click=false
    if not color_blocks_pointer and not quick_blocks_pointer and not welcome_blocks_pointer then
        if search_focus and search_popup_bounds and input.mouse_clicked(0) and
            inside(search_popup_bounds.x,search_popup_bounds.y,
                search_popup_bounds.w,search_popup_bounds.h) then
            search_popup_click=true
            input.consume_mouse_click()
        end
        option_popup_input()
    end
    if search_target and ctx.time()>=search_target.expires then search_target=nil end
    option_seen=false
    color_seen=false
    aim_keybind_seen=false
    local sidebar,radius=sync_settings()
    halo.sidebar_full=sidebar
    sidebar=motion_to("sidebar_width",ui_options.sidebar_collapsed and halo.sidebar_compact or sidebar,18)
    if color_blocks_pointer or quick_blocks_pointer or welcome_blocks_pointer then
        input.with_pointer_blocked(function() draw_menu_body(sidebar,radius) end)
    else
        draw_menu_body(sidebar,radius)
    end
    if color_blocks_pointer then input.with_pointer_blocked(function() draw_quick_settings(radius) end)
    else draw_quick_settings(radius) end
    if not aim_keybind_seen then ui.cancel_menu_keybind(aim_keybind_id) end
    if option_open and not option_seen then option_open,option_anchor=nil,nil end
    if color_open and not color_seen then close_color_popup() end
    draw_option_popup(radius)
    draw_color_popup(radius)
    draw_welcome_dropdown()
end

-- Matches the GTAV Nenyoo cursor: a precise dot, eased accent ring, soft glow,
-- and a short click ripple. Coordinates are physical pixels; the renderer may
-- scale the UI canvas, so divide only at the draw boundary.
local cursor_x,cursor_y=-1,-1
local cursor_press=0
local cursor_pulse=-1
local function cursor_ease(speed,dt)
    return dt<=0 and 1 or 1-math.exp(-speed*dt)
end
__overlay_draws=__overlay_draws or {}
__overlay_draws.cursor=function()
    if ui.windowed or not ui.menu_open() then
        cursor_x,cursor_y=-1,-1
        return
    end
    local mx,my=input.mouse_x(),input.mouse_y()
    local dt,t=ctx.delta(),ctx.time()
    local scale=math.max(.01,ctx.ui_scale())
    local ar,ag,ab=theme.accent()
    if cursor_x<0 then cursor_x,cursor_y=mx,my end
    local k=cursor_ease(26,dt)
    cursor_x=cursor_x+(mx-cursor_x)*k
    cursor_y=cursor_y+(my-cursor_y)*k
    cursor_press=cursor_press+((input.mouse_down(0) and 1 or 0)-cursor_press)*cursor_ease(30,dt)
    if input.mouse_clicked(0) then cursor_pulse=t end
    local breathe=.5+.5*math.sin(t*2.2)
    local radius=10-cursor_press*3+breathe*.8
    local x,y=cursor_x*scale,cursor_y*scale
    local px,py=mx*scale,my*scale
    draw.circle(x,y,radius+7,ar,ag,ab,18)
    draw.circle(x,y,radius+3.5,ar,ag,ab,30)
    draw.circle_outline(x,y,radius,0,0,0,90,3)
    draw.circle_outline(x,y,radius,ar,ag,ab,math.floor(210+30*breathe),1.7)
    local dot=2+cursor_press*1.6
    draw.circle(px,py,dot+1.2,0,0,0,120)
    draw.circle(px,py,dot,255,255,255,255)
    if cursor_pulse>=0 then
        local e=(t-cursor_pulse)/.4
        if e<1 then
            draw.circle_outline(x,y,radius+e*18,ar,ag,ab,
                math.floor(190*(1-e)),1.6)
        else cursor_pulse=-1 end
    end
end
