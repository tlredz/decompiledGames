workspace:WaitForChild("_WorldOrigin")
local RunService = game:GetService("RunService")
return function(data)
	local adornee = data.Adornee
	local attackerChar = data.AttackerChar
	local attackerHum = data.AttackerHum
	local victimChar = data.VictimChar
	local victimHum = data.VictimHum
	local grabExists = data.GrabExists
	local offset = data.Offset or CFrame.new(0, 0, 0)
	local timeout = data.Timeout or 5
	local humanoidRootPart = attackerChar:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = victimChar:FindFirstChild("HumanoidRootPart")
	local v = {
		adornee,
		attackerChar,
		attackerHum,
		humanoidRootPart,
		victimChar,
		victimHum,
		humanoidRootPart2,
		grabExists
	}

	if humanoidRootPart2 and grabExists then
		local lastTime = tick()
		local v2 = false

		while RunService.RenderStepped:Wait() do
			for _, v3 in ipairs(v) do
				if not (v3 and v3.Parent) then
					v2 = true
				end
			end

			if v2 or victimHum.Health <= 0 or attackerHum.Health <= 0 or timeout < tick() - lastTime then
				break
			else
				humanoidRootPart2.CFrame = adornee.CFrame * offset
			end
		end
	end
end