local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = require(ReplicatedStorage.Omni.Shared)
return table.freeze({
	Get = function(_, value: string, name2: string)
		if not (value and name2) then
			return
		end

		local name = Shared.Gems.GetName({
			Type = value,
			Name = name2
		})

		if name and name ~= "Gems" then
			return Shared.Items.List[name]
		end

		if value == "Currency" then
			return Shared.Perks[name2]
		end

		if value == "Title" or value == "Titles" then
			return Shared.ProfileTitles.List[name2]
		end

		local list = Shared[value] or Shared[value .. "s"] or Shared[value:sub(1, #value - 1) .. "ies"]

		if list and list.List then
			list = list.List
		end

		local v

		if list then
			return list[name2]
		end

		return v
	end
})