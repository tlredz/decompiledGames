local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local whichLivesLonger = require(parent.Memory.whichLivesLonger)
local nameOf = require(parent.Utility.nameOf)
local CheckLifetime = {
	formatters = {}
}

function CheckLifetime.formatters.useFunction(p, p2)
	local v = nameOf(p, "object")
	return `The use()-d {nameOf(p2, "object")}`, (`the {v}`)
end

function CheckLifetime.formatters.boundProperty(p, p2, p3: string)
	local name = p.Name
	return `The {nameOf(p2, "value")} (bound to the {p3} property)`, (`the {name} instance`)
end

function CheckLifetime.formatters.boundAttribute(p, p2, p3: string)
	local name = p.Name
	return `The {nameOf(p2, "value")} (bound to the {p3} attribute)`, (`the {name} instance`)
end

function CheckLifetime.formatters.propertyOutputsTo(p, p2, p3: string)
	local name = p.Name
	return `The {nameOf(p2, "object")} (which the {p3} property outputs to)`, (`the {name} instance`)
end

function CheckLifetime.formatters.attributeOutputsTo(p, p2, p3: string)
	local name = p.Name
	return `The {nameOf(p2, "object")} (which the {p3} attribute outputs to)`, (`the {name} instance`)
end

function CheckLifetime.formatters.refOutputsTo(p, p2)
	local name = p.Name
	return `The {nameOf(p2, "object")} (which the Ref key outputs to)`, (`the {name} instance`)
end

function CheckLifetime.formatters.animationGoal(p, p2)
	local v = nameOf(p, "object")
	return `The goal {nameOf(p2, "object")}`, (`the {v} that is following it`)
end

function CheckLifetime.formatters.parameter(p, p2, p3)
	local v = nameOf(p, "object")
	local v2 = nameOf(p2, "object")

	if p3 == false then
		return `The {v2} parameter`, (`the {v} that it was used for`)
	end

	return `The {v2} representing the {p3} parameter`, (`the {v} that it was used for`)
end

function CheckLifetime.formatters.observer(p, p2)
	local v = nameOf(p, "object")
	return `The watched {nameOf(p2, "object")}`, (`the {v} that's observing it for changes`)
end

function CheckLifetime.bOutlivesA(p, p2, p3, p4, callback, ...)
	if p3 == nil then
		External.logError("useAfterDestroy", nil, callback(p2, p4, ...))
	elseif whichLivesLonger(p, p2, p3, p4) == "definitely-a" then
		local v, v2 = callback(p2, p4, ...)
		External.logWarn(
			"possiblyOutlives",
			v,
			v2,
			p == p3 and "they're in the same scope, but the latter is destroyed too quickly" or "the latter is in a different scope that gets destroyed too quickly"
		)
	end
end

return CheckLifetime