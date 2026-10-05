local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoadoutClient = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("LoadoutClient"))
LoadoutClient.Init({
	showHealth = true,
	showHighlight = true
})