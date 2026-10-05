local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local RunService = game:GetService("RunService")
local v2 = require3(game.ReplicatedStorage.Shared.UseBall2)()
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.Packages.Net)
local v5 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Packages.Signal)
local v6 = require3(ReplicatedStorage2.Common.BoostsInfo)
local v7 = require3(ReplicatedStorage2.Common.ServerEventBoosts)
local v8 = require3(ReplicatedStorage2.Shared.AbilityIcons)
local v9 = require3(script.Parent.TopBarController)
local v10 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v11 = require3(ReplicatedStorage2.Shared.DynArgs)
local v12 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
local v13 = require3(ReplicatedStorage2.Shared.Ping)
local v14 = require3(ReplicatedStorage2.Common.Utils.Utilities.Icons)
local v15 = require3(ReplicatedStorage2.Shared.Statable)
local v16 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v17 = require3(ReplicatedStorage2.ClientGameModules.TextUtility)
local v18 = require3(ReplicatedStorage2.Common.MarketplaceService)
local v19 = require3(ReplicatedStorage2.ClientGameModules.Color)
local v20 = require3(ReplicatedStorage2.Controllers.AnalyticsController)
local v21 = require3(ReplicatedStorage2.Shared.GetServerType)
local v22 = require3(ReplicatedStorage2.ServerInfo)
local v23 = require3(ReplicatedStorage2.Controllers.Trading.TradeRequestController)
local v24 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local v25 = require3(ReplicatedStorage2.Controllers.Clans.ClanController)
local color = Color3.fromRGB(255, 0, 4)
local color2 = Color3.fromRGB(26, 255, 0)
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local HUD = localPlayer.PlayerGui:WaitForChild("HUD")
local hotbar = localPlayer.PlayerGui:WaitForChild("Hotbar")
local leftFrame = HUD.LeftFrame
local rightFrame = HUD.RightFrame
local remoteEvent = v4:RemoteEvent("ClansPageOpened")
local guiObjectsByName = {
	BottomOptions = leftFrame.Bottom.BottomOptions,
	MiddleStack = leftFrame.Middle.MiddleStack,
	Top = leftFrame.Top
}
local v26 = {
	"DailyQuestsPage",
	"Emote",
	"ShiftlockButton",
	"WelcomeBackButton",
	"MoneyFrame"
}
local childAddedConnection = nil

for _, guiObject in ipairs(leftFrame:GetDescendants()) do
	if not ((guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel")) and guiObject.Parent:IsA("Frame")) then
		continue
	end

	guiObjectsByName[guiObject.Name] = guiObject
end

local remotes = ReplicatedStorage2.Remotes
local hidden2 = v11.Or()
local hotBarHidden = v11.Or()
local condensed = v11.Or()

local function hideAllUI(_: boolean) end

local function getMissingContent()
	local result = {
		Middle = leftFrame.Middle
	}

	for k, v30 in guiObjectsByName do
		result[k] = v30
	end

	result.ShiftlockButton = nil
	return result
end

local v30 = HUD
local HUDController = {
	Hidden = hidden2,
	HotBarHidden = hotBarHidden,
	Condensed = condensed
}
v12.HideHotbar:InsertDynArgs(HUDController.HotBarHidden)

function HUDController.GetLeftFrameContent(_)
	return guiObjectsByName
end

function HUDController.SetHUDScreenGui(_, p, _: boolean)
	v30.Enabled = false
	v30 = p
	v30.Enabled = not hidden2.CurrentState
end

function HUDController:Show(p: string)
	if p then
		hidden2:SetTag(p, false)
		v12.HideHotbar:SetTag(p, false)
	end

	v30.Enabled = not hidden2.CurrentState
end

function HUDController:Hide(p: string)
	if p then
		hidden2:SetTag(p, true)
		v12.HideHotbar:SetTag(p, true)
	end

	v30.Enabled = not hidden2.CurrentState
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setAttributeOnce(instance, attributeName: string, p)
	if instance:GetAttribute(attributeName) ~= nil then
		return
	end

	instance:SetAttribute(attributeName, p)
end

function HUDController:Condense(p: string?)
	local v31 = {
		Middle = leftFrame.Middle
	}

	for k, v32 in guiObjectsByName do
		v31[k] = v32
	end

	v31.ShiftlockButton = nil

	for k, v32 in v31 do
		if not (v32.Visible or v32:GetAttribute("CondenseHiddenOriginal")) then
			continue
		end

		setAttributeOnce(v32, "CondenseHiddenOriginal", v32.Visible) -- equivalent call inferred; original call site unknown
		setAttributeOnce(v32, "CondensedPositionOriginal", v32.Position) -- equivalent call inferred; original call site unknown
		setAttributeOnce(v32, "CondensedAnchorPointOriginal", v32.AnchorPoint) -- equivalent call inferred; original call site unknown
		setAttributeOnce(v32, "CondensedSizeOriginal", v32.Size) -- equivalent call inferred; original call site unknown
		v32.Visible = table.find(v26, k) and true or false
	end

	if p then
		condensed:SetTag(p, true)
	end
end

function HUDController:Expand(p: string?)
	local v31 = {
		Middle = leftFrame.Middle
	}

	for k, v32 in guiObjectsByName do
		v31[k] = v32
	end

	v31.ShiftlockButton = nil

	for _, v32 in v31 do
		local condenseHiddenOriginal = v32:GetAttribute("CondenseHiddenOriginal")

		if condenseHiddenOriginal ~= nil then
			v32.Visible = condenseHiddenOriginal
		end
	end

	if p then
		condensed:SetTag(p, false)
	end
end

function HUDController:Open() end

function HUDController:Close() end

function HUDController:Toggle()
	self._toggleState = not self._toggleState
	self[self._toggleState and "Open" or "Close"](self)
end

function HUDController:_setupPageButton(instance)
	local v31 = assert(string.match(instance.Name, "(%w+)Page$"), (`{instance.Name} is not a valid page button!`))
	local onlyDead = instance:GetAttribute("OnlyDead")
	local excludeDeadInTrainingMode = instance:GetAttribute("ExcludeDeadInTrainingMode")
	v5.GuiUtils.getActivatedSignal(instance):Connect(function()
		if onlyDead and not (excludeDeadInTrainingMode and self._isTraining) then
			local character = localPlayer.Character

			if not character or character:IsDescendantOf(workspace.Alive) or localPlayer:GetAttribute("RespawnOverride") then
				ReplicatedStorage2.Misc.error:Play()
				return
			end
		end

		v16:Open(v31)
	end)
end

function HUDController:OpenColorPicker()
	local v31 = v3.Client:WaitReplion("Data")

	if v31:Find("GamePasses", "VIP") == nil and not v31:Get({ "Subscriptions", "VIPPlus", "Active" }) then
		v18:PromptGamePassPurchase(localPlayer, 223367086)
		return
	end

	if self._colorPicker then
		return
	end

	local expect = v31:GetExpect("SlashColor")
	local color3 = Color3.new(expect[1], expect[2], expect[3])
	local colorPicker = v19.New(HUD, mouse, {
		Position = UDim2.new(0.35, 0, 0.35, 0)
	})
	colorPicker:SetColor(color3)
	colorPicker.Finished:Connect(function(p2)
		self._colorPicker = nil
		remotes.ChangeSwordColor:FireServer(p2)
	end)
	colorPicker.Canceled:Connect(function()
		self._colorPicker = nil
	end)
	self._colorPicker = colorPicker
end

function HUDController:UpdateAFK(p)
	local uIGradient = guiObjectsByName.AFK.AFKText.UIGradient
	local color3

	if p then
		color3 = ColorSequence.new(color2)
	else
		color3 = ColorSequence.new(color)
	end

	uIGradient.Color = color3
end

function HUDController:UpdateMusic(p)
	if typeof(childAddedConnection) == "RBXScriptConnection" and childAddedConnection.Connected then
		childAddedConnection:Disconnect()
	end

	local volume = p and 0.1 or 0

	for _, sound in ReplicatedStorage2.Music:GetChildren() do
		if sound:IsA("Sound") then
			sound.Volume = volume
		end
	end

	childAddedConnection = ReplicatedStorage2.Music.ChildAdded:Connect(function(sound)
		if sound:IsA("Sound") then
			sound.Volume = volume
		end
	end)
	local IMG = guiObjectsByName.MusicButton.IMG
	local imageColor

	if p then
		imageColor = color2
	else
		imageColor = color
	end

	IMG.ImageColor3 = imageColor
end

function HUDController:OpenCoinsPurchase()
	local character = localPlayer.Character

	if not character or character:IsDescendantOf(workspace.Alive) or localPlayer:GetAttribute("RespawnOverride") then
		ReplicatedStorage2.Misc.error:Play()
		return
	end

	require3(script.Parent.ShopControllerAPI):OpenRobuxPage()
	local v31 = require3(script.Parent.ShopController)
	v31:Open()
	v31:GoTo("Robux")
end

function HUDController:SetCurrency(currency: string)
	self._currency = currency
	self._lastCurrencyChange = os.clock()
	local v31

	if currency == "Credits" then
		v31 = v14:GetIcon("CreditsSingle")
	else
		v31 = v14:GetIcon(currency)
	end

	guiObjectsByName.MoneyFrame.ImageLabel.Image = v31 or ""

	if self._currencyTween then
		self._currencyTween:Cancel()
		self._currencyTween:Destroy()
		self._currencyTween = nil
	end

	local replion = self._currencyAmountValue and v3.Client:GetReplion(currency == "Tokens" and "Inventory" or "Data")

	if replion then
		self._currencyAmountValue.Value = replion:Get(currency) or 0
	end
end

function HUDController:Init()
	self._isAFK = remotes.getAFKStatus:InvokeServer()
	self:UpdateAFK(self._isAFK)
	self._toggleState = true
end

function HUDController:Start()
	if v12.IsUICoveredState:Get() then
		self:Hide("IsCovered")
	end

	v12.IsUICoveredState:Connect(function(p)
		if p then
			self:Hide("IsCovered")
		else
			self:Show("IsCovered")
		end
	end)
	local v31 = {}
	local v32 = nil
	local v33 = nil

	for _, instance in {
		leftFrame.Bottom,
		leftFrame.Middle,
		leftFrame.Top,
		leftFrame.Bottom2
	} do
		local v35 = {
			Buttons = {},
			Instance = instance
		}

		for _, uIComponent in instance:QueryDescendants("GuiButton") do
			if uIComponent:IsA("UIComponent") then
				continue
			end

			local v36 = {
				Instance = uIComponent,
				Visible = v15.getPropertyState(uIComponent, "Visible")
			}

			if uIComponent.Name == "EmotePC" then
				if instance.Name == "Bottom" then
					v32 = v36
				else
					v33 = v36
				end
			end

			v35.Buttons[uIComponent.Name] = v36
		end

		v35.VisibleCount = v15.Computed(function(callback)
			local count = 0

			for k, button in v35.Buttons do
				if callback(button.Visible) then
					count += 1
				end
			end

			return count
		end)
		local v37 = instance
		v35.VisibleCount:Connect(function(p)
			v37.Visible = p > 0
		end)
		v31[instance.Name] = v35
	end

	local touchEnabled = v.TouchEnabled

	if touchEnabled then
		local gamepadEnabled = v.KeyboardEnabled and v.GamepadEnabled

		if gamepadEnabled then
			local GuiService = game:GetService("GuiService")
			gamepadEnabled = GuiService:IsTenFootInterface()
		end

		touchEnabled = not gamepadEnabled
	end

	local v34 = not touchEnabled

	if v32 and v33 then
		if v34 then
			local bottom = v31.Bottom
			local _ = v31.Bottom2
			local computed = v15.Computed(function(callback)
				if condensed.CurrentState then
					return nil
				end

				local v35 = callback(bottom.VisibleCount)

				if v35 > 0 and (v35 < 2 or v35 < 3 and callback(v32.Visible)) then
					return true
				end

				return false
			end)
			v15.Computed(function(callback)
				local v35 = callback(computed)
				local instance = v32.Instance
				instance.Visible = v35 ~= nil and v35
				local instance2 = v33.Instance
				instance2.Visible = v35 ~= nil and not v35
				return true
			end)
		else
			v32.Instance.Visible = false
			v33.Instance.Visible = false
		end
	end

	for _, button in guiObjectsByName do
		if not (button:IsA("GuiButton") and string.match(button.Name, "Page$")) then
			continue
		end

		self:_setupPageButton(button)
	end

	v5.GuiUtils.getActivatedSignal(guiObjectsByName.AFK):Connect(function()
		if workspace:GetAttribute("HackyBackToMainEnabled") then
			game.ReplicatedStorage.Remotes.RequestTeleportToMain:FireServer()
			return
		end

		self._isAFK = not self._isAFK
		self:UpdateAFK(self._isAFK)
		remotes.ChangedAfkMode:FireServer(self._isAFK)
	end)
	remotes.ChangedAfkMode.OnClientEvent:Connect(function(isAFK)
		self._isAFK = isAFK
		self:UpdateAFK(self._isAFK)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateAFK()
		if workspace:GetAttribute("HackyBackToMainEnabled") then
			guiObjectsByName.AFK.AFKText.Text = "Back"
			guiObjectsByName.AFK.AFKText.TextColor3 = BrickColor.new("Bright red").Color
		end
	end

	updateAFK() -- equivalent call inferred; original call site unknown
	workspace:GetAttributeChangedSignal("HackyBackToMainEnabled"):Connect(updateAFK)
	v5.GuiUtils.getActivatedSignal(guiObjectsByName.Toggle):Connect(function()
		self:Toggle()
	end)
	local rankButton = guiObjectsByName.RankButton
	local rankedLobbyServer = v22.isRankedLobbyServer()
	hotBarHidden:SetTag("RankedLobby", rankedLobbyServer)
	v12.HideHotbar:SetTag("RankedLobby", rankedLobbyServer)
	rankButton.Visible = rankedLobbyServer

	if rankedLobbyServer then
		v5.GuiUtils.getActivatedSignal(rankButton):Connect(function()
			v16:Open("RankMenu")
		end)
	end

	local medalTournamentLobby = v22.isMedalTournamentLobby()
	hotBarHidden:SetTag("MedalTournamentLobby", medalTournamentLobby)
	v12.HideHotbar:SetTag("MedalTournamentLobby", medalTournamentLobby)
	local wheel = localPlayer.PlayerGui:WaitForChild("Wheel")
	local enabled = v.TouchEnabled and not v.KeyboardEnabled and not v.GamepadEnabled and wheel.Enabled
	local clanButton = guiObjectsByName.BottomOptions.ClanButton
	local v35 = false
	local helpGuidePage = guiObjectsByName.HelpGuidePage
	local position = nil
	local _ = clanButton.Visible
	local v36 = v3.Client:WaitReplion("Data")
	v5.GuiUtils.getActivatedSignal(clanButton):Connect(function()
		local character = localPlayer.Character

		if not character or character:IsDescendantOf(workspace.Alive) or localPlayer:GetAttribute("RespawnOverride") then
			ReplicatedStorage2.Misc.error:Play()
			return
		end

		local v37 = v10:GetKey("ClansEnabled") == true
		local clansStartingUp = ReplicatedStorage2:GetAttribute("ClansStartingUp")
		local v38 = v36:Get("ClanId") ~= nil

		if v37 then
			if not clansStartingUp and (not v38 or v25.ClanReplion) then
				v16:Open("Clans")
				return
			end

			if _G.SendNotification then
				_G.SendNotification("Clans loading...")
			end

			if clansStartingUp then
				remoteEvent:FireServer()
			end
		elseif _G.SendNotification then
			_G.SendNotification("Clans are temporarily unavailable!")
		end

		ReplicatedStorage2.Misc.error:Play()
	end)

	local function updateFlags()
		v35 = v10:GetKey("ClanUIEnabled") == true and not (v22.isBossFightServer() or v22.isDungeonsMatchServer() or v22.isTournamentLobbyServer() or v22.isTournamentMatchServer() or v22.isTutorialServer() or v22.isAFKServer() or v22.isRhythmServer())
		local v38 = (((v36:Get("Kills") or 0) >= 3 or v36:Get("ClanId")) and true or false) and v35
		clanButton.Visible = v38 and ReplicatedStorage2.FeaturesToggle.Clans.Value

		if not v35 then
			v16:Close("Clans")
		end

		if not enabled then
			if not position then
				position = helpGuidePage.Position
			end

			local helpGuidePage2 = helpGuidePage
			local position2

			if v38 then
				position2 = position
			else
				position2 = clanButton.Position
			end

			helpGuidePage2.Position = position2
		end
	end

	task.spawn(function()
		v4:RemoteEvent("HideAllUI").OnClientEvent:Connect(function(hidden: boolean)
			for _, child in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
				if not (child:IsA("ScreenGui") or child:IsA("BillboardGui")) then
					continue
				end

				if hidden and child.Enabled then
					child:SetAttribute("Hidden", hidden)
					child.Enabled = not hidden
				elseif not hidden and child:GetAttribute("Hidden") == true then
					child:SetAttribute("Hidden", hidden)
					child.Enabled = not hidden
				end
			end
		end)
	end)
	v20:GetRemoteConfigValue("HelpGuideButtonEnabled", false):andThen(function(flag: boolean?)
		local visible = flag and true or false
		helpGuidePage.Visible = visible
		local position2 = helpGuidePage.Position + UDim2.fromScale(0.02, 0)

		if visible or rankedLobbyServer then
			if not visible and rankedLobbyServer then
				guiObjectsByName.RankButton.Position = position2
			end
		else
			guiObjectsByName.SettingsButton.Position = position2
		end
	end):catch(warn)
	v36:OnChange("TotalStats.Wins", updateFlags)
	v36:OnChange("Kills", updateFlags)
	task.spawn(updateFlags)
	v10.DataUpdatedEvent:Connect(updateFlags)
	local v37 = v22.isDungeonsMatchServer() or v22.isDungeonsLobbyServer()
	local tradingPlazaServer = v22.isTradingPlazaServer()
	local v38 = { "Credits" }

	if v37 then
		table.insert(v38, "DungeonRunes")
	elseif tradingPlazaServer then
		table.insert(v38, "Tokens")
	end

	guiObjectsByName.MoneyFrame.SwitchCurrency.Activated:Connect(function()
		local v39 = (table.find(v38, self._currency) or 1) + 1
		self:SetCurrency(v38[#v38 < v39 and 1 or v39])
	end)
	local visible2 = v37 or tradingPlazaServer
	guiObjectsByName.MoneyFrame.SwitchCurrency.Visible = visible2
	guiObjectsByName.MoneyFrame.OpenShop.Visible = tradingPlazaServer or not visible2
	self:SetCurrency(v37 and "DungeonRunes" or tradingPlazaServer and "Tokens" or "Credits")
	local numberValue = Instance.new("NumberValue")
	self._currencyAmountValue = numberValue
	numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		local value = math.round(numberValue.Value)
		guiObjectsByName.MoneyFrame.MoneyLabel.Text = v17.commify(value)
	end)
	ReplicatedStorage2.Remotes.TemporarilyDisableSFX.OnClientEvent:Connect(function(p: number?)
		local volume = SoundService.SFX.Volume
		SoundService.SFX.Volume = 0
		task.wait(tonumber(p) or 0.5)
		SoundService.SFX.Volume = volume
	end)

	for _, v40 in v38 do
		local v41 = v3.Client:WaitReplion(v40 == "Tokens" and "Inventory" or "Data")
		local v42 = v40
		v41:OnChange(v40, function(p: number, p2: number)
			if p2 < p then
				ReplicatedStorage2.Misc.Coins:Play()

				if v42 == "Credits" then
					local character = localPlayer.Character
					local primaryPart

					if character then
						primaryPart = character.PrimaryPart
					end

					if primaryPart then
						local clone = ReplicatedStorage2.Misc.MoneyGet:Clone()
						clone.Parent = primaryPart
						clone.CFrame = primaryPart.CFrame
						clone.WeldConstraint.Part1 = primaryPart
						Debris:AddItem(clone, 2)
						clone.At2.sparkles:Emit(5)
						clone.At2.ParticleEmitter:Emit(10)
					end
				end
			else
				ReplicatedStorage2.Misc.Purchase:Play()
			end

			if v42 == self._currency then
				if self._currencyTween then
					self._currencyTween:Cancel()
					self._currencyTween:Destroy()
					self._currencyTween = nil
				end

				local tween = TweenService:Create(numberValue, TweenInfo.new(1.5), {
					Value = p
				})
				self._currencyTween = tween
				tween:Play()
			end
		end)

		if v40 ~= self._currency then
			continue
		end

		numberValue.Value = v41:GetExpect(self._currency)
		guiObjectsByName.MoneyFrame.MoneyLabel.Text = v17.commify((math.round(numberValue.Value)))
	end

	if tradingPlazaServer then
		guiObjectsByName.MoneyFrame.MoneyLabel.Size = UDim2.fromScale(0.335, 0.546)
		guiObjectsByName.MoneyFrame.OpenShop.Position = UDim2.fromScale(0.733, 0.493)
		guiObjectsByName.MoneyFrame.OpenShop.Size = UDim2.fromScale(1, 0.7)
	end

	v5.GuiUtils.getActivatedSignal(guiObjectsByName.MoneyFrame.OpenShop):Connect(function()
		if self._currency ~= "Tokens" then
			self:OpenCoinsPurchase()
			return
		end

		v23:OpenPage("TokensShop")
		v16:Open("TradeRequest")
	end)
	self:UpdateMusic(v36:GetExpect("MusicEnabled"))
	v5.GuiUtils.getActivatedSignal(guiObjectsByName.MusicButton):Connect(function()
		local v40 = not v36:GetExpect("MusicEnabled")
		self:UpdateMusic(v40)
		remotes.MuteMusic:FireServer(v40)
	end)

	if v22.isRankedLobbyServer() then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateVisibility()
			HUDController:Show()
		end

		updateVisibility() -- equivalent call inferred; original call site unknown
		rankedLobbyServer:GetPropertyChangedSignal("Value"):Connect(updateVisibility)
	end

	guiObjectsByName.RankedPlacements.Visible = false

	if v22.isRankedMatchServer() then
		local rankedPlacements = localPlayer.PlayerGui:WaitForChild("RankedPlacements")
		v5.GuiUtils.getActivatedSignal(guiObjectsByName.RankedPlacements):Connect(function()
			rankedPlacements.Enabled = not rankedPlacements.Enabled
			rankedPlacements.Main.Visible = rankedPlacements.Enabled
		end)
		local v40 = v3.Client:WaitReplion("RankedMatch")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateRankedPlacementVisibility()
			local gameActive = v40:Get("GameActive")
			local gameEnded = v40:Get("GameEnded")
			local waitingForPlayers = v40:Get("WaitingForPlayers")
			guiObjectsByName.RankedPlacements.Visible = gameActive or gameEnded or not waitingForPlayers
		end

		updateRankedPlacementVisibility() -- equivalent call inferred; original call site unknown
		v40:OnDataChange(updateRankedPlacementVisibility)
	end

	local serverInfoLabel = HUD.ServerInfoLabel
	local pingLabel = HUD.PingLabel
	local v40 = game.GameId ~= 4777817887

	if v40 then
		serverInfoLabel.Text = string.format("TEST SERVER | Version %s", game.PlaceVersion)

		if v2 then
			serverInfoLabel.Text ..= " (BALL 2 ENABLED)"
		end

		local v41 = v21()

		if v41 == "Ranked" then
			local v42 = rankedLobbyServer.Value and "Ranked Lobby" or "Ranked Match"
			serverInfoLabel.Text ..= " | " .. v42
		else
			serverInfoLabel.Text ..= " | " .. v41
		end
	end

	serverInfoLabel.Visible = v40 and not RunService:IsStudio()
	RunService.PostSimulation:Connect(function(_: number)
		pingLabel.Text = `{math.round((v13.Get(localPlayer) or 0) * 1000)}ms`
	end)
	pingLabel.Visible = v36:Get({
		"Settings",
		"Misc",
		"Show Ping",
		"Enabled"
	})
	v36:OnChange({
		"Settings",
		"Misc",
		"Show Ping",
		"Enabled"
	}, function(visible)
		pingLabel.Visible = visible
	end)
	self._isTraining = v22.isTrainingServer()
	local boosts = HUD.Boosts
	local tooltip = boosts.UIListLayout.Tooltip
	local RunService2 = game:GetService("RunService")

	if RunService2:IsStudio() then
		boosts.Visible = true
	end

	local v41 = v3.Client:WaitReplion("GlobalBoosts")
	local boost = boosts.UIListLayout.Boost

	for k, boost2 in v6.Boosts do
		local clone = boost:Clone()
		clone:SetAttribute("DisplayName", boost2.DisplayName)
		clone.Parent = boosts
		local timeLeft = clone.TimeLeft
		clone.Icon.Image = boost2.Icon
		local connection = nil
		local update
		local v42 = k
		local update2 = update
		local v44 = boost2

		update = function()
			local v46 = v36:Get({ "Boosts", v42 }) or 0

			if v42 == "Coins2x" then
				local v47 = v46 > 0 and 2 or 0
				local v48 = false
				local v49 = v41:Get({ "Boosts", "Coins" })
				local serverTimeNow = workspace:GetServerTimeNow()

				if v49 and v49.StartsAt <= serverTimeNow and serverTimeNow < v49.EndsAt and v49.Multiplier > 1 then
					if not (connection and connection.Connected) then
						connection = v5.Thread.Every(1, update2)
					end

					v48 = true
					local v50 = math.round(v49.EndsAt - serverTimeNow)

					if v46 <= 0 or v50 <= 0 then
						v46 = math.max(v46, v50)
					else
						v46 = math.min(v46, v50)
					end

					clone:SetAttribute("DisplayName", (`{v47 + v49.Multiplier}x Coins`))
				elseif connection and connection.Connected then
					connection:Disconnect()
				end

				if not v48 then
					clone:SetAttribute("DisplayName", v44.DisplayName)
				end
			end

			if v46 > 0 then
				clone.Visible = true

				if v46 >= 0 then
					clone.LayoutOrder = -v46
					timeLeft.Text = v5.ValueConvertor:FormatTimeWithDays(v46)
				end
			else
				clone.Visible = false
			end
		end

		v36:OnChange({ "Boosts", k }, update)
		v41:OnChange("Boosts", update)
		task.spawn(update)
		local parent = clone
		clone.MouseEnter:Connect(function()
			tooltip.Parent = parent
			tooltip.Text = parent:GetAttribute("DisplayName")
			tooltip.BackToolTip.Text = parent:GetAttribute("DisplayName")
		end)
		clone.MouseLeave:Connect(function()
			tooltip.Parent = nil
		end)
		v.WindowFocusReleased:Connect(function()
			tooltip.Parent = nil
		end)
	end

	local v42 = v3.Client:WaitReplion("ServerEvents")

	for k, boost2 in v7.Boosts do
		local clone = boost:Clone()
		clone:SetAttribute("DisplayName", boost2.DisplayName)
		clone.Parent = boosts
		local timeLeft = clone.TimeLeft
		clone.Icon.Image = boost2.Icon

		if k == "ForceAbility" or k == "GoldenAbilities" then
			local v43 = clone
			local v44 = boost2
			local v45 = k

			local function updateIcon()
				local currentlyEquippedAbility = localPlayer:GetAttribute("CurrentlyEquippedAbility")

				if not currentlyEquippedAbility then
					v43.Icon.Image = v44.Icon
					return
				end

				local child = ReplicatedStorage2.Misc.DataAbilities:FindFirstChild(currentlyEquippedAbility)

				if (v45 == "ForceAbility" or v45 == "GoldenAbilities") and child then
					local attributes = child:GetAttributes()

					if v42:Get({ "Events", "GoldenAbilities" }) and attributes.GoldenAbilityIcon then
						v43.Icon.Image = attributes.GoldenAbilityIcon
					else
						v43.Icon.Image = v45 ~= "GoldenAbilities" and attributes.Icon or v44.Icon
					end
				end
			end

			updateIcon()
			localPlayer:GetAttributeChangedSignal("CurrentlyEquippedAbility"):Connect(updateIcon)
			v42:OnChange({ "Events", "GoldenAbilities" }, updateIcon)
		end

		local renderSteppedConnection = nil
		local v43 = k

		local function update()
			local v46 = v42:Get({ "Events", v43 })
			local v47

			if v46 and v46.endTime and v46.endTime - workspace:GetServerTimeNow() > 0 then
				v47 = v46.endTime - workspace:GetServerTimeNow()
			end

			local v48 = v47 or 0

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function getCanShow()
				if v43 == "ForceAbility" and v42:Get({ "Events", "GoldenAbilities" }) then
					return false
				end

				return not localPlayer:GetAttribute("DoNotDisplayBoost" .. v43)
			end

			if v48 > 0 then
				local v49 = clone
				local canShow = getCanShow() -- equivalent call inferred; original call site unknown
				v49.Visible = canShow

				if v48 >= 0 then
					local total = 0.5
					renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
						if total < 0.5 then
							total += dt
							return
						end

						total = 0
						local v50 = clone
						local canShow2 = getCanShow() -- equivalent call inferred; original call site unknown
						v50.Visible = canShow2

						if v46 and v46.endTime and v46.endTime - workspace:GetServerTimeNow() > 0 then
							v48 = v46.endTime - workspace:GetServerTimeNow()
						end

						clone.LayoutOrder = -v48
						timeLeft.Text = v5.ValueConvertor:FormatShortTime(v48)
					end)
				end
			else
				clone.Visible = false
			end
		end

		v42:OnChange({ "Events", k }, update)
		task.spawn(update)
		local parent = clone
		clone.MouseEnter:Connect(function()
			tooltip.Parent = parent
			tooltip.Text = parent:GetAttribute("DisplayName")
			tooltip.BackToolTip.Text = parent:GetAttribute("DisplayName")
		end)
		clone.MouseLeave:Connect(function()
			tooltip.Parent = nil
		end)
		v.WindowFocusReleased:Connect(function()
			tooltip.Parent = nil
		end)
	end

	local v43 = {}

	local function UpdateAbilityHUDIcon()
		for _, v44 in v43 do
			v44.instance:Destroy()
			v44.connection:Disconnect()
		end

		table.clear(v43)
		local v44 = v36:Get({ "Trials", "Abilities" }) or {}
		local v45 = {}

		for k, experationTime in v44 do
			table.insert(v45, {
				name = k,
				experationTime = experationTime
			})
		end

		table.sort(v45, function(a, b)
			return a.experationTime < b.experationTime
		end)
		local v46 = {}

		for k, v47 in v45 do
			v46[v47.name] = k
		end

		for k in v44 do
			local clone = boost:Clone()
			clone.Name = k
			clone.Parent = boosts
			clone.Icon.Image = v8[k] or "rbxassetid://6034407076"
			local v47 = k

			local function update()
				local v49 = math.max(0, (v36:Get({ "Trials", "Abilities", v47 }) or 0) - workspace:GetServerTimeNow())

				if v49 < 0 then
					clone.Visible = false
					return
				end

				clone.Visible = (v46[v47] or 3) <= 2

				if v49 >= 0 then
					clone.LayoutOrder = -v49
					clone.TimeLeft.Text = v5.ValueConvertor:FormatTimeWithDays(v49)
				end
			end

			local every = v5.Thread.Every(1, update)
			table.insert(v43, {
				connection = every,
				instance = clone
			})
			update()
		end
	end

	v36:OnChange({ "Trials", "Abilities" }, UpdateAbilityHUDIcon)
	task.spawn(UpdateAbilityHUDIcon)
	local editButtonLayout = localPlayer.PlayerGui:WaitForChild("EditButtonLayout")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reflectGameHudVisibility()
		local visible

		if editButtonLayout.Enabled == false then
			visible = not enabled
		else
			visible = false
		end

		hotbar.Ability.Visible = visible and not v22.isRhythmServer()
		hotbar.Block.Visible = visible
	end

	reflectGameHudVisibility() -- equivalent call inferred; original call site unknown

	if v22.isRhythmServer() then
		hotbar.Block.AnchorPoint = Vector2.new(0.5, 0)
		hotbar.Block.Position = UDim2.fromScale(0.5, 0.803)
	end

	editButtonLayout:GetPropertyChangedSignal("Enabled"):Connect(reflectGameHudVisibility)
	wheel:GetPropertyChangedSignal("Enabled"):Connect(reflectGameHudVisibility)
	local toggleHUD = v9:WaitForIcon("ToggleHUD")
	toggleHUD:bindEvent("selected", function()
		toggleHUD:setLabel("Show UI"):setImage(15360127724)
		HUDController:Condense("ToggleHUD")
	end):bindEvent("deselected", function()
		toggleHUD:setLabel("Hide UI"):setImage(15360127676)
		condensed:SetTag("ToggleHUD", false)

		if not v36:Get({
			"Settings",
			"Misc",
			"Hide UI During Match",
			"Enabled"
		}) or localPlayer.Character.Parent ~= workspace.Alive then
			HUDController:Expand("HideDuringMatch")
		end
	end)
	v4:Connect("Conch/HideUI", function(flag: boolean)
		if flag then
			toggleHUD:select()
		else
			toggleHUD:deselect()
		end
	end)
	workspace.Alive.ChildAdded:Connect(function(child)
		if child ~= localPlayer.Character or not v36:Get({
			"Settings",
			"Misc",
			"Hide UI During Match",
			"Enabled"
		}) and v:GetLastInputType() ~= Enum.UserInputType.Touch then
			return
		end

		if Players.LocalPlayer:GetAttribute("ServerAdminAccess") then
			return
		end

		HUDController:Condense("HideDuringMatch")
	end)
	workspace.Dead.ChildAdded:Connect(function(child)
		if child ~= localPlayer.Character or toggleHUD.isSelected then
			return
		end

		HUDController:Expand("HideDuringMatch")
	end)

	local function onDeviceChanged(_)
		local isMobile = v24:IsMobile()
		local v44 = isMobile and "MobileSize" or "OriginalSize"

		for _, v45 in guiObjectsByName do
			local attribute = v45:GetAttribute(v44)

			if attribute then
				v45.Size = attribute
			end
		end

		if isMobile then
			local parent = guiObjectsByName.MoneyFrame.Parent
			parent.Parent = rightFrame
			parent.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			guiObjectsByName.ShopPage.Parent = leftFrame
			local bossUI = localPlayer.PlayerGui:WaitForChild("BossUI")

			local function updateVisibility()
				guiObjectsByName.MoneyFrame.Visible = not bossUI.Enabled
			end

			bossUI:GetPropertyChangedSignal("Enabled"):Connect(updateVisibility)
			task.spawn(updateVisibility)
		else
			local parent = guiObjectsByName.MoneyFrame.Parent
			parent.Parent = leftFrame
			parent.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			guiObjectsByName.ShopPage.Parent = leftFrame.Middle
		end

		if isMobile then
			leftFrame.UIPadding.PaddingBottom = UDim.new(0.05, 0)
			leftFrame.UIPadding.PaddingTop = UDim.new(-0.05, 0)
		else
			leftFrame.UIPadding.PaddingBottom = UDim.new(-0.035, 0)
			leftFrame.UIPadding.PaddingTop = UDim.new(0.035, 0)
		end

		leftFrame.InvisiblePaddingTop_DoNotDelete.Visible = not isMobile
		leftFrame.InvisiblePaddingTop_DoNotDelete.Visible = not isMobile
	end

	local v44 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateBottomVisible()
		local count = 0

		for _, v45 in ipairs(v44) do
			if v45.Visible then
				count += 1
			end
		end

		leftFrame.Bottom.Visible = count > 0
	end

	for _, button in ipairs(leftFrame.Bottom:GetDescendants()) do
		if not ((button:IsA("ImageButton") or button:IsA("TextButton")) and button.Parent:IsA("Frame")) then
			continue
		end

		table.insert(v44, button)
		button:GetPropertyChangedSignal("Visible"):Connect(updateBottomVisible)
		local v45 = button
		button:GetPropertyChangedSignal("Parent"):Connect(function()
			if not leftFrame.Parent then
				return
			end

			local flag = false
			local index = table.find(v44, v45)

			if v45:IsDescendantOf(leftFrame.Bottom) and not index then
				table.insert(v44, v45)
				flag = true
			elseif not v45:IsDescendantOf(leftFrame.Bottom) and index then
				table.remove(v44, index)
				flag = true
			end

			if flag then
				updateBottomVisible() -- equivalent call inferred; original call site unknown
			end
		end)
	end

	updateBottomVisible() -- equivalent call inferred; original call site unknown
	v24.OnChange:Connect(function()
		task.delay(1, updateBottomVisible)
	end)
	v24:Observe(onDeviceChanged)
end

return HUDController