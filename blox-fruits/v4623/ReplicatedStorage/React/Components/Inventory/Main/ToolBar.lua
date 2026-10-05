local React = require(game.ReplicatedStorage.Packages.React)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local Dropdown = require(game.ReplicatedStorage.React.Components.Dropdown)
local TextField = require(game.ReplicatedStorage.React.Components.TextField)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
local useConfig = require(game.ReplicatedStorage.React.Hooks.Inventory.useConfig)
local useCurrentGroup = require(game.ReplicatedStorage.React.Hooks.Inventory.useCurrentGroup)
local useCurrentBracket = require(game.ReplicatedStorage.React.Hooks.Inventory.useCurrentBracket)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	[PseudoEnum.InventoryItemBracket.Swords] = "⚔️",
	[PseudoEnum.InventoryItemBracket.Guns] = "🏹",
	[PseudoEnum.InventoryItemBracket.Fruits] = "🍎",
	[PseudoEnum.InventoryItemBracket.Premium] = "💎",
	[PseudoEnum.InventoryItemBracket.Gear] = "⛏️",
	[PseudoEnum.InventoryItemBracket.Consumables] = "🧪",
	[PseudoEnum.InventoryItemBracket.Accessories] = "🎩",
	[PseudoEnum.InventoryItemBracket.Configurables] = "⚙️",
	[PseudoEnum.InventoryItemBracket.Usables] = "🔑",
	[PseudoEnum.InventoryItemBracket.Materials] = "🌿",
	[PseudoEnum.InventoryItemBracket.Fish] = "🐟",
	[PseudoEnum.InventoryItemBracket.Titles] = "📜",
	[PseudoEnum.InventoryItemBracket.Backgrounds] = "🏞️",
	[PseudoEnum.InventoryItemBracket.Trinkets] = "💍",
	[PseudoEnum.InventoryItemBracket.Scrolls] = "📜",
	[PseudoEnum.InventoryItemBracket.Boxes] = "🎁"
}
local createElement = React.createElement
return function(data)
	local v2 = useConfig()
	local v3 = useDrawContext()
	local v4 = useLastInput()
	local v5 = useCurrentGroup()
	local v6, v7 = useCurrentBracket()
	local v8 = not v2.Layout[v5] and {} or v2.Layout[v5].Brackets
	local isCompact = v4 == "Touch"
	local selectable

	if v3 == "Default" then
		selectable = data.Selectable ~= false
	else
		selectable = false
	end

	local options = React.useMemo(function()
		local result = {
			All = {
				Text = "All" .. (not (#data.Tiles > 0) and "" or ` ({#data.Tiles})`)
			}
		}

		for k, v12 in v8 do
			local count = 0

			for _, tile in ipairs(data.Tiles) do
				for _, bracket in ItemConfig.match(tile.ItemId):unwrap().Inventory.Brackets do
					if v12 ~= bracket then
						continue
					end

					count += 1
					break
				end
			end

			local v13 = v[v12]
			result[v12] = {
				LayoutOrder = k,
				Text = (not v13 and "" or tostring(v13) .. " ") .. FormatUtil.pascalCaseToTitle(v12) .. (not (count > 0) and "" or ` ({count})`)
			}
		end

		return result
	end, { data.Tiles, v8 })
	local selectedKey = not (v6 and options[v6]) and "All" or v6
	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
	}, data)
	local bracketDropdown

	if data.IsMoving or #v8 <= 1 then
		local v19 = {
			Active = false,
			AnchorPoint = Vector2.new(0, 0.5),
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.01, 0.5),
			Size = 0
		}
		local size

		if isCompact then
			size = UDim2.fromScale(0.33, 0.7)
		else
			size = UDim2.fromScale(0.25, 0.7)
		end

		v19.Size = size
		bracketDropdown = createElement("Frame", v19)
	else
		local v19 = {
			AnchorPoint = Vector2.new(0, 0.5),
			AutomaticSize = Enum.AutomaticSize.None,
			ForceClose = v3 ~= "Default" or nil,
			IsCompact = isCompact,
			IsDisabled = #v8 == 0,
			OnSelection = function(p: string)
				if p == "All" then
					v7(nil)
				else
					v7(p)
				end
			end,
			Options = options,
			Position = UDim2.fromScale(0.01, 0.5),
			Selectable = selectable,
			SelectedKey = selectedKey,
			Size = 0
		}
		local size

		if isCompact then
			size = UDim2.fromScale(0.33, 0.7)
		else
			size = UDim2.fromScale(0.25, 0.7)
		end

		v19.Size = size
		bracketDropdown = createElement(Dropdown, v19)
	end

	local searchTextField

	if not data.IsMoving then
		local v20 = {
			AnchorPoint = Vector2.new(1, 0.5),
			AutomaticSize = Enum.AutomaticSize.None,
			BeforeIcon = {
				Image = "rbxassetid://18195291644",
				ImageRectOffset = Vector2.new(0, 0),
				ImageRectSize = Vector2.new(0, 0)
			},
			OnFocusChanged = data.OnSearchFocusChanged,
			OnTextChanged = function(p: string)
				data.OnSearch(p)
				return p
			end,
			PlaceholderText = "Search",
			Position = UDim2.fromScale(0.99, 0.5),
			Selectable = selectable,
			Size = 0,
			Text = 0
		}
		local size

		if isCompact then
			size = UDim2.fromScale(0.4, 0.7)
		else
			size = UDim2.fromScale(0.3, 0.7)
		end

		v20.Size = size
		v20.Text = data.SearchText
		searchTextField = createElement(TextField, v20)
	end

	return createElement("Frame", mergeFrame, {
		BracketDropdown = bracketDropdown,
		SearchTextField = searchTextField
	})
end