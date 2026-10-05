local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Debris")
task.wait()
local v = {
	createVector(0, 0, 2.6),
	createVector(2.6, 0, 0),
	createVector(0, 0, -2.6),
	createVector(-2.6, 0, 0)
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

script.Parent.Weld.C1 = CFrame.new(0, 0, 0)
script.Parent.Smear.Enabled = true
local v3 = CFrame.new(0, 2, 2) * CFrame.Angles(1.3089969389957472, 0, 0)
RunService.Stepped:Connect(function(_, dt)
	script.Parent.Weld.C1 *= CFrame.Angles(0, math.rad(700 * dt), 0)
	script.Parent.Weld.C0 = script.Parent.Weld.C0:Lerp(v3, 0.1)
end)
local _ = script.Parent.Parent.Parent.HumanoidRootPart

if script.Parent:GetAttribute("Charge") < 4 then
	for i = 4, script.Parent:GetAttribute("Charge") + 1, -1 do
		if script.Parent:FindFirstChild("Blood" .. i) then
			script.Parent["Blood" .. i]:Destroy()
		end
	end
end

script.Parent:GetAttributeChangedSignal("Charge"):Connect(function()
	script.Parent["Blood" .. script.Parent:GetAttribute("Charge") + 1]:Destroy()

	if script.Parent:GetAttribute("Charge") == 0 then
		script.Parent.Smear.Enabled = false
	end
end)