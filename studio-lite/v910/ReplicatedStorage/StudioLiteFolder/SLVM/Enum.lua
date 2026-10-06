require(script.Parent:WaitForChild("Types"))
local sLVMEnums = shared.SLVMEnums or {}
local RecursiveFreeze

RecursiveFreeze = function(list, list2)
	if not table.isfrozen(list) then
		table.freeze(list)
	end

	for k, v in list do
		if type(v) == "table" and not table.find(list2, k) then
			RecursiveFreeze(v, list2)
		end

		task.wait()
	end
end

local function GetDictionaryLength(items)
	local count = 0

	for _, _ in pairs(items) do
		count += 1
	end

	return count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetFirstElementOfTable(items)
	for _, item in pairs(items) do
		return item
	end
end

local function AddSubEnum(p: string)
	sLVMEnums[p] = {}
	return sLVMEnums[p]
end

local function AddEnumItem(enumType, name: string)
	local count = 0
	local v = {
		Name = name,
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(enumType) do
		count += 1
	end

	v.Value = count + 1
	v.EnumType = enumType
	enumType[name] = v
	return enumType[name]
end

if not shared.SLVMEnums then
	sLVMEnums.RuleType = {}
	local ruleType = sLVMEnums.RuleType
	local count = 0
	local closureRestriction = {
		Name = "ClosureRestriction",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(ruleType) do
		count += 1
	end

	closureRestriction.Value = count + 1
	closureRestriction.EnumType = ruleType
	ruleType.ClosureRestriction = closureRestriction
	local _ = ruleType.ClosureRestriction
	local count2 = 0
	local userDataRestriction = {
		Name = "UserDataRestriction",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(ruleType) do
		count2 += 1
	end

	userDataRestriction.Value = count2 + 1
	userDataRestriction.EnumType = ruleType
	ruleType.UserDataRestriction = userDataRestriction
	local _ = ruleType.UserDataRestriction
	local count3 = 0
	local tableRestriction = {
		Name = "TableRestriction",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(ruleType) do
		count3 += 1
	end

	tableRestriction.Value = count3 + 1
	tableRestriction.EnumType = ruleType
	ruleType.TableRestriction = tableRestriction
	local _ = ruleType.TableRestriction
	local count4 = 0
	local propertyRestriction = {
		Name = "PropertyRestriction",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(ruleType) do
		count4 += 1
	end

	propertyRestriction.Value = count4 + 1
	propertyRestriction.EnumType = ruleType
	ruleType.PropertyRestriction = propertyRestriction
	local _ = ruleType.PropertyRestriction
	local count5 = 0
	local typeRestriction = {
		Name = "TypeRestriction",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(ruleType) do
		count5 += 1
	end

	typeRestriction.Value = count5 + 1
	typeRestriction.EnumType = ruleType
	ruleType.TypeRestriction = typeRestriction
	local _ = ruleType.TypeRestriction
	sLVMEnums.VariableType = {}
	local variableType = sLVMEnums.VariableType
	local count6 = 0
	local number = {
		Name = "Number",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(variableType) do
		count6 += 1
	end

	number.Value = count6 + 1
	number.EnumType = variableType
	variableType.Number = number
	local _ = variableType.Number
	local count7 = 0
	local string = {
		Name = "String",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(variableType) do
		count7 += 1
	end

	string.Value = count7 + 1
	string.EnumType = variableType
	variableType.String = string
	local _ = variableType.String
	local count8 = 0
	local boolean = {
		Name = "Boolean",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(variableType) do
		count8 += 1
	end

	boolean.Value = count8 + 1
	boolean.EnumType = variableType
	variableType.Boolean = boolean
	local _ = variableType.Boolean
	local count9 = 0
	local table2 = {
		Name = "Table",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(variableType) do
		count9 += 1
	end

	table2.Value = count9 + 1
	table2.EnumType = variableType
	variableType.Table = table2
	local _ = variableType.Table
	local count10 = 0
	local closure = {
		Name = "Closure",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(variableType) do
		count10 += 1
	end

	closure.Value = count10 + 1
	closure.EnumType = variableType
	variableType.Closure = closure
	local _ = variableType.Closure
	local count11 = 0
	local v12 = {
		Name = "Nil",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(variableType) do
		count11 += 1
	end

	v12.Value = count11 + 1
	v12.EnumType = variableType
	variableType.Nil = v12
	local _ = variableType.Nil
	sLVMEnums.AdditionalSettings = {}
	local additionalSettings = sLVMEnums.AdditionalSettings
	local count12 = 0
	local throttleLoopInstructions = {
		Name = "ThrottleLoopInstructions",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(additionalSettings) do
		count12 += 1
	end

	throttleLoopInstructions.Value = count12 + 1
	throttleLoopInstructions.EnumType = additionalSettings
	additionalSettings.ThrottleLoopInstructions = throttleLoopInstructions
	local _ = additionalSettings.ThrottleLoopInstructions
	local count13 = 0
	local throttleRecursiveCalls = {
		Name = "ThrottleRecursiveCalls",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(additionalSettings) do
		count13 += 1
	end

	throttleRecursiveCalls.Value = count13 + 1
	throttleRecursiveCalls.EnumType = additionalSettings
	additionalSettings.ThrottleRecursiveCalls = throttleRecursiveCalls
	local _ = additionalSettings.ThrottleRecursiveCalls
	local count14 = 0
	local sandboxCalls = {
		Name = "SandboxCalls",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(additionalSettings) do
		count14 += 1
	end

	sandboxCalls.Value = count14 + 1
	sandboxCalls.EnumType = additionalSettings
	additionalSettings.SandboxCalls = sandboxCalls
	local _ = additionalSettings.SandboxCalls
	sLVMEnums.ScriptGlobalType = {}
	local scriptGlobalType = sLVMEnums.ScriptGlobalType
	local count15 = 0
	local serverScript = {
		Name = "ServerScript",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(scriptGlobalType) do
		count15 += 1
	end

	serverScript.Value = count15 + 1
	serverScript.EnumType = scriptGlobalType
	scriptGlobalType.ServerScript = serverScript
	local _ = scriptGlobalType.ServerScript
	local count16 = 0
	local client = {
		Name = "Client",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(scriptGlobalType) do
		count16 += 1
	end

	client.Value = count16 + 1
	client.EnumType = scriptGlobalType
	scriptGlobalType.Client = client
	local _ = scriptGlobalType.Client
	local count17 = 0
	local none = {
		Name = "None",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(scriptGlobalType) do
		count17 += 1
	end

	none.Value = count17 + 1
	none.EnumType = scriptGlobalType
	scriptGlobalType.None = none
	local _ = scriptGlobalType.None
	local count18 = 0
	local autoResolve = {
		Name = "AutoResolve",
		Value = 0,
		EnumType = 0
	}

	for _, _ in pairs(scriptGlobalType) do
		count18 += 1
	end

	autoResolve.Value = count18 + 1
	autoResolve.EnumType = scriptGlobalType
	scriptGlobalType.AutoResolve = autoResolve
	local _ = scriptGlobalType.AutoResolve
	RecursiveFreeze(sLVMEnums, { "EnumType" })
	shared.SLVMEnums = sLVMEnums
end

return {
	EnumList = sLVMEnums,
	Utilities = {
		IsA = function(_, items, p: string)
			if type(items) ~= "table" then
				return false
			end

			if items.Name and p == "EnumItem" or p == "Enum" then
				return true
			end

			local firstElementOfTable = GetFirstElementOfTable(items) -- equivalent call inferred; original call site unknown

			if type(firstElementOfTable) == "table" and firstElementOfTable.Name and p == "SubEnum" then
				return true
			end

			return false
		end,
		FindEnumItemByValue = function(_, items, p: number)
			for _, item in pairs(items) do
				if item.Value == p then
					return item
				end
			end
		end,
		FindEnumItemByName = function(_, items, p: string)
			for _, item in pairs(items) do
				if item.Name == p then
					return item
				end
			end
		end
	}
}