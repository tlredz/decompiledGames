local ReflectionService = game:GetService("ReflectionService")
local v = {}
local v2 = {
	Parent = true,
	ClassName = true,
	Name = true,
	ExtentsCFrame = true,
	ExtentsSize = true,
	ResizeIncrement = true,
	ResizeableFaces = true,
	CurrentPhysicalProperties = true,
	Sandboxed = true,
	Capabilities = true,
	PrivateServerId = true,
	PrivateServerOwnerId = true,
	SerializedDefaultAttributes = true
}
local v3 = {
	Debug = true
}
local success, result = pcall(function()
	return tostring(SecurityCapabilities.fromCurrent()):split(" | ")
end)
local v4 = not success and {} or result

local function canRead(read)
	if not read then
		return true
	end

	local parts = tostring(read):split(" | ")

	if parts[1] == nil or parts[1] == "" then
		return true
	end

	for _, part in parts do
		if not table.find(v4, part) then
			return false
		end
	end

	return true
end

return {
	getReadProperties = function(p: string)
		local v5 = v[p]

		if v5 then
			return v5
		end

		local names = {}
		local success2, result2 = pcall(function()
			return ReflectionService:GetPropertiesOfClass(p)
		end)

		if success2 and result2 then
			for _, v6 in result2 do
				local name = v6.Name

				if v2[name] then
					continue
				end

				local display = v6.Display

				if not (not display or (not display.DeprecationMessage or display.DeprecationMessage == "") and not (display.Category and v3[display.Category])) then
					continue
				end

				local type = v6.Type

				if not (not type or type.ScriptType ~= "Instance") then
					continue
				end

				local permits = v6.Permits

				if canRead(permits and permits.Read) then
					table.insert(names, name)
				end
			end
		end

		v[p] = names
		return names
	end
}