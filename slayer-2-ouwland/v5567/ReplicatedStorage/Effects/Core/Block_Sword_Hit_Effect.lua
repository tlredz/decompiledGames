local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
return function(parent, parent2)
	if parent ~= nil and parent2 ~= nil then
		if (parent.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 350 then
			return
		end

		local clone = script.bhit.Attachment:Clone()
		local cFrame = clone.CFrame

		if Utility.IsMeshRig(parent2.Parent) then
			clone.Parent = parent
			clone.CFrame = CFrame.new(0, 0, gameSettings.rigHitEffectOffset) * cFrame
		else
			clone.Parent = parent2
		end

		vfxUtility.EmitAll(clone, vfxUtility.Owned(parent))

		for _, light in pairs(clone:GetDescendants()) do
			if light:IsA("PointLight") then
				TweenService:Create(light, tweenInfo, {
					Brightness = 0
				}):Play()
			end
		end

		if game.Players.LocalPlayer.Character == parent2.Parent then
			Cam_Shaker(parent2.Position, "tinyshake_preset")
		end

		clone.Sound:Play()
		DebrisModule:AddItem(clone, 1.5)
	end
end