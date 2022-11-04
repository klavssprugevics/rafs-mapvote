if CLIENT then

    RMV_ALL_PLAYERS = {}
    RMV_PLAYER_VOTES = {}
    RMV_MAPS = {}
    RMV_CLOSED = false
    
    net.Receive('START_MAPVOTE', function(len)
        RMV_CLOSED = false
        RMV_ALL_PLAYERS = player:GetAll()
        RMV_MAPS = net.ReadTable()
        InitGUI()
    end)

    -- Update avatars 
    net.Receive('REFRESH_VOTES', function(len)
        if RMV_CLOSED then
            return
        end
        
        local votes = net.ReadTable()
        for pl, vote in pairs(votes) do
            local prev_vote = RMV_PLAYER_VOTES[pl]
            if prev_vote ~= vote then
                RMV_PLAYER_VOTES[pl] = vote
                RefreshAvatar(pl)
            end
        end
    end)

    net.Receive('NEXT_MAP', function()
        if RMV_CLOSED then
            return
        end
        local nextMap = net.ReadString()
        
        TitleLabel:SetText('The winner is: ' .. nextMap)
        TitleLabel:SizeToContents()

        -- To do: Some flashy effect
    end)

end