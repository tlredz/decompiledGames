local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local children = script.Explosion:GetChildren()
return function(instance, p: string, _, _)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if p == "Start" then
		local clone = script.UserFX:Clone()
		local formatted = `{instance.Name}-{script.Name}`
		clone.Parent = workspace.Debree
		local weld = Instance.new("Weld", clone)
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone.UserFX
		clone.Name = formatted
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -8,
			RaycastHelper.Crater
		)
		Ouwmit.Enable(
			clone,
			true,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		DebrisModule:AddItem(clone, 10)
		local cam_Shaker = Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 6,
			FadeOutTime = 0.15,
			RotationInfluence = createVector(0.1, 0.1, 0.1),
			PositionInfluence = createVector(0.4, 0.4, 0.4)
		})
		local v2 = vfxUtility.PlaySound(script.Sounds, "PS2soundRESOUNDINGSLASHloopTRUE", humanoidRootPart, false)

		while clone ~= nil and clone.Name == formatted and humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil do
			local clone2 = children[math.random(1, 2)]:Clone()
			clone2.Parent = clone.UserFX
			clone2.WorldCFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -10) * CFrame.new(
				math.random(-15, 15),
				math.random(1, 5),
				math.random(-5, 5)
			)
			Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
			DebrisModule:AddItem(clone2, 3)
			task.wait(0.125)
		end

		cam_Shaker:Destroy()

		if v2 then
			TweenService:Create(v2, TweenInfo.new(0.3), {
				Volume = 0
			}):Play()
			DebrisModule:AddItem(v2, 0.35)
		end
	else
		local child = workspace.Debree:FindFirstChild((`{instance.Name}-{script.Name}`))

		if child ~= nil then
			child.Name = "--"
			Ouwmit.Enable(child, false)
			DebrisModule:AddItem(child, 3)
		end

		if p == "Final" then
			vfxUtility.PlaySound(script.Sounds, "PS2soundRESOUNDINGSLASHfinalslash", humanoidRootPart, true)
			task.wait(0.1)

			if humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil then
				local clone = script.Impact:Clone()
				clone.Parent = workspace.Debree
				clone:PivotTo(humanoidRootPart.CFrame)
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position,
					humanoidRootPart.CFrame.upVector * -8,
					RaycastHelper.Crater
				)
				local surfaceLight = clone.UserFX.UserFX.Light.SurfaceLight
				surfaceLight.Brightness = 35
				surfaceLight.Angle = 90
				TweenService:Create(surfaceLight, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Brightness = 0,
					Angle = 145
				}):Play()
				Ouwmit.Emit(
					clone,
					Ouwmit.Owned(
						instance,
						raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
					)
				)
				DebrisModule:AddItem(clone, 4)
				Cam_Shaker(humanoidRootPart.Position, {
					FadeInTime = 0,
					Frequency = 0.2,
					Amplitude = 1,
					SustainTime = 0.1,
					FadeOutTime = 1,
					RotationInfluence = createVector(0.25, 0.25, 0.25),
					PositionInfluence = createVector(1, 1, 1)
				})
			end
		end
	end
end