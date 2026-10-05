local function PickRandom(items, p: number?)
	local total = 0

	for _, item in items do
		total += item
	end

	local number = Random.new(p):NextNumber(0, total)

	for k, item in items do
		if number < item then
			return k
		else
			number -= item
		end
	end

	return nil
end

return PickRandom