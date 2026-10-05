local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local Shop = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Shop"))
local parent = script.Parent.Parent
local holders = parent:WaitForChild("Holders")
local header = parent:WaitForChild("Header")
local restockButton = header:WaitForChild("RestockButton")
local oddsButton = header:WaitForChild("OddsButton")
local hitTarget = oddsButton:WaitForChild("HitTarget")
local oddsPanel = parent:WaitForChild("OddsPanel")
local title = oddsPanel:WaitForChild("Title")
local cards = oddsPanel:WaitForChild("Cards")
local uIGridLayout = cards:WaitForChild("UIGridLayout")
local card = script:WaitForChild("Card")
local rareCard = script:WaitForChild("RareCard")
local uIAspectRatioConstraint = parent:FindFirstChildOfClass("UIAspectRatioConstraint")
local v = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Mythic = 6,
	Mythical = 6,
	Divine = 7,
	Ethereal = 8
}
local v2 = false
local v3 = false
local v4 = nil

local function OpenCategory()
	for _, guiObject in holders:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject.Visible and Shop.Categories[guiObject.Name] then
			return guiObject.Name
		end
	end

	return nil
end

local function SortedItems(p)
	local result = {}

	for k, config in Shop.Categories[p] do
		table.insert(result, {
			Name = k,
			Config = config
		})
	end

	table.sort(result, function(a, b)
		local v5 = Shop.SourceOrder[a.Config.Source] or 1e999
		local v6 = Shop.SourceOrder[b.Config.Source] or 1e999

		if v5 ~= v6 then
			return v5 < v6
		end

		local v7 = v[a.Config.Rarity] or 0
		local v8 = v[b.Config.Rarity] or 0

		if v7 ~= v8 then
			return v7 < v8
		end

		local price = a.Config.Price or 0
		local price2 = b.Config.Price or 0

		if price == price2 then
			return a.Name < b.Name
		end

		return price < price2
	end)
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WindowAspect()
	local absoluteSize = parent.AbsoluteSize

	if absoluteSize.X > 0 and absoluteSize.Y > 0 then
		return absoluteSize.X / absoluteSize.Y
	end

	return uIAspectRatioConstraint and uIAspectRatioConstraint.AspectRatio or 1
end

local function Arrange(p)
	local v5 = math.max(math.ceil(p / 5), 1)
	local fillDirectionMaxCells = math.max(math.ceil(p / v5), 1)
	local v7 = math.min((1 - (fillDirectionMaxCells - 1) * 0.02) / fillDirectionMaxCells, 0.2)
	local v8 = v5 * v7 + (v5 - 1) * 0.02
	local v9 = v8 + 0.125 + 0.04
	local scale = cards.Size.X.Scale
	local scale2 = oddsPanel.Size.X.Scale
	local v10 = oddsPanel
	local v11 = v9 * scale * scale2
	local windowAspect = WindowAspect() -- equivalent call inferred; original call site unknown
	v10.Size = UDim2.fromScale(scale2, v11 * windowAspect)
	title.Position = UDim2.fromScale(0.5, 0.03 / v9)
	title.Size = UDim2.fromScale(scale, 0.075 / v9)
	cards.Position = UDim2.fromScale(0.5, 0.125 / v9)
	cards.Size = UDim2.fromScale(scale, v8 / v9)
	uIGridLayout.CellSize = UDim2.fromScale(v7, v7 / v8)
	uIGridLayout.CellPadding = UDim2.fromScale(0.02, 0.02 / v8)
	uIGridLayout.FillDirectionMaxCells = fillDirectionMaxCells
end

local function Build(p)
	if v4 == p then
		return
	end

	v4 = p

	for _, guiObject in cards:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local sortedItems = SortedItems(p)
	title.Text = string.format("%s Restock Odds", Shop.GetDisplayName(p))
	Arrange(#sortedItems)

	for k, v6 in sortedItems do
		local v7 = math.clamp(tonumber(v6.Config.StockChance) or 0, 0, 100)
		local clone = (v7 <= 10 and rareCard or card):Clone()
		clone.Name = v6.Name
		clone.LayoutOrder = k
		clone.Title.Text = v6.Config.DisplayName or v6.Name
		clone.Chance.Text = string.format("%g%%", v7)
		clone.Icon.Image = v6.Config.ImageId or ""
		clone.Parent = cards
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Update()
	local openCategory = OpenCategory()
	local visible

	if openCategory == nil then
		visible = false
	else
		visible = parent.Visible

		if visible then
			if parent:GetAttribute("UIClosing") == true then
				visible = false
			else
				visible = v2 or v3 or GuiService.SelectedObject == hitTarget
			end
		end
	end

	if visible then
		Build(openCategory)
	end

	oddsPanel.Visible = visible
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Close()
	v2 = false
	v3 = false
	oddsPanel.Visible = false
end

local function Inside(p, p2)
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	return p2.X >= absolutePosition.X and p2.Y >= absolutePosition.Y and p2.X <= absolutePosition.X + absoluteSize.X and p2.Y <= absolutePosition.Y + absoluteSize.Y
end

GamepadUI.Watch(oddsPanel, Close, hitTarget, 10)
hitTarget.MouseEnter:Connect(function()
	if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
		return
	end

	v2 = true
	Update() -- equivalent call inferred; original call site unknown
end)
hitTarget.MouseLeave:Connect(function()
	v2 = false
	task.delay(0.1, Update)
end)
hitTarget.SelectionGained:Connect(function()
	hitTarget.NextSelectionDown = restockButton.NextSelectionDown
	Update() -- equivalent call inferred; original call site unknown
end)
hitTarget.SelectionLost:Connect(function()
	v3 = false
	Update() -- equivalent call inferred; original call site unknown
end)
hitTarget.Activated:Connect(function()
	v3 = not v3
	Update() -- equivalent call inferred; original call site unknown
end)
UserInputService.InputBegan:Connect(function(input)
	if not oddsPanel.Visible then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape then
		Close() -- equivalent call inferred; original call site unknown
	elseif input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local v5 = oddsButton
		local position = input.Position
		local absolutePosition = v5.AbsolutePosition
		local absoluteSize = v5.AbsoluteSize
		local v6

		if position.X >= absolutePosition.X and position.Y >= absolutePosition.Y and position.X <= absolutePosition.X + absoluteSize.X then
			v6 = position.Y <= absolutePosition.Y + absoluteSize.Y
		else
			v6 = false
		end

		if not v6 then
			local v7 = oddsPanel
			local position2 = input.Position
			local absolutePosition2 = v7.AbsolutePosition
			local absoluteSize2 = v7.AbsoluteSize
			local v8

			if position2.X >= absolutePosition2.X and position2.Y >= absolutePosition2.Y and position2.X <= absolutePosition2.X + absoluteSize2.X then
				v8 = position2.Y <= absolutePosition2.Y + absoluteSize2.Y
			else
				v8 = false
			end

			if not v8 then
				Close() -- equivalent call inferred; original call site unknown
			end
		end
	end
end)
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if not parent.Visible then
		Close() -- equivalent call inferred; original call site unknown
	end
end)
parent:GetAttributeChangedSignal("UIClosing"):Connect(function()
	if parent:GetAttribute("UIClosing") == true then
		Close() -- equivalent call inferred; original call site unknown
	end
end)

for _, guiObject in holders:GetChildren() do
	if guiObject:IsA("GuiObject") then
		guiObject:GetPropertyChangedSignal("Visible"):Connect(function()
			if oddsPanel.Visible then
				Update() -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

hitTarget.NextSelectionRight = restockButton
restockButton.NextSelectionLeft = hitTarget
oddsPanel.Visible = false