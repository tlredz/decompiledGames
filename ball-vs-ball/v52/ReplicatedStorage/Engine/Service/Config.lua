local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CloudConfig = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("CloudConfig"))
return (CloudConfig.getAll())