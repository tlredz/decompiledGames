local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local localPlayer = Players.LocalPlayer
local adminEvent = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Admin"):WaitForChild("AdminEvent")
local clone = script.Parent.AdminUI:Clone()
clone.Parent = localPlayer:WaitForChild("PlayerGui")
clone.Enabled = true
local AdminConsoleView = require(game.ReplicatedStorage.ChickenOrHero.Presentation.AdminConsoleView)
AdminConsoleView.apply(clone)
local console = clone.Console
local output = console.Scroll.Output
local refresh = clone.Refresh
local notice = clone.Notice
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "AdminRefreshBlur"
blurEffect.Size = 0
blurEffect.Parent = Lighting
local v = {}
local AdminAutocomplete = require(script.Parent:WaitForChild("AdminAutocomplete"))
local v2 = AdminAutocomplete.bind(console, localPlayer, v)

local function tween(p, duration, p2)
	TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p2):Play()
end

local function setConsole(p)
	console.Visible = p and localPlayer:GetAttribute("AdminAuthorized") == true
	localPlayer:SetAttribute("AdminConsoleActive", console.Visible or nil)

	if not console.Visible then
		console.Command:ReleaseFocus()
		return
	end

	console.Command.Text = ";"
	task.defer(function()
		console.Command:CaptureFocus()
		console.Command.CursorPosition = 2
	end)
end

local AnnouncementComposer = require(script.Parent:WaitForChild("AnnouncementComposer"))
local v3 = AnnouncementComposer.bind(clone, adminEvent, function()
	setConsole(false)
end)
clone:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	AdminConsoleView.layout(clone)
end)
AdminConsoleView.layout(clone)
local ValleyPanels = require(game.ReplicatedStorage.ChickenOrHero.Presentation.ValleyPanels)
local button = ValleyPanels.button(console, "Giveaway", "GIVEAWAY", 560, 16, 145, 28)
local ValleyTheme = require(game.ReplicatedStorage.ChickenOrHero.Presentation.ValleyTheme)
ValleyTheme.button(button, Color3.fromRGB(228, 203, 137))
button.AnchorPoint = Vector2.new(1, 0)
button.Position = UDim2.new(1, -78, 0, 14)
button.TextSize = 11
button.Activated:Connect(function()
	setConsole(false)
	game.ReplicatedStorage.ChickenOrHero.Admin.GiveawayEvent:FireServer("Open")
end)

local function authorize()
	button.Visible = localPlayer:GetAttribute("AdminTier") == "Owner"
	console.Title.Text = "HUSS VALLEY · " .. string.upper(localPlayer:GetAttribute("AdminTier") or "STAFF") .. " CONSOLE"
	local openConsole = clone.OpenConsole
	openConsole.Visible = localPlayer:GetAttribute("AdminAuthorized") == true and not (localPlayer:GetAttribute("JourneyOpen") or localPlayer:GetAttribute("MapVoteOpen"))

	if not clone.OpenConsole.Visible then
		setConsole(false)
	end
end

local id = nil
local v4 = ""
local count = 0
local v5 = false
local v6 = false
local now = 0
local deadline = 0
local count2 = 0

for _, v7 in { "JourneyOpen", "MapVoteOpen" } do
	localPlayer:GetAttributeChangedSignal(v7):Connect(authorize)
end

authorize()
localPlayer:GetAttributeChangedSignal("AdminAuthorized"):Connect(authorize)
localPlayer:GetAttributeChangedSignal("AdminTier"):Connect(authorize)

-- equivalent calls inferred from this helper; original call sites unknown
local function reply(text)
	output.Text = tostring(text)
	console.Scroll.CanvasPosition = Vector2.zero

	if not id and localPlayer:GetAttribute("AdminAuthorized") == true then
		console.Visible = true
		localPlayer:SetAttribute("AdminConsoleActive", true)
	end
end

local function submit()
	local v7 = console.Command.Text:gsub("\t", "")

	if v7:match("^%s*$") or v7 == ";" then
		return
	end

	if v7:sub(1, 1) ~= ";" then
		v7 = ";" .. v7
	end

	v4 = v7
	table.insert(v, v7)

	if #v > 30 then
		table.remove(v, 1)
	end

	console.Command:ReleaseFocus()
	adminEvent:FireServer("Command", v7)
	output.Text = "Running " .. v7:match("^%S+") .. "…"
end

clone.OpenConsole.Activated:Connect(function()
	if id then
		console.ZIndex = 100
	end

	setConsole(not console.Visible)
end)
console.Close.Activated:Connect(function()
	setConsole(false)
end)
console.Send.Activated:Connect(submit)
console.Command.FocusLost:Connect(function(p)
	if p then
		submit()
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if localPlayer:GetAttribute("AdminAuthorized") ~= true then
		return
	end

	if input.KeyCode == Enum.KeyCode.Semicolon and not (UserInputService:GetFocusedTextBox() or gameProcessed) then
		setConsole(true)
	elseif input.KeyCode == Enum.KeyCode.Escape and console.Visible then
		setConsole(false)
	end
end)

local function clear(p)
	if p and id ~= p then
		return
	end

	count += 1
	id = nil
	v5 = false
	v6 = false
	localPlayer:SetAttribute("AdminRefreshActive", nil)
	TweenService:Create(blurEffect, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = 0
	}):Play()
	TweenService:Create(refresh, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		GroupTransparency = 1
	}):Play()
	local v7 = count
	task.delay(0.35, function()
		if count == v7 then
			refresh.Visible = false
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teleportScreen()
	local clone2 = script.Parent.AdminTeleportUI:Clone()
	local UIProportions = require(game.ReplicatedFirst.UIProportions)
	UIProportions.prepareTeleport(clone2, workspace.CurrentCamera.ViewportSize)
	TeleportService:SetTeleportGui(clone2)
end

local function show(data)
	if type(data) ~= "table" or type(data.id) ~= "string" then
		return
	end

	now = os.clock()
	local v7 = id ~= data.id
	id = data.id
	deadline = data.deadline or workspace:GetServerTimeNow()
	v6 = data.transfer == true
	v5 = false
	count += 1
	local v8 = count
	refresh.Visible = true
	refresh.Content.Retry.Visible = false
	refresh.Content.Dismiss.Visible = false
	refresh.Content.Heading.Text = data.title or "REFRESHING HUSS VALLEY"

	if v7 then
		refresh.GroupTransparency = 1
		refresh.Content.Body.MaxVisibleGraphemes = 0
	end

	refresh.Content.Body.Text = data.message or "Please hold on while you are refreshed."
	localPlayer:SetAttribute("AdminRefreshActive", true)
	setConsole(false)
	TweenService:Create(blurEffect, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = 22
	}):Play()
	TweenService:Create(refresh, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		GroupTransparency = 0
	}):Play()
	teleportScreen() -- equivalent call inferred; original call site unknown

	if v7 then
		task.spawn(function()
			for i = 1, utf8.len(refresh.Content.Body.Text) or #refresh.Content.Body.Text do
				if count ~= v8 then
					return
				end

				refresh.Content.Body.MaxVisibleGraphemes = i
				task.wait(0.025)
			end

			refresh.Content.Body.MaxVisibleGraphemes = -1
		end)
	else
		refresh.Content.Body.MaxVisibleGraphemes = -1
	end
end

local function showFailure(text, p)
	count += 1
	now = os.clock()
	v5 = true
	refresh.Visible = true
	refresh.GroupTransparency = 0
	refresh.Content.Body.MaxVisibleGraphemes = -1
	refresh.Content.Heading.Text = "RECONNECTING PAUSED"
	refresh.Content.Body.Text = text
	refresh.Content.Status.Text = p and "Tap retry when you're ready." or "You can keep playing."
	refresh.Content.Retry.Visible = p == true
	refresh.Content.Dismiss.Visible = not p

	if not p then
		localPlayer:SetAttribute("AdminRefreshActive", nil)
		TweenService:Create(blurEffect, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = 0
		}):Play()
	end
end

refresh.Content.Retry.Activated:Connect(function()
	refresh.Content.Retry.Visible = false
	refresh.Content.Status.Text = "Trying again…"
	v5 = false
	now = os.clock()
	adminEvent:FireServer("RetryTransfer")
end)
refresh.Content.Dismiss.Activated:Connect(function()
	clear()
end)
adminEvent.OnClientEvent:Connect(function(p, text, p2)
	if p == "Reply" then
		reply(text) -- equivalent call inferred; original call site unknown
	elseif p == "Refresh" then
		show(text)
	elseif p == "CancelRefresh" then
		clear(text)
	elseif p == "TransferFailed" then
		showFailure(text, p2)
	elseif p == "Announcement" then
		count2 += 1
		local v7 = count2
		notice.Text = text
		notice.Visible = true
		notice.TextTransparency = 1
		TweenService:Create(notice, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0
		}):Play()
		task.delay(7, function()
			if count2 == v7 then
				TweenService:Create(notice, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = 1
				}):Play()
				task.wait(0.35)

				if count2 == v7 then
					notice.Visible = false
				end
			end
		end)
	end
end)
RunService.RenderStepped:Connect(function()
	if not id or v5 then
		return
	end

	local v7 = math.max(0, (math.ceil(deadline - workspace:GetServerTimeNow())))

	if v7 > 0 then
		refresh.Content.Status.Text = "Refreshing in " .. v7 .. "…"
	else
		refresh.Content.Status.Text = v6 and "Reconnecting…" or "Saving your progress…"
	end

	if os.clock() - now > 140 then
		showFailure("Reconnecting is taking longer than expected. Please rejoin from Roblox if needed.", false)
	end
end)
script.Destroying:Connect(function()
	v3.destroy()
	v2.destroy()
	localPlayer:SetAttribute("AdminRefreshActive", nil)
	localPlayer:SetAttribute("AdminConsoleActive", nil)
	blurEffect:Destroy()
	clone:Destroy()
end)
local success, result = pcall(function()
	return TeleportService:GetLocalPlayerTeleportData()
end)

if success and type(result) == "table" and result.destination == "Refresh" then
	show({
		id = result.refreshId or "arrival",
		title = "REJOINING HUSS VALLEY",
		message = "Your progress is saved. Finding a refreshed server…",
		transfer = true
	})
end

adminEvent:FireServer("Sync")