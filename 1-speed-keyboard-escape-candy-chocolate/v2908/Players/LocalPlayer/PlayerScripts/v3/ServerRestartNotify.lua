local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local serverRestartNotify = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ServerRestartNotify")
local color = Color3.fromRGB(255, 170, 50)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v = nil
local thread = nil
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getGeneralChannel()
	local textChannels = TextChatService:FindFirstChild("TextChannels")

	if textChannels then
		return textChannels:FindFirstChild("RBXGeneral")
	end

	return TextChatService:FindFirstChild("RBXGeneral", true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function postChat(p: string)
	local generalChannel = getGeneralChannel() -- equivalent call inferred; original call site unknown

	if generalChannel then
		generalChannel:DisplaySystemMessage(string.format("<font color=\"%s\"><b>[SERVER]</b> %s</font>", "#ffaa00", p))
	end
end

local function formatLocalTime(p: number)
	return DateTime.fromUnixTimestamp(p):FormatLocalTime("LTS", "en-us")
end

local function formatCountdown(p: number)
	if p <= 0 then
		return "restarting soon"
	end

	local v3 = math.max(0, (math.floor(p)))

	if v3 >= 3600 then
		local v4 = math.floor(v3 / 3600)
		local v5 = math.floor(v3 % 3600 / 60)
		return string.format("%dh %02dm remaining", v4, v5)
	else
		local v4 = math.floor(v3 / 60)
		local v5 = v3 % 60
		return string.format("%dm %02ds remaining", v4, v5)
	end
end

local function buildInitialChatMessage(p: number, p2: string)
	local v3 = "This server is scheduled to restart at " .. DateTime.fromUnixTimestamp(p):FormatLocalTime(
		"LTS",
		"en-us"
	) .. "."

	if p2 ~= "" then
		v3 ..= " " .. p2
	end

	return v3 .. " Please rejoin after the update."
end

-- equivalent calls inferred from this helper; original call sites unknown
local function buildReminderChatMessage(label: string?, flag: boolean)
	if flag then
		return "Server restart is imminent! (30 seconds)"
	end

	return "Server restart in " .. (label or "") .. "."
end

local function ensureRestartGui()
	if v2 and v2.Parent then
		return v2
	end

	local serverRestartGui = playerGui:FindFirstChild("ServerRestartGui")

	if serverRestartGui and serverRestartGui:IsA("ScreenGui") then
		v2 = serverRestartGui
		return serverRestartGui
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ServerRestartGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 15
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui
	v2 = screenGui
	return screenGui
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCountdown()
	if thread then
		task.cancel(thread)
		thread = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeBanner()
	stopCountdown() -- equivalent call inferred; original call site unknown
	local v3 = v2 or playerGui:FindFirstChild("ServerRestartGui")
	local serverRestartBanner = v3 and v3:FindFirstChild("ServerRestartBanner")

	if serverRestartBanner then
		serverRestartBanner:Destroy()
	end

	v = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function runCountdown(textLabel, p: number)
	stopCountdown() -- equivalent call inferred; original call site unknown
	thread = task.spawn(function()
		while textLabel.Parent and v == p do
			textLabel.Text = "Scheduled restart — " .. formatCountdown(p - workspace:GetServerTimeNow())
			task.wait(1)
		end
	end)
end

local function showBanner(restartUnix: number, customMessage: string)
	local restartGui = ensureRestartGui()
	removeBanner() -- equivalent call inferred; original call site unknown
	v = restartUnix
	local frame = Instance.new("Frame")
	frame.Name = "ServerRestartBanner"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, -0.12, 0)
	frame.Size = UDim2.new(0.48, 0, 0.075, 0)
	frame.BackgroundColor3 = Color3.fromRGB(65, 42, 20)
	frame.BackgroundTransparency = 0.08
	frame.BorderSizePixel = 0
	frame.ZIndex = 1
	frame.Parent = restartGui
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.35, 0)
	uICorner.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = color
	uIStroke.Thickness = 2
	uIStroke.Transparency = 0.25
	uIStroke.Parent = frame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingLeft = UDim.new(0, 16)
	uIPadding.PaddingRight = UDim.new(0, 16)
	uIPadding.PaddingTop = UDim.new(0, 6)
	uIPadding.PaddingBottom = UDim.new(0, 6)
	uIPadding.Parent = frame
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.FillDirection = Enum.FillDirection.Vertical
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Padding = UDim.new(0, 2)
	uIListLayout.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, 0, 0.45, 0)
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.TextScaled = true
	textLabel.TextColor3 = color
	textLabel.Text = "SERVER RESTART INBOUND"
	textLabel.Parent = frame
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint.MaxTextSize = 22
	uITextSizeConstraint.MinTextSize = 14
	uITextSizeConstraint.Parent = textLabel
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Subtitle"
	textLabel2.BackgroundTransparency = 1
	textLabel2.Size = UDim2.new(1, 0, 0.4, 0)
	textLabel2.Font = Enum.Font.FredokaOne
	textLabel2.TextScaled = true
	textLabel2.TextColor3 = Color3.fromRGB(255, 240, 220)
	textLabel2.Text = "Scheduled restart — " .. formatCountdown(restartUnix - workspace:GetServerTimeNow())
	textLabel2.Parent = frame
	local uITextSizeConstraint2 = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint2.MaxTextSize = 18
	uITextSizeConstraint2.MinTextSize = 12
	uITextSizeConstraint2.Parent = textLabel2

	if customMessage ~= "" then
		local textLabel3 = Instance.new("TextLabel")
		textLabel3.Name = "Detail"
		textLabel3.BackgroundTransparency = 1
		textLabel3.Size = UDim2.new(1, 0, 0.35, 0)
		textLabel3.Font = Enum.Font.Gotham
		textLabel3.TextScaled = true
		textLabel3.TextColor3 = Color3.fromRGB(220, 220, 220)
		textLabel3.Text = customMessage
		textLabel3.Parent = frame
		local uITextSizeConstraint3 = Instance.new("UITextSizeConstraint")
		uITextSizeConstraint3.MaxTextSize = 16
		uITextSizeConstraint3.MinTextSize = 10
		uITextSizeConstraint3.Parent = textLabel3
	end

	TweenService:Create(frame, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.025, 0)
	}):Play()
	runCountdown(textLabel2, restartUnix) -- equivalent call inferred; original call site unknown
end

local function playAnnouncementSound()
	local announcementSound = SoundService:FindFirstChild("AnnouncementSound")

	if announcementSound and announcementSound:IsA("Sound") then
		local clone = announcementSound:Clone()
		clone.Parent = playerGui
		clone:Play()
		clone.Ended:Once(function()
			clone:Destroy()
		end)
	end
end

local function handleInitial(data)
	local restartUnix = data.restartUnix
	local customMessage = data.customMessage or ""
	local lateJoin = data.lateJoin == true
	local v3 = "This server is scheduled to restart at " .. DateTime.fromUnixTimestamp(restartUnix):FormatLocalTime(
		"LTS",
		"en-us"
	) .. "."

	if customMessage ~= "" then
		v3 ..= " " .. customMessage
	end

	postChat(v3 .. " Please rejoin after the update.") -- equivalent call inferred; original call site unknown
	showBanner(restartUnix, customMessage)

	if not lateJoin then
		playAnnouncementSound()
		NotificationSystem:ShowMessage("SERVER RESTART INBOUND", color)
		NotificationSystem:ShowGeneralNotification(
			"Server restart scheduled at " .. DateTime.fromUnixTimestamp(restartUnix):FormatLocalTime("LTS", "en-us") .. ".",
			color,
			8
		)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function handleReminder(p)
	local reminderChatMessage = buildReminderChatMessage(p.label, p.imminent == true) -- equivalent call inferred; original call site unknown
	postChat(reminderChatMessage) -- equivalent call inferred; original call site unknown
end

serverRestartNotify.OnClientEvent:Connect(function(p)
	if p.kind == "initial" then
		handleInitial(p)
	elseif p.kind == "reminder" then
		handleReminder(p) -- equivalent call inferred; original call site unknown
	end
end)