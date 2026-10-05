local ReplicatedStorage = game:GetService("ReplicatedStorage")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local ServerInfo = require(ReplicatedStorage.ServerInfo)
require(ReplicatedStorage.Shared.UseBall2)

if ServerInfo.isElementalServer() or ServerInfo.isTradingPlazaServer() then
	script.Parent.Visible = false
	script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
		script.Parent.Visible = false
	end)
else
	script.Parent.Activated:Connect(function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		ReplicatedStorage2.Remotes.AbilityButtonPress:Fire()
	end)
	script.Parent.MouseButton1Up:Connect(function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		ReplicatedStorage2.Remotes.AbilityButtonHold:Fire(false)
	end)
	script.Parent.MouseButton1Down:Connect(function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		ReplicatedStorage2.Remotes.AbilityButtonHold:Fire(true)
	end)
end