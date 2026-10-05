local joule = {
	toKilojoule = function(p: number)
		return p * 0.001
	end,
	toMegajoule = function(p: number)
		return p * 1e-6
	end,
	toCalorie = function(p: number)
		return p * 2.39006e-7
	end,
	toKilocalorie = function(p: number)
		return p * 0.000239006
	end,
	toBritishThermalUnit = function(p: number)
		return p * 0.000947817
	end,
	toGigajoule = function(p: number)
		return p * 9.999999999999999e-10
	end,
	toRoblox = function(p: number)
		return p * 0.581
	end
}
local kilojoule = {
	toJoule = function(p: number)
		return p / 0.001
	end
}

function kilojoule.toMegajoule(p: number)
	return joule.toMegajoule(kilojoule.toJoule(p))
end

function kilojoule.toCalorie(p: number)
	return joule.toCalorie(kilojoule.toJoule(p))
end

function kilojoule.toKilocalorie(p: number)
	return joule.toKilocalorie(kilojoule.toJoule(p))
end

function kilojoule.toBritishThermalUnit(p: number)
	return joule.toBritishThermalUnit(kilojoule.toJoule(p))
end

function kilojoule.toGigajoule(p: number)
	return joule.toGigajoule(kilojoule.toJoule(p))
end

function kilojoule.toRoblox(p: number)
	return joule.toRoblox(kilojoule.toJoule(p))
end

local megajoule = {
	toJoule = function(p: number)
		return p / 0.001
	end
}

function megajoule.toKilojoule(p: number)
	return joule.toKilojoule(megajoule.toJoule(p))
end

function megajoule.toCalorie(p: number)
	return joule.toCalorie(megajoule.toJoule(p))
end

function megajoule.toKilocalorie(p: number)
	return joule.toKilocalorie(megajoule.toJoule(p))
end

function megajoule.toBritishThermalUnit(p: number)
	return joule.toBritishThermalUnit(megajoule.toJoule(p))
end

function megajoule.toGigajoule(p: number)
	return joule.toGigajoule(megajoule.toJoule(p))
end

function megajoule.toRoblox(p: number)
	return joule.toRoblox(megajoule.toJoule(p))
end

local calorie = {
	toJoule = function(p: number)
		return p / 2.39006e-7
	end
}

function calorie.toKilojoule(p: number)
	return joule.toKilojoule(calorie.toJoule(p))
end

function calorie.toMegajoule(p: number)
	return joule.toMegajoule(calorie.toJoule(p))
end

function calorie.toKilocalorie(p: number)
	return joule.toKilocalorie(calorie.toJoule(p))
end

function calorie.toBritishThermalUnit(p: number)
	return joule.toBritishThermalUnit(calorie.toJoule(p))
end

function calorie.toGigajoule(p: number)
	return joule.toGigajoule(calorie.toJoule(p))
end

function calorie.toRoblox(p: number)
	return joule.toRoblox(calorie.toJoule(p))
end

local kilocalorie = {
	toJoule = function(p: number)
		return p / 2.39006e-7
	end
}

function kilocalorie.toKilojoule(p: number)
	return joule.toKilojoule(kilocalorie.toJoule(p))
end

function kilocalorie.toMegajoule(p: number)
	return joule.toMegajoule(kilocalorie.toJoule(p))
end

function kilocalorie.toCalorie(p: number)
	return joule.toCalorie(kilocalorie.toJoule(p))
end

function kilocalorie.toBritishThermalUnit(p: number)
	return joule.toBritishThermalUnit(kilocalorie.toJoule(p))
end

function kilocalorie.toGigajoule(p: number)
	return joule.toGigajoule(kilocalorie.toJoule(p))
end

function kilocalorie.toRoblox(p: number)
	return joule.toRoblox(kilocalorie.toJoule(p))
end

local britishThermalUnit = {
	toJoule = function(p: number)
		return p / 0.000947817
	end
}

function britishThermalUnit.toKilojoule(p: number)
	return joule.toKilojoule(britishThermalUnit.toJoule(p))
end

function britishThermalUnit.toMegajoule(p: number)
	return joule.toMegajoule(britishThermalUnit.toJoule(p))
end

function britishThermalUnit.toKilocalorie(p: number)
	return joule.toKilocalorie(britishThermalUnit.toJoule(p))
end

function britishThermalUnit.toCalorie(p: number)
	return joule.toCalorie(britishThermalUnit.toJoule(p))
end

function britishThermalUnit.toGigajoule(p: number)
	return joule.toGigajoule(britishThermalUnit.toJoule(p))
end

function britishThermalUnit.toRoblox(p: number)
	return joule.toRoblox(britishThermalUnit.toJoule(p))
end

local gigajoule = {
	toJoule = function(p: number)
		return p / 9.999999999999999e-10
	end
}

function gigajoule.toKilojoule(p: number)
	return joule.toKilojoule(gigajoule.toJoule(p))
end

function gigajoule.toMegajoule(p: number)
	return joule.toMegajoule(gigajoule.toJoule(p))
end

function gigajoule.toKilocalorie(p: number)
	return joule.toKilocalorie(gigajoule.toJoule(p))
end

function gigajoule.toCalorie(p: number)
	return joule.toCalorie(gigajoule.toJoule(p))
end

function gigajoule.toBritishThermalUnit(p: number)
	return joule.toBritishThermalUnit(gigajoule.toJoule(p))
end

function gigajoule.toRoblox(p: number)
	return joule.toRoblox(gigajoule.toJoule(p))
end

local roblox = {
	toJoule = function(p: number)
		return p / 0.581
	end
}

function roblox.toKilojoule(p: number)
	return joule.toKilojoule(roblox.toJoule(p))
end

function roblox.toMegajoule(p: number)
	return joule.toMegajoule(roblox.toJoule(p))
end

function roblox.toKilocalorie(p: number)
	return joule.toKilocalorie(roblox.toJoule(p))
end

function roblox.toCalorie(p: number)
	return joule.toCalorie(roblox.toJoule(p))
end

function roblox.toBritishThermalUnit(p: number)
	return joule.toBritishThermalUnit(roblox.toJoule(p))
end

function roblox.toGigajoule(p: number)
	return joule.toGigajoule(roblox.toJoule(p))
end

return {
	Joule = joule,
	Kilojoule = kilojoule,
	Megajoule = megajoule,
	Calorie = calorie,
	Kilocalorie = kilocalorie,
	BritishThermalUnit = britishThermalUnit,
	Gigajoule = gigajoule,
	Roblox = roblox
}