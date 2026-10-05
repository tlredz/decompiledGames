local CombinedInput = {}
CombinedInput.__index = CombinedInput

function CombinedInput.new(inputs)
	local currentTexts = {}

	for _, v in inputs do
		currentTexts[v] = v:GetCurrentText()
	end

	return (setmetatable({
		Inputs = inputs,
		LastText = currentTexts[inputs[1]],
		LastTextValues = currentTexts
	}, CombinedInput))
end

function CombinedInput:GetCurrentText()
	local currentTextsByInput = {}

	for _, input in self.Inputs do
		currentTextsByInput[input] = input:GetCurrentText()
	end

	for _, input in self.Inputs do
		if currentTextsByInput[input] == self.LastTextValues[input] then
			continue
		end

		self.LastText = currentTextsByInput[input]
		break
	end

	return self.LastText
end

return CombinedInput