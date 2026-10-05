local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local gearTools = ReplicatedStorage.GearTools
local frozen = table.freeze({})
local strict = t.strict(t.string)

local function toolNamed(tool, p: string)
	local v

	if tool == nil then
		v = false
	else
		v = tool.Name == p
	end

	if v and tool:IsA("Tool") then
		return tool
	end

	return nil
end

return function(childName: string)
	strict(childName)
	local tool = gearTools:FindFirstChild(childName, true)
	local v

	if tool == nil then
		v = false
	else
		v = tool.Name == childName
	end

	if not (v and tool:IsA("Tool")) then
		tool = nil
	end

	local v2

	if tool == nil then
		v2 = gearTools:GetDescendants()
	else
		v2 = frozen
	end

	for _, tool2 in v2 do
		if tool then
			continue
		end

		local v3

		if tool2 == nil then
			v3 = false
		else
			v3 = tool2.Name == childName
		end

		if v3 and tool2:IsA("Tool") then
			tool = tool2
		else
			tool = nil
		end
	end

	return tool
end