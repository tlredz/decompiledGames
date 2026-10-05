local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return {}
end

local ClientState = require(ReplicatedStorage.ClientState)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Trading = require(ReplicatedStorage._FRAMEWORK.Features.Trading)
require(ReplicatedStorage._FRAMEWORK.Features.Trading.Types)
local Config = require(script.Parent.Parent.Config)
require(script.Parent.Parent.Types)
local logger = LoggerManager.createLogger("StandConfigModal", {
	feature = script:GetFullName()
})
local v = nil
local v2 = nil
local v3 = {}
local v4 = {}
local v5 = nil
local v6 = {}
local kind = "Standard"
local v7 = 0
local StandConfigModal = {}

local function getModal()
	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

	if playerGui then
		for _, guiObject in ipairs(CollectionService:GetTagged("TradingStandConfigModal")) do
			if guiObject:IsA("GuiObject") and guiObject:IsDescendantOf(playerGui) then
				return guiObject
			end
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function maxFor(kind2)
	if kind2 == "Premium" then
		return Config.PremiumHighlightMax
	end

	return Config.StandardHighlightMax
end

local function entryToken(p)
	return Items.KeyOf(p) .. ":" .. Items.TierOf(p) .. ":" .. tostring(Items.LimitedNumberOf(p)) .. ":" .. tostring(Items.SignatureOf(p))
end

local function track(list, mouseButton1DownConnections)
	local v8 = Janitor.new()

	for _, v9 in ipairs(list) do
		v8:Add(v9, "Destroy")
	end

	for _, v9 in ipairs(mouseButton1DownConnections) do
		v8:Add(v9)
	end

	v5 = v8
end

local applyModal

applyModal = function(modal)
	if v5 then
		v5:Destroy()
		v5 = nil
	end

	local visible = kind == "Premium"
	local selectedHighlightItems = modal.SelectedHighlightItems
	selectedHighlightItems.ContainerItems3.Visible = not visible
	selectedHighlightItems.MaxHighlight.Visible = not visible
	selectedHighlightItems.ContainerItems6.Visible = visible
	selectedHighlightItems.SelectedItemsLabel.Text = string.format("HIGHLIGHTED ITEMS: %d/%d", #v6, v7)
	Trading.clearItemButtons(selectedHighlightItems.ContainerItems3)
	Trading.clearItemButtons(selectedHighlightItems.ContainerItems6)
	Trading.clearItemButtons(modal.InventoryContainer.OwnedItemsFrame)
	local fillItemButtons = {}
	local mouseButton1DownConnections = {}
	local containerItems6

	if visible then
		containerItems6 = selectedHighlightItems.ContainerItems6
	else
		containerItems6 = selectedHighlightItems.ContainerItems3
	end

	for i, v9 in ipairs(v6) do
		local fillItemButton = Trading.fillItemButton(v9, containerItems6, {
			templateName = "StandTemplateItemButton",
			layoutOrder = i
		})

		if not fillItemButton then
			continue
		end

		local v10 = i
		local mouseButton1DownConnection = fillItemButton.MouseButton1Down:Connect(function()
			table.remove(v6, v10)
			local modal2 = getModal()

			if modal2 then
				applyModal(modal2)
			end
		end)
		table.insert(fillItemButtons, fillItemButton)
		table.insert(mouseButton1DownConnections, mouseButton1DownConnection)
	end

	local ownedItemsFrame = modal.InventoryContainer.OwnedItemsFrame
	local v9 = {}

	for _, v10 in ipairs(v6) do
		local v11 = entryToken(v10)
		local v12 = v9[v11]

		if v12 then
			v9[v11] = v12 + 1
		else
			v9[v11] = 1
		end
	end

	local items = ClientState:Get().Items

	for _, item in ipairs(items) do
		local v10 = entryToken(item)

		if v9[v10] and v9[v10] > 0 then
			v9[v10] -= 1
		else
			local fillItemButton = Trading.fillItemButton(item, ownedItemsFrame)

			if fillItemButton then
				local v11 = item
				local mouseButton1DownConnection = fillItemButton.MouseButton1Down:Connect(function()
					if #v6 < v7 then
						table.insert(v6, Items.CopyEntry(v11))
						local modal2 = getModal()

						if modal2 then
							applyModal(modal2)
						end
					end
				end)
				table.insert(fillItemButtons, fillItemButton)
				table.insert(mouseButton1DownConnections, mouseButton1DownConnection)
			end
		end
	end

	track(fillItemButtons, mouseButton1DownConnections)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function accept(p)
	v.setStandHighlights:fire(v6)

	if ClientState.ActiveModal == p then
		ClientState:CloseCurrentModal()
	end
end

local function wireModal(p)
	if v3[p] then
		return
	end

	v3[p] = true
	p.Visible = false
	local mouseButton1DownConnection = p.AcceptButton.MouseButton1Down:Connect(function()
		accept(p) -- equivalent call inferred; original call site unknown
	end)
	local v8 = Janitor.new()
	v8:Add(mouseButton1DownConnection)
	v4[p] = v8
end

local function openConfig(p)
	local modal = getModal()

	if modal then
		wireModal(modal)
		kind = p.kind
		v7 = maxFor(kind) -- equivalent call inferred; original call site unknown
		v6 = {}

		for _, highlight in ipairs(p.highlights) do
			table.insert(v6, Items.CopyEntry(highlight))
		end

		applyModal(modal)

		if ClientState.ActiveModal ~= modal then
			ClientState:ToggleModal(modal)
		end
	else
		logger:warn("TradingStandConfigModal was not found in PlayerGui")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function considerModal(instance)
	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

	if playerGui and instance:IsDescendantOf(playerGui) then
		wireModal(instance)
	end
end

function StandConfigModal.bind(p)
	if v then
		return
	end

	v = p

	for _, v8 in ipairs(CollectionService:GetTagged("TradingStandConfigModal")) do
		considerModal(v8) -- equivalent call inferred; original call site unknown
	end

	local connection = CollectionService:GetInstanceAddedSignal("TradingStandConfigModal"):Connect(considerModal)
	local openStandConfigConnection = v.openStandConfig:connect(openConfig)
	v2 = Janitor.new()
	v2:Add(connection)
	v2:Add(openStandConfigConnection, true)
end

return StandConfigModal