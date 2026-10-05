local createVector = vector.create
local module = require("./ast")
require("./treewalker")

-- equivalent calls inferred from this helper; original call sites unknown
local function span_cursor(p, vector2: Vector3)
	if p.cursor < vector2.x then
		return "before"
	end

	if p.cursor > vector2.y then
		return "after"
	end

	return "within"
end

local v = newproxy()
local v2 = {
	a = "\7",
	b = "\8",
	f = "\f",
	n = "\n",
	r = "\r",
	t = "\t",
	v = "\11",
	["\\"] = "\\",
	["'"] = "'",
	["\""] = "\""
}

local function get_value(token)
	if token.kind == "number" then
		return tonumber(token.text) or v
	end

	if token.kind == "string" then
		local v3 = string.sub(token.text, 2, -2)
		local v4 = string.gsub(v3, "\\([0-9][0-9]?[0-9]?)", function(p: string)
			local v5 = tonumber(p)

			if v5 and not (v5 > 255) then
				return (string.char(v5))
			end

			return p
		end)

		for k, v5 in v2 do
			v4 = string.gsub(v4, `\\{k}`, v5)
		end

		return v4
	else
		if token.kind == "identifier" then
			return token.text
		end

		if token.kind == "true" then
			return true
		end

		if token.kind == "false" then
			return false
		end

		if token.kind == "nil" then
			return nil
		end

		return v
	end
end

local function char(value: string)
	return string.byte(value)
end

local function is_start_ident_char(p: number)
	return p ~= nil and (p >= 97 and p <= 122 or (p >= 65 and p <= 90 or (p == 64 or p == 95)))
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function is_digit_char(p: number)
	return p >= 48 and p <= 57
end

local function is_ident_char(p: number)
	local v3 = is_start_ident_char(p)
	return v3 or p == 45 or is_digit_char(p) or p == 58
end

local function is_identifier(text: string)
	if not is_start_ident_char(string.byte(text, 1, 1)) then
		return false
	end

	for i = 2, #text do
		local v3 = string.byte(text, i, i)
		local v4 = is_start_ident_char(v3)

		if not v4 then
			if v3 == 45 then
				v4 = true
			else
				v4 = is_digit_char(v3) or v3 == 58
			end
		end

		if not v4 then
			return false
		end
	end

	return true
end

local function wrap_if_necessary(suggestion)
	if suggestion.kind == "expression" then
		return suggestion.text
	end

	if suggestion.kind == "assign" and is_identifier(suggestion.text) then
		return (`{suggestion.text} =`)
	end

	if suggestion.kind == "assign" then
		return (`[{string.format("%q", suggestion.text)}] =`)
	end

	if is_identifier(suggestion.text) then
		return suggestion.text
	end

	return string.format("%q", suggestion.text)
end

local evaluate_expression

evaluate_expression = function(data)
	if not data then
		return nil
	end

	if data.kind == "boolean" then
		return (get_value(data.token))
	end

	if data.kind == "evaluate" then
		if data.command.value then
			return evaluate_expression(data.command.value)
		end

		return v
	else
		if not (data.kind ~= "nil" and data.kind ~= "number" and data.kind ~= "string") then
			return (get_value(data.token))
		end

		if data.kind == "table" then
			local result = {}
			local v3 = 1

			for _, v4 in data.values.value do
				local value = v4.value

				if value.kind == "expression_key" then
					local v5 = evaluate_expression(value.key and value.key.value)
					local v6 = evaluate_expression(value.value)

					if v5 then
						result[v5] = v6
					end
				elseif value.kind == "name_key" then
					result[value.name.text] = evaluate_expression(value.value)
				elseif value.kind == "nokey" then
					result[v3] = evaluate_expression(value.value)
					v3 += 1
				end
			end

			return result
		else
			if not (data.kind == "unary" and data.value) then
				return v
			end

			local v3 = evaluate_expression(data.value)

			if data.operator.kind == "!" then
				return not v3
			end

			if data.operator.kind ~= "-" then
				return v
			end

			local success, result = pcall(function()
				return -v3
			end)

			if success then
				return result
			end

			return v
		end
	end
end

local create_visitor = module.visit.create_visitor()
local get_metadata_for

get_metadata_for = function(data)
	if not (data.kind ~= "intersection" and data.kind ~= "union") then
		return get_metadata_for(data.fields[1])
	end

	if data.kind == "command" then
		return {
			name = data.name,
			description = data.description or "",
			type = "Command"
		}
	end

	return nil
end

function create_visitor:visit_var_root(p)
	if span_cursor(self, p.span) ~= "within" then
		return
	end

	local span2 = p.span
	local suggestions = {}

	if p.kind == "global" then
		for k in self.globals do
			table.insert(suggestions, {
				kind = "expression",
				text = k,
				display = k,
				metadata = get_metadata_for(self.vm.global_metadata[k])
			})
		end
	elseif p.kind == "name" then
		for k in self.vars do
			table.insert(suggestions, {
				kind = "expression",
				text = `${k}`,
				display = `${k}`,
				metadata = nil
			})
		end
	end

	self.result = {
		replace = span2,
		suggestions = suggestions
	}
end

function create_visitor.visit_block(p, p2)
	if span_cursor(p, p2.span) ~= "within" then
		return
	end

	for _, v3 in p2.body do
		if v3.kind == "assign" then
			p.vars[v3.identifier.text] = evaluate_expression(v3.value) or newproxy()
		end
	end
end

function create_visitor.visit_expr_lambda(p, p2)
	if not (span_cursor(p, p2.span) == "within" and (p2.body.block and p2.body.block.value) and p2.body.arguments) then
		return
	end

	if span_cursor(p, p2.body.block.value.span) ~= "within" then
		return
	end

	for _, v3 in p2.body.arguments.value do
		local value = v3.value

		if value then
			p.vars[value.text] = true
		end
	end
end

local function get_focused_argument(p, p2)
	local v3 = 1

	for k, argument in p2.arguments do
		if span_cursor(p, argument.span) == "within" then
			return k
		end

		if span_cursor(p, argument.span) == "after" then
			v3 = k + 1
		end
	end

	return v3
end

local function from_fields_matching_literal(p, p2)
	if p.fields == nil then
		return nil
	end

	for k in p.fields do
		if k.value == p2 then
			return k
		end
	end

	return nil
end

local function from_description_match_literal(p, p2)
	if p.fields_metadata == nil then
		return nil
	end

	for k in p.fields_metadata do
		if k.value == p2 then
			return k
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function get_type_name(value)
	if not value then
		return "unknown"
	end

	if value.kind == "literal" then
		return (`{value.value}`)
	end

	if value.kind == "strange" then
		return value.type
	end

	return value.kind
end

local match_eval_value

match_eval_value = function(value, data, flag: boolean?)
	if data.kind == "literal" then
		if value == data.value then
			return data
		end

		return nil
	elseif data.kind == "command" or data.kind == "function" then
		if typeof(value) == "function" then
			return data
		end

		return nil
	elseif data.kind == "strange" then
		local exact_match

		if flag then
			exact_match = data.exact_match or data.match
		else
			exact_match = data.match
		end

		if not exact_match then
			return data
		end

		if typeof(exact_match) == "table" then
			if match_eval_value(value, exact_match, flag) then
				return data
			end

			return nil
		elseif exact_match(value) then
			return data
		else
			return nil
		end
	elseif data.kind == "intersection" then
		for _, field in data.fields do
			if not match_eval_value(value, field, flag) then
				return nil
			end
		end

		return data
	elseif data.kind == "union" then
		local data2 = {}

		for _, field in data.fields do
			if match_eval_value(value, field, flag) then
				table.insert(data2, data)
			end
		end

		if #data2 > 0 then
			return {
				kind = "union",
				fields = data2
			}
		end

		return nil
	else
		if data.kind ~= "table" then
			return data
		end

		local v3 = {}

		if data.fields then
			for k, field in data.fields do
				local success, result = pcall(rawget, value, k.value)

				if not (success and match_eval_value(result, field, flag)) then
					return nil
				end

				if k.value then
					v3[k.value] = value
				end
			end
		end

		if typeof(value) ~= "table" or not (data.indexer or data.value) then
			return data
		end

		for k, item in pairs(value) do
			if v3[k] then
				continue
			end

			if data.indexer and not match_eval_value(k, data.indexer, flag) or data.value and not match_eval_value(
				item,
				data.value,
				flag
			) then
				return nil
			end
		end

		return data
	end
end

local match

match = function(p, data, data2, flag: boolean?)
	if not data then
		return nil
	end

	if data.kind == "var" then
		local result = nil

		if data.root.kind == "global" then
			result = p.globals[data.root.token.text]
		elseif data.root.kind == "name" and data.root.name then
			result = p.vars[data.root.name.text]
		elseif data.root.kind == "paren" and data.root.node.value then
			result = evaluate_expression(data.root.node.value)
		end

		if not result then
			return nil
		end

		for _, suffix in data.suffixes do
			if suffix.kind == "expression_index" then
				local v3 = evaluate_expression(suffix.node.value)
				local success
				success, result = pcall(rawget, result, v3)

				if not success then
					return nil
				end
			elseif suffix.kind == "name_index" and suffix.name then
				local text = suffix.name.text
				local success
				success, result = pcall(rawget, result, text)

				if not success then
					return nil
				end
			end
		end

		return (match_eval_value(result, data2, flag))
	elseif data2.kind == "command" then
		if data.kind == "command" then
			return data2
		end

		return nil
	elseif data2.kind == "function" then
		if data.kind == "lambda" then
			return data2
		end

		return nil
	elseif data2.kind == "intersection" then
		for _, field in data2.fields do
			if not match(p, data, field, flag) then
				return nil
			end
		end

		return data2
	elseif data2.kind == "union" then
		local fields = {}

		for _, field in data2.fields do
			if match(p, data, field, flag) then
				table.insert(fields, field)
			end
		end

		if #fields > 0 then
			return {
				kind = "union",
				fields = fields
			}
		end

		return nil
	elseif data2.kind == "strange" and typeof(data2.match) == "table" then
		if match(p, data, data2.match, flag) then
			return data2
		end

		return nil
	elseif data2.kind == "strange" or data2.kind == "literal" or data2.kind == "table" then
		return (match_eval_value(evaluate_expression(data), data2, flag))
	else
		return nil
	end
end

local fill_suggestions

fill_suggestions = function(data, data2, data3)
	assert(data.result, "result does not exist")

	if data3.kind == "literal" then
		table.insert(data.result.suggestions, {
			kind = "expression",
			metadata = nil,
			text = tostring(data3.value),
			display = tostring(data3.value)
		})
	elseif data3.kind == "strange" then
		if typeof(data3.suggestions) == "function" then
			local v3

			if data2 and data2.kind == "string" then
				v3 = get_value(data2.token)
			elseif data2 then
				v3 = string.sub(data.input, data2.span.x + 1, data2.span.y + 1)
			end

			local suggestions = data3.suggestions(v3 or "")
			table.move(suggestions, 1, #suggestions, #data.result.suggestions + 1, data.result.suggestions)
		elseif typeof(data3.suggestions) == "table" then
			fill_suggestions(data, data2, data3.suggestions)
		end
	elseif data3.kind == "table" then
		if not (data2 and data2.kind == "table") then
			return
		end

		local value = data2.values.value
		local count = 0
		local v3 = 1

		for k, v5 in value do
			if v5.value.kind == "nokey" then
				count += 1
			end

			if span_cursor(data, v5.span) == "before" then
				v3 = k + 1
			elseif span_cursor(data, v5.span) == "within" then
				v3 = k
				break
			elseif span_cursor(data, v5.span) == "after" then
				v3 = k
			end
		end

		local v5 = value[v3]

		if v5 then
			local value2 = v5.value
			local text = nil
			local v6 = false
			local equals = false
			local value3 = nil

			if value2.kind == "name_key" then
				text = value2.name.text
				v6 = span_cursor(data, value2.name.span) == "within"

				if span_cursor(data, value2.equals.span) == "within" then
					equals = true
				else
					equals = span_cursor(data, value2.equals.span) == "after"
				end

				data.result.replace = value2.value and value2.value.span or vector.create(data.cursor, data.cursor)
			elseif value2.kind == "expression_key" and value2.key then
				text = evaluate_expression(value2.key.value)
				v6 = span_cursor(
					data,
					vector.create(
						value2.key.left.span.x,
						value2.key.right and value2.key.right.span.y or value2.key.value and value2.key.value.span.y or value2.key.left.span.x,
						0
					)
				) == "within"
				equals = value2.equals

				if equals then
					equals = span_cursor(data, value2.equals.span) == "after"
				end

				if value2.key.value and value2.key.value.kind ~= "error" then
					value3 = value2.key.value
				end
			elseif value2.kind == "nokey" then
				data.result.replace = value2.span
				v6 = true

				if data3.indexer then
					equals = match_eval_value(count, data3.indexer)
					text = count
				else
					text = count
					equals = false
				end
			end

			if v6 then
				local result = data.result
				local span

				if value2.kind == "expression_key" and value2.key then
					span = value2.key and value2.key.value and value2.key.value.span or vector.create(
						value2.key.left.span.x,
						value2.key.left.span.x
					)
				elseif value2.kind == "name_key" then
					span = value2.name.span
				elseif value2.kind == "nokey" then
					span = value2.span
				else
					span = data.result.replace
				end

				result.replace = span

				if data3.fields then
					for k in data3.fields do
						table.insert(data.result.suggestions, {
							kind = "assign",
							metadata = nil,
							text = k.value,
							display = k.value
						})
					end
				end

				if data3.indexer then
					fill_suggestions(data, value3, data3.indexer)
				end
			end

			local v7

			if data3.fields ~= nil then
				for k in data3.fields do
					if k.value ~= text then
						continue
					end

					v7 = k
					break
				end
			end

			local v8

			if data3.fields_metadata ~= nil then
				for k in data3.fields_metadata do
					if k.value ~= text then
						continue
					end

					v8 = k
					break
				end
			end

			local value4 = v7 and data3.fields and data3.fields[v7]
			local v9 = v8 and data3.fields_metadata and data3.fields_metadata[v8]

			if v9 then
				local result = data.result
				local additional_info = {
					name = `{text}`,
					description = v9.description,
					type = 0
				}
				local v11 = get_type_name(value4) -- equivalent call inferred; original call site unknown
				additional_info.type = v11
				result.additional_info = additional_info
			end

			if not value4 and data3.indexer and data3.value and match_eval_value(text, data3.indexer) then
				value4 = data3.value
			end

			if equals and value4 then
				local result = data.result
				local span

				if value2.kind == "expression_key" and value2.value then
					span = value2.value.span
				elseif value2.kind == "name_key" and value2.value then
					span = value2.value.span
				elseif value2.kind == "nokey" then
					span = value2.span
				else
					span = data.result.replace
				end

				result.replace = span
				fill_suggestions(data, value2.value, value4)
			end
		else
			local v6 = count + 1
			local v7

			if data3.fields ~= nil then
				for k in data3.fields do
					if k.value ~= v6 then
						continue
					end

					v7 = k
					break
				end
			end

			if v7 == nil or data3.fields == nil then
				return
			end

			fill_suggestions(data, v5, data3.fields[v7])
		end
	elseif data3.kind == "union" then
		local v3 = match(data, data2, data3)

		if v3 == nil then
			v3 = data3
		end

		assert(v3 and v3.kind == "union", "bad value?")

		for _, field in v3.fields do
			assert(field ~= data3)
			fill_suggestions(data, data2, field)
		end
	elseif data3.kind == "intersection" then
		for _, field in data3.fields do
			fill_suggestions(data, data2, field)
		end
	end
end

local function complete_function(data, p, p2)
	local v3 = get_focused_argument(data, p)
	local argument = p.arguments[v3]
	local argument_name = p2.argument_names[v3]

	if not argument_name then
		return
	end

	data.result = {
		replace = argument.span,
		suggestions = {},
		additional_info = {
			name = argument_name,
			type = "unknown"
		}
	}
end

local function complete_command(state, p, p2)
	local v3 = get_focused_argument(state, p)
	local argument = p.arguments[v3]
	local argument2 = p2.arguments[v3]

	if #p2.arguments < v3 and #p2.arguments ~= 0 and p2.arguments[#p2.arguments].varargs then
		argument2 = p2.arguments[#p2.arguments]
	end

	if not argument2 then
		return
	end

	local suggestions = not state.result and {} or state.result.suggestions or {}
	local v5 = {
		replace = argument and argument.span or vector.create(state.cursor, state.cursor, 0),
		suggestions = suggestions,
		additional_info = 0
	}
	local additional_info = {
		name = argument2.name,
		description = argument2.description,
		type = 0
	}
	local type

	if argument2.type then
		local type2 = argument2.type

		if type2 then
			if type2.kind == "literal" then
				type = `{type2.value}`
			elseif type2.kind == "strange" then
				type = type2.type
			else
				type = type2.kind
			end
		else
			type = "unknown"
		end
	else
		type = "unknown"
	end

	additional_info.type = type
	v5.additional_info = additional_info
	state.result = v5

	if argument2.type then
		fill_suggestions(state, argument, argument2.type)
	end
end

local normalize_intersections

normalize_intersections = function(fields, p)
	for _, field in p.fields do
		if field.kind == "intersection" then
			normalize_intersections(fields, field)
		else
			table.insert(fields, field)
		end
	end

	return fields
end

local function swap_pop(list, p: number)
	list[p] = list[#list]
	list[#list] = nil
end

local function choose_command(data, p, p2)
	local v3 = {}
	local v4 = {}

	for _, v5 in normalize_intersections({}, p2) do
		if v5.kind ~= "command" then
			continue
		end

		table.insert(v3, v5)
		table.insert(v4, v5)
	end

	for i = #v3, 1, -1 do
		local v5 = v3[i]
		local argument = v5.arguments[#v5.arguments]
		local varargs

		if argument then
			varargs = argument.varargs
		else
			varargs = false
		end

		if varargs or not (#v5.arguments < #p.arguments) then
			local flag = false

			for k, argument2 in p.arguments do
				local argument3 = v5.arguments[k]

				if #v5.arguments < k and varargs then
					argument3 = argument
				end

				if not (not argument3 or argument3.type and not match(data, argument2, argument3.type, true)) then
					continue
				end

				flag = true
				break
			end

			if flag then
				v3[i] = v3[#v3]
				v3[#v3] = nil
			end
		else
			v3[i] = v3[#v3]
			v3[#v3] = nil
		end
	end

	if #v3 == 0 then
		table.insert(data.issues, {
			why = "no command matches the given type",
			span = p.span
		})
		v3 = v4
	end

	for _, v5 in v3 do
		complete_command(data, p, v5)
	end
end

function create_visitor.visit_command(data, p)
	if not (span_cursor(data, p.span) == "within" and span_cursor(data, p.var.span) == "after") then
		return
	end

	local root = p.var.root

	if #p.var.suffixes > 0 then
		return
	end

	local v3

	if root.kind == "global" then
		local text = root.token.text
		v3 = data.vm.global_metadata[text]
	end

	if v3 == nil then
		return
	end

	if v3.kind == "function" then
		complete_function(data, p, v3)
	elseif v3.kind == "command" then
		complete_command(data, p, v3)
	elseif v3.kind == "intersection" then
		choose_command(data, p, v3)
	else
		table.insert(data.issues, {
			why = `(this is a implementation issue) expected command type, got {v3.kind}`,
			span = p.span
		})
	end
end

function create_visitor.visit_stat_command_end(p, p2)
	if not (p.result and span_cursor(p, p2.var.root.span) == "within") then
		return
	end

	table.insert(p.result.suggestions, {
		kind = nil,
		metadata = nil,
		text = "for",
		display = "for"
	})
	table.insert(p.result.suggestions, {
		kind = nil,
		metadata = nil,
		text = "while",
		display = "while"
	})
end

return {
	analyze = function(vm, str: string, cursor: number)
		local _, result = pcall(module.parse, (buffer.fromstring(str)))

		if not result.result then
			return {
				suggestions = {},
				replace = createVector(0, 0, 0),
				issues = result.issues
			}
		end

		local v3 = {
			vars = table.clone(vm.state.scope.vars),
			globals = table.clone(vm.state.globals),
			cursor = cursor,
			input = str,
			vm = vm,
			issues = result.issues
		}
		module.visit.visit_ast(create_visitor, v3, result.result)

		if v3.result and v3.result.suggestions then
			local suggestionsByDisplay = {}
			local suggestions = {}

			for _, suggestion in v3.result.suggestions do
				suggestion.text = wrap_if_necessary(suggestion)
				suggestionsByDisplay[suggestion.display] = suggestion
			end

			for _, v5 in suggestionsByDisplay do
				table.insert(suggestions, v5)
			end

			v3.result.suggestions = suggestions
		end

		return {
			replace = not v3.result and createVector(0, 0, 0) or v3.result.replace or createVector(0, 0, 0),
			suggestions = not v3.result and {} or v3.result.suggestions or {},
			additional_info = v3.result and v3.result.additional_info,
			issues = v3.issues
		}
	end,
	matches_type = match_eval_value
}