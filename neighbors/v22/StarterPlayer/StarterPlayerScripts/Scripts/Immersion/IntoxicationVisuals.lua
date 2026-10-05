local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
game:GetService("UserInputService")
require(ReplicatedStorage.Modules.Server)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera

-- equivalent calls inferred from this helper; original call sites unknown
local function CreateLightingEffect(className: string)
	local instance = Instance.new(className)
	instance.Name = `IntoxicationEffect_{instance.ClassName}`
	instance.Parent = Lighting
	return instance
end

local lightingEffect = CreateLightingEffect("BlurEffect") -- equivalent call inferred; original call site unknown
lightingEffect.Size = 0
local lightingEffect2 = CreateLightingEffect("ColorCorrectionEffect") -- equivalent call inferred; original call site unknown
local lightingEffect3 = CreateLightingEffect("BloomEffect") -- equivalent call inferred; original call site unknown
lightingEffect3.Intensity = 0
lightingEffect3.Size = 0
lightingEffect3.Threshold = 2
localPlayer:GetAttributeChangedSignal("Intoxication"):Connect(function()
	local intoxication = localPlayer:GetAttribute("Intoxication")
	lightingEffect.Size = intoxication * 10
	lightingEffect2.Saturation = -(intoxication / 2)
	lightingEffect3.Threshold = 2 - intoxication * 1.8
	lightingEffect3.Size = intoxication * 20
	lightingEffect3.Intensity = intoxication * 2
end)
CFrame.new()
CFrame.new()
local cFrame = currentCamera.CFrame
RunService:BindToRenderStep("DrunkCameraUpdate", Enum.RenderPriority.Camera.Value + 69, function(_)
	local intoxication = localPlayer:GetAttribute("Intoxication") or 0
	local cFrame2 = currentCamera.CFrame
	cFrame = cFrame:Lerp(cFrame2, (math.clamp(1 - intoxication, 0.2, 1)))

	if intoxication <= 0 then
		cFrame = cFrame2
	end

	local v4 = tick() / 5
	local v5 = math.abs(math.sin(v4) * (intoxication / 2))
	local v6 = math.abs(math.cos(v4) * (intoxication / 2))
	local v7 = math.clamp(1 - v5, 0, 1)
	local v8 = math.clamp(1 - v6, 0, 1)
	local v9 = math.sin((tick(v4 / 2))) * (intoxication / 2) / 4
	local v10 = math.cos((tick(v4 / 2))) * (intoxication / 2) / 4
	local cframe = CFrame.new(0, 0, 0, v7, v9, 0, v10, v8, 0, 0, 0, 1)

	if intoxication > 0.35 then
		SoundService.AmbientReverb = Enum.ReverbType.SewerPipe
	else
		SoundService.AmbientReverb = Enum.ReverbType.NoReverb
	end

	if intoxication <= 0 then
		CFrame.new()
	else
		currentCamera.CFrame = cFrame * cframe
	end
end)