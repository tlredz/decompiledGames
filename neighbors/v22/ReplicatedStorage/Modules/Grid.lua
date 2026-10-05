local Grid = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function buildSquareGrid(total: number)
	local v = math.ceil(total ^ 0.5)
	return Vector2.new(v, (math.ceil(total / v)))
end

local function spiralGenerator()
	local v = 0
	local v2 = 0
	local v3 = 0
	local v4 = 0
	local count = 0
	return function()
		local v5 = v
		local v6 = v2

		if v3 == 0 then
			v3 = 1
			v = 1
			v2 = -1
			v4 = 0
			count = 0
			return Vector2.zero
		else
			if v4 == 0 then
				v2 += 1
				count += 1
				local v7 = count

				if v3 * 2 <= v7 then
					v4 = 1
					count = 0
				end
			elseif v4 == 1 then
				v -= 1
				count += 1
				local v7 = count

				if v3 * 2 <= v7 then
					v4 = 2
					count = 0
				end
			elseif v4 == 2 then
				v2 -= 1
				count += 1
				local v7 = count

				if v3 * 2 <= v7 then
					v4 = 3
					count = 0
				end
			elseif v4 == 3 then
				v += 1
				count += 1
				local v7 = count

				if v3 * 2 <= v7 then
					v3 += 1
					v4 = 0
					count = 0
					v = v3
					v2 = -v3
				end
			end

			return Vector2.new(v5, v6)
		end
	end
end

function Grid.new(total: number)
	local self = setmetatable({}, {
		__index = Grid
	})

	if total == 1e999 then
		local v = 0
		local v2 = 0
		local v3 = 0
		local v4 = 0
		local count = 0

		function self._generator()
			local v5 = v
			local v6 = v2

			if v3 == 0 then
				v3 = 1
				v = 1
				v2 = -1
				v4 = 0
				count = 0
				return Vector2.zero
			else
				if v4 == 0 then
					v2 += 1
					count += 1
					local v7 = count

					if v3 * 2 <= v7 then
						v4 = 1
						count = 0
					end
				elseif v4 == 1 then
					v -= 1
					count += 1
					local v7 = count

					if v3 * 2 <= v7 then
						v4 = 2
						count = 0
					end
				elseif v4 == 2 then
					v2 -= 1
					count += 1
					local v7 = count

					if v3 * 2 <= v7 then
						v4 = 3
						count = 0
					end
				elseif v4 == 3 then
					v += 1
					count += 1
					local v7 = count

					if v3 * 2 <= v7 then
						v3 += 1
						v4 = 0
						count = 0
						v = v3
						v2 = -v3
					end
				end

				return Vector2.new(v5, v6)
			end
		end
	else
		self.Size = buildSquareGrid(total)
	end

	self.Total = total
	self.Count = 0
	return self
end

function Grid:GetNext()
	self.Count += 1

	if self._generator then
		return self._generator()
	end

	local v = self.Count - 1
	local v2 = v % self.Size.X + 1
	local v3 = math.floor(v / self.Size.X) + 1
	return Vector2.new(v2, v3)
end

return Grid