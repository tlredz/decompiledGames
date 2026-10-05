local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
task.wait()
local v = {
	createVector(0, 0, 4),
	createVector(4, 0, 0),
	createVector(0, 0, -4),
	createVector(-4, 0, 0)
}
local v2 = {}

for i = 1, 4 do
	if not script.Parent:FindFirstChild("Blood" .. i) then
		continue
	end

	v2[i] = TweenService:Create(script.Parent["Blood" .. i], TweenInfo.new(2, Enum.EasingStyle.Exponential), {
		Position = v[i]
	})
	v2[i]:Play()
end

local smear = script.Parent:WaitForChild("Smear")
smear.Enabled = false

function quadraticBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local v3 = CFrame.new(0, 3, 0) * CFrame.Angles(-0.3490658503988659, 0, 0)
local total = 0
RunService.Stepped:Connect(function(_, dt)
	total += 1 * dt
	script.Parent.Weld.C1 *= CFrame.Angles(0, math.rad(160 * dt), 0)
	script.Parent.Weld.C0 = v3 * CFrame.Angles(math.sin(total) * 10, 0, math.sin(total) * 10) + Vector3.new(
		0,
		math.sin(total) - 1,
		0
	)
end)
local parent = script.Parent.Parent.Parent
local humanoidRootPart = parent.HumanoidRootPart

if script.Parent:GetAttribute("Charge") < 4 then
	for i = 4, script.Parent:GetAttribute("Charge") + 1, -1 do
		if script.Parent:FindFirstChild("Blood" .. i) then
			script.Parent["Blood" .. i]:Destroy()
		end
	end
end

script.Parent:GetAttributeChangedSignal("Charge"):Connect(function()
	local parent2 = script.Parent["Blood" .. script.Parent:GetAttribute("Charge") + 1]
	Debris:AddItem(parent2, 1)

	if v2[script.Parent:GetAttribute("Charge") + 1] then
		v2[script.Parent:GetAttribute("Charge") + 1]:Cancel()
		v2[script.Parent:GetAttribute("Charge") + 1]:Destroy()
	end

	task.delay(0.6, function()
		parent2.Trail.Enabled = false
		parent2.ParticleEmitter:Destroy()
		local clone = game.ReplicatedStorage.Utils.Choso.PiercingBlood.Start.Burst:Clone()
		clone.Parent = parent2
		clone:Emit(4)
	end)
	local worldPosition = parent2.WorldPosition
	parent2.Parent = humanoidRootPart
	parent2.WorldPosition = worldPosition
	local cframe = CFrame.new(math.random(1, 2) == 1 and -8 or 8, math.random(4, 7), -4)
	local lastTime = tick()
	local steppedConnection = nil
	steppedConnection = RunService.Stepped:Connect(function()
		if not parent2.Parent then
			steppedConnection:Disconnect()
			return
		end

		local v5 = (tick() - lastTime) / 0.6
		local v6 = parent["Right Arm"].Position - parent["Right Arm"].CFrame.UpVector * 1
		local position = (humanoidRootPart.CFrame * cframe).Position
		parent2.WorldPosition = quadraticBezier(v5, worldPosition, position, v6)
	end)
end)