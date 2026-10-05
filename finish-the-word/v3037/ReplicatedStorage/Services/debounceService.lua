local RunService = game:GetService("RunService")
local v = {}
local v2 = {}
local now = tick()

local function cleanupOldDebounces()
	local now2 = tick()

	if now2 - now < 60 then
		return
	end

	now = now2

	for k, v3 in pairs(v) do
		local v4

		if v3.expiry < now2 then
			v4 = now2 - v3.lastUsed > 300
		else
			v4 = false
		end

		if v4 then
			v2[k] = true
		end
	end

	for k in pairs(v2) do
		v[k] = nil
		v2[k] = nil
	end
end

local DebounceService = {
	clear = function(p)
		v[p] = nil
	end,
	isDebounced = function(p)
		if not v[p] then
			return false
		end

		local selected = tick() < v[p].expiry

		if selected then
			v[p].lastUsed = tick()
		end

		return selected
	end,
	debounce = function(p, value)
		if v[p] and tick() < v[p].expiry then
			return false
		end

		v[p] = {
			expiry = tick() + (value or 1),
			lastUsed = tick()
		}
		return true
	end
}

function DebounceService.createScope(p)
	return {
		debounce = function(p2, p3)
			return DebounceService.debounce(p .. ":" .. p2, p3)
		end,
		isDebounced = function(p2)
			return DebounceService.isDebounced(p .. ":" .. p2)
		end,
		clear = function(p2)
			DebounceService.clear(p .. ":" .. p2)
		end
	}
end

if RunService:IsClient() then
	RunService.Heartbeat:Connect(cleanupOldDebounces)
end

return DebounceService