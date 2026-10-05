local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local terrain = game.Workspace:WaitForChild("Terrain")
local localPlayer = Players.LocalPlayer
local humanoidRootPart = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
local currentCamera = game.Workspace.CurrentCamera
local auroraBorealis = workspace:WaitForChild("active"):WaitForChild("constant"):WaitForChild("Aurora Borealis")
local fishing = workspace:WaitForChild("zones"):WaitForChild("fishing")
local underwater = localPlayer.PlayerGui:WaitForChild("sounds"):WaitForChild("underwater")
local ambience = SoundService:WaitForChild("ambience")
local weather = SoundService:WaitForChild("weather")
local music = SoundService:WaitForChild("music")
local constant = workspace:WaitForChild("active"):WaitForChild("constant")
local cloudParticles = constant:WaitForChild("CloudParticles"):WaitForChild("CloudParticles")
local waves = constant:WaitForChild("Waves"):WaitForChild("Waves"):WaitForChild("waves")
local c1 = cloudParticles:WaitForChild("c1")
local snow1 = cloudParticles:WaitForChild("snow1")
local snow2 = cloudParticles:WaitForChild("snow2")
local weather2 = ReplicatedStorage:WaitForChild("world"):WaitForChild("weather")
local season = ReplicatedStorage:WaitForChild("world"):WaitForChild("season")
local auroraBorealis2 = auroraBorealis:WaitForChild("Aurora Borealis")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)

if not table.find({ 131579468225600, 140688791331730 }, game.PlaceId) then
	repeat
		local v = pcall(function()
			StarterGui:SetCore("ResetButtonCallback", false)
		end)
		task.wait(1)
	until v
end

function UpdateAuroraBorealis()
	for _, beam in pairs(auroraBorealis2:GetChildren()) do
		if beam:IsA("Beam") then
			beam.Enabled = ReplicatedStorage:WaitForChild("world"):WaitForChild("weather").Value == "Aurora Borealis"
		end
	end
end

UpdateAuroraBorealis()
ReplicatedStorage:WaitForChild("world"):WaitForChild("weather").Changed:Connect(function()
	UpdateAuroraBorealis()
end)

local function focusGained()
	ReplicatedStorage:WaitForChild("events"):WaitForChild("afk"):FireServer(false)
end

local function focusReleased()
	ReplicatedStorage:WaitForChild("events"):WaitForChild("afk"):FireServer(true)
end

UserInputService.WindowFocused:Connect(focusGained)
UserInputService.WindowFocusReleased:Connect(focusReleased)
local v = {}
local v2 = {}
local v3 = {}
local count = 0
local count2 = 0

local function AddToHash(instance)
	local v4 = instance.CFrame * CFrame.new(instance.Size / 2)
	local v5 = v
	local v6, v7

	if instance.Size.X * instance.Size.Z // 160000 >= 2 then
		v5 = v3
		v6 = 200
		v7 = 400
	else
		v6 = 50
		v7 = 100
	end

	for i = 0, instance.Size.X // v6 + 1 do
		local v8 = v4.Position - v4.RightVector * i * v6

		for i2 = 0, instance.Size.Z // v6 + 1 do
			local v9 = v8 + v4.LookVector * i2 * v6

			for i3 = 0, instance.Size.Y // v6 + 1 do
				local v10 = v9 - v4.UpVector * i3 * v6 + Vector3.new(v6, v6, v6)
				local vector = Vector3.new(v10.X // v7, v10.Y // v7, v10.Z // v7)
				v5[vector] = v5[vector] or {}

				if table.find(v5[vector], instance) then
					continue
				end

				table.insert(v5[vector], instance)
				count += 1
			end
		end
	end

	count2 += 1
	v2[instance] = true
end

for _, child in pairs(fishing:GetChildren()) do
	AddToHash(child)
end

fishing.ChildAdded:Connect(function(part)
	if part:IsA("BasePart") then
		AddToHash(part)
	end
end)
print(count, "total inserts into spatial hash")
print(count2, "total parts hashed")
local v4 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleUnderwaterEffects(p)
	v4 = p
	ambience.muffle.Enabled = p
	music.muffle.Enabled = p
	weather.muffle.Enabled = p and localPlayer.Character.zone and localPlayer.Character.zone.Value and not localPlayer.Character.zone.Value:FindFirstChild("indoors")
	Lighting.underwaterbl.Enabled = p
	Lighting.underwatercc.Enabled = p
	underwater.Volume = p and 0.6 or 0
	underwater.Playing = p
end

waves.Enabled = true
RunService.PreRender:Connect(function()
	local position = currentCamera.CFrame.Position
	local vector = Vector3.new(position.X // 100, position.Y // 100, position.Z // 100)
	local vector2 = Vector3.new(position.X // 400, position.Y // 400, position.Z // 400)
	local v5 = v[vector]
	local v6 = v3[vector2]

	if v5 or v6 then
		local v7 = false

		if v5 then
			for _, v9 in ipairs(v5) do
				if not ((v9:GetClosestPointOnSurface(position) - position).Magnitude <= 0.25) then
					continue
				end

				v7 = true
				break
			end
		end

		if not v7 and v6 then
			for _, v9 in ipairs(v6) do
				if not ((v9:GetClosestPointOnSurface(position) - position).Magnitude <= 0.25) then
					continue
				end

				v7 = true
				break
			end
		end

		if v7 and not v4 then
			toggleUnderwaterEffects(true)
		elseif not v7 and v4 then
			toggleUnderwaterEffects(false) -- equivalent call inferred; original call site unknown
		end
	elseif v4 then
		toggleUnderwaterEffects(false) -- equivalent call inferred; original call site unknown
	end

	if humanoidRootPart and humanoidRootPart.Parent then
		local position2 = humanoidRootPart.Position
		auroraBorealis2.Position = Vector3.new(position2.X, math.clamp(position2.Y + 240, -160, 10000), position2.Z)
		cloudParticles.Position = Vector3.new(position2.X, math.clamp(position2.Y + 70, -160, 10000), position2.Z)
		waves.Parent.Position = Vector3.new(position2.X, 26.135, position2.Z)
	end
end)
toggleUnderwaterEffects(false) -- equivalent call inferred; original call site unknown

local function updateWeatherAndSeason()
	c1.Enabled = weather2.Value == "Foggy"
	local v5 = season.Value == "Winter"
	snow1.Enabled = v5 and weather2.Value ~= "Rain"
	snow2.Enabled = v5 and weather2.Value ~= "Rain"
end

weather2:GetPropertyChangedSignal("Value"):Connect(updateWeatherAndSeason)
season:GetPropertyChangedSignal("Value"):Connect(updateWeatherAndSeason)
terrain.WaterTransparency = 0.45
Lighting.underwatercc.TintColor = Color3.fromRGB(103, 131, 156)
Lighting.underwaterbl.Size = 11
ReplicatedStorage.events:WaitForChild("setWaterTransparency").OnClientEvent:Connect(function(waterTransparency, size, tintColor)
	terrain.WaterTransparency = waterTransparency
	Lighting.underwaterbl.Size = size
	Lighting.underwatercc.TintColor = tintColor
end)
toggleUnderwaterEffects(false) -- equivalent call inferred; original call site unknown