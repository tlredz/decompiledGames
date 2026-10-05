local ClockUnwrap = {
	SCALE = 10000,
	WRAP = 429496.7296,
	quantize = function(p: number)
		return math.floor(p * 10000) % 4294967296
	end,
	new = function()
		return {
			lastRaw = nil,
			offset = 0
		}
	end,
	unwrap = function(state, p: number)
		local lastRaw2 = p % 4294967296
		local lastRaw = state.lastRaw

		if lastRaw then
			local v2 = (lastRaw2 - lastRaw) % 4294967296

			if v2 < 2147483648 then
				if lastRaw2 < lastRaw then
					state.offset += 429496.7296
				end

				state.lastRaw = lastRaw2
			else
				return (lastRaw + state.offset * 10000 - (4294967296 - v2)) / 10000
			end
		else
			state.lastRaw = lastRaw2
		end

		return lastRaw2 / 10000 + state.offset
	end
}

function ClockUnwrap:unwrapFor(p2, p3: number)
	local v = self[p2]

	if not v then
		v = ClockUnwrap.new()
		self[p2] = v
	end

	return ClockUnwrap.unwrap(v, p3)
end

function ClockUnwrap:seatFull(p2: number)
	local v = math.floor(p2 * 10000)
	local lastRaw = v % 4294967296
	self.lastRaw = lastRaw
	self.offset = (v - lastRaw) / 10000
	return v / 10000
end

function ClockUnwrap:seatFullFor(p2, p3: number)
	local v = self[p2]

	if not v then
		v = ClockUnwrap.new()
		self[p2] = v
	end

	return ClockUnwrap.seatFull(v, p3)
end

return ClockUnwrap