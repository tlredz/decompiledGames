local parent = script.Parent

if not parent:IsA("Tool") then
	return
end

local localPlayer = game.Players.LocalPlayer
local travelerNote = script:WaitForChild("TravelerNote")
parent.Equipped:Connect(function()
	local playerGui = localPlayer.PlayerGui

	if not playerGui then
		return
	end

	local clone = travelerNote:Clone()
	clone.Parent = playerGui
end)
parent.Unequipped:Connect(function()
	local playerGui = localPlayer.PlayerGui

	if not playerGui then
		return
	end

	if playerGui:FindFirstChild("TravelerNote") then
		playerGui:FindFirstChild("TravelerNote"):Destroy()
	end
end)