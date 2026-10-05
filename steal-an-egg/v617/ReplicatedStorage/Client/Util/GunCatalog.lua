local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gears = require(ReplicatedStorage.Data.Gears)
local _ids = {}

for _, v in pairs(Gears.Directory) do
	if v.ToolController == "Gun" then
		_ids[#_ids + 1] = v._id
	end
end

table.freeze(_ids)
return {
	ListGearNames = function()
		return table.clone(_ids)
	end
}