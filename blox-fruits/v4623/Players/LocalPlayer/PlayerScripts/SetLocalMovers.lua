local setLocalMovers = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SetLocalMovers")
local BodyMover = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("BodyMover"))
local localPlayer = game.Players.LocalPlayer
setLocalMovers.OnClientEvent:Connect(function(p, p2)
	local character = localPlayer.Character

	if not character then
		return
	end

	local active = BodyMover:GetActive(character)

	if active then
		for _, v in pairs(active[p]) do
			v.value:Set(p2)
		end
	end
end)