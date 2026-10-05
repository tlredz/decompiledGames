local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Players")
local v = require3(ReplicatedStorage2.Shared.SharedModifiers)
local isClient = RunService:IsClient()
local v2 = v.new({
	Name = "JumpModifiers",
	DefaultValue = 7.2
})
v2:Observe(function(instance, p: number)
	local humanoid = isClient and instance:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		if v.DEBUG then
			print("setting jump for", instance, "to", p)
		end

		humanoid.JumpHeight = p * instance:GetScale()
	end
end)
workspace.Dead.ChildAdded:Connect(function(child)
	v2:ClearAllModifiersFor(child)
end)
return v2