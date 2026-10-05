local Players = game:GetService("Players")
local manage_cd = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("manage_cd"))
return function(childName: string, flag: boolean?)
	if childName == nil then
		return
	end

	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character

	if character == nil then
		return
	end

	local SHC = character:FindFirstChild("SHC")

	if SHC == nil then
		return
	end

	if not flag then
		childName = manage_cd.filter_cd_name(localPlayer, childName)
	end

	local numberValue = SHC:FindFirstChild(childName)

	if numberValue ~= nil and numberValue:IsA("NumberValue") then
		numberValue:Destroy()
	end
end