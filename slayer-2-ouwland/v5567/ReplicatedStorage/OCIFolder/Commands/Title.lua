local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local isServer = RunService:IsServer()
local Titles = require(ReplicatedStorage.CAM.Global.Titles)
local TitleService = isServer and require(ServerStorage.SAM.Services.TitleService) or nil
local suggester = {}
local v2 = {}
local suggester2 = { "Unlock", "Lock" }

for k, v4 in Titles.GetAll() do
	table.insert(suggester, k)
	v2[k:lower()] = k

	if type(v4.displayName) == "string" then
		v2[v4.displayName:lower()] = k
	end
end

table.sort(suggester)

-- equivalent calls inferred from this helper; original call sites unknown
local function named(items, p)
	local lower = tostring(p):lower()

	for _, item in items do
		if item:lower() == lower then
			return item
		end
	end

	return nil
end

return {
	Clearance = 6,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Action",
			Name = "Action",
			Required = true,
			Suggester = suggester2,
			Completer = function(p: string)
				local lower = tostring(p):lower()

				for _, v5 in suggester2 do
					if v5:lower() == lower then
						return v5
					end
				end

				return nil
			end
		},
		{
			Type = "Title",
			Name = "Title",
			Required = true,
			Suggester = suggester,
			Completer = function(value: string)
				if value == nil or value == "" then
					return nil
				end

				return v2[value:lower()] or value
			end
		}
	},
	Server = function(_, items, p: string, p2)
		local item2 = named(suggester2, p) -- equivalent call inferred; original call site unknown

		if item2 == nil then
			error((`Invalid title action: {tostring(p)} (Unlock or Lock)`))
		end

		local v6 = v2[tostring(p2):lower()]

		if v6 == nil then
			error((`No title "{tostring(p2)}"`))
		end

		local unlock

		if item2 == "Unlock" then
			unlock = TitleService.Unlock
		else
			unlock = TitleService.Lock
		end

		local v7 = true
		local v8 = {}

		for _, item in items do
			local v9, v10 = unlock(item, v6)
			table.insert(v8, (`{item.Name}: {v10}`))
			v7 = v7 and v9
		end

		local v9 = {
			Content = table.concat(v8, "\n"),
			ContentColor = Color3.new(1, 1, 1),
			BgColor = 0
		}
		local color

		if v7 then
			if item2 == "Unlock" then
				color = Color3.fromRGB(30, 110, 60)
			else
				color = Color3.fromRGB(150, 80, 30)
			end
		else
			color = Color3.fromRGB(150, 30, 30)
		end

		v9.BgColor = color
		return v9
	end
}