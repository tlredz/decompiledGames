local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)
return function(callback, value: number?, p: number?, p2: number?)
	local v = value or 5
	local v2

	if v >= 1 then
		v2 = v % 1 == 0
	else
		v2 = false
	end

	assert(v2, "retry attempts must be a positive integer")
	assert(p == nil == (p2 == nil), "retry delay range needs both minimum and maximum")

	if p and p2 then
		local v3

		if p >= 0 then
			v3 = p <= p2
		else
			v3 = false
		end

		assert(v3, "invalid retry delay range")
	end

	return Promise.new(function(callback2, callback3)
		local random = Random.new()
		local v3 = nil

		for i = 1, v do
			if i > 1 then
				local v4 = 2 ^ (i - 2)

				if p and p2 then
					v4 = random:NextNumber(p * v4, p2 * v4)
				end

				task.wait(v4)
			end

			local v4 = table.pack(pcall(callback))

			if v4[1] then
				callback2(table.unpack(v4, 2, v4.n))
				return
			else
				v3 = v4[2]
			end
		end

		callback3((`gave up after {v} attempts; last failure: {v3}`))
	end)
end