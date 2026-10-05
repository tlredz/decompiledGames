local meter = {
	toKilometer = function(p: number)
		return p / 1000
	end
}

function meter.toAstronomicalUnit(p: number)
	return meter.toKilometer(p) / 149597870.7
end

function meter.toLightYear(p: number)
	return meter.toAstronomicalUnit(p) / 63241.1
end

function meter.toLightSecond(p: number)
	return meter.toKilometer(p) / 299792.6369041473
end

function meter.toLeague(p: number)
	return p / 5556
end

function meter.toMile(p: number)
	return meter.toKilometer(p) / 1.60934
end

function meter.toFeet(p: number)
	return p * 3.28
end

function meter.toCentimeter(p: number)
	return p * 100
end

function meter.toMillimeter(p: number)
	return p * 1000
end

function meter.toMicrometer(p: number)
	return meter.toMillimeter(p) * 1000
end

function meter.toNanometer(p: number)
	return meter.toNanometer(p) * 1000
end

function meter.toPicometer(p: number)
	return meter.toNanometer(p) * 1000
end

function meter.toPlanck(p: number)
	return meter.toPicometer(p) * 1.6000000000000002e-23
end

function meter.toRoblox(p: number)
	return p * 100 / 28
end

local kilometer = {
	toMeter = function(p: number)
		return p * 1000
	end
}

function kilometer.toAstronomicalUnit(p: number)
	return meter.toAstronomicalUnit(kilometer.toMeter(p))
end

function kilometer.toLightYear(p: number)
	return meter.toLightYear(kilometer.toMeter(p))
end

function kilometer.toLightSecond(p: number)
	return meter.toLightSecond(kilometer.toMeter(p))
end

function kilometer.toLeague(p: number)
	return meter.toLeague(kilometer.toMeter(p))
end

function kilometer.toMile(p: number)
	return meter.toMile(kilometer.toMeter(p))
end

function kilometer.toFeet(p: number)
	return meter.toFeet(kilometer.toMeter(p))
end

function kilometer.toCentimeter(p: number)
	return meter.toCentimeter(kilometer.toMeter(p))
end

function kilometer.toMillimeter(p: number)
	return meter.toMillimeter(kilometer.toMeter(p))
end

function kilometer.toMicrometer(p: number)
	return meter.toMicrometer(kilometer.toMeter(p))
end

function kilometer.toNanometer(p: number)
	return meter.toNanometer(kilometer.toMeter(p))
end

function kilometer.toPicometer(p: number)
	return meter.toPicometer(kilometer.toMeter(p))
end

function kilometer.toPlanck(p: number)
	return meter.toPlanck(kilometer.toMeter(p))
end

function kilometer.toRoblox(p: number)
	return meter.toRoblox(kilometer.toMeter(p))
end

local astronomicalUnit = {
	toKilometer = function(p: number)
		return p * 149597870.7
	end
}

function astronomicalUnit.toMeter(p: number)
	return kilometer.toMeter(astronomicalUnit.toKilometer(p))
end

function astronomicalUnit.toLightYear(p: number)
	return kilometer.toLightYear(astronomicalUnit.toKilometer(p))
end

function astronomicalUnit.toLightSecond(p: number)
	return kilometer.toLightSecond(astronomicalUnit.toKilometer(p))
end

function astronomicalUnit.toLeague(p: number)
	return kilometer.toLeague(astronomicalUnit.toKilometer(p))
end

function astronomicalUnit.toMile(p: number)
	return kilometer.toMile(astronomicalUnit.toKilometer(p))
end

function astronomicalUnit.toFeet(p: number)
	return kilometer.toFeet(astronomicalUnit.toKilometer(p))
end

function astronomicalUnit.toCentimeter(p: number)
	return kilometer.toCentimeter(astronomicalUnit.toKilometer(p))
end

function astronomicalUnit.toMillimeter(p: number)
	return kilometer.toMillimeter(astronomicalUnit.toKilometer(p))
end

function astronomicalUnit.toMicrometer(p: number)
	return kilometer.toMicrometer(astronomicalUnit.toKilometer(p))
end

function astronomicalUnit.toNanometer(p: number)
	return kilometer.toNanometer(astronomicalUnit.toKilometer(p))
end

function astronomicalUnit.toPicometer(p: number)
	return kilometer.toPicometer(astronomicalUnit.toKilometer(p))
end

function astronomicalUnit.toPlanck(p: number)
	return kilometer.toPlanck(astronomicalUnit.toKilometer(p))
end

function astronomicalUnit.toRoblox(p: number)
	return kilometer.toRoblox(astronomicalUnit.toKilometer(p))
end

local lightYear = {
	toKilometer = function(p: number)
		return astronomicalUnit.toKilometer(p * 63241.1)
	end
}

function lightYear.toMeter(p: number)
	return kilometer.toMeter(lightYear.toKilometer(p))
end

function lightYear.toAstronomicalUnit(p: number)
	return kilometer.toAstronomicalUnit(lightYear.toKilometer(p))
end

function lightYear.toLightSecond(p: number)
	return kilometer.toLightSecond(lightYear.toKilometer(p))
end

function lightYear.toLeague(p: number)
	return kilometer.toLeague(lightYear.toKilometer(p))
end

function lightYear.toMile(p: number)
	return kilometer.toMile(lightYear.toKilometer(p))
end

function lightYear.toFeet(p: number)
	return kilometer.toFeet(lightYear.toKilometer(p))
end

function lightYear.toCentimeter(p: number)
	return kilometer.toCentimeter(lightYear.toKilometer(p))
end

function lightYear.toMillimeter(p: number)
	return kilometer.toMillimeter(lightYear.toKilometer(p))
end

function lightYear.toMicrometer(p: number)
	return kilometer.toMicrometer(lightYear.toKilometer(p))
end

function lightYear.toNanometer(p: number)
	return kilometer.toNanometer(lightYear.toKilometer(p))
end

function lightYear.toPicometer(p: number)
	return kilometer.toPicometer(lightYear.toKilometer(p))
end

function lightYear.toPlanck(p: number)
	return kilometer.toPlanck(lightYear.toKilometer(p))
end

function lightYear.toRoblox(p: number)
	return kilometer.toRoblox(lightYear.toKilometer(p))
end

local lightSecond = {
	toKilometer = function(p: number)
		return p * 299792.6369041473
	end
}

function lightSecond.toMeter(p: number)
	return kilometer.toMeter(lightSecond.toKilometer(p))
end

function lightSecond.toAstronomicalUnit(p: number)
	return kilometer.toAstronomicalUnit(lightSecond.toKilometer(p))
end

function lightSecond.toLightYear(p: number)
	return kilometer.toLightYear(lightSecond.toKilometer(p))
end

function lightSecond.toLeague(p: number)
	return kilometer.toLeague(lightSecond.toKilometer(p))
end

function lightSecond.toMile(p: number)
	return kilometer.toMile(lightSecond.toKilometer(p))
end

function lightSecond.toFeet(p: number)
	return kilometer.toFeet(lightSecond.toKilometer(p))
end

function lightSecond.toCentimeter(p: number)
	return kilometer.toCentimeter(lightSecond.toKilometer(p))
end

function lightSecond.toMillimeter(p: number)
	return kilometer.toMillimeter(lightSecond.toKilometer(p))
end

function lightSecond.toMicrometer(p: number)
	return kilometer.toMicrometer(lightSecond.toKilometer(p))
end

function lightSecond.toNanometer(p: number)
	return kilometer.toNanometer(lightSecond.toKilometer(p))
end

function lightSecond.toPicometer(p: number)
	return kilometer.toPicometer(lightSecond.toKilometer(p))
end

function lightSecond.toPlanck(p: number)
	return kilometer.toPlanck(lightSecond.toKilometer(p))
end

function lightSecond.toRoblox(p: number)
	return kilometer.toRoblox(lightSecond.toKilometer(p))
end

local league = {
	toMeter = function(p: number)
		return p * 5556
	end
}

function league.toKilometer(p: number)
	return meter.toKilometer(league.toMeter(p))
end

function league.toAstronomicalUnit(p: number)
	return meter.toAstronomicalUnit(league.toMeter(p))
end

function league.toLightYear(p: number)
	return meter.toLightYear(league.toMeter(p))
end

function league.toLightSecond(p: number)
	return meter.toLightSecond(league.toMeter(p))
end

function league.toMile(p: number)
	return meter.toMile(league.toMeter(p))
end

function league.toFeet(p: number)
	return meter.toFeet(league.toMeter(p))
end

function league.toCentimeter(p: number)
	return meter.toCentimeter(league.toMeter(p))
end

function league.toMillimeter(p: number)
	return meter.toMillimeter(league.toMeter(p))
end

function league.toMicrometer(p: number)
	return meter.toMicrometer(league.toMeter(p))
end

function league.toNanometer(p: number)
	return meter.toNanometer(league.toMeter(p))
end

function league.toPicometer(p: number)
	return meter.toPicometer(league.toMeter(p))
end

function league.toPlanck(p: number)
	return meter.toPlanck(league.toMeter(p))
end

function league.toRoblox(p: number)
	return meter.toRoblox(league.toMeter(p))
end

local mile = {
	toKilometer = function(p: number)
		return p * 1.60934
	end
}

function mile.toMeter(p: number)
	return kilometer.toMeter(mile.toKilometer(p))
end

function mile.toAstronomicalUnit(p: number)
	return kilometer.toAstronomicalUnit(mile.toKilometer(p))
end

function mile.toLightYear(p: number)
	return kilometer.toLightYear(mile.toKilometer(p))
end

function mile.toLightSecond(p: number)
	return kilometer.toLightSecond(mile.toKilometer(p))
end

function mile.toLeague(p: number)
	return kilometer.toLeague(mile.toKilometer(p))
end

function mile.toFeet(p: number)
	return kilometer.toFeet(mile.toKilometer(p))
end

function mile.toCentimeter(p: number)
	return kilometer.toCentimeter(mile.toKilometer(p))
end

function mile.toMillimeter(p: number)
	return kilometer.toMillimeter(mile.toKilometer(p))
end

function mile.toMicrometer(p: number)
	return kilometer.toMicrometer(mile.toKilometer(p))
end

function mile.toNanometer(p: number)
	return kilometer.toNanometer(mile.toKilometer(p))
end

function mile.toPicometer(p: number)
	return kilometer.toPicometer(mile.toKilometer(p))
end

function mile.toPlanck(p: number)
	return kilometer.toPlanck(mile.toKilometer(p))
end

function mile.toRoblox(p: number)
	return kilometer.toRoblox(mile.toKilometer(p))
end

local feet = {
	toMeter = function(p: number)
		return p / 3.28
	end
}

function feet.toKilometer(p: number)
	return meter.toKilometer(feet.toMeter(p))
end

function feet.toAstronomicalUnit(p: number)
	return meter.toAstronomicalUnit(feet.toMeter(p))
end

function feet.toLightYear(p: number)
	return meter.toLightYear(feet.toMeter(p))
end

function feet.toLightSecond(p: number)
	return meter.toLightSecond(feet.toMeter(p))
end

function feet.toLeague(p: number)
	return meter.toLeague(feet.toMeter(p))
end

function feet.toMile(p: number)
	return meter.toMile(feet.toMeter(p))
end

function feet.toCentimeter(p: number)
	return meter.toCentimeter(feet.toMeter(p))
end

function feet.toMillimeter(p: number)
	return meter.toMillimeter(feet.toMeter(p))
end

function feet.toMicrometer(p: number)
	return meter.toMicrometer(feet.toMeter(p))
end

function feet.toNanometer(p: number)
	return meter.toNanometer(feet.toMeter(p))
end

function feet.toPicometer(p: number)
	return meter.toPicometer(feet.toMeter(p))
end

function feet.toPlanck(p: number)
	return meter.toPlanck(feet.toMeter(p))
end

function feet.toRoblox(p: number)
	return meter.toRoblox(feet.toMeter(p))
end

local centimeter = {
	toMeter = function(p: number)
		return p / 100
	end
}

function centimeter.toKilometer(p: number)
	return meter.toKilometer(centimeter.toMeter(p))
end

function centimeter.toAstronomicalUnit(p: number)
	return meter.toAstronomicalUnit(centimeter.toMeter(p))
end

function centimeter.toLightYear(p: number)
	return meter.toLightYear(centimeter.toMeter(p))
end

function centimeter.toLightSecond(p: number)
	return meter.toLightSecond(centimeter.toMeter(p))
end

function centimeter.toLeague(p: number)
	return meter.toLeague(centimeter.toMeter(p))
end

function centimeter.toMile(p: number)
	return meter.toMile(centimeter.toMeter(p))
end

function centimeter.toFeet(p: number)
	return meter.toFeet(centimeter.toMeter(p))
end

function centimeter.toMillimeter(p: number)
	return meter.toMillimeter(centimeter.toMeter(p))
end

function centimeter.toMicrometer(p: number)
	return meter.toMicrometer(centimeter.toMeter(p))
end

function centimeter.toNanometer(p: number)
	return meter.toNanometer(centimeter.toMeter(p))
end

function centimeter.toPicometer(p: number)
	return meter.toPicometer(centimeter.toMeter(p))
end

function centimeter.toPlanck(p: number)
	return meter.toPlanck(centimeter.toMeter(p))
end

function centimeter.toRoblox(p: number)
	return p / 28
end

local roblox = {
	toCentimeter = function(p: number)
		return p * 28
	end
}

function roblox.toMeter(p: number)
	return centimeter.toMeter(roblox.toCentimeter(p))
end

function roblox.toKilometer(p: number)
	return centimeter.toKilometer(roblox.toCentimeter(p))
end

function roblox.toAstronomicalUnit(p: number)
	return centimeter.toAstronomicalUnit(roblox.toCentimeter(p))
end

function roblox.toLightYear(p: number)
	return centimeter.toLightYear(roblox.toCentimeter(p))
end

function roblox.toLightSecond(p: number)
	return centimeter.toLightSecond(roblox.toCentimeter(p))
end

function roblox.toLeague(p: number)
	return centimeter.toLeague(roblox.toCentimeter(p))
end

function roblox.toMile(p: number)
	return centimeter.toMile(roblox.toCentimeter(p))
end

function roblox.toFeet(p: number)
	return centimeter.toFeet(roblox.toCentimeter(p))
end

function roblox.toMillimeter(p: number)
	return centimeter.toMillimeter(roblox.toCentimeter(p))
end

function roblox.toMicrometer(p: number)
	return centimeter.toMicrometer(roblox.toCentimeter(p))
end

function roblox.toNanometer(p: number)
	return centimeter.toNanometer(roblox.toCentimeter(p))
end

function roblox.toPicometer(p: number)
	return centimeter.toPicometer(roblox.toCentimeter(p))
end

function roblox.toPlanck(p: number)
	return centimeter.toPlanck(roblox.toCentimeter(p))
end

local millimeter = {
	toMeter = function(p: number)
		return centimeter.toMeter(p / 1000)
	end
}

function millimeter.toKilometer(p: number)
	return meter.toKilometer(millimeter.toMeter(p))
end

function millimeter.toAstronomicalUnit(p: number)
	return meter.toAstronomicalUnit(millimeter.toMeter(p))
end

function millimeter.toLightYear(p: number)
	return meter.toLightYear(millimeter.toMeter(p))
end

function millimeter.toLightSecond(p: number)
	return meter.toLightSecond(millimeter.toMeter(p))
end

function millimeter.toLeague(p: number)
	return meter.toLeague(millimeter.toMeter(p))
end

function millimeter.toMile(p: number)
	return meter.toMile(millimeter.toMeter(p))
end

function millimeter.toFeet(p: number)
	return meter.toFeet(millimeter.toMeter(p))
end

function millimeter.toCentimeter(p: number)
	return meter.toCentimeter(millimeter.toMeter(p))
end

function millimeter.toMicrometer(p: number)
	return meter.toMicrometer(millimeter.toMeter(p))
end

function millimeter.toNanometer(p: number)
	return meter.toNanometer(millimeter.toMeter(p))
end

function millimeter.toPicometer(p: number)
	return meter.toPicometer(millimeter.toMeter(p))
end

function millimeter.toPlanck(p: number)
	return meter.toPlanck(millimeter.toMeter(p))
end

function millimeter.toRoblox(p: number)
	return meter.toRoblox(millimeter.toMeter(p))
end

local micrometer = {
	toMillimeter = function(p: number)
		return p / 1000
	end
}

function micrometer.toMeter(p: number)
	return millimeter.toMeter(micrometer.toMillimeter(p))
end

function micrometer.toKilometer(p: number)
	return meter.toKilometer(micrometer.toMeter(p))
end

function micrometer.toAstronomicalUnit(p: number)
	return meter.toAstronomicalUnit(micrometer.toMeter(p))
end

function micrometer.toLightYear(p: number)
	return meter.toLightYear(micrometer.toMeter(p))
end

function micrometer.toLightSecond(p: number)
	return meter.toLightSecond(micrometer.toMeter(p))
end

function micrometer.toLeague(p: number)
	return meter.toLeague(micrometer.toMeter(p))
end

function micrometer.toMile(p: number)
	return meter.toMile(micrometer.toMeter(p))
end

function micrometer.toFeet(p: number)
	return meter.toFeet(micrometer.toMeter(p))
end

function micrometer.toCentimeter(p: number)
	return meter.toCentimeter(micrometer.toMeter(p))
end

function micrometer.toNanometer(p: number)
	return meter.toNanometer(micrometer.toMeter(p))
end

function micrometer.toPicometer(p: number)
	return meter.toPicometer(micrometer.toMeter(p))
end

function micrometer.toPlanck(p: number)
	return meter.toPlanck(micrometer.toMeter(p))
end

function micrometer.toRoblox(p: number)
	return meter.toRoblox(micrometer.toMeter(p))
end

local nanometer = {
	toMicrometer = function(p: number)
		return p / 1000
	end
}

function nanometer.toMeter(p: number)
	return millimeter.toMeter(nanometer.toMicrometer(p))
end

function nanometer.toKilometer(p: number)
	return meter.toKilometer(nanometer.toMeter(p))
end

function nanometer.toAstronomicalUnit(p: number)
	return meter.toAstronomicalUnit(nanometer.toMeter(p))
end

function nanometer.toLightYear(p: number)
	return meter.toLightYear(nanometer.toMeter(p))
end

function nanometer.toLightSecond(p: number)
	return meter.toLightSecond(nanometer.toMeter(p))
end

function nanometer.toLeague(p: number)
	return meter.toLeague(nanometer.toMeter(p))
end

function nanometer.toMile(p: number)
	return meter.toMile(nanometer.toMeter(p))
end

function nanometer.toFeet(p: number)
	return meter.toFeet(nanometer.toMeter(p))
end

function nanometer.toCentimeter(p: number)
	return meter.toCentimeter(nanometer.toMeter(p))
end

function nanometer.toMillimeter(p: number)
	return meter.toMillimeter(nanometer.toMeter(p))
end

function nanometer.toPicometer(p: number)
	return meter.toPicometer(nanometer.toMeter(p))
end

function nanometer.toPlanck(p: number)
	return meter.toPlanck(nanometer.toMeter(p))
end

function nanometer.toRoblox(p: number)
	return meter.toRoblox(nanometer.toMeter(p))
end

local picometer = {
	toNanometer = function(p: number)
		return p / 1000
	end
}

function picometer.toMeter(p: number)
	return millimeter.toMeter(picometer.toMicrometer(p))
end

function picometer.toKilometer(p: number)
	return meter.toKilometer(picometer.toMeter(p))
end

function picometer.toAstronomicalUnit(p: number)
	return meter.toAstronomicalUnit(picometer.toMeter(p))
end

function picometer.toLightYear(p: number)
	return meter.toLightYear(picometer.toMeter(p))
end

function picometer.toLightSecond(p: number)
	return meter.toLightSecond(picometer.toMeter(p))
end

function picometer.toLeague(p: number)
	return meter.toLeague(picometer.toMeter(p))
end

function picometer.toMile(p: number)
	return meter.toMile(picometer.toMeter(p))
end

function picometer.toFeet(p: number)
	return meter.toFeet(picometer.toMeter(p))
end

function picometer.toCentimeter(p: number)
	return meter.toCentimeter(picometer.toMeter(p))
end

function picometer.toMillimeter(p: number)
	return meter.toMillimeter(picometer.toMeter(p))
end

function picometer.toMicrometer(p: number)
	return meter.toMicrometer(picometer.toMeter(p))
end

function picometer.toPicometer(p: number)
	return meter.toPicometer(picometer.toMeter(p))
end

function picometer.toPlanck(p: number)
	return meter.toPlanck(picometer.toMeter(p))
end

function picometer.toRoblox(p: number)
	return meter.toRoblox(picometer.toMeter(p))
end

local planck = {
	toPicometer = function(p: number)
		return p / 1.6000000000000002e-23
	end
}

function planck.toMeter(p: number)
	return millimeter.toMeter(planck.toMicrometer(p))
end

function planck.toKilometer(p: number)
	return meter.toKilometer(planck.toMeter(p))
end

function planck.toAstronomicalUnit(p: number)
	return meter.toAstronomicalUnit(planck.toMeter(p))
end

function planck.toLightYear(p: number)
	return meter.toLightYear(planck.toMeter(p))
end

function planck.toLightSecond(p: number)
	return meter.toLightSecond(planck.toMeter(p))
end

function planck.toLeague(p: number)
	return meter.toLeague(planck.toMeter(p))
end

function planck.toMile(p: number)
	return meter.toMile(planck.toMeter(p))
end

function planck.toFeet(p: number)
	return meter.toFeet(planck.toMeter(p))
end

function planck.toCentimeter(p: number)
	return meter.toCentimeter(planck.toMeter(p))
end

function planck.toMillimeter(p: number)
	return meter.toMillimeter(planck.toMeter(p))
end

function planck.toMicrometer(p: number)
	return meter.toMicrometer(planck.toMeter(p))
end

function planck.toNanometer(p: number)
	return meter.toNanometer(planck.toMeter(p))
end

function planck.toRoblox(p: number)
	return meter.toRoblox(planck.toMeter(p))
end

return {
	Meter = meter,
	Kilometer = kilometer,
	AstronomicalUnit = astronomicalUnit,
	LightYear = lightYear,
	LightSecond = lightSecond,
	League = league,
	Mile = mile,
	Feet = feet,
	Centimeter = centimeter,
	Millimeter = millimeter,
	Micrometer = micrometer,
	Nanometer = nanometer,
	Picometer = picometer,
	Planck = planck,
	Roblox = roblox
}