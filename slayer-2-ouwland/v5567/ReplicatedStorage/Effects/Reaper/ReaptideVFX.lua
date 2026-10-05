local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local TokenKit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
return function(instance, p: string, cframe)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or p ~= "Cancel" and vector.magnitude(humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position) > 200 then
		return
	end

	local name = string.format("%s %s", instance.Name, script.Name)

	if p == "Jump" then
		local clone = script.SkillAssets.Jump:Clone()
		clone.Parent = workspace.Debree
		local clone2 = script.Sounds.PS2reaperSKILL2jump:Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		clone:PivotTo(cframe)
		local raycastResult = workspace:Raycast(
			cframe.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, {
				Color = raycastResult.Instance.Color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			}))
		else
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		end

		DebrisModule:AddItem(clone, 3)
		Cam_Shaker(cframe.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local clone3 = script.SkillAssets.Particles.Wind:Clone()
		clone3.Parent = humanoidRootPart
		DebrisModule:AddItem(clone3, 2)
		task.wait(0.75)
		vfxUtility.EnableAll(clone3, false)
	elseif p == "MissHit" then
		local clone = script.SkillAssets.InitialImpact:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(cframe * CFrame.new(0, -0.75, 0))
		local raycastResult = workspace:Raycast(
			cframe.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, {
				Color = raycastResult.Instance.Color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			}))
		else
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		end

		DebrisModule:AddItem(clone, 3)
		local clone2 = script.Sounds.PS2reaperSKILL2landMISS:Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		OuwCraters.Scales({
			Center = cframe,
			Count = 7,
			ScaleMult = 0.7
		})
		OuwCraters.Scales({
			Center = cframe,
			Count = 7,
			Radius = 14,
			ScaleMult = 1.5
		})
		task.spawn(TokenKit.GroundRocks, {
			CF = clone.MaceHit.CFrame,
			InnerRadius = 10,
			OuterRadius = 20,
			Lifetime = 0.3,
			Velocity = {
				Min = 10,
				Max = 20
			},
			Size = {
				Min = 0.2,
				Max = 0.7
			}
		})
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.3,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif p == "Hit" then
		if workspace.Debree:FindFirstChild(name) then
			workspace.Debree[name]:Destroy()
		end

		local configuration = Instance.new("Configuration")
		configuration.Name = name
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 3)
		OuwCraters.Scales({
			Center = cframe,
			Count = 7
		})
		local clone = script.SkillAssets.Jump2:Clone()
		clone.Parent = configuration
		local clone2 = script.Sounds.PS2reaperSKILL2landSUCCEED:Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		clone:PivotTo(cframe * CFrame.new(0, -0.75, 0))
		local raycastResult = workspace:Raycast(
			cframe.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local color

		if raycastResult and raycastResult.Instance ~= nil then
			color = raycastResult.Instance.Color
		end

		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "DustRaycast", "dustraycast" }
		} or nil) or nil))
		Cam_Shaker(cframe.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.3,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		task.wait(0.3)
		local clone3 = script.SkillAssets.GroundCracks:Clone()
		clone3.Parent = configuration
		clone3:PivotTo(cframe)
		vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "DustRaycast", "dustraycast" }
		} or nil) or nil))
		local weld = Instance.new("Weld")
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone3.PrimaryPart
		weld.Parent = clone3.PrimaryPart
		task.wait(0.15)
		local clone4 = script.Sounds.PS2reaperSKILL2landDRAG:Clone()
		clone4.Parent = clone3.HumanoidRootPart
		clone4:Play()
	elseif p == "Unhold" then
		local cFrame = humanoidRootPart.CFrame
		local child = workspace.Debree:FindFirstChild(name)

		if child then
			local groundCracks = child:FindFirstChild("GroundCracks")

			if groundCracks ~= nil then
				vfxUtility.EnableAll(groundCracks, false)
			end

			child.Name = "--"
			DebrisModule:AddItem(child, 2)
		end

		local clone = script.SkillAssets.Jump2:Clone()
		clone.Parent = workspace.Debree
		local clone2 = script.Sounds.PS2reaperSKILL2landKICKFLIP:Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		clone:PivotTo(cFrame * CFrame.new(0, -0.75, 0))
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, {
				Color = raycastResult.Instance.Color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			}))
		else
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		end

		DebrisModule:AddItem(clone, 3.5)
		Cam_Shaker(cFrame.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	elseif p == "Final" then
		local cFrame = humanoidRootPart.CFrame
		local clone = script.SkillAssets.Finish:Clone()
		clone:PivotTo(cFrame)
		clone.Parent = workspace.Debree
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, {
				Color = raycastResult.Instance.Color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			}))
		else
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		end

		local clone2 = script.Sounds.PS2reaperSKILL2landSTOMP:Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		OuwCraters.Scales({
			Center = cFrame,
			ScaleMult = 1.35,
			Radius = 7,
			Count = 7
		})
		task.spawn(TokenKit.GroundRocks, {
			CF = clone.MaceHit.CFrame,
			InnerRadius = 10,
			OuterRadius = 20,
			Lifetime = 0.3,
			Velocity = {
				Min = 10,
				Max = 20
			},
			Size = {
				Min = 0.2,
				Max = 0.7
			}
		})
		Cam_Shaker(cFrame.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
		DebrisModule:AddItem(clone, 3)
		TweenService:Create(clone.Slash, TweenInfo.new(0.2), {
			CFrame = clone.Slash.CFrame * CFrame.Angles(-2.0943951023931953, 0, 0)
		}):Play()
		task.delay(0.1, function()
			for _, beam in clone.Slash:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				TweenService:Create(beam, TweenInfo.new(0.1), {
					TextureLength = 0
				}):Play()
				local v2 = beam
				task.delay(0.05, function()
					TweenService:Create(v2, TweenInfo.new(0.1), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			end
		end)
	end
end