local module = require("../DynamicString")
local module2 = require("../../utils/GeneralUtils")
local SharedEnchants = {}
local v = {
	GetCurrentBoosts = function(self, p2: string?, p3, value: number?)
		local v2

		if p2 then
			v2 = self.Enchants[p2]
		end

		if not v2 then
			return {}
		end

		local v3 = value or 1
		local keeperbound

		if v3 == 1 then
			keeperbound = false
		else
			keeperbound = v2.Keeperbound or v2.KeeperboundAffix
		end

		if not (v2.ConditionalBoosts or keeperbound) then
			return v2
		end

		local copy = module2.copy(v2, true)

		if v2.ConditionalBoosts then
			local conditionalBoosts = copy:ConditionalBoosts(p3, v3)

			if conditionalBoosts then
				for k, conditionalBoost in conditionalBoosts do
					copy[k] = conditionalBoost
				end
			end
		end

		if not keeperbound then
			return copy
		end

		for k, v4 in copy do
			if typeof(v4) == "number" and k ~= "Durability" then
				copy[k] = v4 * v3
			end
		end

		if copy.PercentBoosts then
			for k, percentBoost in copy.PercentBoosts do
				local percentBoosts = copy.PercentBoosts
				local v4

				if percentBoost < 0 and v3 > 0 then
					v4 = percentBoost / v3
				else
					v4 = percentBoost * v3
				end

				percentBoosts[k] = v4
			end
		end

		if copy.Mutations then
			for _, mutation in copy.Mutations do
				mutation.Chance *= v3
			end
		end

		return copy
	end,
	ApplyToStats = function(self, p, items, p2)
		for _, ensureStat in self.EnsureStats do
			if typeof(p[ensureStat]) ~= "number" then
				p[ensureStat] = 0
			end
		end

		local v2 = {}

		for _, item in items do
			if not (item and self.Enchants[item]) then
				continue
			end

			local currentBoosts = self:GetCurrentBoosts(item, p2)

			for k, currentBoost in currentBoosts do
				if not (typeof(currentBoost) == "number" and typeof(p[k]) == "number") then
					continue
				end

				p[k] += currentBoost
			end

			if currentBoosts.PercentBoosts then
				for k, percentBoost in currentBoosts.PercentBoosts do
					v2[k] = (v2[k] or 0) + percentBoost
				end
			end

			if not currentBoosts.AllStatsPercent then
				continue
			end

			for _, percentStat in self.PercentStats do
				v2[percentStat] = (v2[percentStat] or 0) + currentBoosts.AllStatsPercent
			end
		end

		for k, v3 in v2 do
			if typeof(p[k]) ~= "number" then
				continue
			end

			if self.InverseStats[k] then
				p[k] /= v3 / 100 + 1
			else
				p[k] *= v3 / 100 + 1
			end
		end

		return p
	end,
	UpdateDescriptions = function(self)
		for _, enchant in self.Enchants do
			if not enchant._DescriptionTemplate then
				enchant._DescriptionTemplate = enchant.Description
			end

			enchant.Description = module:Format(enchant._DescriptionTemplate, enchant)
		end
	end,
	GetRichDisplayName = function(p, p2: string)
		local enchant = p.Enchants[p2]

		if not enchant then
			return p2
		end

		local v2

		if enchant.ColorGradient then
			local module3 = require("../../utils/FischUtils")
			v2 = module3.GradientRichText(enchant.Display, enchant.ColorGradient)
		else
			v2 = `<font color="#{enchant.Color:ToHex()}">{enchant.Display}</font>`
		end

		if enchant.ForceStroke then
			return (`<stroke color="#{enchant.StrokeColor:ToHex()}">{v2}</stroke>`)
		end

		return v2
	end
}

function SharedEnchants:extend(data)
	self.Enchants = data.Enchants
	self.PercentStats = data.PercentStats or {}
	self.InverseStats = data.InverseStats or {}
	self.EnsureStats = data.EnsureStats or {}

	for k, v2 in v do
		self[k] = v2
	end

	self:UpdateDescriptions()
	return self
end

function SharedEnchants.new(p)
	return SharedEnchants.extend({}, p)
end

return SharedEnchants