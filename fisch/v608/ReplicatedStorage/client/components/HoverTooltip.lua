local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local evalColorSequence = require(ReplicatedStorage.shared.utils.evalColorSequence)
local color = Color3.fromRGB(101, 147, 255)
local color2 = Color3.fromRGB(255, 255, 255)
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v = Component.new({
	Tag = "HoverTooltip",
	Ancestors = { playerGui }
})
local maid = Trove.new()
local v2 = nil
local tooltip = script.tooltip
local tooltip2 = tooltip.tooltip
local arrow = tooltip.arrow
tooltip.Enabled = false
tooltip2.Visible = true
arrow.Visible = true
tooltip.Parent = playerGui
local v3 = color
local absoluteSize = tooltip2.tipContent.AbsoluteSize
local absoluteSize2 = tooltip.AbsoluteSize
local absolutePosition = tooltip.AbsolutePosition
local v4 = false

local function renderTooltip()
	if not v2 then
		tooltip.Enabled = false
		return
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	local v5 = mouseLocation.X / absoluteSize2.X
	local v6 = (v5 - 0.5) * 2
	local v7 = absoluteSize2.Y - (mouseLocation.Y + absoluteSize.Y) < 50
	arrow.AnchorPoint = Vector2.new(0.5, v7 and 1 or 0)
	arrow.Rotation = v7 and 0 or 180
	arrow.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y + (v7 and -5 or 25))
	tooltip2.AnchorPoint = Vector2.new(v5, v7 and 1 or 0)
	tooltip2.Position = UDim2.fromOffset(
		math.clamp(mouseLocation.X + 15 * v6, 0, absoluteSize2.X),
		mouseLocation.Y + (v7 and -20 or 40)
	)

	if typeof(v3) == "ColorSequence" then
		arrow.ImageColor3 = evalColorSequence(v3, (math.clamp(v5, 0, 1)))
	end

	tooltip.Enabled = true
end

local function updateTooltipColor()
	if v2 == nil then
		return
	end

	local tooltipColor = v2:GetAttribute("TooltipColor") or color

	if typeof(tooltipColor) == "Color3" then
		tooltip2.UIStroke.Color = tooltipColor
		arrow.ImageColor3 = tooltipColor
	elseif typeof(tooltipColor) == "ColorSequence" then
		tooltip2.UIStroke.UIGradient.Color = tooltipColor
		tooltip2.UIStroke.Color = color2
	else
		warn((`Bad TooltipColor type on {v2:GetFullName()}: {typeof(tooltipColor)}`))
		tooltipColor = color
	end

	v3 = tooltipColor
	tooltip2.UIStroke.UIGradient.Enabled = typeof(tooltipColor) == "ColorSequence"
end

local function updateTooltipContent()
	if v2 == nil then
		return
	end

	tooltip2.tipContent.Text = v2:GetAttribute("TooltipText") or ""
end

function v.SetHoverTarget(object)
	if object == v2 then
		return
	end

	maid:Clean()
	v2 = object

	if object then
		maid:Connect(object:GetAttributeChangedSignal("TooltipColor"), updateTooltipColor)
		maid:Connect(object:GetAttributeChangedSignal("TooltipText"), updateTooltipContent)
		updateTooltipColor()

		if v2 ~= nil then
			tooltip2.tipContent.Text = v2:GetAttribute("TooltipText") or ""
		end

		local parent = object

		while parent and not parent:IsA("PlayerGui") do
			if parent:IsA("GuiObject") then
				local v5 = parent
				maid:Add(parent:GetPropertyChangedSignal("Visible"):Connect(function()
					if not v5.Visible and v2 == object then
						v4 = false
						v.SetHoverTarget(nil)
					end
				end))
			elseif parent:IsA("LayerCollector") then
				local v5 = parent
				maid:Add(parent:GetPropertyChangedSignal("Enabled"):Connect(function()
					if not v5.Enabled and v2 == object then
						v4 = false
						v.SetHoverTarget(nil)
					end
				end))
				return
			end

			parent = parent.Parent
		end
	end
end

function v:Construct()
	self.Trove = Trove.new()
end

function v.Start(p)
	if not (p.Instance:IsA("GuiButton") or p.Instance:IsA("TextBox")) then
		warn((`HoverTooltip instances should be GuiButtons or TextBoxes so console players can properly select them (got: {p.Instance.ClassName} at {p.Instance:GetFullName()})`))
	end

	p.Instance.Selectable = true

	if not p.Instance:GetAttribute("IsActualButton") then
		p.Instance.SelectionImageObject = script.nothing
	end

	p.Trove:Add(p.Instance.MouseEnter:Connect(function()
		if GamepadService.GamepadCursorEnabled then
			return
		end

		if v2 ~= p.Instance then
			v4 = false
			v.SetHoverTarget(p.Instance)
		end
	end))
	p.Trove:Add(p.Instance.MouseLeave:Connect(function()
		if GamepadService.GamepadCursorEnabled then
			return
		end

		if v2 == p.Instance and not v4 then
			v.SetHoverTarget(nil)
		end
	end))
	p.Trove:Add(p.Instance.SelectionGained:Connect(function()
		if v2 ~= p.Instance then
			v4 = false
			v.SetHoverTarget(p.Instance)
		end
	end))
	p.Trove:Add(p.Instance.SelectionLost:Connect(function()
		if v2 == p.Instance and not v4 then
			v.SetHoverTarget(nil)
		end
	end))
	p.Trove:Add(p.Instance.TouchTap:Connect(function()
		if v2 == p.Instance and v4 then
			v4 = false
			v.SetHoverTarget(nil)
		else
			v4 = true
			v.SetHoverTarget(p.Instance)
		end
	end))
end

function v.Stop(p)
	p.Trove:Clean()

	if v2 == p.Instance then
		v4 = false
		v.SetHoverTarget(nil)
	end
end

tooltip2.tipContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	absoluteSize = tooltip2.tipContent.AbsoluteSize
end)
tooltip:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	absoluteSize2 = tooltip.AbsoluteSize
end)
tooltip:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
	absolutePosition = tooltip.AbsolutePosition
end)
RunService.RenderStepped:Connect(function()
	debug.profilebegin("HoverTooltip::RenderTooltip")
	renderTooltip()
	debug.profileend()
end)
UserInputService.InputBegan:Connect(function(input)
	if not (v2 and v4) then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local v5 = GuiService:GetGuiInset() + Vector2.new(input.Position.X, input.Position.Z)

		if not table.find(playerGui:GetGuiObjectsAtPosition(v5.X, v5.Y), v2) then
			v4 = false
			v.SetHoverTarget(nil)
		end
	elseif input.UserInputType == Enum.KeyCode.ButtonB then
		v4 = false
		v.SetHoverTarget(nil)
	end
end)
return v