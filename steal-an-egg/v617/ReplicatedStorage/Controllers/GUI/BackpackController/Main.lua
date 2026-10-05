if not game:IsLoaded() then
	game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Areas = require(ReplicatedStorage.Data.Areas)
local GridCellFitter = require(ReplicatedStorage.Client.GridCellFitter)
local GUI = require(ReplicatedStorage.Client.GUI)
local MenuNavigation = require(ReplicatedStorage.Client.MenuNavigation)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local InputIconsConfig = require(ReplicatedStorage.Client.InputIconsConfig)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local PlotState = require(ReplicatedStorage.Client.PlotState)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Rarity = require(ReplicatedStorage.Data.Rarity)
RarityDirectory = Rarity.Rarities
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
MutationHandler = Mutations
local HoverCard2 = require(ReplicatedStorage.Client.HoverCard)
HoverCard = HoverCard2
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local ButtonHintStrip2 = require(ReplicatedStorage.Client.ButtonHintStrip)
ButtonHintStrip = ButtonHintStrip2
local ButtonFX2 = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
ButtonFX = ButtonFX2
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
SimpleNumber = Simple
local AssetEarnings = require(ReplicatedStorage.Shared.Util.AssetEarnings)
local AssetIconShape = require(ReplicatedStorage.Client.UI.AssetIconShape)
local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
require(ReplicatedStorage.Shared.Globals.Constants)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local EggSkins = require(ReplicatedStorage.Data.EggSkins)
local EggState = require(ReplicatedStorage.Client.EggState)
local ItemDisplay = require(ReplicatedStorage.Shared.Modules.ItemDisplay)
local Preload = require(ReplicatedStorage.Shared.Utils.Preload)
local warmAssets = Preload.WarmAssets
require(ReplicatedStorage.Shared.Remotes)
require(ReplicatedStorage.Shared.Save)
local ToolGameplayGuard = require(ReplicatedStorage.Client.ToolGameplayGuard)
local TreadmillFlags = require(ReplicatedStorage.Shared.Flags.TreadmillFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local SlotDragController = require(script.SlotDragController)
local SlotFavoriteController = require(script.SlotFavoriteController)
local HotbarDragFeedback = require(script.HotbarDragFeedback)
local v = {
	{
		Name = "Pets",
		Image = "rbxassetid://93714449004895",
		Tags = { "Asset", "Phone" }
	},
	{
		Name = "Eggs",
		Image = "rbxassetid://116524274262912",
		Tags = { "AssetEgg", "PetEgg" }
	},
	{
		Name = "Gear",
		Image = "rbxassetid://78687042850233",
		Tags = { "Gear", "MutationConsumable", "MonsterChest" }
	}
}
local v2 = not v[1] and "Pets" or v[1].Name or "Pets"
local previousCategory = v2
local v4 = {}
local performSearch = nil
local SetCategory
local textBox = nil
local resetSearchResults = nil

for _, v5 in v do
	v4[v5.Name] = v5
end

function IsOfCategory(instance)
	if not instance then
		return false
	end

	local v5 = v4[previousCategory]

	if not (v5 and v5.Tags) then
		return false
	end

	for _, tag in v5.Tags do
		if instance:GetAttribute("ItemType") == tag then
			return true
		end
	end

	return false
end

function GetCategory(instance)
	for k, v5 in v4 do
		if not v5.Tags then
			continue
		end

		for _, tag in v5.Tags do
			if instance:GetAttribute("ItemType") == tag then
				return k
			end
		end
	end

	return v2
end

function HasInventoryCategory(p)
	local attribute = getAttribute(p, "ItemType")

	if attribute == nil then
		return false
	end

	for _, v5 in v4 do
		if not v5.Tags then
			continue
		end

		for _, tag in v5.Tags do
			if attribute == tag then
				return true
			end
		end
	end

	return false
end

local Main = {
	OpenClose = nil,
	IsOpen = false,
	StateChanged = Instance.new("BindableEvent"),
	ModuleName = "Backpack",
	KeepVRTopbarOpen = true,
	VRIsExclusive = true,
	VRClosesNonExclusive = true,
	StartFuseSelection = nil,
	EndFuseSelection = nil,
	IsFuseSelectionActive = nil
}
local v5 = 60
TextSizeAttribute = script:GetAttribute("TextSize")
_BackgroundTransparencyAttribute = script:GetAttribute("BackgroundTransparency")
BackgroundColorAttribute = script:GetAttribute("BackgroundColor")
DraggableColorAttribute = script:GetAttribute("DraggableColor")
EquippedColorAttribute = script:GetAttribute("EquippedColor")
SlotLockedTransparencyAttribute = script:GetAttribute("SlotLockedTransparency")
BorderColorAttribute = script:GetAttribute("BorderColor")
ToggleHotkeys = { Enum.KeyCode.Backquote, Enum.KeyCode.ButtonSelect }
EmptySlotsAttribute = script:GetAttribute("EmptySlots")
_SearchBoxColorAttribute = script:GetAttribute("SearchBoxColor")
_SearchBoxTransparencyAttribute = script:GetAttribute("SearchBoxTransparency")
ApiEvent = ReplicatedStorage:FindFirstChild("Api") or script:WaitForChild("Api")
ApiEvent.Parent = ReplicatedStorage
SelectedSlot = nil
BackpackEnabled = true
local v6 = nil
ActiveFuseSelectionState = nil

function GetViewportSize()
	local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
	local frame = Instance.new("Frame", screenGui)
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 1, 0)
	local absoluteSize = frame.AbsoluteSize
	screenGui:Destroy()
	return absoluteSize
end

local value = Enum.KeyCode.Zero.Value
local value2 = Enum.KeyCode.Backspace.Value
local v7 = {
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true,
	[Enum.UserInputType.Gamepad4] = true,
	[Enum.UserInputType.Gamepad5] = true,
	[Enum.UserInputType.Gamepad6] = true,
	[Enum.UserInputType.Gamepad7] = true,
	[Enum.UserInputType.Gamepad8] = true
}
local UserInputService2 = game:GetService("UserInputService")
UserInputService = UserInputService2
local Players2 = game:GetService("Players")
Players = Players2
PlayerGui = Players.LocalPlayer.PlayerGui
BackpackGui = PlayerGui:WaitForChild("BackpackGui")
local ContextActionService2 = game:GetService("ContextActionService")
ContextActionService = ContextActionService2
local VRService2 = game:GetService("VRService")
VRService = VRService2
local Utility2 = require(script.Utility)
Utility = Utility2
require(script.GameTranslator)
local TopBarPlus2 = require(ReplicatedStorage.Packages.TopBarPlus)
TopBarPlus = TopBarPlus2

local function tryCore(p: string, ...)
	local v8 = 0.03
	local v9 = nil

	for i = 1, 5 do
		local v10 = table.pack(pcall(StarterGui[p], StarterGui, ...))

		if v10[1] == true then
			return true, table.unpack(v10, 2, v10.n)
		end

		v9 = v10[2]

		if not (i < 5) then
			continue
		end

		task.wait(v8)
		v8 *= 2
	end

	return false, v9
end

local Save = require(ReplicatedStorage.Shared.Save)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local AssetItems2 = require(ReplicatedStorage.Shared.Util.AssetItems)
local Assets = require(ReplicatedStorage.Data.Assets)
AssetDirectoryModule = Assets
AssetDirectory = AssetDirectoryModule.Directory
BaseAssetConfig = AssetDirectoryModule.BaseConfig
local Gears = require(ReplicatedStorage.Data.Gears)
local TryLock2 = require(ReplicatedStorage.Shared.Utils.TryLock)
TryLock = TryLock2
local Audio2 = require(ReplicatedStorage.Shared.Audio)
Audio = Audio2
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local AssetRoster = require(ReplicatedStorage.Client.AssetRoster)
local favoriteMode = nil
local previousFavoriteModeActive = false
CloseButton = nil
InventoryStroke = nil
InventoryStrokeDefaultColor = nil
FuseSelectionVisualTrove = nil
FUSE_SELECTION_ASSET_CATEGORY_NAME = "Pets"
FUSE_SELECTION_BACKGROUND_COLOR = Color3.fromRGB(0, 255, 255)
FUSE_SELECTION_STROKE_COLOR = Color3.fromRGB(0, 183, 186)
FUSE_SELECTION_BACKGROUND_TRANSPARENCY = 0
local fn

-- equivalent calls inferred from this helper; original call sites unknown
local function isBackpackEquipInteractionBlocked()
	return not BackpackEnabled or not BackpackGui.Enabled or HiddenUIHandler.IsHidden()
end

local isTenFootInterface = GuiService:IsTenFootInterface()

if isTenFootInterface then
	TextSizeAttribute = 24
	v5 = 100
end

local v12 = false
local v13 = GetViewportSize()
ReplicatedStorage = UserInputService.TouchEnabled and v13.X < 1024
local v14 = v5 * 1.5
local localPlayer = Players.LocalPlayer
local backpack = nil
local main = nil
local parent2 = nil
local inventory = nil
local color = Color3.fromRGB(79, 63, 0)
local v16 = nil
local scrollingFrame = nil
local uIGridLayout = nil
local v17 = nil
local cellSize = nil
local uIAspectRatioConstraint = nil
local aspectRatio = nil
local fillDirection = nil
local horizontalAlignment = nil
local scrollingDirection = nil
local paddingLeft = nil
local uIPadding = nil
local uDim = UDim2.fromScale(0.02, 0.04)
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local backpack2 = localPlayer:WaitForChild("Backpack")
local topBarPlus = TopBarPlus.new()
topBarPlus:setImage("rbxasset://textures/ui/TopBar/inventoryOff.png", "deselected")
topBarPlus:setImage("rbxasset://textures/ui/TopBar/inventoryOn.png", "selected")

for _, v19 in ToggleHotkeys do
	topBarPlus:bindToggleKey(v19)
end

topBarPlus:setName("InventoryIcon")
topBarPlus:setImageScale(1.12)
topBarPlus:setOrder(-5)
topBarPlus:setCaption("Toggle the backpack.")
topBarPlus.deselectWhenOtherIconSelected = false
local v19 = {}
local v20 = nil
local v21 = {}
local v22 = {}
local v23 = {}
local v24 = 0
local v25 = false
local v26 = false
local v27 = false
local v28 = false
local v29 = false
local flag = false
local connections = {}
local flag2 = false
local now = 0
local vREnabled = VRService.VREnabled
local emptySlotsAttribute = vREnabled and EmptySlotsAttribute or ReplicatedStorage and 5 or 10
local v30 = vREnabled and 3 or ReplicatedStorage and 2 or 4
local v31 = TryLock()
local v32 = TryLock()
local v33 = SlotFavoriteController.new(BackpackGui)
local v34 = nil
local v35 = {}
local v36 = {}
local v37 = {}
local v38 = {}
local v39 = {}
local v40 = {}
local flag3 = false
local v41 = {}
local v42 = {}
local v43 = {}
local v44 = {}
local v45 = {}
local flag4 = false
local v46 = nil
local autoSell = nil
local equipBest = nil
local clone = nil
local v47 = TryLock()
local v48 = 0
local v49 = false
local v50 = false
local v51 = true
local flag5 = false
local v52 = false
local v53 = 0
local frame = GUI.AutoSell():WaitForChild("Frame"):WaitForChild("Frame")
local v54 = {}
local v55 = {}
local flag6 = false
local template = frame.UIGridLayout.Template
local v56 = nil

function invokeBackpack(object, ...)
	local v57 = { ... }
	local success, result = pcall(function()
		return { object:InvokeServer(unpack(v57)) }
	end)

	if success then
		return result
	end

	warn((`[Backpack] Failed to invoke '{object and object.Name or "?"}': {result}`))
	return nil
end

function isLocalPlayerWithinOwnPlotBounds()
	local plot = PlotState.ResolvePlot()

	if not plot then
		return false
	end

	local v57 = character or localPlayer.Character

	if not v57 then
		return false
	end

	local humanoidRootPart = v57:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return false
	end

	local boundingBox, v58 = plot.PlotFolder:GetBoundingBox()
	local pointToObjectSpace = boundingBox:PointToObjectSpace(humanoidRootPart.Position)
	local v59 = v58 * 0.5
	return math.abs(pointToObjectSpace.X) <= v59.X and math.abs(pointToObjectSpace.Z) <= v59.Z
end

function updateEquipBestButtonVisibility()
	if not clone then
		return
	end

	clone.Visible = false
end

function requestEquipBestStatusRefresh(flag7: boolean?)
	if not (clone and v52) then
		updateEquipBestButtonVisibility()
		return
	end

	if flag5 then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	if flag7 ~= true and serverTimeNow - v53 < 0.5 then
		return
	end

	v53 = serverTimeNow
	flag5 = true
	task.spawn(function()
		local v57 = invokeBackpack(Remotes.Haul.FetchWearBestStatus)
		flag5 = false

		if not v57 then
			updateEquipBestButtonVisibility()
			return
		end

		v49 = v57[1] == true
		v50 = true
		v51 = false
		updateEquipBestButtonVisibility()
	end)
end

function invalidateEquipBestStatus(flag7: boolean?)
	v51 = true

	if v52 then
		requestEquipBestStatusRefresh(flag7)
	else
		updateEquipBestButtonVisibility()
	end
end

function showEquipBestDebounceNotification()
	Toast.Show({
		Text = "Please wait a bit before equipping bests again!",
		Seconds = 2,
		Color = Color3.fromRGB(255, 170, 0)
	})
end

function requestEquipBest()
	if workspace:GetServerTimeNow() - v48 < 5 then
		showEquipBestDebounceNotification()
	elseif not v47(function()
		local serverTimeNow = workspace:GetServerTimeNow()

		if serverTimeNow - v48 < 5 then
			showEquipBestDebounceNotification()
			return
		end

		v48 = serverTimeNow
		local v57 = invokeBackpack(Remotes.Haul.WearBest)

		if not v57 then
			return
		end

		local v58 = v57[1]
		local v59 = v57[2]

		if v58 then
			invalidateEquipBestStatus(true)
		elseif v59 == "DEBOUNCE" or v59 == "LOCKED" then
			showEquipBestDebounceNotification()
		end
	end) then
		showEquipBestDebounceNotification()
	end
end

function applyAutoSellSlot(p: string, enabled: boolean)
	local v57 = v54[p]

	if not v57 then
		return
	end

	local selectedGradient = v57.SelectedGradient

	if selectedGradient then
		selectedGradient.Enabled = enabled
	end

	local rarityGradient = v57.RarityGradient

	if rarityGradient then
		rarityGradient.Enabled = not enabled
	end
end

function applyAutoSellMap(items)
	v55 = {}

	for k, item in pairs(items) do
		if item then
			v55[k] = true
		end
	end

	for k in pairs(v54) do
		applyAutoSellSlot(k, v55[k] == true)
	end
end

function serializeAutoSellState()
	local result = {}

	for k, v57 in pairs(v55) do
		if v57 then
			result[k] = true
		end
	end

	return result
end

function pushAutoSellState()
	local v57 = serializeAutoSellState()
	local v58 = invokeBackpack(Remotes.Haul.WriteAutoSell, v57)

	if not v58 then
		return false
	end

	local v59 = v58[1]
	local v60 = v58[2]

	if v59 then
		if typeof(v60) == "table" then
			applyAutoSellMap(v60)
		end

		return true
	else
		if typeof(v60) == "string" then
			warn((`[Backpack] Failed to update auto-sell: {v60}`))
		end

		return false
	end
end

function buildAutoSellSlots(parent)
	local raritiesBy_id = {}

	for _, v57 in pairs(AssetDirectory) do
		local rarity = v57.Rarity

		if not rarity then
			continue
		end

		local _id = rarity._id

		if typeof(_id) == "string" then
			raritiesBy_id[_id] = rarity
		end
	end

	local v57 = {}

	for _, v58 in pairs(raritiesBy_id) do
		table.insert(v57, v58)
	end

	table.sort(v57, function(a, b)
		local v58 = typeof(a.Rank) ~= "number" and 0 or a.Rank or 0
		local v59 = typeof(b.Rank) ~= "number" and 0 or b.Rank or 0

		if v58 == v59 then
			return (typeof(a.DisplayName) == "string" and a.DisplayName or a._id) < (typeof(b.DisplayName) == "string" and b.DisplayName or b._id)
		end

		return v58 < v59
	end)

	for _, v58 in ipairs(v57) do
		local _id = v58._id

		if v54[_id] then
			continue
		end

		local clone2 = template:Clone()
		clone2.Visible = true
		clone2.Name = _id
		clone2.LayoutOrder = typeof(v58.Rank) ~= "number" and 0 or v58.Rank or 0
		local textButton = clone2.TextButton
		local selected = textButton.Selected

		if selected and selected:IsA("UIGradient") then
			selected.Enabled = false
		else
			selected = nil
		end

		local textLabel = clone2:FindFirstChild("TextLabel")

		if not (textLabel and textLabel:IsA("TextLabel")) then
			textLabel = nil
		end

		if textLabel then
			local displayName = v58.DisplayName

			if typeof(displayName) == "string" and displayName ~= "" then
				textLabel.Text = displayName
			else
				textLabel.Text = _id
			end
		end

		clone2.Parent = parent
		local rarityGradient = v58.RarityGradient
		local clone3

		if typeof(rarityGradient) == "Instance" then
			clone3 = rarityGradient:Clone()
			clone3.Name = "RarityGradient"
			clone3.Parent = textButton
		end

		for _, uIGradient in ipairs(textButton:GetChildren()) do
			if not uIGradient:IsA("UIGradient") then
				continue
			end

			if uIGradient == clone3 then
				uIGradient.Enabled = true
			else
				uIGradient.Enabled = false
			end
		end

		v54[_id] = {
			Button = textButton,
			SelectedGradient = selected,
			RarityGradient = clone3
		}
		local v59 = _id
		ButtonFX(textButton, nil, function()
			if flag6 then
				return
			end

			local v60 = v55[v59] == true
			local v61 = not v60
			v55[v59] = v61
			applyAutoSellSlot(v59, v61)
			flag6 = true

			if not pushAutoSellState() then
				v55[v59] = v60
				applyAutoSellSlot(v59, v60)
			end

			flag6 = false
		end)
	end
end

function initializeAutoSellUI()
	ButtonFX(autoSell, nil, function()
		Tabs.Toggle("AutoSell")
	end)
	local v57 = {}
	local v58 = invokeBackpack(Remotes.Haul.FetchAutoSell)

	if v58 then
		local v59 = v58[1]

		if typeof(v59) == "table" then
			for k, v60 in pairs(v59) do
				if v60 then
					v57[k] = true
				end
			end
		end
	end

	buildAutoSellSlots(frame)
	applyAutoSellMap(v57)
end

function claimLowestEmptySlot(p)
	local v57 = v20

	if not (v57 and canToolUseHotbarSlot(p, v57.Index)) then
		return nil
	end

	local v58 = nil

	for i = 1, emptySlotsAttribute do
		local v59 = v19[i]

		if not v59 or v59 == v57 or (v59.Tool or v59.IsFakeSlot) then
			continue
		end

		if not canToolUseHotbarSlot(p, i) then
			continue
		end

		v58 = v59
		break
	end

	v20 = v58
	return v57
end

function getInsertableHotbarIndices(p)
	local result = {}

	for i = 1, emptySlotsAttribute do
		local v57 = v19[i]

		if not v57 or v57.IsFakeSlot or not canToolUseHotbarSlot(p, i) then
			continue
		end

		table.insert(result, i)
	end

	return result
end

function insertToolIntoFrontHotbar(p)
	local insertableHotbarIndices = getInsertableHotbarIndices(p)
	local insertableHotbarIndice = insertableHotbarIndices[1]

	if not insertableHotbarIndice then
		return nil
	end

	local v57 = v19[insertableHotbarIndice]

	if not v57 or v57.Tool and getLockedHotbarSlotForTool(p) == insertableHotbarIndice and canToolUseHotbarSlot(
		v57.Tool,
		insertableHotbarIndice
	) then
		return nil
	end

	local v58 = v20
	local index = v58 and table.find(insertableHotbarIndices, v58.Index)

	if index then
		for i = index, 2, -1 do
			local v59 = v19[insertableHotbarIndices[i]]
			local v60 = v19[insertableHotbarIndices[i - 1]]

			if v59 and v60 then
				v60:Swap(v59)
			end
		end

		v57:Fill(p)
		return v57
	else
		local insertableHotbarIndice2 = insertableHotbarIndices[#insertableHotbarIndices]
		local v59 = insertableHotbarIndice2 and v19[insertableHotbarIndice2]

		if v59 and v59.Tool then
			v59:MoveToInventory()
		end

		for i = #insertableHotbarIndices, 2, -1 do
			local v60 = v19[insertableHotbarIndices[i]]
			local v61 = v19[insertableHotbarIndices[i - 1]]

			if v60 and v61 then
				v61:Swap(v60)
			end
		end

		v57:Fill(p)
		return v57
	end
end

function _getAssetUID(value3)
	if typeof(value3) == "table" and (value3.IsVirtualAsset or value3.IsVirtualEgg) then
		return value3.UID
	end

	if typeof(value3) == "Instance" then
		return value3:GetAttribute("UID")
	end

	return nil
end

function getAttribute(value3, attributeName)
	if not value3 then
		return nil
	end

	if typeof(value3) == "table" and value3.GetAttribute or typeof(value3) == "Instance" then
		return value3:GetAttribute(attributeName)
	end

	return nil
end

function parseMutations(value3)
	if typeof(value3) == "table" then
		return table.clone(value3)
	end

	if typeof(value3) ~= "string" then
		return {}
	end

	local result = {}

	for k in string.gmatch(value3, "[^,]+") do
		local v57 = string.match(k, "^%s*(.-)%s*$")

		if v57 ~= "" then
			table.insert(result, v57)
		end
	end

	return result
end

function isAssetUIDFavorite(value3)
	if typeof(value3) ~= "string" or value3 == "" then
		return false
	end

	local v57 = Save.Await()
	local inventory2 = v57 and v57.Inventory
	local v58

	if typeof(inventory2) == "table" then
		v58 = inventory2[value3]
	end

	return typeof(v58) == "table" and AssetItems2.Decode(v58).IsFavorite == true
end

function isToolFavorite(p)
	if not isAssetTool(p) then
		return getAttribute(p, "Favorite") == true
	end

	local attribute = getAttribute(p, "Favorite")

	if typeof(attribute) == "boolean" then
		return attribute
	end

	local attribute2 = getAttribute(p, "ItemData")

	if typeof(attribute2) == "table" and attribute2.IsFavorite == true then
		return true
	end

	return isAssetUIDFavorite(_getAssetUID(p))
end

function getAssetItemData(p)
	local attribute = getAttribute(p, "ItemData")

	if typeof(attribute) == "table" then
		return attribute
	end

	local attribute2 = getAttribute(p, "Category")

	if not attribute2 then
		return nil
	end

	local attribute3 = getAttribute(p, "Scale")
	return {
		Category = attribute2,
		Mutations = parseMutations(getAttribute(p, "Mutations")),
		BaseMutation = getAttribute(p, "BaseMutation"),
		Scale = typeof(attribute3) == "number" and attribute3 or 1,
		IsFavorite = isAssetUIDFavorite(_getAssetUID(p))
	}
end

function getAssetItemDisplayName(p, p2)
	local v57 = typeof(p) == "table"

	if v57 and typeof(p.Category) == "string" and AssetDirectory[p.Category] then
		return ItemDisplay.GetNameFromItemData(p)
	end

	local displayName

	if v57 then
		displayName = p.DisplayName
	end

	local v58

	if v57 then
		v58 = p.Category
	end

	return displayName or p2 and p2.DisplayName or v58 or "Asset"
end

function getAssetItemDisplayNameWithVisualWeight(p, p2)
	return (`{getAssetItemDisplayName(p, p2)} ({AssetItems.WeightLabel(p)})`)
end

function isAssetTool(p)
	return getAttribute(p, "ItemType") == "Asset"
end

function getGearName(p)
	local attribute = getAttribute(p, "GearName")

	if typeof(attribute) == "string" and attribute ~= "" then
		return attribute
	end

	return nil
end

function getGearConfig(p)
	local gearName = getGearName(p)

	if gearName then
		return Gears.Directory[gearName]
	end

	return nil
end

function getToolUses(p)
	local attribute = getAttribute(p, "Uses")

	if typeof(attribute) == "number" then
		return (math.max(attribute, 0))
	end

	return 0
end

function shouldDisplayToolUses(p)
	local attribute = getAttribute(p, "ItemType")

	if attribute == "MutationConsumable" then
		return true
	end

	if attribute ~= "Gear" then
		return false
	end

	local gearConfig = getGearConfig(p)

	if not gearConfig then
		return false
	end

	return typeof(gearConfig.ActiveDeploymentAttribute) == "string" and gearConfig.ActiveDeploymentAttribute ~= ""
end

function getToolUsesText(p)
	return (`x{getToolUses(p)}`)
end

function getHotbarFillTool(p)
	if typeof(p) == "table" and (p.IsVirtualAsset or p.IsVirtualEgg) then
	end

	return p
end

function virtualAssetMatchesUID(p, value3: string?)
	if typeof(p) == "table" and p.IsVirtualAsset and typeof(value3) == "string" then
		return p.UID == value3
	end

	return false
end

function getVirtualAssetUID(p)
	if typeof(p) == "table" and p.IsVirtualAsset then
		return p.UID
	end

	return nil
end

function getVirtualEggUID(p)
	if typeof(p) == "table" and p.IsVirtualEgg then
		return p.UID
	end

	return nil
end

function virtualEggSlotMatchesUID(p, p2: string)
	if p and not p.IsDeleted then
		return getVirtualEggUID(p.Tool) == p2
	end

	return false
end

function findVirtualEggSlotByUID(p: string)
	for _, v57 in pairs(v19) do
		if virtualEggSlotMatchesUID(v57, p) then
			return v57
		end
	end

	return nil
end

function clearVirtualEggSlotsByUID(p: string)
	for i = #v19, 1, -1 do
		local v57 = v19[i]

		if not virtualEggSlotMatchesUID(v57, p) then
			continue
		end

		v57:Clear()

		if emptySlotsAttribute < v57.Index then
			v57:Delete()
		end
	end
end

function clearDuplicateVirtualEggSlotsByUID(p: string, p2)
	for i = #v19, 1, -1 do
		local v57 = v19[i]

		if not (v57 ~= p2 and virtualEggSlotMatchesUID(v57, p)) then
			continue
		end

		v57:Clear()

		if emptySlotsAttribute < v57.Index then
			v57:Delete()
		end
	end
end

function getRegisteredBackpackSlot(p)
	local virtualAssetUID = getVirtualAssetUID(p)

	if virtualAssetUID then
		return v35[virtualAssetUID]
	end

	local virtualEggUID = getVirtualEggUID(p)

	if virtualEggUID then
		return v41[virtualEggUID]
	end

	return v21[p]
end

function registeredSlotContainsTool(p, p2)
	if not p or p.IsDeleted then
		return false
	end

	local tool = p.Tool
	local virtualAssetUID = getVirtualAssetUID(p2)

	if virtualAssetUID then
		return getVirtualAssetUID(tool) == virtualAssetUID
	end

	local virtualEggUID = getVirtualEggUID(p2)

	if virtualEggUID then
		return getVirtualEggUID(tool) == virtualEggUID
	end

	return tool == p2
end

function unregisterVirtualBackpackSlot(p, p2)
	local virtualAssetUID = getVirtualAssetUID(p2)

	if virtualAssetUID and v35[virtualAssetUID] == p then
		v35[virtualAssetUID] = nil
	end

	if virtualAssetUID and v36[virtualAssetUID] == p2 then
		v36[virtualAssetUID] = nil
	end

	local virtualEggUID = getVirtualEggUID(p2)

	if virtualEggUID and v41[virtualEggUID] == p then
		v41[virtualEggUID] = nil
	end

	if virtualEggUID and v42[virtualEggUID] == p2 then
		v42[virtualEggUID] = nil
	end
end

function unregisterBackpackSlotTool(p, p2)
	unregisterVirtualBackpackSlot(p, p2)

	if p2 and v21[p2] == p then
		v21[p2] = nil
	end
end

function registerVirtualBackpackSlot(p, p2)
	local virtualAssetUID = getVirtualAssetUID(p2)

	if virtualAssetUID then
		v35[virtualAssetUID] = p
		v36[virtualAssetUID] = p2
	end

	local virtualEggUID = getVirtualEggUID(p2)

	if virtualEggUID then
		v41[virtualEggUID] = p
		v42[virtualEggUID] = p2
	end
end

function createVirtualAsset(UID: string, p2)
	local category = p2.Category
	local v57 = AssetDirectory[category] or BaseAssetConfig
	local clone2 = table.clone(p2)
	local assetItemDisplayName = getAssetItemDisplayName(clone2, v57)
	return {
		IsVirtualAsset = true,
		UID = UID,
		Name = assetItemDisplayName,
		TextureId = v57.Icon or "",
		ToolTip = "",
		GetAttribute = function(self, p3)
			if p3 == "ItemType" then
				return "Asset"
			elseif p3 == "UID" then
				return UID
			elseif p3 == "Category" then
				return category
			elseif p3 == "DisplayName" then
				return assetItemDisplayName
			elseif p3 == "Mutations" then
				return table.concat(clone2.Mutations or {}, ", ")
			elseif p3 == "BaseMutation" then
				return clone2.BaseMutation
			elseif p3 == "Scale" then
				return clone2.Scale
			elseif p3 == "ItemData" then
				return clone2
			end

			if p3 ~= "Favorite" then
				return nil
			end

			local v58 = Save.Await()

			if v58 and typeof(v58.Inventory) == "table" then
				return isAssetUIDFavorite(UID)
			end

			return clone2.IsFavorite == true
		end,
		IsA = function(self, p3)
			return p3 == "Tool"
		end
	}
end

function isAssetUIDPlaced(value3)
	return typeof(value3) == "string" and v37[value3] == true
end

function hasLocalAssetToolUID(p: string)
	return findAssetToolByUID(p) ~= nil
end

function refreshPlacedAssetUIDs(items)
	local v57 = {}

	for k in pairs(items) do
		if typeof(k) == "string" then
			v57[k] = true
		end
	end

	v37 = v57
end

function assetSignatureField(p)
	if p == nil then
		return ""
	end

	return (tostring(p))
end

function getAssetItemSignature(data)
	return table.concat({
		assetSignatureField(data.Category),
		table.concat(data.Mutations or {}, ","),
		assetSignatureField(data.BaseMutation),
		assetSignatureField(data.Scale),
		assetSignatureField(data.Gender),
		assetSignatureField(data.EyeColor),
		assetSignatureField(data.ColorSeed),
		assetSignatureField(data.ColorIndex),
		assetSignatureField(data.GeneratedMoney),
		assetSignatureField(data.PendingEggName),
		assetSignatureField(data.Claimed),
		assetSignatureField(data.HasBeenFirstPlaced)
	}, "\31")
end

function buildEligibleAssetDataFromSave()
	local v57 = Save.Await()

	if not v57 or typeof(v57.Inventory) ~= "table" then
		return {}, {}
	end

	local result = {}
	local result2 = {}

	for k, v58 in pairs(v57.Inventory) do
		if not (typeof(k) == "string" and typeof(v58) == "table") then
			continue
		end

		local decoded = AssetItems2.Decode(v58)
		local v59 = table.find(v57.EquippedAssets or {}, k) ~= nil

		if decoded.InFuse == true or not (not v59 or hasLocalAssetToolUID(k)) or isAssetUIDPlaced(k) then
			continue
		end

		result[k] = decoded
		result2[k] = getAssetItemSignature(decoded)
	end

	return result, result2
end

function isSerializedAssetEligibleForBackpack(p, p2)
	if typeof(p2) ~= "table" then
		return false
	end

	local decoded = AssetItems2.Decode(p2)
	local v57 = Save.Await()
	local v58 = v57 and table.find(v57.EquippedAssets or {}, p) ~= nil
	return decoded.InFuse ~= true and not (v58 and not hasLocalAssetToolUID(p)) and not isAssetUIDPlaced(p)
end

function captureEligibleAssetUIDs()
	local v57 = Save.Await()
	local result = {}

	if not v57 or typeof(v57.Inventory) ~= "table" then
		return result
	end

	for k, v58 in pairs(v57.Inventory) do
		if typeof(k) == "string" and isSerializedAssetEligibleForBackpack(k, v58) then
			result[k] = true
		end
	end

	return result
end

function queueNewEligibleAssetsForHotbar(p, items)
	for k in pairs(items) do
		if p[k] ~= true then
			v39[k] = true
		end
	end
end

function getEggConfigForRecord(p)
	if typeof(p) ~= "table" or typeof(p.AssetCategory) ~= "string" then
		return nil, nil
	end

	local v57 = AssetDirectory[p.AssetCategory]

	if v57 then
		return v57.Egg, v57
	end

	return nil, nil
end

function getAreaForEggRecord(p)
	local _, v57 = getEggConfigForRecord(p)

	if not (v57 and v57.Rarity) then
		return nil
	end

	local assetCategory = p.AssetCategory
	local _id = v57.Rarity._id or v57.Rarity.DisplayName

	for _, v58 in pairs(Areas.Directory) do
		for _, v59 in ipairs(v58.DropTable) do
			local v60 = v59[1]

			if v60 == assetCategory or v60 == _id then
				return v58
			end
		end
	end

	return nil
end

function getEggDisplayName(data)
	local v57 = EggSkins.Get(data.EggSkin)

	if v57 then
		return v57.DisplayName
	end

	local eggDisplayName = MutationHandler.EggDisplayName(data.Mutations, data.BaseMutation)

	if eggDisplayName then
		return eggDisplayName
	end

	local areaForEggRecord = getAreaForEggRecord(data)

	if areaForEggRecord then
		return (`{areaForEggRecord.DisplayName} Egg`)
	end

	return "Egg"
end

function getEggDisplayNameWithWeight(p)
	return (`{getEggDisplayName(p)} ({EggRecords.WeightLabel(p)})`)
end

function getEggIconForRecord(data, p)
	if typeof(data) ~= "table" then
		return p and p.Icon or ""
	end

	local v57 = EggSkins.Get(data.EggSkin)

	if v57 then
		return v57.Icon
	end

	local eggIcon = MutationHandler.EggIcon(data.Mutations, data.BaseMutation)

	if eggIcon and eggIcon ~= "" then
		return eggIcon
	end

	return p and p.Icon or ""
end

function getEggRecordFromTool(p)
	local attribute = getAttribute(p, "EggRecord")

	if typeof(attribute) == "table" then
		return attribute
	end

	local assetCategory = getAttribute(p, "AssetCategory") or getAttribute(p, "Category")
	local assetScale = getAttribute(p, "AssetScale") or getAttribute(p, "Scale")

	if typeof(assetCategory) == "string" and typeof(assetScale) == "number" then
		return {
			AssetCategory = assetCategory,
			AssetScale = assetScale,
			Mutations = parseMutations(getAttribute(p, "Mutations")),
			BaseMutation = getAttribute(p, "BaseMutation"),
			EggSkin = getAttribute(p, "EggSkin")
		}
	end

	return nil
end

function createVirtualEgg(UID: string, data)
	local eggConfigForRecord, v57 = getEggConfigForRecord(data)

	if eggConfigForRecord and v57 then
		local eggDisplayNameWithWeight = getEggDisplayNameWithWeight(data)
		local weightKg = EggRecords.WeightKg(data)
		return {
			IsVirtualEgg = true,
			UID = UID,
			Name = eggDisplayNameWithWeight,
			TextureId = getEggIconForRecord(data, eggConfigForRecord),
			ToolTip = eggDisplayNameWithWeight,
			GetAttribute = function(self, p2)
				if p2 == "ItemType" then
					return "AssetEgg"
				elseif p2 == "UID" then
					return UID
				end

				if p2 == "AssetCategory" or p2 == "Category" then
					return data.AssetCategory
				end

				if p2 == "DisplayName" then
					return eggDisplayNameWithWeight
				elseif p2 == "EggDisplayName" then
					return eggDisplayNameWithWeight
				elseif p2 == "EggRecord" then
					return table.clone(data)
				elseif p2 == "Mutations" then
					return table.concat(data.Mutations or {}, ", ")
				elseif p2 == "BaseMutation" then
					return data.BaseMutation
				end

				if p2 == "Weight" or p2 == "WeightKg" then
					return weightKg
				end

				if p2 == "Favorite" then
					return false
				end

				return nil
			end,
			IsA = function(self, p2)
				return p2 == "Tool"
			end
		}
	else
		return nil
	end
end

function buildVirtualEggsFromSave()
	local v57 = Save.Await()
	local eggInventory = v57 and v57.EggInventory
	local virtualEggs = {}

	if typeof(eggInventory) ~= "table" then
		return virtualEggs
	end

	for k, v58 in pairs(eggInventory) do
		if not (typeof(k) == "string" and typeof(v58) == "table" and v58.Placement == nil) then
			continue
		end

		local virtualEgg = createVirtualEgg(k, v58)

		if virtualEgg then
			virtualEggs[k] = virtualEgg
		end
	end

	return virtualEggs
end

function captureEggUIDs()
	local v57 = Save.Await()
	local eggInventory = v57 and v57.EggInventory
	local result = {}

	if typeof(eggInventory) ~= "table" then
		return result
	end

	for k, v58 in pairs(eggInventory) do
		if not (typeof(k) == "string" and typeof(v58) == "table" and v58.Placement == nil) then
			continue
		end

		result[k] = true
	end

	return result
end

function queueNewEggsForHotbar(p, items)
	for k in pairs(items) do
		if not p[k] then
			v43[k] = true
		end
	end
end

function clearInstanceAssetSlots()
	local v57 = false

	for _, v58 in pairs(v19) do
		local tool = v58 and v58.Tool

		if not (v58 and typeof(tool) == "Instance" and tool:IsA("Tool") and isAssetTool(tool)) then
			continue
		end

		v58:Clear()
		v57 = true

		if emptySlotsAttribute < v58.Index then
			v58:Delete()
		end
	end

	return v57
end

function clearPlacedAssetBackpackSlot(p: string)
	v39[p] = nil
	v38[p] = nil
	local v57 = false

	for i = #v19, 1, -1 do
		local v58 = v19[i]
		local tool = v58 and v58.Tool

		if not (v58 and tool and getAttribute(tool, "ItemType") == "Asset" and _getAssetUID(tool) == p) then
			continue
		end

		v58:Clear()
		v57 = true

		if emptySlotsAttribute < v58.Index then
			v58:Delete()
		end
	end

	v35[p] = nil
	v36[p] = nil
	return v57
end

function clearPlacedAssetBackpackSlots(items)
	local v57 = false

	for k in pairs(items) do
		if typeof(k) == "string" and clearPlacedAssetBackpackSlot(k) then
			v57 = true
		end
	end

	return v57
end

function syncAssetsFromSave()
	if not scrollingFrame then
		return false
	end

	local eligibleAssetDataFromSave, v57 = buildEligibleAssetDataFromSave()
	local v58 = clearInstanceAssetSlots()

	for k, v59 in pairs(v35) do
		if eligibleAssetDataFromSave[k] then
			continue
		end

		if v59 and not v59.IsDeleted then
			v59:Clear()

			if emptySlotsAttribute < v59.Index then
				v59:Delete()
			end
		end

		v35[k] = nil
		v38[k] = nil
		v58 = true
	end

	for k, v59 in pairs(eligibleAssetDataFromSave) do
		local v60 = v57[k]
		local v61 = v35[k]
		local v62 = v61 and not v61.IsDeleted and virtualAssetMatchesUID(v61.Tool, k)

		if not v62 or v38[k] ~= v60 then
			if not v62 then
				v61 = FindEmptyInventorySlot() or MakeSlot(scrollingFrame)
			end

			v35[k] = v61
			v36[k] = createVirtualAsset(k, v59)
			v38[k] = v60
			v61:Fill(v36[k])
			v58 = true
		elseif v61 then
			v36[k] = v61.Tool
			v38[k] = v60

			if v61.UpdateFavoriteVisual and v61:UpdateFavoriteVisual() then
				v58 = true
			end
		end
	end

	for k in pairs(v36) do
		if not eligibleAssetDataFromSave[k] then
			v36[k] = nil
		end
	end

	if v58 then
		AdjustHotbarFrames()
		UpdateInventorySlots()
	end

	return v58
end

function syncEggsFromSave()
	if not scrollingFrame then
		return
	end

	local virtualEggsFromSave = buildVirtualEggsFromSave()

	for k in pairs(v41) do
		if virtualEggsFromSave[k] then
			continue
		end

		clearVirtualEggSlotsByUID(k)
		v41[k] = nil
	end

	for k, v57 in pairs(virtualEggsFromSave) do
		local v58 = v41[k]

		if not virtualEggSlotMatchesUID(v58, k) then
			v58 = findVirtualEggSlotByUID(k)
		end

		if not v58 or v58.IsDeleted then
			v58 = FindEmptyInventorySlot() or MakeSlot(scrollingFrame)
		end

		v41[k] = v58
		v42[k] = v57
		clearDuplicateVirtualEggSlotsByUID(k, v58)
		v58:Fill(v57)
	end

	for k in pairs(v42) do
		if not virtualEggsFromSave[k] then
			v42[k] = nil
		end
	end

	AdjustHotbarFrames()
	UpdateInventorySlots()
end

function getAssetRarityNumber(p)
	local attribute = getAttribute(p, "Category")
	local v57 = attribute and AssetDirectory[attribute] or BaseAssetConfig
	local rarity = v57 and v57.Rarity

	if not rarity then
		return 1e999
	end

	if rarity.Rank then
		return rarity.Rank
	end

	if RarityDirectory[rarity] and RarityDirectory[rarity].Rank then
		return RarityDirectory[rarity].Rank
	end

	return 1e999
end

function getAssetDropWeight(p)
	local attribute = getAttribute(p, "Category")
	local v57 = attribute and AssetDirectory[attribute] or BaseAssetConfig

	if v57 and typeof(v57.DropWeight) == "number" then
		return v57.DropWeight
	end

	return 1e999
end

function getAssetOddsDenominator(p)
	if getAttribute(p, "ItemType") ~= "Asset" then
		return 0
	end

	local attribute = getAttribute(p, "Category")
	local v57 = attribute and AssetDirectory[attribute] or BaseAssetConfig
	local dropWeight = v57 and v57.DropWeight

	if typeof(dropWeight) ~= "number" or dropWeight <= 0 then
		return 0
	end

	local assetItemData = getAssetItemData(p)

	if assetItemData then
		return 1 / dropWeight * MutationHandler.RarityFactorFor(assetItemData.Mutations, assetItemData.BaseMutation)
	end

	return 0
end

function getAssetEarningRate(p)
	if getAttribute(p, "ItemType") ~= "Asset" then
		return 0
	end

	local assetItemData = getAssetItemData(p)

	if assetItemData then
		return AssetEarnings.MutationOnlyRatePerSecond(assetItemData)
	end

	return 0
end

function getEggAssetConfig(p)
	local eggRecordFromTool = getEggRecordFromTool(p)
	local _, v57 = getEggConfigForRecord(eggRecordFromTool)

	if v57 then
		return v57
	end

	local v58 = getAttribute(p, "AssetCategory") or getAttribute(p, "Category")
	return v58 and AssetDirectory[v58] or nil
end

function getEggRarityNumber(p)
	local eggAssetConfig = getEggAssetConfig(p)
	local rarity = eggAssetConfig and eggAssetConfig.Rarity

	if not rarity then
		return 1e999
	end

	if rarity.Rank then
		return rarity.Rank
	end

	if RarityDirectory[rarity] and RarityDirectory[rarity].Rank then
		return RarityDirectory[rarity].Rank
	end

	return 1e999
end

function getEggBaseEarningRate(p)
	local eggAssetConfig = getEggAssetConfig(p)

	if eggAssetConfig and typeof(eggAssetConfig.EarningRate) == "number" then
		return eggAssetConfig.EarningRate
	end

	return 0
end

function requestFavoriteToggle(p)
	if ActiveFuseSelectionState or not isAssetTool(p) then
		return
	end

	local v57 = _getAssetUID(p)

	if typeof(v57) ~= "string" or v57 == "" then
		return
	end

	local v58 = not isToolFavorite(p)
	v32(function()
		Remotes.PetSatchel.WriteFavourite:FireServer(v57, v58)
	end)
end

function getStackQuantity(p)
	local attribute = getAttribute(p, "StackQuantity")

	if typeof(attribute) == "number" and attribute > 1 then
		return (math.floor(attribute))
	end

	return 1
end

function clearMutationIconFrame(instance, p)
	if not (instance and p) then
		return
	end

	for _, image in ipairs(instance:GetChildren()) do
		if image:IsA("ImageLabel") and image ~= p then
			image:Destroy()
		end
	end

	instance.Visible = false
end

function populateMutationIconFrame(p, p2, _: string?, _)
	if p and p2 then
		clearMutationIconFrame(p, p2)
		p.Visible = false
	end
end

function updateEquipSelectionVisuals()
	for _, v57 in pairs(v19) do
		if v57 then
			v57:UpdateEquipView()
		end
	end
end

function findVirtualAssetSlotContainingUID(p: string)
	for _, v57 in pairs(v19) do
		if v57 and virtualAssetMatchesUID(v57.Tool, p) then
			return v57
		end
	end

	return nil
end

function getCharacterAssetToolUID()
	for _, tool in ipairs(character:GetChildren()) do
		if not (tool:IsA("Tool") and tool:GetAttribute("ItemType") == "Asset") then
			continue
		end

		local UID = tool:GetAttribute("UID")

		if typeof(UID) == "string" then
			return UID
		end
	end

	return nil
end

function findAssetToolByUID(p: string)
	local function searchContainer(instance)
		if not instance then
			return nil
		end

		for _, tool in ipairs(instance:GetChildren()) do
			if tool:IsA("Tool") and tool:GetAttribute("ItemType") == "Asset" and tool:GetAttribute("UID") == p then
				return tool
			end
		end

		return nil
	end

	local v57 = searchContainer(character)

	if v57 then
		return v57
	end

	local v58 = searchContainer(backpack2)
	return v58 or nil
end

function applyVirtualAssetEquipUID(value3: string?)
	v34 = value3

	if typeof(value3) == "string" then
		SelectedSlot = findVirtualAssetSlotContainingUID(value3)
	elseif SelectedSlot and getAttribute(SelectedSlot.Tool, "ItemType") == "Asset" then
		SelectedSlot = nil
	end

	updateEquipSelectionVisuals()
end

function reconcileVirtualAssetEquipState()
	local characterAssetToolUID = getCharacterAssetToolUID()

	if characterAssetToolUID ~= v34 then
		applyVirtualAssetEquipUID(characterAssetToolUID)
		return characterAssetToolUID
	end

	if typeof(characterAssetToolUID) == "string" and not SelectedSlot then
		SelectedSlot = findVirtualAssetSlotContainingUID(characterAssetToolUID)
		updateEquipSelectionVisuals()
	end

	return characterAssetToolUID
end

function syncVirtualAssetEquipStateFromTool(instance)
	local UID = instance:GetAttribute("UID")

	if typeof(UID) ~= "string" then
		return
	end

	if instance.Parent == character then
		applyVirtualAssetEquipUID(UID)
	elseif instance.Parent == backpack2 and v34 == UID then
		task.defer(reconcileVirtualAssetEquipState)
	end
end

function getCharacterEggToolUID()
	for _, tool in ipairs(character:GetChildren()) do
		if not (tool:IsA("Tool") and tool:GetAttribute("ItemType") == "AssetEgg") then
			continue
		end

		local UID = tool:GetAttribute("UID")

		if typeof(UID) == "string" then
			return UID
		end
	end

	return nil
end

function applyVirtualEggEquipUID(value3: string?)
	v46 = value3

	if typeof(value3) == "string" then
		SelectedSlot = findVirtualEggSlotByUID(value3)
	elseif SelectedSlot and getAttribute(SelectedSlot.Tool, "ItemType") == "AssetEgg" then
		SelectedSlot = nil
	end

	updateEquipSelectionVisuals()
end

function reconcileVirtualEggEquipState()
	local characterEggToolUID = getCharacterEggToolUID()

	if characterEggToolUID ~= v46 then
		applyVirtualEggEquipUID(characterEggToolUID)
		return characterEggToolUID
	end

	if typeof(characterEggToolUID) == "string" and not SelectedSlot then
		SelectedSlot = findVirtualEggSlotByUID(characterEggToolUID)
		updateEquipSelectionVisuals()
	end

	return characterEggToolUID
end

function syncVirtualEggEquipStateFromTool(instance)
	local UID = instance:GetAttribute("UID")

	if typeof(UID) ~= "string" then
		return
	end

	if instance.Parent == character then
		applyVirtualEggEquipUID(UID)
	elseif instance.Parent == backpack2 and v46 == UID then
		task.defer(reconcileVirtualEggEquipState)
	end
end

function requestUnequipVirtualEgg()
	reconcileVirtualEggEquipState()

	if not v46 then
		return true
	end

	local v57 = false
	v31(function()
		local v58 = v46
		local doffEggTool, text = EggState.DoffEggTool(v58)

		if doffEggTool then
			v46 = nil

			if SelectedSlot and getAttribute(SelectedSlot.Tool, "UID") == v58 then
				SelectedSlot = nil
			end

			updateEquipSelectionVisuals()
			v57 = true
		elseif text then
			Toast.Show({
				Text = text,
				Seconds = 2,
				Color = Color3.fromRGB(255, 64, 64)
			})
		end
	end)
	return v57
end

function requestEquipVirtualEgg(p: string, p2)
	if isBackpackEquipInteractionBlocked() then
		return
	end

	if reconcileVirtualEggEquipState() ~= p then
		v31(function()
			requestUnequipVirtualAsset()

			if humanoid then
				humanoid:UnequipTools()
			end

			local wearEggTool, text = EggState.WearEggTool(p)

			if wearEggTool then
				v46 = p
				SelectedSlot = p2
				updateEquipSelectionVisuals()
			elseif text then
				Toast.Show({
					Text = text,
					Seconds = 2,
					Color = Color3.fromRGB(255, 64, 64)
				})
			end
		end)
		return
	end

	SelectedSlot = p2
	updateEquipSelectionVisuals()
end

function requestUnequipVirtualAsset()
	reconcileVirtualAssetEquipState()

	if not v34 then
		return true
	end

	local v57 = false
	v31(function()
		local v58 = v34
		local v59, text = Remotes.PenRoster.AskDoff:InvokeServer(v58)

		if v59 == false then
			if text and text ~= "Asset is not available." then
				Toast.Show({
					Text = text,
					Seconds = 2,
					Color = Color3.fromRGB(255, 64, 64)
				})
			end
		else
			v34 = nil

			if SelectedSlot and virtualAssetMatchesUID(SelectedSlot.Tool, v58) then
				SelectedSlot = nil
			end

			updateEquipSelectionVisuals()
			v57 = true
		end
	end)
	return v57
end

function addVirtualAssetOverlay(instance, data, p, object, flag7: boolean?)
	if not (instance:GetAttribute("IsInventorySlot") or flag7) or instance:GetAttribute("HasAssetOverlay") and not flag7 then
		return
	end

	local rarity = not p.Rarity and "Unknown" or p.Rarity.DisplayName or p.Rarity._id or p.Rarity.Name
	local assetItemDisplayName = getAssetItemDisplayName(data, p)
	local v58

	if typeof(data) == "table" and typeof(data.Category) == "string" and AssetDirectory[data.Category] then
		v58 = AssetEarnings.MutationOnlyRatePerSecond(data)
	else
		v58 = AssetEarnings.ComputeBaseRateFromDropWeight(p.DropWeight)
	end

	local text

	if typeof(data) == "table" and typeof(data.Mutations) == "table" then
		text = ItemDisplay.GetMutationRichTextLine(data.Mutations, data.BaseMutation)
	else
		text = nil
	end

	local text2

	if typeof(data) == "table" and typeof(data.Category) == "string" and typeof(data.Scale) == "number" then
		text2 = AssetItems.WeightLabel(data)
	else
		text2 = nil
	end

	local function getInfo()
		if not instance:GetAttribute("IsInventorySlot") then
			return nil
		end

		local v61 = {
			{
				kind = "heading",
				text = assetItemDisplayName
			},
			{
				kind = "rule"
			},
			{
				kind = "tier",
				rarity = rarity
			},
			{
				kind = "rule"
			},
			{
				kind = "heading",
				text = "$" .. SimpleNumber.FormatCompact(v58, ".#") .. "/s",
				tint = Color3.new(0, 1, 0)
			}
		}

		if text2 then
			table.insert(v61, 2, {
				kind = "body",
				text = text2
			})
		end

		if text then
			table.insert(v61, {
				kind = "rule"
			})
			table.insert(v61, {
				kind = "body",
				text = text
			})
		end

		return v61
	end

	local v61 = HoverCard.Attach(instance, getInfo)

	if object then
		object:Add(v61)
	end

	instance:SetAttribute("HasAssetOverlay", true)
end

function addVirtualEggOverlay(instance, p, object)
	if not instance:GetAttribute("IsInventorySlot") or instance:GetAttribute("HasEggOverlay") then
		return
	end

	local eggDisplayNameWithWeight = getEggDisplayNameWithWeight(p)
	local _, v57 = getEggConfigForRecord(p)
	local rarity = v57 and v57.Rarity
	local v58

	if v57 == nil then
		v58 = false
	else
		v58 = v57.Egg.HideRarity == true
	end

	local text = not rarity and "Egg" or rarity.DisplayName or rarity._id or rarity.Name
	local color2

	if rarity then
		color2 = rarity.Color
	else
		color2 = Color3.new(1, 1, 1)
	end

	local function getInfo()
		if not instance:GetAttribute("IsInventorySlot") then
			return nil
		end

		local v60 = {
			{
				kind = "heading",
				text = eggDisplayNameWithWeight
			}
		}

		if not v58 then
			table.insert(v60, {
				kind = "rule"
			})
			table.insert(v60, {
				kind = "heading",
				text = text,
				tint = color2
			})
		end

		return v60
	end

	local v60 = HoverCard.Attach(instance, getInfo)

	if object then
		object:Add(v60)
	end

	instance:SetAttribute("HasEggOverlay", true)
end

function NewGui(className, name)
	local instance = Instance.new(className)
	instance.Name = name
	instance.BackgroundColor3 = Color3.new(0, 0, 0)
	instance.BackgroundTransparency = 1
	instance.BorderColor3 = Color3.new(0, 0, 0)
	instance.BorderSizePixel = 0
	instance.Size = UDim2.new(1, 0, 1, 0)

	if not className:match("Text") then
		return instance
	end

	instance.TextColor3 = Color3.new(1, 1, 1)
	instance.Text = ""
	instance.FontFace = script:GetAttribute("LabelFont")
	instance.TextSize = TextSizeAttribute
	instance.TextWrapped = true

	if className == "TextButton" then
		instance.FontFace = script:GetAttribute("SlotFont")
	end

	return instance
end

function FindLowestEmpty(p)
	for i = 1, emptySlotsAttribute do
		local v57 = v19[i]

		if v57 and not v57.IsFakeSlot and not v57.Tool and canToolUseHotbarSlot(p, i) then
			return v57
		end
	end

	return nil
end

function FindEmptyInventorySlot()
	for i = emptySlotsAttribute + 1, #v19 do
		local v57 = v19[i]

		if v57 and not v57.Tool then
			return v57
		end
	end

	return nil
end

function cancelPendingBackpackRoundRestore()
	if v56 then
		task.cancel(v56)
		v56 = nil
	end
end

function moveRestrictedHotbarToolsToInventory()
	for i = 1, emptySlotsAttribute do
		local v57 = v19[i]

		if not v57 or v57.IsFakeSlot or not v57.Tool or isToolLockedToCurrentHotbarSlot(v57) then
			continue
		end

		v57:MoveToInventory()
	end
end

function isGearTool(p)
	return getAttribute(p, "ItemType") == "Gear" or typeof(getAttribute(p, "GearName")) == "string"
end

function isPhoneTool(p)
	return getAttribute(p, "ItemType") == "Phone"
end

function isBatGearTool(p)
	local gearConfig = getGearConfig(p)
	return gearConfig ~= nil and gearConfig.BatControllerData ~= nil
end

function isTrapGearTool(p)
	return getGearName(p) == "Trap"
end

function getLockedHotbarSlotForTool(tool)
	if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
		return nil
	end

	if isPhoneTool(tool) and TreadmillFlags.PhoneEnabled:Get() then
		return 3
	end

	if not isGearTool(tool) then
		return nil
	end

	if isBatGearTool(tool) then
		return 1
	end

	if isTrapGearTool(tool) then
		return 2
	end

	return nil
end

function canToolUseHotbarSlot(tool, p: number)
	if p == 3 and TreadmillFlags.PhoneEnabled:Get() then
		return typeof(tool) == "Instance" and tool:IsA("Tool") and isPhoneTool(tool)
	elseif p == 1 then
		return typeof(tool) == "Instance" and tool:IsA("Tool") and isGearTool(tool) and isBatGearTool(tool)
	else
		if p ~= 2 then
			local lockedHotbarSlotForTool = getLockedHotbarSlotForTool(tool)
			return lockedHotbarSlotForTool == nil or lockedHotbarSlotForTool == p
		end

		return typeof(tool) == "Instance" and tool:IsA("Tool") and isGearTool(tool) and isTrapGearTool(tool)
	end
end

function isToolLockedToCurrentHotbarSlot(data)
	if not data or data.IsFakeSlot or not data.Tool then
		return false
	end

	local lockedHotbarSlotForTool = getLockedHotbarSlotForTool(data.Tool)
	return lockedHotbarSlotForTool ~= nil and lockedHotbarSlotForTool == data.Index
end

function findGearSlot(callback)
	for _, v57 in pairs(v19) do
		if v57 and not v57.IsFakeSlot and v57.Tool and isGearTool(v57.Tool) and callback(v57.Tool) then
			return v57
		end
	end

	return nil
end

function moveGameplayGearToHotbarSlot(callback, p: number)
	local gearSlot = findGearSlot(callback)

	if not gearSlot then
		return false
	end

	local v57 = v19[p]

	if not v57 or v57.IsFakeSlot or gearSlot == v57 or v57.Tool and canToolUseHotbarSlot(v57.Tool, p) then
		return false
	end

	gearSlot:Swap(v57)

	if emptySlotsAttribute < gearSlot.Index and not gearSlot.Tool then
		gearSlot:Delete()
	end

	return true
end

function moveInvalidLockedHotbarSlotToolToInventory(p: number)
	local v57 = v19[p]

	if not v57 or v57.IsFakeSlot or not v57.Tool or canToolUseHotbarSlot(v57.Tool, p) then
		return false
	end

	local tool = v57.Tool
	v57:MoveToInventory()
	return v57.Tool ~= tool
end

function returnUncategorizedToolsToHotbar()
	local v57 = {}

	for _, v58 in pairs(v19) do
		if not v58 or v58.IsFakeSlot or not (emptySlotsAttribute < v58.Index) or not v58.Tool then
			continue
		end

		if HasInventoryCategory(v58.Tool) then
			continue
		end

		table.insert(v57, v58)
	end

	local v58 = false

	for _, v59 in v57 do
		if not v59.Tool then
			continue
		end

		for i = 1, emptySlotsAttribute do
			local v60 = v19[i]

			if not v60 or (v60.IsFakeSlot or v60.Tool) or not canToolUseHotbarSlot(v59.Tool, i) then
				continue
			end

			v59:Swap(v60)

			if not v59.Tool then
				v59:Delete()
			end

			v58 = true
			break
		end
	end

	return v58
end

function ensureGameplayGearHotbarSlots()
	local v57 = moveGameplayGearToHotbarSlot(isBatGearTool, 1) and true or false
	local v58 = moveGameplayGearToHotbarSlot(isTrapGearTool, 2) and true or v57
	local v59 = moveInvalidLockedHotbarSlotToolToInventory(1) and true or v58
	local v60 = moveInvalidLockedHotbarSlotToolToInventory(2) and true or v59

	if not (returnUncategorizedToolsToHotbar() or v60) then
		return
	end

	AdjustHotbarFrames()
	UpdateInventorySlots()

	if performSearch then
		performSearch(true)
	end
end

function isToolInCharacterOrBackpack(tool)
	if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
		return false
	end

	local parent = tool.Parent
	return parent == character or parent == backpack2
end

function _isInventoryEmpty()
	for i = emptySlotsAttribute + 1, #v19 do
		local v57 = v19[i]

		if v57 and v57.Tool then
			return false
		end
	end

	return true
end

function _UseGazeSelection()
	return UserInputService.VREnabled
end

function AdjustHotbarFrames()
	debug.profilebegin("BackpackController :: AdjustHotbarFrames")

	for i = 1, emptySlotsAttribute do
		local v57 = v19[i]

		if v57 then
			v57:SetNumberText(nil)
		end
	end

	local visible = inventory.Visible
	local v57 = {}

	for i = 1, emptySlotsAttribute do
		local slot = v19[i]
		local isFakeSlot = slot and (slot.IsFakeSlot or slot.Tool or visible)

		if v27 then
			isFakeSlot = slot and slot.Tool and isPhoneTool(slot.Tool)
		end

		if isFakeSlot then
			table.insert(v57, {
				Kind = "Slot",
				Slot = slot
			})
		end
	end

	local v58 = math.max(1, #v57)
	v24 = v58
	local count = 0

	for i = 1, emptySlotsAttribute do
		local v59 = v19[i]

		if v59 then
			v59.Frame.Visible = false
		end
	end

	for _, v59 in ipairs(v57) do
		count += 1
		local slot = v59.Slot

		if not slot then
			continue
		end

		slot.Frame.LayoutOrder = count
		slot:Readjust(count, v58)
		slot.Frame.Visible = true
	end

	PositionInventoryAffordances()
	debug.profileend()
end

function UpdateScrollingFrameCanvasSize()
	debug.profilebegin("BackpackController :: UpdateScrollingFrameCanvasSize")

	if v17 then
		v17()
	end

	debug.profileend()
end

function UpdateInventorySlots()
	debug.profilebegin("BackpackController :: UpdateInventorySlots")

	if flag then
		if performSearch then
			performSearch()
		end
	else
		local v57 = {}
		local v58 = {}
		local v59 = {}
		local v60 = {}
		local v61 = {}

		for i = emptySlotsAttribute + 1, #v19 do
			local v62 = v19[i]
			local tool = v62.Tool

			if tool then
				if IsOfCategory(tool) then
					local attribute = getAttribute(tool, "ItemType")

					if attribute == "Asset" then
						table.insert(v60, v62)
					elseif attribute == "AssetEgg" then
						table.insert(v59, v62)
					elseif attribute == "Sword" then
						table.insert(v58, v62)
					else
						table.insert(v57, v62)
					end

					v62.Frame.Visible = true
				else
					v62.Frame.Visible = false
				end
			else
				table.insert(v61, v62)
				v62.Frame.Visible = false
			end
		end

		table.sort(v60, function(a, b)
			local tool = a.Tool
			local tool2 = b.Tool
			local selected = tool and isToolFavorite(tool)

			if selected ~= (tool2 and isToolFavorite(tool2)) then
				return selected
			end

			local v63 = not tool and 1e999 or getAssetRarityNumber(tool) or 1e999
			local v64 = not tool2 and 1e999 or getAssetRarityNumber(tool2) or 1e999

			if v63 ~= v64 then
				return v64 < v63
			end

			local v65 = not tool and 0 or getAssetEarningRate(tool) or 0
			local v66 = not tool2 and 0 or getAssetEarningRate(tool2) or 0

			if v65 ~= v66 then
				return v66 < v65
			end

			local v67 = not tool and 0 or getAssetOddsDenominator(tool) or 0
			local v68 = not tool2 and 0 or getAssetOddsDenominator(tool2) or 0

			if v67 ~= v68 then
				return v68 < v67
			end

			local v69 = not tool and 1e999 or getAssetDropWeight(tool) or 1e999
			local v70 = not tool2 and 1e999 or getAssetDropWeight(tool2) or 1e999

			if v69 ~= v70 then
				return v69 < v70
			end

			local v71 = not tool and 0 or getAttribute(tool, "Weight") or 0
			local v72 = not tool2 and 0 or getAttribute(tool2, "Weight") or 0

			if v71 == v72 then
				return (tool and getAttribute(tool, "UID") or "") < (tool2 and getAttribute(tool2, "UID") or "")
			end

			return v72 < v71
		end)
		table.sort(v59, function(a, b)
			local tool = a.Tool
			local tool2 = b.Tool
			local v62 = not tool and 1e999 or getEggRarityNumber(tool) or 1e999
			local v63 = not tool2 and 1e999 or getEggRarityNumber(tool2) or 1e999

			if v62 ~= v63 then
				return v63 < v62
			end

			local v64 = not tool and 0 or getEggBaseEarningRate(tool) or 0
			local v65 = not tool2 and 0 or getEggBaseEarningRate(tool2) or 0

			if v64 == v65 then
				return (tool and getAttribute(tool, "UID") or "") < (tool2 and getAttribute(tool2, "UID") or "")
			end

			return v65 < v64
		end)
		table.sort(v58, function(a, b)
			return (getAttribute(a.Tool, "MoneyCost") or 0) > (getAttribute(b.Tool, "MoneyCost") or 0)
		end)
		local layoutOrder = emptySlotsAttribute

		for _, v63 in ipairs(v60) do
			layoutOrder += 1
			v63.Frame.LayoutOrder = layoutOrder
		end

		for _, v63 in ipairs(v59) do
			layoutOrder += 1
			local v64

			if v63.Tool then
				v64 = getEggAssetConfig(v63.Tool)
			end

			v63.Frame.LayoutOrder = v64 and v64.Egg.HideRarity and -2147483648 or layoutOrder
		end

		for _, v63 in ipairs(v58) do
			layoutOrder += 1
			v63.Frame.LayoutOrder = layoutOrder
		end

		for _, v63 in ipairs(v57) do
			layoutOrder += 1
			v63.Frame.LayoutOrder = layoutOrder
		end

		for _, v63 in ipairs(v61) do
			layoutOrder += 1
			v63.Frame.LayoutOrder = layoutOrder
		end

		UpdateScrollingFrameCanvasSize()
		debug.profileend()
	end
end

function ResizeContainers()
	parent2.Size = UDim2.new(0, 5 + emptySlotsAttribute * (v5 + 5), 0, v5 + 5 + 5)
	parent2.Position = UDim2.new(0.5, -parent2.Size.X.Offset / 2, 1, -parent2.Size.Y.Offset)
	main.Size = UDim2.new(0, parent2.Size.X.Offset, 0, parent2.Size.Y.Offset * v30 + 40 + (vREnabled and 80 or 0))
	main.Position = UDim2.new(0.5, -main.Size.X.Offset / 2, 1, parent2.Position.Y.Offset - main.Size.Y.Offset)
	PositionInventoryAffordances()
	AdjustHotbarFrames()
	UpdateInventorySlots()
end

INVENTORY_AFFORDANCE_GAP = 8
PROMPT_HOTBAR_GAP = 28

function PositionInventoryAffordances()
	local X = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 0

	if X > 0 then
		local v57 = 2.5 - (v5 + 5) * math.max(1, v24) * 0.5
		ButtonHintStrip.PinRight(0.5 + (v57 - PROMPT_HOTBAR_GAP) / X)
	end

	if PlatformController.IsConsole() and v26 then
		ButtonHintStrip.Present("Backpack", Enum.KeyCode.ButtonSelect, "Backpack")
	else
		ButtonHintStrip.Retract("Backpack")
	end
end

function _Clamp(p, p2, p3)
	return (math.min(p2, (math.max(p, p3))))
end

function CheckBounds(p, p2, p3)
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	return absolutePosition.X < p2 and p2 <= absolutePosition.X + absoluteSize.X and absolutePosition.Y < p3 and p3 <= absolutePosition.Y + absoluteSize.Y
end

function GetOffset(p, p2)
	return (p.AbsolutePosition + p.AbsoluteSize / 2 - p2).magnitude
end

function UnequipAllTools(_: boolean?, _: boolean?)
	requestUnequipVirtualAsset()
	requestUnequipVirtualEgg()

	if humanoid then
		humanoid:UnequipTools()
	end
end

function _EquipNewTool(p)
	if isBackpackEquipInteractionBlocked() or (humanoid == nil or humanoid.Health <= 0) then
		return
	end

	UnequipAllTools()
	p.Parent = character
end

function _ToggleFavoriteTool(p)
	local tool = p.Tool

	if not tool then
		return
	end

	requestFavoriteToggle(tool)
end

function _IsEquipped(p)
	return p and p.Parent == character
end

function MakeSlot(parent, p)
	local name2 = p or #v19 + 1
	local v58 = {
		Tool = nil,
		Index = name2,
		Frame = nil,
		IsFakeSlot = false,
		FakeType = nil,
		IsDeleted = false
	}
	local visible2 = parent == scrollingFrame or emptySlotsAttribute < name2
	local v60 = nil
	local shadow = nil
	local toolName = nil
	local weight = nil
	local mutations = nil
	local template2 = nil
	local changedConnection = nil
	local favoriteChangedConnection = nil
	local weightChangedConnection = nil
	local connections2 = {}
	local heartbeatConnection = nil
	local parent3 = nil
	local selector = nil
	local toolTip = nil
	local number = nil
	local favIcon = nil
	local v62 = nil
	local textXAlignment = nil
	local textYAlignment = nil
	local v63 = 0
	local v64 = nil
	local v65

	if visible2 then
		v65 = script.InventoryTemplate
	else
		v65 = script.HotbarTemplate
	end

	local clone2 = v65:Clone()
	clone2.Name = name2
	clone2.ZIndex = 20
	local icon = clone2.Icon
	local parent4 = NewGui("Frame", "CooldownOverlay")
	parent4.BackgroundColor3 = Color3.new(0, 0, 0)
	parent4.BackgroundTransparency = 0.35
	parent4.BorderSizePixel = 0
	parent4.Size = UDim2.fromScale(1, 1)
	parent4.Visible = false
	parent4.ZIndex = 20
	parent4.Parent = clone2
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = script:GetAttribute("CornerRadius")
	uICorner.Parent = parent4
	local v67 = NewGui("TextLabel", "CooldownLabel")
	v67.BackgroundTransparency = 1
	v67.Size = UDim2.new(1, -4, 1, -4)
	v67.Position = UDim2.fromOffset(2, 2)
	v67.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold)
	v67.TextColor3 = Color3.new(1, 1, 1)
	v67.TextStrokeColor3 = Color3.new(0, 0, 0)
	v67.TextStrokeTransparency = 0.4
	v67.TextScaled = true
	v67.TextXAlignment = Enum.TextXAlignment.Center
	v67.TextYAlignment = Enum.TextYAlignment.Center
	v67.Visible = false
	v67.ZIndex = parent4.ZIndex + 1
	v67.Text = ""
	v67.Parent = parent4
	local v68 = Trove.new()

	local function restoreAssetIconHover(_: boolean?) end

	local function clearSlotOverlays()
		v68:Clean()
		clearMutationIconFrame(mutations, template2)

		if clone2 then
			clone2:SetAttribute("HasAssetOverlay", nil)
			clone2:SetAttribute("HasEggOverlay", nil)
			clone2:SetAttribute("HasSwordOverlay", nil)
		end
	end

	local function isDragRestrictedItemType(_)
		return false
	end

	local function canPlaceToolInSlot(p2, p3)
		if p2.IsFakeSlot then
			return false
		end

		if not p3 or emptySlotsAttribute < p2.Index then
			return true
		end

		if not canToolUseHotbarSlot(p3, p2.Index) then
			return false
		end

		if typeof(p3) == "table" and (p3.IsVirtualAsset or p3.IsVirtualEgg) then
			return getHotbarFillTool(p3) ~= nil
		end

		getAttribute(p3, "ItemType")
		return true
	end

	local function shouldAllowSlotDragging(tool)
		local v69 = tool or v58.Tool

		if not v69 or typeof(v69) ~= "Instance" and (typeof(v69) ~= "table" or not (v69.IsVirtualAsset or v69.IsVirtualEgg)) then
			return false
		end

		getAttribute(v69, "ItemType")

		if not canPlaceToolInSlot(v58, v69) then
			return false
		end

		return not UserInputService.VREnabled and (not (v58.Index <= emptySlotsAttribute) or inventory.Visible)
	end

	function v58:RefreshDragDetector()
		if v60 then
			local v69

			if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
				v69 = not MenuNavigation.IsCursorActive()
			else
				v69 = false
			end

			v60:SetEnabled(clone2:GetAttribute("Draggable") == true and not (v69 or UserInputService.VREnabled))
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applySlotDraggableState(draggable)
		clone2:SetAttribute("Draggable", draggable)
		v58:RefreshDragDetector()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopCooldownHeartbeat()
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end

	local function disconnectCooldownConnections()
		for _, connection in ipairs(connections2) do
			connection:Disconnect()
		end

		connections2 = {}
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hideCooldownOverlay()
		stopCooldownHeartbeat() -- equivalent call inferred; original call site unknown

		if parent4 then
			parent4.Visible = false
		end

		if v67 then
			v67.Visible = false
			v67.Text = ""
		end
	end

	local function updateCooldownDisplay()
		local tool = v58.Tool

		if tool then
			local cooldownEndTime = tool:GetAttribute("CooldownEndTime")

			if typeof(cooldownEndTime) == "number" and not (cooldownEndTime <= 0) and tool:GetAttribute("CooldownActive") then
				local v69 = cooldownEndTime - workspace:GetServerTimeNow()

				if not (v69 <= 1) then
					if parent4 then
						parent4.Visible = true
					end

					if v67 then
						v67.Visible = true
						v67.Text = tostring((math.max(math.ceil(v69), 0)))
					end

					return true
				end
			end

			hideCooldownOverlay() -- equivalent call inferred; original call site unknown
			return false
		else
			hideCooldownOverlay() -- equivalent call inferred; original call site unknown
			return false
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ensureCooldownHeartbeat(p2)
		if heartbeatConnection then
			return
		end

		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if v58.Tool == p2 then
				if not updateCooldownDisplay() and heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end
			else
				hideCooldownOverlay() -- equivalent call inferred; original call site unknown
				stopCooldownHeartbeat() -- equivalent call inferred; original call site unknown
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function connectCooldownListeners(tool)
		disconnectCooldownConnections()
		hideCooldownOverlay() -- equivalent call inferred; original call site unknown

		if not tool then
			return
		end

		local function onAttributeChanged()
			if updateCooldownDisplay() then
				ensureCooldownHeartbeat(tool) -- equivalent call inferred; original call site unknown
			else
				stopCooldownHeartbeat() -- equivalent call inferred; original call site unknown
			end
		end

		table.insert(connections2, tool:GetAttributeChangedSignal("CooldownEndTime"):Connect(onAttributeChanged))
		table.insert(connections2, tool:GetAttributeChangedSignal("CooldownActive"):Connect(onAttributeChanged))
		table.insert(connections2, tool:GetAttributeChangedSignal("CooldownDuration"):Connect(onAttributeChanged))

		if updateCooldownDisplay() then
			ensureCooldownHeartbeat(tool) -- equivalent call inferred; original call site unknown
		else
			stopCooldownHeartbeat() -- equivalent call inferred; original call site unknown
		end
	end

	function v58:updateDragAppearance()
		if v58.IsFakeSlot then
			clone2.BackgroundTransparency = SlotLockedTransparencyAttribute
			clone2.BackgroundColor3 = BackgroundColorAttribute
		else
			clone2.SelectionImageObject = nil
			local v69 = self.Tool and getAttribute(self.Tool, "ItemType")

			if visible2 then
				clone2.BackgroundTransparency = 0.5
				clone2.BackgroundColor3 = Color3.new(0, 0, 0)
			else
				local draggable = clone2:GetAttribute("Draggable")
				clone2.BackgroundTransparency = SlotLockedTransparencyAttribute
				clone2.BackgroundColor3 = draggable and DraggableColorAttribute or BackgroundColorAttribute
			end
		end
	end

	function v58:Readjust(p2, p3)
		local halfOffset = parent2.Size.X.Offset / 2
		local v70 = v5 + 5
		local v71 = p2 - (p3 / 2 + 0.5)
		local anchorPoint = clone2.AnchorPoint
		local size = clone2.Size
		clone2.Position = UDim2.new(
			0,
			halfOffset - v5 / 2 + v70 * v71 + size.X.Offset * anchorPoint.X,
			0,
			5 + size.Y.Offset * anchorPoint.Y
		)
	end

	function v58:SetNumberText(p2: string?)
		if number then
			number.Text = p2 or v62 or ""
		end
	end

	function v58:Fill(tool)
		if self.IsFakeSlot and self.FakeType ~= "SwordEquip" or tool and not canPlaceToolInSlot(self, tool) then
			return
		end

		if v60 then
			v60:Cancel()
		end

		if self.Tool ~= tool then
			v63 = 0
			v64 = nil
		end

		clearSlotOverlays()

		if favoriteChangedConnection then
			favoriteChangedConnection:Disconnect()
			favoriteChangedConnection = nil
		end

		if weightChangedConnection then
			weightChangedConnection:Disconnect()
			weightChangedConnection = nil
		end

		connectCooldownListeners() -- equivalent call inferred; original call site unknown

		if not tool then
			return self:Clear()
		end

		if self.Tool and self.Tool ~= tool then
			self:Clear()
		end

		local v69 = typeof(tool) == "Instance"
		local attribute = getAttribute(tool, "ItemType")
		local registeredBackpackSlot = getRegisteredBackpackSlot(tool)

		if registeredBackpackSlot and registeredBackpackSlot ~= self and registeredSlotContainsTool(
			registeredBackpackSlot,
			tool
		) then
			registeredBackpackSlot:Clear()

			if emptySlotsAttribute < registeredBackpackSlot.Index then
				registeredBackpackSlot:Delete()
			end
		end

		self.Tool = tool
		registerVirtualBackpackSlot(self, tool)
		self:UpdateFavoriteVisual()

		if v69 then
			favoriteChangedConnection = tool:GetAttributeChangedSignal("Favorite"):Connect(function()
				self:UpdateFavoriteVisual()

				if isAssetTool(tool) then
					UpdateInventorySlots()
				end
			end)
		end

		function v58.UpdateVisuals()
			local textureId = tool.TextureId
			AssetIconShape.Strip(icon)
			icon.Image = textureId
			icon.ScaleType = Enum.ScaleType.Fit
			toolName.TextXAlignment = textXAlignment
			toolName.TextYAlignment = textYAlignment
			shadow.Visible = false
			clearMutationIconFrame(mutations, template2)

			for _, uIGradient in ipairs(shadow:GetChildren()) do
				if uIGradient:IsA("UIGradient") then
					uIGradient:Destroy()
				end
			end

			for _, uIGradient in ipairs(toolName:GetChildren()) do
				if uIGradient:IsA("UIGradient") then
					uIGradient:Destroy()
				end
			end

			for _, uIGradient in ipairs(weight:GetChildren()) do
				if uIGradient:IsA("UIGradient") then
					uIGradient:Destroy()
				end
			end

			local v70 = string.match(tool.Name, "%[X(%d+)%]")
			local name = tool.Name
			local visible = true
			local text = ""
			local v74

			if attribute == "Asset" then
				local attribute2 = getAttribute(tool, "Category")
				local v75 = attribute2 and AssetDirectory[attribute2]

				if v75 then
					local assetItemData = getAssetItemData(tool)

					if assetItemData then
						AssetIconShape.Paint(icon, assetItemData)
					else
						icon.Image = v75.Icon or textureId
					end

					icon.ImageColor3 = Color3.new(1, 1, 1)

					if v75.Rarity and v75.Rarity.RarityGradient then
						local parent5 = toolName
						local clone = v75.Rarity.RarityGradient:Clone()
						clone.Parent = parent5

						if visible2 then
							local clone_2 = v75.Rarity.RarityGradient:Clone()
							clone_2.Parent = shadow
						end
					end
				end

				shadow.Visible = visible2
				local assetItemData = getAssetItemData(tool)

				if assetItemData then
					name = getAssetItemDisplayNameWithVisualWeight(assetItemData, v75 or BaseAssetConfig)
				else
					name = getAttribute(tool, "DisplayName") or tool.Name
				end

				local v76 = parseMutations(getAttribute(tool, "Mutations"))
				local attribute3 = getAttribute(tool, "BaseMutation")
				visible = true

				if visible2 or typeof(tool) == "table" and tool.IsVirtualAsset then
					populateMutationIconFrame(mutations, template2, attribute3, v76)
					text = ""

					if not visible2 then
						visible = false
					end
				else
					name = ""
				end

				v74 = name
			elseif attribute == "AssetEgg" then
				local eggRecordFromTool = getEggRecordFromTool(tool)
				local eggConfigForRecord, v75 = getEggConfigForRecord(eggRecordFromTool)

				if eggConfigForRecord and v75 then
					local eggIconForRecord = getEggIconForRecord(eggRecordFromTool, eggConfigForRecord)
					local v76 = icon

					if eggIconForRecord ~= "" and eggIconForRecord then
						textureId = eggIconForRecord
					end

					v76.Image = textureId
					icon.ImageColor3 = Color3.new(1, 1, 1)

					if not eggConfigForRecord.HideRarity and v75.Rarity and v75.Rarity.RarityGradient then
						local parent5 = toolName
						local clone_3 = v75.Rarity.RarityGradient:Clone()
						clone_3.Parent = parent5

						if visible2 then
							local clone_4 = v75.Rarity.RarityGradient:Clone()
							clone_4.Parent = shadow
						end
					end
				end

				shadow.Visible = visible2

				if eggRecordFromTool then
					name = getEggDisplayNameWithWeight(eggRecordFromTool)
				else
					name = getAttribute(tool, "DisplayName") or tool.Name
				end

				v74 = name
				visible = true
				text = ""
			elseif attribute == "Gear" or attribute == "MutationConsumable" then
				local gearConfig = getGearConfig(tool)
				local v75 = icon

				if not textureId or textureId == "" or not textureId then
					textureId = gearConfig and gearConfig.Icon or ""
				end

				v75.Image = textureId
				icon.ImageColor3 = Color3.new(1, 1, 1)
				shadow.Visible = false
				name = ""
				v74 = not shouldDisplayToolUses(tool) and "" or getToolUsesText(tool)
				visible = v74 ~= ""

				if visible then
					toolName.TextXAlignment = Enum.TextXAlignment.Center
					toolName.TextYAlignment = Enum.TextYAlignment.Center
				end

				text = ""
			elseif textureId == "" then
				v74 = name
			elseif v70 then
				v74 = ""
				name = ""
			else
				v74 = name
				visible = false
			end

			if not visible2 then
				if not shouldDisplayToolUses(tool) then
					v74 = ""
					name = ""
					visible = false
				end

				text = ""
			end

			toolName.Text = v74 or name
			toolName.Visible = visible
			weight.Text = text
			weight.Visible = false

			if selector then
				selector.Visible = true
			end

			if toolTip and tool:IsA("Tool") then
				local v75

				if self.Index <= emptySlotsAttribute then
					v75 = attribute == "Asset" or attribute == "Pet" or attribute == "AssetEgg" or attribute == "Gear"
				else
					v75 = false
				end

				if v75 then
					toolTip.Text = ""
					toolTip.Visible = false
				else
					local toolTip2 = tool.ToolTip

					if toolTip2 == "" then
						toolTip2 = tool.Name
					end

					toolTip.Text = toolTip2
				end
			end
		end

		v58.UpdateVisuals()

		if changedConnection then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		if v69 then
			changedConnection = tool.Changed:Connect(function(p2)
				if p2 == "TextureId" or p2 == "Name" or p2 == "ToolTip" then
					v58.UpdateVisuals()
				end
			end)
		end

		if v69 and attribute == "Asset" then
			weightChangedConnection = tool:GetAttributeChangedSignal("Weight"):Connect(function()
				UpdateInventorySlots()
			end)
		elseif v69 and (attribute == "Gear" or attribute == "MutationConsumable") then
			weightChangedConnection = tool:GetAttributeChangedSignal("Uses"):Connect(function()
				v58.UpdateVisuals()
			end)

			if attribute == "Gear" then
				connectCooldownListeners(tool)
			end
		end

		local v70 = self.Index <= emptySlotsAttribute
		applySlotDraggableState(shouldAllowSlotDragging(tool)) -- equivalent call inferred; original call site unknown
		self:UpdateEquipView()

		if v70 and not self.IsFakeSlot then
			v24 += 1

			if v26 and v24 >= 1 and not v12 then
				v12 = true
				ContextActionService:BindAction(
					"RBXHotbarEquip",
					changeTool,
					false,
					Enum.KeyCode.ButtonL1,
					Enum.KeyCode.ButtonR1
				)
			end
		end

		if typeof(tool) == "Instance" then
			v21[tool] = self
		end

		if attribute == "Asset" then
			local v72 = AssetDirectory[getAttribute(tool, "Category")] or BaseAssetConfig
			local v73 = getAssetItemData(tool) or {}
			addVirtualAssetOverlay(clone2, v73, v72, v68)
		else
			local v72 = attribute == "AssetEgg" and getEggRecordFromTool(tool)

			if v72 then
				addVirtualEggOverlay(clone2, v72, v68)
			end
		end

		v20 = FindLowestEmpty()

		if visible2 and inventory.Visible and not flag then
			clone2.Visible = IsOfCategory(tool)
		end
	end

	function v58:Clear()
		if not self.Tool or self.IsFakeSlot then
			return
		end

		if v60 then
			v60:Cancel()
		end

		v63 = 0
		v64 = nil
		clearSlotOverlays()

		if changedConnection then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		if favoriteChangedConnection then
			favoriteChangedConnection:Disconnect()
			favoriteChangedConnection = nil
		end

		if weightChangedConnection then
			weightChangedConnection:Disconnect()
			weightChangedConnection = nil
		end

		connectCooldownListeners() -- equivalent call inferred; original call site unknown

		for _, uIGradient in ipairs(shadow:GetChildren()) do
			if uIGradient:IsA("UIGradient") then
				uIGradient:Destroy()
			end
		end

		shadow.Visible = false
		AssetIconShape.Strip(icon)
		icon.Image = ""
		toolName.Text = ""
		toolName.Visible = true
		weight.Text = ""
		weight.Visible = false

		if toolTip then
			toolTip.Text = ""
			toolTip.Visible = false
		end

		applySlotDraggableState(false) -- equivalent call inferred; original call site unknown
		favIcon.Visible = false
		self:UpdateEquipView(true)

		if self.Index <= emptySlotsAttribute and not self.IsFakeSlot then
			v24 -= 1

			if v24 < 1 then
				v12 = false
				ContextActionService:UnbindAction("RBXHotbarEquip")
			end
		end

		unregisterBackpackSlotTool(self, self.Tool)
		self.Tool = nil
		v20 = FindLowestEmpty()
	end

	function v58:UpdateEquipView(p3)
		if self.IsFakeSlot then
			return
		end

		local v69 = false
		local attribute = getAttribute(self.Tool, "ItemType")

		if attribute == "Asset" and typeof(self.Tool) == "table" and self.Tool.IsVirtualAsset then
			v69 = not p3 and virtualAssetMatchesUID(self.Tool, v34)
		elseif attribute == "AssetEgg" and typeof(self.Tool) == "table" and self.Tool.IsVirtualEgg then
			v69 = not p3

			if v69 then
				if typeof(v46) == "string" then
					v69 = self.Tool.UID == v46
				else
					v69 = false
				end
			end
		elseif not p3 then
			local tool = self.Tool
			v69 = tool and typeof(tool) == "Instance" and tool.Parent == character and true or false
		end

		if v69 then
			if not parent3 then
				parent3 = NewGui("Frame", "Equipped")
				parent3.ZIndex = 3
				parent3.Size = UDim2.fromScale(1, 1)
				parent3.AnchorPoint = Vector2.new(0.5, 0.5)
				parent3.Position = UDim2.fromScale(0.5, 0.5)
				local uICorner2 = Instance.new("UICorner")
				uICorner2.CornerRadius = script:GetAttribute("CornerRadius")
				uICorner2.Parent = parent3
				local uIStroke = Instance.new("UIStroke")
				uIStroke.Color = EquippedColorAttribute
				uIStroke.Thickness = 3.8
				uIStroke.Parent = parent3
			end

			parent3.Parent = clone2
		elseif parent3 then
			parent3.Parent = nil
		end
	end

	function v58:Delete()
		if self.IsFakeSlot or self.IsDeleted then
			return
		end

		self.IsDeleted = true

		if v60 then
			v60:Destroy()
		end

		if self.Tool then
			self:Clear()
		end

		clearSlotOverlays()
		connectCooldownListeners() -- equivalent call inferred; original call site unknown
		clone2:Destroy()
		local index = table.find(v19, self)

		if index then
			table.remove(v19, index)

			for i = index, #v19 do
				v19[i]:SlideBack()
			end
		end

		UpdateScrollingFrameCanvasSize()
	end

	function v58:UpdateFavoriteVisual()
		if favIcon and self.Tool then
			local toolFavorite = isToolFavorite(self.Tool)

			if favIcon.Visible ~= toolFavorite then
				favIcon.Visible = toolFavorite
				return true
			end
		end

		return false
	end

	function v58:CanSwap(p3)
		if self.IsFakeSlot or p3.IsFakeSlot then
			return false
		end

		local tool = self.Tool
		local tool2 = p3.Tool

		if tool and isToolLockedToCurrentHotbarSlot(self) and p3 ~= self or tool2 and isToolLockedToCurrentHotbarSlot(p3) and self ~= p3 then
			return false
		end

		return not (tool and not canPlaceToolInSlot(p3, tool)) and not (tool2 and not canPlaceToolInSlot(self, tool2))
	end

	function v58:Swap(object2)
		if not self:CanSwap(object2) then
			return
		end

		local tool = self.Tool
		local tool2 = object2.Tool
		self:Clear()

		if tool2 then
			object2:Clear()
			self:Fill(tool2)
		end

		if tool then
			object2:Fill(tool)
		else
			object2:Clear()
		end
	end

	function v58:SlideBack()
		self.Index -= 1
		clone2.Name = self.Index
		clone2.LayoutOrder = self.Index
	end

	function v58:TurnNumber(visible)
		if number then
			number.Visible = visible
		end
	end

	function v58:SetClickability(p2)
		if self.IsFakeSlot then
			return
		end

		if self.Tool then
			applySlotDraggableState(not p2 and shouldAllowSlotDragging(self.Tool)) -- equivalent call inferred; original call site unknown
			self:updateDragAppearance()
		end
	end

	function v58:CheckTerms(items)
		local total = 0
		local tool = self.Tool

		if not tool then
			return total
		end

		local v69 = {}

		if toolName and toolName.Text ~= "" then
			table.insert(v69, toolName.Text:lower())
		end

		local name = typeof(tool) == "table" and tool.Name or tool.Name

		if name then
			table.insert(v69, tostring(name):lower())
		end

		local text = toolTip and toolTip.Text

		if text and text ~= "" then
			table.insert(v69, text:lower())
		end

		local toolTip2 = typeof(tool) == "table" and tool.ToolTip or tool.ToolTip

		if toolTip2 and toolTip2 ~= "" then
			table.insert(v69, tostring(toolTip2):lower())
		end

		for k in pairs(items) do
			for _, v70 in ipairs(v69) do
				local _, v71 = v70:gsub(k, "")
				total += v71
			end
		end

		return total
	end

	function v58:Select()
		local tool = self.Tool

		if tool and v6 then
			if v6.ItemType == getAttribute(tool, "ItemType") and (emptySlotsAttribute < self.Index or v6.AllowHotbar) then
				local validator = v6.Validator

				if not validator or validator(tool) ~= false then
					local v69 = v6

					if ActiveFuseSelectionState then
						Main:EndFuseSelection()
						task.spawn(v69.Callback, tool)
					else
						v69.Callback(tool)

						if v69.Preserve ~= true then
							v6 = nil
						end
					end

					return
				end
			end

			if ActiveFuseSelectionState then
				return
			end
		end

		if tool then
			if isBackpackEquipInteractionBlocked() then
				return
			end

			if typeof(tool) == "table" and tool.IsVirtualAsset then
				local v69 = _getAssetUID(tool)

				if typeof(v69) ~= "string" then
					return
				end

				SelectedSlot = self
				local assetToolByUID = findAssetToolByUID(v69)

				if assetToolByUID and humanoid then
					if assetToolByUID.Parent == character then
						humanoid:UnequipTools()
					else
						humanoid:UnequipTools()
						humanoid:EquipTool(assetToolByUID)
					end
				elseif v34 == v69 then
					requestUnequipVirtualAsset()
				end

				updateEquipSelectionVisuals()
			elseif typeof(tool) == "table" and tool.IsVirtualEgg then
				local v69 = reconcileVirtualEggEquipState()
				local attribute = getAttribute(tool, "UID")

				if typeof(attribute) ~= "string" then
					return
				end

				if v69 == attribute then
					requestUnequipVirtualEgg()
				else
					requestEquipVirtualEgg(attribute, self)
				end
			else
				SelectedSlot = self

				if tool.Parent == character then
					SelectedSlot = nil

					if humanoid then
						UnequipAllTools()
					end
				elseif tool.Parent == backpack2 then
					if humanoid == nil or humanoid.Health <= 0 then
						SelectedSlot = nil
					else
						UnequipAllTools()
						tool.Parent = character
					end
				end
			end
		end
	end

	v58.MainImage = clone2.ImageLabel
	local baseTemplate = clone2.BaseTemplate
	baseTemplate.Amount.Visible = false
	baseTemplate.Amount.Text = ""
	mutations = baseTemplate:FindFirstChild("Mutations")
	template2 = mutations and mutations:FindFirstChild("Template")
	clearMutationIconFrame(mutations, template2)
	local uIStroke = clone2.UIStroke
	uIStroke.Thickness = 0
	clone2.BackgroundColor3 = visible2 and Color3.new(0, 0, 0) or BackgroundColorAttribute
	uIStroke.Color = BorderColorAttribute
	clone2.Text = ""
	clone2.AutoButtonColor = false
	clone2.BorderSizePixel = 0
	local v69 = parent == scrollingFrame and v14 or v5
	clone2.Size = UDim2.new(0, v69, 0, v69)
	clone2.Active = true
	clone2.Draggable = false
	clone2:SetAttribute("Draggable", false)
	clone2:SetAttribute("IsInventorySlot", visible2)
	clone2.BackgroundTransparency = visible2 and 0.5 or SlotLockedTransparencyAttribute
	ButtonFX(clone2, 1.015, nil, true)

	local function activateSlot(userInputType)
		if os.clock() < 0 or v60 and v60:IsActivationSuppressed() then
			return
		end

		local tool = v58.Tool

		if previousFavoriteModeActive and tool and isAssetTool(tool) then
			v63 = 0
			v64 = nil
			requestFavoriteToggle(tool)
		else
			local v70 = userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.MouseMovement or userInputType == Enum.UserInputType.Touch

			if v70 then
				if emptySlotsAttribute < v58.Index and tool ~= nil then
					v70 = not (v58.IsDeleted or previousFavoriteModeActive) and not (v6 or ActiveFuseSelectionState) and (BackpackEnabled and BackpackGui.Enabled and not HiddenUIHandler.IsHidden() and true or false)

					if v70 then
						if clone2:GetAttribute("Draggable") == true then
							v70 = shouldAllowSlotDragging(tool) and (MenuNavigation.IsCursorActive() or clone2 ~= GuiService.SelectedObject)
						else
							v70 = false
						end
					end
				else
					v70 = false
				end
			end

			local now2 = os.clock()

			if v70 then
				if v64 == tool then
					v70 = now2 - v63 < 0.5
				else
					v70 = false
				end
			end

			local v71

			if v70 and not v70 then
				v71 = tool
			end

			v64 = v71
			v63 = (not v70 or v70) and 0 or now2

			if v70 then
				local v72 = FindLowestEmpty(tool)

				if v72 and canPlaceToolInSlot(v72, tool) then
					v58:Swap(v72)

					if not v58.Tool then
						v58:Delete()
					end

					if performSearch then
						task.defer(function()
							performSearch(true)
						end)
					end

					return
				end
			end

			changeSlot(v58)
		end
	end

	clone2.Activated:Connect(function(p2)
		if not v60 or v60:ShouldHandleNativeActivation() then
			activateSlot(p2 and p2.UserInputType)
		end
	end)

	if UserInputService.TouchEnabled then
		clone2.TouchLongPress:Connect(function(_, p2, _)
			if p2 == Enum.UserInputState.End and not (v60 and v60:IsActivationSuppressed()) then
				local tool = v58.Tool

				if tool and isAssetTool(tool) then
					requestFavoriteToggle(tool)
				end
			end
		end)
	end

	v33:Register(clone2, {
		GetTool = function()
			return v58.Tool
		end,
		CanFavorite = function(p2)
			local v70 = inventory.Visible and not v58.IsDeleted

			if not v70 then
				return v70
			end

			if p2 == nil then
				return false
			else
				v70 = isAssetTool(p2) and not (ActiveFuseSelectionState or v6)

				if v70 then
					return not (v60 and v60:IsActivationSuppressed())
				end
			end

			return v70
		end,
		OnFavorite = function(p2)
			v63 = 0
			v64 = nil

			if v60 then
				v60:Cancel()
			end

			requestFavoriteToggle(p2)
		end
	})
	v58.Frame = clone2
	selector = clone2.SelectionObjectClipper.Selector
	shadow = clone2.Shadow
	shadow.Visible = false
	v58.IconImage = icon
	favIcon = clone2.FavIcon
	favIcon.Visible = false
	toolName = clone2.ToolName
	textXAlignment = toolName.TextXAlignment
	textYAlignment = toolName.TextYAlignment
	weight = clone2.Weight
	weight.Visible = false
	v58.Frame.LayoutOrder = v58.Index

	if name2 <= emptySlotsAttribute then
		clone2.StrokeFrame.Visible = false
		toolTip = clone2.ToolTip
		toolTip.Visible = false
		v58.TooltipLabel = toolTip
		clone2.MouseEnter:Connect(function()
			if toolTip.Text ~= "" then
				toolTip.Visible = false
			end
		end)
		clone2.MouseLeave:Connect(function()
			toolTip.Visible = false
		end)

		function v58:MoveToInventory()
			if self.IsFakeSlot or isToolLockedToCurrentHotbarSlot(self) or self.Tool ~= nil and not HasInventoryCategory(self.Tool) then
				return
			end

			if self.Index <= emptySlotsAttribute then
				local tool = self.Tool
				self:Clear()
				local v70 = MakeSlot(scrollingFrame)
				v70:Fill(tool)

				if tool and tool.Parent == character and humanoid then
					UnequipAllTools()
				end

				if tool and typeof(tool) == "Instance" and getAttribute(tool, "ItemType") == "Asset" then
					task.defer(syncAssetsFromSave)
				end

				if flag then
					v70.Frame.Visible = false
					v70.Frame.Parent = inventory
				end
			end
		end

		if name2 <= 10 then
			local text = name2 == 10 and 0 or name2
			number = clone2.Number
			number.Text = text
			v62 = tostring(text)
			number.Visible = false

			v22[value + text] = function()
				changeSlot(v58)
			end
		end
	end

	local ancestryChangedConnection = nil

	local function finishDrag(p2, p3)
		local DELAY_DURATION = 0.01
		v23[clone2] = nil
		HotbarDragFeedback.Finish()

		if ancestryChangedConnection then
			ancestryChangedConnection:Disconnect()
			ancestryChangedConnection = nil
		end

		uIStroke.Thickness = 0
		topBarPlus:unlock()

		if p3 or v58.IsDeleted or not v58.Tool then
			return
		end

		if shouldAllowSlotDragging(v58.Tool) then
			local v70 = CheckBounds(parent2, p2.X, p2.Y)

			if isToolLockedToCurrentHotbarSlot(v58) and not (v70 or CheckBounds(clone2, p2.X, p2.Y)) then
				HotbarDragFeedback.Reject(clone2)
			end

			if CheckBounds(inventory, p2.X, p2.Y) then
				if v58.Index <= emptySlotsAttribute then
					if previousCategory ~= v2 then
						local v71 = GetCategory(v58.Tool)
						SetCategory(v71)
					end

					v58:MoveToInventory()
					textBox.Text = ""
					task.delay(DELAY_DURATION, function()
						if performSearch then
							performSearch(true)
						end
					end)
				end
			elseif v70 then
				local v71 = { 1e999, nil }

				for i = 1, emptySlotsAttribute do
					local v72 = v19[i]
					local frame2 = v72.Frame
					local v73 = GetOffset(frame2, p2)

					if v73 < v71[1] then
						v71 = { v73, v72 }
					end
				end

				local v72 = v71[2]

				if v72 ~= v58 then
					if not v58:CanSwap(v72) then
						HotbarDragFeedback.Reject(v72.Frame)
					end

					v58:Swap(v72)

					if emptySlotsAttribute < v58.Index then
						local tool = v58.Tool

						if tool then
							if tool.Parent == character and humanoid then
								UnequipAllTools()
							end

							if flag then
								v58.Frame.Visible = false
								v58.Frame.Parent = inventory
							end
						else
							v58:Delete()
						end
					end
				end
			elseif v58.Index <= emptySlotsAttribute then
				v58:MoveToInventory()
				task.delay(DELAY_DURATION, function()
					if performSearch then
						performSearch(true)
					end
				end)
			elseif typeof(v58.Tool) == "Instance" and v58.Tool:IsA("Tool") and v58.Tool.CanBeDropped then
				v58.Tool.Parent = workspace
			end

			task.delay(DELAY_DURATION, function()
				if performSearch then
					performSearch(true)
				end
			end)
		else
			applySlotDraggableState(false) -- equivalent call inferred; original call site unknown
			v58:updateDragAppearance()
		end
	end

	local new = SlotDragController.new
	local scrollingFrame2

	if visible2 then
		scrollingFrame2 = scrollingFrame
	end

	v60 = new(clone2, {
		ScrollingFrame = scrollingFrame2,
		CanStart = function()
			local v73 = not v58.IsDeleted

			if v73 then
				if clone2:GetAttribute("Draggable") == true then
					return (BackpackEnabled and BackpackGui.Enabled and not HiddenUIHandler.IsHidden() and true or false) and shouldAllowSlotDragging(v58.Tool)
				else
					return false
				end
			end

			return v73
		end,
		OnActivate = activateSlot,
		OnDragStart = function()
			v63 = 0
			v64 = nil
			local frames = {}

			for i = 1, emptySlotsAttribute do
				local v73 = v19[i]

				if not v73 or v73 == v58 or v58:CanSwap(v73) then
					continue
				end

				table.insert(frames, v73.Frame)
			end

			HotbarDragFeedback.Start(frames)
			v23[clone2] = true
			uIStroke.Thickness = 2
			topBarPlus:lock()
			local tool = v58.Tool

			if typeof(tool) == "Instance" then
				ancestryChangedConnection = tool.AncestryChanged:Connect(function()
					if v58.Tool ~= tool or tool.Parent ~= localPlayer.Backpack and tool.Parent ~= localPlayer.Character then
						v60:Cancel()
					end
				end)
			end
		end,
		OnDragEnd = finishDrag
	})
	clone2.Parent = parent
	v19[name2] = v58

	if emptySlotsAttribute < name2 then
		local canvasPosition = scrollingFrame.CanvasPosition
		UpdateScrollingFrameCanvasSize()
		local v73 = scrollingFrame.AbsoluteCanvasSize.Y - scrollingFrame.AbsoluteSize.Y

		if inventory.Visible and not flag then
			scrollingFrame.CanvasPosition = Vector2.new(
				canvasPosition.X,
				(math.min(canvasPosition.Y, (math.max(0, v73))))
			)
		else
			scrollingFrame.CanvasPosition = canvasPosition
		end
	end

	return v58
end

function moveStackSlotIntoFrontHotbar(object)
	if not object or object.IsDeleted then
		return nil
	end

	if object.Index <= emptySlotsAttribute then
		return object
	end

	local insertableHotbarIndices = getInsertableHotbarIndices(object.Tool)
	local insertableHotbarIndice = insertableHotbarIndices[1]

	if not insertableHotbarIndice then
		return nil
	end

	local v57 = v19[insertableHotbarIndice]

	if not v57 then
		return nil
	end

	local v58 = v20
	local index = v58 and table.find(insertableHotbarIndices, v58.Index)

	if not index then
		local insertableHotbarIndice2 = insertableHotbarIndices[#insertableHotbarIndices]
		local v59 = insertableHotbarIndice2 and v19[insertableHotbarIndice2]

		if v59 and v59.Tool then
			v59:MoveToInventory()
			index = #insertableHotbarIndices
		end
	end

	if not index then
		return nil
	end

	for i = index, 2, -1 do
		local v59 = v19[insertableHotbarIndices[i]]
		local v60 = v19[insertableHotbarIndices[i - 1]]

		if v59 and v60 then
			v60:Swap(v59)
		end
	end

	object:Swap(v57)

	if emptySlotsAttribute < object.Index and not object.Tool then
		object:Delete()
	end

	return v57
end

function movePendingHotbarAssets()
	local v57 = false

	for k in pairs(v39) do
		local v58 = v35[k]

		if not v58 then
			continue
		end

		local v59 = moveStackSlotIntoFrontHotbar(v58)

		if not v59 then
			continue
		end

		v35[k] = v59
		v39[k] = nil
		v57 = true
	end

	if not v57 then
		return v57
	end

	AdjustHotbarFrames()
	UpdateInventorySlots()

	if performSearch then
		performSearch(true)
	end

	return v57
end

function movePendingHotbarEggs()
	local flag7 = false

	for k in pairs(v43) do
		local v57 = v41[k]

		if not v57 then
			continue
		end

		local v58 = moveStackSlotIntoFrontHotbar(v57)

		if not v58 then
			continue
		end

		v41[k] = v58
		v43[k] = nil
		flag7 = true
	end

	if flag7 then
		AdjustHotbarFrames()
		UpdateInventorySlots()

		if performSearch then
			performSearch(true)
		end
	end

	for k in pairs(v44) do
		if Main:ForceEggIntoTutorialHotbar(k) ~= nil then
			v44[k] = nil
		end
	end

	return flag7
end

function OnChildAdded(instance, _: boolean?)
	if instance:IsA("Tool") then
		if instance.Parent == character then
			now = tick()
		end

		local itemType = instance:GetAttribute("ItemType")

		if itemType == "Asset" then
			invalidateEquipBestStatus()
			syncVirtualAssetEquipStateFromTool(instance)
			task.defer(syncAssetsFromSave)
		else
			if itemType == "AssetEgg" then
				syncVirtualEggEquipStateFromTool(instance)
				return
			end

			local v57 = scrollingFrame
			local canvasPosition = scrollingFrame.CanvasPosition

			if not v25 and instance.Parent == character and not v21[instance] then
				local starterGear = localPlayer:FindFirstChild("StarterGear")

				if starterGear and starterGear:FindFirstChild(instance.Name) then
					v25 = true
					local v58 = insertToolIntoFrontHotbar(instance) or claimLowestEmptySlot(instance) or MakeSlot(scrollingFrame)

					if v58.Tool ~= instance then
						v58:Fill(instance)
					end

					if isGearTool(instance) then
						ensureGameplayGearHotbarSlots()
					end

					for _, tool in pairs(character:GetChildren()) do
						if tool:IsA("Tool") and tool ~= instance then
							tool.Parent = backpack2
						end
					end

					AdjustHotbarFrames()

					if performSearch then
						performSearch(true)
					end

					UpdateInventorySlots()
					local v59 = v57.AbsoluteCanvasSize.Y - v57.AbsoluteSize.Y
					v57.CanvasPosition = Vector2.new(canvasPosition.X, (math.min(canvasPosition.Y, (math.max(0, v59)))))
					return
				end
			end

			local v58 = v21[instance]

			if v58 then
				v58:UpdateEquipView()
				return
			end

			local v59 = insertToolIntoFrontHotbar(instance) or claimLowestEmptySlot(instance) or MakeSlot(scrollingFrame)

			if v59.Tool ~= instance then
				v59:Fill(instance)
			end

			if isGearTool(instance) then
				ensureGameplayGearHotbarSlots()
			end

			if v59.Index <= emptySlotsAttribute and not inventory.Visible then
				AdjustHotbarFrames()
			end

			UpdateInventorySlots()
			local v60 = v57.AbsoluteCanvasSize.Y - v57.AbsoluteSize.Y
			v57.CanvasPosition = Vector2.new(canvasPosition.X, (math.min(canvasPosition.Y, (math.max(0, v60)))))
			task.delay(0.05, function()
				if performSearch then
					performSearch(true)
				end
			end)
		end
	elseif instance:IsA("Humanoid") and instance.Parent == character then
		humanoid = instance
	end
end

function OnChildRemoved(tool)
	if not tool:IsA("Tool") then
		return
	end

	now = tick()
	local itemType = tool:GetAttribute("ItemType")

	if itemType == "Asset" then
		invalidateEquipBestStatus()
		task.defer(reconcileVirtualAssetEquipState)
		task.defer(syncAssetsFromSave)
		local v57 = v21[tool]

		if v57 and v57.Tool == tool then
			v57:Clear()

			if emptySlotsAttribute < v57.Index then
				v57:Delete()
			end

			if v57.Index <= emptySlotsAttribute and not inventory.Visible then
				AdjustHotbarFrames()
			end

			UpdateInventorySlots()
		end
	else
		if itemType == "AssetEgg" then
			task.defer(reconcileVirtualEggEquipState)
			return
		end

		local v57 = v21[tool]
		local parent = tool.Parent

		if parent ~= character and parent ~= backpack2 then
			if not v57 or v57.Tool ~= tool then
				for _, v59 in pairs(v19) do
					if v59.Tool ~= tool then
						continue
					end

					v57 = v59
					break
				end
			end

			if v57 and v57.Tool == tool then
				v57:Clear()

				if emptySlotsAttribute < v57.Index then
					v57:Delete()
				end

				if v57.Index <= emptySlotsAttribute and not inventory.Visible then
					AdjustHotbarFrames()
				end

				UpdateInventorySlots()
			end
		end
	end
end

function SetupCharacter(instance)
	v34 = nil
	v46 = nil

	for i = #v19, 1, -1 do
		local v57 = v19[i]

		if not v57.Tool then
			continue
		end

		if typeof(v57.Tool) == "Instance" then
			v57:Clear()
		else
			v57:UpdateEquipView(true)
		end
	end

	for _, connection in pairs(connections) do
		connection:Disconnect()
	end

	connections = {}
	character = instance
	table.insert(connections, instance.ChildRemoved:Connect(OnChildRemoved))
	table.insert(connections, instance.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") and (tool.Name == Constants.LUCKY_BLOCK_TOOL_NAME or tool:GetAttribute("HideFromBackpackUI") == true) then
			return
		end

		OnChildAdded(tool, false)
	end))

	for _, child in pairs(instance:GetChildren()) do
		task.spawn(OnChildAdded, child, false)
	end

	backpack2 = localPlayer:WaitForChild("Backpack")
	table.insert(connections, backpack2.ChildRemoved:Connect(OnChildRemoved))
	table.insert(connections, backpack2.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") and (tool.Name == Constants.LUCKY_BLOCK_TOOL_NAME or tool:GetAttribute("HideFromBackpackUI") == true) then
			return
		end

		OnChildAdded(tool, true)
	end))

	for _, child in pairs(backpack2:GetChildren()) do
		task.spawn(OnChildAdded, child, false)
	end

	table.insert(connections, localPlayer.ChildAdded:Connect(function(backpack3)
		if backpack3:IsA("Backpack") and backpack3 ~= backpack2 and character == instance then
			SetupCharacter(instance)
		end
	end))
	AdjustHotbarFrames()
	invalidateEquipBestStatus(true)
	reconcileVirtualAssetEquipState()
end

local Players3 = game:GetService("Players")
local playerGui = Players3.LocalPlayer:WaitForChild("PlayerGui")

function HandleInputBegan(p, p2)
	if p2 == false then
		local v57 = p.UserInputType == Enum.UserInputType.Keyboard and not v29 and (v26 or p.KeyCode.Value == value2) and v22[p.KeyCode.Value]

		if v57 then
			if ActiveFuseSelectionState then
				return
			else
				v57(false)
			end
		end

		local userInputType = p.UserInputType

		if (userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch) and inventory.Visible and not ActiveFuseSelectionState then
			local mouseLocation = UserInputService:GetMouseLocation()
			local v58 = nil

			for _, v60 in playerGui:GetGuiObjectsAtPosition(mouseLocation.X, mouseLocation.Y) do
				if not v60.Name:find("CategoryFrame") then
					continue
				end

				v58 = v60
				break
			end

			if not v58 then
				topBarPlus:deselect()
			end
		end
	end
end

function OnInputServiceChanged(p)
	if p == "KeyboardEnabled" or p == "VREnabled" then
		local v57 = UserInputService.KeyboardEnabled and not UserInputService.VREnabled

		for i = 1, emptySlotsAttribute do
			v19[i]:TurnNumber(v57)
		end
	end
end

function OnGamepadFocus()
	if MenuNavigation.IsCursorActive() then
		return Enum.ContextActionResult.Pass
	end

	return Enum.ContextActionResult.Sink
end

function unbindAllGamepadEquipActions()
	ContextActionService:UnbindAction("RBXBackpackHasGamepadFocus")
	ContextActionService:UnbindAction("RBXCloseInventory")
end

function _setHotbarVisibility(visible, p)
	for i = 1, emptySlotsAttribute do
		local v57 = v19[i]

		if v57 and v57.Frame and (p or v57.Tool) then
			v57.Frame.Visible = visible
		end
	end
end

function getEquippedHotbarSlot()
	local v57 = reconcileVirtualAssetEquipState()

	if typeof(v57) == "string" then
		local v58 = v35[v57]

		if v58 and not v58.IsDeleted and v58.Index <= emptySlotsAttribute and v58.Tool then
			return v58
		end
	end

	local v58 = reconcileVirtualEggEquipState()

	if typeof(v58) == "string" then
		local v59 = v41[v58]

		if v59 and not v59.IsDeleted and v59.Index <= emptySlotsAttribute and v59.Tool then
			return v59
		end
	end

	if not character then
		return nil
	end

	for _, tool in ipairs(character:GetChildren()) do
		if not tool:IsA("Tool") then
			continue
		end

		local v59 = v21[tool]

		if v59 and v59.Index <= emptySlotsAttribute and v59.Tool then
			return v59
		end
	end

	return nil
end

function changeTool(_, p, p2)
	if p ~= Enum.UserInputState.Begin then
		return
	end

	local v57 = p2.KeyCode == Enum.KeyCode.ButtonL1 and -1 or 1
	local equippedHotbarSlot = getEquippedHotbarSlot()
	local index

	if equippedHotbarSlot then
		index = equippedHotbarSlot.Index
	else
		index = v57 == -1 and 1 or emptySlotsAttribute
	end

	for _ = 1, emptySlotsAttribute do
		index += v57

		if emptySlotsAttribute < index then
			index = 1
		elseif index < 1 then
			index = emptySlotsAttribute
		end

		local v58 = v19[index]

		if not (v58.Tool and v58 ~= equippedHotbarSlot) then
			continue
		end

		v58:Select()
		break
	end
end

function getGamepadSwapSlot()
	for i = 1, #v19 do
		if v19[i].Frame:WaitForChild("UIStroke").Thickness > 0 then
			return v19[i]
		end
	end
end

function changeSlot(object)
	if object.IsFakeSlot then
		object:Select()
		return
	end

	local v57 = not VRService.VREnabled or inventory.Visible

	if MenuNavigation.IsCursorActive() or object.Frame ~= GuiService.SelectedObject or not v57 then
		object:Select()
		v16.SelectionImageObject.Visible = false
	else
		local gamepadSwapSlot = getGamepadSwapSlot()

		if gamepadSwapSlot then
			local uIStroke = gamepadSwapSlot.Frame:WaitForChild("UIStroke")
			uIStroke.Thickness = 0

			if gamepadSwapSlot ~= object then
				object:Swap(gamepadSwapSlot)
				v16.SelectionImageObject.Visible = false

				if emptySlotsAttribute < object.Index and not object.Tool then
					if GuiService.SelectedObject == object.Frame then
						GuiService.SelectedObject = gamepadSwapSlot.Frame
					end

					object:Delete()
				end

				if emptySlotsAttribute < gamepadSwapSlot.Index and not gamepadSwapSlot.Tool then
					if GuiService.SelectedObject == gamepadSwapSlot.Frame then
						GuiService.SelectedObject = object.Frame
					end

					gamepadSwapSlot:Delete()
				end
			end
		else
			local size = object.Frame.Size
			local position = object.Frame.Position
			object.Frame:TweenSizeAndPosition(
				size + UDim2.new(0, 10, 0, 10),
				position - UDim2.new(0, 5, 0, 5),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true,
				function()
					object.Frame:TweenSizeAndPosition(
						size,
						position,
						Enum.EasingDirection.In,
						Enum.EasingStyle.Quad,
						0.1,
						true
					)
				end
			)
			local uIStroke_2 = object.Frame:WaitForChild("UIStroke")
			uIStroke_2.Thickness = 3
			v16.SelectionImageObject.Visible = true
		end
	end
end

function vrMoveSlotToInventory()
	if not VRService.VREnabled then
		return
	end

	local gamepadSwapSlot = getGamepadSwapSlot()

	if gamepadSwapSlot and gamepadSwapSlot.Tool then
		local uIStroke = gamepadSwapSlot:WaitForChild("UIStroke")
		uIStroke.Thickness = 0
		gamepadSwapSlot:MoveToInventory()
		v16.SelectionImageObject.Visible = false
	end
end

function enableGamepadInventoryControl()
	local function handleBackAction(_, p)
		if p ~= Enum.UserInputState.Begin then
			return
		end

		local gamepadSwapSlot = getGamepadSwapSlot()

		if gamepadSwapSlot then
			local uIStroke = gamepadSwapSlot.Frame:WaitForChild("UIStroke")
			uIStroke.Thickness = 0
		elseif inventory.Visible then
			topBarPlus:deselect()
		end
	end

	ContextActionService:BindAction("RBXBackpackHasGamepadFocus", OnGamepadFocus, false, Enum.UserInputType.Gamepad1)
	ContextActionService:BindAction(
		"RBXCloseInventory",
		handleBackAction,
		false,
		Enum.KeyCode.ButtonB,
		Enum.KeyCode.ButtonStart,
		Enum.KeyCode.ButtonSelect
	)

	if not (UserInputService.VREnabled or MenuNavigation.IsCursorActive()) then
		GuiService.SelectedObject = parent2:FindFirstChild("1")
	end
end

function disableGamepadInventoryControl()
	unbindAllGamepadEquipActions()

	for i = 1, emptySlotsAttribute do
		local v57 = v19[i]

		if not (v57 and v57.Frame) then
			continue
		end

		local uIStroke = v57.Frame:WaitForChild("UIStroke")
		uIStroke.Thickness = 0
	end

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(backpack) then
		GuiService.SelectedObject = nil
	end
end

function _bindBackpackHotbarAction()
	if v26 and not v12 then
		v12 = true
		ContextActionService:BindAction(
			"RBXHotbarEquip",
			changeTool,
			false,
			Enum.KeyCode.ButtonL1,
			Enum.KeyCode.ButtonR1
		)
	end
end

function _unbindBackpackHotbarAction()
	disableGamepadInventoryControl()
	v12 = false
	ContextActionService:UnbindAction("RBXHotbarEquip")
end

function gamepadDisconnected()
	flag2 = false
	disableGamepadInventoryControl()
end

function gamepadConnected()
	flag2 = true
	GuiService:AddSelectionParent("RBXBackpackSelection", backpack)

	if v24 >= 1 and v26 and not v12 then
		v12 = true
		ContextActionService:BindAction(
			"RBXHotbarEquip",
			changeTool,
			false,
			Enum.KeyCode.ButtonL1,
			Enum.KeyCode.ButtonR1
		)
	end

	if inventory.Visible then
		enableGamepadInventoryControl()
	end
end

function OnIconChanged(p)
	local visible = p and tryCore("GetCore", "TopbarEnabled")
	topBarPlus:setEnabled(visible and not (GuiService.MenuIsOpen or ActiveFuseSelectionState))
	v26 = visible
	backpack.Visible = visible
	PositionInventoryAffordances()

	if visible then
		if v24 >= 1 and v26 and not v12 then
			v12 = true
			ContextActionService:BindAction(
				"RBXHotbarEquip",
				changeTool,
				false,
				Enum.KeyCode.ButtonL1,
				Enum.KeyCode.ButtonR1
			)
		end
	else
		disableGamepadInventoryControl()
		v12 = false
		ContextActionService:UnbindAction("RBXHotbarEquip")
	end
end

function createScrollButton(p, image)
	local parent = NewGui("ImageButton", p)
	parent.Size = UDim2.new(0, 40, 0, 40)
	parent.Image = "rbxasset://textures/ui/Keyboard/close_button_background.png"
	local v58 = NewGui("ImageLabel", "Icon")
	v58.Size = UDim2.new(0.5, 0, 0.5, 0)
	v58.Position = UDim2.new(0.25, 0, 0.25, 0)
	v58.Image = image
	v58.Parent = parent
	local selectionImageObject = NewGui("ImageLabel", "Selection")
	selectionImageObject.Size = UDim2.new(0.9, 0, 0.9, 0)
	selectionImageObject.Position = UDim2.new(0.05, 0, 0.05, 0)
	selectionImageObject.Image = "rbxasset://textures/ui/Keyboard/close_button_selection.png"
	parent.SelectionImageObject = selectionImageObject
	return parent, v58, selectionImageObject
end

backpack = BackpackGui:WaitForChild("Backpack")
backpack.Visible = false
parent2 = NewGui("Frame", "Hotbar")
parent2.Parent = backpack
GUI = script:FindFirstChild("RoundChoices")

if GUI then
	GUI.Parent = parent2

	if ReplicatedStorage then
		GUI.Size = UDim2.fromScale(1, 0.4)
	end
elseif RunService:IsStudio() then
	error("RoundChoices frame not found in Backpack script")
end

for i = 1, emptySlotsAttribute do
	local makeSlot = MakeSlot(parent2, i)
	makeSlot.Frame.Visible = false
end

main = backpack:WaitForChild("Main")
inventory = main:WaitForChild("Inventory")
local loading = inventory:WaitForChild("Loading")
loading.Visible = false
task.spawn(warmAssets, inventory.ImageLabel.ImageLabel)
autoSell = inventory.AutoSell
autoSell.Visible = false
task.spawn(initializeAutoSellUI)
v20 = FindLowestEmpty()
AdjustHotbarFrames()
topBarPlus.selected:Connect(function()
	if not GuiService.MenuIsOpen then
		Main.OpenClose()
	end
end)
topBarPlus.deselected:Connect(function()
	if inventory.Visible then
		Main.OpenClose()
	end
end)
GUI = NewGui("ImageLabel", "LeftBumper")
GUI.Size = UDim2.new(0, 40, 0, 40)
GUI.Position = UDim2.new(0, -GUI.Size.X.Offset, 0.5, -GUI.Size.Y.Offset / 2)
GUI = NewGui("ImageLabel", "RightBumper")
GUI.Size = UDim2.new(0, 40, 0, 40)
GUI.Position = UDim2.new(1, 0, 0.5, -GUI.Size.Y.Offset / 2)
local backgroundColor3 = inventory.BackgroundColor3
InventoryStroke = inventory:FindFirstChildWhichIsA("UIStroke")
InventoryStrokeDefaultColor = InventoryStroke and InventoryStroke.Color or nil
InventoryStrokeDefaultTransparency = inventory.BackgroundTransparency
inventory.Visible = false

function refreshInventoryFrameVisuals()
	if ActiveFuseSelectionState then
		inventory.BackgroundColor3 = FUSE_SELECTION_BACKGROUND_COLOR

		if InventoryStroke then
			InventoryStroke.Color = FUSE_SELECTION_STROKE_COLOR
		end

		inventory.BackgroundTransparency = FUSE_SELECTION_BACKGROUND_TRANSPARENCY
	else
		inventory.BackgroundColor3 = previousFavoriteModeActive and color or backgroundColor3

		if InventoryStroke and InventoryStrokeDefaultColor then
			InventoryStroke.Color = InventoryStrokeDefaultColor
		end

		inventory.BackgroundTransparency = InventoryStrokeDefaultTransparency
	end
end

local uIStroke = Instance.new("UIStroke")
uIStroke.Name = "FavoriteMode"
uIStroke.Thickness = 4.5
uIStroke.Color = Color3.fromRGB(255, 170, 0)
uIStroke.Enabled = false
uIStroke.ZIndex = 2
uIStroke.Parent = inventory

function updateFavoriteModeVisuals()
	local textLabel = favoriteMode and favoriteMode:FindFirstChildWhichIsA("TextLabel")

	if textLabel then
		textLabel.Text = previousFavoriteModeActive and "Favorite: ON" or "Favorite: OFF"
	end

	if uIStroke then
		uIStroke.Enabled = previousFavoriteModeActive and not ActiveFuseSelectionState
	end

	refreshInventoryFrameVisuals()
end

function setFavoriteModeActive(p)
	previousFavoriteModeActive = p

	if favoriteMode then
		updateFavoriteModeVisuals()
		return
	end

	refreshInventoryFrameVisuals()

	if uIStroke then
		uIStroke.Enabled = previousFavoriteModeActive and not ActiveFuseSelectionState
	end
end

function hideFavoriteModeButton()
	if previousFavoriteModeActive then
		setFavoriteModeActive(false)
	end

	if favoriteMode then
		favoriteMode.Visible = false

		if autoSell then
			autoSell.Visible = false
		end

		if equipBest then
			equipBest.Visible = false
		end
	end
end

function refreshFavoriteModeVisibility()
	if not favoriteMode then
		return
	end

	local v57 = v4[previousCategory]
	local v58 = previousCategory == v2

	if v57 and v57.Tags then
		for _, tag in v57.Tags do
			if tag ~= "Asset" then
				continue
			end

			v58 = true
			break
		end
	end

	if v58 then
		favoriteMode.Visible = false

		if autoSell then
			autoSell.Visible = false
		end

		if equipBest then
			equipBest.Visible = false
		end
	else
		hideFavoriteModeButton()
	end

	updateEquipBestButtonVisibility()
end

favoriteMode = inventory:FindFirstChild("FavoriteMode") or script:FindFirstChild("FavoriteMode")

if favoriteMode then
	favoriteMode.Parent = inventory
	favoriteMode.Visible = false
	updateFavoriteModeVisuals()
	ButtonFX(favoriteMode, nil, function()
		setFavoriteModeActive(not previousFavoriteModeActive)
	end)
end

equipBest = inventory:FindFirstChild("EquipBest")

if equipBest then
	equipBest.Visible = false
	ButtonFX(equipBest, nil, requestEquipBest)
end

GUI = script:FindFirstChild("EquipBest")

if GUI and GUI:IsA("GuiButton") then
	clone = GUI:Clone()
	assert(clone, "missing hotbar")
	clone.Parent = parent2
	clone.Visible = false
	ButtonFX(clone, nil, requestEquipBest)
end

local categoryLabel = inventory:FindFirstChild("CategoryLabel") or script.CategoryTemplate:Clone()
categoryLabel.Parent = inventory

if not categoryLabel:IsA("TextLabel") then
	categoryLabel = categoryLabel:FindFirstChildWhichIsA("TextLabel", true)
end

assert(categoryLabel and categoryLabel:IsA("TextLabel"), "Category label template must contain a TextLabel")
local categoryNamesByName = {}
local clonesByName = {}

local function fn2()
	local activeFuseSelectionState = ActiveFuseSelectionState
	local v57 = activeFuseSelectionState ~= nil

	for k, v58 in clonesByName do
		local v59 = not v57 or activeFuseSelectionState.AllowedCategories[k] == true
		v58.Visible = v59
		local imageButton = v58:FindFirstChild("ImageButton")

		if imageButton and imageButton:IsA("GuiButton") then
			imageButton.Active = v59
		end
	end
end

function updateCategorySelectionVisuals()
	for k, v57 in categoryNamesByName do
		v57.Enabled = k == previousCategory
	end
end

function updateCategoryLabel(text: string)
	categoryLabel.Text = text
	inventory:SetAttribute("CapacityCategory", text)
end

function applyCategoryLayout()
	if not (uIGridLayout and scrollingFrame) then
		return
	end

	if not cellSize then
		cellSize = uIGridLayout.CellSize
	end

	if not uIAspectRatioConstraint then
		uIAspectRatioConstraint = uIGridLayout:FindFirstChildWhichIsA("UIAspectRatioConstraint") or scrollingFrame:FindFirstChildWhichIsA("UIAspectRatioConstraint")

		if uIAspectRatioConstraint then
			aspectRatio = uIAspectRatioConstraint.AspectRatio
		end
	end

	if not scrollingDirection then
		scrollingDirection = scrollingFrame.ScrollingDirection
	end

	if not fillDirection then
		fillDirection = uIGridLayout.FillDirection
	end

	if not horizontalAlignment then
		horizontalAlignment = uIGridLayout.HorizontalAlignment
	end

	if uIPadding and not paddingLeft then
		paddingLeft = uIPadding.PaddingLeft
	end

	uIGridLayout.CellSize = cellSize

	if uIAspectRatioConstraint and aspectRatio then
		uIAspectRatioConstraint.AspectRatio = aspectRatio
	end

	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.ScrollingDirection = scrollingDirection
	uIGridLayout.FillDirection = fillDirection
	uIGridLayout.HorizontalAlignment = horizontalAlignment

	if uIPadding and paddingLeft then
		uIPadding.PaddingLeft = paddingLeft
	end
end

SetCategory = function(preferredCategory)
	if ActiveFuseSelectionState and ActiveFuseSelectionState.AllowedCategories[preferredCategory] ~= true then
		preferredCategory = ActiveFuseSelectionState.PreferredCategory
	end

	if previousCategory == preferredCategory then
		updateCategoryLabel(preferredCategory)
	else
		previousCategory = preferredCategory
		applyCategoryLayout()

		if textBox and textBox.Text ~= "" then
			if resetSearchResults then
				resetSearchResults()
			end

			textBox.Text = ""
		end

		if previousCategory ~= v2 and previousFavoriteModeActive then
			setFavoriteModeActive(false)
		end

		if loading and previousCategory ~= v2 then
			loading.Visible = false
		end

		refreshFavoriteModeVisibility()
		updateCategoryLabel(preferredCategory)

		if scrollingFrame then
			scrollingFrame.CanvasPosition = Vector2.new(0, 0)
		end

		performSearch()
	end

	updateCategorySelectionVisuals()
end

local categoryFrame = inventory:WaitForChild("CategoryFrame")
local categoryTemplate = categoryFrame.CategoryTemplate

if not categoryFrame:FindFirstChildWhichIsA("UIGridLayout") then
	categoryFrame:FindFirstChildWhichIsA("UIListLayout")
end

function createHintForCategory(p, p2)
	local HSV, v57, v58 = p:ToHSV()
	local v59 = math.clamp(v58 + p2, 0, 1)
	return Color3.fromHSV(HSV, v57, v59)
end

for _, v57 in v do
	local name = v57.Name
	local clone2 = categoryTemplate:Clone()
	local imageButton = clone2.ImageButton
	local categoryName = clone2:FindFirstChild("CategoryName")

	if categoryName and categoryName:IsA("TextLabel") then
		categoryName.Text = name
	end

	categoryName = clone2.BackgroundColor3
	local tween = TweenService:Create(clone2, TweenInfo.new(0.2), {
		BackgroundColor3 = createHintForCategory(categoryName, 0.2)
	})
	local tween2 = TweenService:Create(clone2, TweenInfo.new(0.2), {
		BackgroundColor3 = categoryName
	})
	imageButton.MouseEnter:Connect(function()
		tween:Play()
	end)
	imageButton.MouseLeave:Connect(function()
		tween2:Play()
	end)
	local v60 = tween2
	imageButton.MouseButton1Down:Connect(function()
		v60:Play()
	end)
	local v61 = tween
	imageButton.Activated:Connect(function()
		v61:Play()
		SetCategory(name)
	end)
	categoryName = clone2.UIStroke
	assert(categoryName:IsA("UIStroke"), "Category button UIStroke must be a UIStroke")
	categoryName.Enabled = false
	categoryNamesByName[name] = categoryName
	clonesByName[name] = clone2
	imageButton.Image = v57.Image
	clone2.Visible = true
	clone2.Parent = categoryFrame
end

fn2()
updateCategoryLabel(previousCategory)
updateCategorySelectionVisuals()
refreshFavoriteModeVisibility()
v16 = NewGui("TextButton", "VRInventorySelector")
v16.Position = UDim2.new(0, 0, 0, 0)
v16.Size = UDim2.new(1, 0, 1, 0)
v16.BackgroundTransparency = 1
v16.Text = ""
v16.Parent = inventory
GUI = NewGui("ImageLabel", "Selector")
GUI.Size = UDim2.new(1, 0, 1, 0)
GUI.Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png"
GUI.ScaleType = Enum.ScaleType.Slice
GUI.SliceCenter = Rect.new(12, 12, 52, 52)
GUI.Visible = false
v16.SelectionImageObject = GUI
v16.MouseButton1Click:Connect(function()
	vrMoveSlotToInventory()
end)
scrollingFrame = inventory:WaitForChild("ScrollingFrame")
uIGridLayout = scrollingFrame:WaitForChild("UIGridLayout")
uIPadding = scrollingFrame:FindFirstChildWhichIsA("UIPadding")
uIAspectRatioConstraint = uIGridLayout:FindFirstChildWhichIsA("UIAspectRatioConstraint") or scrollingFrame:FindFirstChildWhichIsA("UIAspectRatioConstraint")

if uIAspectRatioConstraint then
	aspectRatio = uIAspectRatioConstraint.AspectRatio
end

scrollingDirection = scrollingFrame.ScrollingDirection

if uIPadding then
	paddingLeft = uIPadding.PaddingLeft
end

if ReplicatedStorage then
	uIGridLayout.CellSize = UDim2.new(
		uIGridLayout.CellSize.X.Scale,
		uIGridLayout.CellSize.X.Offset,
		uIGridLayout.CellSize.Y.Scale,
		uIGridLayout.CellSize.Y.Offset / 2
	)
end

cellSize = uIGridLayout.CellSize
applyCategoryLayout()
v17 = GridCellFitter.Fit(uIGridLayout, ReplicatedStorage and 5 or 6, uDim)
local scrollButton = createScrollButton("ScrollUpButton", "rbxasset://textures/ui/Backpack/ScrollUpArrow.png")
scrollButton.Size = UDim2.new(0, 34, 0, 34)
scrollButton.Position = UDim2.new(0.5, -scrollButton.Size.X.Offset / 2, 0, 43)
ReplicatedStorage = scrollButton.Icon
ReplicatedStorage.Position = scrollButton.Icon.Position - UDim2.new(0, 0, 0, 2)
scrollButton.MouseButton1Click:Connect(function()
	scrollingFrame.CanvasPosition = Vector2.new(
		scrollingFrame.CanvasPosition.X,
		(math.min(
			scrollingFrame.AbsoluteCanvasSize.Y - scrollingFrame.AbsoluteWindowSize.Y,
			(math.max(0, scrollingFrame.CanvasPosition.Y - (v14 + 5)))
		))
	)
end)
local scrollButton2 = createScrollButton("ScrollDownButton", "rbxasset://textures/ui/Backpack/ScrollUpArrow.png")
scrollButton2.Rotation = 180
ReplicatedStorage = scrollButton2.Icon
ReplicatedStorage.Position = scrollButton2.Icon.Position - UDim2.new(0, 0, 0, 2)
scrollButton2.Size = UDim2.new(0, 34, 0, 34)
scrollButton2.Position = UDim2.new(0.5, -scrollButton2.Size.X.Offset / 2, 1, -scrollButton2.Size.Y.Offset - 3)
scrollButton2.MouseButton1Click:Connect(function()
	scrollingFrame.CanvasPosition = Vector2.new(
		scrollingFrame.CanvasPosition.X,
		(math.min(
			scrollingFrame.AbsoluteCanvasSize.Y - scrollingFrame.AbsoluteWindowSize.Y,
			(math.max(0, scrollingFrame.CanvasPosition.Y + (v14 + 5)))
		))
	)
end)
scrollingFrame.Changed:Connect(function(p)
	if p == "AbsoluteWindowSize" or p == "CanvasPosition" or p == "AbsoluteCanvasSize" then
		local visible = scrollingFrame.CanvasPosition.Y ~= 0
		local visible2 = scrollingFrame.CanvasPosition.Y < scrollingFrame.AbsoluteCanvasSize.Y - scrollingFrame.AbsoluteWindowSize.Y
		scrollButton.Visible = visible
		scrollButton2.Visible = visible2
	end
end)
ResizeContainers()
inventory:GetPropertyChangedSignal("Visible"):Connect(PositionInventoryAffordances)
PlatformController.Changed:Connect(PositionInventoryAffordances)
PositionInventoryAffordances()
local parent6 = Utility:Create("Frame")({
	Name = "GamepadHintsFrame",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.fromScale(0.22, 0.062),
	Size = UDim2.new(0.76, 0, 0, isTenFootInterface and 36 or 32),
	BackgroundTransparency = 1,
	Visible = false,
	Parent = inventory
})

function createHint(p, text)
	local parent = Utility:Create("Frame")({
		Name = "HintFrame",
		Size = UDim2.new(1, 0, 1, -5),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Parent = parent6
	})
	local v59 = Utility:Create("ImageLabel")({
		Name = "HintImage",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(48, 48),
		BackgroundTransparency = 1,
		Image = InputIconsConfig.Image(p) or "",
		ScaleType = Enum.ScaleType.Fit,
		Parent = parent
	})
	InputIconsConfig.Changed:Connect(function()
		v59.Image = InputIconsConfig.Image(p) or ""
	end)
	local v60 = Utility:Create("TextLabel")({
		Name = "HintText",
		Position = UDim2.fromOffset(56, 0),
		Size = UDim2.new(1, -56, 1, 0),
		Font = Enum.Font.SourceSansBold,
		TextSize = isTenFootInterface and 26 or 22,
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = false,
		Parent = parent
	})
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint", v60)
	uITextSizeConstraint.MaxTextSize = v60.TextSize
end

function PositionHintFrame()
	local v58 = isTenFootInterface and 36 or 32
	local v59 = isTenFootInterface and 26 or 22
	local TextService = game:GetService("TextService")
	local children = parent6:GetChildren()
	local v60 = {}
	local total = 0

	for k, v61 in children do
		local textSize = TextService:GetTextSize(v61.HintText.Text, v59, v61.HintText.Font, Vector2.new(10000, v58))
		v60[k] = v58 + 8 + math.ceil(textSize.X) + 4
		total += v60[k]
	end

	local v61 = parent6.AbsoluteSize.Y / v58
	local v62 = parent6.AbsoluteSize.X / math.max(v61, 0.001)
	local v63 = math.max(1, #children - 1)
	local v64 = math.min(1, v62 / (total + v63 * 20))
	local v65 = (v62 - total * v64) / v63
	local total2 = 0

	for k, v66 in children do
		v66.Position = UDim2.fromOffset(total2, 0)
		v66.Size = UDim2.new(0, v60[k] * v64, 1, 0)
		v66.HintImage.Size = UDim2.fromOffset(v58 * v64, v58 * v64)
		v66.HintText.Position = UDim2.fromOffset((v58 + 8) * v64, 0)
		v66.HintText.Size = UDim2.new(1, -(v58 + 8) * v64, 1, 0)
		v66.HintText.TextSize = v59 * v64
		total2 += v60[k] * v64 + v65
	end
end

createHint(Enum.KeyCode.ButtonX, "Remove From Hotbar")
createHint(Enum.KeyCode.ButtonA, "Select/Swap")
createHint(Enum.KeyCode.ButtonB, "Close Backpack")
parent6:GetPropertyChangedSignal("AbsoluteSize"):Connect(PositionHintFrame)
PositionHintFrame()
local search = inventory:WaitForChild("Search")
textBox = search:WaitForChild("TextBox")
textBox.ClearTextOnFocus = false
textBox.TextXAlignment = Enum.TextXAlignment.Left
CloseButton = inventory:FindFirstChild("Close")

if CloseButton and CloseButton:IsA("GuiButton") then
	ButtonFX(CloseButton, nil, function()
		if inventory.Visible then
			Main.OpenClose()
		end
	end)
end

local strokeTemplate = search:FindFirstChild("StrokeTemplate") or search:FindFirstChildWhichIsA("UIStroke") or script.StrokeTemplate:Clone()
strokeTemplate.Enabled = false
strokeTemplate.Parent = search
RunService.Heartbeat:Connect(function(dt: number)
	if not strokeTemplate.Enabled then
		return
	end

	local uIGradient = strokeTemplate.UIGradient
	uIGradient.Rotation = (uIGradient.Rotation + dt * 20) % 360
end)
local X = search:FindFirstChild("X") or search:FindFirstChild("ClearSearch") or search:WaitForChild("X")
X.Visible = false

function PerformSearch()
	if textBox.Text == "" then
		ResetSearchResults()
		return
	end

	local v58 = {}

	for k in textBox.Text:gmatch("%S+") do
		v58[k:lower()] = true
	end

	local v59 = {}

	for i = emptySlotsAttribute + 1, #v19 do
		local v60 = v19[i]

		if not (v60 and v60.Tool) then
			continue
		end

		if IsOfCategory(v60.Tool) then
			table.insert(v59, { v60, v60:CheckTerms(v58) })
			v60.Frame.Visible = false
			local v61 = v60
			pcall(function()
				v61.Frame.Parent = inventory
			end)
		else
			v60.Frame.Visible = false
		end
	end

	table.sort(v59, function(a, b)
		return a[2] > b[2]
	end)
	flag = true
	local count = 0

	for _, v60 in ipairs(v59) do
		local v61 = v60[1]

		if v60[2] > 0 then
			v61.Frame.Visible = true
			v61.Frame.Parent = scrollingFrame
			v61.Frame.LayoutOrder = emptySlotsAttribute + count
			count += 1
		else
			v61.Frame.Visible = false
		end
	end

	UpdateScrollingFrameCanvasSize()
	X.ZIndex = 2000
end

performSearch = PerformSearch

function ResetSearchResults()
	flag = false

	for i = emptySlotsAttribute + 1, #v19 do
		local v58 = v19[i]

		if not (v58 and v58.Tool) then
			continue
		end

		local tool = v58.Tool

		if IsOfCategory(tool) then
			v58.Frame.Parent = scrollingFrame
			v58.Frame.Visible = true
		else
			v58.Frame.Visible = false
		end
	end

	X.ZIndex = 0
	UpdateInventorySlots()
end

resetSearchResults = ResetSearchResults

function ClearSearchText()
	ResetSearchResults()
	textBox.Text = ""
end

function OnSearchTextChanged(p)
	if p == "Text" then
		PerformSearch()
		local v58 = textBox.Text ~= ""
		X.Visible = v58
		strokeTemplate.Enabled = v58
	end
end

function OnSearchFocusLost(p)
	if p then
		PerformSearch()
	end
end

X.MouseButton1Click:Connect(ClearSearchText)
textBox.Changed:Connect(OnSearchTextChanged)
textBox.FocusLost:Connect(OnSearchFocusLost)
Main.StateChanged.Event:Connect(function(p)
	if not (p or inventory.Visible) then
		topBarPlus:deselect()
	end
end)

function OnEscapePressed(p)
	if p or ActiveFuseSelectionState then
		return
	end

	if inventory.Visible then
		topBarPlus:deselect()
	end
end

v22[Enum.KeyCode.Escape.Value] = OnEscapePressed

-- equivalent calls inferred from this helper; original call sites unknown
local function updateSearchVisibility()
	search.Visible = UserInputService.VREnabled or UserInputService.PreferredInput ~= Enum.PreferredInput.Gamepad
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshSlotDragDetectors()
	for _, v58 in v19 do
		if not v58.IsDeleted then
			v58:RefreshDragDetector()
		end
	end
end

local function updateBackpackInputMode()
	updateSearchVisibility() -- equivalent call inferred; original call site unknown
	refreshSlotDragDetectors() -- equivalent call inferred; original call site unknown
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateBackpackInputMode)
UserInputService:GetPropertyChangedSignal("VREnabled"):Connect(updateBackpackInputMode)
MenuNavigation.CursorChanged:Connect(refreshSlotDragDetectors)
inventory:GetPropertyChangedSignal("Visible"):Connect(updateSearchVisibility)
updateBackpackInputMode()
GuiService.MenuOpened:Connect(function()
	if inventory.Visible then
		topBarPlus:deselect()
	end
end)

function RemoveSlotAction(_, p, _)
	if not (p == Enum.UserInputState.Begin and GuiService.SelectedObject) then
		return
	end

	for i = 1, emptySlotsAttribute do
		if not (v19[i].Frame == GuiService.SelectedObject and v19[i].Tool) then
			continue
		end

		v19[i]:MoveToInventory()
		resetSearchResults()
		return
	end

	resetSearchResults()
end

function setInventoryVisibility(visible: boolean)
	inventory.Visible = visible
	AdjustHotbarFrames()
	parent2.Active = not visible

	for i = 1, emptySlotsAttribute do
		v19[i]:SetClickability(not visible)
	end

	if inventory.Visible then
		if flag2 then
			if v7[UserInputService:GetLastInputType()] then
				PositionHintFrame()
				parent6.Visible = not UserInputService.VREnabled
			end

			enableGamepadInventoryControl()
		end
	else
		if flag2 then
			parent6.Visible = false
		end

		disableGamepadInventoryControl()
	end

	if inventory.Visible then
		ContextActionService:BindActionAtPriority(
			"RBXRemoveSlot",
			RemoveSlotAction,
			false,
			Enum.ContextActionPriority.High.Value + 100,
			Enum.KeyCode.ButtonX
		)
	else
		ContextActionService:UnbindAction("RBXRemoveSlot")
	end

	local setOverride = MenuNavigation.SetOverride
	local v59

	if visible then
		v59 = backpack
	end

	setOverride("Backpack", v59, parent2:FindFirstChild("1"), function()
		topBarPlus:deselect()
	end, 100)
	Main.IsOpen = inventory.Visible
	Main.StateChanged:Fire(inventory.Visible)

	if not inventory.Visible then
		local v60

		if ActiveFuseSelectionState and fn then
			fn(false)
			v60 = true
		else
			v60 = false
		end

		if not v60 then
			v6 = nil

			if previousFavoriteModeActive then
				setFavoriteModeActive(false)
			end
		end
	end
end

function Main.OpenClose()
	if v27 and not inventory.Visible then
		return
	end

	if ActiveFuseSelectionState then
		if inventory.Visible then
			setInventoryVisibility(false)
		else
			Main.IsOpen = inventory.Visible
		end
	else
		if next(v23) then
			return
		end

		setInventoryVisibility(not inventory.Visible)
	end
end

function setFuseSelectionSlotClickability(p)
	for _, v58 in v19 do
		if v58 and v58.Tool then
			v58:SetClickability(not p)
		end
	end
end

function captureFuseHotbarSnapshot()
	local tools = {}

	for i = 1, emptySlotsAttribute do
		local v58 = v19[i]
		local tool = v58 and v58.Tool

		if not v58 or v58.IsFakeSlot or typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
			continue
		end

		if not isAssetTool(tool) then
			continue
		end

		tools[i] = tool
	end

	return tools
end

function moveFuseHotbarAssetsToInventory()
	for i = 1, emptySlotsAttribute do
		local v58 = v19[i]

		if not v58 or v58.IsFakeSlot or not v58.Tool or not isAssetTool(v58.Tool) then
			continue
		end

		v58:MoveToInventory()
	end
end

function restoreFuseHotbarSnapshot(items)
	local v58 = {}

	for k, tool in items do
		if not (typeof(tool) == "Instance" and tool:IsA("Tool") and tool.Parent) then
			continue
		end

		v58[tool] = k
	end

	for i = 1, emptySlotsAttribute do
		local v59 = v19[i]

		if not v59 or v59.IsFakeSlot or not v59.Tool or not isAssetTool(v59.Tool) then
			continue
		end

		if v58[v59.Tool] then
			continue
		end

		v59:MoveToInventory()
	end

	for k, tool in items do
		if not (typeof(tool) == "Instance" and tool:IsA("Tool") and tool.Parent) then
			continue
		end

		local v59 = v19[k]
		local v60 = v21[tool]

		if not v59 or v59.IsFakeSlot or not v60 or v60.IsFakeSlot then
			continue
		end

		if not (v60.Tool == tool and v59 ~= v60) then
			continue
		end

		if v59.Tool then
			v59:MoveToInventory()
		end

		v60:Swap(v59)
	end
end

function stopFuseSelectionVisuals()
	if FuseSelectionVisualTrove then
		FuseSelectionVisualTrove:Clean()
		FuseSelectionVisualTrove = nil
	end

	refreshInventoryFrameVisuals()
end

function startFuseSelectionVisuals()
	stopFuseSelectionVisuals()

	if not InventoryStroke then
		refreshInventoryFrameVisuals()
		return
	end

	FuseSelectionVisualTrove = Trove.new()
	local total = 0
	FuseSelectionVisualTrove:Add(RunService.Heartbeat:Connect(function(dt)
		if not ActiveFuseSelectionState then
			return
		end

		total += dt * 3
		local midpoint = (math.sin(total) + 1) / 2
		InventoryStroke.Color = FUSE_SELECTION_STROKE_COLOR:Lerp(Color3.fromRGB(255, 255, 255), midpoint)
	end))
	refreshInventoryFrameVisuals()
end

function Main:StartMachineSelection(value3: string, callback, callback2, allowedCategories, value4: string)
	assert(type(value3) == "string", "Expected machine selection item type to be a string")
	assert(type(callback) == "function", "Expected fuse selection callback to be a function")
	assert(type(value4) == "string", "Expected preferred category to be a string")

	if ActiveFuseSelectionState then
		self:EndFuseSelection()
	end

	ActiveFuseSelectionState = {
		AllowedCategories = allowedCategories,
		ItemType = value3,
		PreviousCategory = previousCategory,
		PreviousFavoriteModeActive = previousFavoriteModeActive,
		PreferredCategory = value4,
		HotbarSnapshot = captureFuseHotbarSnapshot()
	}
	self:RequestSelection(value3, callback, false, false, callback2)

	if previousFavoriteModeActive then
		setFavoriteModeActive(false)
	end

	if textBox and textBox.Text ~= "" then
		if resetSearchResults then
			resetSearchResults()
		end

		textBox.Text = ""
	end

	if favoriteMode then
		favoriteMode.Visible = false

		if autoSell then
			autoSell.Visible = false
		end

		if equipBest then
			equipBest.Visible = false
		end
	end

	if flag and resetSearchResults then
		resetSearchResults()
	end

	if textBox and textBox.Text ~= "" then
		textBox.Text = ""
	end

	fn2()
	updateEquipBestButtonVisibility()
	SetCategory(value4)

	if value3 == "Asset" then
		moveFuseHotbarAssetsToInventory()
	end

	AdjustHotbarFrames()
	setInventoryVisibility(true)
	setFuseSelectionSlotClickability(false)
	UpdateInventorySlots()
	startFuseSelectionVisuals()
	OnIconChanged(BackpackEnabled)
	return true
end

fn = function(flag7: boolean)
	local activeFuseSelectionState = ActiveFuseSelectionState

	if not activeFuseSelectionState then
		return
	end

	ActiveFuseSelectionState = nil
	stopFuseSelectionVisuals()
	v6 = nil

	if flag7 then
		setInventoryVisibility(false)
	end

	setFuseSelectionSlotClickability(true)

	if CloseButton then
		CloseButton.Active = true
		CloseButton.Visible = true
	end

	if favoriteMode then
		favoriteMode.Visible = false

		if autoSell then
			autoSell.Visible = false
		end

		if equipBest then
			equipBest.Visible = false
		end
	end

	fn2()

	if activeFuseSelectionState.ItemType == "Asset" then
		restoreFuseHotbarSnapshot(activeFuseSelectionState.HotbarSnapshot)
	end

	SetCategory(activeFuseSelectionState.PreviousCategory)
	refreshFavoriteModeVisibility()

	if activeFuseSelectionState.PreviousFavoriteModeActive then
		setFavoriteModeActive(true)
	else
		refreshInventoryFrameVisuals()
	end

	UpdateInventorySlots()
	OnIconChanged(BackpackEnabled)
	updateEquipBestButtonVisibility()
end

function Main:EndFuseSelection()
	fn(true)
end

function Main:StartFuseSelection(callback, callback2)
	return self:StartMachineSelection("Asset", callback, callback2, {
		[FUSE_SELECTION_ASSET_CATEGORY_NAME] = true
	}, FUSE_SELECTION_ASSET_CATEGORY_NAME)
end

function Main.IsFuseSelectionActive(_)
	return ActiveFuseSelectionState ~= nil
end

tryCore("SetCoreGuiEnabled", Enum.CoreGuiType.Backpack, false)

while not localPlayer do
	wait()
	localPlayer = Players.LocalPlayer
end

localPlayer.CharacterAdded:Connect(SetupCharacter)

if localPlayer.Character then
	SetupCharacter(localPlayer.Character)
end

local function handleLocalActiveAssetRecords(p)
	refreshPlacedAssetUIDs(p)
	local v58 = clearPlacedAssetBackpackSlots(p)
	local v59 = syncAssetsFromSave()

	if v58 and not v59 then
		AdjustHotbarFrames()
		UpdateInventorySlots()
	end

	reconcileVirtualAssetEquipState()
end

refreshPlacedAssetUIDs(AssetRoster.ReadOwnerPen(localPlayer.UserId))
AssetRoster.OwnerRefreshed:Connect(function(p, p2)
	if p == localPlayer.UserId then
		handleLocalActiveAssetRecords(p2)
	end
end)
AssetRoster.OwnerCleared:Connect(function(p)
	if p == localPlayer.UserId then
		handleLocalActiveAssetRecords({})
	end
end)
task.spawn(function()
	Save.Await()
	syncAssetsFromSave()
	syncEggsFromSave()
	reconcileVirtualAssetEquipState()
	reconcileVirtualEggEquipState()
	v40 = captureEligibleAssetUIDs()
	v45 = captureEggUIDs()
	flag3 = true
	flag4 = true
end)
Save.WatchFields({ "Inventory", "AssetFavoriteCategories" }, function()
	local v58 = captureEligibleAssetUIDs()

	if flag3 then
		queueNewEligibleAssetsForHotbar(v40, v58)
	end

	v40 = v58
	flag3 = true
	syncAssetsFromSave()
	reconcileVirtualAssetEquipState()
	movePendingHotbarAssets()
end)
Save.WatchFields({
	"EquippedAssets",
	"BaseUpgradeLevel",
	"Gamepasses",
	"Products"
}, function()
	syncAssetsFromSave()
	reconcileVirtualAssetEquipState()
end)
Save.WatchFields("EggInventory", function()
	local v58 = captureEggUIDs()

	if flag4 then
		queueNewEggsForHotbar(v45, v58)
	end

	v45 = v58
	flag4 = true
	syncEggsFromSave()
	reconcileVirtualEggEquipState()
	movePendingHotbarEggs()
end)
EggState.SnapshotRefreshed:Connect(function()
	syncEggsFromSave()
	reconcileVirtualEggEquipState()
end)
PlotState.LocalPlotChanged:Connect(function()
	invalidateEquipBestStatus(true)
end)
PlotState.FolderChanged:Connect(function()
	invalidateEquipBestStatus(true)
end)
UserInputService.InputBegan:Connect(HandleInputBegan)
UserInputService.TextBoxFocused:Connect(function()
	v29 = true
end)
UserInputService.TextBoxFocusReleased:Connect(function()
	v29 = false
end)

v22[value2] = function()
	if humanoid then
		UnequipAllTools()
	end
end

UserInputService.Changed:Connect(OnInputServiceChanged)
OnInputServiceChanged("KeyboardEnabled")

if UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1) then
	gamepadConnected()
end

UserInputService.GamepadConnected:Connect(function(p)
	if p == Enum.UserInputType.Gamepad1 then
		gamepadConnected()
	end
end)
UserInputService.GamepadDisconnected:Connect(function(p)
	if p == Enum.UserInputType.Gamepad1 then
		gamepadDisconnected()
	end
end)

function Main:RequestSelection(itemType: string, callback, flag7: boolean?, flag8: boolean?, callback2)
	v6 = {
		ItemType = itemType,
		Callback = callback,
		AllowHotbar = flag7 == true,
		Preserve = flag8 == true,
		Validator = callback2
	}
end

function Main.ClearSelectionRequest(_)
	v6 = nil
end

function Main.SetCategory(_, p: string)
	SetCategory(p)
end

function Main.OpenInventory(_)
	if not Main.IsOpen then
		Main.OpenClose()
	end
end

function Main:SetBackpackEnabled(p)
	BackpackEnabled = p
end

function Main.SetTreadmillPhoneOnlyMode(_, flag7: boolean)
	if v27 == flag7 then
		return
	end

	v27 = flag7

	if flag7 and inventory.Visible then
		topBarPlus:deselect()
	end

	AdjustHotbarFrames()
end

function Main.IsOpened(_)
	return Main.IsOpen
end

function Main.GetBackpackEnabled(_)
	return BackpackEnabled
end

function Main.GetCategory(_)
	return previousCategory
end

function Main.RefreshInventory(_)
	if performSearch then
		performSearch()
	else
		UpdateInventorySlots()
	end
end

function Main.GetStateChangedEvent(_)
	return Main.StateChanged.Event
end

function Main:ForceEggIntoTutorialHotbar(p: string)
	local v58 = v41[p] or findVirtualEggSlotByUID(p)

	if not v58 or v58.IsDeleted then
		v44[p] = true
		return nil
	end

	v43[p] = nil
	v44[p] = nil
	local v59 = v19[5]
	assert(v59 and not v59.IsFakeSlot, (`Tutorial egg hotbar slot {5} must be available`))
	assert(canToolUseHotbarSlot(v58.Tool, 5), (`Tutorial egg must be insertable in slot {5}`))

	if v59.Tool and v59 ~= v58 then
		v59:MoveToInventory()
	end

	if v58 ~= v59 then
		v58:Swap(v59)
	end

	v41[p] = v59
	AdjustHotbarFrames()
	UpdateInventorySlots()

	if performSearch then
		performSearch(true)
	end

	if reconcileVirtualEggEquipState() ~= p then
		v59:Select()
	end

	return v59.Frame
end

function Main.GetPhoneSlotFrame(_)
	for i = 1, emptySlotsAttribute do
		local v58 = v19[i]

		if v58 and not v58.IsFakeSlot and v58.Tool and isPhoneTool(v58.Tool) then
			return v58.Frame
		end
	end

	return nil
end

function Main.GetEggSlotFrame(_, p: string)
	local v58 = v41[p] or findVirtualEggSlotByUID(p)

	if v58 == nil or v58.IsDeleted then
		return nil
	end

	return v58.Frame
end

RunService.Heartbeat:Connect(function()
	OnIconChanged(BackpackEnabled)
	local isLocalInsideArena = ToolGameplayGuard.IsLocalInsideArena()

	if isLocalInsideArena and not v28 then
		ensureGameplayGearHotbarSlots()
	end

	v28 = isLocalInsideArena
	local localPlayerWithinOwnPlotBounds = isLocalPlayerWithinOwnPlotBounds()

	if v52 == localPlayerWithinOwnPlotBounds then
		if v52 and (v51 or not v50) then
			requestEquipBestStatusRefresh()
		else
			updateEquipBestButtonVisibility()
		end
	else
		v52 = localPlayerWithinOwnPlotBounds

		if localPlayerWithinOwnPlotBounds then
			requestEquipBestStatusRefresh(true)
		else
			updateEquipBestButtonVisibility()
		end
	end
end)
ApiEvent.Event:Connect(function(p, p2)
	if p == "SetBackpackEnabled" then
		Main:SetBackpackEnabled(p2)
	elseif p == "SetInventoryOpen" then
		if type(p2) == "boolean" and p2 == true then
			Main.IsOpen = true
		elseif type(p2) == "boolean" then
			Main.IsOpen = false
		end
	elseif p == "ToggleBackpack" then
		Main.OpenClose()
	end
end)
local Navigation = require(script.Navigation)
Navigation(backpack, inventory, scrollingFrame, parent2, categoryFrame)
local Capacity = require(script.Capacity)
Capacity(inventory, backpack)
local MutationHint = require(script.MutationHint)
MutationHint(parent2, inventory)
return Main