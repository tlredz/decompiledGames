local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local SpinBuyComponent = require(script.Parent.SpinBuyComponent)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local SpinBalance = require(ReplicatedStorage.CAM.Global.SpinBalance)
local Spinners = require(ReplicatedStorage.CAM.Global.Spinners)
local Clans = require(ReplicatedStorage.CAM.Clans)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
require(ReplicatedStorage.Packages.faye)
local Policies = require(ReplicatedStorage.CAM.Global.Policies)
local localPlayer = Players.LocalPlayer
local color = Color3.fromRGB(85, 170, 255)
local v = {
	Legendary = true,
	Mythic = true,
	Supreme = true
}
local color2 = Color3.fromRGB(150, 150, 155)
return function(object, isClan: boolean, p, p2)
	local listingsOfType = Shop.ListingsOfType(Menum.ShopItemType.Spins, "Spins")
	local cost

	if isClan then
		cost = Spinners.Clan.Cost
	else
		cost = Spinners.EvilArt.Cost
	end

	local data = Utility.GetData(localPlayer, true)
	local spinning = data:FindFirstChild("Spinning")
	local freeClanSpins

	if isClan then
		freeClanSpins = spinning.FreeClanSpins
	else
		freeClanSpins = spinning.FreeOtherSpins
	end

	local function canAfford(callback)
		local total = 0

		for _, v2 in SpinBalance.Values(data, isClan) do
			total += callback(v2)
		end

		return cost <= total
	end

	local value = object:Value(false)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function totalSpins()
		return SpinBalance.Total(data, isClan)
	end

	local v2 = totalSpins() -- equivalent call inferred; original call site unknown
	local value2 = object:Value(v2)
	local v3 = 0
	local UpdValue

	UpdValue = function(p3: number)
		local v4 = math.random(1, 999)
		v3 = v4

		if p3 ~= 0 then
			local v5 = math.sign(p3)
			v2 += math.max(math.floor(math.abs(p3) * 0.5), 1) * v5
		end

		value2:Set(v2)

		if v2 ~= SpinBalance.Total(data, isClan) then
			task.delay(0.05, function()
				if v3 ~= v4 or not object.IsActive then
					return
				end

				UpdValue(SpinBalance.Total(data, isClan) - v2)
			end)
		end
	end

	local function onBalanceChanged()
		UpdValue(SpinBalance.Total(data, isClan) - v2)
	end

	for _, v4 in SpinBalance.Values(data, isClan) do
		object:Connect(v4.Changed, onBalanceChanged)
	end

	local text = object:Do(function(callback)
		local total = 0

		for _, v5 in SpinBalance.Values(data, isClan) do
			total += callback(v5)
		end

		if cost <= total then
			return (`Roll · {cost} {cost == 1 and "Spin" or "Spins"}`)
		end

		return "Insufficient Spins"
	end)
	local bgColor = object:Do(function(callback)
		local total = 0

		for _, v6 in SpinBalance.Values(data, isClan) do
			total += callback(v6)
		end

		if cost <= total and not callback(value) then
			return color
		end

		return color2
	end)

	local function equippedTier()
		local data2 = Utility.GetData(localPlayer, true)
		local clan = data2 ~= nil and data2:FindFirstChild("Clan") or nil
		local tierOf = Clans.TierOf
		local v6

		if clan ~= nil then
			v6 = clan.Value or nil
		end

		return tierOf(v6)
	end

	local v6 = false

	local function confirmedReroll()
		if not isClan then
			return true
		end

		local data2 = Utility.GetData(localPlayer, true)
		local clan = data2 ~= nil and data2:FindFirstChild("Clan") or nil
		local tierOf = Clans.TierOf
		local v7

		if clan ~= nil then
			v7 = clan.Value or nil
		end

		local v8 = tierOf(v7)

		if v8 == nil or not v[v8.name] then
			return true
		end

		local clan2 = Utility.GetData(localPlayer, true):FindFirstChild("Clan")
		local hex = v8.color:ToHex()
		v6 = true
		local v9 = PopUpCreator.new({
			Type = "Question",
			Content = `You already have <b><font color="#{hex}">{clan2.Value}</font></b>, a <b><font color="#{hex}">{v8.name}</font></b> clan. Rolling replaces it. Are you sure?`
		}):WaitResult()
		v6 = false
		return v9 == "Yes"
	end

	local function spin()
		if v6 or value.Value == true or isClan and localPlayer:GetAttribute("PendingClanSpin") ~= nil or SpinBalance.Total(
			data,
			isClan
		) < cost then
			return
		end

		value:Set(true)
		task.spawn(function()
			if not confirmedReroll() then
				value:Set(false)
				return
			end

			local v7 = PopUpCreator.new({
				Type = "Spinner",
				IsClan = isClan
			})
			local signalConnection = nil
			signalConnection = PopUpCreator.signal:Connect(function(p3: number, p4)
				if p3 ~= v7.id or p4 ~= nil then
					return
				end

				signalConnection:Disconnect()
				value:Set(false)
			end)
			object:Add(signalConnection)
		end)
	end

	local v7 = 0
	local lastTime = os.clock()

	local function snapToBottom(state)
		if state.Parent == nil or os.clock() - lastTime > 1 and math.abs(state.CanvasPosition.Y - v7) > 4 then
			return
		end

		local v8 = math.max(state.AbsoluteCanvasSize.Y - state.AbsoluteWindowSize.Y, 0)
		state.CanvasPosition = Vector2.new(0, v8)
		v7 = v8
	end

	local v8 = object:Create("Frame")
	local v9 = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Name = "Spinner",
		CleanDelay = p.Time
	}
	local v10

	if not isClan then
		v10 = object:Create("Frame")({
			Name = "gradient",
			Size = UDim2.new(1, 4, 1, 4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.new(),
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.3)
			}),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.5),
					NumberSequenceKeypoint.new(0.5, 1),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Rotation = -90
			}),
			object:Create("UIShadow")({
				BlurRadius = UDim.new(1, 0),
				Transparency = object:Animation(0, p, {
					From = 1
				}),
				OnClean = function(object2)
					return {
						Transparency = object2:Animation(1, p)
					}
				end
			})
		}) or nil
	end

	local v11 = object:Create("CanvasGroup")({
		Size = UDim2.fromScale(1, 1.2),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.55),
		ZIndex = 2,
		BackgroundTransparency = 1,
		object:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.8),
				NumberSequenceKeypoint.new(0.125, 0),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Rotation = -90
		}),
		object:Create("ScrollingFrame")({
			Size = UDim2.fromScale(1, 1),
			ClipsDescendants = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 0,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 1),
				AbsoluteContentSizeOnChangedInit = function(p3, p4)
					local parent = p3.Parent
					parent.CanvasSize = UDim2.fromOffset(0, p4.Y * 1.2)
					task.defer(function()
						snapToBottom(parent)
					end)
				end
			}),
			function(instance)
				object:Connect(instance:GetPropertyChangedSignal("AbsoluteWindowSize"), function()
					task.defer(function()
						snapToBottom(instance)
					end)
				end)
			end,
			object:Iterate(listingsOfType, function(_, p3, p4, _)
				return SpinBuyComponent(p4, p3, p2, p.Time)
			end)
		})
	})
	local v12 = object:Create("Frame")
	local v13 = {
		Name = "Holder",
		Size = UDim2.new(1, -6, 1, -6),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1
	}
	local v14 = object:Create("UIListLayout")({
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom
	})
	local v15 = object:Create("Frame")
	local v16 = {
		Name = "SpinButton",
		Size = UDim2.fromScale(0.7, 0.2),
		BackgroundTransparency = 1
	}
	local v17

	if Policies.CanSpin then
		v17 = GradientButton(object, {
			GradientRotation = -90,
			Text = text,
			BgColor = bgColor,
			Clicked = spin,
			TextXAlignment = Enum.TextXAlignment.Center,
			Properties = {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0)
			},
			GradientTransparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0.5)
			})
		})
	else
		v17 = object:Create("TextLabel")({
			Size = UDim2.fromScale(1.3, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.35),
			BackgroundTransparency = 1,
			TextColor3 = Color3.new(1, 1, 1),
			Text = "Roblox disabled rolling for you",
			TextScaled = true,
			Font = Enum.Font.SourceSansSemibold
		})
	end

	v16[1] = v17
	do local _values = table.pack(v14, v15(v16), object:Create("Frame")({
	Name = "AATitleHolder",
	Size = UDim2.fromScale(1, 0.2),
	BackgroundTransparency = 1,
	object:Create("TextLabel")({
		Size = UDim2.fromScale(1, 0.8),
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.SourceSans,
		TextScaled = true,
		RichText = true,
		object:Create("UIStroke")({
			Transparency = 0.8
		}),
		object:Create("UIShadow")({
			BlurRadius = UDim.new(1, 0),
			Transparency = object:Animation(0.4, p, {
				From = 1
			}),
			OnClean = function(object2)
				return {
					Transparency = object2:Animation(1, p)
				}
			end
		}),
		Text = object:Do(function(callback, _, _)
			local v18 = callback(freeClanSpins)
			return (`<b>{callback(value2)} Spins</b> {v18 > 0 and `<font transparency=".5">( {v18} Free )</font>` or ""}`)
		end),
		function(parent)
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "SpinsIcon"
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = BunchaIcons.SpinsIcon
			imageLabel.AnchorPoint = Vector2.new(1, 0.5)
			imageLabel.Parent = parent

			local function place()
				local v18 = math.floor(parent.AbsoluteSize.Y * 0.9)
				imageLabel.Size = UDim2.fromOffset(v18, v18)
				imageLabel.Position = UDim2.new(0.5, -math.ceil(parent.TextBounds.X / 2) - 3, 0.5, 0)
			end

			object:Connect(parent:GetPropertyChangedSignal("TextBounds"), place)
			object:Connect(parent:GetPropertyChangedSignal("AbsoluteSize"), place)
			task.defer(place)
		end
	})
})); for _k = 1, _values.n do v13[_k] = _values[_k] end end
	do local _values = table.pack(v10, v11, v12(v13)); for _k = 1, _values.n do v9[_k] = _values[_k] end end
	return v8(v9)
end