local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local StatTypes = require(ReplicatedStorage.CAM.Global.Types.StatTypes)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Multipliers = require(ReplicatedStorage.CAM.Global.Multipliers)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local StatRow = require(script.Parent.StatRow)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)

local function paddingFor()
	return UDim.new(0, Platform_Handler.Platform.Value == "Mobile" and 10 or 5)
end

local localPlayer = Players.LocalPlayer
return function(object)
	local value = object:Value({})
	local v = {}
	local color = Color3.new(0.9, 1, 0.9)
	local color2 = Color3.new(1, 0.9, 0.9)
	local color3 = Color3.new(0.9, 0.95, 1)
	local color4 = Color3.new(1, 0.8, 0.8)
	local v2 = { "Factor", "Regen" }

	local function isMultiplier(value2: string)
		for _, v3 in v2 do
			if string.find(value2, v3, 1, true) ~= nil then
				return true
			end
		end

		return false
	end

	local function displayText(p: string, p2: number)
		if isMultiplier(p) then
			return (`{math.round((1 + p2) * 10000) / 10000}x`)
		end

		if p2 > 0 then
			return (`+{p2}`)
		end

		return (tostring(p2))
	end

	local startTicking

	local function put(p: string, value2, p2)
		local v3 = typeof(value2) == "number" and value2 ~= 0 or value2 == true
		local v4 = v[p]
		local v5

		if typeof(value2) == "number" then
			v5 = value2 < 0
		else
			v5 = false
		end

		local v6 = v5 and 0.45 or 0
		local tint = p2 ~= nil and p2.Tint

		if not tint then
			if isMultiplier(p) then
				if v5 then
					tint = color4
				else
					tint = color3
				end
			elseif v5 then
				tint = color2
			else
				tint = color
			end
		end

		local text = p2 ~= nil and p2.Text

		if not text then
			if typeof(value2) == "number" then
				if isMultiplier(p) then
					text = `{math.round((1 + value2) * 10000) / 10000}x`
				elseif value2 > 0 then
					text = `+{value2}`
				else
					text = tostring(value2)
				end
			else
				text = ""
			end
		end

		if v3 then
			if v4 == nil then
				local v7 = {
					Value = object:Value(value2),
					Dim = object:Value(v6),
					Tint = object:Value(tint),
					Text = object:Value(text)
				}
				v[p] = v7
				value:Add(p, v7)

				if startTicking ~= nil then
					object:Delay(0, startTicking)
				end
			else
				v4.Value:Set(value2)
				v4.Dim:Set(v6)
				v4.Tint:Set(tint)
				v4.Text:Set(text)
			end
		elseif v4 ~= nil then
			v[p] = nil
			value:Remove(p)
			v4.Value:Destroy()
			v4.Dim:Destroy()
			v4.Tint:Destroy()
			v4.Text:Destroy()
		end
	end

	local v3 = {}

	for _, statKey in StatTypes.StatKeys do
		local v4 = statKey
		table.insert(v3, PlayerStatResolver.Attach(localPlayer, statKey, function(p)
			put(v4, p)
		end))
	end

	local function registered(p: string)
		return BunchaIcons.StatsAndDebuffs[p] ~= nil
	end

	table.insert(v3, PlayerStatResolver.AttachActiveStatEvents(localPlayer, {
		Added = function(p, p2)
			if StatTypes.StatKeyLookup[p] or BunchaIcons.StatsAndDebuffs[p] == nil then
				return
			end

			put(p, p2)
		end,
		Changed = function(p, p2)
			if StatTypes.StatKeyLookup[p] or BunchaIcons.StatsAndDebuffs[p] == nil then
				return
			end

			put(p, p2)
		end,
		Removed = function(p)
			if StatTypes.StatKeyLookup[p] then
				return
			end

			local v4 = v[p]
			isMultiplier(p)

			if v4 ~= nil then
				v[p] = nil
				value:Remove(p)
				v4.Value:Destroy()
				v4.Dim:Destroy()
				v4.Tint:Destroy()
				v4.Text:Destroy()
			end
		end
	}))
	local color5 = Color3.new(1, 1, 1)
	local flag = false
	local v4 = {}

	local function markClock(p: string)
		local child = ReplicatedStorage.Player_Service.Values:FindFirstChild(localPlayer.Name)

		if child == nil then
			return nil, false
		end

		local statToAttribute = StatTypes.StatToAttribute(p)
		local v5 = nil
		local v6 = false

		for _, child2 in child:GetChildren() do
			if not (child2:HasTag(StatTypes.ValueStatTag) and child2:GetAttribute(statToAttribute) == true) then
				continue
			end

			v6 = true
			local _Started = child2:GetAttribute("_Started")
			local _Duration = child2:GetAttribute("_Duration")

			if typeof(_Started) ~= "number" or typeof(_Duration) ~= "number" or _Duration <= 0 then
				continue
			end

			local v7 = _Started + _Duration - workspace:GetServerTimeNow()

			if v7 > 0 and (v5 == nil or v5 < v7) then
				v5 = v7
			end
		end

		return v5, v6
	end

	local function refreshClocks()
		local v5 = {}
		local v6 = false

		for k in v do
			table.insert(v5, k)
		end

		for _, v7 in v5 do
			local v8, v9 = markClock(v7)
			v6 = v9 and true or v6

			if v8 == nil then
				if v4[v7] then
					v4[v7] = nil
					put(v7, PlayerStatResolver.GetStat(localPlayer, v7))
				end
			else
				v4[v7] = true
				put(v7, v8, {
					Text = Utility.formatTime(v8),
					Tint = color5
				})
			end
		end

		return v6
	end

	local function refreshWindows()
		local v5 = refreshClocks()

		for _, kind in Multipliers.Kinds do
			for _, v6 in kind do
				local value2 = Multipliers.GetValue(v6)
				local displayName = Multipliers.DisplayName(v6)

				if value2.Status then
					if value2.Remaining > 0 then
						put(displayName, value2.Remaining, {
							Text = `{Utility.formatTime(value2.Remaining)} ({displayName})`,
							Tint = color5
						})
						v5 = true
					else
						local v8 = {
							Text = `Active ({displayName})`,
							Tint = color5
						}
						put(displayName, 1e999, v8)
					end
				else
					local v7 = v[displayName]
					isMultiplier(displayName)

					if v7 ~= nil then
						v[displayName] = nil
						value:Remove(displayName)
						v7.Value:Destroy()
						v7.Dim:Destroy()
						v7.Tint:Destroy()
						v7.Text:Destroy()
					end
				end
			end
		end

		return v5
	end

	local tick

	tick = function()
		if refreshWindows() then
			object:Delay(1, tick)
		else
			flag = false
		end
	end

	startTicking = function()
		if flag then
			return
		end

		flag = true

		if refreshWindows() then
			object:Delay(1, tick)
		else
			flag = false
		end
	end

	for _, kind in Multipliers.Kinds do
		for _, v5 in kind do
			local connection2 = Multipliers.Changed(v5):Connect(startTicking)
			table.insert(v3, function()
				connection2:Disconnect()
			end)
		end
	end

	local child = ReplicatedStorage.Player_Service.Values:FindFirstChild(localPlayer.Name)

	if child ~= nil then
		local childAddedConnection = child.ChildAdded:Connect(startTicking)
		table.insert(v3, function()
			childAddedConnection:Disconnect()
		end)
	end

	startTicking()
	local padding = object:Value(paddingFor())
	object:Connect(Platform_Handler.Platform.Changed.Event, function()
		padding:Set(paddingFor())
	end)
	return object:Create("Frame")({
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(1.05, 1),
		Size = UDim2.fromScale(1.8, 0.55),
		BackgroundTransparency = 1,
		OnClean = function()
			for _, v5 in v3 do
				v5()
			end
		end,
		object:Create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = padding,
			Wraps = true
		}),
		object:AdvancedIterate(value, function(p, p2, p3)
			return StatRow(p3, p, p2)
		end)
	})
end