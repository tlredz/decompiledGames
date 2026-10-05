local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = require(ReplicatedStorage.Modules.UI)
local parent = script.Parent
local parent2 = parent.Parent
local header = parent.Header
local description = parent2.Description
local v = { parent2.Parent.Parent.UIScale, parent2.Parent.Parent.Parent.UIScale }
local buttons = parent2.Buttons

local function getScaleFactor()
	local v2 = 1

	for _, v3 in next, v, nil do
		v2 *= v3.Scale
	end

	return v2
end

local function updateSizeAndPosition()
	local absoluteSize = description.AbsoluteSize
	local v2 = 1

	for _, v3 in next, v, nil do
		v2 *= v3.Scale
	end

	local v3 = absoluteSize / v2
	parent.Position = UDim2.new(
		parent.Position.X.Scale,
		parent.Position.X.Offset,
		description.Position.Y.Scale,
		v3.Y + 20
	)
	parent.Size = UDim2.new(
		parent.Size.X.Scale,
		parent.Size.X.Offset,
		1 - parent.Position.Y.Scale - buttons.Size.Y.Scale,
		-parent.Position.Y.Offset - buttons.Size.Y.Offset - 30
	)
end

UI:AddShadowOnHover(header.Buy)
UI:Bind(header.Buy.Button)
description:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSizeAndPosition)
updateSizeAndPosition()