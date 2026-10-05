local RunService = game:GetService("RunService")
local sway = require(script.Parent:WaitForChild("pkgs"):WaitForChild("sway"))
local movingShards = script.Parent.Parent:WaitForChild("MovingShards")

-- equivalent calls inferred from this helper; original call sites unknown
local function applySway(items, p)
	for _, item in items do
		sway.Create(item, p)
	end
end

local function vc(p: number)
	return (vector.create(p, p, p))
end

local descendants = movingShards:QueryDescendants("Motor6D")

while #descendants < 15 do
	task.wait(0.5)
	descendants = movingShards:QueryDescendants("Motor6D")
end

applySway(movingShards:QueryDescendants("Model[Name=Shards] >> Motor6D"), {
	Intensity = vector.create(0.25, 0.25, 0.25),
	RotationMultiplier = 2,
	Speed = 1
}) -- equivalent call inferred; original call site unknown
local step = sway.Step
RunService.Heartbeat:Connect(function(dt)
	step(dt)
end)