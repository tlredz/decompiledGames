local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DISABLED_MODULE_SCRIPT = script.Parent.DISABLED_MODULE_SCRIPT
local DISABLED_SPEC = script.Parent.DISABLED_SPEC

-- equivalent calls inferred from this helper; original call sites unknown
local function getFramework()
	return require(ReplicatedStorage.Modules.Shared.Framework.Framework)
end

local FrameworkUtil = {
	disableScope = function(folder)
		local v = {}

		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant.ClassName == "ModuleScript" then
				table.insert(v, descendant)
			end
		end

		if folder.ClassName == "ModuleScript" then
			table.insert(v, folder)
		end

		local v2 = #v

		for _, v3 in pairs(v) do
			local clone = string.find(v3.Name, ".spec") and DISABLED_SPEC:Clone() or DISABLED_MODULE_SCRIPT:Clone()
			clone.Name = v3.Name
			clone.Parent = v3.Parent
			local framework = getFramework() -- equivalent call inferred; original call site unknown
			clone:SetAttribute(framework.Constants.DisabledAttribute, true)

			for _, child in ipairs(v3:GetChildren()) do
				child.Parent = clone
			end

			v3:Destroy()
		end

		return v2
	end
}
local v = {}

function FrameworkUtil.wrapModuleWithAnalytics(p, instance, object)
	local Table = require(ReplicatedStorage.Modules.Shared.Functions.Table)
	local name = instance.Name
	local fullName = instance:GetFullName()
	Table.iterateNestedTables(p, function(items, p2)
		for k, item in pairs(items) do
			if typeof(item) ~= "function" then
				continue
			end

			local formatted = `{fullName}-{p2}-{k}`

			if v[formatted] then
				continue
			end

			v[formatted] = true
			local v2 = item
			local v3 = k

			items[k] = function(...)
				local lastTime = tick()
				local v4 = { v2(...) }
				object:Fire(name, p2, v3, tick() - lastTime)
				return table.unpack(v4)
			end
		end
	end, 1)
end

return FrameworkUtil