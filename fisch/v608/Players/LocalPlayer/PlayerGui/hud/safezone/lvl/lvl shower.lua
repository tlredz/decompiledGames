local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local stats = legacyLocalPlayerData.fetch():WaitForChild("Stats")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local level = require(ReplicatedStorage2.shared.modules:WaitForChild("character"):WaitForChild("level"))
stats:WaitForChild("level"):GetPropertyChangedSignal("Value"):Connect(function()
	if stats:WaitForChild("level").Value >= level.Max then
		script.Parent.Text = "Max Level"
	else
		script.Parent.Text = "Level " .. stats:WaitForChild("level").Value
	end
end)

if stats:WaitForChild("level").Value >= level.Max then
	script.Parent.Text = "Max Level"
else
	script.Parent.Text = "Level " .. stats:WaitForChild("level").Value
end