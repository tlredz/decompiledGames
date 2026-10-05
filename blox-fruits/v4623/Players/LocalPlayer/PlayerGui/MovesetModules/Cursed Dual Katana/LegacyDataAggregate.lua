local HttpService = game:GetService("HttpService")
local parent = script.Parent
local require2 = require
local result = {
	Lvl = {},
	Cost = {},
	Cooldown = {}
}
local deepCopy

deepCopy = function(items)
	if type(items) ~= "table" then
		return items
	end

	local result2 = {}

	for k, item in items do
		result2[k] = deepCopy(item)
	end

	return result2
end

local deepMerge

deepMerge = function(p, items)
	if type(p) ~= "table" or type(items) ~= "table" then
		return p
	end

	for k, item in items do
		if type(item) == "table" and type(p[k]) == "table" then
			deepMerge(p[k], item)
		else
			p[k] = deepCopy(item)
		end
	end

	return p
end

local function readOverrides(instance, attributeName: string)
	local attribute = instance:GetAttribute(attributeName)

	if type(attribute) ~= "string" then
		return nil
	end

	local jSONDecode = HttpService:JSONDecode(attribute)

	if type(jSONDecode) == "table" then
		return jSONDecode
	end

	return nil
end

local function applyOverrides(p, p2)
	if p and type(p2) == "table" then
		return (deepMerge(deepCopy(p), p2))
	end

	return p
end

local function readShared(childName: string?, childName2: string?)
	if type(childName) ~= "string" or type(childName2) ~= "string" then
		return nil
	end

	local child = parent:FindFirstChild(childName)
	local child2 = child and child:FindFirstChild(childName2)
	local shared = child2 and child2:FindFirstChild("Shared")

	if shared and shared:IsA("ModuleScript") then
		return require2(shared)
	end

	return nil
end

local function readMovesetShared(childName: string?)
	if type(childName) ~= "string" then
		return nil
	end

	local child = parent:FindFirstChild(childName)
	local shared = child and child:FindFirstChild("Shared")

	if shared and shared:IsA("ModuleScript") then
		return require2(shared)
	end

	return nil
end

local bindings = parent:FindFirstChild("Bindings")

if bindings and bindings:IsA("Folder") then
	local function rebuild()
		table.clear(result.Lvl)
		table.clear(result.Cost)
		table.clear(result.Cooldown)
		result.Cap = nil
		result.Awakening = nil

		for _, folder in bindings:GetChildren() do
			if not folder:IsA("Folder") then
				continue
			end

			local name = folder.Name
			local moveset = folder:GetAttribute("Moveset")
			local move = folder:GetAttribute("Move") or name
			local v = readShared(moveset, move)
			local sharedOverrides = folder:GetAttribute("SharedOverrides")
			local v2

			if type(sharedOverrides) == "string" then
				v2 = HttpService:JSONDecode(sharedOverrides)

				if type(v2) ~= "table" then
					v2 = nil
				end
			end

			if v and type(v2) == "table" then
				v = deepMerge(deepCopy(v), v2)
			end

			if v then
				result.Lvl[name] = v.Lvl
				result.Cost[name] = v.Cost
				result.Cooldown[name] = v.Cooldown
			end

			local v3 = result.Cap == nil and readMovesetShared(moveset)

			if v3 then
				result.Cap = v3.Cap
			end

			local awakenedMoveset = folder:GetAttribute("AwakenedMoveset")
			local awakenedMove = folder:GetAttribute("AwakenedMove") or move
			local v4 = readShared(awakenedMoveset, awakenedMove)
			local awakenedSharedOverrides = folder:GetAttribute("AwakenedSharedOverrides")
			local v5

			if type(awakenedSharedOverrides) == "string" then
				v5 = HttpService:JSONDecode(awakenedSharedOverrides)

				if type(v5) ~= "table" then
					v5 = nil
				end
			end

			if v4 and type(v5) == "table" then
				v4 = deepMerge(deepCopy(v4), v5)
			end

			if not v4 then
				continue
			end

			result.Awakening = result.Awakening or {
				Cost = {},
				Cooldown = {},
				Fragments = {}
			}
			result.Awakening.Cost[name] = v4.Cost
			result.Awakening.Cooldown[name] = v4.Cooldown
			result.Awakening.Fragments[name] = v4.Fragments

			if result.Lvl[name] == nil then
				result.Lvl[name] = v4.Lvl
			end

			if result.Cap ~= nil then
				continue
			end

			local v6 = readMovesetShared(awakenedMoveset)

			if v6 then
				result.Cap = v6.Cap
			end
		end
	end

	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function queueRebuild()
		if flag then
			return
		end

		flag = true
		task.defer(function()
			flag = false
			rebuild()
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watchBinding(child)
		child.AttributeChanged:Connect(queueRebuild)
	end

	for _, child in bindings:GetChildren() do
		watchBinding(child) -- equivalent call inferred; original call site unknown
	end

	bindings.ChildAdded:Connect(function(child)
		watchBinding(child) -- equivalent call inferred; original call site unknown
		queueRebuild() -- equivalent call inferred; original call site unknown
	end)
	bindings.ChildRemoved:Connect(queueRebuild)
	rebuild()
	return result
else
	for _, folder in parent:GetChildren() do
		if not (folder:IsA("Folder") and folder.Name ~= "Bindings") then
			continue
		end

		local v = string.match(folder.Name, "%(Awakened%)$") ~= nil
		local awakening

		if v then
			result.Awakening = result.Awakening or {
				Cost = {},
				Cooldown = {},
				Fragments = {}
			}
			awakening = result.Awakening
		else
			awakening = result
		end

		local shared = folder:FindFirstChild("Shared")

		if not v and shared and shared:IsA("ModuleScript") then
			result.Cap = require2(shared).Cap
		end

		for _, folder2 in folder:GetChildren() do
			if not folder2:IsA("Folder") then
				continue
			end

			local shared2 = folder2:FindFirstChild("Shared")

			if not (shared2 and shared2:IsA("ModuleScript")) then
				continue
			end

			local module = require2(shared2)

			if awakening.Lvl then
				awakening.Lvl[folder2.Name] = module.Lvl
			elseif result.Lvl[folder2.Name] == nil then
				result.Lvl[folder2.Name] = module.Lvl
			end

			awakening.Cost[folder2.Name] = module.Cost
			awakening.Cooldown[folder2.Name] = module.Cooldown

			if awakening.Fragments then
				awakening.Fragments[folder2.Name] = module.Fragments
			end
		end
	end

	return result
end