local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local MainAudioNew = require(ReplicatedStorage.Modules.Client.Components.Tools.UI.MainAudioNew)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local PrivateServerConstants = require(ReplicatedStorage.Modules.Shared.PrivateServer.PrivateServerConstants)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local v = Component.new({
	Tag = "PrivateServerServerTab"
})
local PrivateServerControlsPanel = require(ReplicatedStorage.Modules.Client.UI.PrivateServer.PrivateServerControlsPanel)
local InstanceMusicContext = require(ReplicatedStorage.Modules.Client.Music.InstanceMusicContext)
local UIToggle = require(ReplicatedStorage.Modules.Client.UI.Utils.UIToggle)
local MusicNavigationUtil = require(ReplicatedStorage.Modules.Client.Music.MusicNavigationUtil)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.SetupTimeControls(_) end

function v:OpenThemeMenu()
	local characterThemeMenu = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("NoResetGUIHandler"):WaitForChild("CharacterThemeMenu")
	characterThemeMenu.Catalog.Header.CategoryTabs["005Close"].ReopenPrivateServer.Value = true
	PanelController.OpenPanelByContext("NoResetGUIHandler", "CharacterThemeMenu")
end

function v:SetupFireControls()
	self.toggleFireButton = self.Instance.Row4.LegoFire.Content.Toggle
	self.fireEnabled = true
	self._Janitor:Add(self.toggleFireButton.Activated:Connect(function()
		self.fireEnabled = not self.fireEnabled
		Remotes.fireServerComponent(self.Instance, "ToggleFire", self.fireEnabled)
		self.toggleFireButton.Text = self.fireEnabled and "✅" or "❌"
	end))
end

function v:SetupVehicleContextualUpsellControls()
	self.toggleVehicleContextualUpsellButton = self.Instance.Row4.VehicleContextualUpsell.Content.Toggle
	self.vehicleContextualUpsellEnabled = true
	self._Janitor:Add(self.toggleVehicleContextualUpsellButton.Activated:Connect(function()
		if self.debouncedVehicleContextualUpsell then
			NotificationController.NotifyCenter("Please wait before toggling again")
			return
		end

		self.debouncedVehicleContextualUpsell = true
		task.delay(2, function()
			self.debouncedVehicleContextualUpsell = false
		end)
		self.vehicleContextualUpsellEnabled = not self.vehicleContextualUpsellEnabled
		Remotes.fireServerComponent(self.Instance, "ToggleVehicleContextualUpsell", self.vehicleContextualUpsellEnabled)
		self.toggleVehicleContextualUpsellButton.Text = self.vehicleContextualUpsellEnabled and "✅" or "❌"
	end))
end

function v:SetupThemeControls()
	self.themeButton = self.Instance.Row4.Theme.Content.ThemeButton
	self._Janitor:Add(self.themeButton.Activated:Connect(function()
		self:OpenThemeMenu()
		self.panelRef:CloseButtonPressed()
	end))
	local _1Theme1s = ReplicatedStorage.RE:WaitForChild("1Theme1s")
	self._Janitor:Add(_1Theme1s.OnClientEvent:Connect(function(p, p2)
		if p == "ServerThemeReady" then
			local themeIcon = PrivateServerConstants.ThemeIcons[p2]

			if not themeIcon then
				self.themeButton.ImageTransparency = 1
				return
			end

			self.themeButton.Image = themeIcon
			self.themeButton.ImageTransparency = 0
		elseif p == "DeleteServerTheme" then
			self.themeButton.ImageTransparency = 1
		end
	end))
end

function v:SetupAnnouncementControls()
	local announcement = self.Instance.Announcement
	local textBox = announcement.TextBox
	local buttons = announcement.Buttons
	local v2 = {
		buttons["1s"],
		buttons["3s"],
		buttons["5s"],
		buttons["10s"]
	}
	local send = buttons.Send
	self.selectedDuration = 3

	for _, v3 in v2 do
		local v4 = v3
		self._Janitor:Add(v3.Activated:Connect(function()
			for k, v5 in v2 do
				v5.Checkmark.Visible = false
			end

			v4.Checkmark.Visible = true
			self.selectedDuration = tonumber(v4.Name:match("%d+"))
		end))
	end

	local function send2()
		local text = textBox.Text

		if text == "" then
			return
		end

		Remotes.fireServerComponent(self.Instance, "SendAnnouncement", text, self.selectedDuration)
		send.Interactable = false
		send.BackgroundTransparency = 0.65
		task.delay(self.selectedDuration + 1, function()
			send.Interactable = true
			send.BackgroundTransparency = 0.3
		end)
		textBox.Text = ""
	end

	self._Janitor:Add(announcement.TextBox.FocusLost:Connect(function(flag: boolean)
		if not flag then
			return
		end

		send2()
	end))
	self._Janitor:Add(send.Activated:Connect(function()
		send2()
	end))
end

function v:SetupMusicControls()
	local music = self.Instance.Music
	local buttons = music.Buttons
	local mute = buttons.Mute
	local component = ComponentUtil.GetComponentFromInstance(mute, UIToggle)
	self._Janitor:Add(component.onToggle:Connect(function()
		Remotes.fireServerComponent(self.Instance, "SetMusic", component:isOn())
	end))

	local function openMusicPlayer()
		self.panelRef:CloseButtonPressed()
		local v2 = PanelController.WaitForPanel("MainGUIHandler", "MainAudioNew")

		if v2 == nil then
			return
		end

		local component2 = ComponentUtil.GetComponentFromInstance(v2:GetInstance(), MainAudioNew)
		component2:SetContext(self.context)

		function component2.closeCalled()
			PanelController.OpenPanelByContext("PrivateServerControlsGUI", "PrivateServerControlsPanel")
		end

		PanelController.Open("MainGUIHandler", "MainAudioNew")
	end

	self._Janitor:Add(buttons.Open.Activated:Connect(function()
		if GamepassController.IsOwned(Gamepasses.MUSIC_UNLOCKED) then
			openMusicPlayer()
		else
			GamepassController.Show(
				Gamepasses.MUSIC_UNLOCKED,
				nil,
				"private server audio",
				nil,
				nil,
				nil,
				"private server audio",
				"open music player",
				openMusicPlayer
			)
		end
	end))
	local textBox = music.TextBox
	local musicButtons = buttons.MusicButtons
	local pausePlay = musicButtons.PausePlay
	local next = musicButtons.Next
	local previous = musicButtons.Previous

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateStatus()
		local status = self.context:GetStatus()
		pausePlay.Image = status.isPlaying and "rbxassetid://114212393771017" or "rbxassetid://118117426385847"
		textBox.Text = status.track or ""
	end

	self._Janitor:Add(self.context:OnStatusUpdate():Connect(updateStatus))
	updateStatus() -- equivalent call inferred; original call site unknown
	local flag = false
	self._Janitor:Add(pausePlay.MouseButton1Click:Connect(function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function play()
			if self.context:GetStatus().isPlaying then
				self.context:Stop()
			else
				self.context:Play()
			end
		end

		if not GamepassController.IsOwned(Gamepasses.MUSIC_UNLOCKED) then
			GamepassController.Show(
				Gamepasses.MUSIC_UNLOCKED,
				nil,
				"private server audio",
				nil,
				nil,
				nil,
				"private server audio",
				"play",
				play
			)
			return
		end

		if flag then
			return
		end

		flag = true
		play() -- equivalent call inferred; original call site unknown
		task.wait(0.5)
		flag = false
	end))
	self._Janitor:Add(next.MouseButton1Click:Connect(function()
		if GamepassController.IsOwned(Gamepasses.MUSIC_UNLOCKED) then
			MusicNavigationUtil.selectNext(self.context)
		else
			GamepassController.Show(
				Gamepasses.MUSIC_UNLOCKED,
				nil,
				"private server audio",
				nil,
				nil,
				nil,
				"private server audio",
				"next",
				function()
					MusicNavigationUtil.selectNext(self.context)
				end
			)
		end
	end))
	self._Janitor:Add(previous.MouseButton1Click:Connect(function()
		if GamepassController.IsOwned(Gamepasses.MUSIC_UNLOCKED) then
			MusicNavigationUtil.selectPrevious(self.context)
		else
			GamepassController.Show(
				Gamepasses.MUSIC_UNLOCKED,
				nil,
				"private server audio",
				nil,
				nil,
				nil,
				"private server audio",
				"previous",
				function()
					MusicNavigationUtil.selectPrevious(self.context)
				end
			)
		end
	end))
end

function v:Start()
	self.context = InstanceMusicContext.new(Workspace:WaitForChild("PrivateServerGlobalMusic"), 0.75)
	self.context:Listen()
	self._Janitor:Add(self.context)
	self.panelRef = ComponentUtil.FindComponentByAncestor(
		self.Instance,
		"PrivateServerControlsPanel",
		PrivateServerControlsPanel
	)
	self:SetupThemeControls()
	self:SetupVehicleContextualUpsellControls()
	self:SetupAnnouncementControls()
	self:SetupMusicControls()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v