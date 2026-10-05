local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Crafting = require(ReplicatedStorage.CAM.Global.Crafting)
local Series = require(ReplicatedStorage.CAM.Global.Series)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local TransferPair = require(ReplicatedStorage.CAM.Client.Components.Misc.TransferPair)
local Footer = require(script.Parent.Footer)
local Header = require(script.Parent.Header)
local MaterialTile = require(script.Parent.MaterialTile)
local info = faye.Info(0.25, Enum.EasingStyle.Back)
local uDim = UDim2.fromScale(0.9, 0.9)
local color = Color3.new(1, 0.803922, 0.305882)
local TierTransfer = {
	Offered = function(p: string?)
		for _, v in Crafting.ForStation(p) do
			if v.requiredTier ~= nil then
				return true
			end
		end

		return false
	end,
	new = function(object, station: string?)
		local data = Utility.GetData(Players.LocalPlayer)
		local tick = object:Value(0)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bump()
			tick:Set(tick.Value + 1)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function watch(valueBase)
			if valueBase:IsA("ValueBase") and (valueBase.Name == "Amount" or valueBase.Name == "Tier") then
				object:Connect(valueBase.Changed, bump)
			end
		end

		for _, v in Utility.ItemBags(data) do
			for _, v2 in { "#Amount", "#Tier" } do
				for _, v3 in v:QueryDescendants(v2) do
					watch(v3) -- equivalent call inferred; original call site unknown
				end
			end

			object:Connect(v.DescendantAdded, function(valueBase)
				watch(valueBase) -- equivalent call inferred; original call site unknown
				bump() -- equivalent call inferred; original call site unknown
			end)
			object:Connect(v.ChildRemoved, bump)
		end

		object:Connect(data.Wen.Changed, bump)

		for _, v in { data.Inventory.Toolbar, data.Inventory.Accessories.Stats, data.Inventory.Accessories.Vanity } do
			for _, valueBase in v:GetChildren() do
				if valueBase:IsA("ValueBase") then
					object:Connect(valueBase.Changed, bump)
				end
			end
		end

		local v = 1
		local value2 = 0

		for _, v2 in Utility.HeldEntries(data) do
			local id = v2:FindFirstChild("Id")

			if not (id ~= nil and Crafting.Spendable(v2, v2.Name) and v < Series.TierOf(v2)) then
				continue
			end

			value2 = id.Value
			v = Series.TierOf(v2)
		end

		local v2 = {
			Data = data,
			Station = station,
			From = object:Value(value2),
			To = object:Value(0),
			Step = object:Value(value2 == 0 and "From" or "To"),
			Busy = object:Value(false),
			Tick = tick
		}
		object:Connect(v2.From.Changed, function()
			v2.To:Set(0)

			if v2.From:Get() ~= 0 then
				v2.Step:Set("To")
			end
		end)
		return v2
	end
}

local function read(data, callback)
	callback(data.Tick)
	local v = {}

	for _, v2 in {
		data.Data.Inventory.Toolbar,
		data.Data.Inventory.Accessories.Stats,
		data.Data.Inventory.Accessories.Vanity
	} do
		for _, valueBase in v2:GetChildren() do
			if valueBase:IsA("ValueBase") and valueBase.Value ~= 0 then
				v[valueBase.Value] = true
			end
		end
	end

	local v2 = {}

	for _, v3 in Utility.HeldEntries(data.Data) do
		local id = v3:FindFirstChild("Id")

		if not (id ~= nil and Crafting.Spendable(v3, v3.Name) and Series.SetOf(v3.Name) ~= nil) then
			continue
		end

		table.insert(v2, {
			Name = v3.Name,
			Id = id.Value,
			Tier = Series.TierOf(v3),
			Equipped = v[id.Value] == true
		})
	end

	table.sort(v2, function(a, b)
		if a.Tier ~= b.Tier then
			return a.Tier > b.Tier
		end

		if a.Name == b.Name then
			return a.Id < b.Id
		end

		return a.Name < b.Name
	end)
	local v3 = callback(data.From)
	local v4 = callback(data.To)
	local result = {
		FromRows = {},
		ToRows = {}
	}

	for _, from2 in v2 do
		if from2.Tier < 2 then
			continue
		end

		table.insert(result.FromRows, {
			result = from2.Name,
			tier = from2.Tier,
			id = tostring(from2.Id)
		})

		if from2.Id == v3 then
			result.From = from2
		end
	end

	local from = result.From

	if from == nil then
		return result
	end

	for _, to in v2 do
		if to.Tier >= from.Tier then
			continue
		end

		local tierUp = Crafting.TierUp(to.Name, from.Tier)

		if not (tierUp ~= nil and (data.Station == nil or tierUp.station == data.Station)) then
			continue
		end

		local tierTransferFee = Crafting.TierTransferFee(from.Name, to.Name, to.Tier, from.Tier)

		if tierTransferFee == nil then
			continue
		end

		table.insert(result.ToRows, {
			result = to.Name,
			tier = to.Tier,
			id = tostring(to.Id)
		})

		if to.Id ~= v4 then
			continue
		end

		result.To = to
		result.Fee = tierTransferFee
	end

	return result
end

function TierTransfer.Pick(p, callback)
	local v = read(p, callback)
	local step = callback(p.Step) == "To" and v.From ~= nil and "To" or "From"
	local to

	if step == "To" then
		to = v.To
	else
		to = v.From
	end

	local rows

	if step == "To" then
		rows = v.ToRows
	else
		rows = v.FromRows
	end

	return {
		Step = step,
		Rows = rows,
		Picked = to == nil and "" or tostring(to.Id)
	}
end

function TierTransfer.View(object, data)
	local data2 = data.Data

	local function owned(_, p: string)
		return Crafting.Held(Utility.ItemBag(data2, p), p)
	end

	return object:Create("Frame")({
		Name = "TierTransfer",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Size = UDim2.new(0.65, -18, 1, -12),
		BackgroundTransparency = 1,
		object:Create("Frame")({
			Name = "Holder",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = object:Animation(UDim2.fromScale(1, 1), info, {
				From = uDim
			}),
			BackgroundTransparency = 1,
			Header(object, "Tier Transfer", "The two pieces swap tiers", color),
			object:State(function(p, object2)
				local v = read(data, p)
				local from = v.From
				local to = v.To
				local v2 = {}
				local v3 = false
				local priceLines = {}

				for k, amount in v.Fee or {} do
					if k == "Wen" then
						table.insert(priceLines, {
							Currency = "Wen",
							Amount = amount
						})
						v3 = v3 or not Shop.cashiers.Wen.CanBuy(data2, amount)
					else
						table.insert(v2, {
							name = k,
							amount = amount
						})
						v3 = v3 or Crafting.Held(Utility.ItemBag(data2, k), k) < amount
					end
				end

				table.sort(v2, function(a, b)
					return a.name < b.name
				end)
				local v5

				if from == nil then
					v5 = "Pick a piece"
				elseif to == nil then
					v5 = "Pick a Target"
				elseif from.Equipped or to.Equipped then
					v5 = "Unequip first"
				elseif v3 then
					v5 = "Can't afford"
				else
					v5 = nil
				end

				local v6 = object2:Create("Frame")
				local v7 = {
					Name = "Body",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1
				}
				local v8

				if from ~= nil then
					v8 = object2:Create("Frame")({
						Name = "Pair",
						Position = UDim2.fromScale(0, 0.155),
						Size = UDim2.fromScale(1, 0.42),
						BackgroundTransparency = 1,
						TransferPair(object2, {
							Name = from.Name,
							Now = `Tier {from.Tier}`,
							After = to == nil and "?" or `Tier {to.Tier}`,
							Gains = false
						}, to ~= nil and {
							Name = to.Name,
							Now = `Tier {to.Tier}`,
							After = `Tier {from.Tier}`,
							Gains = true
						} or nil, "Pick a Target")
					})
				end

				local v9

				if #v2 > 0 then
					v9 = object2:Create("Frame")({
						Name = "Additional",
						Position = UDim2.fromScale(0, 0.6),
						Size = UDim2.fromScale(1, 0.26),
						BackgroundTransparency = 1,
						object2:Create("TextLabel")({
							Name = "Label",
							Size = UDim2.fromScale(1, 0.19),
							BackgroundTransparency = 1,
							Font = Enum.Font.SourceSansSemibold,
							Text = "Additional Materials",
							TextColor3 = Color3.new(1, 1, 1),
							TextTransparency = 0.25,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left
						}),
						object2:Create("Frame")({
							Name = "Strip",
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.fromScale(0, 1),
							Size = UDim2.fromScale(1, 0.76),
							BackgroundTransparency = 1,
							object2:Create("UIListLayout")({
								FillDirection = Enum.FillDirection.Horizontal,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								Padding = UDim.new(0, 4)
							}),
							object2:Iterate(v2, function(_, p2, p3)
								return MaterialTile(p3, p2, owned)
							end)
						})
					})
				end

				do local _values = table.pack(v8, v9, Footer(object2, {
	PriceLines = priceLines,
	CanPay = function(_, _, p2)
		return Shop.cashiers.Wen.CanBuy(data2, p2)
	end,
	Ready = function()
		return v5 == nil
	end,
	Text = v5 or "Transfer",
	Label = "Cost",
	Clicked = function()
		if v5 ~= nil or data.Busy:Get() then
			return
		end

		data.Busy:Set(true)
		local v10 = PopUpCreator.new({
			Type = "LoadingFull"
		})
		local success, result = pcall(SignalFunction.ToServer, "TierTransfer", {
			From = from.Id,
			To = to.Id
		})
		v10:Destroy()
		data.Busy:Set(false)

		if success then
			if typeof(result) == "table" then
				success = result.Ok == true
			else
				success = false
			end
		end

		local clone = ReplicatedStorage.Assets.Sounds.Misc[success and "Money_Kaching" or "denied_old"]:Clone()
		clone.Parent = script
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)

		if success then
			data.From:Set(to.Id)
		end
	end
})); for _k = 1, _values.n do v7[_k] = _values[_k] end end
				return v6(v7)
			end)
		})
	})
end

return TierTransfer