local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local color = Color3.fromRGB(255, 255, 255)
local Math = require(script.Parent.Math)
local ClientData = require(ReplicatedStorage.Omni.ClientData)
local isClient = RunService:IsClient()

local function GetOrCreate(className: string, name: string)
	local child = Lighting:FindFirstChild(name)

	if child and child:IsA(className) then
		return child
	end

	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = Lighting
	return instance
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetFalloff(position: Vector3?, maxDistance: number?)
	if not position then
		return 1
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return 0
	end

	local magnitude = (currentCamera.CFrame.Position - position).Magnitude
	return Math.Falloff(magnitude, maxDistance or 80)
end

local Lighting_2 = {}

function Lighting_2.Blur(_, data)
	if isClient and ClientData.Ready and ClientData.Data.Settings["Low Mode"] then
		return
	end

	local falloff = GetFalloff(data.Position, data.MaxDistance) -- equivalent call inferred; original call site unknown

	if falloff <= 0 then
		return
	end

	local name = data.Name or "SkillBlur"
	local v2 = Lighting:FindFirstChild(name)

	if not (v2 and v2:IsA("BlurEffect")) then
		v2 = Instance.new("BlurEffect")
		v2.Name = name
		v2.Parent = Lighting
	end

	v2.Size = 0
	local tween = TweenService:Create(
		v2,
		TweenInfo.new(data.InTime or 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Size = (data.Size or 24) * falloff
		}
	)
	tween:Play()
	tween.Completed:Once(function()
		task.wait(data.HoldTime or 0.05)
		TweenService:Create(v2, TweenInfo.new(data.OutTime or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = 0
		}):Play()
	end)
end

function Lighting_2.ImpactFrame(_, data)
	if isClient and ClientData.Ready and ClientData.Data.Settings["Low Mode"] then
		return
	end

	local falloff = GetFalloff(data.Position, data.MaxDistance) -- equivalent call inferred; original call site unknown

	if falloff <= 0 then
		return
	end

	local name = data.Name or "SkillImpactFrame"
	local v2 = Lighting:FindFirstChild(name)

	if not (v2 and v2:IsA("ColorCorrectionEffect")) then
		v2 = Instance.new("ColorCorrectionEffect")
		v2.Name = name
		v2.Parent = Lighting
	end

	v2.TintColor = (data.TintColor or color):Lerp(color, 1 - falloff)
	v2.Brightness = (data.Brightness or 0.6) * falloff
	v2.Contrast = (data.Contrast or 0.4) * falloff
	v2.Saturation = (data.Saturation or -0.6) * falloff
	task.wait(data.HoldTime or 0.05)
	TweenService:Create(v2, TweenInfo.new(data.Duration or 0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TintColor = color,
		Brightness = 0,
		Contrast = 0,
		Saturation = 0
	}):Play()
end

return Lighting_2