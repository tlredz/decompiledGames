require(script.Parent.Parent.types)
local getSender = require(script.Parent.Parent.getSender)

local function noop() end

local TestRemote = {}

function TestRemote.createTestRemote()
	local v = {}
	local count = 0

	local function fire(_, p, ...)
		local sender = getSender(p)

		for _, v2 in v do
			if sender then
				v2(...)
			else
				v2(p, ...)
			end
		end
	end

	return {
		_fire = fire,
		onFire = function(_, p)
			local v2 = count
			count += 1
			v[v2] = p
			return function()
				v[v2] = nil
			end
		end,
		disconnectAll = function(_)
			table.clear(v)
		end
	}
end

function TestRemote.createTestAsyncRemote()
	local v = noop

	local function request(_, p, ...)
		if getSender(p) then
			return v(...)
		end

		return v(p, ...)
	end

	local function handleRequest(_, p)
		v = p
	end

	local function hasRequestHandler()
		return v ~= noop
	end

	local function disconnectAll()
		v = noop
	end

	return {
		_request = request,
		handleRequest = handleRequest,
		hasRequestHandler = hasRequestHandler,
		disconnectAll = disconnectAll
	}
end

return TestRemote