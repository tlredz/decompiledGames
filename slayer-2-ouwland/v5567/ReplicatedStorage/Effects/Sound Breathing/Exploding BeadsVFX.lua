local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills.Sound["Exploding Beads"].Config)
local tweenInfo = TweenInfo.new(Config.BEAD_TRAVEL_TIME)
local cframe = CFrame.new(
	-0.000183105469,
	-2.05806732,
	-2.51208353,
	1,
	-2.27373675e-13,
	0,
	-2.27373675e-13,
	1,
	0,
	0,
	0,
	1
)
local cframe2 = CFrame.new(-0.000183105469, -2.45, -2.51194286, 1, -2.27373675e-13, 0, -2.27373675e-13, 1, 0, 0, 0, 1)
local children = script.Explosions:GetChildren()
local v = {
	"PS2explodingbeadsVAR1explo1",
	"PS2explodingbeadsVAR1explo2",
	"PS2explodingbeadsVAR1explo3",
	"PS2explodingbeadsVAR1throw",
	"PS2explodingbeadsVAR2placebomb",
	"PS2explodingbeadsVAR2trigger"
}
return function(instance, p: string, cframe3, p2, p3)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if p == "Cancel" then
		local child = workspace.Debree:FindFirstChild((`{script.Name}-Explode`))
		local v2 = child ~= nil
		local v3 = workspace.Debree:FindFirstChild((`{instance.Name}-{script.Parent.Name}`)) ~= nil

		for _, childName in v do
			if not ((not v2 or childName ~= "PS2explodingbeadsVAR2placebomb" and childName ~= "PS2explodingbeadsVAR2trigger") and (not v3 or childName ~= "PS2explodingbeadsVAR1throw" and string.find(
				childName,
				"explo",
				1,
				true
			) == nil)) then
				continue
			end

			local sound = humanoidRootPart:FindFirstChild(childName)

			if sound and sound:IsA("Sound") then
				sound:Destroy()
			end
		end

		if child then
			child.Name = "--"
			DebrisModule:AddItem(child, 4)
		end
	elseif p == "CloseStart" then
		vfxUtility.PlaySound(script.Sounds, "PS2explodingbeadsVAR2placebomb", humanoidRootPart, true)
		task.wait(0.4)

		if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
			return
		end

		vfxUtility.PlaySound(script.Sounds, "PS2explodingbeadsVAR2trigger", humanoidRootPart, true)
	elseif p == "Placebomb" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-Explode`
		DebrisModule:AddItem(configuration, 5.5)
		local raycastResult = workspace:Raycast(cframe3.Position, cframe3.upVector * -8, RaycastHelper.Crater)
		local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local clone = script.BombPlacefx:Clone()
		clone:PivotTo(cframe3)
		clone.Parent = configuration
		Cam_Shaker(cframe3.Position, "activate_shake")
		local clone2 = script.Bomb:Clone()
		clone2:PivotTo(cframe3)
		clone2.Parent = configuration
		Ouwmit.Emit(configuration, Ouwmit.Owned(instance, v2))
		task.wait(0.75)
		clone2:Destroy()
		local clone3 = script.SmokeScreen:Clone()
		clone3:PivotTo(cframe3 * cframe)
		clone3.Parent = configuration
		Ouwmit.Emit(clone3, Ouwmit.Owned(instance))
		local clone4 = script.Explosion:Clone()
		clone4:PivotTo(cframe3 * cframe2)
		clone4.Parent = configuration
		Ouwmit.Emit(clone4, Ouwmit.Owned(instance, v2))
		Cam_Shaker(clone.DustRaycast.WorldPosition, {
			FadeInTime = 0,
			Frequency = 0.15,
			Amplitude = 0.6,
			SustainTime = 0.14,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		OuwCraters.Scales({
			Center = clone.DustRaycast.WorldCFrame,
			ScaleMult = 0.75,
			Radius = 12
		})
		task.wait(0.18)

		if humanoidRootPart == nil or humanoidRootPart.Parent == nil or configuration.Name == "--" then
			return
		end

		local clone5 = script.Land:Clone()
		clone5:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, 3.5))
		clone5.Parent = configuration
		Ouwmit.Emit(clone5, Ouwmit.Owned(instance, v2))
	elseif p == "BeadsPlacement" then
		vfxUtility.PlaySound(script.Sounds, "PS2explodingbeadsVAR1throw", humanoidRootPart, true)
		local cFrame = humanoidRootPart.CFrame
		Cam_Shaker(cFrame, "activate_shake")
		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.upVector * -8, RaycastHelper.Crater)
		local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local formatted = `{instance.Name}-{script.Parent.Name}`
		local child = workspace.Debree:FindFirstChild(formatted)

		if child ~= nil then
			child:Destroy()
		end

		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = formatted
		DebrisModule:AddItem(configuration, 10)
		local clone = script.TossEmit:Clone()
		clone:PivotTo(cFrame)
		clone.Parent = configuration
		DebrisModule:AddItem(clone, 2)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v2))
	elseif p == "BeadThrow" then
		local child = workspace.Debree:FindFirstChild((`{instance.Name}-{script.Parent.Name}`))

		if child == nil then
			return
		end

		local clone = script.Projectile:Clone()
		clone.CFrame = p2.Start
		clone.Name = "Bead" .. cframe3
		clone.Parent = child
		vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
		TweenService:Create(clone, tweenInfo, {
			CFrame = p2.Goal
		}):Play()
		task.delay(tweenInfo.Time, function()
			if clone.Parent == nil then
				return
			end

			vfxUtility.EnableAll(clone, false)
			local clone2 = script.FinalSwingWind:Clone()
			clone2.Parent = clone
			vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		end)
	elseif p == "BeadsExplode" then
		local child = workspace.Debree:FindFirstChild((`{instance.Name}-{script.Parent.Name}`))

		if child ~= nil then
			child.Name = "--"

			for k, v2 in Config.DetonationOrder(#p2, p3) do
				local child2 = child:FindFirstChild("Bead" .. v2)

				if child2 == nil then
					continue
				end

				if k > 1 then
					task.wait(p2[v2])
				end

				if child ~= nil and child.Parent ~= nil then
					child2:Destroy()
				end

				local cFrame = cframe3[v2] or child2.CFrame
				local clone = children[math.random(1, 2)]:Clone()
				clone.CFrame = cFrame
				clone.Parent = child
				vfxUtility.PlaySound(script.Sounds, `PS2explodingbeadsVAR1explo{math.random(1, 3)}`, clone, true)
				Cam_Shaker(cFrame.Position, "tinyshake_preset")
				Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			end
		end
	end
end