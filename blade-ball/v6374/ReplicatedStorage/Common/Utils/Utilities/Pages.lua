local Promise = require(script.Parent.Promise)
local promisify = Promise.promisify(function(object)
	return object:AdvanceToNextPageAsync()
end)

local function fn(object, callback, callback2, callback3)
	return Promise.new(function(callback4, callback5, callback6)
		local v = false
		v = callback6(function()
			v = true
		end)
		local count = 0
		local v2 = {}

		while not v do
			count += 1
			local currentPage = object:GetCurrentPage()
			table.move(currentPage, 1, #currentPage, #v2 + 1, v2)

			if callback then
				task.spawn(callback, currentPage, count)
			end

			if object.IsFinished then
				break
			end

			if Promise.retryWithDelay(promisify, 10, 2, object):await() or v then
				continue
			end

			if not callback2 then
				break
			end

			task.spawn(callback2, count)
			break
		end

		if v then
			return callback5(nil, nil)
		end

		if callback3 then
			task.spawn(callback3, v2, count)
		end

		return callback4(v2, count)
	end)
end

local Pages = {}

function Pages:AdvanceToNextPageAsync(p)
	return promisify(p)
end

function Pages:IterPagesAsync(p, callback, callback2, callback3)
	return fn(p, callback, callback2, callback3)
end

function Pages:IterPages(p, callback, callback2, callback3)
	return self:IterPagesAsync(p, callback, callback2, callback3):expect()
end

return Pages