local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local Controller = require(script.Parent.Parent.Controller)
local guilds = module.Interface:WaitForChild("Frames"):WaitForChild("Guilds")
local vault = guilds:WaitForChild("Main"):WaitForChild("Vault")
local balance = vault:WaitForChild("Balance")
local playerDonation = vault:WaitForChild("PlayerDonation")
local scroll = vault:WaitForChild("Upgrades"):WaitForChild("List"):WaitForChild("Scroll")
local upgrade = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Guilds"):WaitForChild("Upgrade")
local innerScopes = {}

local function GetPerkText(name: string, p2)
	local v = module.Shared.Perks[name] or {}
	return module.Utils.Multipliers.ToStringSingle({
		Name = name,
		RemoveName = true,
		ShowPercentage = not v.NumericOnly,
		MultiplierArray = { p2 }
	})
end

local function GetUpgradeEffectText(p, p2)
	local v = p2 or p

	if not v then
		return "No Bonus"
	end

	local v2, v3

	if v.Perks then
		v2, v3 = next(v.Perks)
	end

	if v2 and v3 then
		local v4 = v3.Type == "Add"
		local v5 = p and p.Perks and p.Perks[v2]
		local amount = v5 and v5.Amount or v4 and 0 or 1
		local perkText = GetPerkText(v2, {
			Type = v3.Type,
			Amount = amount
		})

		if not p2 then
			return (`{perkText} (MAX)`)
		end

		local amount2 = p2.Perks[v2].Amount
		local amount3

		if v4 then
			amount3 = amount2 - amount
		else
			amount3 = amount2 / amount
		end

		return (`{perkText} ({GetPerkText(v2, {
			Type = v3.Type,
			Amount = amount3
		})} next level)`)
	else
		if not v.TotalMembersAdded then
			return "No Bonus"
		end

		local totalMembersAdded = p and p.TotalMembersAdded or 0

		if p2 then
			return (`+{totalMembersAdded} Max Members (+{p2.TotalMembersAdded - totalMembersAdded} next level)`)
		end

		return (`+{totalMembersAdded} Max Members (MAX)`)
	end
end

local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = upgrade:Clone()
		self.Instance.Name = self.UpgradeId
		self.Instance.Main.Info.Title.Text = self.UpgradeInfo.Name
		module.Button:Create(self.Instance.Main.Upgrade.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Guilds", "BuyUpgrade", self.UpgradeId)
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		self:Update()
		return true
	end,
	Update = function(self)
		local v = not self.GuildData.Upgrades[self.UpgradeId] and 0 or self.GuildData.Upgrades[self.UpgradeId].Level or 0
		local v2 = #self.UpgradeInfo.Levels
		local isUpgradeMaxLevel = module.Shared.Guilds.IsUpgradeMaxLevel(self.UpgradeId, v)
		local v3

		if v > 0 then
			v3 = module.Shared.Guilds.GetUpgradeLevelInfo(self.UpgradeId, v)
		else
			v3 = false
		end

		local v4 = not isUpgradeMaxLevel and module.Shared.Guilds.GetNextUpgradeLevelInfo(self.UpgradeId, v)
		self.Instance.Main.Info.Title.Text = `{self.UpgradeInfo.Name} ({v}/{v2})`
		self.Instance.Main.Info.Desc.Text = GetUpgradeEffectText(v3 or nil, v4 or nil)

		if v4 then
			self.Instance.Main.Upgrade.Main.Title.Text = `{module.Utils.Number:Format(v4.Price.Amount)} {v4.Price.Name}`
		end

		local buyUpgrade = Controller.IsViewingOwnGuild() and not isUpgradeMaxLevel and module.Shared.Guilds.GetPermissions(module.Data.Guild.Rank) and module.Shared.Guilds.GetPermissions(module.Data.Guild.Rank).BuyUpgrade
		self.Instance.Main.Upgrade.Visible = buyUpgrade == true
	end
})
local Vault = {
	ClearUpgrades = function()
		for _, v in innerScopes do
			v.Instance:Destroy()
			v:doCleanup()
		end

		table.clear(innerScopes)
	end
}

function Vault.RefreshUpgrades(guildData)
	if not guildData then
		Vault.ClearUpgrades()
	elseif next(innerScopes) then
		for _, v in innerScopes do
			v.GuildData = guildData
			v:Update()
		end
	else
		local total = 0

		for k, upgrade2 in module.Shared.Guilds.Upgrades do
			local innerScope = scope:innerScope()
			innerScope.UpgradeId = k
			innerScope.UpgradeInfo = upgrade2
			innerScope.GuildData = guildData

			if innerScope:Build(total) then
				innerScopes[k] = innerScope
			else
				innerScope:doCleanup()
			end

			total += 0.05
		end
	end
end

function Vault.RefreshBalance(p)
	if not p then
		return
	end

	balance.Amount.Text = module.Utils.Number:Format(p.Vault.Yen)
	local member = p.Members[tostring(module.Instance.UserId)]
	playerDonation.Amount.Text = module.Utils.Number:Format(member and member.TotalDonated or 0)
	balance.Donate.Visible = Controller.IsViewingOwnGuild()
end

function Vault.Refresh()
	Vault.RefreshBalance(Controller.ViewingGuildData)
	Vault.RefreshUpgrades(Controller.ViewingGuildData)
end

function Vault.Init()
	Controller.GuildDataChanged:Connect(function()
		if Controller.CurrentTab ~= "Vault" then
			return
		end

		Vault.Refresh()
	end)
	Controller.TabChanged:Connect(function(p)
		if p == "Vault" then
			Vault.Refresh()
		else
			Vault.ClearUpgrades()
		end
	end)
	module.Frame:OnFrameClosed(guilds, Vault.ClearUpgrades)
	module.Button:Create(balance.Donate.Main, "Small"):BindFunction("Click", function()
		local yen = math.floor(module.Data.Yen or 0)

		if yen < 1 then
			module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
				Message = "You don't have enough Yen.",
				Color = Color3.fromRGB(255, 255, 0)
			})
		else
			module.Scripts.Interface.AmountSelector.Start({
				Start = 1,
				Minimum = 1,
				Maximum = yen,
				Callback = function(p: number)
					module.Signal:Fire("General", "Guilds", "Donate", p)
				end
			})
		end
	end)
end

return Vault