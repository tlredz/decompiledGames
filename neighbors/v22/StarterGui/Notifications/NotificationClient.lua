local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Network = require(ReplicatedStorage.Modules.Network)
require(ReplicatedStorage.Modules.UI)
Network:listen("NotifyClient", function(text, value)
	local clone = script.Example:Clone()
	clone.ContentContainer.Description.Text = text
	clone.Parent = script.Parent
	Debris:AddItem(clone, value or 10)
end)