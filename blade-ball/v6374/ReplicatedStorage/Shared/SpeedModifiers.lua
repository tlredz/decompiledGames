local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Players")
local v = require3(ReplicatedStorage2.Shared.SharedModifiers)
local v2 = require3(ReplicatedStorage2.Shared.LTM)
local isClient = RunService:IsClient()
local v3 = v.new({
	Name = "SpeedModifiers",
	DefaultValue = 36
})
v3:Observe(function(instance, p: number)
	local humanoid = isClient and instance:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		if v.DEBUG then
			print("setting speed for", instance, "to", p)
		end

		local scale = instance:GetScale()
		local currentLTM = v2.getCurrentLTM()
		humanoid.WalkSpeed = p * (currentLTM and currentLTM.getGameMode() == "Fates" and 1 or scale)
	end
end)
workspace:WaitForChild("Dead").ChildAdded:Connect(function(child)
	v3:ClearAllModifiersFor(child)
	child:SetAttribute("ReaperKills", nil)
end)
return v3