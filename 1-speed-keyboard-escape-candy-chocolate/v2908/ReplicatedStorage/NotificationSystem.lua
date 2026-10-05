local createVector = vector.create
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local remo = require(ReplicatedStorage.Packages.remo)
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local SoundManager = require(ReplicatedStorage:WaitForChild("SoundManager"))
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
local UpgradeMultipliers = require(ReplicatedStorage._FRAMEWORK.Libraries.UpgradeMultipliers)
local Items = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("Items"))
local WinsTrophyFlyEffect = require(ReplicatedStorage.WinsTrophyFlyEffect)
local revive = require(ReplicatedStorage._FRAMEWORK.Features.revive)
local localPlayer = RunService:IsClient() and Players.LocalPlayer
local playerGui = RunService:IsClient() and localPlayer:WaitForChild("PlayerGui")
local NotificationSystem = {}

local function assertClientMethod(p: string)
	assert(
		RunService:IsClient(),
		"NotificationSystem:" .. p .. " may not be called on the server. Use the server API methods instead."
	)
end

local v = nil

local function getMainGUI(value: number?)
	if v and v.Parent then
		return v
	end

	local v2 = value or 0

	for _ = 0, v2 do
		local tagged = CollectionService:GetTagged("MainGUI")

		for _, v3 in ipairs(tagged) do
			if not v3:IsDescendantOf(playerGui) then
				continue
			end

			v = v3
			return v3
		end

		if v2 > 0 then
			task.wait(0.2)
		end
	end

	return nil
end

local function formatXP(p)
	return Numbers.formatNumber(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatWinNotificationText(p: number)
	return "+" .. Numbers.formatNumber(p) .. " " .. Config.GetWinsLabel(p) .. "!"
end

function NotificationSystem.ShowMessage(_, text, p)
	assert(
		RunService:IsClient(),
		"NotificationSystem:ShowMessage may not be called on the server. Use the server API methods instead."
	)
	local mainGUI = getMainGUI(10)

	if not mainGUI then
		return
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "CenterMessage"
	textLabel.Size = UDim2.new(0.6, 0, 0.06, 0)
	textLabel.Position = UDim2.new(0.5, 0, 0.35, 0)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = p or Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.Parent = mainGUI
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint", textLabel)
	uITextSizeConstraint.MaxTextSize = 35
	local uIStroke = Instance.new("UIStroke", textLabel)
	uIStroke.Color = Color3.fromRGB(0, 0, 0)
	uIStroke.Thickness = 2.5
	local uIScale = Instance.new("UIScale", textLabel)
	uIScale.Scale = 0.7
	TweenService:Create(uIScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	TweenService:Create(textLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.3, 0)
	}):Play()
	task.delay(Config.DURATIONS.MESSAGE or 2, function()
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(textLabel, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.25, 0),
			TextTransparency = 1
		}):Play()
		TweenService:Create(uIStroke, tweenInfo, {
			Transparency = 1
		}):Play()
		task.delay(0.5, function()
			textLabel:Destroy()
		end)
	end)
end

function NotificationSystem.ShowLevelUp(_, _, p)
	assert(
		RunService:IsClient(),
		"NotificationSystem:ShowLevelUp may not be called on the server. Use the server API methods instead."
	)
	local mainGUI = getMainGUI(10)

	if not mainGUI then
		return
	end

	SoundManager:Play("LEVEL_UP")
	local frame = Instance.new("Frame")
	frame.Name = "LevelUpNotification"
	frame.Size = UDim2.new(0.6, 0, 0.2, 0)
	frame.Position = UDim2.new(0.5, 0, 0.45, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Parent = mainGUI
	local uIListLayout = Instance.new("UIListLayout", frame)
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Padding = UDim.new(0.05, 0)
	local uIScale = Instance.new("UIScale", frame)
	uIScale.Scale = 0
	local textLabel = Instance.new("TextLabel", frame)
	textLabel.Size = UDim2.new(1, 0, 0.4, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "🎉 LEVEL UP! 🎉"
	textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBlack
	local uIStroke = Instance.new("UIStroke", textLabel)
	uIStroke.Thickness = 4
	local textLabel2 = Instance.new("TextLabel", frame)
	textLabel2.Size = UDim2.new(1, 0, 0.3, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Text = "Level " .. p
	textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel2.TextScaled = true
	textLabel2.Font = Enum.Font.GothamBold
	local uIStroke_2 = Instance.new("UIStroke", textLabel2)
	uIStroke_2.Thickness = 3
	TweenService:Create(uIScale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.4, 0)
	}):Play()
	task.delay(Config.DURATIONS.LEVEL_UP or 2.5, function()
		TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, 0, 0.3, 0)
		}):Play()
		TweenService:Create(uIScale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Scale = 0
		}):Play()
		local tweenInfo = TweenInfo.new(0.5)

		for _, descendant in pairs(frame:GetDescendants()) do
			if descendant:IsA("TextLabel") then
				TweenService:Create(descendant, tweenInfo, {
					TextTransparency = 1
				}):Play()
			elseif descendant:IsA("UIStroke") then
				TweenService:Create(descendant, tweenInfo, {
					Transparency = 1
				}):Play()
			end
		end

		task.wait(0.6)
		frame:Destroy()
	end)
end

function NotificationSystem.ShowPlusOne(_, p, value, value2, value3, value4)
	assert(
		RunService:IsClient(),
		"NotificationSystem:ShowPlusOne may not be called on the server. Use the server API methods instead."
	)
	local character = localPlayer.Character

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local humanoidRootPart = character.HumanoidRootPart
	revive.pulseBoostLabel()
	local v2 = value3 or 1
	local v3 = value2 or 1
	local v4 = value4 or 1
	local v5 = ClientState:Get()
	local aura = UpgradeMultipliers.aura(v5.EquippedAura or "None")
	local totalMultiplier = Items.GetTotalMultiplier(v5.EquippedItems or {})
	local v6 = v5.X2BoostExpiresAt and os.time() < v5.X2BoostExpiresAt and 2 or 1
	local v7 = 1 + (v5.FriendBoostPercent or 0) / 100
	local v8 = localPlayer:GetAttribute("RELICSxyz_OwnsBoombox") and 2 or 1
	local rebirths = v5.Rebirths or 0
	local v9 = math.max(
		1,
		(rebirths > 0 and Config.REBIRTH_TIERS[rebirths].multiplier or 1) * p * (value or 1) * v3 * aura * v2 * v4 * totalMultiplier * v6 * v7 * v8 * (Config.WORLD_MULTIPLIER or 1) * Config.GALAXY_XP_MULTIPLIER * Config.GetAscensionXpMultiplier(v5.GalaxyAscensions)
	)
	local billboardGui = Instance.new("BillboardGui", playerGui)
	billboardGui.Name = "PlusOne"
	billboardGui.Size = UDim2.new(4.5, 0, 1.5, 0)
	billboardGui.StudsOffset = createVector(0, 1, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Adornee = humanoidRootPart
	local frame = Instance.new("Frame", billboardGui)
	frame.Size = UDim2.new(0, 0, 0, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	local uIListLayout = Instance.new("UIListLayout", frame)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Padding = UDim.new(0.05, 0)
	local imageLabel = Instance.new("ImageLabel", frame)
	imageLabel.Size = UDim2.new(0.3, 0, 0.8, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = Config.GetSpeedIcon() or "rbxassetid://16408406294"
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint", imageLabel)
	uIAspectRatioConstraint.AspectRatio = 1
	local textLabel = Instance.new("TextLabel", frame)
	textLabel.Size = UDim2.new(0.6, 0, 0.9, 0)
	textLabel.BackgroundTransparency = 1
	local color = Color3.fromRGB(255, 227, 178)

	if v2 >= 100 then
		color = Color3.fromRGB(255, 0, 0)
	elseif v2 >= 25 then
		color = Color3.fromRGB(255, 67, 199)
	elseif v2 >= 9 then
		color = Color3.fromRGB(0, 255, 255)
	elseif v2 > 1 then
		color = Color3.fromRGB(255, 238, 0)
	elseif value and value > 1 then
		color = Color3.fromRGB(255, 125, 65)
	elseif v4 > 1 then
		color = Color3.fromRGB(200, 80, 255)
	elseif v3 * aura > 1 then
		color = Color3.fromRGB(0, 220, 110)
	end

	textLabel.TextColor3 = color
	textLabel.Text = "+" .. Numbers.formatNumber(v9)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBlack
	local uIStroke = Instance.new("UIStroke", textLabel)
	uIStroke.Thickness = 2
	local vector2 = Vector3.new(math.random(-4, 4), math.random(3, 5), math.random(-2, 2))
	TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	TweenService:Create(billboardGui, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		StudsOffset = vector2
	}):Play()
	task.delay(0.5, function()
		local tweenInfo = TweenInfo.new(0.3)
		TweenService:Create(textLabel, tweenInfo, {
			TextTransparency = 1
		}):Play()
		TweenService:Create(imageLabel, tweenInfo, {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(uIStroke, tweenInfo, {
			Transparency = 1
		}):Play()
		TweenService:Create(billboardGui, tweenInfo, {
			StudsOffset = vector2 + createVector(0, -1, 0)
		}):Play()
		task.delay(0.35, function()
			billboardGui:Destroy()
		end)
	end)
end

function NotificationSystem.ShowPlusOneText(_, text, p)
	assert(
		RunService:IsClient(),
		"NotificationSystem:ShowPlusOneText may not be called on the server. Use the server API methods instead."
	)
	local character = localPlayer.Character

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local humanoidRootPart = character.HumanoidRootPart
	local billboardGui = Instance.new("BillboardGui", playerGui)
	billboardGui.Name = "PlusOneText"
	billboardGui.Size = UDim2.new(12, 0, 3, 0)
	billboardGui.StudsOffset = createVector(0, 10, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.ClipsDescendants = false
	billboardGui.LightInfluence = 0
	billboardGui.MaxDistance = 200
	billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	billboardGui.Adornee = humanoidRootPart
	local frame = Instance.new("Frame", billboardGui)
	frame.Size = UDim2.new(1, 0, 0.8, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.ClipsDescendants = false
	frame.ZIndex = 100
	local uIListLayout = Instance.new("UIListLayout", frame)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Padding = UDim.new(0.05, 0)
	local imageLabel = Instance.new("ImageLabel", frame)
	imageLabel.Size = UDim2.new(0.18, 0, 0.8, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = Config.GetSpeedIcon() or "rbxassetid://16408406294"
	imageLabel.LayoutOrder = 0
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint", imageLabel)
	uIAspectRatioConstraint.AspectRatio = 1
	local textLabel = Instance.new("TextLabel", frame)
	textLabel.Size = UDim2.new(0.78, 0, 0.95, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = p or Color3.fromRGB(255, 227, 178)
	textLabel.Text = text
	textLabel.TextScaled = true
	textLabel.TextWrapped = true
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.LayoutOrder = 1
	local uIStroke = Instance.new("UIStroke", textLabel)
	uIStroke.Thickness = 3
	local uIScale = Instance.new("UIScale", frame)
	uIScale.Scale = 0.7
	local vector2 = Vector3.new(math.random(-4, 4), math.random(5, 7), math.random(-2, 2))
	TweenService:Create(uIScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	TweenService:Create(billboardGui, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		StudsOffset = vector2
	}):Play()
	task.delay(0.5, function()
		local tweenInfo = TweenInfo.new(0.3)
		TweenService:Create(textLabel, tweenInfo, {
			TextTransparency = 1
		}):Play()
		TweenService:Create(imageLabel, tweenInfo, {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(uIStroke, tweenInfo, {
			Transparency = 1
		}):Play()
		TweenService:Create(billboardGui, tweenInfo, {
			StudsOffset = vector2 + createVector(0, -1, 0)
		}):Play()
		task.delay(0.35, function()
			if billboardGui.Parent then
				billboardGui:Destroy()
			end
		end)
	end)
end

function NotificationSystem.ShowWinNotification(_, p, p2)
	assert(
		RunService:IsClient(),
		"NotificationSystem:ShowWinNotification may not be called on the server. Use the server API methods instead."
	)
	local mainGUI = getMainGUI(10)

	if not mainGUI then
		return
	end

	local v2 = tonumber(p) or 1
	local v3 = p2 or Config.DURATIONS.WIN or 2
	SoundManager:Play("WIN")
	local frame = Instance.new("Frame", mainGUI)
	frame.Name = "WinNotification"
	frame.Size = UDim2.new(0.5, 0, 0.12, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	local uIListLayout = Instance.new("UIListLayout", frame)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Padding = UDim.new(0.02, 0)
	local uIScale = Instance.new("UIScale", frame)
	uIScale.Scale = 0
	local v4 = WinsTrophyFlyEffect.playWinEffects(v2, frame)
	local textLabel = Instance.new("TextLabel", frame)
	textLabel.AutomaticSize = Enum.AutomaticSize.X
	textLabel.Size = UDim2.new(0, 0, 0.8, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = formatWinNotificationText(v2)
	textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBlack
	local uIStroke = Instance.new("UIStroke", textLabel)
	uIStroke.Thickness = 3
	TweenService:Create(uIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.4, 0)
	}):Play()
	task.delay(v3, function()
		TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, 0, 0.3, 0)
		}):Play()
		TweenService:Create(uIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Scale = 0
		}):Play()
		local tweenInfo = TweenInfo.new(0.4)
		TweenService:Create(textLabel, tweenInfo, {
			TextTransparency = 1
		}):Play()
		WinsTrophyFlyEffect.fadeNotificationIcon(v4, tweenInfo)
		TweenService:Create(uIStroke, tweenInfo, {
			Transparency = 1
		}):Play()
		task.wait(0.5)
		frame:Destroy()
	end)
end

function NotificationSystem.ShowRebirth(_, p)
	assert(
		RunService:IsClient(),
		"NotificationSystem:ShowRebirth may not be called on the server. Use the server API methods instead."
	)
	local mainGUI = getMainGUI(10)

	if not mainGUI then
		return
	end

	SoundManager:Play("REBIRTH")
	local frame = Instance.new("Frame")
	frame.Name = "RebirthNotification"
	frame.Size = UDim2.new(0.6, 0, 0.2, 0)
	frame.Position = UDim2.new(0.5, 0, 0.45, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Parent = mainGUI
	local uIListLayout = Instance.new("UIListLayout", frame)
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Padding = UDim.new(0.05, 0)
	local uIScale = Instance.new("UIScale", frame)
	uIScale.Scale = 0
	local textLabel = Instance.new("TextLabel", frame)
	textLabel.Size = UDim2.new(1, 0, 0.4, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "🌀 NEW REBIRTH! 🌀"
	textLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBlack
	local uIStroke = Instance.new("UIStroke", textLabel)
	uIStroke.Thickness = 4
	uIStroke.Color = Color3.fromRGB(0, 50, 100)
	local textLabel2 = Instance.new("TextLabel", frame)
	textLabel2.Size = UDim2.new(1, 0, 0.3, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Text = "Rebirth #" .. p
	textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel2.TextScaled = true
	textLabel2.Font = Enum.Font.GothamBold
	local uIStroke_2 = Instance.new("UIStroke", textLabel2)
	uIStroke_2.Thickness = 3
	TweenService:Create(uIScale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.4, 0)
	}):Play()
	task.delay(3, function()
		TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, 0, 0.3, 0)
		}):Play()
		TweenService:Create(uIScale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Scale = 0
		}):Play()
		local tweenInfo = TweenInfo.new(0.5)

		for _, descendant in pairs(frame:GetDescendants()) do
			if descendant:IsA("TextLabel") then
				TweenService:Create(descendant, tweenInfo, {
					TextTransparency = 1
				}):Play()
			elseif descendant:IsA("UIStroke") then
				TweenService:Create(descendant, tweenInfo, {
					Transparency = 1
				}):Play()
			end
		end

		task.wait(0.6)
		frame:Destroy()
	end)
end

function NotificationSystem.ShowCurrencyCollect(_, value, value2, value3, p)
	assert(
		RunService:IsClient(),
		"NotificationSystem:ShowCurrencyCollect may not be called on the server. Use the server API methods instead."
	)
	local character = localPlayer.Character

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local humanoidRootPart = character.HumanoidRootPart
	local color = p == 1 and Color3.fromRGB(255, 247, 0) or Color3.fromRGB(238, 0, 255)
	local billboardGui = Instance.new("BillboardGui", playerGui)
	billboardGui.Name = "CurrencyCollect"
	billboardGui.Size = UDim2.new(8, 0, 2.2, 0)
	billboardGui.StudsOffset = createVector(0, 1, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Adornee = humanoidRootPart
	local frame = Instance.new("Frame", billboardGui)
	frame.Size = UDim2.new(0, 0, 0, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	local uIListLayout = Instance.new("UIListLayout", frame)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Padding = UDim.new(0.05, 0)
	local imageLabel = Instance.new("ImageLabel", frame)
	imageLabel.Size = UDim2.new(0.3, 0, 0.8, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://" .. tostring(value or 0)
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint", imageLabel)
	uIAspectRatioConstraint.AspectRatio = 1
	local textLabel = Instance.new("TextLabel", frame)
	textLabel.Size = UDim2.new(0.65, 0, 0.9, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "+" .. tostring(value3 or 1) .. " " .. tostring(value2 or "")
	textLabel.TextColor3 = color
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBlack
	local uIStroke = Instance.new("UIStroke", textLabel)
	uIStroke.Thickness = 2
	local vector2 = Vector3.new(math.random(-4, 4), math.random(3, 5), math.random(-2, 2))
	TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	TweenService:Create(billboardGui, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		StudsOffset = vector2
	}):Play()
	task.delay(1.8, function()
		local tweenInfo = TweenInfo.new(0.45)
		TweenService:Create(textLabel, tweenInfo, {
			TextTransparency = 1
		}):Play()
		TweenService:Create(imageLabel, tweenInfo, {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(uIStroke, tweenInfo, {
			Transparency = 1
		}):Play()
		TweenService:Create(billboardGui, tweenInfo, {
			StudsOffset = vector2 + createVector(0, -1, 0)
		}):Play()
		task.delay(0.5, function()
			billboardGui:Destroy()
		end)
	end)
end

function NotificationSystem.ShowBossHit(_)
	assert(
		RunService:IsClient(),
		"NotificationSystem:ShowBossHit may not be called on the server. Use the server API methods instead."
	)
	local mainGUI = getMainGUI(10)

	if not mainGUI then
		return
	end

	SoundManager:Play("BOSS_HIT")
	local frame = Instance.new("Frame", mainGUI)
	frame.Name = "BossHitNotification"
	frame.Size = UDim2.new(0.5, 0, 0.08, 0)
	frame.Position = UDim2.new(0.5, 0, 0.12, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	local uIScale = Instance.new("UIScale", frame)
	uIScale.Scale = 0
	local textLabel = Instance.new("TextLabel", frame)
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "[BOSS] -100 HP 💥"
	textLabel.TextColor3 = Color3.fromRGB(255, 30, 30)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBlack
	local uIStroke = Instance.new("UIStroke", textLabel)
	uIStroke.Thickness = 3
	uIStroke.Color = Color3.fromRGB(80, 0, 0)
	TweenService:Create(uIScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1.2
	}):Play()
	task.delay(0.3, function()
		TweenService:Create(uIScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			Scale = 1
		}):Play()
	end)
	task.spawn(function()
		for _ = 1, 4 do
			local v2 = math.random(-8, 8)
			TweenService:Create(frame, TweenInfo.new(0.05), {
				Position = UDim2.new(0.5, v2, 0.12, 0)
			}):Play()
			task.wait(0.05)
		end

		TweenService:Create(frame, TweenInfo.new(0.05), {
			Position = UDim2.new(0.5, 0, 0.12, 0)
		}):Play()
	end)
	task.delay(1.5, function()
		TweenService:Create(uIScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Scale = 0
		}):Play()
		TweenService:Create(textLabel, TweenInfo.new(0.4), {
			TextTransparency = 1
		}):Play()
		TweenService:Create(uIStroke, TweenInfo.new(0.4), {
			Transparency = 1
		}):Play()
		task.wait(0.5)
		frame:Destroy()
	end)
end

function NotificationSystem:ShowGeneralNotification(text: string, textColor: Color3, value: number)
	assert(
		RunService:IsClient(),
		"NotificationSystem:ShowGeneralNotification may not be called on the server. Use the server API methods instead."
	)
	local generalNotificationFrame = ReplicatedStorage:FindFirstChild("GeneralNotificationFrame")

	if not generalNotificationFrame then
		warn("[NotificationSystem] GeneralNotificationFrame introuvable dans ReplicatedStorage")
		return
	end

	local generalNotificationGui = playerGui:FindFirstChild("GeneralNotificationGui")

	if not generalNotificationGui then
		warn("[NotificationSystem] GeneralNotificationGui introuvable dans PlayerGui")
		return
	end

	local mainFrame = generalNotificationGui:FindFirstChild("MainFrame")

	if not mainFrame then
		warn("[NotificationSystem] MainFrame introuvable dans GeneralNotificationGui")
		return
	end

	if generalNotificationGui:IsA("ScreenGui") then
		generalNotificationGui.DisplayOrder = math.max(generalNotificationGui.DisplayOrder, 150)
	end

	local clone = generalNotificationFrame:Clone()
	local text2 = clone:FindFirstChild("Text")

	if text2 then
		text2.Text = text

		if textColor then
			text2.TextColor3 = textColor
		end

		if text:find("Secret Black Key") or textColor and textColor.R + textColor.G + textColor.B < 0.5 then
			local v2 = text2:FindFirstChildWhichIsA("UIStroke")

			if not v2 then
				v2 = Instance.new("UIStroke")
				v2.Thickness = 1
				v2.Parent = text2
			end

			v2.Color = Color3.fromRGB(255, 255, 255)
		end
	end

	clone.Parent = mainFrame
	local uIScale = clone:FindFirstChildWhichIsA("UIScale") or Instance.new("UIScale", clone)
	uIScale.Scale = 0
	TweenService:Create(uIScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	task.delay(value or 4, function()
		if not clone.Parent then
			return
		end

		TweenService:Create(uIScale, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Scale = 0
		}):Play()
		task.wait(0.4)

		if clone.Parent then
			clone:Destroy()
		end
	end)
end

local flag = false
local remotes = remo.createRemotes({
	Notification_ShowGeneralNotification = remo.remote()
})

function NotificationSystem.SetupRemotes(_)
	if flag then
		return
	end

	flag = true

	if RunService:IsClient() then
		remotes.Notification_ShowGeneralNotification:connect(function(p: string, color: Color3, p2: number)
			NotificationSystem:ShowGeneralNotification(p, color, p2)
		end)
	end
end

function NotificationSystem.ShowGeneralNotificationForPlayer(_, p, p2: string, color: Color3, p3: number)
	assert(RunService:IsServer(), "NotificationSystem:ShowGeneralNotificationForPlayer may not be called on the client")
	remotes.Notification_ShowGeneralNotification:fire(p, p2, color, p3)
end

function NotificationSystem.ShowGeneralNotificationForEveryone(_, p: string, color: Color3, p2: number)
	assert(
		RunService:IsServer(),
		"NotificationSystem:ShowGeneralNotificationForEveryone may not be called on the client"
	)
	remotes.Notification_ShowGeneralNotification:fireAll(p, color, p2)
end

return NotificationSystem