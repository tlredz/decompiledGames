local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local GuiService = game:GetService("GuiService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local Utils = require(ReplicatedStorage2.Common.Utils)
local Replion = require(ReplicatedStorage2.Packages.Replion)
local ServerInfo = require(ReplicatedStorage2.ServerInfo)
local v = Replion.Client:WaitReplion("Inventory")
local v2 = Replion.Client:WaitReplion("Data")
local localPlayer = game.Players.LocalPlayer
ServerInfo.isTrainingServer()
local huntPrivateServer = ServerInfo.isHuntPrivateServer()
local LTM = require(ReplicatedStorage2.Shared.LTM)
local LTMPackController = require(ReplicatedStorage2.Controllers.LTM.LTMPackController)
local PiggyBankController = require(ReplicatedStorage2.Controllers.PiggyBankController)
local CyberPackController = require(ReplicatedStorage2.Controllers.UI.CyberPackController)
local ValentinesBundleController = require(ReplicatedStorage2.Controllers.ValentinesBundleController)
local FreezePackController = require(ReplicatedStorage2.Controllers.Packs.FreezePackController)
local HellfirePackController = require(ReplicatedStorage2.Controllers.UI.HellfirePackController)
local LimitedTimePackController = require(ReplicatedStorage2.Controllers.LimitedTimePackController)
local Inventory = require(ReplicatedStorage2.Shared.Inventory)
Inventory = Inventory.Client
local v3 = v2:Get("TotalStats.Wins")
v2:OnChange("TotalStats.Wins", function()
	v3 = v2:Get("TotalStats.Wins")
end)

local function IsPointInArea(data, p)
	local position = p.Position
	local halfSize = p.Size / 2

	if data.X > position.X - halfSize.X and data.X < position.X + halfSize.X and data.Y > position.Y - halfSize.Y and data.Y < position.Y + halfSize.Y and data.Z > position.Z - halfSize.Z and data.Z < position.Z + halfSize.Z then
		return true
	end
end

local _ = workspace.MapBounds.Dead
local parent = script.Parent
local list = parent.List
local listLayout = list.ListLayout
local battlepassButton = list.BattlepassButton
local playstationPack = list.PlaystationPack
local cyberPack = list.CyberPack
local freezePack = list.FreezePack
local hellfirePack = list.HellfirePack
local piggyBank = list.PiggyBank
local valentinesBundle = list.ValentinesBundle
local _ = list.LTMPack
local limitedTimePack = list.LimitedTimePack
local currentLTM = LTM.getCurrentLTM()
local lobbyLTMPack

if currentLTM and currentLTM.LobbyLTM and currentLTM.IsActive() and currentLTM.Pack.IsEnabled then
	lobbyLTMPack = list.LobbyLTMPack
else
	lobbyLTMPack = list.LTMPack
end

local v4 = {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 0, 1, -12),
	Size = UDim2.fromScale(1, 0.182)
}
local v5 = {
	AnchorPoint = Vector2.zero,
	Position = UDim2.fromScale(0.7, 0.26),
	Size = UDim2.fromScale(0.182, 0.74)
}
local v6 = false

local function updateIsPlaystation()
	v6 = GuiService:IsTenFootInterface() and UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonB) == "ButtonCircle"
end

task.spawn(updateIsPlaystation)
UserInputService.GamepadConnected:Connect(updateIsPlaystation)
UserInputService.GamepadDisconnected:Connect(updateIsPlaystation)
local v7 = {
	[lobbyLTMPack] = function()
		local isActive = LTMPackController:IsActive() and ServerInfo.isLTMServer() or LTMPackController:IsActive() and LTM.LobbyLTM

		if LTMPackController:HasPack() or huntPrivateServer then
			isActive = false
		end

		return {
			timeLeft = LTMPackController:GetExpireTime(),
			isActive = isActive,
			isGlobalPack = true,
			stackable = true
		}
	end,
	[valentinesBundle] = function()
		return {
			timeLeft = ValentinesBundleController:GetExpireTime(),
			isActive = ValentinesBundleController:IsActive() and not huntPrivateServer,
			isGlobalPack = true,
			stackable = true
		}
	end,
	[playstationPack] = function()
		local offeredPlaySwordTimestamp = v2:Get("OfferedPlaySwordTimestamp")
		local v8 = {
			timeLeft = not offeredPlaySwordTimestamp and 0 or offeredPlaySwordTimestamp + 86400 - workspace:GetServerTimeNow(),
			isActive = 0,
			isGlobalPack = false
		}
		local isActive = not v2:Get("OwnsPlaystationPack") and v6

		if isActive then
			if v3 > 0 then
				isActive = not huntPrivateServer
			else
				isActive = false
			end
		end

		v8.isActive = isActive
		return v8
	end,
	[cyberPack] = function()
		return {
			timeLeft = CyberPackController:GetTimeLeft(),
			isActive = CyberPackController:IsActive() and not huntPrivateServer,
			isGlobalPack = false
		}
	end,
	[freezePack] = function()
		return {
			timeLeft = FreezePackController:GetTimeLeft(),
			isActive = FreezePackController:IsActive() and not huntPrivateServer,
			isGlobalPack = false
		}
	end,
	[hellfirePack] = function()
		return {
			timeLeft = HellfirePackController:GetTimeLeft(),
			isActive = HellfirePackController:IsActive() and not huntPrivateServer,
			isGlobalPack = false
		}
	end,
	[piggyBank] = function()
		return {
			timeLeft = 0.1,
			isActive = PiggyBankController:IsActive("Pack") and not huntPrivateServer,
			isGlobalPack = false
		}
	end,
	[limitedTimePack] = function()
		return {
			timeLeft = LimitedTimePackController:GetTimeLeft(),
			isActive = LimitedTimePackController:IsActive(),
			isGlobalPack = true
		}
	end
}

for k in v7 do
	k:SetAttribute("OriginalSize", k.Size)
end

local timeLeft = playstationPack.TimeLeft
local timerLabel = localPlayer:WaitForChild("PlayerGui"):WaitForChild("PlaystationPack"):WaitForChild("Frame"):WaitForChild("TimerLabel")
task.spawn(function()
	while true do
		local v8 = v2:Get("OfferedPlaySwordTimestamp") + 86400 - workspace:GetServerTimeNow()
		local formatTime = Utils.ValueConvertor:FormatTime(v8)
		timeLeft.Text = formatTime
		timerLabel.Text = formatTime
		task.wait(1)
	end
end)
local duelLobbyServer = ServerInfo.isDuelLobbyServer()
local size = battlepassButton.Size
battlepassButton.Visible = not huntPrivateServer
local v8 = nil
local v9 = nil
local total = 0

while true do
	local v10 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local v11

	if v10 then
		listLayout.FillDirection = Enum.FillDirection.Vertical
		listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		parent.IgnoreGuiInset = true
		battlepassButton.LayoutOrder = 0
		v11 = v5
	else
		listLayout.FillDirection = Enum.FillDirection.Horizontal
		listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		parent.IgnoreGuiInset = false
		battlepassButton.LayoutOrder = 1
		v11 = v4
	end

	if v10 ~= v8 then
		local size2

		if v10 then
			size2 = UDim2.fromScale(0.55, 0.22)
		else
			size2 = size
		end

		battlepassButton.Size = size2
		v8 = v10
	end

	if v11 ~= v9 and v11 then
		for k, v12 in v11 do
			list[k] = v12
		end

		v9 = v11
	end

	local character = localPlayer.Character
	list.Visible = duelLobbyServer or character and character.Parent == workspace.Dead

	if total >= 1 and not (v.Destroyed or v2.Destroyed) then
		local v12 = {}
		total = 0

		for k, callback in v7 do
			local success, result = pcall(callback)

			if success then
				if result then
					if result.isActive and not (result.timeLeft <= 0) then
						table.insert(v12, {
							hudButton = k,
							data = result
						})
					else
						k.Visible = false
					end
				end
			else
				warn((`Failed to update pack for {k:GetFullName()}: \n{result}`))
			end
		end

		table.sort(v12, function(a, b)
			local v13 = a.data.isGlobalPack and -1e99 or 0
			local v14 = b.data.isGlobalPack and -1e99 or 0
			return a.data.timeLeft + v13 < b.data.timeLeft + v14
		end)

		for k, v13 in v12 do
			local visible

			if workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then
				visible = false
			else
				visible = k == 1 or v13.data.stackable
			end

			v13.hudButton.Visible = visible
			v13.hudButton.LayoutOrder = v10 and 1 or 0

			if not visible then
				continue
			end

			local value = v13.hudButton:FindFirstChild("Value")
			local valueBP = v13.hudButton:FindFirstChild("ValueBP")
			local v15

			if valueBP and battlepassButton.Visible and not v10 then
				v15 = valueBP
			else
				v15 = value
			end

			local hudButton = v13.hudButton
			local size2

			if v10 then
				size2 = UDim2.fromScale(0.48, 0.18)
			else
				size2 = v13.hudButton:GetAttribute("OriginalSize")
			end

			hudButton.Size = size2

			if value then
				value.Visible = v15 == value
			end

			if valueBP then
				valueBP.Visible = v15 == valueBP
			end
		end
	end

	total += task.wait(0.5)
end