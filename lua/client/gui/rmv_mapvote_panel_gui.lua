if CLIENT then

    RMV_MAPVOTE_PANEL = nil

    -- Positions
    local GUI_STARTING_X = 5
    local GUI_STARTING_Y = 55
    local GUI_UI_WIDTH = ScrW() * 0.75
    local GUI_UI_HEIGHT = ScrH() * 0.8
    local GUI_THUMBNAIL_COORDS = {}

    -- Sizes
    local GUI_THUMBNAIL_WIDTH = (GUI_UI_WIDTH - 20) / 3  
    local GUI_THUMBNAIL_HEIGHT = (GUI_THUMBNAIL_WIDTH - 20) / 16 * 9 
    local GUI_AVATAR_INIT_SIZE = 32
    local GUI_AVATAR_THUMBNAIL_SIZE = (GUI_THUMBNAIL_WIDTH - 65) / 12

    -- Colors
    local GUI_BASE_PANEL_COLOR = Color(50, 50, 50, 200)
    local GUI_BASE_TEXT_COLOR = Color(255, 255, 255, 255)

    -- Animations
    local GUI_UPDATE_INTERVAL = 0.01

    -- Variables
    local thumbnails = {}
    local allAvatars = {}
    local selectedMap = nil

    
    -- Main panel
    function CreateMainPanel()
        local Frame = vgui.Create('DFrame')
        Frame:SetTitle('')
        Frame:SetSize(GUI_UI_WIDTH, GUI_UI_HEIGHT)
        Frame:Center()
        Frame:SetDraggable(false)
        Frame:ShowCloseButton(false)
        Frame:MakePopup()

        Frame.Paint = function(self, _w, _h)
            draw.RoundedBox(0, 0, 0, _w, _h, Color(0, 0, 0, 0))
            Derma_DrawBackgroundBlur(self, SysTime())
            draw.RoundedBox(0, 0, 0, _w, 45, GUI_BASE_PANEL_COLOR)
            draw.RoundedBox(0, GUI_STARTING_X - 15, GUI_STARTING_Y - 5, _w + 15, GUI_THUMBNAIL_HEIGHT * 2 + 15, GUI_BASE_PANEL_COLOR)
            draw.RoundedBox(0, GUI_STARTING_X - 15, GUI_STARTING_Y + (GUI_THUMBNAIL_HEIGHT + 5) * 2 + 5, (GUI_THUMBNAIL_WIDTH + 10) * 2, GUI_THUMBNAIL_HEIGHT / 3, GUI_BASE_PANEL_COLOR)
        end
        RMV_MAPVOTE_PANEL = Frame
    end

    -- Close button
    function CreateCloseButton()
        local CloseButton = vgui.Create('DButton', RMV_MAPVOTE_PANEL)
        CloseButton:SetText('X')
        CloseButton:SetPos(GUI_UI_WIDTH - 40, 0)
        CloseButton:SetTextColor(GUI_BASE_TEXT_COLOR)
        CloseButton:SetFont('XFont')
        CloseButton:SetSize(40, 40)

        CloseButton.Paint = function(self, _w, _h)
            draw.RoundedBox(0, GUI_UI_WIDTH - 60, 5, 16, 16, Color(255, 255, 255, 0))
        end

        CloseButton.DoClick = function()
            ticker = CurTime()
            DeleteAvatars()
            RMV_MAPVOTE_PANEL:Clear()
            RMV_MAPVOTE_PANEL:Close()
            RMV_CLOSED = true
        end
    end

    -- Title label
    function CreateTitleLabel(text)
        TitleLabel = vgui.Create('DLabel', RMV_MAPVOTE_PANEL)
        TitleLabel:SetText(text)
        TitleLabel:SetTextColor(GUI_BASE_TEXT_COLOR)
        TitleLabel:SetFont('TitleFont')
        TitleLabel:SetPos(10, 0)
        TitleLabel:SizeToContents()
    end

    -- Button for random vote
    function CreateRandomButton()
        local RandomButton = vgui.Create('DButton', RMV_MAPVOTE_PANEL)
        local xpos = (GUI_THUMBNAIL_WIDTH + 5) * 2 + 5
        local ypos = GUI_STARTING_Y + (GUI_THUMBNAIL_HEIGHT + 5) * 2 + 5
        RandomButton:SetText('Random map')
        RandomButton:SetPos((GUI_THUMBNAIL_WIDTH + 5) * 2 + 5, GUI_STARTING_Y + (GUI_THUMBNAIL_HEIGHT + 5) * 2 + 5)
        RandomButton:SetSize(GUI_THUMBNAIL_WIDTH + 15, GUI_THUMBNAIL_HEIGHT / 3)
        RandomButton:SetTextColor(GUI_BASE_TEXT_COLOR)
        RandomButton:SetFont('ButtonFont')
        RandomButton.Paint = function(self, _w, _h)
            draw.RoundedBox(0, 0, 0, _w, _h, GUI_BASE_PANEL_COLOR)
        end

        GUI_THUMBNAIL_COORDS['random'] = {
            xpos,
            ypos,
            xpos + GUI_THUMBNAIL_WIDTH,
            ypos + GUI_THUMBNAIL_HEIGHT / 3
        }

        RandomButton.DoClick = function()
            selectedMap = 'random'
            RefreshThumbnails()
            net.Start('MAP_CHOICE')
            net.WriteString('random')
            net.SendToServer()
        end
    end

    -- Map thumbnails
    function CreateMapThumbnails()
        for k, mapName in pairs(RMV_MAPS) do
    
            local MapVoteImage = vgui.Create('DImageButton', RMV_MAPVOTE_PANEL)
            local MapLabel = vgui.Create('DLabel', RMV_MAPVOTE_PANEL)

            MapLabel:SetText(mapName)
            MapLabel:SetTextColor(GUI_BASE_TEXT_COLOR)
            MapLabel:SetFont('TextOverImageFont')
            MapLabel:SetSize(GUI_THUMBNAIL_WIDTH, 40)

            MapVoteImage:SetPos(GUI_THUMBNAIL_COORDS[mapName][1], GUI_THUMBNAIL_COORDS[mapName][2])
            MapLabel:SetPos(GUI_THUMBNAIL_COORDS[mapName][1] + 5, GUI_THUMBNAIL_COORDS[mapName][2] + GUI_THUMBNAIL_HEIGHT - 40)
            MapVoteImage:SetSize(GUI_THUMBNAIL_WIDTH, GUI_THUMBNAIL_HEIGHT)

            --local fileName = settings['THUMBNAIL_DIR'] .. mapName .. '.jpg'
            local fileName = 'a.jpg'
            if file.Exists(fileName, 'data') then
                MapVoteImage:SetImage('data/' .. fileName)
            else
                MapVoteImage:SetMaterial('models/rendertarget')
            end
            
            thumbnails[mapName] = MapVoteImage
            MapVoteImage.DoClick = function()
                selectedMap = mapName
                RefreshThumbnails()
                net.Start('MAP_CHOICE')
                net.WriteString(mapName)
                net.SendToServer()
            end
        end
    end

    function RefreshThumbnails() 
        for map, img in pairs(thumbnails) do
            img:SetPos(GUI_THUMBNAIL_COORDS[map][1], GUI_THUMBNAIL_COORDS[map][2])
            img:SetSize(GUI_THUMBNAIL_WIDTH, GUI_THUMBNAIL_HEIGHT)
            if map == selectedMap then
                img:SetPos(GUI_THUMBNAIL_COORDS[map][1] + 2, GUI_THUMBNAIL_COORDS[map][2] + 2)
                img:SetSize(GUI_THUMBNAIL_WIDTH - 4, GUI_THUMBNAIL_HEIGHT - 4)
            end
        end
    end

    function CreateThumbnailBackgrounds()
        for _, map in pairs(RMV_MAPS) do
            local panel = vgui.Create('DPanel')
            
            panel:SetPos(GUI_THUMBNAIL_COORDS[map][1], GUI_THUMBNAIL_COORDS[map][2])
            panel:SetSize(GUI_THUMBNAIL_COORDS[map][3] - GUI_THUMBNAIL_COORDS[map][1], GUI_THUMBNAIL_COORDS[map][4] - GUI_THUMBNAIL_COORDS[map][2])
            panel:SetParent(RMV_MAPVOTE_PANEL)
            panel.Paint = function(self, _w, _h)
                draw.RoundedBox(0, 0, 0, _w, _h, Color(0, 255, 255, 255))
            end
                
        end
    end

    -- Populate avatar dock
    function CreateAvatarDock()
       -- Initial position of avatars
       local xposCounter, yposCounter = GUI_STARTING_X, GUI_STARTING_Y + (GUI_THUMBNAIL_HEIGHT + 5) * 2 + 10
       local counter = 1
       for key, p in pairs(RMV_ALL_PLAYERS) do
           RMV_PLAYER_VOTES[p] = -1
           local avatar = vgui.Create('AvatarImage', RMV_MAPVOTE_PANEL)
           avatar:SetSize(GUI_AVATAR_INIT_SIZE, GUI_AVATAR_INIT_SIZE)
           avatar:SetPos(xposCounter, yposCounter)
           avatar:SetPlayer(p, 32)
           avatar:SetTooltip(p:GetName())
           avatar:SetParent(RMV_MAPVOTE_PANEL)
           allAvatars[p] = avatar

           if counter == 18 then
               yposCounter = yposCounter + GUI_AVATAR_INIT_SIZE + 5
               xposCounter = GUI_STARTING_X
           else
               xposCounter = xposCounter + GUI_AVATAR_INIT_SIZE + 5
           end
           counter = counter + 1
       end
    end

    function CalculateThumbnailPositions()
        for k, mapName in pairs(RMV_MAPS) do
            local xpos = 0
            local ypos = 0
            if k < 4 then
                xpos = GUI_STARTING_X + (GUI_THUMBNAIL_WIDTH + 5) * (k - 1)
                ypos = GUI_STARTING_Y
            else
                xpos = GUI_STARTING_X + (GUI_THUMBNAIL_WIDTH + 5) * (k - 4)
                ypos = GUI_STARTING_Y + GUI_THUMBNAIL_HEIGHT + 5
            end
            
            GUI_THUMBNAIL_COORDS[mapName] = {xpos,
            ypos,
            xpos + GUI_THUMBNAIL_WIDTH,
            ypos + GUI_THUMBNAIL_HEIGHT}

        end
    end

    function InitGUI()
        CreateMainPanel()
        CreateCloseButton()
        CreateTitleLabel('Vote for the next map:')
        CreateRandomButton()
        CalculateThumbnailPositions()
        CreateThumbnailBackgrounds()
        CreateMapThumbnails()
        CreateAvatarDock()
    end
    
    function RefreshAvatar(ply)
        if allAvatars[ply] ~= nil then
            allAvatars[ply]:Remove()
            allAvatars[ply] = nil
        end
        InitAvatar(GUI_THUMBNAIL_COORDS[RMV_PLAYER_VOTES[ply]], GUI_AVATAR_THUMBNAIL_SIZE, ply)
    end

    local ticker = 0
    hook.Add('Think', 'CurTimeDelay', function()
        if CurTime() <= ticker then
            return
        end	

        if RMV_MAPVOTE_PANEL ~= nil then
            if not RMV_MAPVOTE_PANEL:IsValid() then
                ticker = CurTime() 
                return
            end
        end

        UpdateAvatars(GUI_THUMBNAIL_COORDS, GUI_AVATAR_THUMBNAIL_SIZE)
        ticker = CurTime() + GUI_UPDATE_INTERVAL
    end)
end