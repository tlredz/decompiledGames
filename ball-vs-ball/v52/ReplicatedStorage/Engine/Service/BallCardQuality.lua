local BallUpgradeRules = require(script.Parent.BallUpgradeRules)
return {
	templateNames = table.freeze({
		Classic = "经典",
		Shiny = "闪光",
		Rainbow = "彩虹",
		Mythic = "神话"
	}),
	kind = function(p, p2)
		if p2 and p2.isSpecial == true then
			return "Mythic"
		end

		if not p then
			return "Classic"
		end

		if p.serial ~= nil then
			return "Rainbow"
		end

		if BallUpgradeRules.killCount(p) == nil then
			return "Classic"
		end

		return "Shiny"
	end
}