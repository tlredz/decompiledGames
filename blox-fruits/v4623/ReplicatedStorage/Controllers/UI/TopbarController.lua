local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerProfileLookup = require(ReplicatedStorage.Controllers.UI.PlayerProfileLookup)
local MobileUIController = require(ReplicatedStorage.Controllers.UI.MobileUIController)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local Flags = require(game.ReplicatedStorage.Modules.Flags)
local Net = require(ReplicatedStorage.Modules.Net)
local HUD = require(ReplicatedStorage.Controllers.UI.HUD)
local AnalyticsUtil = require(ReplicatedStorage.Util.AnalyticsUtil)
local TopbarController = {}
local localPlayer = game.Players.LocalPlayer
local events = ReplicatedStorage.Events

local function reflectTopbarButtonVisiblity(p)
	local isNewUIEnabled = MobileUIController:IsNewUIEnabled()
	local menuOpenCloseButton = localPlayer.PlayerGui.Topbar.Frame.MenuOpenCloseButton

	for _, v in TopbarController:GetNewTopbarButtons() do
		local isOpen = isNewUIEnabled and menuOpenCloseButton:GetAttribute("IsOpen")

		if v.Name == "Crew" or v.Name == "Allies" then
			isOpen = isOpen and localPlayer.Team == game.Teams.Pirates
		end

		if v.Name == "MenuOpenCloseButton" then
			if p then
				isOpen = true
			else
				v.CloseIcon.Visible = true
				v.OpenIcon.Visible = false
				v:SetAttribute("IsOpen", true)
			end
		end

		if v.Name == "EnablePvPButton" then
			isOpen = isOpen and localPlayer:GetAttribute("PvpDisabled") == true
		end

		if v.Name == "MapButton" then
			isOpen = isOpen and localPlayer:GetAttribute("HasUnlockedMap") == true
		end

		v.Visible = isOpen
	end
end

function TopbarController:GetNewTopbarButtons()
	local result = {}

	for _, button in localPlayer.PlayerGui.Topbar.Frame.Buttons:GetChildren() do
		if button:IsA("GuiButton") then
			table.insert(result, button)
		end
	end

	table.insert(result, localPlayer.PlayerGui.Topbar.Frame.MenuOpenCloseButton)
	return result
end

function TopbarController.OnStart(_)
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local topbar = playerGui:WaitForChild("Topbar")
	local buttons = topbar:WaitForChild("Frame"):WaitForChild("Buttons")

	repeat
		task.wait()
	until localPlayer.Character and localPlayer.Character:IsDescendantOf(workspace.Characters)

	local isMobile = LastInput:IsMobile()

	if not game.GuiService:IsTenFootInterface() then
		playerGui:WaitForChild("ServerBrowser")
		local serverBrowserButton = topbar.Frame.ServerBrowserButton
		serverBrowserButton.Activated:Connect(function()
			local Global = require(game.ReplicatedStorage.Global)
			Global.toggleMenu("ServerBrowser")
		end)
		serverBrowserButton.Visible = true
	end

	if isMobile and Flags.NEW_MOBILE_CONTROLS_OPTION_ENABLED then
		buttons.SettingsButton.Activated:Connect(function()
			local Global = require(game.ReplicatedStorage.Global)
			Global.ToggleSettingsWindow()
		end)
		buttons.CrewButton.Activated:Connect(function()
			events.ToggleCrewWindow:Fire()
		end)
		buttons.AlliesButton.Activated:Connect(function()
			events.ToggleAllies:Fire()
		end)
		buttons.HomeButton.Activated:Connect(function()
			events.ActivateHomeButton:Fire()
		end)
		buttons.PlayerProfilesButton.Activated:Connect(function()
			assert(PlayerProfileLookup.IsInitialized, "bad player profile lookup")

			if PlayerProfileLookup:IsOpen() then
				PlayerProfileLookup:Close()
			else
				PlayerProfileLookup:Open(false)
			end
		end)
		local enablePvPButton = buttons.EnablePvPButton
		enablePvPButton.Activated:Connect(function()
			if not enablePvPButton:GetAttribute("IsEnabled") then
				return
			end

			events.EnablePvP:Fire()
		end)
		buttons.MapButton.Activated:Connect(function()
			AnalyticsUtil.reportActivity("HUD/Menu/Map")
			HUD:CloseOthers("Map")
			task.defer(function()
				local pageControllerAsync = HUD:GetPageControllerAsync("Map")

				if pageControllerAsync.isOpen() then
					pageControllerAsync.close()
				else
					pageControllerAsync.open()
				end
			end)
		end)

		for _, v in { "PvpDisabled", "HasUnlockedMap" } do
			localPlayer:GetAttributeChangedSignal(v):Connect(function()
				reflectTopbarButtonVisiblity()
			end)
		end

		local menuOpenCloseButton = topbar.Frame.MenuOpenCloseButton
		menuOpenCloseButton:SetAttribute("IsOpen", true)
		menuOpenCloseButton.Activated:Connect(function()
			local visible = not menuOpenCloseButton:GetAttribute("IsOpen")
			menuOpenCloseButton:SetAttribute("IsOpen", visible)
			menuOpenCloseButton.CloseIcon.Visible = visible
			menuOpenCloseButton.OpenIcon.Visible = not visible
			reflectTopbarButtonVisiblity(true)
		end)
		reflectTopbarButtonVisiblity()
		events.MobileUIModeUpdated.Event:Connect(reflectTopbarButtonVisiblity)
	end

	local flag = false
	local privateServerOwnerId = ReplicatedStorage:WaitForChild("PrivateServerOwnerId")

	local function vipServerOwnerChanged()
		local RunService = game:GetService("RunService")

		if not RunService:IsStudio() and localPlayer.UserId ~= privateServerOwnerId.Value or flag then
			return
		end

		flag = true
		local remoteEvent = Net:RemoteEvent("ToggleServerLock")
		local remoteEvent2 = Net:RemoteEvent("ShutdownVIPServer")
		local remoteEvent3 = Net:RemoteEvent("KickPlayer")
		local remoteEvent4 = Net:RemoteEvent("ToggleServerMode")
		local remoteEvent5 = Net:RemoteEvent("StartShutdownCountdown")
		local value = game.ReplicatedStorage.ServerLocked.Value == true
		local count = 0
		local count2 = 0
		local vIPServerOwnerCommands = topbar.VIPServerOwnerCommands
		local dropdown = vIPServerOwnerCommands.IconButton.Dropdown
		local dropdownScroller = dropdown.DropdownScroller
		local iconLabel = dropdownScroller.LockVIPServer:FindFirstChild("IconLabel", true)
		local iconLabel2 = dropdownScroller.ShutdownVIPServer:FindFirstChild("IconLabel", true)
		local iconLabel3 = dropdownScroller.ToggleServerMode:FindFirstChild("IconLabel", true)
		vIPServerOwnerCommands.Visible = true

		local function toggleLockServer()
			value = not value
			remoteEvent:FireServer()
			iconLabel.Text = value and "Server Entry: Locked 🔒" or "Server Entry: Unlocked 🔓"
		end

		if value then
			iconLabel.Text = value and "Server Entry: Locked 🔒"
		end

		local function shutdownOnSelect()
			count += 1
			count2 += 1

			if count2 == 1 then
				iconLabel2.Text = "Are you sure?"
				local v = count
				task.delay(1, function()
					if count2 == 1 and count == v then
						count2 = 0
						iconLabel2.Text = "Shutdown Server"
					end
				end)
			elseif count2 == 2 then
				iconLabel2.Text = "Shutting down..."
				remoteEvent2:FireServer()
			end
		end

		local kickPlayersFrame = playerGui.Main.KickPlayersFrame
		local list = kickPlayersFrame.List

		local function toggleKickPlayersFrame()
			kickPlayersFrame.Visible = not kickPlayersFrame.Visible
		end

		local v = {
			Default = "Default ⚔️",
			Passive = "Passive 🛡️",
			["Friendly PvP"] = "Friendly PvP 🤝"
		}
		local flag2 = false

		local function toggleServerMode()
			if flag2 then
				return
			end

			flag2 = true
			remoteEvent4:FireServer()

			for i = 15, 1, -1 do
				iconLabel3.Text = string.format("Cooldown (%s)", i)
				task.wait(1)
			end

			iconLabel3.Text = "PvP Mode: " .. v[ReplicatedStorage.ServerMode.Value]
			task.wait(0.1)
			flag2 = false
		end

		dropdownScroller.ShutdownVIPServer:FindFirstChild("ClickRegion", true).Activated:Connect(shutdownOnSelect)
		dropdownScroller.LockVIPServer:FindFirstChild("ClickRegion", true).Activated:Connect(toggleLockServer)
		dropdownScroller.KickPlayers:FindFirstChild("ClickRegion", true).Activated:Connect(toggleKickPlayersFrame)
		dropdownScroller.ToggleServerMode:FindFirstChild("ClickRegion", true).Activated:Connect(toggleServerMode)
		vIPServerOwnerCommands.IconButton.Menu:FindFirstChild("ClickRegion", true).Activated:Connect(function()
			dropdown.Visible = not dropdown.Visible
		end)
		task.defer(function()
			-- equivalent calls inferred from this helper; original call sites unknown
			local function updatePosition()
				local v2 = dropdown.AbsolutePosition.X + dropdown.AbsoluteSize.X + 10
				kickPlayersFrame.Position = UDim2.new(0, v2, 0, 8)
			end

			updatePosition() -- equivalent call inferred; original call site unknown
			dropdown:GetPropertyChangedSignal("AbsolutePosition"):Connect(updatePosition)
			local v2 = nil

			local function reflectSelectedState(p)
				if v2 == p then
					p.BackgroundColor3 = Color3.new(1, 1, 1)
					p.BorderColor3 = Color3.new(0, 0, 0)
				else
					p.BackgroundColor3 = Color3.new(0, 0, 0)
					p.BorderColor3 = Color3.new(1, 1, 1)
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function clearSelectedTile()
				if v2 then
					local v3 = v2
					v2 = nil
					reflectSelectedState(v3)
				end
			end

			dropdown:GetPropertyChangedSignal("Visible"):Connect(function()
				if not dropdown.Visible then
					kickPlayersFrame.Visible = false
					clearSelectedTile() -- equivalent call inferred; original call site unknown
				end
			end)
			kickPlayersFrame:GetPropertyChangedSignal("Visible"):Connect(function()
				if not kickPlayersFrame.Visible and v2 then
					local v3 = v2
					v2 = nil
					reflectSelectedState(v3)
				end
			end)
			kickPlayersFrame.List.KickPlayerTemplate.Visible = false

			local function playerAdded(p)
				if p == localPlayer then
					return
				end

				local clone = kickPlayersFrame.List.KickPlayerTemplate:Clone()
				clone.Visible = true
				clone.Name = p.Name
				clone.Text = string.format("%s (@%s)", p.DisplayName, p.Name)
				clone.Activated:Connect(function()
					local v3 = v2
					clearSelectedTile() -- equivalent call inferred; original call site unknown

					if v3 ~= clone then
						v2 = clone
						reflectSelectedState(clone)
					end
				end)
				clone.Parent = list
			end

			for _, v3 in game.Players:GetPlayers() do
				task.defer(playerAdded, v3)
			end

			game.Players.PlayerAdded:Connect(playerAdded)
			game.Players.PlayerRemoving:Connect(function(player)
				local child = list:FindFirstChild(player.Name)

				if child then
					child:Destroy()

					if child == v2 then
						v2 = nil
					end
				end
			end)
			kickPlayersFrame.Cancel.Activated:Connect(function()
				kickPlayersFrame.Visible = false
			end)
			kickPlayersFrame.Kick.Activated:Connect(function()
				if v2 then
					remoteEvent3:FireServer(v2.Name)
				end
			end)
			local listLayout = list.ListLayout

			-- equivalent calls inferred from this helper; original call sites unknown
			local function reflectCanvasSize()
				list.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y)
			end

			reflectCanvasSize() -- equivalent call inferred; original call site unknown
			listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(reflectCanvasSize)
		end)
		remoteEvent5.OnClientEvent:Connect(function()
			local shutdownCountdown = playerGui.Main.TopHUDList.ShutdownCountdown
			shutdownCountdown.Visible = true

			for i = 15, 1, -1 do
				shutdownCountdown.Text = "Shutting down in: " .. tostring(i)
				task.wait(1)
			end
		end)

		local function chatServerMode(p)
			local v2 = p == true and "PvP Mode is currently " or "PvP Mode changed to "
			local TextChatService = game:GetService("TextChatService")
			TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage((`<font color="#FFFF00">{v2 .. ReplicatedStorage.ServerMode.Value}</font>`))
		end

		local TextChatService = game:GetService("TextChatService")
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage((`<font color="#FFFF00">{"PvP Mode is currently " .. ReplicatedStorage.ServerMode.Value}</font>`))
		ReplicatedStorage.ServerMode.Changed:Connect(chatServerMode)
	end

	vipServerOwnerChanged()
	privateServerOwnerId.Changed:Connect(vipServerOwnerChanged)
end

return TopbarController