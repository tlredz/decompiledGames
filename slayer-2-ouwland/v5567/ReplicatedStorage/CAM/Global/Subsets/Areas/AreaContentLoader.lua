local AreaContentLoader = {}

local function ignoredSet(instance)
	local result = {}
	local success, result2 = pcall(function()
		return instance:QueryDescendants("[$Ignore],[$ignore]")
	end)

	if success and type(result2) == "table" then
		for _, v in result2 do
			result[v] = true
		end
	end

	return result
end

local function isIgnored(instance, p)
	if p == nil or not p[instance] then
		return instance:GetAttribute("$ignore") ~= nil or instance:GetAttribute("Ignore") ~= nil or instance:GetAttribute("ignore") ~= nil
	end

	return true
end

local collectModules

collectModules = function(instance, list, subArea: string?, p2)
	local v = p2 or ignoredSet(instance)

	for _, child in ipairs(instance:GetChildren()) do
		if not ((v == nil or not v[child]) and child:GetAttribute("$ignore") == nil and child:GetAttribute("Ignore") == nil and child:GetAttribute("ignore") == nil) then
			continue
		end

		if child:IsA("ModuleScript") then
			table.insert(list, {
				Module = child,
				SubArea = subArea
			})
		elseif child:IsA("Folder") then
			collectModules(child, list, subArea or child.Name, v)
		else
			warn((`[AreaContentLoader] Skipping {child.ClassName} "{child:GetFullName()}" — only ModuleScripts and Folders belong here`))
		end
	end

	return list
end

local function childAreaNames(p)
	local result = {}

	if type(p) ~= "table" or type(p.Grid) ~= "table" then
		return result
	end

	for _, v in ipairs(p.Grid) do
		if type(v.ChildAreas) ~= "table" then
			continue
		end

		for k in pairs(v.ChildAreas) do
			result[k] = true
		end
	end

	return result
end

local v = { "Npcs", "ActiveNpcs" }

function AreaContentLoader.loadNpcs(moduleScript, p)
	local v2 = childAreaNames(p)
	local v3 = {}
	local v4 = false
	local fullNamesByCode = {}
	local result = {}

	for _, childName in v do
		local child = moduleScript:FindFirstChild(childName)

		if child == nil then
			continue
		end

		collectModules(child, v3)
		v4 = true
	end

	if not (v4 or moduleScript:IsA("ModuleScript")) then
		collectModules(moduleScript, v3)
	end

	for _, v5 in v3 do
		local module = v5.Module
		local success, result2 = pcall(require, module)

		if success then
			if type(result2) == "table" then
				if result2.Ignore ~= true and result2.ignore ~= true then
					result2.SendOver = result2.SendOver or {}

					if result2.SendOver.Code == nil then
						result2.SendOver.Code = module.Name
					end

					if fullNamesByCode[result2.SendOver.Code] == nil then
						fullNamesByCode[result2.SendOver.Code] = module:GetFullName()
					else
						warn((`[AreaContentLoader] Duplicate NPC Code "{result2.SendOver.Code}": {module:GetFullName()} collides with {fullNamesByCode[result2.SendOver.Code]} — rename one of the modules`))
					end

					if v5.SubArea ~= nil then
						result2.SubArea = v5.SubArea

						if v2[v5.SubArea] then
							if result2.Marker == true then
								result2.Marker = v5.SubArea
							end
						elseif p ~= nil then
							warn((`[AreaContentLoader] Npcs subfolder "{v5.SubArea}" ({module:GetFullName()}) does not match any ChildAreas name — treating it as organization only`))
						end
					end

					table.insert(result, result2)
				end
			else
				warn((`[AreaContentLoader] NPC module {module:GetFullName()} must return a table, got {typeof(result2)}`))
			end
		else
			warn((`[AreaContentLoader] Failed to load NPC module {module:GetFullName()}: {result2}`))
		end
	end

	return result
end

function AreaContentLoader.mergeModules(instance)
	if instance == nil or #instance:GetChildren() == 0 then
		return nil
	end

	local v2 = instance.Name == "Quests" and "OfferNpc" or nil
	local result = {}
	local fullNames = {}

	for _, v3 in collectModules(instance, {}) do
		local module = v3.Module
		local success, result2 = pcall(require, module)

		if success then
			if type(result2) == "table" then
				for k, names in pairs(result2) do
					if result[k] ~= nil then
						warn((`[AreaContentLoader] Duplicate key "{k}" in {module:GetFullName()} (already defined by {fullNames[k]}) — the later one wins`))
					end

					if v2 ~= nil and type(names) == "table" and names[v2] == nil then
						names[v2] = module.Name
					end

					result[k] = names
					fullNames[k] = module:GetFullName()
				end
			else
				warn((`[AreaContentLoader] Module {module:GetFullName()} must return a table, got {typeof(result2)}`))
			end
		else
			warn((`[AreaContentLoader] Failed to load module {module:GetFullName()}: {result2}`))
		end
	end

	return result
end

return AreaContentLoader