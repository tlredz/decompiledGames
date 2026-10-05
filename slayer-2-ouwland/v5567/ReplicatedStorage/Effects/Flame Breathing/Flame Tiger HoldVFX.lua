local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local currentCamera = workspace.CurrentCamera
local TokenKit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Config = require(ReplicatedStorage.Skills["Flame Breathing"]["Flame Tiger"].Config)
return function(instance, p: string, value: number?, instance2, _: CFrame?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or vector.magnitude(humanoidRootPart.Position - currentCamera.CFrame.Position) >= 200 then
		return
	end

	if p == "Slash" then
		local clone = script:FindFirstChild("BeamSlash" .. (value or 1)):Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(humanoidRootPart.CFrame)

		if clone.Root:FindFirstChild("Sound") then
			vfxUtility.PlayAtComboSpeed(clone.Root.Sound, Config.HOLD_ANIM_SPEED)
		end

		DebrisModule:AddItem(clone, 2)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.35,
			Amplitude = 0.28,
			SustainTime = 0.35,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.12, 0.12, 0.12),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})
	elseif p == "Jump" then
		local clone = script.Jump:Clone()
		clone.Parent = workspace.Debree
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0)
		vfxUtility.PlayAtComboSpeed(clone.PS2flameCHARGEdashDASH, Config.HOLD_ANIM_SPEED)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.25,
			Amplitude = 0.18,
			SustainTime = 0.2,
			FadeOutTime = 0.15,
			RotationInfluence = createVector(0.08, 0.08, 0.08),
			PositionInfluence = createVector(0.3, 0.3, 0.3)
		})

		if instance2 ~= nil then
			local rootPart = instance2:FindFirstChild("RootPart")

			if rootPart ~= nil then
				for _, child in ipairs(script.Parent["Flame Tiger TapVFX"].Attachments.Tiger:GetChildren()) do
					local clone2 = child:Clone()
					clone2.Parent = rootPart.Mouth
					DebrisModule:AddItem(clone2, 3.5)
					Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
				end

				for _, child in ipairs(script.Parent["Flame Tiger TapVFX"].Attachments.Tiger2:GetChildren()) do
					local clone2 = child:Clone()
					clone2.Parent = rootPart.Mouth["Bone.002"]
					DebrisModule:AddItem(clone2, 3.5)
					Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
				end
			end
		end
	elseif p == "Slam" then
		local configuration = Instance.new("Configuration")
		configuration.Name = `{script.Name}-{"Slam"}`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 4)
		local clone = script:FindFirstChild("BeamSlash5"):Clone()
		clone.Parent = configuration
		clone:PivotTo(humanoidRootPart.CFrame)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		local cFrame = humanoidRootPart.CFrame
		local clone2 = script:FindFirstChild("FlameSlam"):Clone()
		clone2.Parent = configuration
		clone2:PivotTo(cFrame)
		vfxUtility.PlayAtComboSpeed(clone2.Root.PS2flametigerCOMBOslam, Config.HOLD_ANIM_SPEED)
		local cFrame2 = clone2.Part1.CFrame
		OuwCraters.Scales({
			Center = cFrame2,
			Duration = 2,
			Radius = 9,
			ScaleMult = 0.85
		})
		local raycastResult = workspace:Raycast(cFrame2.Position, cFrame2.UpVector * -15, RaycastHelper.Crater)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			color = raycastResult.Instance.Color
			clone2.Part1.raycastdust.WorldPosition = raycastResult.Position
		end

		Ouwmit.Emit(clone2, Ouwmit.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Dust" },
			ColorBlacklist = { "GroundCracks", "Debree22t" }
		} or nil) or nil))
		task.spawn(TokenKit.GroundRocks, {
			CF = cFrame2,
			InnerRadius = 2,
			OuterRadius = 15,
			Velocity = {
				Min = 20,
				Max = 40
			},
			Size = {
				Min = 0.75,
				Max = 3
			}
		})
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0.01,
			Frequency = 0.3,
			Amplitude = 0.4,
			SustainTime = 0.35,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(0.75, 0.75, 0.75)
		})
	end
end