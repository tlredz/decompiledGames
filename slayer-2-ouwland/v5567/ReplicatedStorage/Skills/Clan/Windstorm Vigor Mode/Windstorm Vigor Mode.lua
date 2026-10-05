local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ActivationCore = require(ReplicatedStorage:WaitForChild("Skills"):WaitForChild("Clan"):WaitForChild("Activation"):WaitForChild("ActivationCore"))
return ActivationCore.new(script.Name, script)