local currentCamera = workspace.CurrentCamera
local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
local vfxUtility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("vfxUtility"))
local TweenService = game:GetService("TweenService")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
return function(cFrame)
	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude >= 400 then
		return
	end

	local clone = script.Part:Clone()
	clone.Parent = workspace.Debree
	clone.CFrame = cFrame
	clone.Transparency = 1
	vfxUtility.EmitAll(clone.Attachment)
	clone.Attachment.Sound:Play()
	Cam_Shaker(cFrame.Position, "tinyshake_preset")
	TweenService:Create(clone.Attachment.PointLight, TweenInfo.new(0.4), {
		Brightness = 0
	}):Play()
	DebrisModule:AddItem(clone, 2)
end