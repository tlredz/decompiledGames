local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return {}
end

local ClientState = require(ReplicatedStorage.ClientState)
local AsyncUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.AsyncUtils)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local Config = require(script.Parent.Parent.Config)
local InfoModal = require(script.Parent.InfoModal)
local UiHelpers = require(script.Parent.UiHelpers)
local v = nil
local v2 = {}
local v3 = nil
local v4 = false
local count = 0
local v5 = nil
local v6 = nil
local TargetModal = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getModal()
	return UiHelpers.findTaggedInPlayerGui("TradingTargetModal")
end

local function showInfo(data)
	InfoModal.open({
		title = data.title,
		description = data.description,
		buttons = {
			{
				text = data.confirmText,
				style = data.buttonStyle or "Neutral"
			}
		}
	})
end

local function setTradeButtons(p, p2: string)
	local mainContainer = p.MainContainer
	local tradeButtonActive = mainContainer.TradeButtonActive
	local tradeButtonInactive = mainContainer.TradeButtonInactive

	if p2 == "active" then
		tradeButtonActive.Visible = true
		tradeButtonInactive.Visible = false
	else
		tradeButtonActive.Visible = false
		tradeButtonInactive.Visible = true
		tradeButtonInactive.TextLabel.Text = p2 == "cannot" and "CANNOT TRADE" or "SELECT PLAYER"
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearSelection(p)
	v3 = nil
	v4 = false
	local avatarFrame = p.MainContainer.AvatarFrame
	UiHelpers.fillAvatarFrame(avatarFrame, nil, nil)
	avatarFrame.WarningText.Visible = false
	avatarFrame.WarningText.Text = ""
	local mainContainer = p.MainContainer
	local tradeButtonActive = mainContainer.TradeButtonActive
	local tradeButtonInactive = mainContainer.TradeButtonInactive
	tradeButtonActive.Visible = false
	tradeButtonInactive.Visible = true
	tradeButtonInactive.TextLabel.Text = "SELECT PLAYER"
end

local function applyTarget(p, userId: number, displayName: string, flag: boolean, reason: string?)
	v3 = userId
	v4 = flag
	local avatarFrame = p.MainContainer.AvatarFrame
	UiHelpers.fillAvatarFrame(avatarFrame, userId, displayName)

	if flag then
		avatarFrame.WarningText.Visible = false
		avatarFrame.WarningText.Text = ""
		local mainContainer = p.MainContainer
		local tradeButtonActive = mainContainer.TradeButtonActive
		local tradeButtonInactive = mainContainer.TradeButtonInactive
		tradeButtonActive.Visible = true
		tradeButtonInactive.Visible = false
	else
		local text = (reason == "disabled" or reason == "banned") and "THIS USER HAS TRADING DISABLED" or reason == "busy" and "THIS USER IS TRADING ALREADY" or ""
		avatarFrame.WarningText.Visible = text ~= ""
		avatarFrame.WarningText.Text = text
		local mainContainer = p.MainContainer
		local tradeButtonActive = mainContainer.TradeButtonActive
		local tradeButtonInactive = mainContainer.TradeButtonInactive
		tradeButtonActive.Visible = false
		tradeButtonInactive.Visible = true
		tradeButtonInactive.TextLabel.Text = "CANNOT TRADE"
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncCanvasSize(state)
	state.CanvasSize = UDim2.new(
		state.CanvasSize.X.Scale,
		state.UIListLayout.AbsoluteContentSize.X,
		state.CanvasSize.Y.Scale,
		state.CanvasSize.Y.Offset
	)
end

local fn

local function otherPlayers(p)
	local localPlayer = Players.LocalPlayer
	local result = {}

	for _, v7 in ipairs(Players:GetPlayers()) do
		if v7 ~= localPlayer and v7 ~= p then
			table.insert(result, v7)
		end
	end

	table.sort(result, function(a, b)
		return a.Name < b.Name
	end)
	return result
end

local function fn2(p, p2)
	if v5 then
		v5:Destroy()
	end

	local targetPlayersFrame = p.MainContainer.TargetPlayersFrame
	local scrollingFrame = targetPlayersFrame.ScrollingFrame
	local v7 = otherPlayers(p2)
	targetPlayersFrame.NoPlayers.Visible = #v7 == 0
	local avatarCircleButtons = {}
	local connections = {}

	for i, v8 in ipairs(v7) do
		local avatarCircleButton = UiHelpers.cloneAvatarCircleButton()
		avatarCircleButton.Name = tostring(v8.UserId)
		avatarCircleButton.LayoutOrder = i
		avatarCircleButton.Parent = scrollingFrame
		UiHelpers.fillAvatarCircleButton(avatarCircleButton, v8.UserId, v8.Name)
		table.insert(avatarCircleButtons, avatarCircleButton)
		local v9 = v8
		table.insert(connections, avatarCircleButton.MouseButton1Down:Connect(function()
			fn(p, v9)
		end))
	end

	syncCanvasSize(scrollingFrame) -- equivalent call inferred; original call site unknown
	v5 = Janitor.new()

	for _, v8 in ipairs(avatarCircleButtons) do
		v5:Add(v8, "Destroy")
	end

	for _, connection in ipairs(connections) do
		v5:Add(connection)
	end
end

fn = function(p, player)
	count += 1
	local v7 = count

	if player.Parent then
		UiHelpers.fillAvatarFrame(p.MainContainer.AvatarFrame, player.UserId, player.DisplayName)
		local mainContainer = p.MainContainer
		local tradeButtonActive = mainContainer.TradeButtonActive
		local tradeButtonInactive = mainContainer.TradeButtonInactive
		tradeButtonActive.Visible = false
		tradeButtonInactive.Visible = true
		tradeButtonInactive.TextLabel.Text = "SELECT PLAYER"
		v.queryTarget:request(player.UserId):andThen(function(data)
			if v7 == count then
				if data.found and data.userId then
					applyTarget(
						p,
						data.userId,
						data.displayName or data.name or player.DisplayName,
						data.canTrade == true,
						data.reason
					)
					return
				end

				clearSelection(p) -- equivalent call inferred; original call site unknown
				fn2(p)
				showInfo(Config.InfoFeedback.NotInServer)
			end
		end)
	else
		clearSelection(p) -- equivalent call inferred; original call site unknown
		fn2(p)
		showInfo(Config.InfoFeedback.NotInServer)
	end
end

local function sendTradeRequest(p)
	if v3 and v4 then
		local playerByUserId = Players:GetPlayerByUserId(v3)

		if playerByUserId and playerByUserId.Parent then
			v.requestTrade:fire(v3)

			if ClientState.ActiveModal == p then
				ClientState:CloseCurrentModal()
			end
		else
			clearSelection(p) -- equivalent call inferred; original call site unknown
			fn2(p)
			showInfo(Config.InfoFeedback.NotInServer)
		end
	end
end

local v7 = {
	OnClose = function(_)
		local modal = getModal() -- equivalent call inferred; original call site unknown

		if modal then
			clearSelection(modal) -- equivalent call inferred; original call site unknown
		end
	end
}

local function wireModal(p)
	if v2[p] then
		return
	end

	v2[p] = true
	p.Visible = false
	local scrollingFrame = p.MainContainer.TargetPlayersFrame.ScrollingFrame
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
	local mouseButton1DownConnection = p.MainContainer.TradeButtonActive.MouseButton1Down:Connect(function()
		sendTradeRequest(p)
	end)
	local playerAddedConnection = Players.PlayerAdded:Connect(function()
		fn2(p)
	end)
	local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		if v3 == player.UserId then
			clearSelection(p) -- equivalent call inferred; original call site unknown
		end

		fn2(p, player)
	end)
	local absoluteContentSizeChangedConnection = scrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		syncCanvasSize(scrollingFrame) -- equivalent call inferred; original call site unknown
	end)
	v6 = Janitor.new()
	v6:Add(mouseButton1DownConnection)
	v6:Add(playerAddedConnection)
	v6:Add(playerRemovingConnection)
	v6:Add(absoluteContentSizeChangedConnection)
end

local function openTargetUi()
	local modal = getModal() -- equivalent call inferred; original call site unknown

	if not modal then
		warn("[TradingTargetModal] Modal not found")
		return
	end

	wireModal(modal)
	clearSelection(modal) -- equivalent call inferred; original call site unknown
	fn2(modal)

	if ClientState.ActiveModal ~= modal then
		ClientState:ToggleModal(modal, v7)
	end
end

function TargetModal.open()
	AsyncUtils.fetchPaidItemTradingAllowed(Players.LocalPlayer):andThen(function(p)
		if p then
			openTargetUi()
		else
			showInfo(Config.InfoFeedback.PolicyBlocked)
		end
	end)
end

function TargetModal.bind(p)
	v = p

	for _, v8 in ipairs(CollectionService:GetTagged("TradingTargetModal")) do
		local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

		if playerGui and v8:IsDescendantOf(playerGui) then
			wireModal(v8)
		end
	end

	CollectionService:GetInstanceAddedSignal("TradingTargetModal"):Connect(function(instance)
		local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

		if playerGui and instance:IsDescendantOf(playerGui) then
			wireModal(instance)
		end
	end)
	v.openTargetModal:connect(function()
		TargetModal.open()
	end)
end

return TargetModal