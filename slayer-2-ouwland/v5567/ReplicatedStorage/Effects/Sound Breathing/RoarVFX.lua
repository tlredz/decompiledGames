game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = workspace.CurrentCamera
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
return function(instance, p: string, _)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local formatted = `{instance.Name}-{script.Name}`
	local child = workspace.Debree:FindFirstChild(formatted)

	if child ~= nil then
		child.Name = "--"
		Ouwmit.Enable(child, false)
		DebrisModule:AddItem(child, 1)
	end

	if p == "Start" then
		vfxUtility.PlaySound(script.Sounds, "PS2soundROARinit", humanoidRootPart, true)
		local configuration = Instance.new("Configuration")
		configuration.Name = formatted
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 10)

		for _, v in { instance:FindFirstChild("Has_Blade", true), instance:FindFirstChild("Has_Blade2", true) } do
			local blade = v.Parent:FindFirstChild("Blade") or v.Parent:FindFirstChild("Blade2")

			if blade == nil then
				continue
			end

			local clone = script.Trails["Sword_At_A,Sword_At_B"]:Clone()
			clone.Parent = configuration
			clone.Attachment0 = blade.Sword_At_A
			clone.Attachment1 = blade.Sword_At_B
			local clone2 = script.Trails["Sword_At_A,Sword_At_C"]:Clone()
			clone2.Parent = configuration
			clone2.Attachment0 = blade.Sword_At_A
			clone2.Attachment1 = blade.Sword_At_C
			local clone3 = script.Trails["Sword_At_A,Sword_At_D"]:Clone()
			clone3.Parent = configuration
			clone3.Attachment0 = blade.Sword_At_A
			clone3.Attachment1 = blade.Sword_At_D
		end
	elseif p == "Explode" then
		vfxUtility.PlaySound(script.Sounds, "PS2soundROARexplo", humanoidRootPart, true)
		local cFrame = humanoidRootPart.CFrame
		local clone = script.Explosion:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(cFrame)
		DebrisModule:AddItem(clone, 4)
		local center = CFrame.new(clone.Explosion.SlamFX.WorldPosition) * cFrame.Rotation
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		OuwCraters.Scales({
			Center = center,
			ScaleMult = 0.8
		})
		Cam_Shaker(center.Position, "medium_shake_preset")
	end
end