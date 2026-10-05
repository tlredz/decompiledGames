local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
game:GetService("TweenService")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
return function(instance, p: string, childName: string?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local formatted = `{script.Name}-DragState`
	local child = humanoidRootPart:FindFirstChild(formatted)

	if child ~= nil then
		child.Name = "--"
		DebrisModule:AddItem(child, 0.4)
		vfxUtility.EnableAll(child, false)
	end

	if p == "Start" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{"Start"}`
		DebrisModule:AddItem(configuration, 3.5)
		local clone = script.Explode:Clone()
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0)
		clone.Parent = configuration
		local clone2 = (childName ~= nil and script:FindFirstChild(childName) or script.Init):Clone()
		clone2.Parent = clone
		clone2:Play()
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local v

		if raycastResult then
			v = raycastResult.Instance.Color
		end

		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(v)))
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.3,
			SustainTime = 0.2,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif p == "DustTrail" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{"DustTrail"}`
		DebrisModule:AddItem(configuration, 2)
		local cFrame = humanoidRootPart.CFrame
		local clone = script.Skill.Dash:Clone()
		clone:PivotTo(cFrame)
		clone.Parent = configuration
		local clone2 = script.Dash:Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		local cFrame2 = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame2.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.3,
			SustainTime = 0.2,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(4.5, 4.5, 4.5)
		})
		local clone3 = script.Attachments.DashAttach:Clone()
		clone3.Name = formatted
		clone3.Parent = humanoidRootPart
		DebrisModule:AddItem(clone3, 3.5)
		Ouwmit.Enable(clone3, true, Ouwmit.Owned(instance, v ~= nil and {
			Color = v.Color,
			ColorWhitelist = "DustRaycast"
		} or nil))
	elseif p == "Slash" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{"Slash"}`
		DebrisModule:AddItem(configuration, 3)
		local cFrame = humanoidRootPart.CFrame
		local clone = script.Skill.Slash:Clone()
		clone:PivotTo(cFrame)
		clone.Parent = configuration
		local clone2 = script.Slash:Clone()
		clone2.Parent = clone.Slash
		clone2:Play()
		local cFrame2 = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame2.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
		Cam_Shaker(cFrame.Position, "activate_shake")
	end
end