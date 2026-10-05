local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local Updates = require(ReplicatedStorage.Shared.Updates)
local fFlags = {}

for _, v in Updates.List do
	table.insert(fFlags, v.FFlag)
end

return Conch.register_type("Update", Conch.args.enum_new(fFlags))