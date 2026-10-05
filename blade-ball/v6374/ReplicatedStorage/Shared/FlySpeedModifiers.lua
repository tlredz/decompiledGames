local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Shared.SharedModifiers)
RunService:IsClient()
local v2 = v.new({
	Name = "FlySpeedModifiers",
	DefaultValue = 1
})
v2:Observe(function(instance, flySpeedMultiplier: number)
	instance:SetAttribute("FlySpeedMultiplier", flySpeedMultiplier)
end)
workspace.Dead.ChildAdded:Connect(function(child)
	v2:ClearAllModifiersFor(child)
end)
return v2