local function loadModules(instance)
	local result = {}

	for _, moduleScript in ipairs(instance:GetChildren()) do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local success, result2 = pcall(require, moduleScript)

		if success and type(result2) == "table" then
			result[moduleScript.Name] = result2
		else
			warn((`[AdminAbuse] require "{moduleScript.Name}" échoue`))
		end
	end

	return result
end

local function readMeta(name: string, result)
	local needsDuration = false
	local maxDurationSeconds = nil
	local defaultDurationSeconds = nil
	local isAdminAbuse = true
	local displayName

	if type(result) == "table" then
		if type(result.DisplayName) == "string" and result.DisplayName ~= "" then
			displayName = result.DisplayName
		else
			displayName = name
		end

		needsDuration = result.NeedsDuration == true or false

		if type(result.MaxDurationSeconds) == "number" and result.MaxDurationSeconds > 0 then
			maxDurationSeconds = result.MaxDurationSeconds
		end

		if type(result.DefaultDurationSeconds) == "number" and result.DefaultDurationSeconds > 0 then
			defaultDurationSeconds = result.DefaultDurationSeconds
		end

		if result.IsAdminAbuse == false then
			isAdminAbuse = false
		end
	else
		displayName = name
	end

	return {
		name = name,
		displayName = displayName,
		needsDuration = needsDuration,
		maxDurationSeconds = maxDurationSeconds,
		defaultDurationSeconds = defaultDurationSeconds,
		isAdminAbuse = isAdminAbuse
	}
end

local AdminAbuseRegistry = {}

function AdminAbuseRegistry.listModuleNames(instance)
	local names = {}

	for _, moduleScript in ipairs(instance:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			table.insert(names, moduleScript.Name)
		end
	end

	table.sort(names)
	return names
end

function AdminAbuseRegistry.listModuleMetas(instance)
	local result = {}

	for _, moduleScript in ipairs(instance:GetChildren()) do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local success, result2 = pcall(require, moduleScript)

		if not (not success or type(result2) ~= "table" or result2.Hidden ~= true) then
			continue
		end

		if success then
			table.insert(result, (readMeta(moduleScript.Name, result2)))
		else
			table.insert(result, {
				name = moduleScript.Name,
				displayName = moduleScript.Name,
				needsDuration = false,
				maxDurationSeconds = nil,
				defaultDurationSeconds = nil
			})
		end
	end

	table.sort(result, function(a, b)
		return a.displayName < b.displayName
	end)
	return result
end

function AdminAbuseRegistry.buildAdminAbuseTable(p)
	local v = loadModules(p)
	return (setmetatable({}, {
		__index = function(_, p2: string)
			return v[p2]
		end
	}))
end

function AdminAbuseRegistry.loadRegistry(p)
	return (loadModules(p))
end

return AdminAbuseRegistry