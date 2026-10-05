local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cframe = CFrame.new(0, 5000, 0)
local cframe2 = CFrame.new()
local currentCamera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local closeButton = parent:WaitForChild("closeButton")
local bgButton = parent:WaitForChild("bgButton")
local hideButton = parent:WaitForChild("hideButton")
local v = false
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local part = Instance.new("Part")
part.Size = createVector(2048, 1, 2048)
part.CFrame = cframe - createVector(0, 5, 0)
part.Anchored = true
part.Transparency = 1
part.Parent = workspace
local sky = Instance.new("Sky")
sky.CelestialBodiesShown = false
sky.StarCount = 0
local sky2 = Lighting:FindFirstChildOfClass("Sky")

if sky2 then
	sky2.Parent = nil
end

sky.Parent = Lighting
local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")

if clouds then
	clouds.Enabled = false
end

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

if atmosphere then
	atmosphere.Parent = nil
end

local hud = parent.Parent:WaitForChild("hud")
local rain = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("rain"))

local function updateTransparency(descendant)
	if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Fire") or descendant:IsA("Smoke") or descendant:IsA("Sparkles") or descendant:IsA("Explosion") then
		descendant.LocalTransparencyModifier = v and 1 or 0
	elseif descendant:IsA("Light") or descendant:IsA("LayerCollector") then
		if descendant:GetAttribute("OriginalEnabled") == nil then
			descendant:SetAttribute("OriginalEnabled", descendant.Enabled)
		end

		descendant.Enabled = not v and descendant:GetAttribute("OriginalEnabled")
	end
end

local function updateAllTransparency()
	local v2 = localPlayer.Character:FindFirstChildOfClass("Tool") ~= nil

	for _, descendant in localPlayer.Character:GetDescendants() do
		if not (not v or not (v2 and descendant:FindFirstAncestorOfClass("Tool")) and (v2 or descendant:FindFirstAncestorOfClass("Model") == localPlayer.Character)) then
			continue
		end

		updateTransparency(descendant)
	end
end

local function close()
	parent.Enabled = false
	currentCamera.CameraType = Enum.CameraType.Custom
	character:PivotTo(cframe2)
	part:Destroy()
	v = false
	updateAllTransparency()
	sky:Destroy()

	if sky2 then
		sky2.Parent = Lighting
	end

	if clouds then
		clouds.Enabled = true
	end

	if atmosphere then
		atmosphere.Parent = Lighting
	end

	hud.Enabled = true
	ContextActionService:UnbindAction("PortablePhotoboothFOVZoom")
	script.Parent.requestClose:FireServer()
end

closeButton.Activated:Connect(close)
hideButton.Activated:Connect(function()
	v = not v
	hideButton.Text = v and "Show Character" or "Hide Character"
	updateAllTransparency()
end)
local v2 = 1
local v3 = {
	"rbxassetid://131348339199280",
	"rbxassetid://1361097",
	"rbxassetid://88963401772611",
	"rbxassetid://140529999049576",
	"rbxassetid://135457998783916",
	"rbxassetid://101469499833409"
}
local v4 = {
	Color3.fromRGB(0, 0, 0),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(25, 29, 33),
	Color3.fromRGB(52, 52, 59)
}
local v5 = {
	"SkyboxBk",
	"SkyboxDn",
	"SkyboxFt",
	"SkyboxLf",
	"SkyboxRt",
	"SkyboxUp"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function updateSky()
	local v6 = v3[v2]

	for _, v7 in v5 do
		sky[v7] = v6
	end

	Lighting.FogColor = v4[v2]
end

bgButton.Activated:Connect(function(object)
	if object:IsModifierKeyDown(Enum.ModifierKey.Shift) then
		v2 -= 1
	else
		v2 += 1
	end

	if v2 < 1 then
		v2 = #v3
	elseif v2 > #v3 then
		v2 = 1
	end

	updateSky() -- equivalent call inferred; original call site unknown
	local v6 = v2 == 3 or v2 == 4
	Lighting.EnvironmentDiffuseScale = v6 and 0 or 0.763
	Lighting.EnvironmentSpecularScale = v6 and 0 or 0.6
end)
updateSky() -- equivalent call inferred; original call site unknown
cframe2 = humanoidRootPart.CFrame
character:PivotTo(cframe)
local cloudParticles = workspace:WaitForChild("active"):WaitForChild("constant"):WaitForChild("CloudParticles"):WaitForChild("CloudParticles")
RunService.RenderStepped:Connect(function()
	if not parent.Enabled then
		return
	end

	part.CFrame = CFrame.new(humanoidRootPart.Position.X, cframe.Position.Y - 5, humanoidRootPart.Position.Z)
	Lighting.ClockTime = 12
	Lighting.Ambient = Color3.fromRGB(255, 255, 255)
	localPlayer.CameraMaxZoomDistance = 512
	Lighting.FogStart = 1024
	Lighting.FogEnd = 1024

	for _, child in Lighting:GetChildren() do
		if child:IsA("SunRaysEffect") then
			child.Intensity = 0
		elseif child:IsA("PostEffect") and not child:IsA("BloomEffect") then
			child.Enabled = false
		end
	end

	for _, emitter in cloudParticles:GetChildren() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	if clouds then
		clouds.Enabled = false
	end

	if rain:IsEnabled() then
		rain:Disable()
	end

	hud.Enabled = false

	if math.min(currentCamera.CFrame.Position.Y, humanoidRootPart.Position.Y) < 4000 then
		close()
	end
end)
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
	if Lighting.ClockTime ~= 12 then
		Lighting.ClockTime = 12
	end
end)
ContextActionService:BindActionAtPriority("PortablePhotoboothFOVZoom", function(_, _, object)
	if not object:IsModifierKeyDown(Enum.ModifierKey.Ctrl) then
		return Enum.ContextActionResult.Pass
	end

	TweenService:Create(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
		FieldOfView = currentCamera.FieldOfView - object.Position.Z * 5
	}):Play()
	return Enum.ContextActionResult.Sink
end, false, Enum.RenderPriority.Camera.Value + 1, Enum.UserInputType.MouseWheel)