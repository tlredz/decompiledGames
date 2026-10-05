local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local parent = script.Parent
local hitTarget = parent:WaitForChild("OddsShower"):WaitForChild("HitTarget")
local parent2 = parent.Parent.Parent
local oddsPanel = parent2:WaitForChild("OddsPanel")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local General = require(ReplicatedStorage2.GameData.General)
local Pets = require(ReplicatedStorage2.GameData.Pets)
local HatchLuck = require(ReplicatedStorage2.GameData.HatchLuck)
local pets = ReplicatedStorage2.Assets:WaitForChild("Pets")
local v = false
local v2 = false
local v3 = false

local function Refresh()
	local rarities = General.PremiumEggs["Giant Egg"].Rarities
	local v4 = {}
	local total = 0

	for childName, pet in pairs(Pets) do
		if pet.Rarity and (not HatchLuck.RequireAsset or pets:FindFirstChild(childName)) then
			v4[pet.Rarity] = true
		end
	end

	for k, rarity in pairs(rarities) do
		if v4[k] then
			total += math.max(tonumber(rarity) or 0, 0)
		end
	end

	for _, frame in oddsPanel.Rows:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v5 = not v4[frame.Name] and 0 or math.max(tonumber(rarities[frame.Name]) or 0, 0) or 0
		frame.Chance.Text = string.format("%g%%", v5)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Update()
	local visible = v or v2 or v3 or GuiService.SelectedObject == hitTarget

	if visible then
		Refresh()
	end

	oddsPanel.Visible = visible
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Close()
	v = false
	v2 = false
	v3 = false
	oddsPanel.Visible = false
end

GamepadUI.Watch(oddsPanel, Close, hitTarget, 10)
hitTarget.MouseEnter:Connect(function()
	v = true
	Update() -- equivalent call inferred; original call site unknown
end)
hitTarget.MouseLeave:Connect(function()
	v = false
	task.delay(0.1, Update)
end)
oddsPanel.MouseEnter:Connect(function()
	v2 = true
	Update() -- equivalent call inferred; original call site unknown
end)
oddsPanel.MouseLeave:Connect(function()
	v2 = false
	task.delay(0.1, Update)
end)
hitTarget.SelectionGained:Connect(Update)
hitTarget.SelectionLost:Connect(function()
	v3 = false
	Update() -- equivalent call inferred; original call site unknown
end)
hitTarget.Activated:Connect(function()
	v3 = not v3
	Update() -- equivalent call inferred; original call site unknown
end)

local function Inside(p, p2)
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	return p2.X >= absolutePosition.X and p2.Y >= absolutePosition.Y and p2.X <= absolutePosition.X + absoluteSize.X and p2.Y <= absolutePosition.Y + absoluteSize.Y
end

UserInputService.InputBegan:Connect(function(input)
	if not oddsPanel.Visible then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape then
		Close() -- equivalent call inferred; original call site unknown
	elseif input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local v4 = hitTarget
		local position = input.Position
		local absolutePosition = v4.AbsolutePosition
		local absoluteSize = v4.AbsoluteSize
		local v5

		if position.X >= absolutePosition.X and position.Y >= absolutePosition.Y and position.X <= absolutePosition.X + absoluteSize.X then
			v5 = position.Y <= absolutePosition.Y + absoluteSize.Y
		else
			v5 = false
		end

		if not v5 then
			local v6 = oddsPanel
			local position2 = input.Position
			local absolutePosition2 = v6.AbsolutePosition
			local absoluteSize2 = v6.AbsoluteSize
			local v7

			if position2.X >= absolutePosition2.X and position2.Y >= absolutePosition2.Y and position2.X <= absolutePosition2.X + absoluteSize2.X then
				v7 = position2.Y <= absolutePosition2.Y + absoluteSize2.Y
			else
				v7 = false
			end

			if not v7 then
				Close() -- equivalent call inferred; original call site unknown
			end
		end
	end
end)
parent2:GetPropertyChangedSignal("Visible"):Connect(function()
	if not parent2.Visible then
		Close() -- equivalent call inferred; original call site unknown
	end
end)
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if not parent.Visible then
		Close() -- equivalent call inferred; original call site unknown
	end
end)
Refresh()
oddsPanel.Visible = false