local Array2D = {}
Array2D.__index = Array2D

function Array2D.new(maxX: number, maxY: number)
	local self = setmetatable({}, Array2D)
	self.maxX = maxX
	self.maxY = maxY
	self._array = table.create(maxX * maxY)
	return self
end

function Array2D:set(p: number, p2: number, p3)
	if p >= 1 and p <= self.maxX and p % 1 == 0 then
		if not (p2 >= 1) or not (p2 <= self.maxY) or p2 % 1 ~= 0 then
			error("Array2D.set: The following y-index is out of bounds or is not an integer: " .. tostring(p2))
		end
	else
		error("Array2D.set: The following x-index is out of bounds or is not an integer: " .. tostring(p))
	end

	self._array[p + (p2 - 1) * self.maxX] = p3
end

function Array2D:get(p2: number, p3: number)
	return self._array[p2 + (p3 - 1) * self.maxX]
end

return Array2D