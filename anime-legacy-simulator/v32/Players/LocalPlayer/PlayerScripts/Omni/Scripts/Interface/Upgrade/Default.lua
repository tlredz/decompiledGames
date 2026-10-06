local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local upgrade = module.Interface:WaitForChild("Frames"):WaitForChild("Upgrade")
local scroll = upgrade:WaitForChild("List"):WaitForChild("Scroll")
local currency = upgrade:WaitForChild("Currency")
local upgrade2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Upgrade"):WaitForChild("Default"):WaitForChild("Upgrade")
local innerScopes = {}
local v = nil
local v2 = nil
local Default = {}

local function GetPriceIcon(p)
	local v3 = nil

	if p.Type == "Item" then
		v3 = module.Shared.Items.List[p.Name]
	elseif p.Type == "Currency" then
		v3 = module.Shared.Perks[p.Name]
	end

	return v3 and v3.Icon or ""
end

local function FormatPerk(p, p2, p3)
	local numericOnly = module.Shared.Perks[p] and module.Shared.Perks[p].NumericOnly
	local amount = p2.Amount

	if p2.Type == "Multi" then
		return (p3 and "+" or "") .. module.Utils.Number:FormatDecimal(amount) .. "x"
	end

	if numericOnly then
		return "+" .. tostring(module.Utils.Number:Format(amount))
	end

	return "+" .. module.Utils.Number:FormatDecimal(amount * 100) .. "%"
end

local function GetDescription(name, info, currentLevel)
	local levelInformation = module.Shared.Upgrade.GetLevelInformation(v, name, currentLevel)

	if not levelInformation then
		return ""
	end

	local v3 = {}
	local v4 = {}

	for k in levelInformation.Perks do
		table.insert(v3, k)
	end

	table.sort(v3)

	for _, v5 in v3 do
		local perk = levelInformation.Perks[v5]
		local perk2 = info.Perks[v5]
		local formatPerk = FormatPerk(v5, perk, false)

		if #v3 > 1 then
			formatPerk = v5 .. ": " .. formatPerk
		end

		if not info.Manual and perk2 and perk2.Increasing then
			local increasing = perk2.Increasing
			local v7

			if increasing.Type == "Multi" then
				v7 = module.Utils.Number:FormatDecimal(increasing.Amount) .. "x"
			else
				v7 = FormatPerk(v5, {
					Type = perk.Type,
					Amount = increasing.Amount
				}, true)
			end

			formatPerk ..= " (" .. v7 .. " per level)"
		end

		table.insert(v4, formatPerk)
	end

	return table.concat(v4, ", ")
end

local function UpdateCurrency()
	currency.Visible = v2 ~= nil

	if not v2 then
		return
	end

	currency.Title.Text = tostring(module.Utils.Number:Format(module.Shared.Upgrade.GetPriceAmount(module.Data, v2)))
	local icon = currency.Icon
	local v3 = v2
	local v4 = nil

	if v3.Type == "Item" then
		v4 = module.Shared.Items.List[v3.Name]
	elseif v3.Type == "Currency" then
		v4 = module.Shared.Perks[v3.Name]
	end

	icon.Image = v4 and v4.Icon or ""
end

local v3 = {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = upgrade2:Clone()
		self.Instance.Name = self.Name
		self.Instance.LayoutOrder = self.Info.Index or 0
		self.Instance.Visible = true
		module.Button:Create(self.Instance.Main.Add.Main, "Small"):BindFunction("Click", function()
			if not v or module.Shared.Upgrade.GetCurrentLevel(v, self.Name, module.Data) >= self.Info.MaxLevel then
				return
			end

			module.Signal:Fire("General", "Upgrade", "Upgrade", v, self.Name)
		end)
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Update()
		self.Instance.Parent = scroll

		if duration > 0 then
			local thread = task.delay(duration, function()
				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
			table.insert(self, function()
				if coroutine.status(thread) == "dead" then
					return
				end

				task.cancel(thread)
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end
	end,
	Update = function(self)
		local currentLevel = module.Shared.Upgrade.GetCurrentLevel(v, self.Name, module.Data)
		local visible = self.Info.MaxLevel <= currentLevel
		local main = self.Instance.Main
		main.Title.Text = self.Name .. " (" .. currentLevel .. "/" .. self.Info.MaxLevel .. " Points)"
		main.Desc.Text = GetDescription(self.Name, self.Info, currentLevel)
		main.Icon.Image = self.Info.Icon or ""
		main.Add.Visible = not visible
		main.Maxed.Visible = visible
		local levelInformation = module.Shared.Upgrade.GetLevelInformation(v, self.Name, currentLevel + 1)

		if not levelInformation then
			main.Add.Visible = false
			return
		end

		main.Add.Main.Title.Text = tostring(module.Utils.Number:Format(levelInformation.Price.Amount))
		local icon = main.Add.Main.Icon
		local price = levelInformation.Price
		local v5 = nil

		if price.Type == "Item" then
			v5 = module.Shared.Items.List[price.Name]
		elseif price.Type == "Currency" then
			v5 = module.Shared.Perks[price.Name]
		end

		icon.Image = v5 and v5.Icon or ""
	end
}
local scope = fusion.scoped(fusion, v3)

function Default.UpdateAll()
	if not v then
		return
	end

	for _, v4 in innerScopes do
		v4:Update()
	end

	UpdateCurrency()
end

function Default.Generate()
	local v4 = module.Shared.Upgrade.List[v]
	local v5 = {}

	for k in v4.Upgrades do
		table.insert(v5, k)
	end

	table.sort(v5, function(a, b)
		local index = v4.Upgrades[a].Index or 0
		local index2 = v4.Upgrades[b].Index or 0

		if index == index2 then
			return a < b
		end

		return index < index2
	end)

	for k, name in v5 do
		if innerScopes[name] then
			continue
		end

		local innerScope = scope:innerScope()
		innerScope.Name = name
		innerScope.Info = v4.Upgrades[name]
		innerScope:Build((k - 1) * 0.05)
		innerScopes[name] = innerScope
	end
end

function Default.Clear()
	for _, v4 in innerScopes do
		v4.Instance:Destroy()
		v4:doCleanup()
	end

	table.clear(innerScopes)
end

function Default.Start(p: string)
	Default.Stop()
	v = p
	local v4 = module.Shared.Upgrade.List[p]

	for _, upgrade3 in v4.Upgrades do
		local price = upgrade3.Price

		if price and (not v2 or v2.Type == price.Type and v2.Name == price.Name) then
			v2 = price
		else
			v2 = nil
			break
		end
	end

	upgrade.Header.Title.Text = v4.Name
	scroll.CanvasPosition = Vector2.zero
	Default.Generate()
	UpdateCurrency()
	module.Frame:Open(upgrade)
end

function Default.Stop()
	Default.Clear()
	v = nil
	v2 = nil
end

module:OnDataChanged({}, function(_, _, list)
	local v4 = list[1]

	if v4 == "Upgrade" then
		Default.UpdateAll()
	elseif v and v2 and (v4 == v2.Name or v4 == "Items") then
		UpdateCurrency()
	end
end)
return Default