require(script.Parent._Types)
local TEMPLATE = {}
TEMPLATE.cooldown = 4
TEMPLATE.cooldownReductionPerUpgrade = 1
TEMPLATE.iconId = "rbxassetid://14520169908"

function TEMPLATE.canBeUsed(_)
	return true
end

function TEMPLATE.validateArguments(p)
	assert(typeof(p) == "table", "Bad arguments")
end

function TEMPLATE.localOwnerActivation(_, p)
	p.addCleaner(function() end)()
	p.addCleaner(Instance.new("Part"))
	p.clearAllCleaners()
	return {}
end

function TEMPLATE.anyClientActivationAsync(_, _, _) end

function TEMPLATE.serverActivationAsync(_, _, _) end

return TEMPLATE