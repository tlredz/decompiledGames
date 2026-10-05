local schemes = script.Parent.Schemes
local v = {}

for _, child in ipairs(schemes:GetChildren()) do
	local modulesByName = {}

	for _, moduleScript in ipairs(child:GetChildren()) do
		local name = moduleScript.Name
		local module = require(moduleScript)
		modulesByName[name] = module
	end

	v[child.Name] = modulesByName
end

local function GetSchemesFor(part)
	local className = part.ClassName
	local v2 = className == "StringValue" and part:GetAttribute("SoundLocation") and "Sound" or className

	if part:IsA("BasePart") then
		return v.BasePart, part
	end

	if v[v2] ~= nil then
		return v[v2], part
	end

	if v2 == "Configuration" then
		local className2 = part:GetAttribute("ClassName")

		if v[className2] then
			return v[className2], part
		end

		if v[part.Name] then
			local parent = part.Parent
			return v[part.Name], parent
		end
	end
end

return GetSchemesFor