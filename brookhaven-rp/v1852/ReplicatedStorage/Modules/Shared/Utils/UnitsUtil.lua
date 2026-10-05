local UnitsUtil = {}

function UnitsUtil.studsPerSecondToMilesPerHour(p: number)
	return p * 0.648
end

function UnitsUtil.studsPerSecondToKilometersPerHour(p: number)
	return p * 0.648 * 1.609
end

function UnitsUtil.milesPerHourToKilometersPerHour(p: number)
	return p * 1.609
end

function UnitsUtil.milesPerHourToStudsPerSecond(p: number)
	return p / 0.648
end

function UnitsUtil.studsToMiles(p: number)
	return p * 0.0001551590380139643
end

function UnitsUtil.studsToMeters(p: number)
	return p * 0.0001551590380139643 * 1.609 * 1000
end

function UnitsUtil.milesToStuds(p: number)
	return p / 0.0001551590380139643
end

function UnitsUtil.studsToKilometers(p: number)
	return p * 0.0001551590380139643 * 1.609
end

function UnitsUtil.milesToKilometers(p: number)
	return p * 1.609
end

function UnitsUtil.milesToFeet(p: number)
	return p * 5280
end

function UnitsUtil.kilometersToMeters(p: number)
	return p * 1000
end

return UnitsUtil