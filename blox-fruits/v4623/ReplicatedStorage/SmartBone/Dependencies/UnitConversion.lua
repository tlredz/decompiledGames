local UnitConversion = {
	Conversions = {
		Kilometer = 280.0336040324839,
		Hektometer = 28.00336040324839,
		Decameter = 2.800336040324839,
		Meter = 0.2800336040324839,
		Decimeter = 0.02800336040324839,
		Centimeter = 0.002800336040324839,
		Millimeter = 0.0002800336040324839,
		Miles = 4850.975973116774,
		Yards = 2.7562363483618033,
		Feet = 0.9187454494539344,
		Inches = 0.07656212078782787
	}
}

function UnitConversion.Convert(p: number, p2: string)
	return UnitConversion.Conversions[p2] ~= nil and p * UnitConversion.Conversions[p2]
end

function UnitConversion.ConvertInverse(p: number, p2: string)
	return UnitConversion.Conversions[p2] ~= nil and UnitConversion.Conversions[p2] / p
end

function UnitConversion.ConvertRounded(p: number, p2: string)
	return UnitConversion.Conversions[p2] ~= nil and math.floor(p * UnitConversion.Conversions[p2])
end

return UnitConversion