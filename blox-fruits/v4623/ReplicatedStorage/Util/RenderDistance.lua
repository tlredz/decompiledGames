local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local currentCamera = workspace.CurrentCamera
local v = nil
v = {
	new = function(p, p2, p3, value)
		local v2 = p3 or p2 * 2
		local v3 = value or 0.5
		local v4 = nil
		v4 = {
			Counter = 0,
			LastDistance = 0,
			LastTick = 0,
			value = v.value,
			GetDistance = function(self)
				if tick() - v4.LastTick > 0.5 then
					v4.LastDistance = v.value(p)
					v4.LastTick = tick()
				end

				return v4.LastDistance
			end,
			WithinRange = function(p4, p5)
				local distance = v4:GetDistance()

				if distance < p2 then
					return true
				end

				if not p5 then
					return false
				end

				local v5 = math.min(v3, (distance - p2) / (v2 - p2) * v3)
				p4.Counter += p5

				if v5 <= p4.Counter then
					p4.Counter = 0
					return true
				else
					return false
				end
			end
		}
		v4:GetDistance()
		return v4
	end,
	value = function(value)
		if not value then
			return 1e999
		end

		local v2 = typeof(value) == "Vector3"
		local v3

		if typeof(value) == "Instance" then
			v3 = value.ClassName == "Attachment"
		else
			v3 = false
		end

		if v3 then
			return (currentCamera.CFrame.p - value.WorldPosition).magnitude
		end

		return (currentCamera.CFrame.p - (v2 and value or value.Position)).magnitude
	end
}
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return v
end

local RunService2 = game:GetService("RunService")

if not (RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false) then
	return v
end

local MasterClock = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("MasterClock"))
local lastTime = nil
local count = 0
game.Players.LocalPlayer.Idled:Connect(function(p)
	if lastTime then
		local v2 = math.abs(p - (os.clock() - lastTime))

		if v2 <= 0.03333333333333333 or v2 + 1 <= 0.03333333333333333 then
			count += 1
		else
			count = 0
		end

		local v3 = count
		local Global = require(game.ReplicatedStorage.Global)

		if (Global.TestGame and 1 or 20) <= v3 then
			MasterClock._fixDelayRequest = true
		end
	end

	lastTime = os.clock()
end)

function MasterClock:_sendDelayRequest(p2)
	return getmetatable(self)._sendDelayRequest(self, p2 - (self._fixDelayRequest and 1200 or 0))
end

return v