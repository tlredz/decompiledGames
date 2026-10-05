local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local faye = require(ReplicatedStorage.Packages.faye)
local BossHunts = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.BossHunts)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local TimedEvents = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.TimedEvents)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local HuntCard = require(script.HuntCard)
local Transition = require(script.Transition)
require(script.Types)
local localPlayer = Players.LocalPlayer
local info = faye.Info(0.2)
local every = TimedEvents.BossHunt.Every

local function readsSide(p: string?)
	local v = p ~= nil and BossHunts.Sides[p] or nil
	local data = Utility.GetData(localPlayer)
	local value

	if data ~= nil then
		value = data.Race.Value or nil
	end

	return v ~= nil and value ~= nil and table.find(v.Race, value) ~= nil
end

local function readsBand(p: string)
	local data = Utility.GetData(localPlayer)
	local goal

	if data ~= nil then
		goal = data.Exp.Goal or nil
	end

	if goal == nil then
		return false
	end

	local v = goal.Value / gameSettings.expPerLevel

	if p == "High" then
		return BossHunts.BandLevel <= v
	end

	return v <= BossHunts.BandLevel
end

local v = not RunService:IsRunning()
local v2 = {
	{
		Id = "1",
		Quest = "Eliminate Rengu",
		Boss = "Rengu",
		Side = "Muzan",
		Tier = "Legendary",
		ExpiresAt = 540
	},
	{
		Id = "2",
		Quest = "Eliminate Akazo",
		Boss = "Akazo",
		Side = "Crow",
		Tier = "Mythic",
		ExpiresAt = 300
	},
	{
		Id = "3",
		Quest = "Eliminate Mother Bear",
		Boss = "Mother Bear",
		Side = "Crow",
		Tier = "Common",
		ExpiresAt = 75
	},
	{
		Id = "4",
		Quest = "Eliminate Datai",
		Boss = "Datai",
		Side = "Crow",
		Tier = "Legendary",
		ExpiresAt = 480
	},
	{
		Id = "5",
		Quest = "Eliminate Tai Chi Trainee Suzume",
		Boss = "Tai Chi Trainee Suzume",
		Side = "Muzan",
		Tier = "UnCommon",
		ExpiresAt = 210
	}
}
return function(object, instance, _, p, p2: string)
	local v3 = {}
	local value = object:Value(v3)
	local value2 = object:Value(0)

	local function visibleCap()
		local count = 0

		for k in BossHunts.Sides do
			local v4

			if k ~= nil then
				v4 = BossHunts.Sides[k] or nil
			end

			local data = Utility.GetData(localPlayer)
			local value3

			if data ~= nil then
				value3 = data.Race.Value or nil
			end

			local v5

			if v4 == nil or value3 == nil then
				v5 = false
			else
				v5 = table.find(v4.Race, value3) ~= nil
			end

			if v5 then
				count += 1
			end
		end

		return math.max(count, 1) * BossHunts.MaxOpen
	end

	local canvasSize = object:Value(UDim2.new())
	local size = object:Value(UDim2.new(1, -12, 0, 20))
	local v4 = nil
	local value5 = object:Value(UDim2.new(1, 0, 0, 20))
	local padding = object:Value(UDim.new())
	local v5 = 20
	local v6 = 0
	local v7 = 0

	local function pinToBottom()
		if v4 == nil or v4.Parent == nil then
			return
		end

		local v8 = math.max(v4.AbsoluteCanvasSize.Y - v4.AbsoluteWindowSize.Y, 0)
		v4.CanvasPosition = Vector2.new(0, v8)
	end

	local function refreshCanvas()
		local count = 0

		for _ in v3 do
			count += 1
		end

		value2:Set(count)
		local v8 = count < 1 and 1 or count
		local v9 = math.max(v8 * v5 + (v8 - 1) * v6, v7) * 1.4
		canvasSize:Set(UDim2.new(0, 0, 0, v9))
		size:Set(UDim2.new(1, -12, 0, v9))
		task.defer(pinToBottom)
	end

	local bossHunts = ReplicatedStorage:FindFirstChild("BossHunts")

	local function untilNextRoll()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v8 = every - serverTimeNow % every

		if bossHunts == nil then
			return v8
		end

		local v9 = nil

		for k in BossHunts.Sides do
			local v10

			if k ~= nil then
				v10 = BossHunts.Sides[k] or nil
			end

			local data = Utility.GetData(localPlayer)
			local value7

			if data ~= nil then
				value7 = data.Race.Value or nil
			end

			local v11

			if v10 == nil or value7 == nil then
				v11 = false
			else
				v11 = table.find(v10.Race, value7) ~= nil
			end

			if not v11 then
				continue
			end

			for _, band in BossHunts.Bands do
				local data2 = Utility.GetData(localPlayer)
				local goal

				if data2 ~= nil then
					goal = data2.Exp.Goal or nil
				end

				local v12

				if goal == nil then
					v12 = false
				else
					local v13 = goal.Value / gameSettings.expPerLevel

					if band == "High" then
						v12 = BossHunts.BandLevel <= v13
					else
						v12 = v13 <= BossHunts.BandLevel
					end
				end

				if not v12 then
					continue
				end

				local attribute = bossHunts:GetAttribute((`EligibleAt{k}{band}`))

				if attribute == nil then
					return v8
				end

				if v9 == nil or attribute < v9 then
					v9 = attribute
				end
			end
		end

		if v9 == nil then
			return v8
		end

		return (math.max(v8, math.ceil(v9 / every) * every - serverTimeNow))
	end

	local function readHunt(instance2)
		local side = instance2:GetAttribute("Side")
		local v8

		if side ~= nil then
			v8 = BossHunts.Sides[side] or nil
		end

		local data = Utility.GetData(localPlayer)
		local value7

		if data ~= nil then
			value7 = data.Race.Value or nil
		end

		local v9

		if v8 == nil or value7 == nil then
			v9 = false
		else
			v9 = table.find(v8.Race, value7) ~= nil
		end

		if v9 then
			return {
				Id = instance2.Name,
				Quest = instance2:GetAttribute("Quest"),
				Boss = instance2:GetAttribute("Boss"),
				Side = instance2:GetAttribute("Side"),
				Tier = instance2:GetAttribute("Tier"),
				ExpiresAt = instance2:GetAttribute("ExpiresAt")
			}
		end

		return nil
	end

	if v then
		for _, v8 in v2 do
			local clone = table.clone(v8)
			clone.ExpiresAt += workspace:GetServerTimeNow()
			value:Add(clone.Id, clone)
		end

		refreshCanvas()
	elseif bossHunts ~= nil then
		for _, child in bossHunts:GetChildren() do
			local v8 = readHunt(child)

			if v8 ~= nil then
				value:Add(v8.Id, v8)
			end
		end

		refreshCanvas()
		object:Connect(bossHunts.ChildAdded, function(p3)
			local v8 = readHunt(p3)

			if v8 ~= nil then
				value:Add(v8.Id, v8)
			end

			refreshCanvas()
		end)
		object:Connect(bossHunts.ChildRemoved, function(p3)
			value:Remove(p3.Name)
			refreshCanvas()
		end)
	end

	object:Create("Frame")({
		Parent = instance,
		Size = UDim2.fromScale(0.7, 0.7),
		OnClean = Transition.FadeOutOnClean(),
		object:Create("UIAspectRatioConstraint")({
			AspectRatio = 0.6
		}),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, Platform_Handler.Platform.Value == "Mobile" and 1.03 or 1),
		object:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.25, 0.8),
				NumberSequenceKeypoint.new(0.7, 0.9),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Rotation = -90
		}),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.1)
		}),
		BackgroundColor3 = Color3.new(0.065, 0.065, 0.065),
		BackgroundTransparency = object:Animation(0, Transition.Info, {
			From = 1
		}),
		object:Create("CanvasGroup")({
			Name = "ListMask",
			Size = UDim2.new(1, -12, 1, -(Platform_Handler.Platform.Value == "Mobile" and 0 or 4)),
			Position = UDim2.new(0.5, 0, 0, -26),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			object:Create("UIGradient")({
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.06, 0),
					NumberSequenceKeypoint.new(0.94, 0),
					NumberSequenceKeypoint.new(1, 0.7)
				})
			}),
			object:Create("ScrollingFrame")({
				Name = "ActualHolder",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.new(1, 12, 1, 0),
				BackgroundTransparency = 1,
				CanvasSize = canvasSize,
				function(p3)
					v4 = p3
					task.defer(pinToBottom)
				end,
				AbsoluteSizeOnChangedInit = function(_, point: Vector2)
					if point.X <= 0 then
						return
					end

					local uIScale = instance:FindFirstChildOfClass("UIScale")
					local v8 = (uIScale == nil or not (uIScale.Scale > 0)) and 1 or uIScale.Scale
					v5 = point.X * 0.258 / v8
					v6 = point.X * 0.02 / v8
					v7 = point.Y / v8
					value5:Set(UDim2.new(1, 0, 0, v5))
					padding:Set(UDim.new(0, v6))
					refreshCanvas()
				end,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 0,
				object:Create("Frame")({
					Name = "InnerHolder",
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0),
					Size = size,
					BackgroundTransparency = 1,
					object:Create("UIListLayout")({
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Bottom,
						Padding = padding
					}),
					object:AdvancedIterate(value, function(_, p3, p4, _)
						return HuntCard(p4, p3, p2, p, value5)
					end)
				})
			})
		}),
		object:Create("Frame")({
			Name = "Footer",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -5),
			Size = UDim2.new(1, -12, 0, 26),
			BackgroundTransparency = 1,
			object:State(function(callback, object2)
				if bossHunts == nil and not v then
					return
				end

				local v8 = callback(value2)
				local data = Utility.GetData(localPlayer)
				local noun = BossHunts.Noun
				local v9

				if data ~= nil then
					v9 = data.Race.Value or nil
				end

				local v10 = noun(v9)
				local count = 0

				for k in BossHunts.Sides do
					local v11

					if k ~= nil then
						v11 = BossHunts.Sides[k] or nil
					end

					local data2 = Utility.GetData(localPlayer)
					local value7

					if data2 ~= nil then
						value7 = data2.Race.Value or nil
					end

					local v12

					if v11 == nil or value7 == nil then
						v12 = false
					else
						v12 = table.find(v11.Race, value7) ~= nil
					end

					if v12 then
						count += 1
					end
				end

				local v11 = math.max(count, 1) * BossHunts.MaxOpen
				local v12 = v11 <= v8

				-- equivalent calls inferred from this helper; original call sites unknown
				local function line()
					if v12 then
						return (`{v8} / {v11} {v10}s available`)
					end

					return (`{v8} / {v11} Next {v10} in <b>{Utility.formatTime((untilNextRoll()))}</b>`)
				end

				local v13 = line() -- equivalent call inferred; original call site unknown
				local text = object2:Value(v13)

				if not v12 then
					object2:Spawn(function()
						while true do
							task.wait(0.25)
							local v15 = line() -- equivalent call inferred; original call site unknown
							text:Set(v15)
						end
					end)
				end

				return object2:Create("TextLabel")({
					Name = "Label",
					Size = UDim2.fromScale(1, 0.98),
					BackgroundTransparency = 1,
					RichText = true,
					Text = text,
					TextScaled = true,
					TextWrapped = false,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextColor3 = Color3.new(1, 1, 1),
					TextTransparency = object2:Animation(0.25, info, {
						From = 1
					}),
					Font = Enum.Font.SourceSansSemibold
				})
			end)
		})
	})
end