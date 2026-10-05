local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return function(list, p: string)
	local v = tonumber(p)

	if v == nil then
		return
	end

	for _, v2 in ipairs(list) do
		local data = Utility.GetData(v2, true)

		if data then
			data.Customization.Pants.Value.Value = v
		end
	end
end