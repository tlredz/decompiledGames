local Players = game:GetService("Players")
local React = require(game.ReplicatedStorage.Packages.React)
return function()
	local localPlayer = Players.LocalPlayer
	local useState = React.useState
	local v

	if localPlayer then
		v = localPlayer.Character or nil
	end

	local state, setState = useState(v)
	React.useEffect(function()
		if not localPlayer then
			return
		end

		local function onCharacterAdded(p)
			setState(p)
		end

		local characterAddedConnection = localPlayer.CharacterAdded:Connect(onCharacterAdded)
		local characterRemovingConnection = localPlayer.CharacterRemoving:Connect(function()
			setState(nil)
		end)

		if localPlayer.Character then
			setState(localPlayer.Character)
		end

		return function()
			characterAddedConnection:Disconnect()
			characterRemovingConnection:Disconnect()
		end
	end, { localPlayer })
	return state
end