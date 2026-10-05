local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local v = {}

for i = 1, 25 do
	table.insert(v, i)
end

return Conch.register_type("CalendarDay", Conch.args.enum_new(v))