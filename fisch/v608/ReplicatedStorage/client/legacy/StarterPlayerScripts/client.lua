local createVector = vector.create
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local localPlayer = Players.LocalPlayer
local auroraBorealis = game.Workspace:WaitForChild("active"):WaitForChild("constant"):WaitForChild(
	"Aurora Borealis",
	1e999
)
local fishing = workspace:WaitForChild("zones"):WaitForChild("fishing", 1e999)
local underwater = localPlayer.PlayerGui:WaitForChild("sounds"):WaitForChild("underwater")
local ambience = SoundService:WaitForChild("ambience")
local weather = SoundService:WaitForChild("weather")
local music = SoundService:WaitForChild("music")
Lighting:WaitForChild("sunrays")
local constant = game.Workspace:WaitForChild("active"):WaitForChild("constant")
local cloudParticles = constant:WaitForChild("CloudParticles"):WaitForChild("CloudParticles")
local waves = constant:WaitForChild("Waves"):WaitForChild("Waves")
local waves2 = waves:WaitForChild("waves")
local c1 = cloudParticles:WaitForChild("c1")
local snow1 = cloudParticles:WaitForChild("snow1")
local snow2 = cloudParticles:WaitForChild("snow2")
local weather2 = ReplicatedStorage:WaitForChild("world"):WaitForChild("weather")
local meteorological = weather2:WaitForChild("meteorological")
local season = ReplicatedStorage:WaitForChild("world"):WaitForChild("season")
local auroraBorealis2 = auroraBorealis:WaitForChild("Aurora Borealis")
local rainbow = constant:WaitForChild("Rainbow"):WaitForChild("Rainbow")
local starfall = constant:WaitForChild("Starfall")
local tornado = constant:WaitForChild("Tornado")
local tornadoVFX = tornado:WaitForChild("TornadoVFX")
local Workspace = game:GetService("Workspace")
local terrain = Workspace:WaitForChild("Terrain")
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local random = Random.new()
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)

if game.PlaceId ~= 131579468225600 then
	repeat
		local v = pcall(function()
			StarterGui:SetCore("ResetButtonCallback", false)
		end)
		task.wait(1)
	until v
end

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)

function UpdateAuroraBorealis()
	for _, beam in pairs(auroraBorealis2:GetChildren()) do
		if beam:IsA("Beam") then
			beam.Enabled = meteorological.Value == "Aurora Borealis"
		end
	end
end

function UpdateRainbow()
	local v = meteorological.Value == "Rainbow"
	GeneralUtils.fastTween(rainbow.SurfaceGui.ImageLabel, TweenInfo.new(v and 6 or 4), {
		ImageTransparency = v and 0 or 1
	})
end

local renderSteppedConnection = nil

function UpdateStarfall()
	task.wait(random:NextNumber(3, 5))

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if meteorological.Value ~= "Starfall" then
		return
	end

	local v = 0
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
		if v > 0 then
			v -= dt
			return
		end

		v = random:NextNumber(0.3, 1.2)
		local character = Players.LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (workspace:FindFirstChild("world") and workspace.world:FindFirstChild("water") and workspace.world.water:FindFirstChild("seaVolumes") and workspace.world.water.seaVolumes:FindFirstChild("MainSea")) then
			return
		end

		local vector2 = Vector3.new(
			humanoidRootPart.Position.X - math.random(1000, 1300),
			math.clamp(humanoidRootPart.Position.Y + math.random(700, 800), -160, 10000),
			humanoidRootPart.Position.Z + math.random(0, 2000)
		)
		local vector3 = Vector3.new(vector2.X - 200, vector2.Y - 800, vector2.Z - 1500)
		local v2 = (vector2 - vector3).Magnitude / math.random(350, 425)
		local clone = starfall:WaitForChild("StarTemplate"):Clone()
		clone.Name = "Star"

		for _, descendant in clone:GetDescendants() do
			if not (descendant:IsA("Trail") or descendant:IsA("BillboardGui") or descendant:IsA("Script")) then
				continue
			end

			descendant.Enabled = true
		end

		clone.Position = vector2
		clone.Parent = starfall
		Debris:AddItem(clone, v2 + 1)
		GeneralUtils.fastTween(clone, TweenInfo.new(v2), {
			Position = vector3
		})
	end)
end

local renderSteppedConnection2 = nil
local clones = {}

function UpdateTornado()
	if renderSteppedConnection2 then
		renderSteppedConnection2:Disconnect()
		renderSteppedConnection2 = nil
	end

	for _, v in clones do
		v:Destroy()
	end

	table.clear(clones)
	task.wait(random:NextNumber(1, 3))
	local enabled = weather2.Value == "Tornado"

	for _, effect in tornadoVFX:GetDescendants() do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = enabled
		end
	end

	if not enabled then
		return
	end

	local function spawnWindPart()
		local character = Players.LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local position = humanoidRootPart.Position + Vector3.new(0, math.random(-20, 10), 0)
		local clone

		if clones[1] then
			clone = clones[1]
			table.remove(clones, 1)
		else
			clone = tornado:WaitForChild("WindTemplate"):Clone()
		end

		clone.Name = "Wind" .. tostring(math.random(1, 1000))
		clone.Position = position
		clone.Anchored = true
		clone.CanCollide = false
		clone.Trail.Enabled = true
		clone.Parent = tornado
		local lastTime = tick()
		local v3 = math.random(3, 6)
		local v4 = math.random(1, 360)
		local v5 = math.random(100, 125)
		local v6 = math.random(300, 400)
		local rotSpeed = clone:GetAttribute("RotSpeed") or createVector(10, 10, 10)
		task.spawn(function()
			while clone and clone.Parent == tornado and tick() - lastTime < v3 do
				local v7 = tick() - lastTime
				local v8 = (tick() + v4) * 10 * 0.5
				local v9 = v5 + 150 * (v7 / v3)
				local v10 = v9 * math.cos(v8)
				local v11 = v9 * math.sin(v8)
				local vector2 = Vector3.new(position.X + v10, position.Y + v6 * (v7 / v3), position.Z + v11)
				local cframe = CFrame.Angles(
					math.rad(rotSpeed.X * v7),
					math.rad(rotSpeed.Y * v7),
					(math.rad(rotSpeed.Z * v7))
				)
				clone.CFrame = CFrame.new(vector2) * cframe
				task.wait(0.025)
			end
		end)
		task.delay(v3, function()
			if not clone or clone.Parent ~= tornado then
				return
			end

			clone.Trail.Enabled = false
			table.insert(clones, clone)
		end)
	end

	local total = 0
	local v2 = 0
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt: number)
		local character = Players.LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local mainSea = humanoidRootPart and humanoidRootPart.Parent and workspace:FindFirstChild("world") and workspace.world:FindFirstChild("water") and workspace.world.water:FindFirstChild("seaVolumes") and workspace.world.water.seaVolumes:FindFirstChild("MainSea")

		if mainSea then
			total += dt * 0.08
			local position = humanoidRootPart.Position
			local v3 = position.X + math.cos(total) * 200
			local v4 = position.Z + math.sin(total) * 200
			local v5 = math.clamp(
				humanoidRootPart.Position.Y - 1,
				mainSea.Position.Y + mainSea.Size.Y / 2,
				mainSea.Position.Y + mainSea.Size.Y / 2 + 10
			)
			tornadoVFX:PivotTo(CFrame.new(v3, v5, v4))
		end

		if v2 > 0 then
			v2 -= dt
			return
		end

		v2 = random:NextNumber(0.25, 1)
		spawnWindPart()
	end)
end

UpdateAuroraBorealis()
UpdateRainbow()
UpdateStarfall()
UpdateTornado()
weather2.Changed:Connect(UpdateTornado)
meteorological.Changed:Connect(function()
	UpdateAuroraBorealis()
	UpdateRainbow()
	UpdateStarfall()
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
local count = 0
local count2 = 0

local function AddToHash(instance)
	if instance:GetAttribute("NotWater") == true then
		return
	end

	local v3 = instance.CFrame * CFrame.new(instance.Size / 2)
	local v4 = v
	local v5, v6

	if instance.Size.X * instance.Size.Z // 160000 >= 2 then
		v4 = v2
		v5 = 200
		v6 = 400
	else
		v5 = 50
		v6 = 100
	end

	for i = 0, instance.Size.X // v5 + 1 do
		local v7 = v3.Position - v3.RightVector * i * v5

		for i2 = 0, instance.Size.Z // v5 + 1 do
			local v8 = v7 + v3.LookVector * i2 * v5

			for i3 = 0, instance.Size.Y // v5 + 1 do
				local v9 = v8 - v3.UpVector * i3 * v5 + Vector3.new(v5, v5, v5)
				local vector2 = Vector3.new(v9.X // v6, v9.Y // v6, v9.Z // v6)
				v4[vector2] = v4[vector2] or {}

				if table.find(v4[vector2], instance) then
					continue
				end

				table.insert(v4[vector2], instance)
				count += 1
			end
		end
	end

	count2 += 1
end

for _, child in ipairs(fishing:GetChildren()) do
	AddToHash(child)
end

fishing.ChildAdded:Connect(function(part)
	if part:IsA("BasePart") then
		AddToHash(part)
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function UnderwaterStuff()
	localPlayer:SetAttribute("IsWater", true)
	ambience.muffle.Enabled = true
	music.muffle.Enabled = true
	weather.muffle.Enabled = true
	Lighting.underwaterbl.Enabled = true
	Lighting.underwatercc.Enabled = true
	underwater.Volume = 0.6
	underwater.Playing = true
end

local function OverwaterStuff()
	localPlayer:SetAttribute("IsWater", false)
	ambience.muffle.Enabled = false
	music.muffle.Enabled = false
	local value = localPlayer.Character:WaitForChild("zone").Value

	if value ~= nil and not value:FindFirstChild("indoors") then
		weather.muffle.Enabled = false
	end

	Lighting.underwaterbl.Enabled = false
	Lighting.underwatercc.Enabled = false
	underwater.Volume = 0
	underwater.Playing = false
end

waves2.Enabled = true

local function isCameraInNoUnderwaterZone(position: Vector3)
	for _, part in pairs(CollectionService:GetTagged("NoUnderwaterEffects")) do
		if part:IsA("BasePart") and (part:GetClosestPointOnSurface(position) - position).Magnitude <= 0.25 then
			return true
		end
	end

	return false
end

local function updateUnderwaterState()
	local position = workspace.CurrentCamera.CFrame.Position
	local vector2 = Vector3.new(position.X // 100, position.Y // 100, position.Z // 100)
	local vector3 = Vector3.new(position.X // 400, position.Y // 400, position.Z // 400)
	local v3 = v[vector2]
	local v4 = v2[vector3]
	local cameraInNoUnderwaterZone = isCameraInNoUnderwaterZone(position)

	if v3 or v4 then
		local flag = false

		if not cameraInNoUnderwaterZone then
			if v3 then
				for _, v6 in v3 do
					if not ((v6:GetClosestPointOnSurface(position) - position).Magnitude <= 0.25) then
						continue
					end

					flag = true
					break
				end
			end

			if not flag and v4 then
				for _, v6 in ipairs(v4) do
					if not ((v6:GetClosestPointOnSurface(position) - position).Magnitude <= 0.25) then
						continue
					end

					flag = true
					break
				end
			end
		end

		if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("zone") and Players.LocalPlayer.Character.zone.Value and Players.LocalPlayer.Character.zone.Value:FindFirstChild("ignoreOcean") then
			flag = false
		end

		if flag and not (localPlayer:GetAttribute("IsWater") or cameraInNoUnderwaterZone) then
			if Players.LocalPlayer:GetAttribute("NoWaterZone") or Players.LocalPlayer:GetAttribute("InFinalJurassicCutscene") or Players.LocalPlayer:GetAttribute("playingJurassicCutscene") then
				OverwaterStuff()
			else
				UnderwaterStuff() -- equivalent call inferred; original call site unknown
			end
		elseif Players.LocalPlayer:GetAttribute("NoWaterZone") or Players.LocalPlayer:GetAttribute("InFinalJurassicCutscene") or Players.LocalPlayer:GetAttribute("playingJurassicCutscene") or cameraInNoUnderwaterZone then
			OverwaterStuff()
		elseif not flag and localPlayer:GetAttribute("IsWater") == true then
			OverwaterStuff()
		end
	elseif localPlayer:GetAttribute("IsWater") == true then
		OverwaterStuff()
	end

	local character = Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart.Parent then
		auroraBorealis2.Position = Vector3.new(
			humanoidRootPart.Position.X,
			math.clamp(humanoidRootPart.Position.Y + 240, -160, 10000),
			humanoidRootPart.Position.Z
		)
		local mainSea = workspace:FindFirstChild("world") and workspace.world:FindFirstChild("water") and workspace.world.water:FindFirstChild("seaVolumes") and workspace.world.water.seaVolumes:FindFirstChild("MainSea")

		if mainSea then
			waves.Position = Vector3.new(
				humanoidRootPart.Position.X,
				mainSea.Position.Y + mainSea.Size.Y / 2,
				humanoidRootPart.Position.Z
			)
			rainbow.Position = Vector3.new(
				humanoidRootPart.Position.X - 1250,
				math.clamp(humanoidRootPart.Position.Y + 250, mainSea.Position.Y + mainSea.Size.Y / 2, 10000),
				humanoidRootPart.Position.Z
			)
		end

		cloudParticles.Position = Vector3.new(
			humanoidRootPart.Position.X,
			math.clamp(humanoidRootPart.Position.Y + 70, -160, 10000),
			humanoidRootPart.Position.Z
		)
	end
end

RunService.PreRender:Connect(updateUnderwaterState)

local function updateWeatherAndSeason()
	if weather2.Value == "Foggy" then
		c1.Enabled = true
	else
		c1.Enabled = false
	end

	if season.Value == "Winter" and weather2.Value ~= "Rain" then
		snow1.Enabled = true
		snow2.Enabled = true
	else
		snow1.Enabled = false
		snow2.Enabled = false
	end
end

weather2.Changed:Connect(updateWeatherAndSeason)
meteorological.Changed:Connect(updateWeatherAndSeason)
season.Changed:Connect(updateWeatherAndSeason)
terrain.WaterTransparency = 0.45
Lighting.underwatercc.TintColor = Color3.fromRGB(103, 131, 156)
Lighting.underwaterbl.Size = 11
ReplicatedStorage.events:WaitForChild("setWaterTransparency").OnClientEvent:Connect(function(waterTransparency: number, size: number, tintColor: Color3)
	terrain.WaterTransparency = waterTransparency
	Lighting.underwaterbl.Size = size
	Lighting.underwatercc.TintColor = tintColor
end)