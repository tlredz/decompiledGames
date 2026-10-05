local character = game.Players.LocalPlayer.Character
local currentCamera = workspace.CurrentCamera
local VRService = game:GetService("VRService")
local Network = require(game.ReplicatedStorage.Modules.Network)

if not VRService.VREnabled then
	return
end

local cframe = CFrame.Angles(-1.5707963267948966, 0, 0)

while true do
	local v = {}

	if character.PrimaryPart then
		local _ = character.PrimaryPart
		v.head = currentCamera:GetRenderCFrame()

		if character:FindFirstChild("RightHand") then
			v.right = character.RightHand.CFrame * cframe
		end

		if character:FindFirstChild("LeftHand") then
			v.left = character.LeftHand.CFrame * cframe
		end

		Network:fire("VR_Replication", v)
	end

	task.wait(0.03333333333333333)
end