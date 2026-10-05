local Players = game:GetService("Players")
local v = {}

local function Remove(p)
	v[p] = nil
end

Players.PlayerRemoving:Connect(Remove)
local ServerClock = {}

function ServerClock.Store(object, p: number, p2: number?)
	local v2 = v[object]

	if not v2 then
		v2 = {
			clockOffset = 0,
			oneWayDelay = 0.05
		}
		v[object] = v2
	end

	if p2 then
		local oneWayDelay = workspace:GetServerTimeNow() - p2

		if oneWayDelay > 0 and oneWayDelay <= object:GetNetworkPing() + 0.05 then
			v2.oneWayDelay = oneWayDelay
		end
	end

	local v3 = math.max(object:GetNetworkPing(), 0) + 0.05
	local v4 = os.clock() - p - math.clamp(v2.oneWayDelay, 0, v3)
	v2.clockOffset += 0.2 * (v4 - v2.clockOffset)
end

function ServerClock.ConvertTo(p, p2: number, p3: string)
	local v2 = v[p]

	if not v2 then
		return p2
	end

	if p3 == "Server" then
		return p2 + v2.clockOffset
	end

	return p2 - v2.clockOffset
end

ServerClock.Remove = Remove
return ServerClock