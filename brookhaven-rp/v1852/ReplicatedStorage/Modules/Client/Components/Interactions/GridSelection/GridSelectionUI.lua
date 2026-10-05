local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ToolsConfig = require(ReplicatedStorage.Modules.Shared.DB.Tools.ToolsConfig)
local BakingConfig = require(ReplicatedStorage.Modules.Shared.Housing.Baking.BakingConfig)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local HoverFX = require(ReplicatedStorage.Modules.Client.Components.UI.Animation.HoverFX)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local GamepassIcon = require(ReplicatedStorage.Modules.Client.Item.GamepassIcon)
local uDim = UDim2.fromScale(0.75, 0.75)
local uDim2 = UDim2.fromScale(0.925, 0.925)
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local color = Color3.fromRGB(255, 255, 255)
local uDim3 = UDim.new(0, 6)
local rbxassetfontsfamiliesNunitojson = Font.new(
	"rbxasset://fonts/families/Nunito.json",
	Enum.FontWeight.Regular,
	Enum.FontStyle.Normal
)
local color2 = Color3.fromRGB(0, 0, 0)
local color3 = Color3.fromRGB(255, 196, 55)

-- equivalent calls inferred from this helper; original call sites unknown
local function udim2ToPixels(udim: UDim2, absoluteSize: Vector2)
	return Vector2.new(udim.X.Scale * absoluteSize.X + udim.X.Offset, udim.Y.Scale * absoluteSize.Y + udim.Y.Offset)
end

local function formatVector2(point: Vector2)
	return string.format("(%.1f, %.1f)", point.X, point.Y)
end

local function formatUDim2(udim: UDim2)
	return string.format("{%.3f,%d},{%.3f,%d}", udim.X.Scale, udim.X.Offset, udim.Y.Scale, udim.Y.Offset)
end

local function getGridMetrics(container, uIGridLayout)
	local absoluteSize = container.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return nil
	end

	local cellSize = udim2ToPixels(uIGridLayout.CellSize, absoluteSize) -- equivalent call inferred; original call site unknown
	local cellPadding = udim2ToPixels(uIGridLayout.CellPadding, absoluteSize) -- equivalent call inferred; original call site unknown

	if cellSize.X <= 0 or cellSize.Y <= 0 then
		return nil
	end

	local v3 = cellSize.X + cellPadding.X
	local v4 = cellSize.Y + cellPadding.Y

	if v3 <= 0 or v4 <= 0 then
		return nil
	end

	local fillDirectionMaxCells = uIGridLayout.FillDirectionMaxCells

	if fillDirectionMaxCells <= 0 then
		fillDirectionMaxCells = math.max(1, (math.floor((absoluteSize.X + cellPadding.X) / v3 + 0.001)))
	end

	return {
		cellSize = cellSize,
		stride = Vector2.new(v3, v4),
		columns = fillDirectionMaxCells,
		cellPadding = cellPadding
	}
end

local function getIndexedCellOrigin(point: Vector2, p: number, p2: number)
	local v = math.max(p2, 1) - 1
	return Vector2.new(v % p * point.X, math.floor(v / p) * point.Y)
end

local function isWrapperFullyInView(container, wrapper, absoluteSize: Vector2)
	local absoluteSize2 = container.AbsoluteSize

	if absoluteSize2.X <= 0 or absoluteSize2.Y <= 0 or absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return false
	end

	local v = wrapper.AbsolutePosition - container.AbsolutePosition
	return v.X >= -1 and v.Y >= -1 and v.X + absoluteSize.X <= absoluteSize2.X + 1 and v.Y + absoluteSize.Y <= absoluteSize2.Y + 1
end

local function getTemplate()
	local gridSelectionBillboard = ReplicatedStorage:FindFirstChild("GridSelectionBillboard")
	local v

	if gridSelectionBillboard == nil then
		v = false
	else
		v = gridSelectionBillboard:IsA("BillboardGui")
	end

	assert(v, "ReplicatedStorage.GridSelectionBillboard missing")
	return gridSelectionBillboard
end

local function resolveIcon(p: string, instance)
	local icon = instance:GetAttribute("Icon")

	if typeof(icon) == "string" and icon ~= "" then
		return icon
	end

	local v = ToolsConfig.GetConfig()[p]

	if v ~= nil and typeof(v.Icon) == "string" and v.Icon ~= "" then
		return v.Icon
	end

	local item = ItemRegistry.GetItem(p, MenuItem)

	if item ~= nil then
		local icon2 = item:GetIcon()

		if typeof(icon2) == "string" and icon2 ~= "" then
			return icon2
		end
	end

	return BakingConfig.GetIconForToolName(p)
end

local GridSelectionUI = {
	ResolveIcon = function(p: string, p2)
		return resolveIcon(p, p2)
	end
}

local function getDisplayOrder(instance)
	local displayOrder = instance:FindFirstChild("DisplayOrder")

	if displayOrder ~= nil and (displayOrder:IsA("IntValue") or displayOrder:IsA("NumberValue")) then
		return displayOrder.Value
	end

	local layoutOrder = instance:GetAttribute("LayoutOrder")

	if typeof(layoutOrder) == "number" then
		return layoutOrder
	end

	return 1e999
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRequiredGamepassId(instance)
	local gamepass = instance:FindFirstChild("Gamepass")

	if gamepass == nil or not (gamepass:IsA("NumberValue") and gamepass.Value > 0) then
		return nil
	end

	return gamepass.Value
end

local function resolveGamepassIconImage(p: number)
	if Gamepasses.Exists(p) then
		local smallIcon = GamepassIcon.GetSmallIcon(Gamepasses.GetById(p))

		if smallIcon ~= nil and smallIcon ~= "" then
			return smallIcon
		end
	end

	return (`rbxthumb://type=GamePass&id={p}&w=150&h=150`)
end

local function applyGamepassPresentation(itemDisplay, gamepassIcon, requiredGamepassId: number)
	local v = itemDisplay:FindFirstChildOfClass("UIStroke")

	if v == nil then
		v = Instance.new("UIStroke")
		v.Name = "GamepassStroke"
		v.Parent = itemDisplay
	end

	v.Color = color3
	v.Thickness = 2.5
	v.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	v.Transparency = 1
	v.Enabled = true

	if gamepassIcon == nil then
		return v
	end

	local image

	if Gamepasses.Exists(requiredGamepassId) then
		image = GamepassIcon.GetSmallIcon(Gamepasses.GetById(requiredGamepassId))

		if image == nil or image == "" then
			image = `rbxthumb://type=GamePass&id={requiredGamepassId}&w=150&h=150`
		end
	else
		image = `rbxthumb://type=GamePass&id={requiredGamepassId}&w=150&h=150`
	end

	if image ~= nil then
		gamepassIcon.Image = image
	end

	gamepassIcon.ImageTransparency = 1
	gamepassIcon.Visible = true
	return v
end

function GridSelectionUI.Create(instance, instance2, callback)
	local maid = Janitor.new()
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	assert(playerGui ~= nil, "PlayerGui missing")
	local gridSelectionBillboard = ReplicatedStorage:FindFirstChild("GridSelectionBillboard")
	local v

	if gridSelectionBillboard == nil then
		v = false
	else
		v = gridSelectionBillboard:IsA("BillboardGui")
	end

	assert(v, "ReplicatedStorage.GridSelectionBillboard missing")
	local gui = maid:Add(gridSelectionBillboard:Clone())
	gui.Name = "GridSelectionBillboard"

	if not (instance:IsA("BasePart") or instance:IsA("Model") or instance:IsA("Attachment")) then
		instance = nil
	end

	gui.Adornee = instance
	gui.Parent = playerGui
	local container = gui:WaitForChild("Container")
	local itemWrapper = container:WaitForChild("ItemWrapper")
	itemWrapper.Visible = false
	container.Active = true
	container.Selectable = false
	container.SelectionGroup = true
	container.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
	container.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
	container.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
	container.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
	local children = instance2:GetChildren()
	table.sort(children, function(a, b)
		local displayOrder = getDisplayOrder(a)
		local displayOrder2 = getDisplayOrder(b)

		if displayOrder == displayOrder2 then
			return a.Name < b.Name
		end

		return displayOrder < displayOrder2
	end)
	local v3 = {}
	local flag = false
	local uIGridLayout = container:FindFirstChildOfClass("UIGridLayout")
	maid:Add(function()
		flag = true
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isEntryInView(p)
		local absoluteSize = p.wrapper.AbsoluteSize

		if not (absoluteSize.X <= 0 or absoluteSize.Y <= 0) then
			return (isWrapperFullyInView(container, p.wrapper, absoluteSize))
		end

		local v4

		if uIGridLayout ~= nil then
			v4 = getGridMetrics(container, uIGridLayout)
		end

		if v4 == nil then
			return false
		end

		absoluteSize = v4.cellSize
		return (isWrapperFullyInView(container, p.wrapper, absoluteSize))
	end

	local function connectHover(state)
		local tweenDescriptions, hoverEnd = HoverFX.GetTweenDescriptions(state.itemDisplay)

		for _, v5 in UIAnimationEffects.ConnectButtonHoverAndActivationFX(state.button, state.itemDisplay, {
			Hover = tweenDescriptions,
			HoverEnd = hoverEnd
		}) do
			maid:Add(v5)
		end
	end

	local function popInEntry(state)
		if flag or state.revealed then
			return
		end

		-- equivalent call inferred; original call site unknown
		if isEntryInView(state) then
			state.revealed = true
			state.itemDisplay.Visible = true
			local tween = TweenService:Create(state.itemDisplay, tweenInfo, {
				Size = uDim2,
				BackgroundTransparency = 0.35
			})
			local tween2 = TweenService:Create(state.toolIcon, tweenInfo, {
				ImageTransparency = 0
			})
			maid:Add(tween, "Cancel")
			maid:Add(tween2, "Cancel")
			tween:Play()
			tween2:Play()

			if state.gamepassIcon ~= nil and state.gamepassIcon.Visible then
				local tween3 = TweenService:Create(state.gamepassIcon, tweenInfo, {
					ImageTransparency = 0
				})
				maid:Add(tween3, "Cancel")
				tween3:Play()
			end

			if state.gamepassStroke ~= nil then
				local tween3 = TweenService:Create(state.gamepassStroke, tweenInfo, {
					Transparency = 0
				})
				maid:Add(tween3, "Cancel")
				tween3:Play()
			end

			maid:Add(tween.Completed:Connect(function(p)
				if flag or p ~= Enum.PlaybackState.Completed then
					return
				end

				local entryInView = isEntryInView(state) -- equivalent call inferred; original call site unknown

				if entryInView == false then
					state.itemDisplay.Visible = false
				else
					connectHover(state)
				end
			end))
		else
			state.queued = false
			state.itemDisplay.Visible = false
		end
	end

	local function syncCanvasVisibility()
		if flag then
			return
		end

		if uIGridLayout ~= nil then
			getGridMetrics(container, uIGridLayout)
		end

		local count = 0
		local count2 = 0

		for _, v4 in v3 do
			local entryInView = isEntryInView(v4) -- equivalent call inferred; original call site unknown

			if entryInView == true then
				count2 += 1
			end

			v4.button.Active = entryInView
			v4.button.Selectable = entryInView

			if v4.revealed == true then
				v4.itemDisplay.Visible = entryInView
			else
				v4.itemDisplay.Visible = false
			end

			if v4.itemDisplay.Visible == true then
				count += 1
			end
		end
	end

	local function queueVisibleReveals()
		if flag then
			return
		end

		syncCanvasVisibility()
		local count = 0

		for _, v4 in v3 do
			if v4.revealed or v4.queued then
				continue
			end

			-- equivalent call inferred; original call site unknown
			if not isEntryInView(v4) then
				continue
			end

			v4.queued = true
			count += 1
			local v5 = (count - 1) * 0.03
			local v6 = v4
			maid:Add(task.delay(v5, function()
				if flag then
					return
				end

				popInEntry(v6)
			end))
		end
	end

	for k, optionInstance in children do
		local wrapper = maid:Add(itemWrapper:Clone())
		wrapper.Name = optionInstance.Name
		wrapper.LayoutOrder = k
		wrapper.Visible = true
		wrapper.Parent = container
		local itemDisplay = wrapper:WaitForChild("ItemDisplay")
		local toolIcon = itemDisplay:WaitForChild("ToolIcon")
		local gamepassIcon = itemDisplay:FindFirstChild("GamepassIcon")
		local button = itemDisplay:WaitForChild("Button")
		itemDisplay.AnchorPoint = Vector2.new(0.5, 0.5)
		itemDisplay.Position = UDim2.fromScale(0.5, 0.5)
		itemDisplay.Size = uDim
		itemDisplay.BackgroundColor3 = color
		itemDisplay.BackgroundTransparency = 1
		itemDisplay.Visible = false
		local v6 = itemDisplay:FindFirstChildOfClass("UICorner")

		if v6 == nil then
			v6 = Instance.new("UICorner")
			v6.Parent = itemDisplay
		end

		v6.CornerRadius = uDim3

		if button:IsA("TextButton") then
			button.FontFace = rbxassetfontsfamiliesNunitojson
			button.TextColor3 = color2
		end

		toolIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		toolIcon.Position = UDim2.fromScale(0.5, 0.5)
		toolIcon.Size = UDim2.fromScale(0.8, 0.8)
		toolIcon.BackgroundTransparency = 1
		toolIcon.ImageTransparency = 1
		local icon = resolveIcon(optionInstance.Name, optionInstance)

		if icon ~= nil then
			toolIcon.Image = icon
		end

		if gamepassIcon ~= nil then
			gamepassIcon.Visible = false
		end

		local gamepassStroke = nil
		local requiredGamepassId = getRequiredGamepassId(optionInstance) -- equivalent call inferred; original call site unknown

		if requiredGamepassId ~= nil then
			gamepassStroke = applyGamepassPresentation(itemDisplay, gamepassIcon, requiredGamepassId)
		end

		button.Active = true
		button.Selectable = true
		button.SelectionOrder = k
		local v8 = optionInstance
		maid:Add(button.Activated:Connect(function()
			callback(v8)
		end))
		table.insert(v3, {
			wrapper = wrapper,
			itemDisplay = itemDisplay,
			toolIcon = toolIcon,
			gamepassIcon = gamepassIcon,
			gamepassStroke = gamepassStroke,
			button = button,
			optionInstance = optionInstance,
			layoutIndex = k,
			revealed = false,
			queued = false
		})
	end

	maid:Add(container:GetPropertyChangedSignal("CanvasPosition"):Connect(queueVisibleReveals))
	maid:Add(container:GetPropertyChangedSignal("AbsoluteSize"):Connect(queueVisibleReveals))
	maid:Add(container:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(queueVisibleReveals))

	if uIGridLayout ~= nil then
		maid:Add(uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(queueVisibleReveals))
		maid:Add(uIGridLayout:GetPropertyChangedSignal("AbsoluteCellSize"):Connect(queueVisibleReveals))
	end

	task.defer(function()
		if flag then
			return
		end

		queueVisibleReveals()
		maid:Add(task.delay(0, queueVisibleReveals))
		maid:Add(task.delay(0.05, queueVisibleReveals))
	end)
	return {
		Gui = gui,
		Destroy = function()
			maid:Destroy()
		end
	}
end

return GridSelectionUI