local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return {}
end

local ClientState = require(ReplicatedStorage.ClientState)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local UiHelpers = require(script.Parent.UiHelpers)
local Config = require(script.Parent.Parent.Config)
require(script.Parent.Parent.Types)
local v = nil
local v2 = {}
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getModal()
	return UiHelpers.findTaggedInPlayerGui("TradingContractModal")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setArrow(p, ready: boolean)
	p.ReadyText.Visible = ready
	p.Arrow.ImageTransparency = ready and 0.2 or 0.75
end

local function setActionButtons(data, ready: boolean, p: number)
	local inactiveButton = data.InactiveButton
	local readyButton = data.ReadyButton
	local cancelButton = data.CancelButton
	inactiveButton.TextLabel.Text = "SELECT " .. tostring(Config.MinOfferItems) .. "+ ITEMS"

	if ready then
		local textLabel = cancelButton.TextLabel
		local size = textLabel.Size
		textLabel.Text = "PROCESSING... CANCEL"
		textLabel.Size = UDim2.new(size.X.Scale, size.X.Offset, 0.85, 0)
		inactiveButton.Visible = false
		readyButton.Visible = false
		cancelButton.Visible = true
	else
		if p < Config.MinOfferItems then
			inactiveButton.Visible = true
			readyButton.Visible = false
		else
			inactiveButton.Visible = false
			readyButton.Visible = true
		end

		cancelButton.Visible = false
	end
end

local function refreshOwnedItems(data, offer)
	local ownedItemsFrame = data.InventoryContainer.OwnedItemsFrame
	UiHelpers.clearItemButtons(ownedItemsFrame)
	local items = ClientState:Get().Items or {}
	local v3 = {}

	for _, v4 in ipairs(offer) do
		local v5 = Items.KeyOf(v4) .. ":" .. Items.TierOf(v4) .. ":" .. tostring(Items.LimitedNumberOf(v4)) .. ":" .. tostring(Items.SignatureOf(v4))
		v3[v5] = (v3[v5] or 0) + 1
	end

	for _, item in ipairs(items) do
		local key = Items.KeyOf(item)
		local tier = Items.TierOf(item)
		local limitedNumber = Items.LimitedNumberOf(item)
		local signature = Items.SignatureOf(item)
		local v4 = key .. ":" .. tier .. ":" .. tostring(limitedNumber) .. ":" .. tostring(signature)

		if v3[v4] and v3[v4] > 0 then
			v3[v4] -= 1
		else
			local fillItemButton = UiHelpers.fillItemButton(item, ownedItemsFrame)

			if fillItemButton then
				local v5 = key
				local v6 = tier
				local v7 = limitedNumber
				local v8 = signature
				fillItemButton.MouseButton1Down:Connect(function()
					v.addOfferItem:fire(v5, v6, v7, v8)
				end)
			end
		end
	end
end

local function refreshPartyFrame(p, data, flag2: boolean)
	UiHelpers.fillAvatarFrame(p.Container.AvatarFrame, data.userId, data.displayName)
	local selectedItems = p.Container.SelectedItems
	UiHelpers.clearItemButtons(selectedItems)

	for _, v3 in ipairs(data.offer) do
		local fillItemButton = UiHelpers.fillItemButton(v3, selectedItems, {
			active = flag2,
			selectable = flag2
		})

		if not (fillItemButton and flag2) then
			continue
		end

		local v4 = Items.KeyOf(v3)
		local v5 = Items.TierOf(v3)
		local v6 = Items.LimitedNumberOf(v3)
		local v7 = Items.SignatureOf(v3)
		fillItemButton.MouseButton1Down:Connect(function()
			v.removeOfferItem:fire(v4, v5, v6, v7)
		end)
	end

	local sumOfferBonusPercent = UiHelpers.sumOfferBonusPercent(data.offer)

	if flag2 then
		p.Container.OfferTextLabel.Text = "YOUR OFFER: +" .. sumOfferBonusPercent .. "%"
	else
		p.Container.OfferTextLabel.Text = string.upper(data.displayName or data.name) .. "'S OFFER: +" .. sumOfferBonusPercent .. "%"
	end
end

local function resolveParties(p)
	local userId = Players.LocalPlayer.UserId
	local parties = p.parties
	local v3 = parties[userId] or parties[tostring(userId)]
	local v4 = nil

	for k, party in pairs(parties) do
		if tonumber(k) ~= userId then
			v4 = party
		end
	end

	return v3, v4
end

local function applySnapshot(modal, p)
	local parties, v3 = resolveParties(p)

	if not (parties and v3) then
		return
	end

	refreshPartyFrame(modal.YourPlayer, parties, true)
	refreshPartyFrame(modal.TheirPlayer, v3, false)
	refreshOwnedItems(modal, parties.offer)
	setArrow(modal.YourArrow, parties.ready) -- equivalent call inferred; original call site unknown
	setArrow(modal.TheirArrow, v3.ready) -- equivalent call inferred; original call site unknown
	setActionButtons(modal, parties.ready, #parties.offer)
end

local v3 = {
	OnClose = function(_)
		if flag then
			return
		end

		if v then
			v.cancelContract:fire()
		end
	end
}

local function wireModal(state)
	if v2[state] then
		return
	end

	v2[state] = true
	state.Visible = false
	state.ReadyButton.MouseButton1Down:Connect(function()
		v.setReady:fire(true)
	end)
	state.CancelButton.MouseButton1Down:Connect(function()
		v.setReady:fire(false)
	end)
end

local function openWithSnapshot(p)
	local modal = getModal() -- equivalent call inferred; original call site unknown

	if not modal then
		warn("[TradingContractModal] Modal not found")
		return
	end

	wireModal(modal)
	applySnapshot(modal, p)

	if ClientState.ActiveModal ~= modal then
		ClientState:ToggleModal(modal, v3)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closeFromServer()
	local modal = getModal() -- equivalent call inferred; original call site unknown
	flag = true

	if modal and ClientState.ActiveModal == modal then
		ClientState:CloseCurrentModal()
	end

	flag = false
end

return {
	bind = function(p)
		v = p

		for _, v4 in ipairs(CollectionService:GetTagged("TradingContractModal")) do
			local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

			if playerGui and v4:IsDescendantOf(playerGui) then
				wireModal(v4)
			end
		end

		CollectionService:GetInstanceAddedSignal("TradingContractModal"):Connect(function(instance)
			local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

			if playerGui and instance:IsDescendantOf(playerGui) then
				wireModal(instance)
			end
		end)
		v.contractOpened:connect(function(p2)
			openWithSnapshot(p2)
		end)
		v.contractUpdated:connect(function(p2)
			local modal = getModal() -- equivalent call inferred; original call site unknown

			if modal and ClientState.ActiveModal == modal then
				applySnapshot(modal, p2)
			else
				openWithSnapshot(p2)
			end
		end)
		v.contractClosed:connect(function(_)
			closeFromServer() -- equivalent call inferred; original call site unknown
		end)
	end
}