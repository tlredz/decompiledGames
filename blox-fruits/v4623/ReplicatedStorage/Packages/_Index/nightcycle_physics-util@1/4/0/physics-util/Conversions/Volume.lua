local liter = {
	toMilliliter = function(p: number)
		return p * 1000
	end,
	toKiloliter = function(p: number)
		return p * 0.001
	end,
	toCup = function(p: number)
		return p * 4.16667
	end,
	toPint = function(p: number)
		return p * 2.11338
	end,
	toQuart = function(p: number)
		return p * 1.05669
	end,
	toGallon = function(p: number)
		return p * 0.264172
	end,
	toCubicFeet = function(p: number)
		return p * 0.0353147
	end,
	toCubicInch = function(p: number)
		return p * 61.0237
	end,
	toCubicMeter = function(p: number)
		return p * 0.001
	end
}

function liter.toRoblox(p: number)
	return liter.toCubicMeter(p) / 0.021952
end

local milliliter = {
	toLiter = function(p: number)
		return p / 1000
	end
}

function milliliter.toKiloliter(p: number)
	return liter.toKiloliter(milliliter.toLiter(p))
end

function milliliter.toCup(p: number)
	return liter.toCup(milliliter.toLiter(p))
end

function milliliter.toPint(p: number)
	return liter.toPint(milliliter.toLiter(p))
end

function milliliter.toQuart(p: number)
	return liter.toQuart(milliliter.toLiter(p))
end

function milliliter.toGallon(p: number)
	return liter.toGallon(milliliter.toLiter(p))
end

function milliliter.toCubicFeet(p: number)
	return liter.toCubicFeet(milliliter.toLiter(p))
end

function milliliter.toCubicInch(p: number)
	return liter.toCubicInch(milliliter.toLiter(p))
end

function milliliter.toCubicMeter(p: number)
	return liter.toCubicMeter(milliliter.toLiter(p))
end

function milliliter.toRoblox(p: number)
	return liter.toRoblox(milliliter.toLiter(p))
end

local kiloliter = {
	toLiter = function(p: number)
		return p / 0.001
	end
}

function kiloliter.toMilliliter(p: number)
	return liter.toMilliliter(kiloliter.toLiter(p))
end

function kiloliter.toCup(p: number)
	return liter.toCup(kiloliter.toLiter(p))
end

function kiloliter.toPint(p: number)
	return liter.toPint(kiloliter.toLiter(p))
end

function kiloliter.toQuart(p: number)
	return liter.toQuart(kiloliter.toLiter(p))
end

function kiloliter.toGallon(p: number)
	return liter.toGallon(kiloliter.toLiter(p))
end

function kiloliter.toCubicFeet(p: number)
	return liter.toCubicFeet(kiloliter.toLiter(p))
end

function kiloliter.toCubicInch(p: number)
	return liter.toCubicInch(kiloliter.toLiter(p))
end

function kiloliter.toCubicMeter(p: number)
	return liter.toCubicMeter(kiloliter.toLiter(p))
end

function kiloliter.toRoblox(p: number)
	return liter.toRoblox(kiloliter.toLiter(p))
end

local cup = {
	toLiter = function(p: number)
		return p / 4.16667
	end
}

function cup.toKiloliter(p: number)
	return liter.toKiloliter(cup.toLiter(p))
end

function cup.toMilliliter(p: number)
	return liter.toMilliliter(cup.toLiter(p))
end

function cup.toPint(p: number)
	return liter.toPint(cup.toLiter(p))
end

function cup.toQuart(p: number)
	return liter.toQuart(cup.toLiter(p))
end

function cup.toGallon(p: number)
	return liter.toGallon(cup.toLiter(p))
end

function cup.toCubicFeet(p: number)
	return liter.toCubicFeet(cup.toLiter(p))
end

function cup.toCubicInch(p: number)
	return liter.toCubicInch(cup.toLiter(p))
end

function cup.toCubicMeter(p: number)
	return liter.toCubicMeter(cup.toLiter(p))
end

function cup.toRoblox(p: number)
	return liter.toRoblox(cup.toLiter(p))
end

local pint = {
	toLiter = function(p: number)
		return p / 2.11338
	end
}

function pint.toKiloliter(p: number)
	return liter.toKiloliter(pint.toLiter(p))
end

function pint.toCup(p: number)
	return liter.toCup(pint.toLiter(p))
end

function pint.toMilliliter(p: number)
	return liter.toMilliliter(pint.toLiter(p))
end

function pint.toQuart(p: number)
	return liter.toQuart(pint.toLiter(p))
end

function pint.toGallon(p: number)
	return liter.toGallon(pint.toLiter(p))
end

function pint.toCubicFeet(p: number)
	return liter.toCubicFeet(pint.toLiter(p))
end

function pint.toCubicInch(p: number)
	return liter.toCubicInch(pint.toLiter(p))
end

function pint.toCubicMeter(p: number)
	return liter.toCubicMeter(pint.toLiter(p))
end

function pint.toRoblox(p: number)
	return liter.toRoblox(pint.toLiter(p))
end

local quart = {
	toLiter = function(p: number)
		return p / 1.05669
	end
}

function quart.toKiloliter(p: number)
	return liter.toKiloliter(quart.toLiter(p))
end

function quart.toCup(p: number)
	return liter.toCup(quart.toLiter(p))
end

function quart.toPint(p: number)
	return liter.toPint(quart.toLiter(p))
end

function quart.toMilliliter(p: number)
	return liter.toMilliliter(quart.toLiter(p))
end

function quart.toGallon(p: number)
	return liter.toGallon(quart.toLiter(p))
end

function quart.toCubicFeet(p: number)
	return liter.toCubicFeet(quart.toLiter(p))
end

function quart.toCubicInch(p: number)
	return liter.toCubicInch(quart.toLiter(p))
end

function quart.toCubicMeter(p: number)
	return liter.toCubicMeter(quart.toLiter(p))
end

function quart.toRoblox(p: number)
	return liter.toRoblox(quart.toLiter(p))
end

local gallon = {
	toLiter = function(p: number)
		return p / 0.264172
	end
}

function gallon.toKiloliter(p: number)
	return liter.toKiloliter(gallon.toLiter(p))
end

function gallon.toCup(p: number)
	return liter.toCup(gallon.toLiter(p))
end

function gallon.toPint(p: number)
	return liter.toPint(gallon.toLiter(p))
end

function gallon.toQuart(p: number)
	return liter.toQuart(gallon.toLiter(p))
end

function gallon.toMilliliter(p: number)
	return liter.toMilliliter(gallon.toLiter(p))
end

function gallon.toCubicFeet(p: number)
	return liter.toCubicFeet(gallon.toLiter(p))
end

function gallon.toCubicInch(p: number)
	return liter.toCubicInch(gallon.toLiter(p))
end

function gallon.toCubicMeter(p: number)
	return liter.toCubicMeter(gallon.toLiter(p))
end

function gallon.toRoblox(p: number)
	return liter.toRoblox(gallon.toLiter(p))
end

local cubicFeet = {
	toLiter = function(p: number)
		return p / 0.0353147
	end
}

function cubicFeet.toKiloliter(p: number)
	return liter.toKiloliter(cubicFeet.toLiter(p))
end

function cubicFeet.toCup(p: number)
	return liter.toCup(cubicFeet.toLiter(p))
end

function cubicFeet.toPint(p: number)
	return liter.toPint(cubicFeet.toLiter(p))
end

function cubicFeet.toQuart(p: number)
	return liter.toQuart(cubicFeet.toLiter(p))
end

function cubicFeet.toGallon(p: number)
	return liter.toGallon(cubicFeet.toLiter(p))
end

function cubicFeet.toMilliliter(p: number)
	return liter.toMilliliter(cubicFeet.toLiter(p))
end

function cubicFeet.toCubicInch(p: number)
	return liter.toCubicInch(cubicFeet.toLiter(p))
end

function cubicFeet.toCubicMeter(p: number)
	return liter.toCubicMeter(cubicFeet.toLiter(p))
end

function cubicFeet.toRoblox(p: number)
	return liter.toRoblox(cubicFeet.toLiter(p))
end

local cubicInch = {
	toLiter = function(p: number)
		return p / 1000
	end
}

function cubicInch.toKiloliter(p: number)
	return liter.toKiloliter(cubicInch.toLiter(p))
end

function cubicInch.toCup(p: number)
	return liter.toCup(cubicInch.toLiter(p))
end

function cubicInch.toPint(p: number)
	return liter.toPint(cubicInch.toLiter(p))
end

function cubicInch.toQuart(p: number)
	return liter.toQuart(cubicInch.toLiter(p))
end

function cubicInch.toGallon(p: number)
	return liter.toGallon(cubicInch.toLiter(p))
end

function cubicInch.toCubicFeet(p: number)
	return liter.toCubicFeet(cubicInch.toLiter(p))
end

function cubicInch.toMilliliter(p: number)
	return liter.toMilliliter(cubicInch.toLiter(p))
end

function cubicInch.toCubicMeter(p: number)
	return liter.toCubicMeter(cubicInch.toLiter(p))
end

function cubicInch.toRoblox(p: number)
	return liter.toRoblox(cubicInch.toLiter(p))
end

local v10 = {
	toLiter = function(p: number)
		return p / 0.001
	end
}

function v10.toKiloliter(p: number)
	return liter.toKiloliter(v10.toLiter(p))
end

function v10.toCup(p: number)
	return liter.toCup(v10.toLiter(p))
end

function v10.toPint(p: number)
	return liter.toPint(v10.toLiter(p))
end

function v10.toQuart(p: number)
	return liter.toQuart(v10.toLiter(p))
end

function v10.toGallon(p: number)
	return liter.toGallon(v10.toLiter(p))
end

function v10.toCubicFeet(p: number)
	return liter.toCubicFeet(v10.toLiter(p))
end

function v10.toCubicInch(p: number)
	return liter.toCubicInch(v10.toLiter(p))
end

function v10.toMilliliter(p: number)
	return liter.toMilliliter(v10.toLiter(p))
end

function v10.toRoblox(p: number)
	return liter.toRoblox(v10.toLiter(p))
end

local roblox = {
	toCubicMeter = function(p: number)
		return p * 0.021952
	end
}

function roblox.toLiter(p: number)
	return v10.toLiter(roblox.toCubicMeter(p))
end

function roblox.toKiloliter(p: number)
	return v10.toKiloliter(roblox.toCubicMeter(p))
end

function roblox.toCup(p: number)
	return v10.toCup(roblox.toCubicMeter(p))
end

function roblox.toPint(p: number)
	return v10.toPint(roblox.toCubicMeter(p))
end

function roblox.toQuart(p: number)
	return v10.toQuart(roblox.toCubicMeter(p))
end

function roblox.toGallon(p: number)
	return v10.toGallon(roblox.toCubicMeter(p))
end

function roblox.toCubicFeet(p: number)
	return v10.toCubicFeet(roblox.toCubicMeter(p))
end

function roblox.toCubicInch(p: number)
	return v10.toCubicInch(roblox.toCubicMeter(p))
end

function roblox.toMilliliter(p: number)
	return v10.toMilliliter(roblox.toCubicMeter(p))
end

return {
	Liter = liter,
	Milliliter = milliliter,
	Kiloliter = kiloliter,
	Cup = cup,
	Pint = pint,
	Quart = quart,
	Gallon = gallon,
	CubicFeet = cubicFeet,
	CubicInch = cubicInch,
	Roblox = roblox
}