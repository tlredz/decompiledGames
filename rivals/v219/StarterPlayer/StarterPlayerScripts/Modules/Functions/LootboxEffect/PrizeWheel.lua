local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utility = require(ReplicatedStorage.Modules.Utility)
local v = {
	6.15,
	6.35,
	6.6,
	6.8,
	7.15,
	7.45,
	7.8,
	8.25,
	8.8,
	9.6,
	11.05
}
return function(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChild("RootPart")
	Utility:CreateSound("rbxassetid://97748906880096", 1, 1, humanoidRootPart, true)
	wait(1.45)
	Utility:CreateSound("rbxassetid://103519956736851", 1, 1.25, humanoidRootPart, true)
	wait(0.6)
	local lastTime = tick()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function get_pitch()
		return (1.5 + -0.3999999999999999 * ((tick() - lastTime) / 9) ^ 2) * (0.975 + 0.05 * math.random())
	end

	local v2 = tick() + 4
	local v3 = 0

	while tick() < v2 do
		if v3 < tick() then
			Utility:CreateSound("rbxassetid://103519956736851", 0.8, get_pitch(), humanoidRootPart, true)
			v3 = tick() + 0.08
		end

		RunService.RenderStepped:Wait()
	end

	for k, v4 in pairs(v) do
		local v5 = v[k - 1] or 6.05
		wait(v4 - v5)
		Utility:CreateSound("rbxassetid://103519956736851", 0.8, get_pitch(), humanoidRootPart, true)
	end

	wait(3.95)
end