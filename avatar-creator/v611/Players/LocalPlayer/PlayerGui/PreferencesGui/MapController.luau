local createVector = vector.create
local SavedPreferences = require(game.ReplicatedStorage:WaitForChild("SavedPreferences"))
local loaded = SavedPreferences.Load()
local map = script.Parent.Panel.Pages.Map
local Lighting = game:GetService("Lighting")
local baseplate = workspace:WaitForChild("Baseplate")
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", Lighting)
local v = {
	GreenScreen = {
		14,
		2,
		Color3.new(1, 1, 1),
		0,
		Color3.new(0, 1, 0)
	},
	Daylight = {
		14,
		2,
		Color3.fromRGB(155, 165, 185),
		0.2,
		Color3.fromRGB(199, 221, 255)
	},
	Sunset = {
		18.1,
		1.7,
		Color3.fromRGB(171, 127, 148),
		0.3,
		Color3.fromRGB(255, 186, 138)
	},
	Night = {
		0,
		1,
		Color3.fromRGB(75, 90, 128),
		0.2,
		Color3.fromRGB(120, 147, 200)
	},
	Misty = {
		9,
		1.3,
		Color3.fromRGB(160, 174, 180),
		0.48,
		Color3.fromRGB(213, 225, 225)
	}
}
local v2 = {
	GreenScreen = { Enum.Material.SmoothPlastic, Color3.new(0, 1, 0) },
	Classic = { Enum.Material.Plastic, Color3.fromRGB(85, 145, 65) },
	Grass = { Enum.Material.Grass, Color3.fromRGB(100, 140, 84) },
	Sand = { Enum.Material.Sand, Color3.fromRGB(216, 194, 143) },
	Snow = { Enum.Material.Snow, Color3.fromRGB(234, 240, 245) },
	Slate = { Enum.Material.Slate, Color3.fromRGB(76, 84, 96) },
	Marble = { Enum.Material.Marble, Color3.fromRGB(209, 206, 202) }
}

local function highlight(list, p)
	for _, button in ipairs(map:GetChildren()) do
		if not (button:IsA("TextButton") and button.Name:sub(1, #list) == list) then
			continue
		end

		button.BackgroundColor3 = button.Name == list .. p and Color3.fromRGB(73, 97, 131) or Color3.fromRGB(46, 51, 60)
	end
end

local function flatGreen(parent, face)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "FlatGreenScreen"
	surfaceGui.Face = face
	surfaceGui.AlwaysOnTop = false
	surfaceGui.LightInfluence = 0
	surfaceGui.Brightness = 1
	surfaceGui.MaxDistance = 10000
	surfaceGui.CanvasSize = Vector2.new(16, 16)
	surfaceGui.ZOffset = 0.01
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	frame.Parent = surfaceGui
	surfaceGui.Parent = parent
	return surfaceGui
end

local parent2 = flatGreen(baseplate, Enum.NormalId.Top)
parent2.Enabled = false
local model = Instance.new("Model")
model.Name = "LocalGreenScreenSky"
local v4 = {}
local v5 = true

for _, v6 in ipairs({
	createVector(1, 0, 0),
	createVector(-1, -0, -0),
	createVector(0, 1, 0),
	createVector(-0, -1, -0),
	createVector(0, 0, 1),
	createVector(-0, -0, -1)
}) do
	local part = Instance.new("Part")
	part.Name = "GreenScreenWall"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.new(0, 1, 0)
	part.Size = Vector3.new(v6.X == 0 and 258 or 1, v6.Y == 0 and 258 or 1, v6.Z == 0 and 258 or 1)
	flatGreen(
		part,
		v6.X > 0 and Enum.NormalId.Left or v6.X < 0 and Enum.NormalId.Right or v6.Y > 0 and Enum.NormalId.Bottom or v6.Y < 0 and Enum.NormalId.Top or v6.Z > 0 and Enum.NormalId.Front or Enum.NormalId.Back
	)
	part.Reflectance = 0
	part.Parent = model
	table.insert(v4, {
		part = part,
		offset = v6 * 128
	})
end

local globalShadows = Lighting.GlobalShadows
local fogStart = Lighting.FogStart
local fogEnd = Lighting.FogEnd
local enabledsByPostEffect = {}

local function greenSky(p)
	model.Parent = p and workspace or nil

	if p then
		Lighting.GlobalShadows = false
	else
		Lighting.GlobalShadows = globalShadows
	end

	Lighting.FogStart = p and 100000 or fogStart
	Lighting.FogEnd = p and 100000 or fogEnd

	if p then
		for _, postEffect in Lighting:GetChildren() do
			if not postEffect:IsA("PostEffect") then
				continue
			end

			if enabledsByPostEffect[postEffect] == nil then
				enabledsByPostEffect[postEffect] = postEffect.Enabled
			end

			postEffect.Enabled = false
		end
	else
		for k, enabled in pairs(enabledsByPostEffect) do
			if k.Parent then
				k.Enabled = enabled
			end
		end

		enabledsByPostEffect = {}
	end
end

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	if not (model.Parent and workspace.CurrentCamera) then
		return
	end

	local position = workspace.CurrentCamera.CFrame.Position

	for _, v6 in v4 do
		v6.part.Position = position + v6.offset
	end
end)
script.Destroying:Connect(function()
	model.Parent = nil
	Lighting.GlobalShadows = globalShadows
	Lighting.FogStart = fogStart
	Lighting.FogEnd = fogEnd

	for k, enabled in pairs(enabledsByPostEffect) do
		if k.Parent then
			k.Enabled = enabled
		end
	end

	enabledsByPostEffect = {}
	model:Destroy()
	parent2:Destroy()
end)

local function sky(p)
	if not v5 then
		SavedPreferences.Set("SkyPreset", p)
	end

	greenSky(p == "GreenScreen")
	local v6 = v[p]
	Lighting.ClockTime = v6[1]
	Lighting.Brightness = v6[2]
	Lighting.Ambient = v6[3]
	Lighting.OutdoorAmbient = v6[3]
	atmosphere.Density = v6[4]
	atmosphere.Color = v6[5]
	atmosphere.Haze = p == "Misty" and 2 or 0
	highlight("Sky_", p)
end

local function terrain(p)
	if not v5 then
		SavedPreferences.Set("GroundPreset", p)
	end

	parent2.Enabled = p == "GreenScreen"
	local v6 = v2[p]
	baseplate.Material = v6[1]
	baseplate.Color = v6[2]
	baseplate.Transparency = 0
	baseplate.TopSurface = p == "Classic" and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth

	for _, child in ipairs(baseplate:GetChildren()) do
		if child:IsA("Texture") or child:IsA("Decal") then
			child.Transparency = 1
		end
	end

	highlight("Ground_", p)
end

for k in pairs(v) do
	local v6 = k
	map["Sky_" .. k].Activated:Connect(function()
		sky(v6)
	end)
end

for k in pairs(v2) do
	local v6 = k
	map["Ground_" .. k].Activated:Connect(function()
		terrain(v6)
	end)
end

map.Reset.Activated:Connect(function()
	sky("Daylight")
	terrain("Classic")
end)
sky(loaded.SkyPreset)
terrain(loaded.GroundPreset)
v5 = false