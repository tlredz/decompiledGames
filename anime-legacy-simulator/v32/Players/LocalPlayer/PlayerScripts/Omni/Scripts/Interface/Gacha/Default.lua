local module = require("@game/ReplicatedStorage/Omni")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Omni.Libs.Fusion)
local gacha = module.Interface:WaitForChild("Frames"):WaitForChild("Gacha")
local header = gacha:WaitForChild("Header")
local buttons = gacha:WaitForChild("Buttons")
local currency = gacha:WaitForChild("Currency")
local index = gacha:WaitForChild("Index")
local v = gacha:WaitForChild("_")
local scroll = index:WaitForChild("List"):WaitForChild("Scroll")
local pity = gacha:WaitForChild("Pity")
local price = gacha:WaitForChild("Price")
local current = gacha:WaitForChild("Current")
gacha:WaitForChild("Close")
local stopGacha = module.Interface:WaitForChild("HUD"):WaitForChild("StopButtons"):WaitForChild("StopGacha")
local index2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Gacha"):WaitForChild("Default"):WaitForChild("Index")
local v2 = nil
local flag = false
local v3 = nil
local v4 = false
local v5 = false
local count = 0
local v6 = 0
local v7 = {}
local v8 = {}
local scope = Fusion.scoped(Fusion)
local value = scope:Value(0)
local spring = scope:Spring(value, 10, 1)
local Default = {}

local function GetResults(p)
	local source = p and p.Source
	local normal

	if typeof(source) == "table" then
		normal = source.Normal
	else
		normal = false
	end

	return typeof(normal) == "table" and normal or {}
end

local function CanDisplayResult(value2, data)
	if typeof(value2) ~= "string" or typeof(data) ~= "table" or not module.Utils.Validator:ValidateNumber(data.Index) then
		return false
	end

	return typeof(data.Icon) == "string" and typeof(data.Rarity) == "string" and typeof(data.Perks) == "table"
end

local function GetPreview()
	if not v2 then
		return nil
	end

	local v9 = module.Shared.Gacha.List[v2]

	if not v9 then
		return nil
	end

	local source = v9 and v9.Source
	local normal

	if typeof(source) == "table" then
		normal = source.Normal
	else
		normal = false
	end

	for k, v10 in typeof(normal) == "table" and normal or {} do
		if not CanDisplayResult(k, v10) then
			return nil
		end
	end

	local gachaLuck = module.Utils.PlayerStats.GachaLuck(module.Data, module.Instance)
	local v10 = module.Data.Pity[`Gacha_{v2}`]
	return module.Shared.Gacha.GetNormalPreview(
		v9,
		gachaLuck,
		v10,
		module.Shared.SoftPity.GetState(module.Data, (`Gacha_{v2}`))
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetChanceText(p, p2: string)
	if not p then
		return "Unavailable"
	end

	local chance = p.Chances[p2]
	local chance2 = chance and chance.Chance or 0
	return module.Utils.Probability.FormatPercentage(chance2) or "Unavailable"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CanPay(price2)
	local monetizationPolicy = module.Shared.MonetizationPolicy.FromPlayer(module.Instance)
	local canSpendRandom, v9 = module.Shared.Economy.CanSpendRandom(module.Data, price2, monetizationPolicy)
	return canSpendRandom, v9, monetizationPolicy
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetOwnedAmount(type: string, name: string)
	if type == "Currency" or type == "Currencies" then
		return module.Data[name] or 0
	end

	if type == "Item" or type == "Items" then
		return module.Data.Items.List[name] or 0
	end

	return 0
end

local function ShowLateResults(gachaName: string, items)
	local v9 = module.Shared.Gacha.List[gachaName]

	if not v9 or v9.Source.Type ~= "Normal" or typeof(items) ~= "table" then
		return
	end

	for _, item in items do
		local v10

		if typeof(item) == "table" then
			v10 = item.Name and v9.Source.Normal[item.Name]
		else
			v10 = false
		end

		if v10 then
			module.Signal:FireSelf("Interface", "Notifications", "Create", "Drop", {
				Type = "Gacha",
				GachaName = gachaName,
				Name = item.Name,
				Rarity = v10.Rarity,
				Amount = 1
			})
		end
	end
end

local v9 = {
	Build = function(self, p: string, data, p2)
		local gachaName = v2
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.Instance = index2:Clone()
		self.Instance.Name = p
		self.Instance.Main.Title.Text = p
		self.Instance.Main.Icon.Image = data.Icon
		self.Instance.Main.UIGradient:SetAttribute("Rarity", data.Rarity)
		self.Instance.LayoutOrder = data.Index
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self.Button = module.Button:Create(self.Instance.Main, "Default")
		self.Button:BindFunction("Click", function()
			local v11 = module.Libs.NeoHover.GetByIdentifier("Gacha")

			if not v11 then
				return
			end

			v11:Click(self.Instance.Main, {
				GachaName = gachaName,
				ResultName = p
			})
		end)
		self.Button:BindOnEnter("Hover", function()
			local v11 = module.Libs.NeoHover.GetByIdentifier("Gacha")

			if not v11 then
				return
			end

			v11:Open(self.Instance.Main, {
				GachaName = gachaName,
				ResultName = p
			})
		end)
		self.Button:BindOnLeave("Hover", function()
			local v11 = module.Libs.NeoHover.GetByIdentifier("Gacha")

			if not v11 then
				return
			end

			v11:Close(self.Instance.Main)
		end)
		self:Hydrate(self.Instance.Main)({
			Size = self.SizeSpring
		})
		local index3 = 0
		local source = p2 and p2.Source
		local normal

		if typeof(source) == "table" then
			normal = source.Normal
		else
			normal = false
		end

		for _, v11 in typeof(normal) == "table" and normal or {} do
			if not (typeof(v11) == "table" and module.Utils.Validator:ValidateNumber(v11.Index) and index3 < v11.Index) then
				continue
			end

			index3 = v11.Index
		end

		local v11 = index3 > 0 and 0.5 * ((data.Index - 1) / index3) or 0
		task.delay(v11, function()
			if not next(self) then
				return
			end

			self.Size:set(UDim2.fromScale(1, 1))
		end)
		return true
	end
}
local scope2 = Fusion.scoped(Fusion, v9)
scope:Observer(spring):onBind(function()
	local currentSpring = scope.peek(spring)

	if not currentSpring then
		return
	end

	local uIGradient = pity.Bar.Slider.UIGradient

	if currentSpring >= 1 then
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0)
		})
	elseif currentSpring <= 0 then
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 1)
		})
	else
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(currentSpring, 0),
			NumberSequenceKeypoint.new(math.min(1, currentSpring + 0.1), 1),
			NumberSequenceKeypoint.new(1, 1)
		})
	end
end)

local function ShouldStopAuto()
	if not (v2 and GetPreview()) then
		return true
	end

	local v10 = module.Shared.Gacha.List[v2]

	if not v10 then
		return true
	end

	if v10.Source.Type ~= "Normal" then
		return false
	end

	local canSpendRandom, _, _ = CanPay(v10.Price) -- equivalent call inferred; original call site unknown

	if not canSpendRandom then
		return true
	end

	if not v10.KeepBest then
		return false
	end

	local v12 = module.Data.Gacha[v2]
	local current2 = v12 and v12.Current
	local v13 = current2 and v10.Source.Normal[current2]

	if not v13 then
		return false
	end

	local index3 = 0

	for _, v14 in v10.Source.Normal do
		if index3 < v14.Index then
			index3 = v14.Index
		end
	end

	if index3 <= v13.Index then
		return true
	end

	return false
end

function Default.Roll()
	if not v2 or v4 or v5 or os.clock() < v6 then
		return
	end

	if not GetPreview() then
		Default.RefreshList()
		return
	end

	local price2 = module.Shared.Gacha.List[v2].Price
	local canSpendRandom, v11, monetizationPolicy = CanPay(price2) -- equivalent call inferred; original call site unknown

	if canSpendRandom then
		local gachaCooldown = module.Utils.PlayerStats.GachaCooldown(module.Data, module.Instance, v2)

		if not module.Utils.Validator:ValidateNumber(gachaCooldown) or gachaCooldown <= 0 then
			return
		end

		v4 = true
		count += 1
		v6 = os.clock() + gachaCooldown
		local v13 = count
		module.Signal:Fire("General", "Gacha", "Roll", v2, nil, v13)
		task.delay(math.max(30, gachaCooldown + 3), function()
			if v13 ~= count or not v4 then
				return
			end

			v4 = false
			module.AutoRoll.Expire("Gacha", v13)
		end)
	else
		Default.CancelAuto()
		local signal = module.Signal
		local message

		if v11 == "InsufficientBalance" then
			message = `You need {price2.Amount} {price2.Name} to roll this gacha!`
		else
			message = module.Shared.MonetizationPolicy.GetPaymentMessage(v11, monetizationPolicy)
		end

		signal:FireSelf("Interface", "Notifications", "Create", "Text", {
			Message = message,
			Color = Color3.new(1, 1, 0)
		})
	end
end

function Default.StartAuto()
	if not v2 or flag then
		return
	end

	if ShouldStopAuto() then
		Default.RefreshList()
		return
	end

	v3 = module.AutoRoll.Claim(Default.CancelAuto, "Gacha", v2)
	flag = true
	stopGacha.Visible = true
	v8.Auto = module.Utils.Loop:Connect({
		Time = 0.1,
		Identifier = "GachaAutoRollingLoop",
		Callback = function(connection)
			if connection ~= v8.Auto or not (flag and v2) then
				connection:Disconnect()
				return
			end

			if v4 or v5 then
				return
			end

			if ShouldStopAuto() then
				Default.CancelAuto()
			else
				Default.Roll()
			end
		end
	})
end

function Default.CancelAuto()
	module.AutoRoll.Release(v3)
	v3 = nil
	flag = false
	stopGacha.Visible = false

	if v8.Auto then
		v8.Auto:Disconnect()
		v8.Auto = nil
	end
end

function Default.GetTemplate(p: string)
	local v10 = v7[p]

	if v10 then
		return v10.Instance
	end

	local v11 = module.Shared.Gacha.List[v2]

	if not v11 then
		return
	end

	local source = v11 and v11.Source
	local normal

	if typeof(source) == "table" then
		normal = source.Normal
	else
		normal = false
	end

	local v12 = (typeof(normal) == "table" and normal or {})[p]

	if not CanDisplayResult(p, v12) then
		return
	end

	local innerScope = scope2:innerScope()

	if innerScope:Build(p, v12, v11) then
		v7[p] = innerScope
		return innerScope.Instance
	else
		innerScope:doCleanup()
	end
end

function Default.ClearList()
	for k, v10 in v7 do
		v10.Instance:Destroy()
		v10:doCleanup()
		v7[k] = nil
	end

	table.clear(v7)
end

function Default.RefreshList()
	if not (v2 and module.Frame:IsFrameOpened(gacha)) then
		return
	end

	local v10 = module.Shared.Gacha.List[v2]

	if not v10 then
		return
	end

	local v11 = module.Data.Gacha[v2]
	local preview = GetPreview()
	local source = v10 and v10.Source
	local normal

	if typeof(source) == "table" then
		normal = source.Normal
	else
		normal = false
	end

	local v13 = typeof(normal) == "table" and normal or {}
	header.Title.Text = v10.Name
	v.Text = preview and "Next roll chances (rounded)" or "Chances unavailable"
	buttons.Roll.Main.Title.Text = preview and "Spin" or "Unavailable"

	if not preview and flag then
		Default.CancelAuto()
	end

	local v14 = module.Utils.Info:Get(v10.Price.Type, v10.Price.Name) or {}
	price.Icon.Image = v14.Icon or ""
	price.Amount.Text = module.Utils.Number:Format(v10.Price.Amount) .. " " .. v10.Price.Name
	local ownedAmount = GetOwnedAmount(v10.Price.Type, v10.Price.Name) -- equivalent call inferred; original call site unknown
	currency.Icon.Image = v14.Icon or ""
	currency.Title.Text = module.Utils.Number:Format(ownedAmount)
	local current2 = v11 and v11.Current
	local v16 = current2 and v13[current2]

	if CanDisplayResult(current2, v16) then
		current.Title.Text = current2
		current.Main.Icon.Image = v16.Icon
		local chance = current.Chance
		local text

		if preview then
			local chanceText = GetChanceText(preview, current2) -- equivalent call inferred; original call site unknown
			text = chanceText or "Unavailable"
		else
			text = "Unavailable"
		end

		chance.Text = text
		current.Main.UIGradient:SetAttribute("Rarity", v16.Rarity)
		current.Title.UIGradient:SetAttribute("Rarity", v16.Rarity)
		local perksArray = {}

		for k, perk in v16.Perks do
			perksArray[k] = { perk }
		end

		current.Perks.Text = module.Utils.Multipliers.ToStringTable({
			IsRich = true,
			PerksArray = perksArray,
			ShowPercentageForMultipliers = { "All" }
		})
	else
		current.Title.Text = "None"
		current.Main.Icon.Image = v10.Icon
		current.Chance.Text = preview and "—" or "Unavailable"
		current.Perks.Text = "No perks to show yet"
		current.Main.UIGradient:SetAttribute("Rarity", nil)
		current.Title.UIGradient:SetAttribute("Rarity", nil)
	end

	local currentState = preview and preview.Pity.CurrentState
	local v17 = currentState and v10.Pity[currentState.CurrentIndex]

	if v17 then
		value:set((math.min(1, currentState.CurrentAmount / v17.Amount)))
		pity.Value.UIGradient:SetAttribute("Rarity", v17.Name)
		pity.Value.Text = `{v17.Name} Pity [ {string.format("%.0f", (math.min(currentState.CurrentAmount, v17.Amount)))}/{string.format("%.0f", v17.Amount)} ]`
		pity.Visible = true
	else
		value:set(0)
		pity.Visible = false
	end

	for k in v13 do
		local template = Default.GetTemplate(k)

		if not template then
			continue
		end

		local chance = template.Main.Chance
		local text = GetChanceText(preview, k) -- equivalent call inferred; original call site unknown
		chance.Text = text
	end

	for k, v18 in v7 do
		if v13[k] then
			continue
		end

		v18.Instance:Destroy()
		v18:doCleanup()
		v7[k] = nil
	end
end

local function Prepare(p: string)
	if not module.Shared.Gacha.List[p] then
		return false
	end

	if v2 == p then
		return true
	end

	if v2 then
		Default.Stop()
	end

	spring:setPosition(0)
	Default.ClearList()
	Default.CancelAuto()
	v2 = p
	v.Size = UDim2.new(0.489570379, 0, v.Size.Y.Scale, v.Size.Y.Offset)
	v8.Data = module:OnDataChanged({ "Gacha" }, Default.RefreshList)
	v8.Pity = module:OnDataChanged({ "Pity" }, Default.RefreshList)
	v8.SoftPity = module:OnDataChanged({ "SoftPity" }, Default.RefreshList)
	v8.Loop = module.Utils.Loop:Connect({
		Time = 1,
		Identifier = "GachaInterfaceRefreshLoop",
		Callback = function(connection)
			if v2 == p then
				Default.RefreshList()
			else
				connection:Disconnect()
			end
		end
	})
	return true
end

function Default.Start(p: string)
	if not Prepare(p) then
		return
	end

	module.Frame:Open(gacha)
	Default.RefreshList()
end

function Default.Resume(p: string)
	if not Prepare(p) then
		module.AutoRoll.SaveGacha(nil)
		return
	end

	Default.StartAuto()

	if not flag then
		module.AutoRoll.SaveGacha(nil)
	end
end

function Default.Close()
	if module.Frame:IsFrameOpened(gacha) then
		module.Frame:Close(gacha)
	end

	Default.ClearList()
end

function Default.Stop()
	if not v2 then
		return
	end

	Default.CancelAuto()
	count += 1
	v4 = false

	for k, connection in v8 do
		if k == "Auto" then
			continue
		end

		connection:Disconnect()
		v8[k] = nil
	end

	v2 = nil
	module.Frame:Close(gacha)
	Default.ClearList()
end

function Default.RollFailed(p: string, p2: number?, p3: string?)
	if module.AutoRoll.TakeExpired("Gacha", p2) or (not v4 or p2 ~= count or v2 ~= p) then
		return
	end

	v4 = false

	if module.AutoRoll.ShouldRetry(p3) then
		v6 = os.clock() + 1
	else
		Default.CancelAuto()
	end

	Default.RefreshList()
end

function Default.Rolled(gachaName: string, items, p2: number?)
	if module.AutoRoll.TakeExpired("Gacha", p2) then
		ShowLateResults(gachaName, items)
		return
	end

	if not v4 or p2 ~= count or v2 ~= gachaName then
		return
	end

	v4 = false
	local v10 = module.Shared.Gacha.List[gachaName]

	if v10 and v10.Source.Type == "Normal" then
		local v11 = {}

		for _, item in items do
			local v12 = item.Name and v10.Source.Normal[item.Name]

			if v12 then
				table.insert(v11, {
					Name = item.Name,
					Rarity = v12.Rarity,
					Icon = v12.Icon
				})
			end
		end

		if #v11 > 0 then
			local v12 = {
				Info = {},
				Chances = v10.Source.Normal
			}

			for k, v13 in v10.Source.Normal do
				v12.Info[k] = {
					Rarity = v13.Rarity,
					Icon = v13.Icon
				}
			end

			local gachaLuck = module.Utils.PlayerStats.GachaLuck(module.Data, module.Instance)
			local gachaCooldown = module.Utils.PlayerStats.GachaCooldown(module.Data, module.Instance, gachaName)
			v5 = true
			module.Gacha.Animation(gachaCooldown, v11, v12, gachaLuck, {
				DropType = "Gacha",
				GachaName = gachaName,
				OnFinish = function(p3)
					v5 = false

					if not p3 and p2 == count then
						Default.CancelAuto()
					end
				end
			})
		end
	end

	Default.RefreshList()
end

module.Button:Create(buttons.Roll.Main, "Small"):BindFunction("Click", function()
	Default.Roll()
end)
module.Button:Create(buttons.Auto.Main, "Default"):BindFunction("Click", function()
	Default.StartAuto()
end)
module.Button:Create(stopGacha.Main, "Default"):BindFunction("Click", function()
	Default.CancelAuto()
end)
module.Frame:OnFrameOpened(gacha, Default.RefreshList)
module.Frame:OnFrameClosed(gacha, function()
	Default.Close()
end)
script.Destroying:Connect(Default.Stop)
return Default