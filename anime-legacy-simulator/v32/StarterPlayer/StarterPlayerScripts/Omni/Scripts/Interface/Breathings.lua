local module = require("@game/ReplicatedStorage/Omni")
local v = {
	Pity = true,
	SoftPity = true,
	Breathings = true,
	Maps = true
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Omni.Libs.Fusion)
local breathings = module.Interface:WaitForChild("Frames"):WaitForChild("Breathings")
local header = breathings:WaitForChild("Header")
local buttons = breathings:WaitForChild("Buttons")
local price = breathings:WaitForChild("Price")
local currency = breathings:WaitForChild("Currency")
local breathings2 = breathings:WaitForChild("Breathings")
local current = breathings:WaitForChild("Current")
local index = breathings:WaitForChild("Index")
local main = index:WaitForChild("Main")
local scroll = main:WaitForChild("List"):WaitForChild("Scroll")
local pity = breathings:WaitForChild("Pity")
local stopBreathings = module.Interface:WaitForChild("HUD"):WaitForChild("StopButtons"):WaitForChild("StopBreathings")
local breathings3 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Breathings")
local breathing = breathings3:WaitForChild("Breathing")
local index2 = breathings3:WaitForChild("Index")
local flag = false
local v2 = nil
local v3 = nil
local v4 = false
local v5 = nil
local v6 = false
local v7 = false
local v8 = nil
local v9 = 0
local count = 0
local v10 = {}
local count2 = 0
local v11 = {}
local count3 = 0
local v12 = {}
local scope = Fusion.scoped(Fusion)
local value = scope:Value(0)
local spring = scope:Spring(value, 10, 1)
local uIScale = main:FindFirstChildWhichIsA("UIScale") or Instance.new("UIScale")
uIScale.Parent = main
main.Active = true
local value2 = scope:Value(0)
local spring2 = scope:Spring(value2, 25, 1)
scope:Hydrate(uIScale)({
	Scale = spring2
})
local Breathings = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function Notify(message: string)
	module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
		Message = message,
		Color = Color3.new(1, 1, 0)
	})
end

local function IsAmount(p)
	local v13 = module.Utils.Validator:ValidateNumber(p)

	if v13 then
		if p >= 0 and p <= 9007199254740991 then
			return p % 1 == 0
		else
			return false
		end
	end

	return v13
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HasAccess()
	local maps = module.Data.Maps

	if typeof(maps) == "table" and typeof(maps.List) == "table" then
		return module.Utils.PlayerStats.OwnsMap(module.Shared.Breathings.MapName, module.Data)
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckAccess()
	-- equivalent call inferred; original call site unknown
	if HasAccess() then
		return true
	end

	Notify(`Unlock {module.Shared.Breathings.MapName} to use Breathings!`)
	return false
end

local function GetWeaponData(value3)
	if typeof(value3) ~= "string" then
		return nil
	end

	local weapons = module.Data.Weapons

	if typeof(weapons) ~= "table" or typeof(weapons.List) ~= "table" then
		return nil
	end

	local v13 = weapons.List[value3]

	if typeof(v13) ~= "table" or typeof(v13.Name) ~= "string" or v13.Name == "Melee" then
		return nil
	end

	if module.Shared.Weapons.List[v13.Name] then
		return v13
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetSelectedWeaponData()
	return (GetWeaponData(v2))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetSelectedBreathingsData()
	local selectedWeaponData = GetSelectedWeaponData() -- equivalent call inferred; original call site unknown
	return selectedWeaponData and selectedWeaponData.Breathings
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetDisplayState()
	return module.Shared.Breathings.GetRollState(GetSelectedBreathingsData())
end

local function CanDisplayBreathing(value3, p)
	if typeof(value3) ~= "string" or typeof(p) ~= "table" then
		return false
	end

	if typeof(p.Icon) ~= "string" or typeof(p.Rarities) ~= "table" then
		return false
	end

	for k, rarity in p.Rarities do
		if typeof(k) ~= "string" or typeof(rarity) ~= "table" then
			return false
		end

		for _, v13 in { "Attributes", "Perks" } do
			if typeof(rarity[v13]) ~= "table" then
				return false
			end

			for k2, v14 in rarity[v13] do
				if typeof(k2) ~= "string" or typeof(v14) ~= "table" then
					return false
				end

				if typeof(v14.Type) ~= "string" or not module.Utils.Validator:ValidateNumber(v14.Amount) then
					return false
				end
			end
		end
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetResults()
	local list = module.Shared.Breathings.List
	return typeof(list) == "table" and list or {}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetLuck()
	return module.Utils.PlayerStats.GachaLuck(module.Data, module.Instance)
end

local function GetPreview()
	if not GetWeaponData(v2) then
		return nil
	end

	local list = module.Shared.Breathings.List

	for k, v13 in typeof(list) == "table" and list or {} do
		if not CanDisplayBreathing(k, v13) then
			return nil
		end
	end

	if typeof(module.Data.Pity) ~= "table" then
		return nil
	end

	local getPreview = module.Shared.Breathings.GetPreview
	local luck = GetLuck() -- equivalent call inferred; original call site unknown
	return getPreview(
		luck,
		GetSelectedBreathingsData(),
		module.Data.Pity.Breathings,
		module.Shared.SoftPity.GetState(module.Data, "Breathings")
	)
end

local function GetPityPreview()
	if typeof(module.Data.Pity) == "table" then
		return module.Shared.Gacha.GetPityPreview(module.Shared.Breathings.Pity, module.Data.Pity.Breathings)
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CanPay(p)
	local monetizationPolicy = module.Shared.MonetizationPolicy.FromPlayer(module.Instance)
	local canSpendRandom, v13 = module.Shared.Economy.CanSpendRandom(module.Data, p, monetizationPolicy)
	return canSpendRandom, v13, monetizationPolicy
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetOwnedAmount(p)
	if not p then
		return nil
	end

	local balance = module.Shared.Economy.GetBalance(module.Data, p)
	return balance and balance.Total
end

local function GetFinalPrice()
	local price2 = module.Shared.Breathings.Price

	if typeof(price2) ~= "table" or typeof(price2.Name) ~= "string" then
		return nil
	end

	local amount = price2.Amount
	local v13 = module.Utils.Validator:ValidateNumber(amount)

	if v13 then
		if amount >= 0 and amount <= 9007199254740991 then
			v13 = amount % 1 == 0
		else
			v13 = false
		end
	end

	if not v13 or price2.Amount == 0 then
		return nil
	end

	if price2.Type == "Item" or price2.Type == "Items" then
		if not module.Shared.Items.List[price2.Name] then
			return nil
		end
	elseif price2.Type ~= "Currency" and price2.Type ~= "Currencies" or not module.Shared.Perks[price2.Name] then
		return nil
	end

	local amount2 = price2.Amount * 2 ^ (GetDisplayState()).LockedCount
	local v15 = module.Utils.Validator:ValidateNumber(amount2)

	if v15 then
		if amount2 >= 0 and amount2 <= 9007199254740991 then
			v15 = amount2 % 1 == 0
		else
			v15 = false
		end
	end

	if v15 then
		return {
			Type = price2.Type,
			Name = price2.Name,
			Amount = amount2
		}
	end

	return nil
end

local function GetCooldown()
	local breathingsCooldown = module.Utils.PlayerStats.BreathingsCooldown(module.Data, module.Instance)

	if module.Utils.Validator:ValidateNumber(breathingsCooldown) and not (breathingsCooldown <= 0) then
		return breathingsCooldown
	end

	return nil
end

local function GetMostCommonRarity(p)
	local v13 = 1e999
	local v14 = nil

	for k in p.Rarities do
		local rarity = module.Utils.Order:Rarity(k)

		if not (rarity < v13) then
			continue
		end

		v14 = k
		v13 = rarity
	end

	return v14
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetSameSetChance(p)
	if not p then
		return nil
	end

	local outcomeKey = module.Shared.Breathings.GetOutcomeKey(p.State.Current)

	if not outcomeKey then
		return nil
	end

	local chance = p.Chances[outcomeKey]
	return chance and chance.Chance or 0
end

local function IsAutoStop(p: string, p2: string)
	local breathings4 = module.Data.Breathings
	local autoStop

	if typeof(breathings4) == "table" then
		autoStop = breathings4.AutoStop
	else
		autoStop = false
	end

	local v13

	if typeof(autoStop) == "table" then
		v13 = autoStop[p]
	else
		v13 = false
	end

	return typeof(v13) == "table" and v13[p2] == true
end

local function IsSelectedWeaponChange(p, p2, list)
	if #list == 0 then
		return true
	end

	return list[1] == "List" and (list[2] == nil or list[2] == v2 and not module:IsExpChange(list, p, p2))
end

local function IsPriceItemChange(_, _, list)
	if list[1] ~= "List" or list[2] == nil then
		return true
	end

	local price2 = module.Shared.Breathings.Price

	if module.Shared.Gems.GetName(price2) then
		return list[2] == "Free Gems" or list[2] == "Paid Gems"
	end

	return list[2] == price2.Name
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsYenPrice()
	return module.Shared.Breathings.Price.Name == "Yen"
end

local function IsRelevantDataChange(p, p2, list)
	local v13 = list[1]

	if v13 == nil or v[v13] then
		return true
	end

	if v13 == "Yen" then
		return IsYenPrice()
	end

	if v13 ~= "Weapons" and v13 ~= "Items" then
		return false
	end

	local v14 = table.move(list, 2, #list, 1, {})

	if v13 == "Weapons" then
		if #v14 == 0 then
			return true
		end

		return v14[1] == "List" and (v14[2] == nil or v14[2] == v2 and not module:IsExpChange(v14, p, p2))
	else
		if v14[1] ~= "List" or v14[2] == nil then
			return true
		end

		local price2 = module.Shared.Breathings.Price
		local v15

		if not module.Shared.Gems.GetName(price2) then
			return v14[2] == price2.Name
		end

		if v14[2] ~= "Free Gems" then
			return v14[2] == "Paid Gems"
		end

		v15 = true
		return true
	end
end

local function ShowLateResults(p: string, items)
	if typeof(items) ~= "table" then
		return
	end

	local v13 = false

	for _, item in items do
		if not (typeof(item) == "table" and typeof(item.Name) == "string" and typeof(item.Rarity) == "string") then
			continue
		end

		module.Signal:FireSelf("Interface", "Notifications", "Create", "Drop", {
			Type = "Breathing",
			Name = item.Name,
			Rarity = item.Rarity,
			Amount = 1
		})
		local name = item.Name
		local rarity = item.Rarity
		local breathings4 = module.Data.Breathings
		local autoStop

		if typeof(breathings4) == "table" then
			autoStop = breathings4.AutoStop
		else
			autoStop = false
		end

		local v14

		if typeof(autoStop) == "table" then
			v14 = autoStop[name]
		else
			v14 = false
		end

		local v15

		if typeof(v14) == "table" then
			v15 = v14[rarity] == true
		else
			v15 = false
		end

		if v15 then
			v13 = true
		end
	end

	if v13 and v4 and v2 == p then
		Breathings.CancelAuto()
		module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
			Message = "Auto Stop: you got a Breathing you were watching for!",
			Color = Color3.fromRGB(0, 255, 149)
		})
	end

	if flag then
		Breathings.RefreshUI()
	end
end

local v13 = {
	Build = function(self, layoutOrder: number)
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.Instance = breathing:Clone()
		self.Instance.Name = tostring(layoutOrder)
		self.Instance.LayoutOrder = layoutOrder
		self.Button = module.Button:Create(self.Instance.Main.LockButton.Main, "Default")
		self.Button:BindFunction("Click", function()
			local entry = self.Entry

			if not (v2 and entry) then
				return
			end

			local locked = entry.Locked == true

			if not locked and not module.Shared.Breathings.CanLock(GetSelectedBreathingsData(), entry.Slot) then
				Notify("Keep at least one Breathing unlocked!") -- equivalent call inferred; original call site unknown
				return
			end

			module.Signal:Fire("General", "Breathings", "SetLock", v2, entry.Slot, entry.Name, entry.Rarity, not locked)
		end)
		self.Instance.Parent = breathings2
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Size = self.SizeSpring
		})
		local v14 = count2 * 0.05
		count2 += 1
		task.delay(v14, function()
			if not next(self) then
				return
			end

			self.Size:set(UDim2.fromScale(1, 1))
		end)
		return true
	end
}
local scope2 = Fusion.scoped(Fusion, v13)
local color = Color3.fromRGB(0, 255, 149)
local color2 = Color3.fromRGB(255, 51, 99)
local uDim = UDim2.fromScale(0.789, 0.5)
local uDim2 = UDim2.fromScale(0.211, 0.5)
local v14 = {
	Build = function(self, breathingName: string, rarityName: string)
		self.BreathingName = breathingName
		self.RarityName = rarityName
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.ToggleColor = self:Value(color2)
		self.ToggleColorSpring = self:Spring(self.ToggleColor, 10, 1)
		self.TogglePosition = self:Value(uDim2)
		self.TogglePositionSpring = self:Spring(self.TogglePosition, 10, 1)
		self.Instance = index2:Clone()
		self.Instance.Name = `{breathingName} ({rarityName})`
		self.Instance.Main.UIGradient:SetAttribute("Rarity", rarityName)
		module.Button:Create(self.Instance.Main.Toggle.Point, "Small"):BindFunction("Click", function()
			local breathingName2 = breathingName
			local rarityName2 = rarityName
			local breathings4 = module.Data.Breathings
			local autoStop

			if typeof(breathings4) == "table" then
				autoStop = breathings4.AutoStop
			else
				autoStop = false
			end

			local v17

			if typeof(autoStop) == "table" then
				v17 = autoStop[breathingName2]
			else
				v17 = false
			end

			local v18

			if typeof(v17) == "table" then
				v18 = v17[rarityName2] == true
			else
				v18 = false
			end

			module.Signal:Fire("General", "Breathings", "SetAutoStop", breathingName, rarityName, not v18)
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Size = self.SizeSpring
		})
		self:Hydrate(self.Instance.Main.Toggle)({
			ImageColor3 = self.ToggleColorSpring
		})
		self:Hydrate(self.Instance.Main.Toggle.Point)({
			Position = self.TogglePositionSpring,
			ImageColor3 = self.ToggleColorSpring
		})
		self:Hydrate(self.Instance.Main.Toggle.Point.Glow)({
			ImageColor3 = self.ToggleColorSpring
		})
		local v15 = count3 * 0.05
		count3 += 1
		task.delay(v15, function()
			if not next(self) then
				return
			end

			self.Size:set(UDim2.fromScale(1, 1))
		end)
		self:Update()
		return true
	end,
	Update = function(self)
		local breathingName = self.BreathingName
		local rarityName = self.RarityName
		local breathings4 = module.Data.Breathings
		local autoStop

		if typeof(breathings4) == "table" then
			autoStop = breathings4.AutoStop
		else
			autoStop = false
		end

		local v15

		if typeof(autoStop) == "table" then
			v15 = autoStop[breathingName]
		else
			v15 = false
		end

		local v16

		if typeof(v15) == "table" then
			v16 = v15[rarityName] == true
		else
			v16 = false
		end

		self.ToggleColor:set(v16 and color or color2)
		self.TogglePosition:set(v16 and uDim or uDim2)
	end
}
local scope3 = Fusion.scoped(Fusion, v14)
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

function Breathings.GetBuffTemplate(p: number)
	local v15 = v10[p]

	if v15 then
		return v15
	end

	local innerScope = scope2:innerScope()

	if innerScope:Build(p) then
		v10[p] = innerScope
		return innerScope
	else
		innerScope:doCleanup()
	end
end

function Breathings.ClearBuffs()
	for k, v15 in v10 do
		v15.Instance:Destroy()
		v15:doCleanup()
		v10[k] = nil
	end

	table.clear(v10)
	count2 = 0
end

function Breathings.RefreshBuffs()
	local selectedBreathingsData = GetSelectedBreathingsData() -- equivalent call inferred; original call site unknown
	local getRollState = module.Shared.Breathings.GetRollState
	local selectedWeaponData = GetSelectedWeaponData() -- equivalent call inferred; original call site unknown
	local v17 = {}

	for _, entry in getRollState(selectedWeaponData and selectedWeaponData.Breathings).Current do
		local v19 = (GetResults())[entry.Name]
		local v20 = CanDisplayBreathing(entry.Name, v19) and v19.Rarities[entry.Rarity]

		if not v20 then
			continue
		end

		local buffTemplate = Breathings.GetBuffTemplate(entry.Slot)

		if not buffTemplate then
			continue
		end

		local locked = entry.Locked == true
		local main2 = buffTemplate.Instance.Main
		buffTemplate.Entry = entry
		v17[entry.Slot] = true
		main2.Icon.Image = v19.Icon or ""
		main2.Title.Text = `{entry.Name} ({entry.Rarity})`
		main2.UIGradient:SetAttribute("Rarity", entry.Rarity)
		local stringEffects = module.Utils.Multipliers.ToStringEffects({ v20 })
		main2.Value.Text = (stringEffects == "" or not stringEffects) and "No effects" or stringEffects
		main2.LockButton:SetAttribute("Locked", locked)
		main2.LockButton:SetAttribute(
			"CanLock",
			locked or module.Shared.Breathings.CanLock(selectedBreathingsData, entry.Slot)
		)
		main2.LockButton.Main.UIGradient.Enabled = locked
	end

	for k, v18 in v10 do
		if v17[k] then
			continue
		end

		v18.Instance:Destroy()
		v18:doCleanup()
		v10[k] = nil
	end
end

function Breathings.GetIndexTemplate(p: string, p2: string)
	v11[p] = v11[p] or {}
	local v15 = v11[p][p2]

	if v15 then
		return v15
	end

	local innerScope = scope3:innerScope()

	if innerScope:Build(p, p2) then
		v11[p][p2] = innerScope
		return innerScope
	else
		innerScope:doCleanup()
	end
end

function Breathings.ClearIndexList()
	for k, list in v11 do
		for _, v15 in list do
			v15.Instance:Destroy()
			v15:doCleanup()
		end

		table.clear(list)
		v11[k] = nil
	end

	table.clear(v11)
	count3 = 0
end

function Breathings.RefreshIndexList(p)
	local v15 = p or GetPreview()
	local v16 = {}
	local v17 = {}
	local v18 = {}

	if v15 then
		for _, outcome in v15.Outcomes do
			local v19 = {}

			for _, v20 in outcome.New do
				v19[v20.Name] = v19[v20.Name] or {}

				if v19[v20.Name][v20.Rarity] then
					continue
				end

				v19[v20.Name][v20.Rarity] = true
				v16[v20.Name] = v16[v20.Name] or {}
				v16[v20.Name][v20.Rarity] = (v16[v20.Name][v20.Rarity] or 0) + outcome.Chance
			end
		end
	end

	local list = module.Shared.Breathings.List

	for k, v19 in typeof(list) == "table" and list or {} do
		if not CanDisplayBreathing(k, v19) then
			continue
		end

		for k2 in v19.Rarities do
			table.insert(v17, {
				Name = k,
				Rarity = k2
			})
		end
	end

	table.sort(v17, function(a, b)
		local rarity = module.Utils.Order:Rarity(a.Rarity)
		local rarity2 = module.Utils.Order:Rarity(b.Rarity)

		if rarity < rarity2 then
			return true
		elseif rarity == rarity2 then
			return a.Name < b.Name
		else
			return false
		end
	end)

	for k, v19 in v17 do
		local indexTemplate = Breathings.GetIndexTemplate(v19.Name, v19.Rarity)

		if not indexTemplate then
			continue
		end

		v18[v19.Name] = v18[v19.Name] or {}
		v18[v19.Name][v19.Rarity] = true
		local v20 = (GetResults())[v19.Name]
		local stringEffects = module.Utils.Multipliers.ToStringEffects({ v20.Rarities[v19.Rarity] })
		local v21

		if v15 then
			local v22 = not v16[v19.Name] and 0 or v16[v19.Name][v19.Rarity] or 0
			v21 = module.Utils.Probability.FormatPercentage((math.clamp(v22, 0, 100))) or "Unavailable"
		else
			v21 = "Unavailable"
		end

		indexTemplate.Instance.LayoutOrder = k
		indexTemplate.Instance.Main.Title.Text = `{v19.Name} - {v21}`
		indexTemplate.Instance.Main.Icon.Image = v20.Icon
		indexTemplate.Instance.Main.Desc.RichText = true
		indexTemplate.Instance.Main.Desc.Text = (stringEffects == "" or not stringEffects) and "No effects" or stringEffects
		indexTemplate:Update()
	end

	for k, v19 in v11 do
		for k2, v20 in v19 do
			if v18[k] and v18[k][k2] then
				continue
			end

			v20.Instance:Destroy()
			v20:doCleanup()
			v19[k2] = nil
		end

		if not next(v19) then
			v11[k] = nil
		end
	end

	main.Header.Title.Text = "Breathing Chances"
	main.Header.Desc.Text = v15 and "Chance per roll" or GetWeaponData(v2) and "Chances unavailable" or "Select a weapon"
	main.Desc.Text = "Chances can overlap. Auto Stop ends on any selected new result."
end

local count4 = 0

function Breathings.OpenIndex()
	if index.Visible and scope.peek(value2) == 1 then
		return
	end

	count4 += 1
	Breathings.ClearIndexList()
	Breathings.RefreshIndexList()
	index.Visible = true
	value2:set(1)

	if not v12.IndexData then
		v12.IndexData = module:OnDataChanged({ "Breathings" }, function()
			Breathings.RefreshIndexList()
		end)
	end
end

function Breathings.CloseIndex()
	count4 += 1
	local v15 = count4
	value2:set(0)

	if v12.IndexData then
		v12.IndexData:Disconnect()
		v12.IndexData = nil
	end

	task.delay(0.3, function()
		if count4 ~= v15 then
			return
		end

		index.Visible = false
		Breathings.ClearIndexList()
	end)
end

local function GetRollAvailability(p)
	-- equivalent call inferred; original call site unknown
	if not HasAccess() then
		return nil, (`Unlock {module.Shared.Breathings.MapName} to use Breathings!`)
	end

	if not GetWeaponData(v2) then
		return nil, "Select a valid Weapon first!"
	end

	if not p then
		return nil, "Breathing chances are unavailable for this selection."
	end

	local finalPrice = GetFinalPrice()
	local ownedAmount = GetOwnedAmount(finalPrice) -- equivalent call inferred; original call site unknown
	local breathingsCooldown = module.Utils.PlayerStats.BreathingsCooldown(module.Data, module.Instance)

	if not module.Utils.Validator:ValidateNumber(breathingsCooldown) or breathingsCooldown <= 0 then
		breathingsCooldown = nil
	end

	if not finalPrice or ownedAmount == nil or not breathingsCooldown then
		return nil, "Breathings are unavailable. Please try again later!"
	end

	local canSpendRandom, v18, monetizationPolicy = CanPay(finalPrice) -- equivalent call inferred; original call site unknown

	if canSpendRandom then
		return breathingsCooldown
	end

	local v20 = nil

	if v18 == "InsufficientBalance" then
		return v20, (`You need {finalPrice.Amount} {finalPrice.Name} to spin Breathings!`)
	end

	return v20, (module.Shared.MonetizationPolicy.GetPaymentMessage(v18, monetizationPolicy))
end

function Breathings.Roll()
	if not flag or v6 or v7 or os.clock() < v9 then
		return
	end

	local v15, message = GetRollAvailability(GetPreview())

	if v15 then
		v6 = true
		v8 = v2
		count += 1
		v9 = os.clock() + v15
		local v17 = count
		module.Signal:Fire("General", "Breathings", "Spin", v2, v17)
		task.delay(math.max(30, v15 + 3), function()
			if v17 ~= count or not v6 then
				return
			end

			v6 = false
			v8 = nil
			module.AutoRoll.Expire("Breathings", v17)

			if flag then
				Breathings.RefreshUI()
			end
		end)
	else
		Breathings.CancelAuto()
		Notify(message)
		Breathings.RefreshUI()
	end
end

function Breathings.RollFailed(p: string, p2: number?, p3: string?)
	if module.AutoRoll.TakeExpired("Breathings", p2) or (not v6 or v8 ~= p or p2 ~= count) then
		return
	end

	v6 = false
	v8 = nil

	if module.AutoRoll.ShouldRetry(p3) then
		v9 = os.clock() + 1
	else
		Breathings.CancelAuto()
	end

	if flag then
		Breathings.RefreshUI()
	end
end

function Breathings.StartAuto()
	if not flag or v4 or v6 then
		return
	end

	local v15, message = GetRollAvailability(GetPreview())

	if v15 then
		v5 = module.AutoRoll.Claim(Breathings.CancelAuto, "Breathings", v2)
		v4 = true
		stopBreathings.Visible = true
		v12.Auto = module.Utils.Loop:Connect({
			Time = 0.1,
			Identifier = "BreathingsAutoRollingLoop",
			Callback = function(connection)
				if connection ~= v12.Auto or not (v4 and flag) then
					connection:Disconnect()
					return
				end

				if v6 or v7 then
					return
				end

				if GetRollAvailability(GetPreview()) then
					Breathings.Roll()
				else
					Breathings.CancelAuto()
				end
			end
		})
	else
		Notify(message)
		Breathings.RefreshUI()
	end
end

function Breathings.CancelAuto()
	module.AutoRoll.Release(v5)
	v5 = nil
	v4 = false
	stopBreathings.Visible = false

	if v12.Auto then
		v12.Auto:Disconnect()
		v12.Auto = nil
	end
end

function Breathings.SelectWeapon(p: string)
	if not GetWeaponData(p) or v2 == p then
		return
	end

	Breathings.CancelAuto()
	count += 1
	v6 = false
	v8 = nil
	Breathings.ClearBuffs()
	v2 = p
	Breathings.RefreshUI()
end

function Breathings.DeselectWeapon()
	if not v2 then
		return
	end

	Breathings.CancelAuto()
	Breathings.ClearBuffs()
	v2 = nil
	Breathings.RefreshUI()
end

function Breathings.OpenWeaponSelector()
	local v15 = module.Signal:InvokeSelf("Interface", "Inventory", "GetController")

	if not v15 then
		return
	end

	v15.SetMode("Selection", {
		Category = "Weapons",
		PastUI = breathings,
		Callback = function(p: string)
			if not GetWeaponData(p) then
				module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
					Message = "Select a valid Weapon other than Melee!",
					Color = Color3.fromRGB(255, 255, 0)
				})
				return
			end

			Breathings.SelectWeapon(p)
			v15.CloseInterface()
		end
	})
end

function Breathings.RefreshUI()
	if not module.Frame:IsFrameOpened(breathings) then
		return
	end

	local breathings4 = module.Shared.Breathings
	local displayState = GetDisplayState() -- equivalent call inferred; original call site unknown
	local preview = GetPreview()
	local finalPrice = GetFinalPrice()
	local ownedAmount = GetOwnedAmount(finalPrice) -- equivalent call inferred; original call site unknown
	local v19 = not finalPrice and {} or module.Utils.Info:Get(finalPrice.Type, finalPrice.Name) or {}
	local selectedWeaponData = GetSelectedWeaponData() -- equivalent call inferred; original call site unknown
	local v21 = selectedWeaponData and module.Shared.Weapons.List[selectedWeaponData.Name]
	header.Title.Text = breathings4.Name
	buttons.Index.Main.Title.Text = "See Chances"
	local title = buttons.Spin.Main.Title
	local text

	if selectedWeaponData then
		if preview and finalPrice then
			local breathingsCooldown = module.Utils.PlayerStats.BreathingsCooldown(module.Data, module.Instance)

			if not module.Utils.Validator:ValidateNumber(breathingsCooldown) or breathingsCooldown <= 0 then
				breathingsCooldown = nil
			end

			text = breathingsCooldown and "Spin" or "Unavailable"
		else
			text = "Unavailable"
		end
	else
		text = "Spin"
	end

	title.Text = text
	price.Icon.Image = v19.Icon or ""
	price.Amount.Text = not finalPrice and "Unavailable" or `{module.Utils.Number:Format(finalPrice.Amount)} {finalPrice.Name}` or "Unavailable"
	price._.Text = finalPrice and finalPrice.Name == "Gems" and "Free Gems first" or "per spin"
	currency.Icon.Image = v19.Icon or ""
	currency.Title.Text = ownedAmount == nil and "Unavailable" or module.Utils.Number:Format(ownedAmount) or "Unavailable"
	current.Main.NothingSelected.Visible = not selectedWeaponData
	current.Main.Icon.Visible = selectedWeaponData ~= nil

	if selectedWeaponData and v21 then
		local lockedCount = displayState.LockedCount
		local unlockedCount = displayState.UnlockedCount
		current.Title.Text = selectedWeaponData.Name
		current.Main.Icon.Image = v21.Icon or ""
		current.Main.UIGradient:SetAttribute("Rarity", v21.Rarity)
		current.Title.UIGradient:SetAttribute("Rarity", v21.Rarity)

		if lockedCount > 0 and unlockedCount == 0 then
			current.Tip.Text = "Unlock at least one Breathing before spinning!"
		elseif preview then
			current.Tip.Text = `{unlockedCount} unlocked, {lockedCount} locked | Chance to repeat on the next spin.`
		else
			current.Tip.Text = "Chances unavailable. Try another selection or come back later."
		end

		local v23 = {}

		for _, v24 in displayState.Current do
			local v25 = (GetResults())[v24.Name]

			if CanDisplayBreathing(v24.Name, v25) and v25.Rarities[v24.Rarity] then
				table.insert(v23, v25.Rarities[v24.Rarity])
			end
		end

		local stringEffects = module.Utils.Multipliers.ToStringEffects(v23)
		local sameSetChance = GetSameSetChance(preview) -- equivalent call inferred; original call site unknown
		local perks = current.Perks

		if stringEffects == "" or not stringEffects then
			stringEffects = #displayState.Current > 0 and "No effects" or "No Breathings yet, spin to get some!"
		end

		perks.Text = stringEffects
		current.Chance.Text = preview and "" or "Unavailable"

		if sameSetChance ~= nil then
			local formatPercentage = module.Utils.Probability.FormatPercentage(sameSetChance)
			current.Chance.Text = formatPercentage and `Repeat: {formatPercentage}` or "Unavailable"
		end
	else
		current.Title.Text = ""
		current.Main.Icon.Image = ""
		current.Main.UIGradient:SetAttribute("Rarity", nil)
		current.Title.UIGradient:SetAttribute("Rarity", nil)
		current.Tip.Text = "Select a weapon to spin a Breathing."
		current.Perks.Text = ""
		current.Chance.Text = ""
	end

	Breathings.RefreshBuffs()

	if index.Visible then
		Breathings.RefreshIndexList(preview)
	end

	local pity2 = preview and preview.Pity

	if not pity2 then
		if typeof(module.Data.Pity) == "table" then
			pity2 = module.Shared.Gacha.GetPityPreview(module.Shared.Breathings.Pity, module.Data.Pity.Breathings)
		else
			pity2 = nil
		end
	end

	local v23 = pity2 and pity2.Enabled and breathings4.Pity[pity2.CurrentState.CurrentIndex]

	if v23 then
		local v24 = math.min(pity2.CurrentState.CurrentAmount, v23.Amount)
		value:set(v24 / v23.Amount)
		pity.Value.UIGradient:SetAttribute("Rarity", v23.Name)
		pity.Value.Text = `{v23.Name} Pity [ {module.Utils.Number:Format(v24)}/{module.Utils.Number:Format(v23.Amount)} ]`
		pity.Visible = true
	else
		value:set(0)
		pity.Visible = false
	end

	if v4 and not (v6 or v7 or GetRollAvailability(preview)) then
		Breathings.CancelAuto()
	end
end

local function Prepare()
	-- equivalent call inferred; original call site unknown
	if not HasAccess() then
		return false
	end

	if flag then
		return true
	end

	flag = true
	Breathings.ClearBuffs()
	Breathings.CancelAuto()
	Breathings.CloseIndex()
	spring:setPosition(0)
	Breathings.RefreshUI()
	v12.Data = module:OnDataChangedDeferred({}, Breathings.RefreshUI, IsRelevantDataChange)
	v12.Loop = module.Utils.Loop:Connect({
		Time = 1,
		Identifier = "BreathingsInterfaceRefreshLoop",
		Callback = function(connection)
			if flag then
				Breathings.RefreshUI()
			else
				connection:Disconnect()
			end
		end
	})
	return true
end

function Breathings.Start()
	-- equivalent call inferred; original call site unknown
	if CheckAccess() then
		if flag then
			if not module.Frame:IsFrameOpened(breathings) then
				module.Frame:Open(breathings)
			end

			Breathings.RefreshUI()
		else
			Prepare()
			module.Frame:Open(breathings)
		end
	else
		Breathings.Stop()
		module.Frame:Close(breathings)
	end
end

function Breathings.Resume(p: string)
	if not Prepare() then
		module.AutoRoll.SaveGacha(nil)
		return
	end

	Breathings.SelectWeapon(p)

	if v2 == p then
		Breathings.StartAuto()
	end

	if not v4 then
		module.AutoRoll.SaveGacha(nil)
	end
end

function Breathings.Stop()
	count += 1
	v6 = false
	v8 = nil

	if not flag then
		return
	end

	Breathings.CancelAuto()

	for k, connection in v12 do
		if k == "Auto" then
			continue
		end

		connection:Disconnect()
		v12[k] = nil
	end

	Breathings.CloseIndex()
	flag = false
	v2 = nil
	Breathings.ClearBuffs()
	module.Frame:Close(breathings)
end

function Breathings.Close()
	if module.Frame:IsFrameOpened(breathings) then
		module.Frame:Close(breathings)
	end

	Breathings.CloseIndex()
	Breathings.ClearBuffs()
end

function Breathings.Rolled(p: string, list, p2: number?)
	if module.AutoRoll.TakeExpired("Breathings", p2) then
		ShowLateResults(p, list)
		return
	end

	if not v6 or v8 ~= p or p2 ~= count then
		return
	end

	v6 = false
	v8 = nil

	if not flag or v2 ~= p then
		return
	end

	if typeof(list) == "table" and #list ~= 0 then
		local v15 = {}
		local v16 = false

		for _, v17 in list do
			if not (typeof(v17) == "table" and typeof(v17.Name) == "string" and typeof(v17.Rarity) == "string") then
				continue
			end

			local v18 = (GetResults())[v17.Name]

			if not (CanDisplayBreathing(v17.Name, v18) and v18.Rarities[v17.Rarity]) then
				continue
			end

			table.insert(v15, {
				Name = v17.Name,
				Rarity = v17.Rarity,
				Icon = v18.Icon
			})
			local name = v17.Name
			local rarity = v17.Rarity
			local breathings4 = module.Data.Breathings
			local autoStop

			if typeof(breathings4) == "table" then
				autoStop = breathings4.AutoStop
			else
				autoStop = false
			end

			local v19

			if typeof(autoStop) == "table" then
				v19 = autoStop[name]
			else
				v19 = false
			end

			local v20

			if typeof(v19) == "table" then
				v20 = v19[rarity] == true
			else
				v20 = false
			end

			if v20 then
				v16 = true
			end
		end

		if v16 and v4 then
			Breathings.CancelAuto()
			module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
				Message = "Auto Stop: you got a Breathing you were watching for!",
				Color = Color3.fromRGB(0, 255, 149)
			})
		end

		if #v15 > 0 then
			local list2 = module.Shared.Breathings.List
			local info = {}
			local chances = {}

			for k, v19 in typeof(list2) == "table" and list2 or {} do
				if not CanDisplayBreathing(k, v19) then
					continue
				end

				local rarity = GetMostCommonRarity(v19)

				if not rarity then
					continue
				end

				info[k] = {
					Rarity = rarity,
					Icon = v19.Icon
				}
				local chance = v19.Chance
				chances[k] = {
					Name = k,
					Chance = (not module.Utils.Validator:ValidateNumber(chance) or chance <= 0) and 1 or chance
				}
			end

			local luck = GetLuck() -- equivalent call inferred; original call site unknown
			local v20 = (not module.Utils.Validator:ValidateNumber(luck) or luck <= -1) and 0 or luck
			local breathingsCooldown = module.Utils.PlayerStats.BreathingsCooldown(module.Data, module.Instance)

			if not module.Utils.Validator:ValidateNumber(breathingsCooldown) or breathingsCooldown <= 0 then
				breathingsCooldown = nil
			end

			v7 = true
			module.Gacha.Animation(breathingsCooldown or 2, v15, {
				Info = info,
				Chances = chances
			}, v20, {
				DropType = "Breathing",
				OnFinish = function(p3)
					v7 = false

					if not p3 and p2 == count then
						Breathings.CancelAuto()
					end

					if flag and p2 == count then
						Breathings.RefreshUI()
					end
				end
			})
		end

		Breathings.RefreshUI()
	else
		Breathings.CancelAuto()
		Breathings.RefreshUI()
		Notify("No Breathings were rolled. Please try again!") -- equivalent call inferred; original call site unknown
	end
end

module.Button:Create(buttons.Spin.Main, "Small"):BindFunction("Click", function()
	Breathings.Roll()
end)
module.Button:Create(buttons.Auto.Main, "Default"):BindFunction("Click", function()
	Breathings.StartAuto()
end)
module.Button:Create(stopBreathings.Main, "Default"):BindFunction("Click", function()
	Breathings.CancelAuto()
end)
module.Button:Create(buttons.Index.Main, "Default"):BindFunction("Click", function()
	Breathings.OpenIndex()
end)
module.Button:Create(current.Main, "Default"):BindFunction("Click", function()
	if v2 then
		Breathings.DeselectWeapon()
	else
		Breathings.OpenWeaponSelector()
	end
end)
module.Button:Create(main.Close.Main, "Close"):BindFunction("Click", function()
	Breathings.CloseIndex()
end)
module.Frame:OnFrameOpened(breathings, function()
	local v15 = v3
	v3 = nil
	Breathings.Start()

	if flag and v15 then
		Breathings.SelectWeapon(v15)
	end
end)
module.Frame:OnFrameClosed(breathings, function()
	Breathings.Close()
end)
script.Destroying:Connect(Breathings.Stop)
module.Button:Create(breathings.Currency.More, "Small"):BindFunction("Commerce", function()
	v3 = v2
	module.Signal:FireSelf("Interface", "GemProducts", "Open", "Breathings", "Breathings", "Breathings")
end)
return Breathings