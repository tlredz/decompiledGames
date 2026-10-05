local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer
local admin = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Admin")
local eventHostRemote = admin:WaitForChild("EventHostRemote")
local EventHostCatalog = require(admin:WaitForChild("EventHostCatalog"))
local EventHostLayout = require(admin:WaitForChild("EventHostLayout"))
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ValleyEventAudience"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 82
screenGui.IgnoreGuiInset = false
screenGui:SetAttribute("UIProportionalExclude", true)
screenGui:SetAttribute("SelfManagedText", true)
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Name = "Root"
frame.Size = UDim2.fromScale(1, 1)
frame.BackgroundTransparency = 1
frame.Parent = screenGui

local function label(name)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundColor3 = Color3.fromRGB(15, 26, 38)
	textLabel.BackgroundTransparency = 0.08
	textLabel.TextColor3 = Color3.fromRGB(232, 237, 228)
	textLabel.TextScaled = true
	textLabel.TextWrapped = true
	textLabel.BorderSizePixel = 0
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.Visible = false
	textLabel.Parent = frame
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 10)
	uICorner.Parent = textLabel
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingLeft = UDim.new(0.04, 0)
	uIPadding.PaddingRight = UDim.new(0.04, 0)
	uIPadding.PaddingTop = UDim.new(0.14, 0)
	uIPadding.PaddingBottom = UDim.new(0.14, 0)
	uIPadding.Parent = textLabel
	return textLabel
end

local parent = label("EventCountdown")
local v2 = label("HostAnnouncement")
parent.TextColor3 = Color3.fromRGB(235, 201, 137)
v2.RichText = true
v2.BackgroundTransparency = 1
v2.TextStrokeTransparency = 0.45

local function resize()
	local absoluteSize = frame.AbsoluteSize
	local toast, v3 = EventHostLayout.toast(absoluteSize.X, absoluteSize.Y)
	parent.Size = UDim2.fromOffset(math.min(420, absoluteSize.X * 0.8), 32)
	parent.Position = UDim2.fromScale(0.5, 0.07)
	v2.Size = UDim2.fromOffset(toast, v3)
	v2.Position = UDim2.new(0.5, 0, 0.07, 40)
end

local function escape(p)
	return tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;")
end

local v3 = {}
local flag = false
local flag2 = true
local idsByMode = {}

local function notifyBoost(data)
	if type(data) ~= "table" or type(data.id) ~= "string" or type(data.endsAt) ~= "number" or data.endsAt <= workspace:GetServerTimeNow() then
		return
	end

	local v4 = data.mode == "DoubleCoins" and "Coins" or data.mode == "DoubleGems" and "Gems" or false

	if not v4 or idsByMode[data.mode] == data.id then
		return
	end

	idsByMode[data.mode] = data.id
	task.spawn(function()
		for _ = 1, 5 do
			if not flag2 or data.endsAt <= workspace:GetServerTimeNow() then
				break
			end

			if pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
				Title = "2X " .. string.upper(v4) .. " ENABLED!",
				Text = "An admin activated double " .. string.lower(v4) .. "! See your wallet for the countdown.",
				Duration = 6
			}) then
				break
			else
				task.wait(1)
			end
		end
	end)
end

local function announce(p)
	if #v3 >= 5 then
		table.remove(v3, 1)
	end

	table.insert(v3, p)

	if flag then
		return
	end

	flag = true
	task.spawn(function()
		while flag2 and #v3 > 0 do
			local v4 = table.remove(v3, 1)
			v2.Text = "<font color=\"#FF7777\"><b>" .. tostring(v4.authorName):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(
				">",
				"&gt;"
			):gsub(
				"\"",
				"&quot;"
			) .. "</b></font> <font color=\"#7DCDE4\">" .. utf8.char(57344) .. "</font>: " .. tostring(v4.message):gsub(
				"&",
				"&amp;"
			):gsub(
				"<",
				"&lt;"
			):gsub(
				">",
				"&gt;"
			):gsub(
				"\"",
				"&quot;"
			)
			v2.Visible = true
			v2.TextTransparency = 1
			TweenService:Create(v2, TweenInfo.new(0.2), {
				TextTransparency = 0
			}):Play()
			task.wait(7)

			if not flag2 then
				break
			end

			TweenService:Create(v2, TweenInfo.new(0.25), {
				TextTransparency = 1
			}):Play()
			task.wait(0.25)
		end

		flag = false

		if flag2 then
			v2.Visible = false
		end
	end)
end

local v4 = nil
local colorCorrectionEffect = nil
local particleEmitter = nil
local part = nil
local v5 = {}
local v6 = {}

local function clear()
	for _, v7 in v5 do
		v7:Destroy()
	end

	table.clear(v5)

	if colorCorrectionEffect then
		colorCorrectionEffect:Destroy()
		colorCorrectionEffect = nil
	end

	if part then
		part:Destroy()
		part = nil
		particleEmitter = nil
	end

	for k, v7 in v6 do
		if Lighting[k] == v7.applied then
			Lighting[k] = v7.original
		end
	end

	table.clear(v6)
	v4 = nil
	parent.Visible = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lighting(p, color)
	v6[p] = {
		original = Lighting[p],
		applied = color
	}
	Lighting[p] = color
end

local function apply(data)
	if type(data) ~= "table" or data.mode == "DoubleCoins" or data.mode == "DoubleGems" or not EventHostCatalog.Modes[data.mode] or data.endsAt <= workspace:GetServerTimeNow() then
		clear()
		return
	end

	if v4 and v4.id == data.id then
		return
	end

	clear()
	v4 = data

	if data.mode == "GoldenHour" or data.mode == "Blackout" or data.mode == "MoonGravity" then
		colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "EventHostColor"
		colorCorrectionEffect.Parent = Lighting

		if data.mode == "GoldenHour" then
			lighting("ClockTime", 17.7) -- equivalent call inferred; original call site unknown
			colorCorrectionEffect.TintColor = Color3.fromRGB(255, 225, 179)
			colorCorrectionEffect.Saturation = 0.12
		else
			if data.mode ~= "Blackout" then
				colorCorrectionEffect.TintColor = Color3.fromRGB(191, 216, 255)
				return
			end

			lighting("ClockTime", 0) -- equivalent call inferred; original call site unknown
			lighting("Brightness", 0.5) -- equivalent call inferred; original call site unknown
			lighting("Ambient", Color3.fromRGB(45, 55, 78)) -- equivalent call inferred; original call site unknown
			lighting("OutdoorAmbient", Color3.fromRGB(56, 66, 88)) -- equivalent call inferred; original call site unknown
			colorCorrectionEffect.TintColor = Color3.fromRGB(171, 197, 255)
			colorCorrectionEffect.Brightness = -0.08
		end
	elseif data.mode == "Confetti" then
		part = Instance.new("Part")
		part.Name = "EventConfettiLocal"
		part.Size = createVector(1, 1, 1)
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Parent = workspace
		particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particleEmitter.Rate = 24
		particleEmitter.Lifetime = NumberRange.new(2, 3)
		particleEmitter.Speed = NumberRange.new(4, 9)
		particleEmitter.Acceleration = createVector(0, -10, 0)
		particleEmitter.SpreadAngle = Vector2.new(180, 180)
		particleEmitter.Rotation = NumberRange.new(0, 360)
		particleEmitter.RotSpeed = NumberRange.new(-80, 80)
		particleEmitter.Size = NumberSequence.new(0.25)
		particleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 201, 137)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(184, 157, 241)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 205, 228))
		})
		particleEmitter.Parent = part
	end
end

local total = 0
local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.1 or not v4 then
		return
	end

	total = 0
	local v7 = math.max(0, (math.ceil(v4.endsAt - workspace:GetServerTimeNow())))

	if v7 <= 0 then
		clear()
		return
	end

	parent.Visible = true
	parent.Text = EventHostCatalog.Modes[v4.mode].Name .. " · " .. math.floor(v7 / 60) .. ":" .. string.format(
		"%02d",
		v7 % 60
	)

	if v4.mode == "Rainbow" then
		for k, v8 in v5 do
			if k.Parent then
				continue
			end

			v8:Destroy()
			v5[k] = nil
		end

		for _, v8 in Players:GetPlayers() do
			local character = v8.Character

			if not (character and character.Parent) then
				continue
			end

			local v9 = v5[character]

			if not v9 then
				v9 = Instance.new("Highlight")
				v9.Name = "EventRainbowLocal"
				v9.Adornee = character
				v9.FillTransparency = 0.8
				v9.OutlineTransparency = 0.1
				v9.DepthMode = Enum.HighlightDepthMode.Occluded
				v9.Parent = character
				v5[character] = v9
			end

			v9.FillColor = Color3.fromHSV((workspace:GetServerTimeNow() * 0.12 + v8.UserId % 10 * 0.1) % 1, 0.65, 1)
			v9.OutlineColor = v9.FillColor
		end
	elseif part then
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		particleEmitter.Enabled = humanoidRootPart ~= nil

		if humanoidRootPart then
			part.Position = humanoidRootPart.Position + createVector(0, 12, 0)
		end
	end
end)
local onClientEventConnection = eventHostRemote.OnClientEvent:Connect(function(p, p2)
	if p == "EventState" then
		apply(p2)
	elseif p == "BoostEnabled" then
		notifyBoost(p2)
	elseif p == "Announcement" and type(p2) == "table" then
		announce(p2)
	end
end)
local absoluteSizeChangedConnection = frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
script.Destroying:Connect(function()
	flag2 = false
	onClientEventConnection:Disconnect()
	heartbeatConnection:Disconnect()
	absoluteSizeChangedConnection:Disconnect()
	clear()
	screenGui:Destroy()
end)
resize()
eventHostRemote:FireServer("PublicSync")