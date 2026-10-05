local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local BitohiUI = require(ReplicatedStorage:WaitForChild("BitohiUI"))
local UIController = require(ReplicatedStorage:WaitForChild("UIController"))
local UIChoreo = require(ReplicatedStorage:WaitForChild("UIChoreo"))
local UIQuality = require(ReplicatedStorage:WaitForChild("UIQuality"))
local UIIdle = require(ReplicatedStorage:WaitForChild("UIIdle"))
local enthusiasticArrive = BitohiUI.EnthusiasticArrive
local juice = BitohiUI.Juice
local spring = BitohiUI.Spring
local store = BitohiUI.Store
local spr = spring.spr
local parent = script.Parent
local holders = parent:WaitForChild("Holders")
local POSE = UIChoreo.POSE
local SWING = UIChoreo.SWING
local v = {
	S = 0,
	Tune = "Card",
	PoseTune = SWING
}
local v2 = { 0.7, 7 }
local v3 = { 1, 11 }
local v4 = {
	Scale = 1.3,
	Rotation = 0,
	ScaleName = "JoltScale"
}
local v5 = UIChoreo.new(parent, {
	Parts = {
		{
			Get = "Header",
			Pose = POSE.Header,
			At = 0.07
		},
		{
			Get = "Header.CloseButton",
			Pose = POSE.Close,
			At = 0.16,
			Fade = false
		},
		{
			Get = "Header.RestockButton",
			Pose = POSE.Pop,
			At = 0.22,
			Fade = false
		},
		{
			Get = "Header.OddsButton",
			Pose = POSE.Pop,
			At = 0.26,
			Fade = false
		}
	},
	Idle = false
})
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function idleLater()
	count += 1
	local v6 = count
	task.delay(0.6, function()
		if v6 == count and UIController.isOpen(parent) then
			UIIdle.start(parent)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function idleStop()
	count += 1
	UIIdle.stop(parent)
end

local skip = v5:Skip()

local function skip2(guiObject)
	if skip(guiObject) then
		return true
	end

	local parent2 = guiObject.Parent

	if parent2 == holders then
		return guiObject:IsA("GuiObject") and not guiObject.Visible
	end

	if not parent2 or parent2.Parent ~= holders or not (parent2:IsA("ScrollingFrame") and guiObject:IsA("GuiObject")) then
		return false
	end

	local Y = parent2.AbsolutePosition.Y
	local Y2 = guiObject.AbsolutePosition.Y
	return not (Y2 < Y + parent2.AbsoluteSize.Y and Y < Y2 + guiObject.AbsoluteSize.Y)
end

local flag = false

local function pages()
	local scrollingFrames = {}

	for _, scrollingFrame in ipairs(holders:GetChildren()) do
		if scrollingFrame:IsA("ScrollingFrame") then
			table.insert(scrollingFrames, scrollingFrame)
		end
	end

	return scrollingFrames
end

local function artOf(instance)
	local productExpander = instance:FindFirstChild("ProductExpander")

	if not productExpander then
		return nil
	end

	local imageViewport = productExpander:FindFirstChild("ImageViewport")

	if imageViewport and imageViewport.Visible then
		return imageViewport
	end

	return productExpander:FindFirstChild("ImageShower")
end

local function onScreen(instance)
	local Y = instance.AbsolutePosition.Y
	local v6 = Y + instance.AbsoluteSize.Y
	local result = {}

	for _, guiObject in ipairs(instance:GetChildren()) do
		if not (guiObject:IsA("GuiObject") and guiObject.Visible and guiObject:FindFirstChild("ProductExpander")) then
			continue
		end

		local Y2 = guiObject.AbsolutePosition.Y

		if Y2 < v6 and Y < Y2 + guiObject.AbsoluteSize.Y then
			table.insert(result, guiObject)
		end
	end

	table.sort(result, function(a, b)
		return a.AbsolutePosition.Y < b.AbsolutePosition.Y
	end)

	if UIQuality.low() then
		for i = #result, 7, -1 do
			result[i] = nil
		end
	end

	return result
end

local count2 = 0
local v6 = {}
local v7 = store.new()
local v8 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectOpen()
	for i = #v8, 1, -1 do
		v8[i]:Disconnect()
		v8[i] = nil
	end
end

local function popPage(p, p2)
	local v9 = onScreen(p)

	for i, v10 in ipairs(v9) do
		local productExpander = v10:FindFirstChild("ProductExpander")
		local imageViewport

		if productExpander then
			imageViewport = productExpander:FindFirstChild("ImageViewport")

			if not (imageViewport and imageViewport.Visible) then
				imageViewport = productExpander:FindFirstChild("ImageShower")
			end
		end

		v6[v10] = imageViewport or false
		spr.stop(v10, "Rotation")
		v10.Rotation = i % 2 == 0 and 7 or -7

		if imageViewport then
			enthusiasticArrive.set(imageViewport, v, {
				Flip = i % 2 == 0,
				Fade = false
			})
		end
	end

	local v10 = count2
	local v11 = not (#v9 > 1) and 0.05 or math.min(0.05, 0.35 / (#v9 - 1)) or 0.05

	for i, v12 in ipairs(v9) do
		local v13 = v12
		local v14 = i
		task.delay(p2 + (i - 1) * v11, function()
			if v10 ~= count2 or not v13.Parent then
				return
			end

			spring.to(v13, SWING, {
				Rotation = 0
			})
			local v15 = v6[v13]

			if v15 then
				task.delay(0.05, function()
					if v10 == count2 and v15.Parent then
						enthusiasticArrive.play(v15, v, {
							Reset = false,
							Flip = v14 % 2 == 0,
							Fade = false
						})
					end
				end)
			end
		end)
	end
end

local function wireHover(instance)
	if v7[instance] then
		return
	end

	local productExpander = instance:FindFirstChild("ProductExpander")

	if not productExpander then
		return
	end

	v7[instance] = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function swell(scale)
		local productExpander2 = instance:FindFirstChild("ProductExpander")
		local imageViewport

		if productExpander2 then
			imageViewport = productExpander2:FindFirstChild("ImageViewport")

			if not (imageViewport and imageViewport.Visible) then
				imageViewport = productExpander2:FindFirstChild("ImageShower")
			end
		end

		if imageViewport then
			spring.to(spring.scale(imageViewport, "HoverScale"), v2, {
				Scale = scale
			})
		end
	end

	productExpander.MouseEnter:Connect(function()
		if UserInputService:GetLastInputType() ~= Enum.UserInputType.Touch then
			swell(1.1) -- equivalent call inferred; original call site unknown
		end
	end)
	productExpander.MouseLeave:Connect(function()
		swell(1) -- equivalent call inferred; original call site unknown
	end)
	productExpander.SelectionGained:Connect(function()
		swell(1.1) -- equivalent call inferred; original call site unknown
	end)
	productExpander.SelectionLost:Connect(function()
		swell(1) -- equivalent call inferred; original call site unknown
	end)
end

local function watchStock(instance)
	local productExpander = instance:FindFirstChild("ProductExpander")
	local stock = productExpander and productExpander:FindFirstChild("Stock")

	if not stock then
		return
	end

	local v9 = tonumber(stock.Text:match("%d+"))
	table.insert(v8, stock:GetPropertyChangedSignal("Text"):Connect(function()
		local v10 = tonumber(stock.Text:match("%d+"))

		if v10 and v9 and v10 < v9 then
			local productExpander2 = instance:FindFirstChild("ProductExpander")
			local imageViewport

			if productExpander2 then
				imageViewport = productExpander2:FindFirstChild("ImageViewport")

				if not (imageViewport and imageViewport.Visible) then
					imageViewport = productExpander2:FindFirstChild("ImageShower")
				end
			end

			if imageViewport then
				juice.jolt(imageViewport, v4)
			end
		end

		v9 = v10
	end))
end

local function eachTile(fn)
	for _, v9 in ipairs((pages())) do
		for _, guiObject in ipairs(v9:GetChildren()) do
			if guiObject:IsA("GuiObject") then
				fn(guiObject, v9)
			end
		end
	end
end

local function resetTiles()
	local v9 = {}

	for k, v10 in pairs(v6) do
		if k.Parent then
			spr.stop(k, "Rotation")
			k.Rotation = 0
		end

		if v10 then
			table.insert(v9, v10)
		end
	end

	enthusiasticArrive.reset(v9)
	table.clear(v6)
end

local function onOpen(p)
	count2 += 1
	v5:Enter(p)
	disconnectOpen() -- equivalent call inferred; original call site unknown
	eachTile(function(p2)
		wireHover(p2)
		watchStock(p2)
	end)
	flag = false

	for _, v9 in ipairs((pages())) do
		table.insert(v8, v9:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			flag = true
		end))
	end

	for _, v9 in ipairs((pages())) do
		local v10 = v9
		table.insert(v8, v9:GetPropertyChangedSignal("Visible"):Connect(function()
			if v10.Visible and UIController.isOpen(parent) then
				count2 += 1
				idleStop() -- equivalent call inferred; original call site unknown
				local v11 = {}

				for k, v12 in pairs(v6) do
					if k.Parent == v10 then
						continue
					end

					if k.Parent then
						spr.stop(k, "Rotation")
						k.Rotation = 0
					end

					if v12 then
						table.insert(v11, v12)
					end

					v6[k] = nil
				end

				if #v11 > 0 then
					enthusiasticArrive.reset(v11)
				end

				UIController.refreshFade(parent)
				popPage(v10, 0)
				idleLater() -- equivalent call inferred; original call site unknown
			end
		end))
	end

	idleLater() -- equivalent call inferred; original call site unknown

	if p == false then
		for k, v9 in pairs(v6) do
			if k.Parent then
				spring.to(k, SWING, {
					Rotation = 0
				})
			end

			if v9 and v9.Parent then
				enthusiasticArrive.play(v9, v, {
					Reset = false,
					Fade = false
				})
			end
		end
	else
		for _, v9 in ipairs((pages())) do
			if v9.Visible then
				popPage(v9, 0.12)
			end
		end
	end
end

local function onClose()
	count2 += 1
	count += 1
	disconnectOpen() -- equivalent call inferred; original call site unknown

	if flag then
		flag = false
		UIController.refreshFade(parent)
	end

	v5:Leave()

	for _, v9 in pairs(v6) do
		if v9 and v9.Parent then
			spring.to(spring.scale(v9, "AnimScale"), v3, {
				Scale = 0.3
			})
		end
	end
end

local function onHidden()
	count2 += 1
	count += 1
	disconnectOpen() -- equivalent call inferred; original call site unknown
	flag = false
	UIController.refreshFade(parent)
	v5:Reset()
	resetTiles()
end

UIController.decorate(parent, {
	Skip = skip2,
	Warm = function()
		v5:Warm()
	end,
	CloseLead = 0.08,
	Open = onOpen,
	Close = onClose,
	Hidden = onHidden
})