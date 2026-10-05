-- failed to load script (decompiled with syntax error):
-- ptSrqvyhWILQaBBBvNgjLkBIu:210: Expected identifier when parsing expression, got ';'

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local LightingController = require(ReplicatedStorage.client.legacyControllers.LightingController)
local localPlayer = Players.LocalPlayer
local color = Color3.fromRGB(180, 200, 255)
local v = false
local zonePart = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local tweens = {}
local connection = nil
local v6 = Component.new({
	Tag = "HadesBlindnessZone",
	Ancestors = { Workspace }
})

local function cancelTweens()
	for _, v7 in tweens do
		v7:Cancel()
		v7:Destroy()
	end

	table.clear(tweens)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tweenProperty(p, p2, duration: number)
	local tween = TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p2)
	table.insert(tweens, tween)
	tween:Play()
	return tween
end

local function hasLantern()
	local success, result = pcall(legacyLocalPlayerData.fetch)

	if not (success and result) then
		return false
	end

	local stats = result:FindFirstChild("Stats")
	local hasbodylantern = stats and stats:FindFirstChild("hasbodylantern")
	local lanterntype = hasbodylantern and hasbodylantern:FindFirstChild("lanterntype")
	return lanterntype ~= nil and lanterntype.Value == "Styx Lantern"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRootPart()
	local character = localPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart") or nil
end

local function ensureVignette()
	if v2 and v2.Parent and v3 then
		return v3
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HadesBlindnessVignette"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 900
	screenGui.ResetOnSpawn = false
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	imageLabel.BackgroundTransparency = 0.4
	imageLabel.Image = "rbxassetid://84483216486599"
	imageLabel.ImageColor3 = Color3.new(0, 0, 0)
	imageLabel.ImageTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Stretch
	imageLabel.ZIndex = 100
	imageLabel.Parent = screenGui
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
	v2 = screenGui
	v3 = imageLabel
	return imageLabel
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureColorCorrection()
	if v5 and v5.Parent then
		return v5
	end

	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "HadesBlindnessCC"
	colorCorrectionEffect.Brightness = 0
	colorCorrectionEffect.Contrast = 0
	colorCorrectionEffect.Saturation = 0
	colorCorrectionEffect.TintColor = Color3.new(1, 1, 1)
	colorCorrectionEffect.Parent = Lighting
	v5 = colorCorrectionEffect
	return colorCorrectionEffect
end

local function ensurePlayerLight()
	local rootPart = getRootPart() -- equivalent call inferred; original call site unknown

	if not rootPart then
		return nil
	end

	if v4 and v4.Parent then
		return v4
	end

	local pointLight = Instance.new("PointLight")
	pointLight.Name = "HadesBlindnessLight"
	pointLight.Color = color
	pointLight.Range = 0
	pointLight.Brightness = 0
	pointLight.Shadows = true
	pointLight.Parent = rootPart
	v4 = pointLight
	return pointLight
end

local function applyBlindness(flag: boolean)
	cancelTweens()
	local colorCorrection = ensureColorCorrection() -- equivalent call inferred; original call site unknown
	local rootPart = getRootPart() -- equivalent call inferred; original call site unknown
	local v7

	if rootPart then
		if v4 and v4.Parent then
			v7 = v4
		else
			v7 = Instance.new("PointLight")
			v7.Name = "HadesBlindnessLight"
			v7.Color = color
			v7.Range = 0
			v7.Brightness = 0
			v7.Shadows = true
			v7.Parent = rootPart
			v4 = v7
		end
	end

	local vignette = ensureVignette()

	if connection then
		connection:Disconnect()
		connection = nil
	end

	connection = LightingController.HookLighting:BindAtPriority(10000, function(p)
		local atmosphere = p.Atmosphere
		atmosphere.Color = Color3.new()
		atmosphere.Decay = Color3.new()
		atmosphere.Glare = 0
		atmosphere.Haze = 10
		atmosphere.Density = 0.5
	end)
	local v8 = {
		Brightness = flag and -0.35 or -0.5,
		Contrast = flag and 0.08 or 0.1,
		Saturation = flag and -0.08 or -0.15,
		TintColor = 0
	}
	local tintColor

	if flag then
		tintColor = Color3.fromRGB(175, 185, 205)
	else
		tintColor = Color3.fromRGB(160, 170, 195)
	end

	v8.TintColor = tintColor
	tweenProperty(colorCorrection, v8, 1) -- equivalent call inferred; original call site unknown

	if v7 then
		local tween = TweenService:Create(v7, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Range = flag and 75 or 32,
			Brightness = flag and 3.5 or 1.8
		})
		table.insert(tweens, tween)
		tween:Play()
	end

	local tween = TweenService:Create(vignette, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		ImageTransparency = flag and 0.4 or 0.05,
		BackgroundTransparency = flag and 0.75 or 0.45
	})
	table.insert(tweens, tween)
	tween:Play()
end

local function removeBlindness()
	cancelTweens()

	if connection then
		connection:Disconnect()
		connection = nil
	end

	if v5 and v5.Parent then
		;(tweenProperty(v5, {
			Brightness = 0,
			Contrast = 0,
			Saturation = 0,
			TintColor = Color3.new(1, 1, 1)
		}, 1)).Completed:Once(function()
			if v5 and v5.Parent and not v then
				v5:Destroy()
				v5 = nil
			end
		end)
	end

	if v4 and v4.Parent then
		local tween = TweenService:Create(v4, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Range = 0,
			Brightness = 0
		})
		table.insert(tweens, tween)
		tween:Play()
		tween.Completed:Once(function()
			if v4 and v4.Parent and not v then
				v4:Destroy()
				v4 = nil
			end
		end)
	end

	if v3 and v3.Parent then
		local tween = TweenService:Create(v3, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			ImageTransparency = 1,
			BackgroundTransparency = 1
		})
		table.insert(tweens, tween)
		tween:Play()
		tween.Completed:Once(function()
			if v2 and v2.Parent and not v then
				v2:Destroy()
				v2 = nil
				v3 = nil
			end
		end)
	end
end

local function isPointInsidePart(vector: Vector3, instance)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(vector)
	local v7 = instance.Size * 0.5
	return math.abs(pointToObjectSpace.X) <= v7.X and math.abs(pointToObjectSpace.Y) <= v7.Y and math.abs(pointToObjectSpace.Z) <= v7.Z
end

function v6:Construct()
	self.trove = Trove.new()
	local instance = self.Instance

	if not instance:IsA("BasePart") then
		return
	end

	self.zonePart = instance
	self.zonePart.Transparency = 1
	self.zonePart.CanCollide = false
end

function v6.Start(p)
	if not p.zonePart then
		return
	end

	local total = 0
	p.trove:Add(RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total < 0.1 then
			return
		end

		total = 0
		local rootPart = getRootPart() -- equivalent call inferred; original call site unknown

		if not rootPart then
			return
		end

		local position = rootPart.Position
		local zonePart2 = p.zonePart
		local pointToObjectSpace = zonePart2.CFrame:PointToObjectSpace(position)
		local v7 = zonePart2.Size * 0.5
		local v8

		if math.abs(pointToObjectSpace.X) <= v7.X and math.abs(pointToObjectSpace.Y) <= v7.Y then
			v8 = math.abs(pointToObjectSpace.Z) <= v7.Z
		else
			v8 = false
		end

		if v8 and not v then
			v = true
			zonePart = p.zonePart
			applyBlindness(hasLantern())
		elseif not v8 and v and zonePart == p.zonePart then
			v = false
			zonePart = nil
			removeBlindness()
		end
	end))
	p.trove:Add(localPlayer.CharacterAdded:Connect(function()
		if v and zonePart == p.zonePart then
			task.wait(0.5)
			v4 = nil
			applyBlindness(hasLantern())
		end
	end))
	task.spawn(function()
		local fetched = legacyLocalPlayerData.fetch()

		if fetched then
			local stats = fetched:WaitForChild("Stats")
			local hasbodylantern = stats and stats:WaitForChild("hasbodylantern")
			local lanterntype = hasbodylantern and hasbodylantern:WaitForChild("lanterntype")

			if lanterntype and lanterntype:IsA("ValueBase") then
				p.trove:Add(lanterntype.Changed:Connect(function()
					if v and zonePart == p.zonePart then
						applyBlindness(hasLantern())
					end
				end))
			end
		end
	end)
end

function v6.Stop(p)
	if v and zonePart == p.zonePart then
		v = false
		zonePart = nil
		removeBlindness()
	end

	p.trove:Clean()
end

return v6