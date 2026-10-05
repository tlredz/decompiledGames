local _ = {
	DefaultRateLimiterRate = 120
}
local RateLimiter = {
	Default = nil
}
local Players = game:GetService("Players")
local v = {}
local v2 = {}
local class = {}
class.__index = class

function class:CheckRate(player)
	local _sources = self._sources
	local now = os.clock()
	local _source = _sources[player]

	if _source == nil then
		if typeof(player) == "Instance" and player:IsA("Player") and v[player] == nil then
			return false
		end

		_sources[player] = now + self._rate_period
		return true
	else
		local v3 = math.max(now, _source + self._rate_period)

		if v3 - now < 1 then
			_sources[player] = v3
			return true
		else
			return false
		end
	end
end

function class:CleanSource(p2)
	self._sources[p2] = nil
end

function class:Cleanup()
	self._sources = {}
end

function class.Destroy(p)
	v2[p] = nil
end

function RateLimiter.NewRateLimiter(p)
	if p <= 0 then
		error("[RateLimiter]: Invalid rate")
	end

	local v3 = {
		_sources = {},
		_rate_period = 1 / p
	}
	setmetatable(v3, class)
	v2[v3] = true
	return v3
end

for _, v3 in ipairs(Players:GetPlayers()) do
	v[v3] = true
end

RateLimiter.Default = RateLimiter.NewRateLimiter(120)
Players.PlayerAdded:Connect(function(player)
	v[player] = true
end)
Players.PlayerRemoving:Connect(function(player)
	v[player] = nil

	for k in pairs(v2) do
		k._sources[player] = nil
	end
end)
return RateLimiter