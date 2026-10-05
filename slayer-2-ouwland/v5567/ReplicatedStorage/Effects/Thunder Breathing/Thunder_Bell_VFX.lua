local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.CAM.Client.Modules
require(modules.Effects.Craters.CraterHandler)
script:FindFirstChild("Assets")
local _ = workspace.Debree
script:FindFirstChild("Sounds")
require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(game.ReplicatedStorage.CAM.DebrisModule)
local tweenInfo = TweenInfo.new(0.085)

local function Random_Number(p, p2)
	return Random.new():NextNumber(p, p2)
end

local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local tweenInfo2 = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo3 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

local function LTN()
	local clone = script.NewAssets.ColorCorrection:Clone()
	clone.Parent = workspace.Camera
	TweenService:Create(clone, tweenInfo2, {
		TintColor = Color3.fromRGB(255, 255, 255)
	}):Play()
	TweenService:Create(clone, tweenInfo3, {
		Brightness = 0,
		Contrast = 0,
		Saturation = 0
	}):Play()
	DebrisModule:AddItem(clone, 0.2)
end

return function(instance, p, p2)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local formatted = `{script.Name}-{instance.Name}`

	if p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local parent = workspace.Debree:FindFirstChild(formatted)

	if p == "Dash1" or p == "Dash2" or p == "Dash3" then
		if p == "Dash1" then
			if parent ~= nil then
				parent:Destroy()
			end

			parent = Instance.new("Folder")
			parent.Name = formatted
			parent.Parent = workspace.Debree
			DebrisModule:AddItem(parent, 4)
			local clone = script.NewAssets.Startup:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -1.8, 0))
			clone.Parent = parent
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				humanoidRootPart.CFrame.upVector * -30,
				RaycastHelper.Crater
			)
			local color

			if not (raycastResult == nil or raycastResult.Instance == nil) then
				local cFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.new(0, 1, 0)
				clone.Startup.CFrame = cFrame
				clone.GroundFX.CFrame = cFrame
				color = raycastResult.Instance.Color
			end

			Ouwmit.Emit(clone, Ouwmit.Owned(instance, color ~= nil and ({
				Color = color,
				ColorWhitelist = { "raycastdust", "Rocks", "Dust" }
			} or nil) or nil))
		end

		if parent == nil then
			return
		end

		local v2 = p2[1]
		local v3 = p2[2]
		local v4 = p2[3]
		local _ = p2[4]
		local clone = script.NewAssets[p]:Clone()
		clone.CFrame = CFrame.new(v3.Position, v2.Position) * CFrame.Angles(3.141592653589793, 0, 0)
		clone.Parent = parent
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		local clone2 = script.Sounds.PS2thunderbreathTBdash:Clone()
		clone2.Parent = clone
		clone2:Play()
		local trail = parent:FindFirstChild("Trail")

		if trail == nil then
			trail = script.NewAssets.Trail:Clone()
			trail.Parent = parent
		end

		trail.CFrame = CFrame.new(v2.Position, v3.Position)
		TweenService:Create(trail, tweenInfo, {
			CFrame = trail.CFrame * CFrame.new(0, 0, -v4)
		}):Play()
		Cam_Shaker(humanoidRootPart.Position, "tinyshake_less_aggresive_preset")
	elseif p == "Downslam" then
		if parent == nil then
			return
		end

		local trail = parent:FindFirstChild("Trail")

		if trail == nil then
			trail = script.NewAssets.Trail:Clone()
			trail.Parent = parent
		end

		trail.CFrame = CFrame.new(trail.Position, p2.Position)
		TweenService:Create(trail, tweenInfo, {
			CFrame = trail.CFrame * CFrame.new(0, 0, -vector.magnitude(trail.Position - p2.Position))
		}):Play()
		local clone = script.NewAssets.ThunderBolt:Clone()
		clone:PivotTo(CFrame.new(p2.Position, trail.Position) * CFrame.Angles(0, 3.141592653589793, 0))
		clone.Parent = parent
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -30,
			RaycastHelper.Crater
		)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			local cFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(0, 0, 0)
			clone.SlashVFXEmit.Startup.CFrame = cFrame
			clone.SlashVFXEmit.GroundFX.CFrame = cFrame
			color = raycastResult.Instance.Color
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "raycastdust", "Rocks", "Dust" }
		} or nil) or nil))
		OuwCraters.Scales({
			Center = humanoidRootPart.CFrame,
			Duration = 1.5,
			Count = 10,
			ScaleMult = 1,
			Radius = 14
		})
		OuwCraters.Scales({
			Center = humanoidRootPart.CFrame,
			Duration = 2,
			Count = 10,
			ScaleMult = 2,
			Radius = 20
		})

		if instance == game.Players.LocalPlayer.Character or vector.magnitude(workspace.CurrentCamera.CFrame.Position - p2.Position) < 30 then
			LTN()
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.75,
			SustainTime = 0.14,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local clone2 = script.Sounds.PS2thunderbreathTBdownslam:Clone()
		clone2.Parent = clone.SlashVFXEmit.Startup
		clone2:Play()
		parent.Name = "--"
	end
end