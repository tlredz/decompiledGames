local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitohiUI = require(ReplicatedStorage:WaitForChild("BitohiUI"))
local UIController = require(ReplicatedStorage:WaitForChild("UIController"))
local UIChoreo = require(ReplicatedStorage:WaitForChild("UIChoreo"))
local UIQuality = require(ReplicatedStorage:WaitForChild("UIQuality"))
local enthusiasticArrive = BitohiUI.EnthusiasticArrive
local spring = BitohiUI.Spring
local spr = spring.spr
local parent = script.Parent
local scrollingFrame = parent:WaitForChild("ScrollingFrame")
local uIGridLayout = scrollingFrame:WaitForChild("UIGridLayout")
local POSE = UIChoreo.POSE
local SWING = UIChoreo.SWING
local v = {
	S = 0,
	Tune = "Card",
	PoseTune = SWING
}
local v2 = { 1, 11 }
local v3 = UIChoreo.new(parent, {
	Parts = {
		{
			Get = "Header",
			Pose = POSE.Header,
			At = 0.07
		},
		{
			Get = "Pets",
			Pose = POSE.Pop,
			At = 0.12,
			Fade = false
		},
		{
			Get = "CloseBtn",
			Pose = POSE.Close,
			At = 0.16
		},
		{
			Get = "Eggs",
			Pose = POSE.Pop,
			At = 0.17,
			Fade = false
		},
		{
			Get = "Frame.Sell_Ready",
			Pose = POSE.Pop,
			At = 0.22,
			Fade = false
		},
		{
			Get = "Frame.Sell_NotReady",
			Pose = POSE.Pop,
			At = 0.22,
			Fade = false
		}
	},
	Idle = false
})

-- equivalent calls inferred from this helper; original call sites unknown
local function applyOpenFrom()
	parent:SetAttribute("UIOpenFrom", UIQuality.low() and 1 or UIController.Settings.OpenFrom)
end

applyOpenFrom() -- equivalent call inferred; original call site unknown
parent.Destroying:Once(UIQuality.onChanged(applyOpenFrom))

-- equivalent calls inferred from this helper; original call sites unknown
local function atRest()
	local child = parent:FindFirstChild(UIController.Settings.ScaleName)
	return child == nil or math.abs(child.Scale - 1) < 0.001
end

local absoluteSize = scrollingFrame.AbsoluteSize
scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	if atRest() then
		absoluteSize = scrollingFrame.AbsoluteSize
	end
end)
local v4 = {
	Known = {},
	Shown = {},
	List = {},
	Scroll = 0,
	Height = 0,
	Cell = 0
}

local function rebuildView()
	table.clear(v4.Known)
	table.clear(v4.Shown)
	table.clear(v4.List)

	if atRest() then
		absoluteSize = scrollingFrame.AbsoluteSize
	end

	local v5 = absoluteSize
	local v6 = uIGridLayout.CellSize.X.Offset + uIGridLayout.CellSize.X.Scale * v5.X
	local cell = uIGridLayout.CellSize.Y.Offset + uIGridLayout.CellSize.Y.Scale * v5.Y
	local v8 = uIGridLayout.CellPadding.X.Offset + uIGridLayout.CellPadding.X.Scale * v5.X
	local v9 = uIGridLayout.CellPadding.Y.Offset + uIGridLayout.CellPadding.Y.Scale * v5.Y
	local Y = scrollingFrame.CanvasPosition.Y
	local v10 = v4
	local v11 = v4
	local v12 = v4
	local Y2 = v5.Y
	v10.Scroll = Y
	v11.Height = Y2
	v12.Cell = cell
	local buttons = {}

	for _, button in ipairs(scrollingFrame:GetChildren()) do
		if not button:IsA("GuiButton") then
			continue
		end

		v4.Known[button] = true

		if button.Visible then
			table.insert(buttons, button)
		end
	end

	if v6 <= 0 or cell <= 0 then
		return
	end

	table.sort(buttons, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	local v13 = math.max(1, (math.floor((v5.X - scrollingFrame.ScrollBarThickness + v8) / (v6 + v8))))

	for i, tile in ipairs(buttons) do
		local v15 = math.floor((i - 1) / v13) * (cell + v9) - Y

		if v5.Y <= v15 then
			break
		end

		if not (v15 + cell > 0) then
			continue
		end

		v4.Shown[tile] = true
		local list = v4.List
		local v16 = {
			Tile = tile,
			Whole = v15 >= 0 and v15 + cell <= v5.Y
		}
		table.insert(list, v16)
	end
end

local function inView(button)
	if v4.Known[button] == nil or v4.Scroll ~= scrollingFrame.CanvasPosition.Y or v4.Height ~= absoluteSize.Y or v4.Cell ~= uIGridLayout.CellSize.Y.Offset + uIGridLayout.CellSize.Y.Scale * absoluteSize.Y then
		rebuildView()
	end

	return v4.Shown[button] == true
end

local skip = v3:Skip()

local function skip2(button)
	if skip(button) then
		return true
	end

	if button.Parent == scrollingFrame and button:IsA("GuiButton") then
		return not inView(button)
	end

	return false
end

local count = 0
local v5 = {}
local Y = 0

local function popTiles(p)
	rebuildView()
	local count2 = #v4.List

	if UIQuality.low() then
		count2 = math.min(count2, 6)
	end

	local v6 = not (count2 > 1) and 0.03 or math.min(0.03, 0.35 / (count2 - 1)) or 0.03
	local v7 = count

	for i = 1, count2 do
		local v8 = v4.List[i]
		local tile = v8.Tile
		local icon = tile:FindFirstChild("Icon")
		local flip = i % 2 == 0
		v5[tile] = icon or false

		if v8.Whole then
			spr.stop(tile, "Rotation")
			tile.Rotation = flip and 7 or -7
		end

		if icon then
			enthusiasticArrive.set(icon, v, {
				Flip = flip,
				Fade = false
			})
		end

		task.delay(p + (i - 1) * v6, function()
			if v7 ~= count or not tile.Parent then
				return
			end

			spring.to(tile, SWING, {
				Rotation = 0
			})

			if icon then
				task.delay(0.05, function()
					if v7 == count and icon.Parent then
						enthusiasticArrive.play(icon, v, {
							Reset = false,
							Flip = flip,
							Fade = false
						})
					end
				end)
			end
		end)
	end
end

local function resetTiles()
	local v6 = {}

	for k, v7 in pairs(v5) do
		if k.Parent then
			spr.stop(k, "Rotation")
			k.Rotation = 0
		end

		if v7 and v7.Parent then
			table.insert(v6, v7)
		end
	end

	enthusiasticArrive.reset(v6)
	table.clear(v5)
end

local function onOpen(p)
	count += 1
	v3:Enter(p)
	Y = scrollingFrame.CanvasPosition.Y

	if p ~= false then
		popTiles(0.12)
		return
	end

	for k, v6 in pairs(v5) do
		if k.Parent then
			spring.to(k, SWING, {
				Rotation = 0
			})
		end

		if v6 and v6.Parent then
			enthusiasticArrive.play(v6, v, {
				Reset = false,
				Fade = false
			})
		end
	end
end

local function onClose()
	count += 1

	if scrollingFrame.CanvasPosition.Y ~= Y then
		Y = scrollingFrame.CanvasPosition.Y
		UIController.refreshFade(parent)
	end

	v3:Leave()
	rebuildView()
	local count2 = #v4.List

	if UIQuality.low() then
		count2 = math.min(count2, 6)
	end

	for i = 1, count2 do
		local tile = v4.List[i].Tile
		local icon = tile:FindFirstChild("Icon")

		if tile.Rotation ~= 0 then
			spring.to(tile, v2, {
				Rotation = 0
			})
		end

		if not icon then
			continue
		end

		v5[tile] = icon
		spring.to(spring.scale(icon, "AnimScale"), v2, {
			Scale = 0.3
		})
	end
end

local function onHidden()
	count += 1
	v3:Reset()
	resetTiles()
end

UIController.decorate(parent, {
	Skip = skip2,
	Warm = function()
		v3:Warm()
	end,
	CloseLead = 0.08,
	Open = onOpen,
	Close = onClose,
	Hidden = onHidden
})