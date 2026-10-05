local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.NPCManager.Types)
local frozen = table.freeze({
	Serious = "255828374",
	Sly = "238984437",
	Smug = "405706038",
	Furious = "277939506",
	Suspicious = "209715003",
	Tired = "141728515",
	Chill = "7074749"
})
return table.freeze({
	getFaceId = function(p, p2: string?)
		if p == "Default" then
			return p2
		end

		return assert(frozen[p], (`Unknown NPC expression {p}`))
	end
})