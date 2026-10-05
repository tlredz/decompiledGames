local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AdService = game:GetService("AdService")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local faye = require(ReplicatedStorage.Packages.faye)
local v = RunService:IsStudio() and not RunService:IsRunning()
local item = gameSettings.SellRobuxPayout.Item
local image = not Items[item] and "" or Items[item].Icon or ""
local color = Color3.new(0.85, 0.85, 0.85)
local color2 = Color3.new(1, 1, 1)
local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.6) })
local color3 = Color3.new(0.1, 0.1, 0.1)
local color4 = Color3.new(0.55, 0.55, 0.55)
local color5 = Color3.new(1, 1, 1)
local color6 = Color3.new(1, 1, 1)
local color7 = Color3.fromRGB(255, 95, 95)
local info = faye.Info(0.2)
local v3 = {
	NoData = "Your data is still loading, try again in a moment",
	NoSave = "Ads can't be watched in this server",
	Busy = "An ad is already playing",
	AdAlreadyShowing = "An ad is already playing",
	DailyCap = "You've watched every ad for today, come back tomorrow",
	AdNotReady = "No ad is ready for you right now, try again later",
	ShowInterrupted = "The ad was closed before it finished",
	InsufficientMemory = "Your device ran low on memory, try again later",
	InternalError = "Roblox couldn't play the ad, try again later",
	Failed = "Roblox couldn't play the ad, try again later"
}
local color8 = Color3.fromRGB(255, 80, 80)
local flag = false

local function uiScale(parent)
	local v4 = 1

	while parent ~= nil and not parent:IsA("LayerCollector") do
		local uIScale = parent:FindFirstChildOfClass("UIScale")

		if uIScale ~= nil and uIScale.Scale > 0 then
			v4 *= uIScale.Scale
		end

		parent = parent.Parent
	end

	return v4
end

local function checkAvailable()
	if v then
		return true
	end

	local success, result = pcall(function()
		return AdService:GetAdAvailabilityNowAsync(Enum.AdFormat.RewardedVideo)
	end)

	if success then
		if result == nil then
			success = false
		else
			success = result.AdAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable
		end
	end

	return success
end

return function(object, p)
	local v4 = (p == nil or p.Align ~= "Right") and 0 or 1
	local localPlayer = Players.LocalPlayer
	local data, v5 = Utility.GetData(localPlayer)
	local rewardedAds

	if v5 == nil then
		rewardedAds = nil
	else
		rewardedAds = v5:FindFirstChild("RewardedAds") or nil
	end

	local function adsValue(childName: string)
		local child = rewardedAds ~= nil and rewardedAds:FindFirstChild(childName) or nil

		if child == nil then
			return (object:Value(0))
		end

		return (object:InstancePropertySync(child, "Value"))
	end

	local shards

	if rewardedAds ~= nil then
		shards = rewardedAds:FindFirstChild("Shards") or nil
	end

	local v6

	if shards == nil then
		v6 = object:Value(0)
	else
		v6 = object:InstancePropertySync(shards, "Value")
	end

	local day

	if rewardedAds ~= nil then
		day = rewardedAds:FindFirstChild("Day") or nil
	end

	local v7

	if day == nil then
		v7 = object:Value(0)
	else
		v7 = object:InstancePropertySync(day, "Value")
	end

	local watched

	if rewardedAds ~= nil then
		watched = rewardedAds:FindFirstChild("Watched") or nil
	end

	local v8

	if watched == nil then
		v8 = object:Value(0)
	else
		v8 = object:InstancePropertySync(watched, "Value")
	end

	local function oreHeld()
		local v9 = data ~= nil and Utility.HeldItem(data, item) or nil
		local amount

		if v9 ~= nil then
			amount = v9:FindFirstChild("Amount") or nil
		end

		if v9 == nil then
			return 0
		end

		if amount == nil then
			return 1
		end

		return (math.floor(amount.Value))
	end

	local v9

	if data ~= nil then
		v9 = Utility.HeldItem(data, item) or nil
	end

	local amount

	if v9 ~= nil then
		amount = v9:FindFirstChild("Amount") or nil
	end

	local value = object:Value(v9 == nil and 0 or amount == nil and 1 or math.floor(amount.Value))
	local v10

	if data ~= nil then
		v10 = Utility.ItemBag(data, item) or nil
	end

	if v10 ~= nil then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function bump()
			local v12

			if data ~= nil then
				v12 = Utility.HeldItem(data, item) or nil
			end

			local amount2

			if v12 ~= nil then
				amount2 = v12:FindFirstChild("Amount") or nil
			end

			value:Set(v12 == nil and 0 or amount2 == nil and 1 or math.floor(amount2.Value))
		end

		local function watchStack(instance)
			if instance.Name ~= item then
				return
			end

			bump() -- equivalent call inferred; original call site unknown
			local amount2 = instance:FindFirstChild("Amount")

			if amount2 ~= nil then
				object:Connect(amount2.Changed, bump)
			end
		end

		local child = v10:FindFirstChild(item)

		if child ~= nil and child.Name == item then
			local v11

			if data ~= nil then
				v11 = Utility.HeldItem(data, item) or nil
			end

			local amount2

			if v11 ~= nil then
				amount2 = v11:FindFirstChild("Amount") or nil
			end

			value:Set(v11 == nil and 0 or amount2 == nil and 1 or math.floor(amount2.Value))
			local amount3 = child:FindFirstChild("Amount")

			if amount3 ~= nil then
				object:Connect(amount3.Changed, bump)
			end
		end

		object:Connect(v10.ChildAdded, watchStack)
		object:Connect(v10.ChildRemoved, function(p2)
			if p2.Name == item then
				bump() -- equivalent call inferred; original call site unknown
			end
		end)
	end

	local visible = object:Value(false)
	local value3 = object:Value(false)
	task.spawn(function()
		local success

		if v then
			success = true
		else
			local result
			success, result = pcall(function()
				return AdService:GetAdAvailabilityNowAsync(Enum.AdFormat.RewardedVideo)
			end)

			if success then
				if result == nil then
					success = false
				else
					success = result.AdAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable
				end
			end
		end

		if not object.IsActive then
			return
		end

		visible:Set(success)
	end)
	local value4 = object:Value((math.floor((workspace:GetServerTimeNow()))))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function capped(callback)
		return callback(v7) == callback(value4) // 86400 and callback(v8) >= gameSettings.RewardedAds.DailyCap
	end

	local function usable(callback)
		local v11 = callback(visible)
		return v11 and not capped(callback)
	end

	local function fn(p2)
		return p2.Value
	end

	local v11 = false

	local function tick()
		value4:Set((math.floor((workspace:GetServerTimeNow()))))

		if not v11 then
			local v12

			if v7.Value == value4.Value // 86400 then
				v12 = v8.Value >= gameSettings.RewardedAds.DailyCap
			else
				v12 = false
			end

			if v12 then
				v11 = true
				task.spawn(function()
					while object.IsActive do
						local v13

						if v7.Value == value4.Value // 86400 then
							if v8.Value >= gameSettings.RewardedAds.DailyCap then
								v13 = true
							else
								v13 = false
							end
						else
							v13 = false
						end

						if not v13 then
							break
						end

						task.wait(1 - workspace:GetServerTimeNow() % 1)
						value4:Set((math.floor((workspace:GetServerTimeNow()))))
					end

					v11 = false
				end)
			end
		end
	end

	object:Connect(v7.Changed, tick)
	object:Connect(v8.Changed, tick)
	tick()
	local textSize = object:Value(14)
	local textSize2 = object:Value(12)
	local value7 = object:Value(0)
	local value8 = object:Value(0)
	local value9 = object:Value(0)
	local padding = object:Value(UDim.new())
	local padding2 = object:Value(UDim.new())

	local function ink(callback)
		local v13 = callback(visible)

		if v13 then
			v13 = not capped(callback)
		end

		local v14

		if v13 then
			v14 = 0
		else
			v14 = capped(callback) and 0 or 0.5
		end

		return object:Animation(v14, info)
	end

	local function inkColor(callback)
		local v13

		if callback(v7) == callback(value4) // 86400 then
			v13 = callback(v8) >= gameSettings.RewardedAds.DailyCap
		else
			v13 = false
		end

		local v14

		if v13 then
			v14 = color5
		else
			v14 = color3
		end

		return object:Animation(v14, info)
	end

	local function request()
		if flag then
			return
		end

		flag = true
		ScreenEffects.CircleClick()

		if PopUpCreator.new({
			Type = "Question",
			Content = "You are about to watch an ad, proceed?"
		}):WaitResult() ~= "Yes" then
			flag = false
			return
		end

		local v12 = PopUpCreator.new({
			Type = "LoadingFull"
		})
		local success, result, v13 = pcall(SignalFunction.ToServer, "WatchRewardedAd")
		v12:Destroy()
		flag = false

		if success and result == true then
			return
		end

		PopUpCreator.new({
			Type = "BigMessage",
			Content = "Request unsuccessful",
			Color = color8,
			Subtext = (not success or typeof(v13) ~= "string") and "Something went wrong, try again later" or v3[v13] or "Something went wrong, try again later"
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function notCapped(callback)
		return not capped(callback)
	end

	local v12 = object:Create("Frame")
	local v13 = {
		Name = "AdForOre",
		Visible = visible,
		Size = object:Do(function(callback)
			return UDim2.new(0, math.max(callback(value7) + callback(value9) * 2, callback(value8)), 1, 0)
		end),
		AnchorPoint = Vector2.new(v4, 0),
		Position = UDim2.fromScale(v4, 0),
		BackgroundTransparency = 1,
		AbsoluteSizeOnChangedInit = function(p2, point: Vector2)
			local v14 = point.Y / uiScale(p2)
			local v15 = v14 * 0.62
			textSize:Set((math.max(math.floor(v15 * 0.5), 1)))
			textSize2:Set((math.max(math.floor(v14 * 0.3 * 1.35), 1)))
			value9:Set((math.floor(v15 * 0.45)))
			padding:Set(UDim.new(0, (math.floor(v15 * 0.27))))
			padding2:Set(UDim.new(0, (math.floor(v15 * 0.13))))
		end
	}
	local v14 = object:Create("Frame")
	local v15 = {
		Name = "Balance",
		Size = UDim2.fromScale(1, 0.3),
		BackgroundTransparency = 1
	}
	local v16 = object:Create("UIListLayout")
	local v17 = {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = 0,
		VerticalAlignment = 0,
		Padding = 0,
		AbsoluteContentSizeOnChangedInit = 0
	}
	local horizontalAlignment

	if v4 == 1 then
		horizontalAlignment = Enum.HorizontalAlignment.Right
	else
		horizontalAlignment = Enum.HorizontalAlignment.Left
	end

	v17.HorizontalAlignment = horizontalAlignment
	v17.VerticalAlignment = Enum.VerticalAlignment.Center
	v17.Padding = padding2

	function v17.AbsoluteContentSizeOnChangedInit(p2)
		value8:Set(p2.AbsoluteContentSize.X / uiScale(p2))
	end

	do local _values = table.pack(v16(v17), object:Create("TextLabel")({
	Name = "Amount",
	LayoutOrder = 1,
	Size = UDim2.fromScale(0, 1),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundTransparency = 1,
	Text = object:Do(function(callback)
		local v19

		if callback(v7) == callback(value4) // 86400 then
			v19 = callback(v8) >= gameSettings.RewardedAds.DailyCap
		else
			v19 = false
		end

		if v19 then
			return "Ads are on cooldown"
		end

		local v20 = callback(value)
		return (`{Utility.addCommasToNumber(v20)} {v20 == 1 and "Ore" or "Ores"}`)
	end),
	TextColor3 = object:Do(function(callback)
		local v20

		if callback(v7) == callback(value4) // 86400 then
			v20 = callback(v8) >= gameSettings.RewardedAds.DailyCap
		else
			v20 = false
		end

		local v21

		if v20 then
			v21 = color7
		else
			v21 = color6
		end

		return object:Animation(v21, info)
	end),
	TextSize = textSize2,
	Font = Enum.Font.SourceSansBold
}), object:Create("ImageLabel")({
	Name = "Icon",
	LayoutOrder = 2,
	Visible = object:Do(notCapped),
	Size = UDim2.fromScale(1, 1),
	SizeConstraint = Enum.SizeConstraint.RelativeYY,
	BackgroundTransparency = 1,
	Image = image,
	ScaleType = Enum.ScaleType.Fit,
	object:Create("UIShadow")({
		BlurRadius = UDim.new(0.8, 0),
		Transparency = 0.7
	})
})); for _k = 1, _values.n do v15[_k] = _values[_k] end end
	do local _values = table.pack(v14(v15), object:Create("TextButton")({
	Name = "Pill",
	Size = UDim2.fromScale(1, 0.62),
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0, 1),
	BackgroundColor3 = object:Do(function(callback)
		local v19

		if callback(v7) == callback(value4) // 86400 then
			v19 = callback(v8) >= gameSettings.RewardedAds.DailyCap
		else
			v19 = false
		end

		local v20

		if v19 then
			v20 = color4
		else
			local v21 = callback(visible)

			if v21 then
				v21 = notCapped(callback)
			end

			if v21 and callback(value3) then
				v20 = color2
			else
				v20 = color
			end
		end

		return object:Animation(v20, info)
	end),
	BackgroundTransparency = object:Do(function(callback)
		local v20 = callback(visible)

		if v20 then
			v20 = notCapped(callback)
		end

		local v21

		if v20 then
			v21 = 0.1
		else
			v21 = capped(callback) and 0.1 or 0.5
		end

		return object:Animation(v21, info)
	end),
	AutoButtonColor = false,
	MouseButton1Click = function()
		local value12 = visible.Value

		if value12 then
			value12 = v7.Value ~= value4.Value // 86400 or not (v8.Value >= gameSettings.RewardedAds.DailyCap)
		end

		if not value12 then
			return
		end

		task.spawn(request)
	end,
	MouseEnter = function()
		if not value3:Compare(true) then
			value3:Set(true)
		end
	end,
	MouseLeave = function()
		if value3:Compare(true) then
			value3:Set(false)
		end
	end,
	object:Create("UICorner")({
		CornerRadius = UDim.new(1)
	}),
	object:Create("UIGradient")({
		Transparency = numberSequence,
		Rotation = -90
	}),
	object:Create("UIShadow")({
		Color = Color3.new(0.25, 0.25, 0.25),
		BlurRadius = UDim.new(0.8, 0),
		Transparency = 0.6
	}),
	object:Create("Frame")({
		Name = "Row",
		Size = object:Do(function(callback)
			return UDim2.new(1, -callback(value9) * 2, 1, 0)
		end),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = padding,
			AbsoluteContentSizeOnChangedInit = function(p2)
				value7:Set(p2.AbsoluteContentSize.X / uiScale(p2))
			end
		}),
		object:Create("ImageLabel")({
			Name = "Glyph",
			LayoutOrder = 1,
			Visible = object:Do(notCapped),
			Size = UDim2.fromScale(0.4, 0.4),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			Image = BunchaIcons.ServerBrowser.Arrow,
			ImageColor3 = color3,
			ImageTransparency = object:Do(ink),
			ScaleType = Enum.ScaleType.Fit
		}),
		object:Create("TextLabel")({
			Name = "Label",
			LayoutOrder = 2,
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Text = object:Do(function(callback)
				local v19

				if callback(v7) == callback(value4) // 86400 then
					v19 = callback(v8) >= gameSettings.RewardedAds.DailyCap
				else
					v19 = false
				end

				if v19 then
					return Utility.formatTimeUnits(86400 - callback(value4) % 86400, " ")
				end

				return "Watch ad"
			end),
			TextColor3 = object:Do(inkColor),
			TextTransparency = object:Do(ink),
			TextSize = textSize,
			Font = Enum.Font.SourceSansBold
		}),
		object:Create("Frame")({
			Name = "Progress",
			LayoutOrder = 3,
			Visible = object:Do(notCapped),
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = padding2
			}),
			object:Create("ImageLabel")({
				Name = "Ore",
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.6, 0.6),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1,
				Image = image,
				ImageTransparency = object:Do(ink),
				ScaleType = Enum.ScaleType.Fit
			}),
			object:Create("TextLabel")({
				Name = "Count",
				LayoutOrder = 2,
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Text = object:Do(function(callback)
					return (`{math.floor((callback(v6)))}/{gameSettings.RewardedAds.ShardsPerOre}`)
				end),
				TextColor3 = color3,
				TextTransparency = object:Do(ink),
				TextSize = textSize,
				Font = Enum.Font.SourceSansSemibold
			})
		})
	})
})); for _k = 1, _values.n do v13[_k] = _values[_k] end end
	return v12(v13)
end