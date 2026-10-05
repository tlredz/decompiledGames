local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Shared.SharedModifiers)
local isServer = RunService:IsServer()
local v2 = v.new({
	Name = "ScaleModifiers",
	DefaultValue = 1
})
v2:Observe(function(instance, p: number)
	if isServer then
		instance:ScaleTo(p)
	end
end)
workspace.Dead.ChildAdded:Connect(function(child)
	v2:ClearAllModifiersFor(child)
	child:SetAttribute("ReaperKills", nil)
end)
return v2