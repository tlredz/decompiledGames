local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("TweenService")
local SocialService = game:GetService("SocialService")
local SoundService = game:GetService("SoundService")
game:GetService("GuiService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("LocalizationService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Packages.Promise)
local v5 = require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Packages.Conch)
local v6 = require3(ReplicatedStorage2.Controllers.UI.InviteRewardsController)
local v7 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v8 = require3(ReplicatedStorage2.ClientGameModules.Icon)
local v9 = require3(ReplicatedStorage2.ServerInfo)
local v10 = require3(ReplicatedStorage2.Shared.GetServerType)
local localPlayer = Players.LocalPlayer
local isRankedLobby = ReplicatedStorage2.ServerInfo:WaitForChild("isRankedLobby")
local v11 = {}
local promisify = v4.promisify(function()
	return SocialService:CanSendGameInviteAsync(localPlayer)
end)
local TopBarController = {}

function TopBarController:Create(p)
	assert(not v8.getIcon(p), (`Icon {p} already exist!`))
	local v12 = v8.new():setName(p)
	table.insert(v11, v12)

	if GuiService:GetGuiInset().Y == 36 then
		v12:setLeft()
		return v12
	end

	v12:setRight()
	return v12
end

function TopBarController:GetIcon(p)
	return assert(v8.getIcon(p), (`{p} is not a valid TopBar icon!`))
end

function TopBarController.WaitForIcon(_, p)
	while not v8.getIcon(p) do
		task.wait()
	end

	return v8.getIcon(p)
end

function TopBarController:AddDropdown(p, object2)
	local icon = self:GetIcon(p)

	if table.find(icon.dropdownIcons, object2) then
		return
	end

	object2:joinDropdown(icon)
end

function TopBarController:RemoveDropdown(p, p2)
	local icon = self:GetIcon(p)
	local index = table.find(icon.dropdownIcons, p2)

	if not index then
		return
	end

	print("removing")
	icon:setDropdown((v5.List.remove(icon.dropdownIcons, index)))
end

function TopBarController:Notify(p)
	self:GetIcon(p):notify()
end

function TopBarController:Init()
	v8.modifyBaseTheme({
		{
			"Widget",
			"MinimumWidth",
			32,
			"Deselected"
		},
		{
			"Widget",
			"MinimumHeight",
			32,
			"Deselected"
		}
	})

	if v.TouchEnabled and not (v.KeyboardEnabled or v.GamepadEnabled) then
		local _ = not GuiService:IsTenFootInterface()
	end

	self:Create("DailyLogin"):setImage(15017879696):setLabel(""):setCaption("Login Rewards"):modifyTheme({
		{ "Notice", "BackgroundColor3", Color3.fromRGB(255, 55, 55) },
		{ "NoticeLabel", "TextColor3", Color3.fromRGB(255, 255, 255) },
		{ "NoticeUIStroke", "Color", Color3.fromRGB(255, 255, 255) }
	})
	self:Create("Extra"):setImage(14523245630):setLabel("EXTRA"):setCaption("These are special offers from the developers!"):modifyTheme({
		{ "Notice", "BackgroundColor3", Color3.fromRGB(255, 55, 55) },
		{ "NoticeLabel", "TextColor3", Color3.fromRGB(255, 255, 255) },
		{ "NoticeUIStroke", "Color", Color3.fromRGB(255, 255, 255) },
		{ "Dropdown", "MaxIcons", 3 }
	}).notified:Connect(function()
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://4590662766"
		SoundService:PlayLocalSound(sound)
	end)
end

function TopBarController:Start()
	if v9.isTutorialServer() then
		v8.setTopbarEnabled(false)
		return
	end

	v4.retryWithDelay(promisify, 5, 3.5):andThen(function(flag: boolean)
		if not (flag and v6:HasFriends()) then
			return
		end

		while workspace:GetAttribute("AreInvitesEnabled") == nil do
			workspace.AttributeChanged:Wait()
		end

		if not workspace:GetAttribute("AreInvitesEnabled") then
			return
		end

		self:AddDropdown(
			"Extra",
			(self:Create("InviteFriends"):setImage(14566188021):setLabel("INVITE FRIENDS"):disableStateOverlay(true):bindEvent(
				"selected",
				function(object2)
					v6:PromptFriendInvite()
					object2:deselect()
					local icon = self:GetIcon("Extra")

					if icon and icon.isSelected then
						icon:deselect()
					end
				end
			))
		)
	end):catch(warn)

	if not isRankedLobby.Value then
		local v12 = self:Create("PlayerStats"):setLabel("Stats"):setImage(14523680897):setCaption("View stats"):bindEvent(
			"selected",
			function()
				v7:Open("PersonalStats")
			end
		):bindEvent(
			"deselected",
			function()
				v7:Close("PersonalStats")
			end
		)
		v7:OnGuiClose("PersonalStats", function(_)
			if not v12.isSelected then
				return
			end

			v12:deselect()
		end)
	end

	self:Create("ToggleHUD"):setLabel("Hide UI"):setImage(15360127676):setCaption("Toggle HUD")
	self:Create("Settings"):setImage(14664859855):setLabel(""):setCaption("Settings")
	local v12 = self:Create("GiftInventory"):setImage(14523245630):setLabel(""):setCaption("Gift Inventory"):setEnabled(false)
	local v13 = self:Create("ColorSlash"):setImage(15385811618):setLabel("SLASH COLOR"):setCaption("Set the slash color!"):setOrder(1000)
	local v14 = self:Create("ServerBrowser"):setImage(7744394226):setLabel(""):setCaption("Server Browser"):setOrder(-1)
	self:AddDropdown("Extra", v13)
	local v15 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
	local v16 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
	local v17 = require3(ReplicatedStorage2.Shared.UseNewServerBrowser)() and "ServerBrowser" or "ServerBrowserOld"
	v14.toggled:Connect(function(flag: boolean, p)
		if p ~= "User" then
			return
		end

		if flag then
			v16:Open(v17, false, true)
		else
			v16:Close(v17)
		end
	end)
	v16:OnGuiClose(v17, function()
		v14:deselect()
	end)

	if not v9.isPrivateServer() and not v9.isReservedServer() and (v10() == "Normal" or v9.isProServer() or v9.isVoiceServer() or v9.isTradingPlazaServer() or v9.isProTradingPlazaServer() or v9.isFiftyPlayersServer() or v9.isDuelLobbyServer() or v9.isRankedLobbyServer()) then
		v14:setEnabled(false)
	end

	v13.toggled:Connect(function(flag: boolean, p)
		if p ~= "User" then
			return
		end

		if flag then
			v15:OpenColorPicker()
			v13:deselect()
		end
	end)
	local v18 = v2.Client:WaitReplion("Data")

	local function updateVIP()
		v13:setEnabled(v18:Find("GamePasses", "VIP") or v18:Get("Subscriptions.VIPPlus.Active"))
	end

	v18:OnChange("GamePasses", updateVIP)
	v18:OnChange("Subscriptions.VIPPlus.Active", updateVIP)
	v13:setEnabled(v18:Find("GamePasses", "VIP") or v18:Get("Subscriptions.VIPPlus.Active"))
	local currentCamera = workspace.CurrentCamera
	local v19 = false

	local function updateButtonPosition()
		local v20 = v12.enabled and 2 or 1
		local v21 = currentCamera.ViewportSize.X <= v20 * 30 + 480

		if v21 ~= v19 then
			v19 = v21
			local icon = self:GetIcon("DailyLogin")

			if v21 then
				icon:setLabel("DAILY LOGIN")
				self:AddDropdown("Extra", icon)

				if v12.enabled then
					v12:setLabel("GIFT INVENTORY")
					self:AddDropdown("Extra", v12)
				end
			else
				icon:setLabel("")
				self:RemoveDropdown("Extra", icon)

				if v12.enabled then
					v12:setLabel("")
					self:RemoveDropdown("Extra", v12)
				end
			end
		end
	end

	updateButtonPosition()
	currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateButtonPosition)

	if v9.isTestGame() and GuiService:IsTenFootInterface() then
		local v20 = self:Create("DevConsole"):setWidth(32):setLabel("🖥 DEV CONSOLE"):setCaption("Developer Console"):setOrder(2000)
		self:AddDropdown("Extra", v20)
		v20.toggled:Connect(function(flag: boolean, p)
			if p ~= "User" then
				return
			end

			StarterGui:SetCore("DevConsoleVisible", flag)

			if not flag then
				return
			end

			local success, rankInGroup = pcall(localPlayer.GetRankInGroup, localPlayer, 12836673)

			if not success or not rankInGroup or rankInGroup < 150 then
				return
			end

			v3:RemoteEvent("RequestLogs"):FireServer()
		end)
	end
end

return TopBarController