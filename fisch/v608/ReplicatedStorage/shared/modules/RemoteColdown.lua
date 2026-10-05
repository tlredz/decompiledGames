local Players = game:GetService("Players")
local v = {}

local function RateLimit(p, p2: string, p3: number)
	if not v[p] then
		v[p] = {}
	end

	local now = os.clock()
	local v2 = v[p][p2] or 0

	if p3 <= now - v2 then
		v[p][p2] = now
		return true, p3
	else
		return false, p3 - (now - v2)
	end
end

Players.PlayerRemoving:Connect(function(player)
	v[player] = nil
end)
return RateLimit