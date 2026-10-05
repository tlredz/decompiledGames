local megapascal = {
	toAtmosphere = function(p: number)
		return p * 9.86923
	end,
	toKilopascal = function(p: number)
		return p * 1000
	end,
	toPascal = function(p: number)
		return p * 1000000
	end,
	toBar = function(p: number)
		return p * 10
	end,
	toMillibar = function(p: number)
		return p * 10000
	end,
	toPoundsPerSquareInch = function(p: number)
		return p * 145.038
	end,
	toRoblox = function(p: number)
		return p / 7.958727441543766
	end
}
local kilopascal = {
	toMegapascal = function(p: number)
		return p / 1000
	end
}

function kilopascal.toAtmosphere(p: number)
	return megapascal.toAtmosphere(kilopascal.toMegapascal(p))
end

function kilopascal.toPascal(p: number)
	return megapascal.toPascal(kilopascal.toMegapascal(p))
end

function kilopascal.toBar(p: number)
	return megapascal.toBar(kilopascal.toMegapascal(p))
end

function kilopascal.toMillibar(p: number)
	return megapascal.toMillibar(kilopascal.toMegapascal(p))
end

function kilopascal.toPoundsPerSquareInch(p: number)
	return megapascal.toPoundsPerSquareInch(kilopascal.toMegapascal(p))
end

function kilopascal.toRoblox(p: number)
	return megapascal.toRoblox(kilopascal.toMegapascal(p))
end

local pascal = {
	toMegapascal = function(p: number)
		return p / 1000000
	end
}

function pascal.toAtmosphere(p: number)
	return megapascal.toAtmosphere(pascal.toMegapascal(p))
end

function pascal.toPascal(p: number)
	return megapascal.toPascal(pascal.toMegapascal(p))
end

function pascal.toBar(p: number)
	return megapascal.toBar(pascal.toMegapascal(p))
end

function pascal.toMillibar(p: number)
	return megapascal.toMillibar(pascal.toMegapascal(p))
end

function pascal.toPoundsPerSquareInch(p: number)
	return megapascal.toPoundsPerSquareInch(pascal.toMegapascal(p))
end

function pascal.toRoblox(p: number)
	return megapascal.toRoblox(pascal.toMegapascal(p))
end

local atmosphere = {
	toMegapascal = function(p: number)
		return p / 9.86923
	end
}

function atmosphere.toKilopascal(p: number)
	return megapascal.toAtmosphere(atmosphere.toMegapascal(p))
end

function atmosphere.toPascal(p: number)
	return megapascal.toPascal(atmosphere.toMegapascal(p))
end

function atmosphere.toBar(p: number)
	return megapascal.toBar(atmosphere.toMegapascal(p))
end

function atmosphere.toMillibar(p: number)
	return megapascal.toMillibar(atmosphere.toMegapascal(p))
end

function atmosphere.toPoundsPerSquareInch(p: number)
	return megapascal.toPoundsPerSquareInch(atmosphere.toMegapascal(p))
end

function atmosphere.toRoblox(p: number)
	return megapascal.toRoblox(atmosphere.toMegapascal(p))
end

local bar = {
	toMegapascal = function(p: number)
		return p / 10
	end
}

function bar.toKilopascal(p: number)
	return megapascal.toAtmosphere(bar.toMegapascal(p))
end

function bar.toPascal(p: number)
	return megapascal.toPascal(bar.toMegapascal(p))
end

function bar.toAtmosphere(p: number)
	return megapascal.toAtmosphere(bar.toMegapascal(p))
end

function bar.toMillibar(p: number)
	return megapascal.toMillibar(bar.toMegapascal(p))
end

function bar.toPoundsPerSquareInch(p: number)
	return megapascal.toPoundsPerSquareInch(bar.toMegapascal(p))
end

function bar.toRoblox(p: number)
	return megapascal.toRoblox(bar.toMegapascal(p))
end

local poundsPerSquareInch = {
	toMegapascal = function(p: number)
		return p / 145.038
	end
}

function poundsPerSquareInch.toKilopascal(p: number)
	return megapascal.toAtmosphere(poundsPerSquareInch.toMegapascal(p))
end

function poundsPerSquareInch.toPascal(p: number)
	return megapascal.toPascal(poundsPerSquareInch.toMegapascal(p))
end

function poundsPerSquareInch.toAtmosphere(p: number)
	return megapascal.toAtmosphere(poundsPerSquareInch.toMegapascal(p))
end

function poundsPerSquareInch.toBar(p: number)
	return megapascal.toBar(poundsPerSquareInch.toMegapascal(p))
end

function poundsPerSquareInch.toMillibar(p: number)
	return megapascal.toMillibar(poundsPerSquareInch.toMegapascal(p))
end

function poundsPerSquareInch.toRoblox(p: number)
	return megapascal.toRoblox(poundsPerSquareInch.toMegapascal(p))
end

local roblox = {
	toMegapascal = function(p: number)
		return p * 7.958727441543766
	end
}

function roblox.toKilopascal(p: number)
	return megapascal.toKilopascal(roblox.toMegapascal(p))
end

function roblox.toPascal(p: number)
	return megapascal.toPascal(roblox.toMegapascal(p))
end

function roblox.toAtmosphere(p: number)
	return megapascal.toAtmosphere(roblox.toMegapascal(p))
end

function roblox.toBar(p: number)
	return megapascal.toBar(roblox.toMegapascal(p))
end

function roblox.toMillibar(p: number)
	return megapascal.toMillibar(roblox.toMegapascal(p))
end

function roblox.toPoundsPerSquareInch(p: number)
	return megapascal.toPoundsPerSquareInch(roblox.toMegapascal(p))
end

return {
	Megapascal = megapascal,
	Kilopascal = kilopascal,
	Pascal = pascal,
	Atmosphere = atmosphere,
	Bar = bar,
	Millibar = {
		toMegapascal = function(p: number)
			return p / 10000
		end,
		toKilopascal = function(p: number)
			return megapascal.toAtmosphere(bar.toMegapascal(p))
		end,
		toPascal = function(p: number)
			return megapascal.toPascal(bar.toMegapascal(p))
		end,
		toAtmosphere = function(p: number)
			return megapascal.toAtmosphere(bar.toMegapascal(p))
		end,
		toBar = function(p: number)
			return megapascal.toBar(bar.toMegapascal(p))
		end,
		toPoundsPerSquareInch = function(p: number)
			return megapascal.toPoundsPerSquareInch(bar.toMegapascal(p))
		end,
		toRoblox = function(p: number)
			return megapascal.toRoblox(bar.toMegapascal(p))
		end
	},
	PoundsPerSquareInch = poundsPerSquareInch,
	Roblox = roblox
}