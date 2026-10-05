local Languages = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
local FastSignal = require(ReplicatedStorage.Modules.FastSignal)
local v = {
	en = true
}
Languages.List = { "en" }
Languages.Updated = FastSignal.new()
Languages.MultiLingual = false

local function isTableIdentical(list, list2)
	for _, v2 in next, list, nil do
		if not table.find(list2, v2) then
			return false
		end
	end

	for _, v2 in next, list2, nil do
		if not table.find(list, v2) then
			return false
		end
	end

	return true
end

function Languages.HasLanguage(_, p: string, flag: boolean?)
	if v.all and not flag then
		return true
	end

	return v[p] and true or false
end

Network:listen("UpdatePlayerLanguages", function(list)
	if isTableIdentical(Languages.List, list) then
		return
	end

	if not next(list) then
		table.insert(list, "en")
	end

	local v2 = {}

	for _, v3 in next, list, nil do
		v2[v3] = true
	end

	v = v2
	Languages.MultiLingual = #list > 1
	Languages.List = list
	Languages.Updated:Fire()
end)
return Languages