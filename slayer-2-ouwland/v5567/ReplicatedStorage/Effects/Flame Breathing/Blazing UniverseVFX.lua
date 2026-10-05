local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.CraterHandler)
local currentCamera = workspace.CurrentCamera
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local TokenKit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
return function(instance, p: string, cFrame: CFrame?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or vector.magnitude(humanoidRootPart.Position - currentCamera.CFrame.Position) >= 200 and p ~= "Cancel" then
		return
	end

	if p == "Start" then
		local clone = script.FlameStartup:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -1.5, 0))
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		local clone2 = script.Parent["Unknowing FireVFX"].Sounds.PS2flameCHARGEcharge:Clone()
		clone2.Parent = clone.Startup
		clone2:Play()
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.UpVector * -10,
			RaycastHelper.Crater
		)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			color = raycastResult.Instance.Color
			clone.Startup.Position = raycastResult.Position
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Dust" },
			ColorBlacklist = { "GroundCracks", "Debree22t" }
		} or nil) or nil))
	elseif p == "Jump" then
		local configuration = Instance.new("Configuration")
		configuration.Name = `{script.Name}-{"Jump"}`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 2)
		local has_Blade = instance:FindFirstChild("Has_Blade", true)

		if has_Blade ~= nil then
			local blade = has_Blade.Parent:FindFirstChild("Blade")

			if blade ~= nil then
				local clone = script.SwordAura:Clone()
				clone.Parent = configuration
				clone.Weld.Part0 = blade
				Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			end
		end

		local clone = script.FlameJump:Clone()
		clone.Parent = configuration

		if typeof(cFrame) ~= "CFrame" then
			cFrame = humanoidRootPart.CFrame
		end

		clone:PivotTo(cFrame * CFrame.new(0, -1.5, 0))
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		OuwCraters.Scales({
			Center = cFrame,
			Count = 5,
			Radius = 6,
			OffsetMargin = 6,
			ScaleMult = 0.7
		})
		local clone2 = script.Sounds.PS2flameCHARGEarialJUMP:Clone()
		clone2.Parent = clone.Part1
		clone2:Play()
	elseif p == "Slam" then
		local configuration = Instance.new("Configuration")
		configuration.Name = `{script.Name}-{"Slam"}`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 2)

		if typeof(cFrame) ~= "CFrame" then
			cFrame = humanoidRootPart.CFrame
		end

		local v = cFrame * CFrame.new(0, 0, -3.5)
		local _ = v.lookVector
		local clone = script.FlameSlam:Clone()
		clone.Parent = configuration
		clone:PivotTo(v)
		local raycastResult = workspace:Raycast(v.Position, v.upVector * -150, RaycastHelper.Crater)
		local v2, color

		if raycastResult == nil or raycastResult.Position == nil then
			v2 = v
		else
			color = raycastResult.Instance.Color
			clone.Part1.Position = raycastResult.Position + createVector(0, 0.15, 0) + v.lookVector * 3.5
			v2 = CFrame.new(raycastResult.Position) * v.Rotation
		end

		OuwCraters.Scales({
			Center = v2,
			Count = 8,
			OffsetMargin = 6
		})
		local clone2 = script.Sounds.PS2flameCHARGEarialSLAM:Clone()
		clone2.Parent = clone.Part1
		clone2:Play()
		Cam_Shaker(v2.Position, "medium_shake_preset")
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Dust" },
			ColorBlacklist = { "GroundCracks", "Debree22t" }
		} or nil) or nil))
		task.spawn(TokenKit.GroundRocks, {
			CF = v2,
			InnerRadius = 2,
			OuterRadius = 15,
			Velocity = {
				Min = 20,
				Max = 40
			},
			Size = {
				Min = 0.75,
				Max = 2
			}
		})
		local clone3 = script.BeamSlash:Clone()
		clone3:PivotTo(v)
		clone3.Parent = configuration
		Ouwmit.Emit(clone3, Ouwmit.Owned(instance))
	end
end