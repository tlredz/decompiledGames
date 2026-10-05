local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ActivationCoreServer = require(ReplicatedStorage.Skills.Clan.Activation.ActivationCoreServer)
return ActivationCoreServer.new(script.Parent.Name, script)