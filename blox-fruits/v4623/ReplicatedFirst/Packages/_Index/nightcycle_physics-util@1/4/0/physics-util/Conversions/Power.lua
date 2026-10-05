local kilowatt = {
	toWatt = function(p: number)
		return p * 1000
	end,
	toMegawatt = function(p: number)
		return p * 0.001
	end,
	toGigawatt = function(p: number)
		return p * 1e-6
	end,
	toHorsepower = function(p: number)
		return p * 0.7457
	end,
	toFootPoundsPerMinute = function(p: number)
		return p * 43478.260869565216
	end,
	toKilogramMetersPerSecond = function(p: number)
		return p * 0.0098
	end,
	toRoblox = function(p: number)
		return p * 581.9100000000001
	end
}
local watt = {
	toKilowatt = function(p: number)
		return p / 1000
	end
}

function watt.toMegawatt(p: number)
	return kilowatt.toMegawatt(watt.toKilowatt(p))
end

function watt.toGigawatt(p: number)
	return kilowatt.toGigawatt(watt.toKilowatt(p))
end

function watt.toHorsepower(p: number)
	return kilowatt.toHorsepower(watt.toKilowatt(p))
end

function watt.toFootPoundsPerMinute(p: number)
	return kilowatt.toFootPoundsPerMinute(watt.toKilowatt(p))
end

function watt.toKilogramMetersPerSecond(p: number)
	return kilowatt.toKilogramMetersPerSecond(watt.toKilowatt(p))
end

function watt.toRoblox(p: number)
	return kilowatt.toRoblox(watt.toKilowatt(p))
end

local megawatt = {
	toKilowatt = function(p: number)
		return p / 0.001
	end
}

function megawatt.toWatt(p: number)
	return kilowatt.toMegawatt(megawatt.toKilowatt(p))
end

function megawatt.toGigawatt(p: number)
	return kilowatt.toGigawatt(megawatt.toKilowatt(p))
end

function megawatt.toHorsepower(p: number)
	return kilowatt.toHorsepower(megawatt.toKilowatt(p))
end

function megawatt.toFootPoundsPerMinute(p: number)
	return kilowatt.toFootPoundsPerMinute(megawatt.toKilowatt(p))
end

function megawatt.toKilogramMetersPerSecond(p: number)
	return kilowatt.toKilogramMetersPerSecond(megawatt.toKilowatt(p))
end

function megawatt.toRoblox(p: number)
	return kilowatt.toRoblox(megawatt.toKilowatt(p))
end

local gigawatt = {
	toKilowatt = function(p: number)
		return p / 1e-6
	end
}

function gigawatt.toWatt(p: number)
	return kilowatt.toMegawatt(gigawatt.toKilowatt(p))
end

function gigawatt.toMegawatt(p: number)
	return kilowatt.toMegawatt(gigawatt.toKilowatt(p))
end

function gigawatt.toHorsepower(p: number)
	return kilowatt.toHorsepower(gigawatt.toKilowatt(p))
end

function gigawatt.toFootPoundsPerMinute(p: number)
	return kilowatt.toFootPoundsPerMinute(gigawatt.toKilowatt(p))
end

function gigawatt.toKilogramMetersPerSecond(p: number)
	return kilowatt.toKilogramMetersPerSecond(gigawatt.toKilowatt(p))
end

function gigawatt.toRoblox(p: number)
	return kilowatt.toRoblox(gigawatt.toKilowatt(p))
end

local horsepower = {
	toKilowatt = function(p: number)
		return p / 1e-6
	end
}

function horsepower.toWatt(p: number)
	return kilowatt.toMegawatt(horsepower.toKilowatt(p))
end

function horsepower.toMegawatt(p: number)
	return kilowatt.toMegawatt(horsepower.toKilowatt(p))
end

function horsepower.toGigawatt(p: number)
	return kilowatt.toGigawatt(horsepower.toKilowatt(p))
end

function horsepower.toFootPoundsPerMinute(p: number)
	return kilowatt.toFootPoundsPerMinute(horsepower.toKilowatt(p))
end

function horsepower.toKilogramMetersPerSecond(p: number)
	return kilowatt.toKilogramMetersPerSecond(horsepower.toKilowatt(p))
end

function horsepower.toRoblox(p: number)
	return kilowatt.toRoblox(horsepower.toKilowatt(p))
end

local footPoundsPerMinute = {
	toKilowatt = function(p: number)
		return p / 1e-6
	end
}

function footPoundsPerMinute.toWatt(p: number)
	return kilowatt.toMegawatt(footPoundsPerMinute.toKilowatt(p))
end

function footPoundsPerMinute.toMegawatt(p: number)
	return kilowatt.toMegawatt(footPoundsPerMinute.toKilowatt(p))
end

function footPoundsPerMinute.toGigawatt(p: number)
	return kilowatt.toGigawatt(footPoundsPerMinute.toKilowatt(p))
end

function footPoundsPerMinute.toHorsepower(p: number)
	return kilowatt.toHorsepower(footPoundsPerMinute.toKilowatt(p))
end

function footPoundsPerMinute.toKilogramMetersPerSecond(p: number)
	return kilowatt.toKilogramMetersPerSecond(footPoundsPerMinute.toKilowatt(p))
end

function footPoundsPerMinute.toRoblox(p: number)
	return kilowatt.toRoblox(footPoundsPerMinute.toKilowatt(p))
end

local roblox = {
	toKilowatt = function(p: number)
		return p / 581.9100000000001
	end
}

function roblox.toWatt(p: number)
	return kilowatt.toWatt(roblox.toKilowatt(p))
end

function roblox.toMegawatt(p: number)
	return kilowatt.toMegawatt(roblox.toKilowatt(p))
end

function roblox.toGigawatt(p: number)
	return kilowatt.toGigawatt(roblox.toKilowatt(p))
end

function roblox.toHorsepower(p: number)
	return kilowatt.toHorsepower(roblox.toKilowatt(p))
end

function roblox.toKilogramMetersPerSecond(p: number)
	return kilowatt.toKilogramMetersPerSecond(roblox.toKilowatt(p))
end

function roblox.toFootPoundsPerMinute(p: number)
	return kilowatt.toFootPoundsPerMinute(roblox.toKilowatt(p))
end

return {
	Kilowatt = kilowatt,
	Watt = watt,
	Megawatt = megawatt,
	Gigawatt = gigawatt,
	Horsepower = horsepower,
	FootPoundsPerMinute = footPoundsPerMinute,
	Roblox = roblox
}