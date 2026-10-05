local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.PseudoEnum)
require(game.ReplicatedStorage.React.RobloxTypes)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local useFirstTagged = require(game.ReplicatedStorage.React.Hooks.Instance.useFirstTagged)
local useTagGuiObject = require(game.ReplicatedStorage.React.Hooks.UID.useTagGuiObject)
local useConfig = require(game.ReplicatedStorage.React.Hooks.Inventory.useConfig)
local useViewportSize = require(game.ReplicatedStorage.React.Hooks.useViewportSize)
local useStackFilter = require(game.ReplicatedStorage.React.Hooks.Inventory.Tiles.useStackFilter)
local useGroupFilter = require(game.ReplicatedStorage.React.Hooks.Inventory.Tiles.useGroupFilter)
local useBracketFilter = require(game.ReplicatedStorage.React.Hooks.Inventory.Tiles.useBracketFilter)
local useSearchFilter = require(game.ReplicatedStorage.React.Hooks.Inventory.Tiles.useSearchFilter)
local useCurrentGroup = require(game.ReplicatedStorage.React.Hooks.Inventory.useCurrentGroup)
local useSort = require(game.ReplicatedStorage.React.Hooks.Inventory.Tiles.useSort)
local Header = require(script.Header)
local NavigationRail = require(script.NavigationRail)
local ToolBar = require(script.ToolBar)
local TileGrid = require(script.TileGrid)
local BuildMenu = require(script.BuildMenu)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)

function log(...)
	RunService:IsStudio()
end

function selectGuiObject(guiObject)
	if guiObject and guiObject:IsA("GuiObject") and RunService:IsRunning() then
		GuiService.SelectedObject = guiObject
	end
end

local createElement = React.createElement
return function(data)
	log("redraw Inventory/main")
	local state, setState = React.useState(nil)
	local ref = React.useRef(nil)
	local state2, setState2 = React.useState(false)
	local v = useDrawContext()
	local v2 = useLastInput()
	local v3 = useConfig()
	local v4, _ = useCurrentGroup()
	local v5 = v3.HideToolBar ~= true
	local count = 0

	for _, _ in v3.Layout do
		count += 1
	end

	local v6

	if v == "Default" then
		v6 = count > 1
	else
		v6 = false
	end

	local selectable

	if v == "Default" then
		selectable = data.Selectable ~= false
	else
		selectable = false
	end

	React.useEffect(function()
		if v == "Offscreen" then
			setState(nil)
			ref.current = nil
			setState2(false)
		end
	end, { v == "Offscreen" })
	local tiles = useGroupFilter((useStackFilter(data.Tiles)))
	local tiles2 = useSort(useSearchFilter(useBracketFilter(tiles), state))
	local v11, exitButtonTag = useTagGuiObject("InventoryExitButton")
	local v13, v14 = useTagGuiObject("InventoryToolBar")
	local v15, selectedTabTag = useTagGuiObject("InventorySelectedTab")
	local v17 = useFirstTagged(data.ActionButtonTag)
	local v18

	if v == "Default" then
		v18 = v2 == "Gamepad"
	else
		v18 = false
	end

	React.useEffect(function()
		if v18 then
			selectGuiObject(v11)
		end
	end, { v18, v11 })
	local onSearch = React.useMemo(function()
		return function(current: string?)
			if current and current:len() == 0 then
				current = nil
			end

			setState2(current ~= nil)
			ref.current = current
			setState(current)
		end
	end, {})
	local onScrollToTop = React.useMemo(function()
		return function()
			setState2(false)
		end
	end, {})
	local v21 = math.round((math.clamp(useViewportSize().Y * 0.5 * (v3.Scale or 1), 250, 500)))
	local v22 = math.round((math.clamp(v21 * 0.125 / (v3.Scale or 1), 40, 80)))

	if not v5 then
		v21 -= v22
		v22 = 0
	end

	local v23 = math.round(v21 * 1.5)
	local v24 = math.round(v21 * 0.1 / (v3.Scale or 1))
	local v27 = {
		[React.Tag] = data[React.Tag],
		AnchorPoint = data.AnchorPoint,
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		LayoutOrder = data.LayoutOrder,
		Position = data.Position,
		Size = UDim2.fromOffset(v23, v24 + v21),
		SizeConstraint = data.SizeConstraint,
		ZIndex = data.ZIndex
	}
	local v28 = {
		Outline = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		Corner = createElement("UICorner", {
			CornerRadius = UDim.new(0, 1)
		}),
		Header = createElement(Header, {
			AnchorPoint = Vector2.new(0.5, 0),
			AutomaticSize = Enum.AutomaticSize.None,
			ExitButtonTag = exitButtonTag,
			OnExit = data.OnExit,
			Position = UDim2.fromScale(0.5, 0),
			Selectable = selectable,
			Size = UDim2.new(1, 0, 0, v24),
			Title = v3.Title
		}),
		PageContent = 0,
		NavigationRail = 0
	}
	local v31 = {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.new(1, 0, 1, -v24)
	}
	local v32 = {
		Padding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8)
		}),
		BuildMenu = 0,
		ToolBar = 0,
		TileGrid = 0
	}
	local buildMenu

	if v4 == "Build" then
		buildMenu = createElement(BuildMenu, {})
	end

	v32.BuildMenu = buildMenu
	local toolBar

	if v5 and v4 ~= "Build" then
		toolBar = createElement(ToolBar, {
			[React.Tag] = v14,
			Tiles = tiles,
			SearchText = state,
			OnSearch = onSearch,
			AnchorPoint = Vector2.new(0.5, 0),
			AutomaticSize = Enum.AutomaticSize.None,
			Position = UDim2.fromScale(0.5, 0),
			Selectable = selectable,
			Size = UDim2.new(1, 0, 0, v22),
			ZIndex = 3,
			OnSearchFocusChanged = function(flag: boolean)
				if not flag then
					setState2(false)
				end
			end
		})
	end

	v32.ToolBar = toolBar
	local tileGrid

	if v4 ~= "Build" then
		local v38 = {
			Tiles = tiles2,
			AnchorPoint = Vector2.new(0.5, 1),
			AutomaticSize = Enum.AutomaticSize.None,
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.new(1, 0, 1, -v22),
			RowCellCount = 0,
			Selectable = 0,
			ScrollToTop = 0,
			OnScrollToTop = 0,
			OnGamepadBorderExit = 0,
			Variant = 0
		}
		local rowCellCount

		if v4 == "Stash" then
			rowCellCount = v2 == "Touch" and 4 or 5
		else
			rowCellCount = v2 == "Touch" and 3 or 4
		end

		v38.RowCellCount = rowCellCount
		v38.Selectable = selectable
		v38.ScrollToTop = state2
		v38.OnScrollToTop = onScrollToTop

		function v38.OnGamepadBorderExit(p: string)
			if p == "Up" then
				if v13 then
					GuiService:Select(v13)
				else
					selectGuiObject(v11)
				end
			elseif p == "Left" then
				selectGuiObject(v15)
			elseif p == "Right" then
				selectGuiObject(v17)
			end
		end

		v38.Variant = v4 == "Stash" and "Fade" or "Elevated"
		tileGrid = createElement(TileGrid, v38)
	end

	v32.TileGrid = tileGrid
	v28.PageContent = createElement("Frame", v31, v32)
	local navigationRail

	if v6 then
		navigationRail = createElement(NavigationRail, {
			Position = UDim2.fromScale(0, 0.085),
			AnchorPoint = Vector2.new(1, 0),
			Selectable = selectable,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.fromScale(0.16000000000000003, 0.8),
			SelectedTabTag = selectedTabTag
		})
	end

	v28.NavigationRail = navigationRail
	return (createElement("Frame", v27, v28))
end