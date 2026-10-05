local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {
	ChristmasCookie = "Christmas Cookie",
	DandyEasterEggs = "Dandy's Easter Eggs",
	DandyCorn = "Dandy Corn",
	BonBon = "Bon Bon"
}
local namesByChildName = {}

local function moduleName(childName)
	local v2 = namesByChildName[childName]

	if v2 ~= nil then
		return v2 or nil
	end

	local itemModules = ReplicatedStorage:FindFirstChild("ItemModules")
	local moduleScript = itemModules and itemModules:FindFirstChild(childName)
	local name = false

	if moduleScript and moduleScript:IsA("ModuleScript") then
		local success, result = pcall(require, moduleScript)

		if success and type(result) == "table" and type(result.Name) == "string" and result.Name ~= "" then
			name = result.Name
		end
	end

	namesByChildName[childName] = name
	return name or nil
end

return {
	get = function(value, value2)
		if type(value) ~= "string" then
			return (tostring(value2 or value))
		end

		local v2 = v[value]

		if v2 then
			return v2
		end

		if type(value2) == "string" and value2 ~= "" then
			return value2
		end

		local v3 = moduleName(value)
		return v3 or value:gsub("(%l)(%u)", "%1 %2")
	end
}