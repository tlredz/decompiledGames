local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local Maid = require(ReplicatedStorage.Util.Maid)
require(ReplicatedStorage.Util)
local maid = Maid.new()
local maid2 = Maid.new()
local flag = false
local v = nil
local numberValue = nil
local renderSteppedConnection = nil
local v2 = nil
local v3 = nil
local count = 0
local eventConnection = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local count2 = 0
local v9 = {
	Soft = {
		ClockTime = 5.4,
		Brightness = 3.6,
		Ambient = Color3.fromRGB(175, 145, 145),
		OutdoorAmbient = Color3.fromRGB(135, 115, 115),
		EnvironmentDiffuseScale = 0.78,
		EnvironmentSpecularScale = 0.7
	},
	Intense = {
		ClockTime = 1.4,
		Brightness = 3.3,
		Ambient = Color3.fromRGB(185, 95, 105),
		OutdoorAmbient = Color3.fromRGB(115, 65, 75),
		EnvironmentDiffuseScale = 0.65,
		EnvironmentSpecularScale = 0.58
	},
	Scary = {
		ClockTime = 0.2,
		Brightness = 1.6,
		Ambient = Color3.fromRGB(60, 10, 10),
		OutdoorAmbient = Color3.fromRGB(45, 8, 8),
		EnvironmentDiffuseScale = 0.4,
		EnvironmentSpecularScale = 0.35
	}
}

local function makePillar(parent, cframe: CFrame)
	local position = cframe.Position
	local part = Instance.new("Part")
	part.Name = "RedSkyPillar"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Shape = Enum.PartType.Cylinder
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Transparency = 0.35
	part.Size = createVector(65, 6000, 65)
	part.CFrame = CFrame.new(position + createVector(0, 3000, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Parent = parent
	local part2 = Instance.new("Part")
	part2.Name = "BlackSkyPillar"
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanTouch = false
	part2.CanQuery = false
	part2.Shape = Enum.PartType.Cylinder
	part2.Material = Enum.Material.Neon
	part2.Color = Color3.fromRGB(0, 0, 0)
	part2.Transparency = 0.15
	part2.Size = createVector(35, 6005, 35)
	part2.CFrame = CFrame.new(position + createVector(0, 3000, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
	part2.Parent = parent
	local pointLight = Instance.new("PointLight")
	pointLight.Name = "DogHouseRedGlow"
	pointLight.Color = Color3.fromRGB(255, 0, 0)
	pointLight.Brightness = 8
	pointLight.Range = 700
	pointLight.Parent = part
	task.spawn(function()
		while part.Parent do
			TweenService:Create(part, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Transparency = 0.15,
				Size = createVector(80, 6000, 80)
			}):Play()
			TweenService:Create(part2, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Transparency = 0.05,
				Size = createVector(45, 6005, 45)
			}):Play()
			task.wait(0.45)
			TweenService:Create(part, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Transparency = 0.4,
				Size = createVector(60, 6000, 60)
			}):Play()
			TweenService:Create(part2, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Transparency = 0.18,
				Size = createVector(30, 6005, 30)
			}):Play()
			task.wait(0.45)
		end
	end)
end

local function makeAngryBillboard(folder, center: CFrame)
	local part = Instance.new("Part")
	part.Name = "AngryEmojiAnchor"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = center * CFrame.new(0, 15, 0)
	part.Parent = folder
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "AngryDogHouseEmoji"
	billboardGui.Adornee = part
	billboardGui.AlwaysOnTop = true
	billboardGui.MaxDistance = 25000
	billboardGui.Size = UDim2.fromOffset(180, 180)
	billboardGui.Enabled = true
	billboardGui.Parent = part
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(0.82, 0.82)
	textLabel.Position = UDim2.fromScale(0.09, 0.09)
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.Text = "😡"
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0.25
	textLabel.TextStrokeColor3 = Color3.fromRGB(80, 0, 0)
	textLabel.ZIndex = 2
	textLabel.Parent = billboardGui
	maid:GiveTask(task.spawn(function()
		local map = workspace:FindFirstChild("Map")

		while part.Parent and billboardGui.Parent do
			task.wait(0.15)
			local character = localPlayer.Character
			local position = character and character:GetPivot().Position

			if not position then
				continue
			end

			map = map or workspace:FindFirstChild("Map")

			if not map then
				continue
			end

			local doghouseDimension = map:FindFirstChild("doghouseDimension")

			if doghouseDimension then
				local bossSpawns = doghouseDimension:FindFirstChild("BossSpawns")
				local part2 = bossSpawns and bossSpawns:FindFirstChild("Part", true)

				if part2 and part2:IsA("BasePart") then
					billboardGui.Enabled = (position - part2.Position).Magnitude > 2000
				else
					billboardGui.Enabled = true
				end
			else
				billboardGui.Enabled = true
			end
		end
	end))
end

local function makeRift(_, _: CFrame) end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapshotLighting()
	return {
		ClockTime = Lighting.ClockTime,
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
		EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
	}
end

local function applyLightingBlend(value: number)
	local v10 = v5
	local v11 = v6

	if not (v10 and v11) then
		return
	end

	Lighting.ClockTime = v10.ClockTime + (v11.ClockTime - v10.ClockTime) * value
	Lighting.Brightness = v10.Brightness + (v11.Brightness - v10.Brightness) * value
	Lighting.Ambient = v10.Ambient:Lerp(v11.Ambient, value)
	Lighting.OutdoorAmbient = v10.OutdoorAmbient:Lerp(v11.OutdoorAmbient, value)
	Lighting.EnvironmentDiffuseScale = v10.EnvironmentDiffuseScale + (v11.EnvironmentDiffuseScale - v10.EnvironmentDiffuseScale) * value
	Lighting.EnvironmentSpecularScale = v10.EnvironmentSpecularScale + (v11.EnvironmentSpecularScale - v10.EnvironmentSpecularScale) * value
end

local function tweenLightingTo(p, duration: number)
	count += 1
	v5 = snapshotLighting()
	v6 = p

	if v then
		v:Cancel()
		v = nil
	end

	if numberValue then
		numberValue:Destroy()
		numberValue = nil
	end

	numberValue = Instance.new("NumberValue")
	numberValue.Value = 0

	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if numberValue then
				applyLightingBlend(numberValue.Value)
			end
		end)
	end

	v = TweenService:Create(numberValue, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = 1
	})
	v:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function makeLighting(lightingPreset: string?)
	if not v4 then
		v4 = snapshotLighting()
	end

	tweenLightingTo(v9[lightingPreset or "Soft"] or v9.Soft, 1.5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreLighting()
	if not v4 then
		return
	end

	tweenLightingTo(v4, 1.5)
	local v10 = v

	if not v10 then
		return
	end

	v10.Completed:Once(function()
		if v ~= v10 then
			return
		end

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		if numberValue then
			numberValue:Destroy()
			numberValue = nil
		end

		v = nil
		v5 = nil
		v6 = nil
		v4 = nil
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSkyColorCorrection()
	if v7 and v7.Parent then
		return v7
	end

	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "DogHouseSkyCC"
	colorCorrectionEffect.Enabled = true
	colorCorrectionEffect.Parent = Lighting
	v7 = colorCorrectionEffect
	return colorCorrectionEffect
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startSkyRandom()
	count2 += 1
	local v10 = count2
	local skyColorCorrection = getSkyColorCorrection() -- equivalent call inferred; original call site unknown
	task.spawn(function()
		local lastTime = os.clock()

		while count2 == v10 and os.clock() - lastTime < 3 do
			TweenService:Create(skyColorCorrection, TweenInfo.new(0.18, Enum.EasingStyle.Linear), {
				TintColor = Color3.fromHSV(math.random(), 0.85, 1)
			}):Play()
			task.wait(0.2)
		end
	end)
end

local function startSkyScary()
	count2 += 1
	local skyColorCorrection = getSkyColorCorrection() -- equivalent call inferred; original call site unknown
	TweenService:Create(skyColorCorrection, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		TintColor = Color3.fromRGB(255, 70, 70),
		Brightness = -0.05,
		Contrast = 0.15,
		Saturation = -0.1
	}):Play()

	if not (v8 and v8.Parent) then
		local atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = "DogHouseScaryFog"
		atmosphere.Density = 0.42
		atmosphere.Offset = 0.1
		atmosphere.Color = Color3.fromRGB(90, 15, 15)
		atmosphere.Decay = Color3.fromRGB(60, 5, 5)
		atmosphere.Glare = 0.3
		atmosphere.Haze = 2.4
		local lightingLayers = Lighting:FindFirstChild("LightingLayers")

		if lightingLayers then
			atmosphere:SetAttribute("ZIndex", 1000002)
			local numberValue2 = Instance.new("NumberValue")
			numberValue2.Name = "Intensity"
			numberValue2.Value = 0
			numberValue2.Parent = atmosphere
			atmosphere.Parent = lightingLayers
			TweenService:Create(numberValue2, TweenInfo.new(2, Enum.EasingStyle.Sine), {
				Value = 1
			}):Play()
		else
			atmosphere.Parent = Lighting
		end

		v8 = atmosphere
	end

	if not v4 then
		v4 = snapshotLighting()
	end

	local scary = v9.Scary or v9.Soft
	tweenLightingTo(scary, 1.5)
end

local function restoreSky()
	count2 += 1

	if v7 then
		local v10 = v7
		TweenService:Create(v10, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
			TintColor = Color3.new(1, 1, 1),
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		}):Play()
		task.delay(1.6, function()
			if v10 then
				v10:Destroy()
			end
		end)
		v7 = nil
	end

	if v8 then
		local v10 = v8
		local intensity = v10:FindFirstChild("Intensity")

		if intensity and intensity:IsA("NumberValue") then
			TweenService:Create(intensity, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
				Value = 0
			}):Play()
			task.delay(1.6, function()
				if v10 then
					v10:Destroy()
				end
			end)
		else
			v10:Destroy()
		end

		v8 = nil
	end
end

local function applyDogHouseMusicMuted()
	local v10 = v2

	if not (v10 and v10.Parent) then
		return
	end

	local Global = require(game.ReplicatedStorage.Global)
	local v11

	if Global.isMusicMuted == nil then
		v11 = false
	else
		v11 = Global.isMusicMuted() == true
	end

	if v11 then
		v10:Pause()
	else
		v10:Resume()
	end
end

local function playDogHouseMusic(p: string)
	pcall(function()
		_G.updateMusic2(true)
	end)
	local Sound = require(game.ReplicatedStorage.Util.Sound)
	local v10 = Sound:Play(p)
	v10.Parent = workspace
	v2 = v10
	v3 = p
	maid2:GiveTask(v10)
	applyDogHouseMusicMuted()

	if not eventConnection then
		local Global = require(game.ReplicatedStorage.Global)
		local musicMutedChanged = Global.MusicMutedChanged

		if musicMutedChanged then
			eventConnection = musicMutedChanged.Event:Connect(applyDogHouseMusicMuted)
			maid2:GiveTask(eventConnection)
			maid2:GiveTask(function()
				eventConnection = nil
			end)
		end
	end
end

local function isInDogHouse()
	return localPlayer:HasTag("DogHouseIndra")
end

local function start(p)
	if flag then
		return
	end

	flag = true
	local dogHouseAdminAbuseEnvironment = workspace:FindFirstChild("DogHouseAdminAbuseEnvironment")

	if dogHouseAdminAbuseEnvironment then
		dogHouseAdminAbuseEnvironment:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = "DogHouseAdminAbuseEnvironment"
	folder.Parent = workspace
	maid:GiveTask(folder)
	local center = p.Center or CFrame.new(0, 20, 0)

	if typeof(center) == "Vector3" then
		center = CFrame.new(center)
	end

	if not v4 then
		local lightingPreset = p.LightingPreset or "Soft"
		makeLighting(lightingPreset) -- equivalent call inferred; original call site unknown
	end

	makeAngryBillboard(folder, center)

	if not (v2 and v2.Parent) then
		task.spawn(playDogHouseMusic, "DH_Phase1")
	end

	maid:GiveTask(RunService.RenderStepped:Connect(function()
		local dogHouseAdminAbuseEnvironment2 = workspace:FindFirstChild("DogHouseAdminAbuseEnvironment")

		if not dogHouseAdminAbuseEnvironment2 then
			return
		end

		local dogHouseRift = dogHouseAdminAbuseEnvironment2:FindFirstChild("DogHouseRift")

		if dogHouseRift and dogHouseRift:IsA("BasePart") then
			dogHouseRift.CFrame *= CFrame.Angles(0, 0.026179938779914945, 0)
		end

		local dogHouseRiftRing = dogHouseAdminAbuseEnvironment2:FindFirstChild("DogHouseRiftRing")

		if dogHouseRiftRing and dogHouseRiftRing:IsA("BasePart") then
			dogHouseRiftRing.CFrame *= CFrame.Angles(0.03490658503988659, 0, 0)
		end
	end))
end

return function(p)
	if p.Stage == "Start" then
		if maid then
			maid:DoCleaning()
		end

		maid = Maid.new()
		flag = false
		start(p)
	elseif p.Stage == "CutsceneStart" then
		if not v4 then
			local lightingPreset = p.LightingPreset or "Soft"
			makeLighting(lightingPreset) -- equivalent call inferred; original call site unknown
		end

		if not (v2 and v2.Parent) then
			task.spawn(playDogHouseMusic, "DH_Phase1")
		end
	elseif p.Stage == "SkyRandom" then
		startSkyRandom() -- equivalent call inferred; original call site unknown
	elseif p.Stage == "SkyScary" then
		startSkyScary()
	elseif p.Stage == "SkyRestore" then
		restoreSky()
		makeLighting() -- equivalent call inferred; original call site unknown
	elseif p.Stage == "Lighting" then
		if localPlayer:HasTag("DogHouseIndra") then
			local lightingPreset = p.LightingPreset or "Soft"
			makeLighting(lightingPreset) -- equivalent call inferred; original call site unknown

			if lightingPreset == "Intense" and v3 ~= "DH_Phase2" then
				if v2 then
					v2:Stop()
					v2:Destroy()
					v2 = nil
				end

				task.spawn(playDogHouseMusic, "DH_Phase2")
			end
		end
	elseif p.Stage == "End" then
		flag = false

		if v2 then
			v2:Stop()
		end

		v2 = nil
		v3 = nil
		maid2:DoCleaning()
		task.spawn(function()
			pcall(function()
				_G.updateMusic2(false)
			end)
		end)
		restoreSky()
		restoreLighting() -- equivalent call inferred; original call site unknown

		if maid then
			maid:DoCleaning()
		end
	end
end