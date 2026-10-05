local metersPerSecond = {
	toKilometersPerHour = function(p: number)
		return p * 3.6
	end,
	toMilesPerHour = function(p: number)
		return p * 2.23694
	end,
	toFeetPerSecond = function(p: number)
		return p * 3.28084
	end,
	toKnot = function(p: number)
		return p * 1.94384
	end,
	toRoblox = function(p: number)
		return p * 3.57
	end
}
local kilometersPerHour = {
	toMetersPerSecond = function(p: number)
		return p / 3.6
	end
}

function kilometersPerHour.toMilesPerHour(p: number)
	return metersPerSecond.toMilesPerHour(kilometersPerHour.toMetersPerSecond(p))
end

function kilometersPerHour.toFeetPerSecond(p: number)
	return metersPerSecond.toFeetPerSecond(kilometersPerHour.toMetersPerSecond(p))
end

function kilometersPerHour.toKnot(p: number)
	return metersPerSecond.toKnot(kilometersPerHour.toMetersPerSecond(p))
end

function kilometersPerHour.toRoblox(p: number)
	return metersPerSecond.toRoblox(kilometersPerHour.toMetersPerSecond(p))
end

local milesPerHour = {
	toMetersPerSecond = function(p: number)
		return p / 2.23694
	end
}

function milesPerHour.toKilometersPerHour(p: number)
	return metersPerSecond.toKilometersPerHour(milesPerHour.toMetersPerSecond(p))
end

function milesPerHour.toFeetPerSecond(p: number)
	return metersPerSecond.toFeetPerSecond(milesPerHour.toMetersPerSecond(p))
end

function milesPerHour.toKnot(p: number)
	return metersPerSecond.toKnot(milesPerHour.toMetersPerSecond(p))
end

function milesPerHour.toRoblox(p: number)
	return metersPerSecond.toRoblox(milesPerHour.toMetersPerSecond(p))
end

local feetPerSecond = {
	toMetersPerSecond = function(p: number)
		return p / 3.28084
	end
}

function feetPerSecond.toKilometersPerHour(p: number)
	return metersPerSecond.toKilometersPerHour(feetPerSecond.toMetersPerSecond(p))
end

function feetPerSecond.toMilesPerHour(p: number)
	return metersPerSecond.toMilesPerHour(feetPerSecond.toMetersPerSecond(p))
end

function feetPerSecond.toKnot(p: number)
	return metersPerSecond.toKnot(feetPerSecond.toMetersPerSecond(p))
end

function feetPerSecond.toRoblox(p: number)
	return metersPerSecond.toRoblox(feetPerSecond.toMetersPerSecond(p))
end

local roblox = {
	toMetersPerSecond = function(p: number)
		return p / 3.57
	end
}

function roblox.toKilometersPerHour(p: number)
	return metersPerSecond.toKilometersPerHour(roblox.toMetersPerSecond(p))
end

function roblox.toMilesPerHour(p: number)
	return metersPerSecond.toMilesPerHour(roblox.toMetersPerSecond(p))
end

function roblox.toFeetPerSecond(p: number)
	return metersPerSecond.toFeetPerSecond(roblox.toMetersPerSecond(p))
end

function roblox.toKnot(p: number)
	return metersPerSecond.toKnot(roblox.toMetersPerSecond(p))
end

return {
	MetersPerSecond = metersPerSecond,
	KilometersPerHour = kilometersPerHour,
	MilesPerHour = milesPerHour,
	FeetPerSecond = feetPerSecond,
	Knot = {
		toMetersPerSecond = function(p: number)
			return p / 1.94384
		end,
		toKilometersPerHour = function(p: number)
			return metersPerSecond.toKilometersPerHour(feetPerSecond.toMetersPerSecond(p))
		end,
		toMilesPerHour = function(p: number)
			return metersPerSecond.toMilesPerHour(feetPerSecond.toMetersPerSecond(p))
		end,
		toFeetPerSecond = function(p: number)
			return metersPerSecond.toFeetPerSecond(feetPerSecond.toMetersPerSecond(p))
		end,
		toRoblox = function(p: number)
			return metersPerSecond.toRoblox(feetPerSecond.toMetersPerSecond(p))
		end
	},
	Roblox = roblox
}