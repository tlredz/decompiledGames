local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Handler = require(script.Parent:WaitForChild("Handler"))
local Confetti = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("Confetti"))
local serverData = ReplicatedStorage:WaitForChild("ServerData")

local function NextRelease()
	local serverTimeNow = workspace:GetServerTimeNow()
	local v = nil
	local v2 = nil

	for k, v3 in serverData:GetAttributes() do
		if not (string.sub(k, 1, 10) == "ReleaseAt_" and typeof(v3) == "number" and serverTimeNow < v3 and (v == nil or v3 < v)) then
			continue
		end

		v2 = k
		v = v3
	end

	return v2, v
end

local v = nil
local v2 = nil
local Watch

Watch = function()
	local v3, v4 = NextRelease()

	if v3 == nil or v == v3 and v2 == v4 then
		return
	end

	v = v3
	v2 = v4
	task.spawn(function()
		local v5 = v4 - 10 - workspace:GetServerTimeNow()

		if v5 > 0 then
			task.wait(v5)
		end

		if serverData:GetAttribute(v3) ~= v4 or v ~= v3 or localPlayer:GetAttribute("GameLoaded") ~= true then
			return
		end

		Handler:Countdown("Update Starts In", v4)
		task.wait((math.max(v4 - workspace:GetServerTimeNow(), 0)))

		if serverData:GetAttribute(v3) ~= v4 then
			return
		end

		pcall(Confetti.Burst)

		if v == v3 then
			v = nil
			v2 = nil
		end

		Watch()
	end)
end

local v3, v4 = NextRelease()

if v3 ~= nil and (v ~= v3 or v2 ~= v4) then
	v = v3
	v2 = v4
	task.spawn(function()
		local v5 = v4 - 10 - workspace:GetServerTimeNow()

		if v5 > 0 then
			task.wait(v5)
		end

		if serverData:GetAttribute(v3) ~= v4 or v ~= v3 or localPlayer:GetAttribute("GameLoaded") ~= true then
			return
		end

		Handler:Countdown("Update Starts In", v4)
		task.wait((math.max(v4 - workspace:GetServerTimeNow(), 0)))

		if serverData:GetAttribute(v3) ~= v4 then
			return
		end

		pcall(Confetti.Burst)

		if v == v3 then
			v = nil
			v2 = nil
		end

		Watch()
	end)
end

serverData.AttributeChanged:Connect(function(value)
	if string.sub(value, 1, 10) == "ReleaseAt_" then
		local v5, v6 = NextRelease()

		if v5 == nil or v == v5 and v2 == v6 then
			return
		end

		v = v5
		v2 = v6
		task.spawn(function()
			local v7 = v6 - 10 - workspace:GetServerTimeNow()

			if v7 > 0 then
				task.wait(v7)
			end

			if serverData:GetAttribute(v5) ~= v6 or v ~= v5 or localPlayer:GetAttribute("GameLoaded") ~= true then
				return
			end

			Handler:Countdown("Update Starts In", v6)
			task.wait((math.max(v6 - workspace:GetServerTimeNow(), 0)))

			if serverData:GetAttribute(v5) ~= v6 then
				return
			end

			pcall(Confetti.Burst)

			if v == v5 then
				v = nil
				v2 = nil
			end

			Watch()
		end)
	end
end)