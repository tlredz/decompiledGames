local random = Random.new(tick())
local Randomizer = {
	GetRandomNumber = function(p: number, p2: number, flag: boolean)
		if flag then
			return random:NextNumber(p, p2)
		end

		return random:NextInteger(p, p2)
	end
}

function Randomizer.GetRandomSign()
	local randomNumber = Randomizer.GetRandomNumber(-1, 1)
	return randomNumber == 0 and 1 or randomNumber
end

return Randomizer