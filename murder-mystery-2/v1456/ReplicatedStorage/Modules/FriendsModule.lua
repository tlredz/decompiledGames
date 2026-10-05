local FriendsModule = {}
local localPlayer = game.Players.LocalPlayer
FriendsModule.FriendsOnline = {}

function FriendsModule:GetFriendsOnline()
	if os.clock() - -10 >= 10 and localPlayer.UserId > 0 then
		pcall(function()
			FriendsModule.FriendsOnline = localPlayer:GetFriendsOnline()
		end)
	end

	return FriendsModule.FriendsOnline
end

return FriendsModule