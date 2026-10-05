local squareMeter = {
	toSquareCentimeter = function(p: number)
		return p * 10000
	end,
	toSquareMillimeter = function(p: number)
		return p * 1000000
	end,
	toSquareKilometer = function(p: number)
		return p * 1e-6
	end,
	toSquareMile = function(p: number)
		return p * 3.861e-7
	end,
	toSquareYard = function(p: number)
		return p * 1.19599
	end,
	toSquareFeet = function(p: number)
		return p * 10.7639
	end,
	toSquareInch = function(p: number)
		return p * 1550
	end,
	toHectare = function(p: number)
		return p * 0.0001
	end,
	toAcre = function(p: number)
		return p * 0.000247105
	end,
	toRoblox = function(p: number)
		return p / 0.0784
	end
}
local squareCentimeter = {
	toSquareMeter = function(p: number)
		return p / 10000
	end
}

function squareCentimeter.toSquareMillimeter(p: number)
	return squareMeter.toSquareMillimeter(squareCentimeter.toSquareMeter(p))
end

function squareCentimeter.toSquareKilometer(p: number)
	return squareMeter.toSquareKilometer(squareCentimeter.toSquareMeter(p))
end

function squareCentimeter.toSquareMile(p: number)
	return squareMeter.toSquareMile(squareCentimeter.toSquareMeter(p))
end

function squareCentimeter.toSquareYard(p: number)
	return squareMeter.toSquareYard(squareCentimeter.toSquareMeter(p))
end

function squareCentimeter.toSquareFeet(p: number)
	return squareMeter.toSquareFeet(squareCentimeter.toSquareMeter(p))
end

function squareCentimeter.toSquareInch(p: number)
	return squareMeter.toSquareInch(squareCentimeter.toSquareMeter(p))
end

function squareCentimeter.toHectare(p: number)
	return squareMeter.toHectare(squareCentimeter.toSquareMeter(p))
end

function squareCentimeter.toAcre(p: number)
	return squareMeter.toAcre(squareCentimeter.toSquareMeter(p))
end

function squareCentimeter.toRoblox(p: number)
	return squareMeter.toRoblox(squareCentimeter.toSquareMeter(p))
end

local squareMillimeter = {
	toSquareMeter = function(p: number)
		return p / 1000000
	end
}

function squareMillimeter.toSquareCentimeter(p: number)
	return squareMeter.toSquareCentimeter(squareMillimeter.toSquareMeter(p))
end

function squareMillimeter.toSquareKilometer(p: number)
	return squareMeter.toSquareKilometer(squareMillimeter.toSquareMeter(p))
end

function squareMillimeter.toSquareMile(p: number)
	return squareMeter.toSquareMile(squareMillimeter.toSquareMeter(p))
end

function squareMillimeter.toSquareYard(p: number)
	return squareMeter.toSquareYard(squareMillimeter.toSquareMeter(p))
end

function squareMillimeter.toSquareFeet(p: number)
	return squareMeter.toSquareFeet(squareMillimeter.toSquareMeter(p))
end

function squareMillimeter.toSquareInch(p: number)
	return squareMeter.toSquareInch(squareMillimeter.toSquareMeter(p))
end

function squareMillimeter.toHectare(p: number)
	return squareMeter.toHectare(squareMillimeter.toSquareMeter(p))
end

function squareMillimeter.toAcre(p: number)
	return squareMeter.toAcre(squareMillimeter.toSquareMeter(p))
end

function squareMillimeter.toRoblox(p: number)
	return squareMeter.toRoblox(squareMillimeter.toSquareMeter(p))
end

local squareFeet = {
	toSquareMeter = function(p: number)
		return p / 10.7639
	end
}

function squareFeet.toSquareMillimeter(p: number)
	return squareMeter.toSquareMillimeter(squareFeet.toSquareMeter(p))
end

function squareFeet.toSquareKilometer(p: number)
	return squareMeter.toSquareKilometer(squareFeet.toSquareMeter(p))
end

function squareFeet.toSquareMile(p: number)
	return squareMeter.toSquareMile(squareFeet.toSquareMeter(p))
end

function squareFeet.toSquareYard(p: number)
	return squareMeter.toSquareYard(squareFeet.toSquareMeter(p))
end

function squareFeet.toSquareCentimeter(p: number)
	return squareMeter.toSquareCentimeter(squareFeet.toSquareMeter(p))
end

function squareFeet.toSquareInch(p: number)
	return squareMeter.toSquareInch(squareFeet.toSquareMeter(p))
end

function squareFeet.toHectare(p: number)
	return squareMeter.toHectare(squareFeet.toSquareMeter(p))
end

function squareFeet.toAcre(p: number)
	return squareMeter.toAcre(squareFeet.toSquareMeter(p))
end

function squareFeet.toRoblox(p: number)
	return squareMeter.toRoblox(squareFeet.toSquareMeter(p))
end

local squareInch = {
	toSquareMeter = function(p: number)
		return p / 1550
	end
}

function squareInch.toSquareMillimeter(p: number)
	return squareMeter.toSquareMillimeter(squareInch.toSquareMeter(p))
end

function squareInch.toSquareKilometer(p: number)
	return squareMeter.toSquareKilometer(squareInch.toSquareMeter(p))
end

function squareInch.toSquareMile(p: number)
	return squareMeter.toSquareMile(squareInch.toSquareMeter(p))
end

function squareInch.toSquareYard(p: number)
	return squareMeter.toSquareYard(squareInch.toSquareMeter(p))
end

function squareInch.toSquareCentimeter(p: number)
	return squareMeter.toSquareCentimeter(squareInch.toSquareMeter(p))
end

function squareInch.toSquareInch(p: number)
	return squareMeter.toSquareInch(squareInch.toSquareMeter(p))
end

function squareInch.toHectare(p: number)
	return squareMeter.toHectare(squareInch.toSquareMeter(p))
end

function squareInch.toAcre(p: number)
	return squareMeter.toAcre(squareInch.toSquareMeter(p))
end

function squareInch.toRoblox(p: number)
	return squareMeter.toRoblox(squareInch.toSquareMeter(p))
end

local squareYard = {
	toSquareMeter = function(p: number)
		return p / 10000
	end
}

function squareYard.toSquareMillimeter(p: number)
	return squareMeter.toSquareMillimeter(squareYard.toSquareMeter(p))
end

function squareYard.toSquareKilometer(p: number)
	return squareMeter.toSquareKilometer(squareYard.toSquareMeter(p))
end

function squareYard.toSquareMile(p: number)
	return squareMeter.toSquareMile(squareYard.toSquareMeter(p))
end

function squareYard.toSquareCentimeter(p: number)
	return squareMeter.toSquareCentimeter(squareYard.toSquareMeter(p))
end

function squareYard.toSquareFeet(p: number)
	return squareMeter.toSquareFeet(squareYard.toSquareMeter(p))
end

function squareYard.toSquareInch(p: number)
	return squareMeter.toSquareInch(squareYard.toSquareMeter(p))
end

function squareYard.toHectare(p: number)
	return squareMeter.toHectare(squareYard.toSquareMeter(p))
end

function squareYard.toAcre(p: number)
	return squareMeter.toAcre(squareYard.toSquareMeter(p))
end

function squareYard.toRoblox(p: number)
	return squareMeter.toRoblox(squareYard.toSquareMeter(p))
end

local squareKilometer = {
	toSquareMeter = function(p: number)
		return p / 1e-6
	end
}

function squareKilometer.toSquareMillimeter(p: number)
	return squareMeter.toSquareMillimeter(squareKilometer.toSquareMeter(p))
end

function squareKilometer.toSquareCentimeter(p: number)
	return squareMeter.toSquareCentimeter(squareKilometer.toSquareMeter(p))
end

function squareKilometer.toSquareMile(p: number)
	return squareMeter.toSquareMile(squareKilometer.toSquareMeter(p))
end

function squareKilometer.toSquareYard(p: number)
	return squareMeter.toSquareYard(squareKilometer.toSquareMeter(p))
end

function squareKilometer.toSquareFeet(p: number)
	return squareMeter.toSquareFeet(squareKilometer.toSquareMeter(p))
end

function squareKilometer.toSquareInch(p: number)
	return squareMeter.toSquareInch(squareKilometer.toSquareMeter(p))
end

function squareKilometer.toHectare(p: number)
	return squareMeter.toHectare(squareKilometer.toSquareMeter(p))
end

function squareKilometer.toAcre(p: number)
	return squareMeter.toAcre(squareKilometer.toSquareMeter(p))
end

function squareKilometer.toRoblox(p: number)
	return squareMeter.toRoblox(squareKilometer.toSquareMeter(p))
end

local squareMile = {
	toSquareMeter = function(p: number)
		return p / 10000
	end
}

function squareMile.toSquareMillimeter(p: number)
	return squareMeter.toSquareMillimeter(squareMile.toSquareMeter(p))
end

function squareMile.toSquareKilometer(p: number)
	return squareMeter.toSquareKilometer(squareMile.toSquareMeter(p))
end

function squareMile.toSquareCentimeter(p: number)
	return squareMeter.toSquareCentimeter(squareMile.toSquareMeter(p))
end

function squareMile.toSquareYard(p: number)
	return squareMeter.toSquareYard(squareMile.toSquareMeter(p))
end

function squareMile.toSquareFeet(p: number)
	return squareMeter.toSquareFeet(squareMile.toSquareMeter(p))
end

function squareMile.toSquareInch(p: number)
	return squareMeter.toSquareInch(squareMile.toSquareMeter(p))
end

function squareMile.toHectare(p: number)
	return squareMeter.toHectare(squareMile.toSquareMeter(p))
end

function squareMile.toAcre(p: number)
	return squareMeter.toAcre(squareMile.toSquareMeter(p))
end

function squareMile.toRoblox(p: number)
	return squareMeter.toRoblox(squareMile.toSquareMeter(p))
end

local acre = {
	toSquareMeter = function(p: number)
		return p / 0.000247105
	end
}

function acre.toSquareMillimeter(p: number)
	return squareMeter.toSquareMillimeter(acre.toSquareMeter(p))
end

function acre.toSquareKilometer(p: number)
	return squareMeter.toSquareKilometer(acre.toSquareMeter(p))
end

function acre.toSquareMile(p: number)
	return squareMeter.toSquareMile(acre.toSquareMeter(p))
end

function acre.toSquareYard(p: number)
	return squareMeter.toSquareYard(acre.toSquareMeter(p))
end

function acre.toSquareFeet(p: number)
	return squareMeter.toSquareFeet(acre.toSquareMeter(p))
end

function acre.toSquareInch(p: number)
	return squareMeter.toSquareInch(acre.toSquareMeter(p))
end

function acre.toHectare(p: number)
	return squareMeter.toHectare(acre.toSquareMeter(p))
end

function acre.toSquareCentimeter(p: number)
	return squareMeter.toAcre(acre.toSquareMeter(p))
end

function acre.toRoblox(p: number)
	return squareMeter.toRoblox(acre.toSquareMeter(p))
end

local hectare = {
	toSquareMeter = function(p: number)
		return p / 0.0001
	end
}

function hectare.toSquareMillimeter(p: number)
	return squareMeter.toSquareMillimeter(hectare.toSquareMeter(p))
end

function hectare.toSquareKilometer(p: number)
	return squareMeter.toSquareKilometer(hectare.toSquareMeter(p))
end

function hectare.toSquareMile(p: number)
	return squareMeter.toSquareMile(hectare.toSquareMeter(p))
end

function hectare.toSquareYard(p: number)
	return squareMeter.toSquareYard(hectare.toSquareMeter(p))
end

function hectare.toSquareFeet(p: number)
	return squareMeter.toSquareFeet(hectare.toSquareMeter(p))
end

function hectare.toSquareInch(p: number)
	return squareMeter.toSquareInch(hectare.toSquareMeter(p))
end

function hectare.toSquareCentimeter(p: number)
	return squareMeter.toSquareCentimeter(hectare.toSquareMeter(p))
end

function hectare.toAcre(p: number)
	return squareMeter.toAcre(hectare.toSquareMeter(p))
end

function hectare.toRoblox(p: number)
	return squareMeter.toRoblox(hectare.toSquareMeter(p))
end

local roblox = {
	toSquareMeter = function(p: number)
		return p * 0.0784
	end
}

function roblox.toSquareMillimeter(p: number)
	return squareMeter.toSquareMillimeter(roblox.toSquareMeter(p))
end

function roblox.toSquareKilometer(p: number)
	return squareMeter.toSquareKilometer(roblox.toSquareMeter(p))
end

function roblox.toSquareMile(p: number)
	return squareMeter.toSquareMile(roblox.toSquareMeter(p))
end

function roblox.toSquareYard(p: number)
	return squareMeter.toSquareYard(roblox.toSquareMeter(p))
end

function roblox.toSquareFeet(p: number)
	return squareMeter.toSquareFeet(roblox.toSquareMeter(p))
end

function roblox.toSquareInch(p: number)
	return squareMeter.toSquareInch(roblox.toSquareMeter(p))
end

function roblox.toSquareCentimeter(p: number)
	return squareMeter.toSquareCentimeter(roblox.toSquareMeter(p))
end

function roblox.toAcre(p: number)
	return squareMeter.toAcre(roblox.toSquareMeter(p))
end

function roblox.toHectare(p: number)
	return squareMeter.toHectare(roblox.toSquareMeter(p))
end

return {
	SquareMeter = squareMeter,
	SquareCentimeter = squareCentimeter,
	SquareMillimeter = squareMillimeter,
	SquareFeet = squareFeet,
	SquareInch = squareInch,
	SquareYard = squareYard,
	SquareKilometer = squareKilometer,
	SquareMile = squareMile,
	Acre = acre,
	Hectare = hectare,
	Roblox = roblox
}