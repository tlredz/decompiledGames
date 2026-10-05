game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetEarnings = require(ReplicatedStorage.Shared.Util.AssetEarnings)
local AssetIconShape = require(ReplicatedStorage.Client.UI.AssetIconShape)
require(ReplicatedStorage.Shared.Types.AssetItem)
local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
local GridCellFitter = require(ReplicatedStorage.Client.GridCellFitter)
local Assets = require(ReplicatedStorage.Data.Assets)
local directory = Assets.Directory
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local FuseKernel = require(ReplicatedStorage.Shared.Util.FuseKernel)
require(ReplicatedStorage.Shared.Types.FuseMachine)
local ItemDisplay = require(ReplicatedStorage.Shared.Modules.ItemDisplay)
local Log = require(ReplicatedStorage.Packages.Log)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
require(ReplicatedStorage.Shared.Save)
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = Log.new()
local FuseMachineBackpackSelection = {}
FuseMachineBackpackSelection.__index = FuseMachineBackpackSelection
FuseMachineBackpackSelection.__class = "FuseMachineBackpackSelection"
local uDim = UDim2.fromScale(0.02, 0.04)
local GUI = ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("GUI")
assert(GUI:IsA("Folder"), "Controllers.GUI must be a Folder")
local main = GUI.BackpackController.Main
assert(main:IsA("ModuleScript"), "BackpackController.Main must be a ModuleScript")
local inventoryTemplate = main.InventoryTemplate
assert(inventoryTemplate:IsA("GuiButton"), "BackpackController.Main.InventoryTemplate must be a GuiButton")

function FuseMachineBackpackSelection:new()
	local object = setmetatable({}, FuseMachineBackpackSelection)
	object._active = false
	object._rows = Trove.new()
	object._scrollingFrame = self
	object._trove = Trove.new()
	object._columns = 5
	local uIGridLayout = self:FindFirstChildOfClass("UIGridLayout")
	assert(uIGridLayout, "Fuse picker needs a grid layout")
	object._refitGrid = GridCellFitter.Fit(uIGridLayout, object._columns, uDim)
	self.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.ScrollingDirection = Enum.ScrollingDirection.Y

	for _, guiObject in self:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	object._trove:Add(object._rows)
	object._trove:Connect(uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if object._active then
			object._refitGrid()
		end
	end)
	return object
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getConfig(p)
	local v2 = directory[p.Category]
	assert(v2 ~= nil, (`Missing asset config {p.Category}`))
	return v2
end

local function getOddsDenominator(p)
	local config = getConfig(p) -- equivalent call inferred; original call site unknown
	return 1 / config.DropWeight * Mutations.RarityFactorFor(p.Mutations, p.BaseMutation)
end

local function clearDirectGradients(instance)
	for _, uIGradient in ipairs(instance:GetChildren()) do
		if uIGradient:IsA("UIGradient") then
			uIGradient:Destroy()
		end
	end
end

local function sortLikeBackpack(p, a: string, p2, b: string)
	local config = getConfig(p) -- equivalent call inferred; original call site unknown
	local config2 = getConfig(p2) -- equivalent call inferred; original call site unknown
	local rank = config.Rarity.Rank
	local rank2 = config2.Rarity.Rank

	if rank ~= rank2 then
		return rank2 < rank
	end

	local mutationOnlyRatePerSecond = AssetEarnings.MutationOnlyRatePerSecond(p)
	local mutationOnlyRatePerSecond2 = AssetEarnings.MutationOnlyRatePerSecond(p2)

	if mutationOnlyRatePerSecond ~= mutationOnlyRatePerSecond2 then
		return mutationOnlyRatePerSecond2 < mutationOnlyRatePerSecond
	end

	local v2 = 1 / (getConfig(p)).DropWeight * Mutations.RarityFactorFor(p.Mutations, p.BaseMutation)
	local v3 = 1 / (getConfig(p2)).DropWeight * Mutations.RarityFactorFor(p2.Mutations, p2.BaseMutation)

	if v2 ~= v3 then
		return v3 < v2
	end

	if config.DropWeight ~= config2.DropWeight then
		return config.DropWeight < config2.DropWeight
	end

	local weightKg = AssetItems.WeightKg(p)
	local weightKg2 = AssetItems.WeightKg(p2)

	if weightKg == weightKg2 then
		return a < b
	end

	return weightKg2 < weightKg
end

function FuseMachineBackpackSelection:_createRow(p2: string, p3, layoutOrder: number, callback)
	local clone = inventoryTemplate:Clone()
	clone.Name = `FuseSelection.{p2}`
	clone.LayoutOrder = layoutOrder
	clone:SetAttribute("IsInventorySlot", true)
	clone.Active = true
	clone.AutoButtonColor = false
	clone.BackgroundColor3 = Color3.new(0, 0, 0)
	clone.BackgroundTransparency = 0.5
	local uIStroke = clone.UIStroke
	assert(uIStroke:IsA("UIStroke"), "Fuse inventory row requires UIStroke")
	uIStroke.Thickness = 0
	clone.Visible = true
	clone.Parent = self._scrollingFrame
	self._rows:Add(clone)
	local baseTemplate = clone.BaseTemplate
	local amount = baseTemplate.Amount
	assert(amount:IsA("TextLabel"), "Fuse inventory row Amount must be a TextLabel")
	amount.Text = ""
	amount.Visible = false
	local mutations = baseTemplate.Mutations
	assert(mutations:IsA("GuiObject"), "Fuse inventory row Mutations must be a GuiObject")
	mutations.Visible = false
	local icon = clone.Icon
	assert(icon:IsA("ImageLabel"), "Fuse inventory row Icon must be an ImageLabel")
	AssetIconShape.Paint(icon, p3)
	icon.ImageColor3 = Color3.new(1, 1, 1)
	local config = getConfig(p3) -- equivalent call inferred; original call site unknown
	local toolName = clone.ToolName
	assert(toolName:IsA("TextLabel"), "Fuse inventory row ToolName must be a TextLabel")
	clearDirectGradients(toolName)
	local clone_2 = config.Rarity.RarityGradient:Clone()
	clone_2.Parent = toolName
	toolName.Text = `{ItemDisplay.GetNameFromItemData(p3)} ({AssetItems.WeightLabel(p3)})`
	toolName.Visible = true
	local shadow = clone.Shadow
	assert(shadow:IsA("ImageLabel"), "Fuse inventory row Shadow must be an ImageLabel")
	clearDirectGradients(shadow)
	local clone_3 = config.Rarity.RarityGradient:Clone()
	clone_3.Parent = shadow
	shadow.Visible = true
	local favIcon = clone.FavIcon
	assert(favIcon:IsA("GuiObject"), "Fuse inventory row FavIcon must be a GuiObject")
	favIcon.Visible = false
	local weight = clone.Weight
	assert(weight:IsA("GuiObject"), "Fuse inventory row Weight must be a GuiObject")
	weight.Visible = false
	self._rows:Add(clone.Activated:Connect(function()
		callback(p2)
	end))
	ButtonFX(clone, 1.015)
end

function FuseMachineBackpackSelection:Open(p, p2: string?, p3, flag: boolean?, flag2: boolean?)
	if self._active then
		return 0
	end

	local v2 = {}
	local v3 = {}
	local values = {}

	for _, equippedAsset in ipairs(p.EquippedAssets) do
		v2[equippedAsset] = true
	end

	for k, v4 in pairs(p.Inventory) do
		if not ((not v2[k] or flag == true) and FuseKernel.MayEnterFuse(k, v4, p2, false, flag2)) then
			continue
		end

		table.insert(v3, k)
		values[k] = AssetItems.Decode(v4)
	end

	table.sort(v3, function(a: string, b: string)
		return (sortLikeBackpack(
			assert(values[a], (`Missing Fuse selection item data for {a}`)),
			a,
			assert(values[b], (`Missing Fuse selection item data for {b}`)),
			b
		))
	end)
	self._active = true
	self._scrollingFrame.CanvasPosition = Vector2.zero

	for i, v4 in ipairs(v3) do
		self:_createRow(v4, assert(values[v4], (`Missing Fuse selection item data for {v4}`)), i, p3)
	end

	return #v3
end

function FuseMachineBackpackSelection:Close()
	if not self._active then
		return
	end

	self._rows:Clean()
	self._scrollingFrame.CanvasPosition = Vector2.zero
	self._active = false
end

function FuseMachineBackpackSelection:RefreshGridLayout()
	assert(self._active, "FuseMachine backpack selection must be open before refreshing its grid")
	local X = self._scrollingFrame.AbsoluteSize.X
	local v2 = self._scrollingFrame.AbsoluteSize.Y < 150
	self._columns = X < 420 and not v2 and 3 or X < 650 and 4 or 5
	local uIGridLayout = self._scrollingFrame:FindFirstChildOfClass("UIGridLayout")
	assert(uIGridLayout, "Fuse picker needs a grid layout")
	uIGridLayout.FillDirectionMaxCells = self._columns
	self._refitGrid(self._columns)
end

function FuseMachineBackpackSelection:IsOpen()
	return self._active
end

function FuseMachineBackpackSelection:Destroy()
	self:Close()
	self._trove:Destroy()
	v:AtTrace():Log("Destroyed FuseMachine backpack selection")
end

return FuseMachineBackpackSelection