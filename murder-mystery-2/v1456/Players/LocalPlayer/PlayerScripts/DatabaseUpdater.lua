local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))

local function onDatabaseUpdated(p: string, items)
	for k, item in items do
		Sync[p][k] = {}

		for _, v in item do
			Sync[p][k] = v
		end
	end
end