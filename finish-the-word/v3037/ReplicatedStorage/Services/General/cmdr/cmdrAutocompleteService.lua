local import = _G.import("cmdrService")
local import2 = _G.import("cmdrAutocompleteProviders")
local import3 = _G.import("cmdrTextUtil")
local import4 = _G.import("stringUtil")
local import5 = _G.import("commandsCollection")
local localPlayer = game.Players.LocalPlayer

local function getLocalGroups()
	local admin = localPlayer:GetAttribute("Admin")
	local moderator = localPlayer:GetAttribute("Moderator")
	return admin and {
		Admin = true
	} or moderator and {
		Moderator = true
	} or {}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sortCategoryOrder(categories)
	table.sort(categories, function(a, b)
		local lower = a:lower()
		local lower2 = b:lower()

		if lower == "other" and lower2 ~= "other" then
			return false
		end

		return lower2 == "other" and lower ~= "other" or lower < lower2
	end)
end

local function makeCommandEntryFromCommand(commandByName)
	return {
		Name = commandByName.Name or "",
		Description = commandByName.Description or "",
		ArgsText = import3.buildArgsText(commandByName) or "",
		Destructive = commandByName.Destructive,
		Category = commandByName.Category or "Other"
	}
end

local function isCommandAllowed(p, p2)
	if not p then
		return false
	end

	local groups = p.Groups

	if type(groups) ~= "table" or #groups == 0 then
		return true
	end

	for i = 1, #groups do
		local group = groups[i]

		if group and p2[group] then
			return true
		end
	end

	return false
end

local function getAllowedCommandNames(list)
	local localGroups = getLocalGroups()
	local result = {}

	for i = 1, #list do
		local v = list[i]
		local commandByName = import.getCommandByName(v)
		local flag

		if commandByName then
			local groups = commandByName.Groups

			if type(groups) == "table" and #groups ~= 0 then
				local flag2 = true

				for i2 = 1, #groups do
					local group = groups[i2]

					if not (group and localGroups[group]) then
						continue
					end

					flag = true
					flag2 = false
					break
				end

				if flag2 then
					flag = false
				end
			else
				flag = true
			end
		else
			flag = false
		end

		if flag then
			result[#result + 1] = v
		end
	end

	return result
end

local function getCommandEntryList(p)
	local allowedCommandNames = getAllowedCommandNames(p == "" and import5:getAllCommandNames() or import.getSuggestions(p))
	local commandEntryFromCommands = {}
	local byCategory = {}
	local categories = {}

	for i = 1, #allowedCommandNames do
		local allowedCommandName = allowedCommandNames[i]
		local commandByName = import.getCommandByName(allowedCommandName)

		if not commandByName then
			continue
		end

		local commandEntryFromCommand = makeCommandEntryFromCommand(commandByName)
		commandEntryFromCommands[#commandEntryFromCommands + 1] = commandEntryFromCommand
		local category = commandEntryFromCommand.Category

		if not byCategory[category] then
			byCategory[category] = {}
			categories[#categories + 1] = category
		end

		byCategory[category][#byCategory[category] + 1] = commandEntryFromCommand
	end

	sortCategoryOrder(categories) -- equivalent call inferred; original call site unknown

	for _, v3 in ipairs(categories) do
		table.sort(byCategory[v3], function(a, b)
			return a.Name:lower() < b.Name:lower()
		end)
	end

	return commandEntryFromCommands, {
		ByCategory = byCategory,
		CategoryOrder = categories
	}
end

local function getBestCommandCompletion(value)
	if value == "" then
		return
	end

	local v = getAllowedCommandNames(import.getSuggestions(value))[1]

	if not v then
		return
	end

	local lower = value:lower()
	local lower2 = v:lower()

	if not import4.startsWith(lower2, lower) then
		return
	end

	if lower2 == lower then
		return
	else
		return v
	end
end

local function getCommandGhostText(list)
	local bestCommandCompletion = getBestCommandCompletion(list[1] or "")

	if not bestCommandCompletion then
		return ""
	end

	local commandByName = import.getCommandByName(bestCommandCompletion)

	if not commandByName then
		return bestCommandCompletion
	end

	local argsText = import3.buildArgsText(commandByName)

	if argsText == "" then
		return bestCommandCompletion
	end

	return bestCommandCompletion .. " " .. argsText
end

local function buildArgumentsSoFar(p, list)
	local args = p.Args or {}
	local result = {}

	for i = 1, #args do
		local v = list[i + 1]

		if not v then
			break
		end

		result[args[i].Name] = v
	end

	return result
end

local function getArgumentContext(p, list)
	local v = list[1]
	local command = v and import.getCommandByName(v)

	if not command then
		return
	end

	local args = command.Args or {}
	local activeArgIndex = import3.getActiveArgIndex(p, list)
	local arg = args[#args]
	local argumentIndex = arg and arg.Variadic and #args < activeArgIndex and #args or activeArgIndex
	return {
		Command = command,
		ArgumentIndex = argumentIndex,
		ArgumentSpec = args[argumentIndex],
		Prefix = import3.getCurrentTokenPrefix(p, list),
		ArgumentsSoFar = buildArgumentsSoFar(command, list)
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getProvider(argumentSpec)
	if argumentSpec then
		return import2[argumentSpec.Provider or argumentSpec.Type]
	end
end

local function getArgumentGhostText(p, argumentContext)
	if not (argumentContext and argumentContext.Command) then
		return ""
	end

	local argumentSpec = argumentContext.ArgumentSpec
	local provider = getProvider(argumentSpec) -- equivalent call inferred; original call site unknown
	local v

	if provider then
		local v2
		v2, v = provider({
			Cmd = argumentContext.Command,
			ArgSpec = argumentSpec,
			ArgIndex = argumentContext.ArgumentIndex,
			Prefix = argumentContext.Prefix,
			ArgsSoFar = argumentContext.ArgumentsSoFar
		})
	else
		v = false
	end

	if (not v or v == "") and argumentSpec then
		local v2 = argumentSpec.Name == "amount"
		local v3 = argumentSpec.Optional and true or false
		local v4 = (argumentContext.Prefix or "") == ""
		v = v2 and v3 and v4 and "1" or v
	end

	if not v or v == "" then
		return ""
	end

	local ghostLineForCurrentToken = import3.buildGhostLineForCurrentToken(p, v)
	local remainingArgsText = import3.buildRemainingArgsText(argumentContext.Command, argumentContext.ArgumentIndex + 1)

	if remainingArgsText ~= "" then
		ghostLineForCurrentToken ..= " " .. remainingArgsText
	end

	return ghostLineForCurrentToken
end

local function getArgumentEntryList(argumentContext)
	if not (argumentContext and argumentContext.Command) then
		return {}
	end

	local provider = getProvider(argumentContext.ArgumentSpec) -- equivalent call inferred; original call site unknown

	if provider then
		return provider({
			Cmd = argumentContext.Command,
			ArgSpec = argumentContext.ArgumentSpec,
			ArgIndex = argumentContext.ArgumentIndex,
			Prefix = argumentContext.Prefix,
			ArgsSoFar = argumentContext.ArgumentsSoFar
		}) or {}
	end

	local remainingArgsText = import3.buildRemainingArgsText(argumentContext.Command, argumentContext.ArgumentIndex)

	if remainingArgsText == "" then
		return {}
	end

	return {
		{
			Name = argumentContext.Command.Name,
			Description = argumentContext.Command.Description or "",
			ArgsText = remainingArgsText
		}
	}
end

return {
	compute = function(p)
		local tokenize = import.tokenize(p)

		if import3.isCommandStage(p) then
			local v = tokenize[1] or ""
			local commandEntryList, groups = getCommandEntryList(v)
			local v3 = {
				Stage = "command",
				Key = "command:" .. v:lower(),
				GhostText = 0,
				Entries = 0,
				Groups = 0
			}
			local bestCommandCompletion = getBestCommandCompletion(tokenize[1] or "")

			if bestCommandCompletion then
				local commandByName = import.getCommandByName(bestCommandCompletion)

				if commandByName then
					local argsText = import3.buildArgsText(commandByName)

					if argsText ~= "" then
						bestCommandCompletion ..= " " .. argsText
					end
				end
			else
				bestCommandCompletion = ""
			end

			v3.GhostText = bestCommandCompletion
			v3.Entries = commandEntryList
			v3.Groups = groups
			return v3
		else
			local argumentContext = getArgumentContext(p, tokenize)
			local v = not (argumentContext and argumentContext.ArgumentSpec) and "none" or argumentContext.ArgumentSpec.Provider or argumentContext.ArgumentSpec.Type or "none"
			local v2 = not argumentContext and "" or argumentContext.Prefix or ""
			return {
				Stage = "args",
				Key = ("args:%s:%d:%s"):format(
					v,
					not argumentContext and 0 or argumentContext.ArgumentIndex or 0,
					v2:lower()
				),
				GhostText = getArgumentGhostText(p, argumentContext),
				Entries = getArgumentEntryList(argumentContext)
			}
		end
	end
}