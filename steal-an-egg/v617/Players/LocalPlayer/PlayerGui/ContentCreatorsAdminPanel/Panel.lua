local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local launcher = parent:WaitForChild("Launcher")
local object = setmetatable({}, {
	__mode = "k"
})

local function bindCaption(button)
	if not button:IsA("TextButton") or object[button] then
		return
	end

	local caption = button:FindFirstChild("Caption")

	if not (caption and caption:IsA("TextLabel")) then
		return
	end

	object[button] = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function sync()
		caption.Text = button.Text
		caption.TextSize = button.Text == "X" and 30 or button.TextSize
		caption.TextColor3 = button.TextColor3
		caption.TextXAlignment = button.TextXAlignment
		caption.TextWrapped = button.TextWrapped
	end

	for _, propertyName in {
		"Text",
		"TextSize",
		"TextColor3",
		"TextXAlignment",
		"TextWrapped"
	} do
		button:GetPropertyChangedSignal(propertyName):Connect(sync)
	end

	sync() -- equivalent call inferred; original call site unknown
end

for _, descendant in parent:GetDescendants() do
	bindCaption(descendant)
end

parent.DescendantAdded:Connect(bindCaption)
local root = parent:WaitForChild("Root")
local editor = root.Editor
local picker = editor.Picker
local whitelist = editor.Whitelist
local server2 = nil
local v2 = nil
local v3 = {}
local v4 = {}
local accountsByQuery = {}
local v5 = "list"
local admin = nil
local v6 = ""

local function fn() end

local function fn2() end

local function fn3() end

local templates = parent:WaitForChild("Templates")
local Areas = require(ReplicatedStorage.Data.Areas)
local Assets = require(ReplicatedStorage.Data.Assets)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local StaffEntryHotkey = require(ReplicatedStorage.Client.StaffEntryHotkey)
local Preferences = require(ReplicatedStorage.Shared.Preferences)
local MenuNavigation = require(ReplicatedStorage.Client.MenuNavigation)
local GUI = require(ReplicatedStorage.Client.GUI)
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local CreatorCommands = require(ReplicatedStorage.Shared.CreatorCommands)
local contentCreatorRemotes = ReplicatedStorage:WaitForChild("ContentCreatorRemotes")
local request = contentCreatorRemotes:WaitForChild("Request")
local update = contentCreatorRemotes:WaitForChild("Update")
Color3.new(1, 1, 1)
local color = Color3.fromRGB(112, 255, 24)
local color2 = Color3.fromRGB(207, 208, 223)
local v7 = {
	Camera = Color3.fromRGB(68, 196, 255),
	Character = Color3.fromRGB(119, 255, 65),
	Collection = Color3.fromRGB(255, 211, 49),
	Mutations = Color3.fromRGB(236, 104, 255),
	Scene = Color3.fromRGB(255, 149, 62),
	Servers = Color3.fromRGB(170, 144, 255),
	Manage = Color3.fromRGB(255, 111, 136)
}
local v8 = {
	target = "PLAYER",
	server = "CREATOR SERVER",
	speed = "WALK SPEED · 1–300",
	zone = "ZONE",
	zoneOrAll = "GUARDS TO PAUSE",
	guard = "GUARD APPEARANCE",
	asset = "ANIMAL / EGG TYPE",
	egg = "PLACED EGG",
	size = "SIZE MULTIPLIER · 0.1–100",
	amount = "AMOUNT · 1–25",
	currency = "WHAT TO GIVE",
	prank = "PRANK",
	pet = "PEN PET",
	mutation = "MUTATION"
}

local function amountMax(p: string?)
	if p == "giveShards" then
		return 1000000
	end

	return 25
end

local v9 = {
	Access = false,
	Owns = false,
	Commands = 0,
	Active = 0,
	TargetActive = 0,
	Players = 0,
	Servers = 0,
	Balances = 0,
	PlacedEggs = 0,
	PenPets = 0,
	Mutations = 0
}
v9.Commands = {}
v9.Active = {}
v9.TargetActive = {}
v9.Players = {}
v9.Servers = {}
v9.Balances = {}
v9.PlacedEggs = {}
v9.PenPets = {}
v9.Mutations = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function balanceLabel(p)
	for _, v10 in v9.Balances or {} do
		if v10.Value == p then
			return v10.Label
		end
	end

	return nil
end

local clonesById = {}
local text3 = "Camera"
local v11 = false
local visible2 = false
local fn4
local fn5
local v13 = false
local v14 = nil
local v15 = {}
local clonesByName = {}
local v16 = {}
local flag = false
local count = 0
local v17 = 0
local flag2 = false
local v18 = 0
local count2 = 0
local selectedObject = nil
local v19 = {}
local v20 = nil
local fn6 = nil
local total = 100

-- equivalent calls inferred from this helper; original call sites unknown
local function isPlayerPicker()
	return v20 == "target" or v20 == "guest"
end

local function isOwnedPicker()
	return v20 == "egg" or v20 == "pet"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function grantsPet()
	return v14 ~= nil and (v14.Id == "giveAnimal" or v14.Id == "spawnMutatedPet")
end

local v21 = nil
local v22 = nil
local v23 = nil

local function notice(text: string, flag3: boolean?)
	count2 += 1
	local v24 = count2
	parent.Toast.Message.Text = text
	local stroke = parent.Toast.Stroke
	local color4

	if flag3 == false then
		color4 = Color3.fromRGB(244, 160, 130)
	else
		color4 = Color3.fromRGB(160, 207, 159)
	end

	stroke.Color = color4
	parent.Toast.Visible = true
	task.delay(7, function()
		if v24 == count2 then
			parent.Toast.Visible = false
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function focus(selectedObject2)
	if UserInputService.GamepadEnabled and not MenuNavigation.IsCursorActive() then
		GuiService.SelectedObject = selectedObject2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function panelEnabled()
	return Preferences.IsOn("CreatorPanel")
end

local function refreshLauncher(flag3: boolean)
	local parent2

	if PlatformController.IsConsole() then
		parent2 = GUI.HUD()
	else
		parent2 = parent
	end

	if launcher.Parent ~= parent2 then
		launcher.Parent = parent2
	end

	launcher.Visible = parent.Enabled and v9.Access and Preferences.IsOn("CreatorPanel") and not flag3 and not (UserInputService.KeyboardEnabled or StaffEntryHotkey.IsHidden())
end

local function showPanel(visible: boolean)
	if visible and not (v9.Access and Preferences.IsOn("CreatorPanel")) then
		return
	end

	if visible and not root.Visible then
		flag2 = true
		v17 = 0
		selectedObject = GuiService.SelectedObject

		if not v13 and v9.Owns and not v9.Reserved then
			v13 = true
			fn5("Servers")
		end
	end

	root.Visible = visible
	refreshLauncher(visible)

	if visible then
		editor.Visible = v14 ~= nil and (not visible2 or v11)
		root.Position = UDim2.fromScale(0.5, 0.52)
		TweenService:Create(root, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0.5, 0.5)
		}):Play()
		focus(root.Tabs:FindFirstChild(text3) or root.Tabs.Camera) -- equivalent call inferred; original call site unknown
	else
		flag2 = false
		editor.Visible = false
		picker.Visible = false
		local v24 = GuiService
		local selectedObject2

		if selectedObject and selectedObject.Parent then
			selectedObject2 = selectedObject
		end

		v24.SelectedObject = selectedObject2
	end
end

local function resize()
	local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
	local v24 = root
	local size

	if viewportSize and viewportSize.Y < 600 then
		size = UDim2.fromScale(0.94, 0.94)
	else
		size = UDim2.fromScale(0.9, 0.84)
	end

	v24.Size = size
	visible2 = root.AbsoluteSize.X < 870 or root.AbsoluteSize.Y < 450
	local v26 = root.AbsoluteSize.Y < 430
	local v27 = visible2 and 126 or 142
	local v28 = v27 + 28
	local v29 = v26 and 73 or 85
	root.Header.Size = UDim2.new(1, -12, 0, v26 and 52 or 56)
	root.Header.Close.Position = UDim2.new(1, -54, 0, 5)
	root.Header.Close.Size = UDim2.fromOffset(44, 44)
	root.Header.Title.TextSize = v26 and 25 or 28
	root.Header.Title.Size = UDim2.new(1, -330, 1, 0)
	root.Header.Search.Size = UDim2.fromOffset(root.AbsoluteSize.X < 650 and 170 or 240, 44)
	root.Header.Search.Position = UDim2.new(1, root.AbsoluteSize.X < 650 and -240 or -310, 0, 5)

	if root.AbsoluteSize.X < 650 then
		root.Header.Title.Size = UDim2.new(1, -255, 1, 0)
		root.Header.Title.TextSize = 20
	end

	root.NavTitle.Visible = not v26
	root.Tabs.Position = UDim2.fromOffset(14, v29)
	root.Tabs.Size = UDim2.new(0, v27, 1, -v29 - 40)
	root.Tabs.Layout.Padding = UDim.new(0, v26 and 6 or 10)

	for _, button in root.Tabs:GetChildren() do
		if button:IsA("TextButton") then
			button.Size = UDim2.new(1, -4, 0, v26 and 44 or 48)
		end
	end

	root.ListTitle.Position = UDim2.fromOffset(v28 + 6, v29)
	root.ListTitle.Size = UDim2.new(0, not visible2 and 220 or root.AbsoluteSize.X - v28 - 25, 0, 28)
	root.ListTitle.Visible = not (visible2 and v11)
	root.Cards.Position = UDim2.fromOffset(v28, v29 + 39)
	local cards = root.Cards
	local size2

	if visible2 then
		size2 = UDim2.new(1, -v28 - 16, 1, -v29 - 80)
	else
		size2 = UDim2.new(0, 224, 1, -v29 - 80)
	end

	cards.Size = size2
	root.Cards.Visible = not (visible2 and v11)
	root.NoResults.Position = UDim2.fromOffset(v28 + 6, v29 + 45)
	root.NoResults.Size = UDim2.new(0, not visible2 and 210 or root.AbsoluteSize.X - v28 - 30, 0, 42)
	local v31 = editor
	local v32

	if visible2 then
		v32 = v28
	else
		v32 = v28 + 240
	end

	v31.Position = UDim2.fromOffset(v32, v29)
	local v33 = editor

	if not visible2 then
		v28 += 240
	end

	v33.Size = UDim2.new(1, -v28 - 18, 1, -v29 - 40)
	editor.Visible = v14 ~= nil and (not visible2 or v11)
	editor.Close.Visible = visible2
	editor.Eyebrow.Visible = not v26
	editor.Eyebrow.Position = UDim2.fromOffset(visible2 and 125 or 20, 14)
	editor.Title.Position = UDim2.fromOffset(visible2 and 125 or 20, v26 and 12 or 35)
	editor.Title.Size = UDim2.new(1, -(visible2 and 142 or 40), 0, 35)
	editor.Title.TextSize = v26 and 19 or 24
	local v37 = v14 and v14.Id == "listps"
	editor.Description.Visible = not (v26 or v37)
	editor.Title.Visible = not (v37 and v26)
	editor.DirectorySearch.Visible = v37 == true
	local directorySearch = editor.DirectorySearch
	local position

	if v26 then
		position = UDim2.fromOffset(125, 10)
	else
		position = UDim2.fromOffset(20, 79)
	end

	directorySearch.Position = position
	editor.DirectorySearch.Size = UDim2.new(1, v26 and -142 or -40, 0, 44)
	whitelist.Search.Position = UDim2.fromOffset(16, v26 and 62 or 68)
	whitelist.Options.Position = UDim2.fromOffset(12, v26 and 114 or 122)
	whitelist.Options.Size = UDim2.new(1, -24, 1, v26 and -184 or -196)
	whitelist.Confirmation.Message.Position = UDim2.fromOffset(18, v26 and 44 or 52)
	whitelist.Confirmation.Message.Size = UDim2.new(1, -36, 0, v26 and 36 or 42)
	whitelist.Confirmation.Accounts.Position = UDim2.fromOffset(12, v26 and 84 or 98)
	whitelist.Confirmation.Accounts.Size = UDim2.new(1, -24, 1, v26 and -148 or -162)
	local v39 = v26 and 54 or v37 and 135 or 120
	local v40 = v26 and 80 or 103
	editor.Fields.Position = UDim2.fromOffset(14, v39)
	editor.Fields.Size = UDim2.new(1, -28, 1, -v39 - v40 - 8)
	local v41 = editor.Fields.AbsoluteSize.X >= 450 and (not v14 or v14.Id ~= "listps") and 2 or 1
	editor.Fields.Layout.CellSize = UDim2.new(1 / v41, -((v41 - 1) * 8 + 14) / v41, 0, 80)
	editor.Fields.Layout.CellPadding = UDim2.fromOffset(8, 8)
	editor.Help.Position = UDim2.fromOffset(20, v39)
	editor.Help.Size = UDim2.new(1, -40, 1, -v39 - v40 - 8)

	if v26 and v14 then
		editor.Help.Text = v14.Id == "freecam" and "Enable to start filming. Use the on-screen movement controls and drag to look." or v14.Id == "listps" and "No creator servers are available. Ask an admin to configure your access." or "Enable this tool below. Return here to disable it."
	end

	editor.ActionBar.Size = UDim2.new(1, 0, 0, v40)
	editor.ActionBar.Position = UDim2.new(0, 0, 1, -v40)
	editor.Reason.Position = UDim2.new(0, 18, 1, -v40 + 2)
	editor.Reason.Size = UDim2.new(1, -36, 0, v26 and 24 or 30)
	editor.Reason.TextSize = v26 and 11 or 12
	editor.Run.Position = UDim2.new(0, 18, 1, -54)
	editor.Reset.Position = UDim2.new(1, -107, 1, -54)
	editor.Run.Size = UDim2.new(1, editor.Reset.Visible and -136 or -36, 0, 44)
	root.Status.Hint.TextXAlignment = Enum.TextXAlignment.Right
	root.Status.Hint.Visible = not visible2
	root.Status.Server.Size = UDim2.new(visible2 and 1 or 0.55, -12, 1, 0)
	root.Status.Server.TextTruncate = Enum.TextTruncate.AtEnd
	picker.Title.Visible = not v26
	local search = picker.Search
	local position2

	if v26 then
		position2 = UDim2.fromOffset(124, 14)
	else
		position2 = UDim2.fromOffset(18, 77)
	end

	search.Position = position2
	picker.Search.Size = UDim2.new(1, v26 and -142 or -36, 0, 44)
	picker.Options.Position = UDim2.fromOffset(14, v26 and 70 or 135)
	picker.Options.Size = UDim2.new(1, -28, 1, v26 and -82 or -150)
	local v43 = v20 ~= "asset" and v20 ~= "egg" and v20 ~= "pet" and v20 ~= "target" and v20 ~= "guest" and 1 or math.max(
		1,
		(math.floor((picker.Options.AbsoluteSize.X - 14) / 130))
	)
	picker.Options.Layout.CellSize = UDim2.new(
		1 / v43,
		-((v43 - 1) * 10 + 14) / v43,
		0,
		(v20 == "target" or v20 == "guest" or v20 == "egg" or v20 == "pet") and 124 or (v20 == "asset" or v20 == "egg") and 112 or 48
	)
	picker.Options.Layout.CellPadding = UDim2.fromOffset(10, 10)
end

local function selectedActive()
	if not v14 then
		return false
	end

	local target = v15.target or localPlayer.UserId
	local v24

	if target == localPlayer.UserId then
		v24 = v9.Active
	else
		v24 = (v9.TargetActive or {})[tostring(target)] or {}
	end

	return v24[v14.Id] ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function paintToggle(p, flag3: boolean)
	local backgroundColor

	if flag3 then
		backgroundColor = color
	else
		backgroundColor = Color3.fromRGB(68, 68, 86)
	end

	p.BackgroundColor3 = backgroundColor
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ownServer()
	for _, server in v9.Servers do
		if server.OwnerUserId == localPlayer.UserId then
			return server
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ownSignature()
	local server = ownServer() -- equivalent call inferred; original call site unknown

	if server then
		return (`{server.Status}|{tostring(server.Enabled)}|{tostring(server.Current)}|{#server.Whitelist}`)
	end

	return ""
end

local function inputProblem()
	if not v14 or v14.Toggle and selectedActive() then
		return nil
	end

	if v14.Id == "myServer" then
		local server = ownServer() -- equivalent call inferred; original call site unknown

		if not server then
			return "Your creator server is not configured yet."
		end

		if server.Current then
			return "You are already in your server. Manage it below."
		end

		return nil
	else
		for _, field in v14.Fields do
			local v24 = v15[field]

			if field == "speed" or field == "size" or field == "amount" then
				local v25 = field == "size" and 0.1 or 1
				local v26

				if field == "speed" then
					v26 = 300
				elseif field == "size" then
					v26 = 100
				elseif (v14 and v14.Id) == "giveShards" then
					v26 = 1000000
				else
					v26 = 25
				end

				if type(v24) ~= "number" or v24 ~= v24 or v24 < v25 or v26 < v24 or field == "amount" and v24 % 1 ~= 0 then
					return "Enter " .. field .. " from " .. v25 .. " to " .. v26 .. "."
				end
			else
				if v24 ~= nil and v24 ~= "" then
					if field ~= "currency" then
						continue
					end

					-- equivalent call inferred; original call site unknown
					if balanceLabel(v24) then
						continue
					end
				end

				return "Choose " .. (field == "asset" and "an animal / egg type" or field == "zoneOrAll" and "a zone" or field == "guard" and "a guard" or field == "currency" and "what to give" or "a " .. field) .. " to continue."
			end
		end

		return nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shown(creatorCommand)
	if v9.Guest then
		return creatorCommand.Guest == true
	end

	return (not creatorCommand.Admin or v9.Admin) and (not creatorCommand.Owner or v9.Owns)
end

local function refreshView()
	refreshLauncher(root.Visible)
	fn3()

	if v9.Access then
		root.Tabs.Manage.Visible = v9.Admin

		for _, button in root.Tabs:GetChildren() do
			if button:IsA("TextButton") and button.Name ~= "Manage" then
				button.Visible = not v9.Guest or button.Name == "Servers"
			end
		end

		if v9.Guest and text3 ~= "Servers" then
			fn5("Servers")
			return
		end

		if not v9.Admin then
			editor.Follow.Visible = false
		end

		root.Status.Server.Text = not v9.Server and "PUBLIC SERVER" or v9.Server .. "  /  CREATOR SERVER"
		root.Status.Hint.Text = v9.Admin and "Admin access · All controls available" or v9.Guest and "Guest access · Join servers you are whitelisted on." or v9.Reserved and "Creator access · Server tools enabled" or v9.Owns and "Start your server from the Servers tab to unlock every tool." or "Join a creator server to start your session."
		local text = string.lower(root.Header.Search.Text)
		root.ListTitle.Text = text ~= "" and "Search results" or text3
		local count3 = 0

		for _, creatorCommand in CreatorCommands do
			local v24 = clonesById[creatorCommand.Id]
			local command = v9.Commands[creatorCommand.Id]
			local allowed = command and command.Allowed
			local v25 = v9.Active[creatorCommand.Id] ~= nil
			local visible

			if text == "" then
				visible = creatorCommand.Category == text3
			else
				visible = string.find(
					string.lower(creatorCommand.Title .. " " .. creatorCommand.Description .. " " .. creatorCommand.Id),
					text,
					1,
					true
				) ~= nil
			end

			if visible then
				if v9.Guest then
					visible = creatorCommand.Guest == true
				else
					visible = (not creatorCommand.Admin or v9.Admin) and (not creatorCommand.Owner or v9.Owns)
				end
			end

			v24.Visible = visible

			if v24.Visible then
				count3 += 1
			end

			v24.State.Text = v25 and "● Enabled" or allowed and "Ready" or "Locked"
			local state = v24.State
			local textColor

			if allowed or v25 then
				textColor = v7[creatorCommand.Category]
			else
				textColor = color2
			end

			state.TextColor3 = textColor
			v24.Action.Text = v25 and "ADJUST / TURN OFF  >" or allowed and "OPEN CONTROLS  >" or "VIEW ACCESS  >"
		end

		local noResults = root.NoResults
		noResults.Visible = count3 == 0 and not (visible2 and v11)

		if v14 and editor.Visible then
			local command = v9.Commands[v14.Id]
			local v25 = inputProblem()
			local v26

			if v14.Id == "myServer" then
				for _, server in v9.Servers do
					if server.OwnerUserId ~= localPlayer.UserId then
						continue
					end

					v26 = server
					break
				end
			end

			local reason = editor.Reason
			local text2

			if flag then
				text2 = "Applying your changes…"
			elseif v18 > os.clock() then
				text2 = "Guests will be notified, then returned to a public server."
			elseif command and command.Allowed and v25 then
				text2 = v25
			else
				text2 = not command and "Access unavailable." or command.Reason or "Access unavailable."
			end

			reason.Text = text2
			local reason2 = editor.Reason
			local textColor

			if command and command.Allowed then
				textColor = color
			else
				textColor = Color3.fromRGB(255, 153, 116)
			end

			reason2.TextColor3 = textColor
			local run = editor.Run
			local text4

			if flag then
				text4 = "Working…"
			elseif v18 > os.clock() then
				text4 = "Confirm close"
			elseif v14.Id == "myServer" then
				text4 = v26 and v26.Current and "You are in your server" or v26 and v26.Enabled and "Join my server" or "Start & join my server"
			elseif v14.Id == "listps" then
				text4 = "Refresh"
			elseif v14.Id == "joinps" then
				text4 = "Join server"
			elseif v14.Id == "manageWhitelist" then
				text4 = "Manage guests"
			elseif v14.Id == "invitePlayers" or v14.Id == "followPlayer" then
				text4 = "Find a player"
			elseif not v14.Toggle then
				text4 = "Apply"
			elseif selectedActive() then
				text4 = "On · Turn off"
			else
				text4 = "Off · Turn on"
			end

			run.Text = text4
			local run2 = editor.Run
			local color3

			if command and command.Allowed and not (flag or v25) then
				if v14.Confirm then
					color3 = Color3.fromRGB(255, 50, 50)
				else
					color3 = color
				end
			else
				color3 = Color3.fromRGB(85, 85, 105)
			end

			run2.BackgroundColor3 = color3
			local run3 = editor.Run
			run3.Active = command ~= nil and command.Allowed and not flag and v25 == nil

			if v14.Toggle and command and command.Allowed and not (flag or v25) then
				paintToggle(editor.Run, selectedActive()) -- equivalent call inferred; original call site unknown
			end

			local reset = editor.Reset
			reset.Visible = v14.Reset == true and not v14.Toggle
			editor.Reset.Text = "Reset"
			editor.Run.Size = UDim2.new(1, editor.Reset.Visible and -136 or -36, 0, 44)
			editor.Scope.Text = v9.Admin and "Admin mode · Choose a player to target, or leave it as yourself. Panel grants still never save." or "Panel items last for this session only and never save."
		end
	else
		root.Visible = false
		refreshLauncher(false)
		flag2 = false
		editor.Visible = false
		picker.Visible = false
		local v24 = GuiService
		local selectedObject2

		if selectedObject and selectedObject.Parent then
			selectedObject2 = selectedObject
		end

		v24.SelectedObject = selectedObject2
	end
end

local function applyState(state)
	if type(state) == "table" then
		local admin2 = v9.Admin

		if state.Lightweight == true and state.Access == true then
			local v24 = state.Admin == admin2
			state.Servers = not v24 and {} or v9.Servers
			state.PlacedEggs = not v24 and {} or v9.PlacedEggs
			state.PenPets = not v24 and {} or v9.PenPets
		end

		v9 = state

		if whitelist.Visible and whitelist.Options.Visible then
			fn()
		end

		local visible = whitelist.Visible or editor.Invite.Visible or editor.Follow.Visible or editor.Disguise.Visible or picker.Visible

		if v14 and not visible then
			local v24

			if v9.Admin == admin then
				if v14.Id == "myServer" and ownSignature() ~= v6 then
					v24 = v11
					fn4(v14)
					v11 = v24
				end
			else
				v24 = v11
				fn4(v14)
				v11 = v24
			end
		end

		refreshView()
		resize()
	end
end

local function send(p: string, p2)
	if flag then
		return nil
	end

	flag = true
	count += 1
	refreshView()
	local success, result = pcall(function()
		return request:InvokeServer(p, p2)
	end)
	flag = false

	if success and type(result) == "table" then
		applyState(result.State)

		if type(result.State) == "table" and not result.State.Lightweight then
			flag2 = false
			v17 = os.clock() + (root.Visible and 3 or 30)
		end

		if result.Message then
			notice(result.Message, result.Ok)
		end

		refreshView()
		return result
	else
		notice("Connection interrupted. Please try again.", false)
		refreshView()
		return nil
	end
end

local function playerOption(userId, displayName: string?, name: string?)
	local label

	if name then
		label = (displayName or name) .. " (@" .. name .. ") · " .. tostring(userId)
	else
		label = "User ID: " .. tostring(userId)
	end

	local v24 = {
		Value = userId,
		Label = label,
		Title = displayName or name or "Player",
		Subtitle = 0,
		Image = 0
	}
	local subtitle

	if name then
		subtitle = "@" .. name
	else
		subtitle = "ID: " .. tostring(userId)
	end

	v24.Subtitle = subtitle
	v24.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=420&h=420"
	return v24
end

local function optionsFor(p: string)
	local result = {}

	if p == "target" then
		for _, player in v9.Players do
			table.insert(result, (playerOption(player.UserId, player.DisplayName, player.Name)))
		end
	elseif p == "server" then
		for _, server in v9.Servers do
			table.insert(result, {
				Value = server.Id or tostring(server.OwnerUserId),
				Label = server.Name .. (not server.Enabled and " · Disabled" or " · " .. (server.Status or "Checking…"))
			})
		end
	elseif p == "currency" then
		for _, v24 in v9.Balances or {} do
			table.insert(result, {
				Value = v24.Value,
				Label = v24.Label
			})
		end
	elseif p == "egg" then
		for _, v24 in not v9.PlacedEggs and {} or v9.PlacedEggs[tostring(v15.target or localPlayer.UserId)] or {} do
			table.insert(result, {
				Value = v24.Uid,
				Title = v24.Title or v24.Label,
				Subtitle = v24.Subtitle or string.sub(v24.Uid, -6),
				Label = v24.Label .. " · " .. string.sub(v24.Uid, -6),
				Image = v24.Image
			})
		end
	elseif p == "pet" then
		for _, v24 in not v9.PenPets and {} or v9.PenPets[tostring(v15.target or localPlayer.UserId)] or {} do
			table.insert(result, {
				Value = v24.Uid,
				Title = v24.Title,
				Subtitle = v24.Subtitle,
				Label = v24.Label .. " · " .. v24.Subtitle,
				Image = v24.Image
			})
		end
	elseif p == "mutation" then
		for _, v24 in v9.Mutations or {} do
			table.insert(result, {
				Value = v24.Value,
				Label = v24.Label
			})
		end

		if v14 and v14.Id == "setPetMutation" then
			table.insert(result, {
				Value = Mutations.NO_MUTATION,
				Label = "No mutation"
			})
		end
	elseif p == "asset" then
		local v24 = {
			["Light 7"] = "Pegasus",
			["Light 8"] = "ArchAngel",
			["Dark 7"] = "Skeleton Horse",
			["Dark 8"] = "World Burner"
		}
		local v25 = {}

		for k, v26 in Assets.Directory do
			if v24[k] and Assets.Directory[v24[k]] then
				continue
			end

			local displayName = v26.DisplayName or k
			v25[displayName] = (v25[displayName] or 0) + 1
		end

		for k, v26 in Assets.Directory do
			if v24[k] and Assets.Directory[v24[k]] or (v9.ExcludedAssets or {})[k] then
				continue
			end

			local displayName = v26.DisplayName or k

			if v25[displayName] > 1 then
				displayName = k
			end

			local v28

			if v14 == nil then
				v28 = false
			else
				v28 = v14.Id == "giveAnimal" or v14.Id == "spawnMutatedPet"
			end

			local image

			if v28 then
				image = v26.Icon or "rbxassetid://83736894896123"
			else
				image = v26.Egg and v26.Egg.Icon or "rbxassetid://103094823152347"
			end

			table.insert(result, {
				Value = k,
				Label = displayName,
				Image = image
			})
		end
	elseif p == "prank" then
		result = {
			{
				Value = "fling",
				Label = "Fling · Launch into the air"
			},
			{
				Value = "slip",
				Label = "Slip · A brief sideways tumble"
			},
			{
				Value = "dropEgg",
				Label = "Drop egg · Drop a stolen egg"
			}
		}
	else
		if p == "zoneOrAll" then
			table.insert(result, {
				Value = "all",
				Label = "All zones"
			})
		end

		for k in Areas.Directory do
			table.insert(result, {
				Value = k,
				Label = k
			})
		end
	end

	table.sort(result, function(a, b)
		return a.Label < b.Label
	end)
	return result
end

local renderOptions

renderOptions = function()
	for _, guiObject in picker.Options:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local text = string.lower(picker.Search.Text)
	local v24 = {}

	for _, v25 in v19 do
		if not string.find(string.lower(v25.Label .. " " .. tostring(v25.Value)), text, 1, true) then
			continue
		end

		table.insert(v24, v25)
	end

	local function prepare(folder, layoutOrder: number)
		folder.Name = "Option" .. layoutOrder
		folder.ZIndex += 10

		for _, guiObject in folder:GetDescendants() do
			if guiObject:IsA("GuiObject") then
				guiObject.ZIndex += 10
			end
		end

		folder.Visible = true
		folder.LayoutOrder = layoutOrder
		folder.Parent = picker.Options
	end

	local v25 = v20 == "asset" or v20 == "egg" or v20 == "pet"
	local playerPicker = isPlayerPicker() -- equivalent call inferred; original call site unknown
	local v26 = v25 or playerPicker
	local playerTile

	if playerPicker or v20 == "egg" or v20 == "pet" then
		playerTile = templates.PlayerTile
	elseif v25 then
		playerTile = templates.AssetTile
	else
		playerTile = templates.Option
	end

	for i = 1, math.min(#v24, total) do
		local v27 = v24[i]
		local clone = playerTile:Clone()

		if v26 then
			clone.Image.Image = v27.Image
			clone.Title.Text = v27.Title or v27.Label

			if playerPicker or v20 == "egg" or v20 == "pet" then
				clone.Subtitle.Text = v27.Subtitle
			end

			local visible

			if v20 == nil then
				visible = false
			else
				visible = v15[v20] == v27.Value
			end

			clone.SelectionBadge.Visible = visible
			local stroke = clone.Stroke
			local color4

			if visible then
				color4 = color
			else
				color4 = Color3.fromRGB(114, 114, 135)
			end

			stroke.Color = color4
		else
			clone.Text = v27.Label
			clone.TextSize = 13
			clone.TextWrapped = true
		end

		clone.Selectable = v20 ~= nil
		clone.AutoButtonColor = v20 ~= nil
		prepare(clone, i)
		clone.Activated:Connect(function()
			local v29 = v20

			if not v29 then
				return
			end

			if fn6 then
				local v30 = fn6
				picker.Visible = false
				v30(v27)
			else
				v15[v29] = v27.Value

				if v29 == "target" and clonesByName.egg then
					v15.egg = nil
					clonesByName.egg.Choose.Text = "Choose an egg"
				end

				if v29 == "target" and clonesByName.pet then
					v15.pet = nil
					clonesByName.pet.Choose.Text = "Choose a pet"
				end

				clonesByName[v29].Choose.Text = v27.Label
				picker.Visible = false
				refreshView()
				focus(clonesByName[v29].Choose) -- equivalent call inferred; original call site unknown
			end
		end)
	end

	local v27 = #v24

	if total < v27 then
		local clone = playerTile:Clone()

		if v26 then
			clone.Image.Visible = false
			clone.SelectionBadge.Visible = false
			clone.Title.Text = "Load 100 more"

			if playerPicker or v20 == "egg" or v20 == "pet" then
				clone.Subtitle.Text = ""
			end
		else
			clone.Text = "Load 100 more"
		end

		prepare(clone, total + 1)
		clone.Activated:Connect(function()
			total += 100
			renderOptions()
		end)
	end

	local title = picker.Title
	local text2

	if #v24 == 0 then
		text2 = "No matches"
	elseif v25 then
		if v20 == "pet" then
			text2 = "Choose a pet"
		else
			text2 = grantsPet() and "Choose a pet" or "Choose an egg"
		end
	elseif v20 == "mutation" then
		text2 = "Choose a mutation"
	elseif v20 == nil then
		text2 = "Approved players"
	elseif v20 == "guest" then
		text2 = "Choose a guest"
	elseif playerPicker then
		text2 = "Choose a player"
	else
		text2 = "Choose an option"
	end

	title.Text = text2
	local search = picker.Search
	local placeholderText

	if v25 then
		local v31 = #v19
		local v32

		if v20 == "pet" then
			v32 = " pets..."
		else
			v32 = grantsPet() and " pets..." or " eggs..."
		end

		placeholderText = "Search " .. v31 .. v32
	else
		placeholderText = playerPicker and "Search name, username or user ID..." or "Search options..."
	end

	search.PlaceholderText = placeholderText
	resize()
end

local function openGuestPicker(id: string)
	local v24 = send("manageWhitelist", {
		action = "presence",
		server = id
	})

	if not (v24 and v24.Ok and v24.Data) then
		return
	end

	v19 = {}

	for _, account in v24.Data.Accounts do
		local here = account.Status == "Here"
		table.insert(v19, {
			Value = account.UserId,
			Here = here,
			Title = account.Name,
			Subtitle = here and "● In this server" or account.Status == "Online" and "● Online elsewhere" or account.Status == "Offline" and "● Offline" or "● Unknown",
			Label = `{account.Name} {account.UserId} {account.Status}`,
			Image = `rbxthumb://type=AvatarHeadShot&id={account.UserId}&w=420&h=420`
		})
	end

	if #v19 == 0 then
		notice("Add someone to your guest list first.", false)
		return
	end

	v20 = "guest"

	fn6 = function(p)
		if p.Here then
			send("sendps", {
				target = p.Value,
				server = id
			})
			return
		end

		local v25 = send("invitePlayers", {
			action = "guests",
			server = id,
			targets = { (tostring(p.Value)) }
		})

		if v25 and v25.Ok and v25.Data and v25.Data.Native then
			v21.Native(v25.Data.Native)
		end
	end

	total = 100
	picker.Search.Text = ""
	picker.Visible = true
	renderOptions()
	focus(picker.Back) -- equivalent call inferred; original call site unknown
end

local function filterServers()
	if not v14 or v14.Id ~= "listps" then
		return
	end

	local text = string.lower(editor.DirectorySearch.Text)
	local count3 = 0

	for _, guiObject in editor.Fields:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		guiObject.Visible = string.find(string.lower(guiObject:GetAttribute("SearchText") or ""), text, 1, true) ~= nil

		if guiObject.Visible then
			count3 += 1
		end
	end

	editor.Help.Visible = count3 == 0
	editor.Help.Text = text == "" and "No creator servers are available. Ask an admin to configure your access." or "No servers match that search."
end

-- equivalent calls inferred from this helper; original call sites unknown
local function whitelistServer()
	for _, server in v9.Servers do
		if (server.Id or tostring(server.OwnerUserId)) == server2 then
			return server
		end
	end

	return nil
end

fn3 = function()
	local count3 = 0

	for _ in v3 do
		count3 += 1
	end

	local visible3 = v5 == "list"
	whitelist.RemoveSelected.Visible = visible3 and count3 > 0
	whitelist.RemoveSelected.Text = `Remove {count3}`
	local server = whitelistServer() -- equivalent call inferred; original call site unknown
	local v26

	if server == nil then
		v26 = false
	else
		v26 = server.Enabled == true
	end

	local invite = whitelist.Invite

	if visible3 then
		if v9.Commands.invitePlayers == nil then
			visible3 = false
		else
			visible3 = v9.Commands.invitePlayers.Allowed == true
		end
	end

	invite.Visible = visible3
	local active = v26 and count3 > 0
	whitelist.Invite.Active = active
	whitelist.Invite.Text = not v26 and "Start your server to invite" or count3 == 0 and "Select guests to invite" or `Invite {count3}`
	local invite2 = whitelist.Invite
	local backgroundColor

	if active then
		backgroundColor = color
	else
		backgroundColor = Color3.fromRGB(85, 85, 105)
	end

	invite2.BackgroundColor3 = backgroundColor
	local visible = whitelist.RemoveSelected.Visible and whitelist.Invite.Visible
	local invite3 = whitelist.Invite
	local size

	if visible then
		size = UDim2.new(0.5, -20, 0, 44)
	else
		size = UDim2.new(1, -32, 0, 44)
	end

	invite3.Size = size
	local removeSelected = whitelist.RemoveSelected
	local position

	if visible then
		position = UDim2.new(0.5, 4, 1, -58)
	else
		position = UDim2.new(0, 16, 1, -58)
	end

	removeSelected.Position = position
	local removeSelected2 = whitelist.RemoveSelected
	local size2

	if visible then
		size2 = UDim2.new(0.5, -20, 0, 44)
	else
		size2 = UDim2.new(1, -32, 0, 44)
	end

	removeSelected2.Size = size2
end

local function whitelistPage(p: string)
	v5 = p
	whitelist.AddForm.Visible = p == "add"
	whitelist.Confirmation.Visible = p == "confirm"
	whitelist.Add.Visible = p == "list"
	whitelist.Search.Visible = p == "list"
	whitelist.Options.Visible = p == "list"
	whitelist.Empty.Visible = false
	local server = whitelistServer() -- equivalent call inferred; original call site unknown
	local v25 = server and server.Name:match("^CC_(.+)_%d+$") or "creator"
	whitelist.Title.Text = p == "add" and "Add guests" or "Guests · " .. v25
	fn3()
end

local function showWhitelistPreview(data)
	v2 = data
	local confirmation = whitelist.Confirmation

	for _, guiObject in confirmation.Accounts:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local v24 = editor.AbsoluteSize.Y < 350
	local v25 = math.max(1, (math.floor((confirmation.Accounts.AbsoluteSize.X - 14) / 130)))
	confirmation.Accounts.Layout.CellSize = UDim2.new(1 / v25, -((v25 - 1) * 10 + 14) / v25, 0, v24 and 96 or 124)
	confirmation.Accounts.Layout.CellPadding = UDim2.fromOffset(10, 10)

	for k, account in data.Accounts do
		local clone = templates.PlayerTile:Clone()
		clone.Name = "Account" .. account.UserId
		clone.Title.Text = account.Name
		clone.Subtitle.Text = "ID: " .. account.UserId
		clone.Image.Image = "rbxthumb://type=AvatarHeadShot&id=" .. account.UserId .. "&w=420&h=420"
		clone.SelectionBadge.Visible = false
		clone.Selectable = false
		clone.AutoButtonColor = false

		if v24 then
			clone.Image.Size = UDim2.fromOffset(40, 40)
			clone.Image.Position = UDim2.new(0.5, -20, 0, 4)
			clone.Title.Position = UDim2.new(0, 6, 0, 46)
			clone.Subtitle.Position = UDim2.new(0, 6, 0, 70)
		end

		for _, guiObject in clone:GetDescendants() do
			if guiObject:IsA("GuiObject") then
				guiObject.ZIndex += 26
			end
		end

		clone.ZIndex += 26
		clone.Visible = true
		clone.LayoutOrder = k
		clone.Parent = confirmation.Accounts
	end

	local v26 = data.Skipped and #data.Skipped or 0
	local message = confirmation.Message
	local v27

	if data.Remove then
		v27 = `Remove {#data.Accounts} guest(s) from {data.Server}?`
	else
		v27 = `Add {#data.Accounts} guest(s) to {data.Server}?`
	end

	message.Text = v27 .. (not (v26 > 0) and "" or ` {v26} skipped.`)
	confirmation.Confirm.Text = data.Remove and "Remove guests" or "Add guests"
	local confirm = confirmation.Confirm
	local backgroundColor

	if data.Remove then
		backgroundColor = Color3.fromRGB(255, 50, 50)
	else
		backgroundColor = color
	end

	confirm.BackgroundColor3 = backgroundColor
	v5 = "confirm"
	whitelist.AddForm.Visible = false
	whitelist.Confirmation.Visible = true
	whitelist.Add.Visible = false
	whitelist.Search.Visible = false
	whitelist.Options.Visible = false
	whitelist.Empty.Visible = false
	local server = whitelistServer() -- equivalent call inferred; original call site unknown
	local v30 = server and server.Name:match("^CC_(.+)_%d+$") or "creator"
	whitelist.Title.Text = "Guests · " .. v30
	fn3()
	focus(confirmation.Cancel) -- equivalent call inferred; original call site unknown
end

fn = function()
	if not whitelist.Visible then
		return
	end

	local server = whitelistServer() -- equivalent call inferred; original call site unknown

	if not server then
		whitelist.Visible = false
		return
	end

	for _, guiObject in whitelist.Options:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local v25 = {}

	for _, v26 in server.Guests or {} do
		v25[tostring(v26.UserId)] = true
	end

	for k in v3 do
		if not v25[k] then
			v3[k] = nil
		end
	end

	local text = string.lower(whitelist.Search.Text)
	local v26 = editor.AbsoluteSize.Y < 350
	local v27 = math.max(1, (math.floor((whitelist.Options.AbsoluteSize.X - 14) / 130)))
	whitelist.Options.Layout.CellSize = UDim2.new(1 / v27, -((v27 - 1) * 10 + 14) / v27, 0, v26 and 96 or 124)
	local count3 = 0

	for _, v28 in server.Guests or {} do
		if not string.find(string.lower(v28.Name .. " " .. v28.UserId), text, 1, true) then
			continue
		end

		count3 += 1
		local userId = tostring(v28.UserId)
		local clone = templates.PlayerTile:Clone()
		clone.Name = "Guest" .. v28.UserId
		clone.Title.Text = v28.Name
		clone.Subtitle.Text = "ID: " .. v28.UserId
		clone.Image.Image = "rbxthumb://type=AvatarHeadShot&id=" .. v28.UserId .. "&w=420&h=420"

		-- equivalent calls inferred from this helper; original call sites unknown
		local function paint()
			local visible = v3[userId] ~= nil
			clone.SelectionBadge.Visible = visible
			local stroke = clone.Stroke
			local color4

			if visible then
				color4 = Color3.fromRGB(255, 50, 50)
			else
				color4 = Color3.fromRGB(114, 114, 135)
			end

			stroke.Color = color4
		end

		paint() -- equivalent call inferred; original call site unknown

		if v26 then
			clone.Image.Size = UDim2.fromOffset(40, 40)
			clone.Image.Position = UDim2.new(0.5, -20, 0, 4)
			clone.Title.Position = UDim2.new(0, 6, 0, 46)
			clone.Subtitle.Position = UDim2.new(0, 6, 0, 70)
		end

		for _, guiObject in clone:GetDescendants() do
			if guiObject:IsA("GuiObject") then
				guiObject.ZIndex += 20
			end
		end

		clone.ZIndex += 20
		clone.Visible = true
		clone.LayoutOrder = count3
		clone.Parent = whitelist.Options
		local v31 = userId
		local v32 = v28
		local v33 = clone
		clone.Activated:Connect(function()
			local v34 = v3
			local v36

			if not v3[v31] then
				v36 = v32.Name
			end

			v34[v31] = v36
			paint() -- equivalent call inferred; original call site unknown
			fn3()
		end)
	end

	local empty = whitelist.Empty
	empty.Visible = count3 == 0 and whitelist.Options.Visible
	whitelist.Empty.Text = text == "" and "No guests yet. The creator always has access." or "No guests match that search."
	fn3()
end

local fn7

fn7 = function()
	local entries = whitelist.AddForm.Entries

	for _, guiObject in entries:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for k, text in v4 do
		local clone = templates.EntryRow:Clone()
		clone.Name = "Entry" .. k
		clone.LayoutOrder = k
		clone.Input.Text = text
		local v25 = accountsByQuery[text:match("^%s*(.-)%s*$")]

		if v25 and v25.UserId then
			clone.Avatar.Image = `rbxthumb://type=AvatarHeadShot&id={v25.UserId}&w=150&h=150`
			clone.Status.Text = `@{v25.Name} · {v25.UserId}`
			clone.Status.TextColor3 = color
		elseif v25 then
			clone.Avatar.Image = ""
			clone.Status.Text = "No account with that name or ID"
			clone.Status.TextColor3 = Color3.fromRGB(255, 153, 116)
		else
			clone.Avatar.Image = ""
			clone.Status.Text = "Checking…"
			clone.Status.TextColor3 = color2
		end

		for _, guiObject in clone:GetDescendants() do
			if guiObject:IsA("GuiObject") then
				guiObject.ZIndex += 20
			end
		end

		clone.ZIndex += 20
		clone.Visible = true
		clone.Parent = entries
		local v26 = k
		clone.Input:GetPropertyChangedSignal("Text"):Connect(function()
			v4[v26] = clone.Input.Text
		end)
		clone.Input.FocusLost:Connect(function()
			task.defer(function()
				fn7()
				fn2()
			end)
		end)
		local v28 = k
		clone.Discard.Activated:Connect(function()
			table.remove(v4, v28)
			fn7()
		end)
	end

	whitelist.AddForm.Lookup.Text = #v4 == 0 and "Add guests" or `Add {#v4} guest(s)`
	whitelist.AddForm.Lookup.Active = #v4 > 0
	local lookup = whitelist.AddForm.Lookup
	local backgroundColor

	if #v4 == 0 then
		backgroundColor = Color3.fromRGB(85, 85, 105)
	else
		backgroundColor = color
	end

	lookup.BackgroundColor3 = backgroundColor
end

fn2 = function()
	local v24 = {}
	local matches = {}

	for _, v25 in v4 do
		local match = v25:match("^%s*(.-)%s*$")

		if not (#match > 0) or accountsByQuery[match] ~= nil or v24[match] or not (#matches < 20) then
			continue
		end

		v24[match] = true
		table.insert(matches, match)
	end

	if #matches == 0 then
		return
	end

	local v25 = send("manageWhitelist", {
		action = "resolve",
		server = server2,
		queries = matches
	})

	if not (v25 and v25.Ok and v25.Data) then
		return
	end

	for _, account in v25.Data.Accounts do
		accountsByQuery[account.Query] = account
	end

	fn7()
end

local function queueWhitelistEntries(text: string)
	for k in string.gmatch(text, "[^%s,]+") do
		if #v4 >= 20 then
			notice("You can prepare 20 accounts at a time.", false)
			break
		else
			table.insert(v4, k)
		end
	end

	whitelist.AddForm.Query.Text = ""
	fn7()
	focus(whitelist.AddForm.Query) -- equivalent call inferred; original call site unknown
	fn2()
end

local function openWhitelist(server: string)
	server2 = server
	local v24 = send("manageWhitelist", {
		action = "list",
		server = server
	})

	if not (v24 and v24.Ok) then
		return
	end

	whitelist.Visible = true
	whitelist.Search.Text = ""
	table.clear(v3)
	table.clear(v4)
	table.clear(accountsByQuery)
	v5 = "list"
	whitelist.AddForm.Visible = false
	whitelist.Confirmation.Visible = false
	whitelist.Add.Visible = true
	whitelist.Search.Visible = true
	whitelist.Options.Visible = true
	whitelist.Empty.Visible = false
	local server3 = whitelistServer() -- equivalent call inferred; original call site unknown
	local v26 = server3 and server3.Name:match("^CC_(.+)_%d+$") or "creator"
	whitelist.Title.Text = "Guests · " .. v26
	fn3()
	fn()
	focus(whitelist.Add) -- equivalent call inferred; original call site unknown
end

whitelist.Add.Activated:Connect(function()
	v5 = "add"
	whitelist.AddForm.Visible = true
	whitelist.Confirmation.Visible = false
	whitelist.Add.Visible = false
	whitelist.Search.Visible = false
	whitelist.Options.Visible = false
	whitelist.Empty.Visible = false
	local server = whitelistServer() -- equivalent call inferred; original call site unknown
	local _ = server and server.Name:match("^CC_(.+)_%d+$")
	whitelist.Title.Text = "Add guests"
	fn3()
	whitelist.AddForm.Query.Text = ""
	fn7()
	focus(whitelist.AddForm.Query) -- equivalent call inferred; original call site unknown
end)
whitelist.AddForm.Queue.Activated:Connect(function()
	queueWhitelistEntries(whitelist.AddForm.Query.Text)
end)
whitelist.AddForm.Query.FocusLost:Connect(function(flag3: boolean)
	if flag3 then
		queueWhitelistEntries(whitelist.AddForm.Query.Text)
	end
end)
whitelist.RemoveSelected.Activated:Connect(function()
	local queries = {}

	for k in v3 do
		table.insert(queries, k)
	end

	if #queries == 0 then
		return
	end

	if #queries > 20 then
		notice("Remove up to 20 guests at a time.", false)
		return
	end

	local v25 = send("manageWhitelist", {
		action = "remove",
		server = server2,
		queries = queries
	})

	if v25 and v25.Ok and v25.Data then
		showWhitelistPreview(v25.Data)
	end
end)

local function backFromWhitelist()
	if not whitelist.AddForm.Visible then
		whitelist.Visible = false
		return
	end

	v5 = "list"
	whitelist.AddForm.Visible = false
	whitelist.Confirmation.Visible = false
	whitelist.Add.Visible = true
	whitelist.Search.Visible = true
	whitelist.Options.Visible = true
	whitelist.Empty.Visible = false
	local server = whitelistServer() -- equivalent call inferred; original call site unknown
	local v25 = server and server.Name:match("^CC_(.+)_%d+$") or "creator"
	whitelist.Title.Text = "Guests · " .. v25
	fn3()
	fn()
end

whitelist.Back.Activated:Connect(backFromWhitelist)
whitelist.Search:GetPropertyChangedSignal("Text"):Connect(fn)
whitelist.Options:GetPropertyChangedSignal("AbsoluteSize"):Connect(fn)
whitelist.AddForm.Lookup.Activated:Connect(function()
	local matches = {}

	for _, v24 in v4 do
		local match = v24:match("^%s*(.-)%s*$")

		if #match > 0 then
			table.insert(matches, match)
		end
	end

	if #matches == 0 then
		notice("Add at least one username or user ID.", false)
		return
	end

	local v24 = send("manageWhitelist", {
		action = "lookup",
		server = server2,
		queries = matches
	})

	if v24 and v24.Ok and v24.Data then
		showWhitelistPreview(v24.Data)
	end
end)

local function cancelWhitelist()
	local v24

	if v2 == nil then
		v24 = false
	else
		v24 = v2.Remove ~= true
	end

	v2 = nil

	if v24 and #v4 > 0 then
		v5 = "add"
		whitelist.AddForm.Visible = true
		whitelist.Confirmation.Visible = false
		whitelist.Add.Visible = false
		whitelist.Search.Visible = false
		whitelist.Options.Visible = false
		whitelist.Empty.Visible = false
		local server = whitelistServer() -- equivalent call inferred; original call site unknown
		local _ = server and server.Name:match("^CC_(.+)_%d+$")
		whitelist.Title.Text = "Add guests"
		fn3()
		fn7()
	else
		v5 = "list"
		whitelist.AddForm.Visible = false
		whitelist.Confirmation.Visible = false
		whitelist.Add.Visible = true
		whitelist.Search.Visible = true
		whitelist.Options.Visible = true
		whitelist.Empty.Visible = false
		local server = whitelistServer() -- equivalent call inferred; original call site unknown
		local v26 = server and server.Name:match("^CC_(.+)_%d+$") or "creator"
		whitelist.Title.Text = "Guests · " .. v26
		fn3()
		fn()
	end
end

whitelist.Confirmation.Cancel.Activated:Connect(cancelWhitelist)
whitelist.Confirmation.Confirm.Activated:Connect(function()
	if not v2 then
		return
	end

	local v24 = send("manageWhitelist", {
		action = "confirm",
		token = v2.Token
	})

	if v24 and v24.Ok then
		v2 = nil
		table.clear(v3)
		table.clear(v4)
		v5 = "list"
		whitelist.AddForm.Visible = false
		whitelist.Confirmation.Visible = false
		whitelist.Add.Visible = true
		whitelist.Search.Visible = true
		whitelist.Options.Visible = true
		whitelist.Empty.Visible = false
		local server = whitelistServer() -- equivalent call inferred; original call site unknown
		local v26 = server and server.Name:match("^CC_(.+)_%d+$") or "creator"
		whitelist.Title.Text = "Guests · " .. v26
		fn3()
		fn()
	end
end)

local function addField(name: string, layoutOrder: number)
	local clone = templates.Field:Clone()
	clone.Visible = true
	clone.Name = name
	clone.LayoutOrder = layoutOrder
	local label = clone.Label
	local text

	if name == "amount" and v14 and (v14.Id == "giveShards" and 1000000 or 25) == 1000000 then
		text = `AMOUNT · 1–{1000000}`
	else
		text = v8[name] or name
	end

	label.Text = text
	clone.Parent = editor.Fields
	clonesByName[name] = clone

	if name == "hideOtherUI" or name == "hideControls" then
		v15[name] = false
		clone.Label.Text = name == "hideControls" and "HIDE FREECAM CONTROLS" or "HIDE OTHER UI DURING FREECAM"
		clone.Choose.Text = "Off"
		clone.Choose.BackgroundColor3 = Color3.fromRGB(68, 68, 86)
		clone.Choose.Activated:Connect(function()
			local v25 = not v15[name]

			if selectedActive() then
				local v28 = {
					target = v15.target,
					enabled = true,
					settingsOnly = true,
					hideOtherUI = 0,
					hideControls = 0
				}
				local hideOtherUI

				if name == "hideOtherUI" then
					hideOtherUI = v25
				else
					hideOtherUI = v15.hideOtherUI == true
				end

				v28.hideOtherUI = hideOtherUI
				local hideControls

				if name == "hideControls" then
					hideControls = v25
				else
					hideControls = v15.hideControls == true
				end

				v28.hideControls = hideControls
				local v31 = send("freecam", v28)

				if not (v31 and v31.Ok) then
					return
				end
			end

			v15[name] = v25
			clone.Choose.Text = v15[name] and "On" or "Off"
			paintToggle(clone.Choose, v15[name]) -- equivalent call inferred; original call site unknown
		end)
	elseif name == "speed" or name == "size" or name == "amount" then
		clone.Input.Visible = true
		clone.Choose.Visible = false
		clone.Input.Text = tostring(name ~= "speed" and 1 or v9.Active.setSpeed or 32)
		v15[name] = tonumber(clone.Input.Text)
		clone.Input:GetPropertyChangedSignal("Text"):Connect(function()
			v15[name] = tonumber(clone.Input.Text)
			refreshView()
		end)
	else
		if name == "server" and #v9.Servers == 1 then
			v15[name] = v9.Servers[1].Id or tostring(v9.Servers[1].OwnerUserId)
			clone.Choose.Text = v9.Servers[1].Name
		end

		if name == "target" then
			v15[name] = localPlayer.UserId
			clone.Choose.Text = "You · " .. localPlayer.DisplayName
		end

		if name == "currency" and (v9.Balances or {})[1] then
			v15[name] = v9.Balances[1].Value
			clone.Choose.Text = v9.Balances[1].Label
		end

		clone.Choose.TextSize = 13
		clone.Choose.TextWrapped = true
		clone.Choose.Activated:Connect(function()
			v20 = name
			fn6 = nil
			v19 = optionsFor(name)
			total = 100
			picker.Search.Text = ""
			picker.Visible = true
			renderOptions()
			focus(picker.Back) -- equivalent call inferred; original call site unknown
		end)
	end
end

fn4 = function(data)
	editor.Invite.Visible = false
	editor.Follow.Visible = false
	editor.Disguise.Visible = false
	whitelist.Visible = false
	v11 = true

	if v14 then
		local v24 = {
			Values = table.clone(v15),
			Text = {}
		}

		for k, v25 in clonesByName do
			local text = v24.Text
			local v26

			if v25.Input.Visible then
				v26 = v25.Input.Text
			else
				v26 = v25.Choose.Text
			end

			text[k] = v26
		end

		v16[v14.Id] = v24
	end

	v14 = data
	v15 = {}
	clonesByName = {}
	v18 = 0
	editor.Title.Text = data.Title
	editor.Eyebrow.Text = string.upper(data.Category)
	editor.Accent.BackgroundColor3 = v7[data.Category]

	for k, v24 in clonesById do
		local backgroundColor

		if k == data.Id then
			backgroundColor = Color3.fromRGB(56, 70, 51)
		else
			backgroundColor = Color3.fromRGB(57, 57, 74)
		end

		v24.BackgroundColor3 = backgroundColor
		local stroke = v24.Stroke
		local color4

		if k == data.Id then
			color4 = color
		else
			color4 = Color3.fromRGB(114, 114, 135)
		end

		stroke.Color = color4
	end

	editor.Description.Text = data.Description

	for _, guiObject in editor.Fields:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local layoutOrder = 0

	for _, field in data.Fields do
		layoutOrder += 1
		addField(field, layoutOrder)
	end

	if data.Id == "freecam" then
		local layoutOrder2 = layoutOrder + 1
		local clone = templates.Field:Clone()
		clone.Visible = true
		clone.Name = "hideOtherUI"
		clone.LayoutOrder = layoutOrder2
		clone.Label.Text = v8.hideOtherUI or "hideOtherUI"
		clone.Parent = editor.Fields
		clonesByName.hideOtherUI = clone
		v15.hideOtherUI = false
		clone.Label.Text = "HIDE OTHER UI DURING FREECAM"
		clone.Choose.Text = "Off"
		clone.Choose.BackgroundColor3 = Color3.fromRGB(68, 68, 86)
		local v26 = "hideOtherUI"
		clone.Choose.Activated:Connect(function()
			local v27 = not v15[v26]

			if selectedActive() then
				local v30 = {
					target = v15.target,
					enabled = true,
					settingsOnly = true,
					hideOtherUI = 0,
					hideControls = 0
				}
				local hideOtherUI

				if v26 == "hideOtherUI" then
					hideOtherUI = v27
				else
					hideOtherUI = v15.hideOtherUI == true
				end

				v30.hideOtherUI = hideOtherUI
				local hideControls

				if v26 == "hideControls" then
					hideControls = v27
				else
					hideControls = v15.hideControls == true
				end

				v30.hideControls = hideControls
				local v33 = send("freecam", v30)

				if not (v33 and v33.Ok) then
					return
				end
			end

			v15[v26] = v27
			clone.Choose.Text = v15[v26] and "On" or "Off"
			paintToggle(clone.Choose, v15[v26]) -- equivalent call inferred; original call site unknown
		end)
		layoutOrder = layoutOrder2 + 1
		local clone2 = templates.Field:Clone()
		clone2.Visible = true
		clone2.Name = "hideControls"
		clone2.LayoutOrder = layoutOrder
		clone2.Label.Text = v8.hideControls or "hideControls"
		clone2.Parent = editor.Fields
		clonesByName.hideControls = clone2
		v15.hideControls = false
		clone2.Label.Text = "HIDE FREECAM CONTROLS"
		clone2.Choose.Text = "Off"
		clone2.Choose.BackgroundColor3 = Color3.fromRGB(68, 68, 86)
		local v27 = "hideControls"
		clone2.Choose.Activated:Connect(function()
			local v28 = not v15[v27]

			if selectedActive() then
				local v31 = {
					target = v15.target,
					enabled = true,
					settingsOnly = true,
					hideOtherUI = 0,
					hideControls = 0
				}
				local hideOtherUI

				if v27 == "hideOtherUI" then
					hideOtherUI = v28
				else
					hideOtherUI = v15.hideOtherUI == true
				end

				v31.hideOtherUI = hideOtherUI
				local hideControls

				if v27 == "hideControls" then
					hideControls = v28
				else
					hideControls = v15.hideControls == true
				end

				v31.hideControls = hideControls
				local v34 = send("freecam", v31)

				if not (v34 and v34.Ok) then
					return
				end
			end

			v15[v27] = v28
			clone2.Choose.Text = v15[v27] and "On" or "Off"
			paintToggle(clone2.Choose, v15[v27]) -- equivalent call inferred; original call site unknown
		end)
	end

	if (v9.Admin or v9.CanTarget) and not table.find(data.Fields, "target") and data.Id ~= "listps" and data.Id ~= "myServer" and data.Id ~= "freecam" and data.Id ~= "manageWhitelist" and data.Id ~= "openps" and data.Id ~= "closeps" and data.Id ~= "followPlayer" and data.Id ~= "disguisePlayer" then
		local layoutOrder2 = layoutOrder + 1
		local clone = templates.Field:Clone()
		clone.Visible = true
		clone.Name = "target"
		clone.LayoutOrder = layoutOrder2
		clone.Label.Text = v8.target or "target"
		clone.Parent = editor.Fields
		clonesByName.target = clone
		v15.target = localPlayer.UserId
		clone.Choose.Text = "You · " .. localPlayer.DisplayName
		clone.Choose.TextSize = 13
		clone.Choose.TextWrapped = true
		local v26 = "target"
		clone.Choose.Activated:Connect(function()
			v20 = v26
			fn6 = nil
			v19 = optionsFor(v26)
			total = 100
			picker.Search.Text = ""
			picker.Visible = true
			renderOptions()
			focus(picker.Back) -- equivalent call inferred; original call site unknown
		end)
	end

	if data.Id == "myServer" then
		local server = ownServer() -- equivalent call inferred; original call site unknown
		local count3 = 0

		local function row(text: string, text2: string)
			count3 += 1
			local clone = templates.Field:Clone()
			clone.Visible = true
			clone.LayoutOrder = count3
			clone.Label.Text = text
			clone.Choose.Text = text2
			clone.Choose.TextSize = 13
			clone.Choose.TextWrapped = true
			clone.Parent = editor.Fields
			return clone
		end

		if server then
			local formatted = `{#server.Whitelist} {#server.Whitelist == 1 and "guest" or "guests"} · Manage`
			count3 += 1
			local clone = templates.Field:Clone()
			clone.Visible = true
			clone.LayoutOrder = count3
			clone.Label.Text = "GUESTS"
			clone.Choose.Text = formatted
			clone.Choose.TextSize = 13
			clone.Choose.TextWrapped = true
			clone.Parent = editor.Fields
			clone.Choose.Activated:Connect(function()
				openWhitelist(server.Id)
			end)
		end

		if server then
			local text = server.Enabled and "Invite a player" or "Start your server first"
			count3 += 1
			local clone = templates.Field:Clone()
			clone.Visible = true
			clone.LayoutOrder = count3
			clone.Label.Text = "INVITE"
			clone.Choose.Text = text
			clone.Choose.TextSize = 13
			clone.Choose.TextWrapped = true
			clone.Parent = editor.Fields
			clone.Choose.Active = server.Enabled == true
			clone.Choose.Activated:Connect(function()
				if server.Enabled then
					v21.Open(server.Id)
				else
					notice("Start your server before inviting players.", false)
				end
			end)
			local text2 = server.Enabled and "Send a guest" or "Start your server first"
			count3 += 1
			local clone2 = templates.Field:Clone()
			clone2.Visible = true
			clone2.LayoutOrder = count3
			clone2.Label.Text = "SEND"
			clone2.Choose.Text = text2
			clone2.Choose.TextSize = 13
			clone2.Choose.TextWrapped = true
			clone2.Parent = editor.Fields
			clone2.Choose.Active = server.Enabled == true
			clone2.Choose.Activated:Connect(function()
				if server.Enabled then
					openGuestPicker(server.Id)
				else
					notice("Start your server before sending guests.", false)
				end
			end)
		end

		if server and server.Enabled then
			count3 += 1
			local clone = templates.Field:Clone()
			clone.Visible = true
			clone.LayoutOrder = count3
			clone.Label.Text = "CLOSE SERVER"
			clone.Choose.Text = "Close"
			clone.Choose.TextSize = 13
			clone.Choose.TextWrapped = true
			clone.Parent = editor.Fields
			local v26 = 0
			clone.Choose.Activated:Connect(function()
				local now = os.clock()

				if v26 <= now then
					v26 = os.clock() + 5
					clone.Choose.Text = "Confirm close"
				else
					local v27 = send("myServer", {
						action = "close"
					})

					if v27 and v27.Ok then
						fn4(data)
						return
					end

					v26 = 0
					clone.Choose.Text = "Close"
				end
			end)
		end

		local description = editor.Description
		local text4

		if server then
			if server.Current then
				text4 = `You are in {server.Name}. Every creator tool is unlocked here.`
			elseif server.Enabled then
				text4 = `{server.Name} is open. Join it to unlock every creator tool.`
			else
				text4 = `{server.Name} is closed. Start it to open your private server.`
			end
		else
			text4 = "Your creator access is not set up yet. Ask an admin to add you."
		end

		description.Text = text4
	end

	if data.Id == "listps" then
		for k, server in v9.Servers do
			local clone = templates.Field:Clone()
			clone.Visible = true
			clone.LayoutOrder = k
			clone:SetAttribute("SearchText", server.Name .. " " .. table.concat(server.Whitelist, " "))
			clone.Label.Text = server.Name .. " · " .. (server.Status or "Checking…")
			clone.Choose.Text = tostring(#server.Whitelist) .. " guests · Manage whitelist"
			clone.Choose.TextSize = 12
			clone.Choose.TextWrapped = true
			local v25 = server
			clone.Choose.Activated:Connect(function()
				openWhitelist(v25.Id or tostring(v25.OwnerUserId))
			end)
			clone.Parent = editor.Fields
		end

		if #v9.Servers == 0 then
			editor.Description.Text = "No creator servers are available to you yet."
		end
	end

	local v25 = v16[data.Id]

	if v25 then
		for k, v26 in clonesByName do
			if v25.Values[k] ~= nil then
				v15[k] = v25.Values[k]
			end

			if not v25.Text[k] then
				continue
			end

			if v26.Input.Visible then
				v26.Input.Text = v25.Text[k]
			else
				v26.Choose.Text = v25.Text[k]
			end
		end
	end

	for _, v26 in { "hideOtherUI", "hideControls" } do
		if not clonesByName[v26] then
			continue
		end

		paintToggle(clonesByName[v26].Choose, v15[v26] == true) -- equivalent call inferred; original call site unknown
	end

	local help = editor.Help
	local visible

	if data.Id == "freecam" or #data.Fields ~= 0 or v9.Admin or data.Id == "listps" or data.Id == "myServer" then
		if data.Id == "listps" then
			visible = #v9.Servers == 0
		else
			visible = false
		end
	else
		visible = true
	end

	help.Visible = visible
	editor.Help.Text = data.Id == "freecam" and [[
Move freely to frame your shot.

Keyboard: W A S D · Q / E
Mouse: hold right button to look
Touch: use the on-screen controls
Controller: sticks and triggers]] or data.Id == "listps" and "No creator servers are available. Ask an admin to configure your access." or "Enable this tool below.\nYou can return here to disable it at any time."

	if data.Id == "listps" then
		filterServers()
	end

	editor.Fields.CanvasPosition = Vector2.zero
	picker.Visible = false
	editor.Visible = true
	admin = v9.Admin
	v6 = ownSignature()
	refreshView()
	resize()
	local v27

	if visible2 then
		v27 = editor.Close
	else
		v27 = editor.Run
	end

	focus(v27) -- equivalent call inferred; original call site unknown

	if data.Id == "followPlayer" and v9.Admin and v22 then
		v22.Open()
	end
end

for k, creatorCommand in CreatorCommands do
	local clone = templates.CommandCard:Clone()
	clone.Name = creatorCommand.Id
	clone.LayoutOrder = k
	clone.Title.Text = creatorCommand.Title
	clone.Description.Visible = false
	clone.Action.Visible = false
	local clone2 = parent.UIKit.Icons[creatorCommand.Category]:Clone()
	clone2.Visible = true
	clone2.Parent = clone.Icon
	clone.Icon.BackgroundColor3 = v7[creatorCommand.Category]
	clone.Accent.BackgroundColor3 = v7[creatorCommand.Category]
	clone.Parent = root.Cards
	clonesById[creatorCommand.Id] = clone
	local v24 = creatorCommand
	clone.Activated:Connect(function()
		fn4(v24)
	end)
	local v26 = creatorCommand

	local function highlight(flag3: boolean)
		local stroke = clone.Stroke
		local tweenInfo = TweenInfo.new(0.12)
		local color3

		if flag3 then
			color3 = v7[v26.Category]
		elseif v14 and v14.Id == v26.Id then
			color3 = color
		else
			color3 = Color3.fromRGB(114, 114, 135)
		end

		TweenService:Create(stroke, tweenInfo, {
			Color = color3,
			Thickness = flag3 and 3 or 2
		}):Play()
	end

	local highlight2 = highlight
	clone.MouseEnter:Connect(function()
		highlight2(true)
	end)
	local highlight3 = highlight
	clone.MouseLeave:Connect(function()
		highlight3(false)
	end)
	local highlight4 = highlight
	clone.SelectionGained:Connect(function()
		highlight4(true)
	end)
	local highlight5 = highlight
	clone.SelectionLost:Connect(function()
		highlight5(false)
	end)
end

fn5 = function(p: string)
	text3 = p
	root.Header.Search.Text = ""

	for _, button in root.Tabs:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		paintToggle(button, button.Name == p) -- equivalent call inferred; original call site unknown
		local textColor

		if button.Name == p then
			textColor = Color3.new(1, 1, 1)
		else
			textColor = color2
		end

		button.TextColor3 = textColor
	end

	root.Cards.CanvasPosition = Vector2.zero
	root.ListTitle.Text = text3

	if visible2 then
		v11 = false
	else
		for _, creatorCommand in CreatorCommands do
			if creatorCommand.Category ~= text3 then
				continue
			end

			-- equivalent call inferred; original call site unknown
			if not shown(creatorCommand) then
				continue
			end

			fn4(creatorCommand)
			break
		end
	end

	refreshView()
	resize()
end

for _, button in root.Tabs:GetChildren() do
	if not button:IsA("TextButton") then
		continue
	end

	local v24 = button
	button.Activated:Connect(function()
		fn5(v24.Name)
	end)
end

local camera = root.Tabs.Camera
local camera2 = root.Tabs.Camera
local color3 = Color3.new(1, 1, 1)
camera.BackgroundColor3 = color
camera2.TextColor3 = color3
editor.Run.Activated:Connect(function()
	if not v14 or flag then
		return
	end

	local command = v9.Commands[v14.Id]

	if not (command and command.Allowed) then
		notice(command and command.Reason or "Access unavailable.", false)
		return
	end

	local text = inputProblem()

	if text then
		notice(text, false)
	elseif v14.Id == "myServer" then
		send("myServer", {
			action = "start"
		})
		fn4(v14)
	elseif v14.Id == "followPlayer" then
		v22.Open()
	elseif v14.Id == "disguisePlayer" and not selectedActive() then
		v23.Open()
	elseif v14.Id == "invitePlayers" then
		v21.Open((tostring(v15.server)))
	elseif v14.Id == "manageWhitelist" then
		openWhitelist(tostring(v15.server))
	elseif v14.Confirm and v18 <= os.clock() then
		v18 = os.clock() + 5
		editor.Reason.Text = "Guests will be notified, then returned to a public server."
		editor.Run.Text = "Confirm close"
	else
		local clone = table.clone(v15)

		if v14.Toggle then
			clone.enabled = not selectedActive()
		end

		local id = v14.Id
		local v25 = send(id, clone)
		v18 = 0

		if v25 and v25.Ok and id == "freecam" and clone.enabled then
			root.Visible = false
			refreshLauncher(false)
			flag2 = false
			editor.Visible = false
			picker.Visible = false
			local v26 = GuiService
			local selectedObject2

			if selectedObject and selectedObject.Parent then
				selectedObject2 = selectedObject
			end

			v26.SelectedObject = selectedObject2
		end

		if v25 and v25.Ok and id == "listps" then
			fn4(v14)
		end
	end
end)
editor.Reset.Activated:Connect(function()
	if v14 then
		local clone = table.clone(v15)
		clone.enabled = false
		clone.reset = true
		send(v14.Id, clone)
	end
end)
GUI.OnActivated(launcher, function()
	showPanel(not root.Visible)
end)
root.Header.Close.Activated:Connect(function()
	root.Visible = false
	refreshLauncher(false)
	flag2 = false
	editor.Visible = false
	picker.Visible = false
	local v24 = GuiService
	local selectedObject2

	if selectedObject and selectedObject.Parent then
		selectedObject2 = selectedObject
	end

	v24.SelectedObject = selectedObject2
end)
editor.Close.Activated:Connect(function()
	v11 = false
	resize()
	focus(v14 and clonesById[v14.Id]) -- equivalent call inferred; original call site unknown
end)

local function backFromPicker()
	picker.Visible = false
	local v24

	if visible2 then
		v24 = editor.Close
	else
		v24 = editor.Run
	end

	focus(v24) -- equivalent call inferred; original call site unknown
end

picker.Back.Activated:Connect(backFromPicker)
picker.Search:GetPropertyChangedSignal("Text"):Connect(function()
	total = 100
	picker.Options.CanvasPosition = Vector2.zero
	renderOptions()
end)
editor.DirectorySearch:GetPropertyChangedSignal("Text"):Connect(filterServers)
root.Header.Search:GetPropertyChangedSignal("Text"):Connect(function()
	if visible2 then
		v11 = false
	end

	root.Cards.CanvasPosition = Vector2.zero
	refreshView()
	resize()
end)
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
editor:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
editor.Fields.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or UserInputService:GetFocusedTextBox() then
		return
	end

	if input.KeyCode == Enum.KeyCode.F3 and Preferences.IsOn("CreatorPanel") then
		showPanel(not root.Visible)
	end
end)
StaffEntryHotkey.Changed:Connect(function()
	refreshLauncher(root.Visible)
end)
local v24 = panelEnabled() -- equivalent call inferred; original call site unknown
Preferences.Observe("CreatorPanel", function(flag3: boolean)
	if flag3 == v24 then
		return
	end

	v24 = flag3

	if not flag3 then
		root.Visible = false
		refreshLauncher(false)
		flag2 = false
		editor.Visible = false
		picker.Visible = false
		local v25 = GuiService
		local selectedObject2

		if selectedObject and selectedObject.Parent then
			selectedObject2 = selectedObject
		end

		v25.SelectedObject = selectedObject2
	end

	refreshLauncher(root.Visible)
end)
PlatformController.Changed:Connect(function()
	refreshLauncher(root.Visible)
end)
parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	refreshLauncher(root.Visible)
end)
local FollowPlayer = require(parent.FollowPlayer)
v22 = FollowPlayer.new(parent, send, notice)
local DisguisePlayer = require(parent.DisguisePlayer)
v23 = DisguisePlayer.new(parent, send, notice)
local Invitations = require(parent.Invitations)
v21 = Invitations.new(parent, send, notice)
local v25 = {
	{
		"CreatorPanel",
		root,
		root.Tabs.Camera,
		function()
			if visible2 and v11 and editor.Visible then
				v11 = false
				resize()
				focus(v14 and clonesById[v14.Id]) -- equivalent call inferred; original call site unknown
			else
				root.Visible = false
				refreshLauncher(false)
				flag2 = false
				editor.Visible = false
				picker.Visible = false
				local v26 = GuiService
				local selectedObject2

				if selectedObject and selectedObject.Parent then
					selectedObject2 = selectedObject
				end

				v26.SelectedObject = selectedObject2
			end
		end,
		1000
	},
	{
		"CreatorPicker",
		picker,
		picker.Back,
		backFromPicker,
		1010
	},
	{
		"CreatorWhitelist",
		whitelist,
		whitelist.Add,
		backFromWhitelist,
		1020
	},
	{
		"CreatorWhitelistConfirmation",
		whitelist.Confirmation,
		whitelist.Confirmation.Cancel,
		cancelWhitelist,
		1040
	},
	{
		"CreatorInvite",
		editor.Invite,
		editor.Invite.Find,
		v21.Back,
		1030
	},
	{
		"CreatorInviteConfirmation",
		editor.Invite.Confirmation,
		editor.Invite.Confirmation.Cancel,
		v21.CancelWhitelist,
		1050
	},
	{
		"CreatorFollow",
		editor.Follow,
		editor.Follow.Find,
		v22.Back,
		1030
	},
	{
		"CreatorDisguise",
		editor.Disguise,
		editor.Disguise.Find,
		v23.Back,
		1030
	},
	{
		"CreatorInvitePrompt",
		parent.InvitePrompt,
		parent.InvitePrompt.Decline,
		v21.Decline,
		1100
	}
}

for _, v26 in v25 do
	MenuNavigation.SetOverride(v26[1], v26[2], v26[3], v26[4], v26[5], true, true)
end

parent.Destroying:Connect(function()
	if launcher.Parent ~= parent then
		launcher:Destroy()
	end

	for _, v26 in v25 do
		MenuNavigation.SetOverride(v26[1], nil)
	end
end)
editor.Whitelist.Invite.Activated:Connect(function()
	local server = whitelistServer() -- equivalent call inferred; original call site unknown

	if not (server and server.Enabled) then
		notice("Start your server before inviting players.", false)
		return
	end

	local targets = {}

	for k in v3 do
		table.insert(targets, k)
	end

	if #targets == 0 then
		notice("Pick the guests you want to invite.", false)
		return
	end

	if #targets > 20 then
		notice("Invite up to 20 guests at a time.", false)
		return
	end

	local v28 = send("invitePlayers", {
		action = "guests",
		server = server2,
		targets = targets
	})

	if not (v28 and v28.Ok) then
		return
	end

	table.clear(v3)
	fn()

	if v28.Data and v28.Data.Native then
		v21.Native(v28.Data.Native)
	end
end)
local CameraEffects = require(parent.CameraEffects)
local v26 = CameraEffects.new(parent, function()
	send("freecam", {
		enabled = false
	})
end)
update.OnClientEvent:Connect(function(p: string, data)
	if p == "invite" then
		v21.Receive(data)
	elseif p == "notice" then
		notice(data)
	elseif p == "freecamSettings" then
		v26.SetFreecamSettings(data)
	elseif p == "effect" then
		v26.Set(data.Command, data.Enabled, data.HideOtherUI, data.HideControls)
	end
end)
parent.Destroying:Connect(function()
	v26.Destroy()
end)
local creatorPanelNotice = localPlayer:GetAttribute("CreatorPanelNotice")

if type(creatorPanelNotice) == "string" then
	notice(creatorPanelNotice)
end

for _, creatorCommand in CreatorCommands do
	if creatorCommand.Id ~= "freecam" then
		continue
	end

	fn4(creatorCommand)
	break
end

v11 = false
resize()
task.spawn(function()
	local WAIT_INTERVAL = 0.25

	while parent.Parent do
		if flag then
			task.wait(WAIT_INTERVAL)
		else
			local now = os.clock()

			if v17 <= now then
				local visible = root.Visible or flag2
				flag2 = false
				local v27 = count
				local now2 = os.clock()
				local success, result = pcall(function()
					return request:InvokeServer("snapshot", {
						lightweight = not visible
					})
				end)

				if not parent.Parent then
					break
				end

				local v29

				if success then
					if type(result) == "table" then
						v29 = type(result.State) == "table"
					else
						v29 = false
					end
				else
					v29 = success
				end

				if v29 and v27 == count then
					applyState(result.State)
				elseif visible and root.Visible and v27 == count then
					flag2 = true
				end

				local v30 = (v29 or success and type(result) == "table" and result.Message == "Please wait.") and 1.1 or 3
				local v31

				if flag2 then
					v31 = math.max(os.clock(), now2 + v30)
				else
					v31 = os.clock() + (root.Visible and 3 or 30)
				end

				v17 = v31
				task.wait(WAIT_INTERVAL)
			else
				task.wait(WAIT_INTERVAL)
			end
		end
	end
end)