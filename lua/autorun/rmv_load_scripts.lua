local function sendClientScripts()
    AddCSLuaFile("client/rmv_cl_cvars.lua")
    AddCSLuaFile("autorun/rmv_load_scripts.lua")
    AddCSLuaFile("shared/rmv_network_strings.lua")
    AddCSLuaFile("client/vgui/rmv_fonts.lua")
    AddCSLuaFile("client/rmv_cl_rafsmapvote.lua")
    AddCSLuaFile("client/vgui/rmv_mapvote_panel.lua")
    AddCSLuaFile("client/vgui/rmv_mapvote_list.lua")
    AddCSLuaFile("client/rmv_chat_routines.lua")
end

local function loadServerScripts()
    include("shared/rmv_network_strings.lua")
    include("server/utils/rmv_logging.lua")
    include("server/config/rmv_config.lua")
    include("server/config/rmv_map_info.lua")
    include("server/voting/rmv_tally.lua")
    include("server/voting/rmv_candidates.lua")
    include("server/voting/rmv_rtv.lua")
    include("server/rmv_init.lua")
    include("server/rmv_sv_rafsmapvote.lua")
    include("server/integration/rmv_ttt.lua")
end

local function loadClientScripts()
    include("client/rmv_cl_cvars.lua")
    include("shared/rmv_network_strings.lua")
    include("client/vgui/rmv_fonts.lua")
    include("client/rmv_cl_rafsmapvote.lua")
    include("client/vgui/rmv_mapvote_panel.lua")
    include("client/vgui/rmv_mapvote_list.lua")
    include("client/rmv_chat_routines.lua")
end

local function sendMaterials()
    -- You can probably get a table of these and make a loop
    resource.AddFile("materials/clock.png")
    resource.AddFile("materials/cross_black.png")
    resource.AddFile("materials/cross_white.png")
    resource.AddFile("materials/moon.png")
    resource.AddFile("materials/no_thumbnail.png")
    resource.AddFile("materials/sun.png")
end

if SERVER then
    sendClientScripts()
    sendMaterials()
    loadServerScripts()
end

if CLIENT then
    loadClientScripts()
end
