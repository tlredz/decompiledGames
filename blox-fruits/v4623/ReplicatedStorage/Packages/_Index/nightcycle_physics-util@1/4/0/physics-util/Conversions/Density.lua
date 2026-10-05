local gramPerCubicCentimeter = {
	toKilogramsPerCubicMeter = function(p: number)
		return p * 0.001
	end,
	toGramPerMilliliter = function(p: number)
		return p * 1e-6
	end,
	toRoblox = function(p: number)
		return p
	end
}
local gramPerMilliliter = {
	toGramPerCubicCentimeter = function(p: number)
		return p / 1e-6
	end
}

function gramPerMilliliter.toKilogramsPerCubicMeter(p: number)
	return gramPerCubicCentimeter.toKilogramsPerCubicMeter(gramPerMilliliter.toGramPerCubicCentimeter(p))
end

function gramPerMilliliter.toRoblox(p: number)
	return gramPerCubicCentimeter.toRoblox(gramPerMilliliter.toGramPerCubicCentimeter(p))
end

local kilogramsPerCubicMeter = {
	toGramPerCubicCentimeter = function(p: number)
		return p / 0.001
	end
}

function kilogramsPerCubicMeter.toKilogramsPerCubicMeter(p: number)
	return gramPerCubicCentimeter.toKilogramsPerCubicMeter(kilogramsPerCubicMeter.toGramPerCubicCentimeter(p))
end

function kilogramsPerCubicMeter.toRoblox(p: number)
	return gramPerCubicCentimeter.toRoblox(kilogramsPerCubicMeter.toGramPerCubicCentimeter(p))
end

local roblox = {
	toGramPerCubicCentimeter = function(p: number)
		return p
	end
}

function roblox.toKilogramsPerCubicMeter(p: number)
	return gramPerCubicCentimeter.toKilogramsPerCubicMeter(roblox.toGramPerCubicCentimeter(p))
end

function roblox.toGramPerMilliliter(p: number)
	return gramPerCubicCentimeter.toGramPerMilliliter(roblox.toGramPerCubicCentimeter(p))
end

return {
	GramPerCubicCentimeter = gramPerCubicCentimeter,
	KilogramsPerCubicMeter = kilogramsPerCubicMeter,
	GramPerMilliliter = gramPerMilliliter,
	Roblox = roblox
}