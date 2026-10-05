local localPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local function handleFall()
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or humanoidRootPart.Position.Y > -10 then
		return
	end

	humanoidRootPart.CFrame = CFrame.new(2480.5, 4.51, -463.75)
end

return {
	Priority = 1,
	Run = function()
		RunService.Heartbeat:Connect(handleFall)
	end
}