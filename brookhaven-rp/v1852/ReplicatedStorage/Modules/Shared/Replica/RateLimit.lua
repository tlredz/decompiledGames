local Players = game:GetService("Players")
local v = {}
local v2 = {}
local RateLimit = {}
RateLimit.__index = RateLimit

function RateLimit.New(p: number, flag: boolean?)
	if p <= 0 then
		error("[RateLimit]: Invalid rate")
	end

	local v3 = {
		sources = {},
		rate_period = 1 / p,
		is_full_wait = flag == true
	}
	setmetatable(v3, RateLimit)
	v2[v3] = true
	return v3
end

function RateLimit.CheckRate(data, p)
	local sources = data.sources
	local now = os.clock()
	local player = p == nil and "nil" or p
	local source = sources[player]

	if source == nil then
		if typeof(player) == "Instance" and player:IsA("Player") and v[player] == nil then
			return false
		end

		sources[player] = now + data.rate_period
		return true
	elseif data.is_full_wait == true then
		if source <= now then
			sources[player] = now + data.rate_period
			return true
		else
			return false
		end
	else
		local v3 = math.max(now, source + data.rate_period)

		if v3 - now < 1 then
			sources[player] = v3
			return true
		else
			return false
		end
	end
end

function RateLimit.CleanSource(p, p2)
	p.sources[p2] = nil
end

function RateLimit:Cleanup()
	self.sources = {}
end

function RateLimit.Destroy(p)
	v2[p] = nil
end

for _, v3 in ipairs(Players:GetPlayers()) do
	v[v3] = true
end

Players.PlayerAdded:Connect(function(player)
	v[player] = true
end)
Players.PlayerRemoving:Connect(function(player)
	v[player] = nil

	for k in pairs(v2) do
		k.sources[player] = nil
	end
end)
return RateLimit