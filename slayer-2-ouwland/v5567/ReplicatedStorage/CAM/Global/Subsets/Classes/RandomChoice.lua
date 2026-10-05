local random = Random.new()
local RandomChoice = {}

function RandomChoice.Generate(value: number, value2: number)
	return {
		Min = 1,
		Max = value or 1,
		Target = 1,
		CoolDown = value2 or 1,
		Last = 0
	}
end

function RandomChoice:Perform()
	if self == nil then
		return false
	end

	if os.clock() - self.Last > self.CoolDown then
		self.Last = os.clock()
		return random:NextInteger(self.Min, self.Max) == self.Target
	else
		return false
	end
end

return RandomChoice