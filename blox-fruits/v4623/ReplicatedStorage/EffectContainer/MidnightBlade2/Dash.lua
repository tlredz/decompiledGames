local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tween = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("Tween"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local MasterClock = require(ReplicatedStorage2:WaitForChild("Util"):WaitForChild("MasterClock"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local HeartbeatLoopFor = require(ReplicatedStorage3:WaitForChild("Util"):WaitForChild("HeartbeatLoopFor"))
local _ = HeartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = HeartbeatLoopFor.AwaitHeartbeatLoopFor

local function adjustDuration(p, p2)
	local v = math.max(0.01, p - p2)
	return v, p2 - (p - v)
end

return function(data)
	local root = data.Root or data.HRP
	local origin = data.Origin
	local point = data.Point
	local duration = data.Duration
	local dimension

	if data.Dimension == nil then
		dimension = root:GetAttribute("PortaledToAnotherDimension") == true
	else
		dimension = data.Dimension
	end

	local v = origin
	local flag = false

	local function isCancelled()
		if not root.Parent or root:GetAttribute("PortaledToAnotherDimension") == true ~= dimension or (root.Position - v).Magnitude > 200 then
			flag = true
		end

		return flag
	end

	if not root.Parent or root:GetAttribute("PortaledToAnotherDimension") == true ~= dimension or (root.Position - v).Magnitude > 200 then
		flag = true
	end

	if flag then
		return
	end

	local v2 = math.max(0, MasterClock.MasterClock:GetTime() - data.ClockTime)
	local unit = (point - origin).Unit

	if game.Players.LocalPlayer == game.Players:GetPlayerFromCharacter(root.Parent) then
		origin = root.Position
	end

	local v3 = origin + unit * math.min(200, (point - origin).Magnitude)
	local v4 = math.max(0.01, duration - v2)
	local _ = v2 - (duration - v4)
	awaitHeartbeatLoopFor(v4, function(_, _, p)
		if not root.Parent or root:GetAttribute("PortaledToAnotherDimension") == true ~= dimension or (root.Position - v).Magnitude > 200 then
			flag = true
		end

		if flag then
			return
		end

		local quad = Tween.ease.out.quad(p, 0, 1, 1)
		local v5 = origin + (v3 - origin) * quad

		if root.Anchored == false then
			root.CFrame = CFrame.new(createVector(0, 0, 0), unit) + v5
			v = v5
		end
	end, function()
		if not root.Parent or root:GetAttribute("PortaledToAnotherDimension") == true ~= dimension or (root.Position - v).Magnitude > 200 then
			flag = true
		end

		if flag then
			return
		end

		if root.Anchored == false then
			root.CFrame = CFrame.new(createVector(0, 0, 0), unit) + v3
		end
	end)
end