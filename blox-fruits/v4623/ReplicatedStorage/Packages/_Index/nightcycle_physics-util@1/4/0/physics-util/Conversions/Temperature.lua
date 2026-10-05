local celsius = {
	toKelvin = function(p: number)
		return p + 273
	end,
	toFahrenheit = function(p: number)
		return p * 1.8 + 32
	end
}
local kelvin = {
	toCelsius = function(p: number)
		return p - 273
	end
}

function kelvin.toFahrenheit(p: number)
	return celsius.toFahrenheit(kelvin.toCelsius(p))
end

local fahrenheit = {
	toCelsius = function(p: number)
		return (p - 32) / 1.8
	end
}

function fahrenheit.toKelvin(p: number)
	return celsius.toKelvin(fahrenheit.toCelsius(p))
end

return {
	Kelvin = kelvin,
	Celsius = celsius,
	Fahrenheit = fahrenheit
}