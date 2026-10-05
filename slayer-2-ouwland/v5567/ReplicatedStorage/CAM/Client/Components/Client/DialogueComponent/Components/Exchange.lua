local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Crafting = require(ReplicatedStorage.CAM.Global.Crafting)
local Series = require(ReplicatedStorage.CAM.Global.Series)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Row = require(script.Row)
local info = faye.Info(0.45)
local uDim = UDim2.fromScale(0, 0.04)
return function()
	return function(object, parent, _, p2)
		local materials = Series.Materials()
		local owned = {}
		local data = Utility.GetData(Players.LocalPlayer)

		if data ~= nil then
			for _, v2 in Utility.HeldEntries(data) do
				if not (table.find(materials, v2.Name) ~= nil and Crafting.Spendable(v2, v2.Name)) then
					continue
				end

				local amount = v2:FindFirstChild("Amount")
				owned[v2.Name] = (owned[v2.Name] or 0) + (amount == nil and 1 or amount.Value)
			end
		end

		local exchange = typeof(p2.Exchange) ~= "table" and {} or p2.Exchange
		p2.Exchange = exchange

		if exchange.Give ~= nil and owned[exchange.Give] == nil then
			exchange.Give = nil
		end

		if exchange.Take ~= nil and table.find(materials, exchange.Take) == nil then
			exchange.Take = nil
		end

		local amount2

		if exchange.Give ~= nil then
			amount2 = math.clamp(exchange.Amount or 1, 1, owned[exchange.Give])
		end

		exchange.Amount = amount2
		local picked = object:Value(exchange.Give)
		local picked2 = object:Value(exchange.Take)
		local amount3 = object:Value(exchange.Amount or 1)
		local v6 = object:Create("CanvasGroup")
		local v7 = {
			Parent = parent,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			GroupTransparency = object:Animation(0, info, {
				From = 1
			}),
			Position = object:Animation(UDim2.fromScale(0, 0), info, {
				From = uDim
			}),
			OnClean = function(object2)
				return {
					GroupTransparency = object2:Animation(1, info),
					Position = object2:Animation(uDim, info)
				}
			end
		}
		local v8 = object:Create("Frame")
		local v9 = {
			Name = "ExchangeFrame",
			CleanDelay = info.Time,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.96)
		}
		local size

		if Platform_Handler.Platform.Value == "Mobile" then
			size = UDim2.fromScale(0.5, 0.31)
		else
			size = UDim2.fromScale(0.6, 0.5)
		end

		v9.Size = size
		v9[1], v9[2] = object:Create("UIAspectRatioConstraint")({
	AspectRatio = 2.5
}), (object:Create("UICorner")({
	CornerRadius = UDim.new(0.025)
}))
		v9.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
		do local _values = table.pack(object:Create("UIGradient")({
	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 0.4) }),
	Rotation = 90
}), object:Create("Frame")({
	Name = "Holder",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.96, 0.92),
	BackgroundTransparency = 1,
	object:Create("UIListLayout")({
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0.04)
	}),
	Row(object, 1, "Give", materials, {
		Picked = picked,
		Owned = owned,
		Pick = function(p3)
			if exchange.Take == p3 then
				exchange.Take = nil
				picked2:Set(nil)
			end

			local exchange2 = exchange
			local give

			if exchange.Give ~= p3 then
				give = p3
			end

			exchange2.Give = give
			local exchange3 = exchange
			local amount

			if exchange.Give ~= nil then
				amount = math.min(amount3.Value, owned[p3])
			end

			exchange3.Amount = amount
			picked:Set(exchange.Give)
			amount3:Set(exchange.Amount or 1)
		end,
		Editor = {
			Amount = amount3,
			Step = function(p3)
				if exchange.Give == nil then
					return
				end

				exchange.Amount = math.clamp(exchange.Amount + p3, 1, owned[exchange.Give])
				amount3:Set(exchange.Amount)
			end
		}
	}),
	Row(object, 2, "Receive", materials, {
		Picked = picked2,
		Pick = function(take)
			if exchange.Give == take then
				local exchange2 = exchange
				exchange.Give = nil
				exchange2.Amount = nil
				picked:Set(nil)
			end

			local exchange3 = exchange

			if exchange.Take == take then
				take = nil
			end

			exchange3.Take = take
			picked2:Set(exchange.Take)
		end
	})
})); for _k = 1, _values.n do v9[2 + _k] = _values[_k] end end
		do local _values = table.pack(v8(v9)); for _k = 1, _values.n do v7[_k] = _values[_k] end end
		return v6(v7)
	end
end