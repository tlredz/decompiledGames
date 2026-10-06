local Players = game:GetService("Players")
local CommandSchema = {
	result = function(ok, code, message, p4)
		return {
			ok = ok,
			code = code,
			message = message,
			data = p4
		}
	end,
	param = function(candidates)
		if type(candidates) == "string" then
			if candidates == "playerName" then
				return {
					type = "string",
					candidates = "playerName"
				}
			end

			return {
				type = candidates
			}
		else
			if type(candidates) == "function" then
				return {
					type = "string",
					candidates = candidates
				}
			end

			if type(candidates) ~= "table" then
				error("Invalid parameter definition.")
				return
			end

			if type(candidates.type) == "string" then
				return table.clone(candidates)
			end

			return {
				type = "string",
				candidates = candidates
			}
		end
	end,
	paramNames = function(p)
		local v = {}
		local result = {}

		for _, v2 in p.paramOrder or {} do
			assert(p.params and p.params[v2] ~= nil, "Parameter order contains an undefined parameter.")
			assert(not v[v2], "Parameter order contains a duplicate parameter.")
			v[v2] = true
			table.insert(result, v2)
		end

		local v2 = {}

		for k in p.params or {} do
			if not v[k] then
				table.insert(v2, k)
			end
		end

		table.sort(v2)

		for _, v3 in v2 do
			table.insert(result, v3)
		end

		return result
	end,
	candidates = function(callback)
		if type(callback) == "function" then
			callback = callback()
		end

		local result = {}

		if callback == "playerName" then
			for _, v in Players:GetPlayers() do
				table.insert(result, v.Name)
			end
		elseif type(callback) == "table" then
			if #callback > 0 then
				for _, item in callback do
					table.insert(result, (tostring(item)))
				end
			else
				for k in callback do
					table.insert(result, (tostring(k)))
				end
			end
		end

		table.sort(result)
		return result
	end
}

function CommandSchema.validate(p, p2)
	local v = p2 == nil and {} or p2

	if type(v) ~= "table" then
		return nil, CommandSchema.result(false, "INVALID_ARGUMENTS", "Invalid input.")
	end

	for k in v do
		if (k ~= "enabled" or not p.toggle) and (not p.params or p.params[k] == nil) then
			return nil, CommandSchema.result(false, "INVALID_ARGUMENTS", "Unknown field: " .. tostring(k))
		end
	end

	local defaults = {}

	if p.toggle then
		if type(v.enabled) ~= "boolean" then
			return nil, CommandSchema.result(false, "INVALID_ARGUMENTS", "Choose on or off.")
		end

		defaults.enabled = v.enabled
	end

	for _, v2 in CommandSchema.paramNames(p) do
		local param = CommandSchema.param(p.params[v2])
		local default = v[v2]

		if default == "" then
			default = nil
		end

		if default == nil then
			default = param.default
		end

		local v3 = v2

		local function invalid(p3)
			return nil, CommandSchema.result(false, "INVALID_ARGUMENTS", v3 .. ": " .. p3)
		end

		if default == nil then
			if param.required ~= false and param.default == nil then
				return invalid("required")
			end
		else
			if param.type == "number" or param.type == "integer" then
				if type(default) == "string" then
					default = tonumber(default)
				end

				if type(default) ~= "number" or default ~= default or math.abs(default) == 1e999 then
					return invalid("enter a valid number")
				end

				if param.type == "integer" and default % 1 ~= 0 then
					return invalid("enter a whole number")
				end

				if param.min ~= nil and (default < param.min or param.exclusiveMin and default == param.min) then
					return invalid("value is too low")
				end

				if param.max ~= nil and param.max < default then
					return invalid("value is too high")
				end
			elseif param.type == "string" then
				if type(default) ~= "string" then
					return invalid("enter text")
				end
			elseif param.type == "boolean" then
				if type(default) ~= "boolean" then
					return invalid("choose on or off")
				end
			else
				if param.type ~= "player" then
					return invalid("unsupported field")
				end

				if type(default) == "string" then
					default = Players:FindFirstChild(default)
				end

				if typeof(default) ~= "Instance" or not default:IsA("Player") or default.Parent ~= Players then
					return invalid("choose a player in this server")
				end
			end

			if param.choices and not table.find(CommandSchema.candidates(param.choices), (tostring(default))) then
				return invalid("choose an available option")
			end
		end

		defaults[v2] = default
	end

	return defaults, nil
end

function CommandSchema.describe(name, data)
	local params = {}

	for _, v2 in CommandSchema.paramNames(data) do
		local param = CommandSchema.param(data.params[v2])
		local v3 = {
			type = param.type,
			required = param.required ~= false and param.default == nil,
			default = param.default,
			min = param.min,
			max = param.max,
			exclusiveMin = param.exclusiveMin,
			candidates = CommandSchema.candidates(param.candidates or param.choices),
			choices = 0
		}
		local choices

		if param.choices then
			choices = CommandSchema.candidates(param.choices)
		end

		v3.choices = choices
		params[v2] = v3
	end

	return {
		name = name,
		desc = data.desc or "",
		order = data.order or 0,
		params = params,
		paramOrder = CommandSchema.paramNames(data),
		client = type(data.clientFn) == "function",
		server = type(data.serverFn) == "function",
		toggle = data.toggle == true,
		hideUIAfterExec = data.hideUIAfterExec == true
	}
end

function CommandSchema.list(items)
	local result = {}

	for k, item in items do
		table.insert(result, {
			name = k,
			desc = item.desc or "",
			order = item.order or 0,
			client = type(item.clientFn) == "function",
			server = type(item.serverFn) == "function"
		})
	end

	table.sort(result, function(a, b)
		if a.order == b.order then
			return a.name < b.name
		end

		return a.order < b.order
	end)
	return result
end

function CommandSchema.invoke(callback, p, p2)
	if not callback then
		return CommandSchema.result(true, "OK", "Done.")
	end

	local v = nil
	local v2, v3 = xpcall(function()
		v = table.pack(callback(p, p2))
	end, debug.traceback)

	if not v2 then
		warn("[AdminPanel] " .. tostring(v3))
		return CommandSchema.result(false, "EXECUTION_ERROR", "Could not complete the command.")
	end

	local v4 = v[1]

	if type(v4) == "table" and type(v4.ok) == "boolean" then
		return CommandSchema.result(
			v4.ok,
			v4.code or v4.ok and "OK" or "COMMAND_REJECTED",
			v4.message or v4.reason or v4.ok and "Done." or "Could not complete the command.",
			v4.data
		)
	end

	if type(v4) == "boolean" then
		return CommandSchema.result(
			v4,
			v4 and "OK" or "COMMAND_REJECTED",
			v[2] or v4 and "Done." or "Could not complete the command."
		)
	end

	return CommandSchema.result(true, "OK", "Done.", v4)
end

return CommandSchema