local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local v = {
	script.Parent.Parent,
	ReplicatedFirst,
	ReplicatedStorage,
	ServerScriptService,
	ServerStorage
}

local function FindFirstDescendantWithNameAndClassName(folder, p: string, className: string)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA(className) and descendant.Name == p then
			return descendant
		end
	end

	return nil
end

local function GetPromiseLibrary()
	local plugin = script:FindFirstAncestorOfClass("Plugin")

	if plugin then
		local firstDescendantWithNameAndClassName = FindFirstDescendantWithNameAndClassName(
			plugin,
			"Promise",
			"ModuleScript"
		)

		if firstDescendantWithNameAndClassName then
			return true, require(firstDescendantWithNameAndClassName)
		end

		return false
	else
		local v2 = nil

		for _, v4 in ipairs(v) do
			v2 = FindFirstDescendantWithNameAndClassName(v4, "Promise", "ModuleScript")

			if v2 then
				break
			end
		end

		if v2 then
			return true, require(v2)
		end

		return false
	end
end

return GetPromiseLibrary