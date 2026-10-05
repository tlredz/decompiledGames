local dressrosa = workspace:FindFirstChild("Dressrosa") or workspace:FindFirstChild("Map")

local function MapRay(p, p2, ...)
	return workspace:FindPartOnRayWithWhitelist(Ray.new(p, p2), { dressrosa, ... })
end

local RunService = game:GetService("RunService")
local BodyMover = require(game.ReplicatedStorage.Util.BodyMover)
local _ = workspace.CurrentCamera
return function(list)
	local cFrame2, v2 = unpack(list)
	local Players = game:GetService("Players")
	local character = Players.LocalPlayer.Character
	local magnitude = character:GetModelSize().Magnitude
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local v3 = BodyMover.new(character)
	local v4 = v3:Create("BodyGyro", {
		CFrame = cFrame2
	})
	local v5 = v3:Create("BodyPosition", {
		Position = cFrame2.p
	})
	local lastTime = tick()
	local cFrame = cFrame2
	local v6 = cFrame
	cFrame = v6
	local v8 = 0
	local v9 = 1

	while tick() - lastTime < v2 do
		local now = tick()
		local v10 = (now - lastTime) / v2
		math.sin(3.141592653589793 * v10)
		local _ = v10 ^ 0.5

		if now - v8 > 0.075 then
			cFrame = humanoidRootPart.CFrame
			local v11 = cFrame2 * CFrame.Angles(
				Random.new():NextNumber(0, 3.141592653589793),
				v9 * Random.new():NextNumber(0, 6.283185307179586),
				0
			) * Vector3.new(0, 0, -magnitude)
			local v12, v13, v14 = MapRay(cFrame.p, (v11 - cFrame.p) * 1.1)

			if v12 then
				v11 = v13 + v14 * magnitude / 2
			end

			v6 = CFrame.new(v11, cFrame2.p) * CFrame.Angles(0, 0, Random.new():NextNumber(0, 6.283185307179586))
			v9 = v9 == 1 and -1 or 1
			v8 = now
		else
			local lerped = cFrame:Lerp(v6, (now - v8) / 0.075)
			v4:Set(lerped)
			v5:Set(lerped.p)
			humanoidRootPart.CFrame = lerped
		end

		RunService.Stepped:Wait()
	end

	v5:Destroy()
	v4:Destroy()
end