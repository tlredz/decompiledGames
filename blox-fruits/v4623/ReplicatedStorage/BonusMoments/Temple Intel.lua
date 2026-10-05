local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Effect = require(game.ReplicatedStorage.Effect)
local Anims = require(game.ReplicatedStorage.Util.Anims)
local Lightning = require(game.ReplicatedStorage.Util.Lightning)
local Maid = require(game.ReplicatedStorage.Util.Maid)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local CompassTracker = require(game.ReplicatedStorage.GuideModule.CompassTracker)
local color = Color3.fromRGB(226, 232, 255)
local color2 = Color3.fromRGB(120, 140, 220)
local color3 = Color3.fromRGB(32, 30, 40)
local count = 0
local v = {
	"Controllers",
	"WeatherController",
	"Precipitation",
	"Singletons",
	"Rain",
	"RainTrail",
	"Particle_1"
}
local v2 = {
	"Map",
	"SkyArea2",
	"SkyTemple",
	"Tree"
}
local maid = Maid.new()
local maid2 = Maid.new()
local flag = false
local flag2 = false
local v3 = false
local v4 = false
local v5 = nil
local v6 = 0
local now = 0
local position = nil
local v7 = false
local v8 = nil

local function localRoot()
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function localAlive()
	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	return humanoid ~= nil and humanoid.Health > 0
end

local function questGiver()
	local nPCs = workspace:FindFirstChild("NPCs")
	local skyQuestGiver2

	if nPCs then
		skyQuestGiver2 = nPCs:FindFirstChild("Sky Quest Giver 2", true)
	end

	if skyQuestGiver2 then
		return skyQuestGiver2:GetPivot().Position
	end

	return v8
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = true

local function roofAbove(position2: Vector3)
	local children = { workspace.CurrentCamera }

	for _, childName in {
		"Characters",
		"Enemies",
		"NPCs",
		"_WorldOrigin"
	} do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	raycastParams.FilterDescendantsInstances = children
	return workspace:Raycast(position2 + createVector(0, 3, 0), createVector(0, 60, 0), raycastParams) ~= nil
end

local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function heat()
	return (math.clamp(math.max(v6 / 14, not (now > 0) and 0 or (os.clock() - now) / 90), 0, 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCompass()
	if not flag2 then
		return
	end

	flag2 = false
	pcall(function()
		CompassTracker.removeTracker("TempleIntelGem")
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startCompass()
	if flag2 then
		return
	end

	flag2 = true
	pcall(function()
		CompassTracker.createTracker("TempleIntelGem", {
			Target = function()
				if not v4 then
					return position or createVector(0, 0, 0)
				end

				local nPCs = workspace:FindFirstChild("NPCs")
				local skyQuestGiver2

				if nPCs then
					skyQuestGiver2 = nPCs:FindFirstChild("Sky Quest Giver 2", true)
				end

				local v9

				if skyQuestGiver2 then
					v9 = skyQuestGiver2:GetPivot().Position
				else
					v9 = v8
				end

				return v9 or position or createVector(0, 0, 0)
			end,
			AlertIconSettings = {
				MaxDistance = 1000
			},
			IconSettings = {
				ShowIsland = false
			},
			ShowOffScreenAlert = true
		})
	end)
end

local function gemTemplate()
	local gem = script:FindFirstChild("Gem")

	if not gem then
		return nil
	end

	if gem:IsA("BasePart") then
		return gem
	end

	return gem:FindFirstChildWhichIsA("BasePart", true)
end

local function shake(p: number, p2: number, p3: number, p4: number)
	local Util = require(game.ReplicatedStorage.Util)
	local cameraShaker = Util.CameraShaker
	pcall(function()
		cameraShaker:ShakeOnce(p, p2, p3, p4, createVector(1, 1, 1), createVector(1, 1, 2))
	end)
end

local function playSound(p: string, vector2: Vector3, p2: number, p3: number, value: number?)
	local Util = require(game.ReplicatedStorage.Util)
	pcall(function()
		Util.Sound:Play(p, vector2, value or 260, p3, p2)
	end)
end

local function loopSound(p: string, p2, p3: number, p4: number, p5: number)
	local Util = require(game.ReplicatedStorage.Util)
	local success, result = pcall(function()
		return Util.Sound:Play(`UpperSkySFX.{p}`, p2, p4, 1, p3, p5)
	end)

	if not success or typeof(result) ~= "Instance" or not result:IsA("Sound") then
		return nil
	end

	result.Looped = true
	return result
end

local function stopLoop(p, p2: number)
	if not p then
		return
	end

	local Util = require(game.ReplicatedStorage.Util)
	pcall(function()
		Util.Sound:FadeOut(p, p2)
	end)
end

local function screenFlash(color4: Color3, p: number, duration: number)
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "IntelShock"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 50
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = color4
	frame.BackgroundTransparency = 1 - p
	frame.Parent = screenGui
	TweenService:Create(frame, TweenInfo.new(duration), {
		BackgroundTransparency = 1
	}):Play()
	Debris:AddItem(screenGui, duration + 0.1)
end

local function boltLight(position2: Vector3, brightness: number, range: number, p: number)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(position2)
	part.Parent = workspace.CurrentCamera
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Brightness = brightness
	pointLight.Range = range
	pointLight.Parent = part
	Debris:AddItem(part, p)
	return pointLight
end

local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
raycastParams2.RespectCanCollide = true
raycastParams2.IgnoreWater = true

local function skyHit(vector2: Vector3)
	local children = { workspace.CurrentCamera }

	for _, childName in { "Characters", "Enemies", "NPCs" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	raycastParams2.FilterDescendantsInstances = children
	return workspace:Raycast(vector2 + createVector(0, 200, 0), createVector(0, -260, 0), raycastParams2)
end

local function summonCloud(position2: Vector3)
	count += 1
	local formatted = `TempleIntelCloud_{count}`
	local folder = Instance.new("Folder")
	folder.Name = "CloudProxy"
	folder:SetAttribute("Id", formatted)
	folder:SetAttribute("Iteration", count)
	folder:SetAttribute("DestroyAt", tick() + 4)
	folder:SetAttribute("Position", position2 + createVector(0, 200, 0))
	folder.Parent = workspace._WorldOrigin
	Debris:AddItem(folder, 4.5)
	Effect.new("Lightning2.X"):play({
		Origin = position2 + createVector(0, 200, 0),
		CloudId = formatted,
		Stage = 2,
		CloudProxy = folder,
		StartCFrame = CFrame.new(position2),
		Height = 200
	})
	return formatted
end

local function stormCloud(position2: Vector3)
	local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin")

	if not _WorldOrigin then
		return nil
	end

	local v9 = _WorldOrigin:FindFirstChild("TempleIntelStormCloud")

	if not v9 then
		v9 = Instance.new("Folder")
		v9.Name = "TempleIntelStormCloud"
		v9:SetAttribute("Id", "TempleIntelStormCloud")
		v9:SetAttribute("Iteration", 1)
		v9.Parent = _WorldOrigin
		maid:GiveTask(v9)
	end

	v9:SetAttribute("Position", position2 + createVector(0, 200, 0))
	v9:SetAttribute("DestroyAt", tick() + 4)
	return "TempleIntelStormCloud"
end

local function fruitBolt(cloudId: string, position2: Vector3, raycastResult: RaycastResult?, value: number?)
	local normal = not raycastResult and createVector(0, 1, 0) or raycastResult.Normal
	local lightning2X = Effect.new("Lightning2.X")
	local v10 = {
		Origin = position2 + createVector(0, 200, 0),
		CloudId = cloudId,
		Stage = 3,
		Result = 0,
		StartCFrame = 0,
		Height = 200,
		SizeMult = 0
	}
	local instance

	if raycastResult then
		instance = raycastResult.Instance
	else
		instance = workspace.Terrain
	end

	v10.Result = {
		Instance = instance,
		Position = position2,
		Normal = normal
	}
	v10.StartCFrame = CFrame.new(position2, position2 + normal)
	v10.SizeMult = value or 0.5
	lightning2X:play(v10)
end

local function groundSparks(vector2: Vector3, p: number, p2: number, size: number)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.FastMode then
		return
	end

	local position2 = vector2 + createVector(0, 0.4, 0)

	for _ = 1, p do
		local v10 = math.random() * 3.141592653589793 * 2
		local v11 = p2 * (0.4 + math.random() * 0.6)
		local position3 = position2 + Vector3.new(math.cos(v10) * v11, 0, math.sin(v10) * v11)
		Lightning.new({
			Lifetime = 0.12 + math.random() * 0.18,
			DrawType = "Singular",
			Colors = {
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, color2)
			},
			Sizes = {
				{
					Size = size * 0.15,
					Time = 0
				},
				{
					Size = size,
					Time = 0.5
				},
				{
					Size = 0,
					Time = 1
				}
			},
			Transparencies = {
				{
					Transparency = 0,
					Time = 0
				},
				{
					Transparency = 0,
					Time = 1
				}
			},
			Points = {
				Start = {
					Position = position2
				},
				End = {
					Position = position3
				}
			},
			ArcSize = {
				Min = 1.5 + v11 * 0.08,
				Max = 3 + v11 * 0.16
			},
			ChangesSegmentOffset = true,
			OffsetChangePercent = {
				EqualOrBelow = 0.15,
				Bounds = { 0, 1 }
			}
		})
	end
end

local function scorch(position2: Vector3)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Slate
	part.Color = color3
	part.Transparency = 0.25
	part.Size = createVector(0.25, 12, 12)
	part.CFrame = CFrame.new(position2 + createVector(0, 0.12, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Parent = workspace.CurrentCamera
	TweenService:Create(part, TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Transparency = 1
	}):Play()
	Debris:AddItem(part, 2)
end

local function shock(vector2: Vector3)
	local character = Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		pcall(function()
			Effect.new("ThunderGod.Aura"):play({
				Root = humanoidRootPart,
				Duration = 1.6
			})
		end)
		task.spawn(function()
			for i = 1, 4 do
				if not humanoidRootPart.Parent then
					break
				end

				local position2 = humanoidRootPart.Position

				for _ = 1, 3 do
					local vector3 = Vector3.new(
						(math.random() - 0.5) * 4,
						(math.random() - 0.5) * 6,
						(math.random() - 0.5) * 4
					)
					local vector4 = Vector3.new(
						(math.random() - 0.5) * 4,
						(math.random() - 0.5) * 6,
						(math.random() - 0.5) * 4
					)
					Effect.new("Lightning.Beam"):play({
						Origin = position2 + vector3,
						Target = position2 + vector4,
						Color = color,
						LayerColor = color2,
						Segments = 3,
						Variance = 0.9,
						Size = 0.35,
						LayerSize = 0.8,
						Curvy = true,
						Duration = 0.2,
						FadeOut = 0.08
					})
				end

				groundSparks(position2 - createVector(0, 2.6, 0), 4, 7, 0.28)
				boltLight(position2, 6 - i, 26, 0.3)
				task.wait(0.14)
			end
		end)
	end

	screenFlash(color, 0.5, 0.3)
	local Util = require(game.ReplicatedStorage.Util)
	local v9 = "ElectricImpactShort"
	local v10 = nil
	local v11 = 0.85
	local v12 = 1
	pcall(function()
		Util.Sound:Play(v9, vector2, v10 or 260, v11, v12)
	end)
	local Util2 = require(game.ReplicatedStorage.Util)
	local cameraShaker = Util2.CameraShaker
	local v13 = 15
	local v14 = 8
	local v15 = 0.02
	local v16 = 1.2
	pcall(function()
		cameraShaker:ShakeOnce(v13, v14, v15, v16, createVector(1, 1, 1), createVector(1, 1, 2))
	end)
end

local function impact(position2: Vector3, flag3: boolean, flag4: boolean, cloudId: string?, raycastResult: RaycastResult?)
	local v9 = flag4 and 1 or 0.55
	local currentCamera = workspace.CurrentCamera
	local v10 = math.clamp(
		1 - (not currentCamera and 1e999 or (currentCamera.CFrame.Position - position2).Magnitude) / 260,
		0,
		1
	)

	if cloudId then
		fruitBolt(cloudId, position2, raycastResult, flag4 and 0.5 or 0.18 + math.random() * 0.24)
	end

	if flag4 then
		Effect.new("TyrantCloudBreak"):play({
			CFrame = CFrame.new(position2),
			Size = createVector(28, 10, 28)
		})
	end

	if flag3 then
		if flag4 then
			Effect.new("DustExplosion"):play({
				CFrame = CFrame.new(position2),
				Size = { 0, 14 },
				Duration = 0.7
			})
			scorch(position2)
		end

		groundSparks(position2, math.round(v9 * 14), v9 * 19.200000000000003, v9 * 0.45)

		if flag4 then
			task.delay(0.09, function()
				groundSparks(position2, math.round(v9 * 9), v9 * 27.599999999999998, v9 * 0.3)
			end)
		end
	end

	if flag4 or v10 > 0.35 then
		local v11 = boltLight(position2 + createVector(0, 3, 0), v9 * 16, v9 * 70, 0.7)
		TweenService:Create(v11, TweenInfo.new(0.08), {
			Brightness = v9 * 2,
			Range = v9 * 40
		}):Play()
		task.delay(0.11, function()
			if v11.Parent then
				v11.Brightness = v9 * 9
				TweenService:Create(v11, TweenInfo.new(0.4), {
					Brightness = 0,
					Range = 14
				}):Play()
			end
		end)
	end

	if v10 <= 0 then
		return
	end

	if flag4 then
		local v11 = v10 * 0.85
		local Util = require(game.ReplicatedStorage.Util)
		local v12 = "ElectricImpactShort"
		local v13 = nil
		local v14 = 0.9
		pcall(function()
			Util.Sound:Play(v12, position2, v13 or 260, v14, v11)
		end)
		local Util2 = require(game.ReplicatedStorage.Util)
		local cameraShaker = Util2.CameraShaker
		local v15 = 7
		local v16 = 5
		local v17 = 0.05
		local v18 = 0.9
		pcall(function()
			cameraShaker:ShakeOnce(v15, v16, v17, v18, createVector(1, 1, 1), createVector(1, 1, 2))
		end)
	elseif v10 > 0.82 then
		local v11 = v10 * 2
		local Util = require(game.ReplicatedStorage.Util)
		local cameraShaker = Util.CameraShaker
		local v12 = 4
		local v13 = 0.05
		local v14 = 0.6
		pcall(function()
			cameraShaker:ShakeOnce(v11, v12, v13, v14, createVector(1, 1, 1), createVector(1, 1, 2))
		end)
	end
end

local function strike(position2: Vector3, duration: number)
	local v9 = skyHit(position2)
	local v10 = v9 ~= nil

	if v9 then
		position2 = v9.Position
	end

	local cloudId = summonCloud(position2)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color2
	part.Transparency = 0.55
	part.Size = createVector(0.4, 24, 24)
	part.CFrame = CFrame.new(position2) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Parent = workspace.CurrentCamera
	Debris:AddItem(part, duration + 0.4)
	TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = createVector(0.4, 9.6, 9.6),
		Transparency = 0.08,
		Color = color
	}):Play()
	TweenService:Create(
		boltLight(position2 + createVector(0, 2, 0), 0, 20, duration + 0.1),
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Brightness = 5,
			Range = 34
		}
	):Play()

	if v10 then
		task.delay(duration * 0.55, function()
			groundSparks(position2, 3, 6, 0.3)
		end)
		task.delay(duration * 0.82, function()
			groundSparks(position2, 5, 9, 0.35)
		end)
	end

	task.delay(duration, function()
		impact(position2, v10, true, cloudId, v9)
	end)
	return position2
end

local function ambientStrike(position2: Vector3)
	local v9 = math.random() * 3.141592653589793 * 2
	local v10 = math.sqrt((math.random())) * 195 + 35
	local v12 = skyHit(position2 + Vector3.new(math.cos(v9) * v10, 0, math.sin(v9) * v10))

	if not v12 then
		return
	end

	impact(v12.Position, true, false, stormCloud(v12.Position), v12)
end

local function downpourParticle()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	for _, childName in v do
		ReplicatedStorage = ReplicatedStorage:FindFirstChild(childName)

		if not ReplicatedStorage then
			return nil
		end
	end

	if ReplicatedStorage:IsA("ParticleEmitter") then
		return ReplicatedStorage
	end

	return nil
end

local function downpour()
	local v9 = downpourParticle()

	if v9 then
		local Global = require(game.ReplicatedStorage.Global)

		if not Global.FastMode then
			local part = Instance.new("Part")
			part.Name = "TempleIntelRain"
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Locked = true
			part.Massless = true
			part.Transparency = 1
			part.Size = createVector(80, 80, 80)
			part.Parent = workspace.CurrentCamera
			local clone = v9:Clone()
			clone.Rate = 0
			clone.Enabled = true
			clone.Parent = part
			local sound = Instance.new("Sound")
			sound.Name = "Downpour"
			sound.SoundId = "rbxassetid://1516791621"
			sound.Looped = true
			sound.Volume = 0
			sound.Parent = part
			sound:Play()
			local raycastParams3 = RaycastParams.new()
			raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams3.IgnoreWater = true
			local children = { workspace.CurrentCamera }

			for _, childName in {
				"Characters",
				"Enemies",
				"NPCs",
				"_WorldOrigin"
			} do
				local child = workspace:FindFirstChild(childName)

				if child then
					table.insert(children, child)
				end
			end

			raycastParams3.FilterDescendantsInstances = children
			local v10 = 0
			maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
				local currentCamera = workspace.CurrentCamera

				if not (currentCamera and part.Parent) then
					return
				end

				local cFrame = currentCamera.CFrame
				local lookVector = cFrame.LookVector
				local Y = math.abs(lookVector.Y)
				local cross = lookVector:Cross(createVector(0, 1, 0))
				local unit

				if cross.Magnitude > 0.001 then
					unit = cross.Unit
				else
					unit = cFrame.RightVector
				end

				local v11 = (1 - Y) * 20 + 80
				part.Size = Vector3.new(80, 80, v11)
				part.CFrame = CFrame.fromMatrix(cFrame.Position, unit, createVector(0, 1, 0)) + (1 - Y) * lookVector * (v11 / 3) + Vector3.new(
					0,
					Y * 20,
					0
				)
				local v12 = workspace:Raycast(cFrame.Position, createVector(0, 500, 0), raycastParams3) ~= nil and 0 or 1
				local v13 = v12 < v10 and 0.18 or 1.1
				v10 = math.clamp(v10 + math.sign(v12 - v10) * (dt / v13), 0, 1)
				clone.Rate = v10 * 300
				sound.Volume = v10 * 0.35
			end))
			maid:GiveTask(function()
				TweenService:Create(clone, TweenInfo.new(1.1), {
					Rate = 0
				}):Play()
				TweenService:Create(sound, TweenInfo.new(1.1), {
					Volume = 0
				}):Play()
				Debris:AddItem(part, 1.7000000000000002)
			end)
		end
	end
end

local function huntStrike()
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	if not humanoidRootPart then
		return
	end

	local v9 = heat() -- equivalent call inferred; original call site unknown
	local v10 = v9 * -0.44999999999999996 + 1
	local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
	local v11 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z) * v10 * (v9 * 0.3500000000000001 + 0.7)

	if v11.Magnitude > 90 then
		v11 = v11.Unit * 90
	end

	local v12 = v9 * -16 + 22
	local v13 = math.random() * 3.141592653589793 * 2
	local v14 = math.sqrt((math.random())) * v12
	local v16 = strike(humanoidRootPart.Position + v11 + Vector3.new(math.cos(v13) * v14, 0, math.sin(v13) * v14), v10)
	task.delay(v10, function()
		if not (v3 and v4) then
			return
		end

		local character2 = Players.LocalPlayer.Character
		local humanoidRootPart2

		if character2 then
			humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
		end

		if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
			humanoidRootPart2 = nil
		end

		if humanoidRootPart2 then
			local character3 = Players.LocalPlayer.Character
			local humanoid

			if character3 then
				humanoid = character3:FindFirstChildOfClass("Humanoid")
			end

			local v17

			if humanoid == nil then
				v17 = false
			else
				v17 = humanoid.Health > 0
			end

			if v17 and not roofAbove(humanoidRootPart2.Position) then
				local v18 = humanoidRootPart2.Position - v16

				if Vector3.new(v18.X, 0, v18.Z).Magnitude > 13 or math.abs(v18.Y) > 14 then
					return
				end

				shock(v16)
				local v19 = v5

				if v19 then
					v19:FireServer("Struck")
				end
			end
		end
	end)
end

local function huntLoop()
	local v9 = os.clock() + 1.2

	while true do
		task.wait(0.25)

		if not v3 then
			break
		end

		local character = Players.LocalPlayer.Character
		local humanoidRootPart

		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end

		if not humanoidRootPart then
			continue
		end

		local character2 = Players.LocalPlayer.Character
		local humanoid

		if character2 then
			humanoid = character2:FindFirstChildOfClass("Humanoid")
		end

		local v10

		if humanoid == nil then
			v10 = false
		else
			v10 = humanoid.Health > 0
		end

		if not v10 then
			continue
		end

		if roofAbove(humanoidRootPart.Position) then
			v6 = math.max(0, v6 - 0.75)
			v9 = math.max(v9, os.clock() + 1.2)
		else
			v6 += 0.25

			if not (os.clock() < v9) then
				local v11 = heat() -- equivalent call inferred; original call site unknown
				huntStrike()
				v9 = os.clock() + (v11 * -2 + 4)
			end
		end
	end
end

local function startStorm()
	maid:DoCleaning()
	v3 = true
	v6 = 0
	now = os.clock()
	maid:GiveTask(function()
		v3 = false
	end)
	downpour()
	startCompass() -- equivalent call inferred; original call site unknown
	maid:GiveTask(task.spawn(huntLoop))
	maid:GiveTask(task.spawn(function()
		while true do
			local character = Players.LocalPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				Effect.new("ThunderGod.Storm"):play({
					Root = humanoidRootPart,
					Duration = 9,
					Range = 4000
				})
			end

			task.wait(3)
		end
	end))
	maid:GiveTask(task.spawn(function()
		while true do
			task.wait(0.3 + math.random() * 0.7)
			local Global = require(game.ReplicatedStorage.Global)

			if Global.FastMode then
				continue
			end

			for _ = 1, math.random(2, 5) do
				task.delay(math.random() * 0.55, function()
					local character = Players.LocalPlayer.Character
					local humanoidRootPart

					if character then
						humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					end

					if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
						humanoidRootPart = nil
					end

					if v3 and humanoidRootPart then
						ambientStrike(humanoidRootPart.Position)
					end
				end)
			end
		end
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopStorm()
	v3 = false
	v6 = 0
	now = 0
	maid:DoCleaning()
end

local raycastParams3 = RaycastParams.new()
raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
raycastParams3.RespectCanCollide = true
raycastParams3.IgnoreWater = true

local function groundedCFrameFor(position2: Vector3)
	local children = { workspace.CurrentCamera }

	for _, childName in { "Characters", "Enemies", "NPCs" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	raycastParams3.FilterDescendantsInstances = children
	local raycastResult = workspace:Raycast(
		position2 + createVector(0, 10, 0),
		createVector(0, -100, 0),
		raycastParams3
	)
	local position3

	if raycastResult then
		position3 = raycastResult.Position
	else
		position3 = position2 - createVector(0, 4, 0)
	end

	return CFrame.lookAt(position3, position3 + createVector(0, 0, 1))
end

local maid3 = Maid.new()
local v9 = false
local v10 = nil
local v11 = nil
local config = nil
local logic = nil

local function puzzleModule(childName: string)
	local moduleScript = script:FindFirstChild(childName)

	if not (moduleScript and moduleScript:IsA("ModuleScript")) then
		warn((`[Temple Intel] {childName} is missing from the client module`))
		return nil
	end

	local success, result = pcall(require, moduleScript)

	if success then
		return result
	end

	warn((`[Temple Intel] {childName} failed to load: {result}`))
	return nil
end

local function puzzleConfig()
	if not config then
		config = puzzleModule("PuzzleConfig")
	end

	return config
end

local function puzzleLogic()
	if not logic then
		logic = puzzleModule("PuzzleLogic")
	end

	return logic
end

local function relicHandoffDelay()
	if not config then
		config = puzzleModule("PuzzleConfig")
	end

	local v15 = not config and {} or config.RelicFinale or {}
	return (v15.ShakeTime or 0) + (v15.RiseTime or 0) + (v15.OrbitTime or 0) + (v15.BurstTime or 0) + (v15.ApproachTime or 0) + (v15.HoverTime or 0) + (v15.AlignTime or 0) + (v15.DropTime or 0) + (v15.BounceTime or 0)
end

local function relicCatchAt()
	if not config then
		config = puzzleModule("PuzzleConfig")
	end

	local v15 = not config and {} or config.RelicFinale or {}
	return (math.max(relicHandoffDelay() - (v15.BounceTime or 0) - (v15.CatchKeyTime or 0), 0))
end

local function relicCleanupAt()
	if not config then
		config = puzzleModule("PuzzleConfig")
	end

	local v15 = not config and {} or config.RelicFinale or {}
	return relicHandoffDelay() + (v15.CleanupTime or 0.35)
end

local function playCatchAnimation()
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local success, result = pcall(function()
		return Anims:Get(character, "rbxassetid://107104405666769")
	end)

	if not (success and result) then
		warn("[Temple Intel] catch animation failed to load")
		return
	end

	result.Priority = Enum.AnimationPriority.Action
	result:Play()
	maid3:GiveTask(function()
		if result.IsPlaying then
			result:Stop()
		end
	end)
end

local function clearPuzzle()
	v9 = false
	maid3:DoCleaning()
	Effect.new("TempleIntel.FinaleCamera"):play({
		Remove = true
	})
	Effect.new("TempleIntel.Finale"):play({
		Remove = true
	})
	Effect.new("TempleIntel.Relic"):play({
		Remove = true
	})
	Effect.new("TempleIntel.Beams"):play({
		Remove = true
	})
	Effect.new("TempleIntel.Puzzle"):play({
		Remove = true
	})
end

local function removeRelic(part)
	Effect.new("TempleIntel.Relic"):play({
		Remove = true
	})
	local parent = part.Parent

	if parent and parent:IsA("Model") then
		parent:Destroy()
	elseif part.Parent then
		part:Destroy()
	end
end

local function runFinale(p, part, ring)
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
		warn((`[Temple Intel] finale needs the relic part, got {typeof(part)}`))
		return
	end

	local v14 = p or v5
	local now2 = os.clock()
	local character = Players.LocalPlayer.Character

	if not config then
		config = puzzleModule("PuzzleConfig")
	end

	local config2 = config
	local position2 = part.Position
	local Util = require(game.ReplicatedStorage.Util)
	local v16 = "UpperSkySFX.BF_UpperSky_All_Pylons_Correct_Cutscene_01"
	local v17 = 100
	local v18 = 1
	local v19 = 1
	pcall(function()
		Util.Sound:Play(v16, position2, v17 or 260, v18, v19)
	end)
	Effect.new("TempleIntel.Relic"):play({
		Finale = true,
		StartedAt = now2
	})
	Effect.new("TempleIntel.Finale"):play({
		Relic = part,
		Ring = ring,
		StartedAt = now2,
		Config = config2
	})
	Effect.new("TempleIntel.FinaleCamera"):play({
		Relic = part,
		Centre = part.Position,
		StartedAt = now2,
		Config = config2
	})
	local v20 = not config2 and {} or config2.RelicFinale or {}
	local shakeTime = v20.ShakeTime or 0

	for _, v21 in {
		{
			At = 0,
			Sound = "Dragon.Rumble"
		},
		{
			At = shakeTime,
			Sound = "Diamond.DiamondShimmerCharge"
		},
		{
			At = shakeTime + (v20.RiseTime or 0) + (v20.OrbitTime or 0),
			Sound = "CursedDualKatanas.SparkExplosion"
		},
		{
			At = relicCatchAt(),
			Sound = "Chests.CoinCollect1"
		}
	} do
		local v22 = v21
		task.delay(v21.At, function()
			if v9 and v5 == v14 and part.Parent then
				local sound = v22.Sound
				local position3 = part.Position
				local Util2 = require(game.ReplicatedStorage.Util)
				local v23 = 220
				local v24 = 1
				local v25 = 1
				pcall(function()
					Util2.Sound:Play(sound, position3, v23 or 260, v24, v25)
				end)
			end
		end)
	end

	task.spawn(function()
		task.wait((relicCatchAt()))

		if v9 and not flag then
			local character2 = Players.LocalPlayer.Character
			local humanoid

			if character2 then
				humanoid = character2:FindFirstChildOfClass("Humanoid")
			end

			local v21

			if humanoid == nil then
				v21 = false
			else
				v21 = humanoid.Health > 0
			end

			if v21 and Players.LocalPlayer.Character == character then
				playCatchAnimation()
			end
		end
	end)
	task.spawn(function()
		task.wait((relicHandoffDelay()))
		local v21 = os.clock() + 8

		while v14 and not flag and v5 == v14 and v9 do
			local character2 = Players.LocalPlayer.Character
			local humanoid

			if character2 then
				humanoid = character2:FindFirstChildOfClass("Humanoid")
			end

			local v22

			if humanoid == nil then
				v22 = false
			else
				v22 = humanoid.Health > 0
			end

			if not v22 then
				break
			end

			if v14:InvokeServer("TakeIntel") == true then
				flag = true
				break
			end

			if v21 <= os.clock() then
				break
			else
				task.wait(1.5)
			end
		end

		if flag then
			task.wait((math.max(relicCleanupAt() - relicHandoffDelay(), 0)))
			removeRelic(part)
		elseif v5 == v14 and v9 then
			clearPuzzle()
		end
	end)
end

local function revealPuzzle(p, position2: Vector3?, flag3: boolean)
	if v9 or flag then
		return
	end

	if not position2 then
		local gem = script:FindFirstChild("Gem")

		if gem then
			if not gem:IsA("BasePart") then
				gem = gem:FindFirstChildWhichIsA("BasePart", true)
			end
		else
			gem = nil
		end

		if gem then
			position2 = gem.Position
		else
			position2 = nil
		end
	end

	if not position2 then
		warn("[Temple Intel] no gem position to place the puzzle at")
		return
	end

	clearPuzzle()
	v9 = true
	v7 = flag3

	if not config then
		config = puzzleModule("PuzzleConfig")
	end

	local config2 = config
	local origin

	if config2 and typeof(config2.Origin) == "CFrame" then
		origin = config2.Origin
	else
		origin = groundedCFrameFor(position2)
	end

	local v15 = p or v5
	position = origin.Position
	local templeIntelPuzzle = Effect.new("TempleIntel.Puzzle")
	local v16 = {
		Origin = origin,
		Config = config2,
		Logic = 0,
		OnReady = 0,
		OnSolved = 0,
		OnPowerDown = 0
	}

	if not logic then
		logic = puzzleModule("PuzzleLogic")
	end

	v16.Logic = logic

	function v16.OnReady(relic, ring, instance)
		if not v9 then
			instance:Destroy()
			return
		end

		maid3:GiveTask(instance)
		local templeIntelRelic = Effect.new("TempleIntel.Relic")
		local v17 = {
			Relic = relic,
			Ring = ring,
			Config = 0
		}

		if not config then
			config = puzzleModule("PuzzleConfig")
		end

		v17.Config = config
		templeIntelRelic:play(v17)
		local templeIntelBeams = Effect.new("TempleIntel.Beams")

		if not config then
			config = puzzleModule("PuzzleConfig")
		end

		templeIntelBeams:play({
			Config = config
		})
		v10 = loopSound("Pylon_Room_Laser_Ambience_Loop_01", origin.Position, 0.5, 12, 1.2)
		v11 = loopSound("BF_UpperSky_Floating_Blue_Orb_Aura_01", relic, 0.6, 6, 0.6)
		maid3:GiveTask(function()
			local v19 = v10

			if v19 then
				local Util = require(game.ReplicatedStorage.Util)
				local v20 = 0.8
				pcall(function()
					Util.Sound:FadeOut(v19, v20)
				end)
			end

			local v20 = v11

			if v20 then
				local Util = require(game.ReplicatedStorage.Util)
				local v21 = 0.5
				pcall(function()
					Util.Sound:FadeOut(v20, v21)
				end)
			end

			v10 = nil
			v11 = nil
		end)

		if flag3 then
			maid3:GiveTask(task.spawn(function()
				while v9 and not flag do
					local character = Players.LocalPlayer.Character
					local humanoidRootPart

					if character then
						humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					end

					if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
						humanoidRootPart = nil
					end

					if humanoidRootPart and (humanoidRootPart.Position - origin.Position).Magnitude <= 34 then
						runFinale(v15, relic, ring)
						break
					else
						task.wait(0.4)
					end
				end
			end))
		end
	end

	function v16.OnSolved(relic, ring)
		v7 = true

		if v15 then
			v15:FireServer("Solved")
		end

		runFinale(v15, relic, ring)
	end

	function v16.OnPowerDown()
		Effect.new("TempleIntel.Finale"):play({
			PowerDown = true
		})
		local v17 = v10

		if v17 then
			local Util = require(game.ReplicatedStorage.Util)
			local v18 = 0.8
			pcall(function()
				Util.Sound:FadeOut(v17, v18)
			end)
		end

		v10 = nil
	end

	templeIntelPuzzle:play(v16)
	startCompass() -- equivalent call inferred; original call site unknown
end

local function thought(p: string)
	local DialogueController = require(game.ReplicatedStorage.DialogueController)

	if DialogueController.Active then
		return false
	end

	local displayName = Players.LocalPlayer.DisplayName
	local v14 = DialogueController.new()
	v14:setTitle(displayName)
	v14:addPage("Main", function(object)
		object:setTitle(displayName)
		object:addText(p)
	end)
	task.spawn(DialogueController.start, v14:build())
	return true
end

local function templeWall()
	local workspace2 = workspace

	for _, childName in v2 do
		if workspace2 then
			workspace2 = workspace2:FindFirstChild(childName)
		else
			workspace2 = nil
		end
	end

	return workspace2
end

local function wallStanding(folder)
	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") and part.Transparency < 1 and part.LocalTransparencyModifier < 1 then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchHints(maid4)
	maid2:DoCleaning()

	if maid4.Completed then
		return
	end

	local v14 = false
	local v15 = false
	maid2:GiveTask(task.spawn(function()
		while not (v14 and v15) do
			task.wait(0.5)
			local character = Players.LocalPlayer.Character
			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				humanoidRootPart = nil
			end

			if not humanoidRootPart or v5 ~= maid4 or maid4.Completed then
				continue
			end

			local workspace2

			if not v14 then
				workspace2 = workspace

				for _, childName in v2 do
					if workspace2 then
						workspace2 = workspace2:FindFirstChild(childName)
					else
						workspace2 = nil
					end
				end
			end

			if workspace2 and workspace2:IsA("Model") and (workspace2:GetPivot().Position - humanoidRootPart.Position).Magnitude <= 40 and wallStanding(workspace2) then
				v14 = thought("This wall seems a bit brittle... Maybe I can break through.")
			end

			if v15 or not v9 or v7 or not position then
				continue
			end

			if not ((position - humanoidRootPart.Position).Magnitude <= 45) then
				continue
			end

			v15 = thought("The orb seems to have a mind of its own, and it doesn't seem to react unless you configure it...")
		end
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearQuestProps()
	v4 = false
	stopStorm() -- equivalent call inferred; original call site unknown
	stopCompass() -- equivalent call inferred; original call site unknown
	clearPuzzle()
	flag = false
	position = nil
end

local TempleIntel = {}

function TempleIntel.OnLoad(maid4)
	v5 = maid4
	clearQuestProps() -- equivalent call inferred; original call site unknown
	maid4:GiveTask(maid)
	maid4:GiveTask(maid3)
	maid4:GiveTask(maid2)
	maid4:GiveTask(clearQuestProps)
	watchHints(maid4) -- equivalent call inferred; original call site unknown
end

TempleIntel.RemoteEvents = {
	Reveal = function(p, p2, p3)
		v5 = p or v5
		local v15 = p or v5

		if typeof(p2) ~= "Vector3" then
			p2 = nil
		end

		revealPuzzle(v15, p2, p3 == true)
	end,
	Storm = function(p, p2, p3)
		v5 = p or v5

		if typeof(p3) == "Vector3" then
			v8 = p3
		end

		if p2 == true then
			v4 = true

			if not v3 then
				local Util = require(game.ReplicatedStorage.Util)
				local cameraShaker = Util.CameraShaker
				local v14 = 12
				local v15 = 6
				local v16 = 0.1
				local v17 = 1.6
				pcall(function()
					cameraShaker:ShakeOnce(v14, v15, v16, v17, createVector(1, 1, 1), createVector(1, 1, 2))
				end)
				local character = Players.LocalPlayer.Character
				local humanoidRootPart

				if character then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				end

				if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
					humanoidRootPart = nil
				end

				if humanoidRootPart then
					local position2 = humanoidRootPart.Position
					local Util2 = require(game.ReplicatedStorage.Util)
					local v18 = "LowerSkyBonusMomentSFX.BF_LowerSky_Dark_Storm_Spawns_01"
					local v19 = 400
					local v20 = 1
					local v21 = 1
					pcall(function()
						Util2.Sound:Play(v18, position2, v19 or 260, v20, v21)
					end)
				end

				startStorm()
			end
		else
			v4 = false
			stopStorm() -- equivalent call inferred; original call site unknown
		end
	end,
	Dropped = function(p)
		v5 = p or v5
		v4 = false
		stopStorm() -- equivalent call inferred; original call site unknown
		clearPuzzle()
		flag = false
	end,
	Clear = function(_)
		clearQuestProps() -- equivalent call inferred; original call site unknown
	end
}

function TempleIntel.OnComplete(_, _, _)
	maid2:DoCleaning()
	clearQuestProps() -- equivalent call inferred; original call site unknown
	v5 = nil
end

return TempleIntel