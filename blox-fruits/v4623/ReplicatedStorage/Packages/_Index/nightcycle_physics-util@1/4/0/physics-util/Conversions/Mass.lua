local kilogram = {
	toPound = function(p: number)
		return p * 2.20462
	end,
	toOunce = function(p: number)
		return p * 35.27392
	end,
	toStone = function(p: number)
		return p * 30.864679999999996
	end,
	toTon = function(p: number)
		return p * 0.00110231
	end,
	toKiloton = function(p: number)
		return p * 1.10231e-6
	end,
	toMegaton = function(p: number)
		return p * 1.10231e-9
	end,
	toGram = function(p: number)
		return p * 1000
	end,
	toMilligram = function(p: number)
		return p * 1000000
	end,
	toTonne = function(p: number)
		return p * 0.001
	end,
	toKilotonne = function(p: number)
		return p * 1e-6
	end,
	toMegatonne = function(p: number)
		return p * 9.999999999999999e-10
	end,
	toRoblox = function(p: number)
		return p / 21.952
	end
}
local ounce = {
	toKilogram = function(p: number)
		return p / 35.27392
	end
}

function ounce.toPound(p: number)
	return kilogram.toPound(ounce.toKilogram(p))
end

function ounce.toStone(p: number)
	return kilogram.toStone(ounce.toKilogram(p))
end

function ounce.toTon(p: number)
	return kilogram.toTon(ounce.toKilogram(p))
end

function ounce.toKiloton(p: number)
	return kilogram.toKiloton(ounce.toKilogram(p))
end

function ounce.toMegaton(p: number)
	return kilogram.toMegaton(ounce.toKilogram(p))
end

function ounce.toGram(p: number)
	return kilogram.toGram(ounce.toKilogram(p))
end

function ounce.toMilligram(p: number)
	return kilogram.toMilligram(ounce.toKilogram(p))
end

function ounce.toTonne(p: number)
	return kilogram.toTonne(ounce.toKilogram(p))
end

function ounce.toKilotonne(p: number)
	return kilogram.toKilotonne(ounce.toKilogram(p))
end

function ounce.toMegatonne(p: number)
	return kilogram.toMegatonne(ounce.toKilogram(p))
end

function ounce.toRoblox(p: number)
	return kilogram.toRoblox(ounce.toKilogram(p))
end

local pound = {
	toKilogram = function(p: number)
		return p / 2.20462
	end
}

function pound.toTon(p: number)
	return kilogram.toTon(pound.toKilogram(p))
end

function pound.toOunce(p: number)
	return kilogram.toOunce(pound.toKilogram(p))
end

function pound.toStone(p: number)
	return kilogram.toStone(pound.toKilogram(p))
end

function pound.toKiloton(p: number)
	return kilogram.toKiloton(pound.toKilogram(p))
end

function pound.toMegaton(p: number)
	return kilogram.toMegaton(pound.toKilogram(p))
end

function pound.toGram(p: number)
	return kilogram.toGram(pound.toKilogram(p))
end

function pound.toMilligram(p: number)
	return kilogram.toMilligram(pound.toKilogram(p))
end

function pound.toTonne(p: number)
	return kilogram.toTonne(pound.toKilogram(p))
end

function pound.toKilotonne(p: number)
	return kilogram.toKilotonne(pound.toKilogram(p))
end

function pound.toMegatonne(p: number)
	return kilogram.toMegatonne(pound.toKilogram(p))
end

function pound.toRoblox(p: number)
	return kilogram.toRoblox(pound.toKilogram(p))
end

local stone = {
	toKilogram = function(p: number)
		return p / 2.20462
	end
}

function stone.toTon(p: number)
	return kilogram.toTon(stone.toKilogram(p))
end

function stone.toOunce(p: number)
	return kilogram.toOunce(stone.toKilogram(p))
end

function stone.toPound(p: number)
	return kilogram.toPound(stone.toKilogram(p))
end

function stone.toKiloton(p: number)
	return kilogram.toKiloton(stone.toKilogram(p))
end

function stone.toMegaton(p: number)
	return kilogram.toMegaton(stone.toKilogram(p))
end

function stone.toGram(p: number)
	return kilogram.toGram(stone.toKilogram(p))
end

function stone.toMilligram(p: number)
	return kilogram.toMilligram(stone.toKilogram(p))
end

function stone.toTonne(p: number)
	return kilogram.toTonne(stone.toKilogram(p))
end

function stone.toKilotonne(p: number)
	return kilogram.toKilotonne(stone.toKilogram(p))
end

function stone.toMegatonne(p: number)
	return kilogram.toMegatonne(stone.toKilogram(p))
end

function stone.toRoblox(p: number)
	return kilogram.toRoblox(stone.toKilogram(p))
end

local ton = {
	toKilogram = function(p: number)
		return p / 0.00110231
	end
}

function ton.toOunce(p: number)
	return kilogram.toOunce(ton.toKilogram(p))
end

function ton.toPound(p: number)
	return kilogram.toPound(ton.toKilogram(p))
end

function ton.toStone(p: number)
	return kilogram.toStone(ton.toKilogram(p))
end

function ton.toKiloton(p: number)
	return kilogram.toKiloton(ton.toKilogram(p))
end

function ton.toMegaton(p: number)
	return kilogram.toMegaton(ton.toKilogram(p))
end

function ton.toGram(p: number)
	return kilogram.toGram(ton.toKilogram(p))
end

function ton.toMilligram(p: number)
	return kilogram.toMilligram(ton.toKilogram(p))
end

function ton.toTonne(p: number)
	return kilogram.toTonne(ton.toKilogram(p))
end

function ton.toKilotonne(p: number)
	return kilogram.toKilotonne(ton.toKilogram(p))
end

function ton.toMegatonne(p: number)
	return kilogram.toMegatonne(ton.toKilogram(p))
end

function ton.toRoblox(p: number)
	return kilogram.toRoblox(ton.toKilogram(p))
end

local kiloton = {
	toKilogram = function(p: number)
		return p / 35.27392
	end
}

function kiloton.toOunce(p: number)
	return kilogram.toKiloton(kiloton.toKilogram(p))
end

function kiloton.toPound(p: number)
	return kilogram.toPound(kiloton.toKilogram(p))
end

function kiloton.toStone(p: number)
	return kilogram.toStone(kiloton.toKilogram(p))
end

function kiloton.toTon(p: number)
	return kilogram.toTon(kiloton.toKilogram(p))
end

function kiloton.toMegaton(p: number)
	return kilogram.toMegaton(kiloton.toKilogram(p))
end

function kiloton.toGram(p: number)
	return kilogram.toGram(kiloton.toKilogram(p))
end

function kiloton.toMilligram(p: number)
	return kilogram.toMilligram(kiloton.toKilogram(p))
end

function kiloton.toTonne(p: number)
	return kilogram.toTonne(kiloton.toKilogram(p))
end

function kiloton.toKilotonne(p: number)
	return kilogram.toKilotonne(kiloton.toKilogram(p))
end

function kiloton.toMegatonne(p: number)
	return kilogram.toMegatonne(kiloton.toKilogram(p))
end

function kiloton.toRoblox(p: number)
	return kilogram.toRoblox(kiloton.toKilogram(p))
end

local megaton = {
	toKilogram = function(p: number)
		return p / 1.10231e-9
	end
}

function megaton.toOunce(p: number)
	return kilogram.toOunce(megaton.toKilogram(p))
end

function megaton.toPound(p: number)
	return kilogram.toPound(megaton.toKilogram(p))
end

function megaton.toStone(p: number)
	return kilogram.toStone(megaton.toKilogram(p))
end

function megaton.toTon(p: number)
	return kilogram.toTon(megaton.toKilogram(p))
end

function megaton.toKiloton(p: number)
	return kilogram.toKiloton(megaton.toKilogram(p))
end

function megaton.toGram(p: number)
	return kilogram.toGram(megaton.toKilogram(p))
end

function megaton.toMilligram(p: number)
	return kilogram.toMilligram(megaton.toKilogram(p))
end

function megaton.toTonne(p: number)
	return kilogram.toTonne(megaton.toKilogram(p))
end

function megaton.toKilotonne(p: number)
	return kilogram.toKilotonne(megaton.toKilogram(p))
end

function megaton.toMegatonne(p: number)
	return kilogram.toMegatonne(megaton.toKilogram(p))
end

function megaton.toRoblox(p: number)
	return kilogram.toRoblox(megaton.toKilogram(p))
end

local gram = {
	toKilogram = function(p: number)
		return p / 1000
	end
}

function gram.toOunce(p: number)
	return kilogram.toOunce(gram.toKilogram(p))
end

function gram.toPound(p: number)
	return kilogram.toPound(gram.toKilogram(p))
end

function gram.toStone(p: number)
	return kilogram.toStone(gram.toKilogram(p))
end

function gram.toTon(p: number)
	return kilogram.toTon(gram.toKilogram(p))
end

function gram.toKiloton(p: number)
	return kilogram.toKiloton(gram.toKilogram(p))
end

function gram.toMegaton(p: number)
	return kilogram.toMegaton(gram.toKilogram(p))
end

function gram.toMilligram(p: number)
	return kilogram.toMilligram(gram.toKilogram(p))
end

function gram.toTonne(p: number)
	return kilogram.toTonne(gram.toKilogram(p))
end

function gram.toKilotonne(p: number)
	return kilogram.toKilotonne(gram.toKilogram(p))
end

function gram.toMegatonne(p: number)
	return kilogram.toMegatonne(gram.toKilogram(p))
end

function gram.toRoblox(p: number)
	return kilogram.toRoblox(gram.toKilogram(p))
end

local milligram = {
	toKilogram = function(p: number)
		return p / 1000000
	end
}

function milligram.toOunce(p: number)
	return kilogram.toOunce(milligram.toKilogram(p))
end

function milligram.toPound(p: number)
	return kilogram.toPound(milligram.toKilogram(p))
end

function milligram.toStone(p: number)
	return kilogram.toStone(milligram.toKilogram(p))
end

function milligram.toTon(p: number)
	return kilogram.toTon(milligram.toKilogram(p))
end

function milligram.toKiloton(p: number)
	return kilogram.toKiloton(milligram.toKilogram(p))
end

function milligram.toMegaton(p: number)
	return kilogram.toMegaton(milligram.toKilogram(p))
end

function milligram.toGram(p: number)
	return kilogram.toGram(milligram.toKilogram(p))
end

function milligram.toTonne(p: number)
	return kilogram.toTonne(milligram.toKilogram(p))
end

function milligram.toKilotonne(p: number)
	return kilogram.toKilotonne(milligram.toKilogram(p))
end

function milligram.toMegatonne(p: number)
	return kilogram.toMegatonne(milligram.toKilogram(p))
end

function milligram.toRoblox(p: number)
	return kilogram.toRoblox(milligram.toKilogram(p))
end

local tonne = {
	toKilogram = function(p: number)
		return p / 0.001
	end
}

function tonne.toOunce(p: number)
	return kilogram.toOunce(tonne.toKilogram(p))
end

function tonne.toPound(p: number)
	return kilogram.toPound(tonne.toKilogram(p))
end

function tonne.toStone(p: number)
	return kilogram.toStone(tonne.toKilogram(p))
end

function tonne.toTon(p: number)
	return kilogram.toTon(tonne.toKilogram(p))
end

function tonne.toKiloton(p: number)
	return kilogram.toKiloton(tonne.toKilogram(p))
end

function tonne.toMegaton(p: number)
	return kilogram.toMegaton(tonne.toKilogram(p))
end

function tonne.toGram(p: number)
	return kilogram.toGram(tonne.toKilogram(p))
end

function tonne.toMilligram(p: number)
	return kilogram.toMilligram(tonne.toKilogram(p))
end

function tonne.toKilotonne(p: number)
	return kilogram.toKilotonne(tonne.toKilogram(p))
end

function tonne.toMegatonne(p: number)
	return kilogram.toMegatonne(tonne.toKilogram(p))
end

function tonne.toRoblox(p: number)
	return kilogram.toRoblox(tonne.toKilogram(p))
end

local kilotonne = {
	toKilogram = function(p: number)
		return p / 1e-6
	end
}

function kilotonne.toOunce(p: number)
	return kilogram.toOunce(kilotonne.toKilogram(p))
end

function kilotonne.toPound(p: number)
	return kilogram.toPound(kilotonne.toKilogram(p))
end

function kilotonne.toStone(p: number)
	return kilogram.toStone(kilotonne.toKilogram(p))
end

function kilotonne.toTon(p: number)
	return kilogram.toTon(kilotonne.toKilogram(p))
end

function kilotonne.toKiloton(p: number)
	return kilogram.toKiloton(kilotonne.toKilogram(p))
end

function kilotonne.toMegaton(p: number)
	return kilogram.toMegaton(kilotonne.toKilogram(p))
end

function kilotonne.toGram(p: number)
	return kilogram.toGram(kilotonne.toKilogram(p))
end

function kilotonne.toMilligram(p: number)
	return kilogram.toMilligram(kilotonne.toKilogram(p))
end

function kilotonne.toTonne(p: number)
	return kilogram.toTonne(kilotonne.toKilogram(p))
end

function kilotonne.toMegatonne(p: number)
	return kilogram.toMegatonne(kilotonne.toKilogram(p))
end

function kilotonne.toRoblox(p: number)
	return kilogram.toRoblox(kilotonne.toKilogram(p))
end

local megatonne = {
	toKilogram = function(p: number)
		return p / 9.999999999999999e-10
	end
}

function megatonne.toOunce(p: number)
	return kilogram.toOunce(megatonne.toKilogram(p))
end

function megatonne.toPound(p: number)
	return kilogram.toPound(megatonne.toKilogram(p))
end

function megatonne.toStone(p: number)
	return kilogram.toStone(megatonne.toKilogram(p))
end

function megatonne.toTon(p: number)
	return kilogram.toTon(megatonne.toKilogram(p))
end

function megatonne.toKiloton(p: number)
	return kilogram.toKiloton(megatonne.toKilogram(p))
end

function megatonne.toMegaton(p: number)
	return kilogram.toMegaton(megatonne.toKilogram(p))
end

function megatonne.toGram(p: number)
	return kilogram.toGram(megatonne.toKilogram(p))
end

function megatonne.toMilligram(p: number)
	return kilogram.toMilligram(megatonne.toKilogram(p))
end

function megatonne.toTonne(p: number)
	return kilogram.toTonne(megatonne.toKilogram(p))
end

function megatonne.toKilotonne(p: number)
	return kilogram.toKilotonne(megatonne.toKilogram(p))
end

function megatonne.toRoblox(p: number)
	return kilogram.toRoblox(megatonne.toKilogram(p))
end

return {
	Ounce = ounce,
	Pound = pound,
	Stone = stone,
	Ton = ton,
	Kiloton = kiloton,
	Megaton = megaton,
	Gram = gram,
	Kilogram = kilogram,
	Milligram = milligram,
	Tonne = tonne,
	Kilotonne = kilotonne,
	Megatonne = megatonne,
	Roblox = {
		toKilogram = function(p: number)
			return p * 21.952
		end,
		toOunce = function(p: number)
			return kilogram.toOunce(megatonne.toKilogram(p))
		end,
		toPound = function(p: number)
			return kilogram.toPound(megatonne.toKilogram(p))
		end,
		toStone = function(p: number)
			return kilogram.toStone(megatonne.toKilogram(p))
		end,
		toTon = function(p: number)
			return kilogram.toTon(megatonne.toKilogram(p))
		end,
		toKiloton = function(p: number)
			return kilogram.toKiloton(megatonne.toKilogram(p))
		end,
		toMegaton = function(p: number)
			return kilogram.toMegaton(megatonne.toKilogram(p))
		end,
		toGram = function(p: number)
			return kilogram.toGram(megatonne.toKilogram(p))
		end,
		toMilligram = function(p: number)
			return kilogram.toMilligram(megatonne.toKilogram(p))
		end,
		toTonne = function(p: number)
			return kilogram.toTonne(megatonne.toKilogram(p))
		end,
		toKilotonne = function(p: number)
			return kilogram.toKilotonne(megatonne.toKilogram(p))
		end,
		toMegatonne = function(p: number)
			return kilogram.toKilotonne(megatonne.toKilogram(p))
		end
	}
}