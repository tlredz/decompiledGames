require("./ast")
local module = require("./ast/display")
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})

local function get_stack_trace_info(data)
	local fn_name = data.fn_name
	local v

	if fn_name or not data.fn then
		v = `function {fn_name}`
	else
		local v2, v3, v4 = debug.info(data.fn, "nsl")

		if v2 == "" then
			v = `{v3}:{v4}`
		else
			v = `function {v2}`
		end
	end

	if data.origin == "conch" then
		return (`{data.origin}:{data.line} {v}`)
	end

	if data.fn then
		return (`{data.origin} {v}`)
	end

	return ""
end

-- equivalent calls inferred from this helper; original call sites unknown
local function push_conch_trace(p, fn, fn_name: string?, z: number)
	table.insert(p.trace, {
		fn = fn,
		fn_name = fn_name,
		origin = "conch",
		line = z
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function push_luau_trace(p, fn, fn_name: string?, _: number)
	table.insert(p.trace, {
		fn = fn,
		fn_name = fn_name,
		origin = "luau"
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pop_trace(p)
	table.remove(p.trace)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reset_state(state)
	table.clear(state.trace)

	while not state.scope.root do
		state.scope = state.scope.up
	end
end

local function throw(state, p, p2: string)
	local v = {}

	for i = #state.trace, 1, -1 do
		table.insert(v, (get_stack_trace_info(state.trace[i])))
	end

	reset_state(state) -- equivalent call inferred; original call site unknown
	error(`{p2} at {p.span.x}:{p.span.y}\n{table.concat(v, "\n")}`, 0)
end

local evaluate_expression
local visit_block

local function read_variable(p, p2: string)
	local scope = p.scope

	while scope do
		local var = scope.vars[p2]

		if var then
			return scope, var
		else
			scope = scope.up
		end
	end

	return nil, nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function write_variable(p, text: string, p2)
	local scope = p.scope

	while true do
		if not scope then
			scope = nil
			break
		end

		if scope.vars[text] then
			break
		else
			scope = scope.up
		end
	end

	(scope or p.scope).vars[text] = p2
end

local function index(p, p2, p3, p4)
	local success, result = pcall(function()
		return p3[p4]
	end)

	if not success then
		throw(p, p2, `could not index {typeof(p3)} with {p4}`)
	end

	return result
end

local function call(p, p2, fn, ...)
	if object2[fn] then
		local v = object2[fn]

		if v == true then
			v = nil
		end

		push_conch_trace(p, fn, v, p2.span.z) -- equivalent call inferred; original call site unknown
		local v2 = table.pack(fn(...))
		pop_trace(p) -- equivalent call inferred; original call site unknown
		return v2
	else
		local success, result = pcall(function(...)
			return table.pack(fn(...))
		end, ...)
		local _ = p2.span.z
		push_luau_trace(p, fn, nil) -- equivalent call inferred; original call site unknown

		if not success then
			throw(p, p2, (`{result}`):gsub("", ""))
		end

		pop_trace(p) -- equivalent call inferred; original call site unknown
		return result
	end
end

local v = {
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

local function get_value(p, p2)
	if p2.kind == "number" then
		local text = tonumber(p2.text)

		if text then
			return text
		end

		return throw(p, p2, `{text} is not a valid number`)
	elseif p2.kind == "string" then
		local v2 = string.sub(p2.text, 2, -2)
		local v3 = string.gsub(v2, "\\([0-9][0-9]?[0-9]?)", function(p3: string)
			local v4 = tonumber(p3)
			assert(v4)
			return (string.char(v4))
		end)

		for k, v4 in v do
			v3 = string.gsub(v3, `\\{k}`, v4)
		end

		return v3
	else
		if p2.kind == "identifier" then
			return p2.text
		end

		if p2.kind == "true" then
			return true
		end

		if p2.kind == "false" then
			return false
		end

		if p2.kind == "nil" then
			return nil
		end

		return throw(p, p2, "could not get value")
	end
end

local function evaluate_var(p, p2)
	local root = p2.root
	local v2 = nil

	if root.kind == "global" then
		v2 = p.globals[root.token.text]
	elseif root.kind == "name" then
		if not root.name then
			return throw(p, p2, "no root name token")
		end

		local text = root.name.text
		local scope = p.scope

		while true do
			if not scope then
				scope = nil
				v2 = nil
				break
			end

			v2 = scope.vars[text]

			if v2 then
				break
			else
				scope = scope.up
			end
		end
	elseif root.kind == "paren" then
		local value = root.node.value

		if not value then
			return throw(p, root, "missing expression")
		end

		v2 = evaluate_expression(p, value)
	end

	for _, suffix in p2.suffixes do
		if suffix.kind == "expression_index" then
			local value = suffix.node.value

			if not value then
				return throw(p, suffix, "missing expression")
			end

			local v3 = evaluate_expression(p, value)
			local v4 = v2
			local success, result = pcall(function()
				return v4[v3]
			end)

			if not success then
				throw(p, p2, `could not index {typeof(v2)} with {v3}`)
			end

			v2 = result
		elseif suffix.kind == "name_index" then
			if not suffix.name then
				return throw(p, suffix, "missing expression")
			end

			local v3 = get_value(p, suffix.name)
			local v4 = v2
			local success, result = pcall(function()
				return v4[v3]
			end)

			if not success then
				throw(p, p2, `could not index {typeof(v2)} with {v3}`)
			end

			v2 = result
		end
	end

	return v2
end

local function evaluate_command(p, p2)
	local v2 = {}

	for k, argument in p2.arguments do
		table.move({ evaluate_expression(p, argument) }, 1, 8000, k, v2)
	end

	local v3 = evaluate_var(p, p2.var)

	if v3 ~= nil then
		return call(p, p2, v3, unpack(v2))
	end

	return throw(p, p2, `attempt to invoke a non-existent command: {module.display_var(p2.var)}`)
end

local function evaluate_table(p, data)
	local result = {}
	local v2 = 1

	for _, v3 in data.values.value do
		local value = v3.value

		if value.kind == "expression_key" then
			if not (value.key and value.key.value) then
				return throw(p, v3, "no key")
			end

			if not value.value then
				return throw(p, v3, "no value")
			end

			result[evaluate_expression(p, value.key.value)] = evaluate_expression(p, value.value)
		elseif value.kind == "name_key" then
			if not value.value then
				return throw(p, v3, "no value")
			end

			result[value.name.text] = evaluate_expression(p, value.value)
		elseif value.kind == "nokey" then
			if not value.value then
				return throw(p, v3, "no value")
			end

			result[v2] = evaluate_expression(p, value.value)
			v2 += 1
		end
	end

	return result
end

local function wrap_op(p, data, p2: string, p3, p4, fn, _: string?)
	local success, result = pcall(fn, p3, p4)

	if success then
		return result
	end

	return throw(p, data, `attempt to {p2} on {typeof(p3)} and {typeof(p4)}`)
end

local function evaluate_binary(p, data)
	if not data.left then
		return throw(p, data, "missing lhs expression")
	end

	if not data.right then
		return throw(p, data, "missing rhs expression")
	end

	local v2 = evaluate_expression(p, data.left)
	local v3 = evaluate_expression(p, data.right)
	local kind = data.operator.kind

	if kind == "!=" then
		return wrap_op(p, data, "compare !=", v2, v3, function(p2, p3)
			return p2 ~= p3
		end)
	elseif kind == "%" then
		return wrap_op(p, data, "get modulo of", v2, v3, function(p2, p3)
			return p2 % p3
		end)
	elseif kind == "*" then
		return wrap_op(p, data, "multiply", v2, v3, function(p2, p3)
			return p2 * p3
		end)
	elseif kind == "+" then
		return wrap_op(p, data, "add", v2, v3, function(p2, p3)
			return p2 + p3
		end)
	elseif kind == "-" then
		return wrap_op(p, data, "subtract", v2, v3, function(p2, p3)
			return p2 - p3
		end)
	elseif kind == ".." then
		return wrap_op(p, data, "concatenate", v2, v3, function(p2, p3)
			return p2 .. p3
		end)
	elseif kind == "/" then
		return wrap_op(p, data, "divide", v2, v3, function(p2, p3)
			return p2 / p3
		end)
	elseif kind == "//" then
		return wrap_op(p, data, "idivide", v2, v3, function(p2, p3)
			return p2 // p3
		end)
	elseif kind == "<" then
		return wrap_op(p, data, "compare <", v2, v3, function(p2, p3)
			return p2 < p3
		end)
	elseif kind == "<=" then
		return wrap_op(p, data, "compare <=", v2, v3, function(p2, p3)
			return p2 <= p3
		end)
	elseif kind == "==" then
		return wrap_op(p, data, "compare ==", v2, v3, function(p2, p3)
			return p2 == p3
		end)
	elseif kind == ">" then
		return wrap_op(p, data, "compare >", v2, v3, function(p2, p3)
			return p3 < p2
		end)
	elseif kind == ">=" then
		return wrap_op(p, data, "compare >=", v2, v3, function(p2, p3)
			return p3 <= p2
		end)
	elseif kind == "^" then
		return wrap_op(p, data, "power", v2, v3, function(p2, p3)
			return p2 ^ p3
		end)
	elseif kind == "and" then
		return v2 and v3
	elseif kind == "or" then
		return v2 or v3
	elseif kind == "~=" then
		return wrap_op(p, data, "compare ~=", v2, v3, function(p2, p3)
			return p2 ~= p3
		end)
	end

	return throw(p, data, `unsupported operator {kind}`)
end

local function evaluate_unary(p, data)
	if not data.value then
		return throw(p, data, "missing expression")
	end

	local v2 = evaluate_expression(p, data.value)

	if data.operator.kind == "!" then
		return not v2
	end

	if data.operator.kind == "-" then
		return -v2
	end

	return throw(p, data, `unsupported operator {data.operator}`)
end

local function evaluate_lambda(p, data)
	local v2 = {
		vars = p.scope.vars,
		root = true,
		up = p.scope.up
	}

	local function conch_guest_fn(...)
		local scope = {
			vars = v2.vars,
			up = v2.up,
			root = true
		}

		for k, v4 in data.body.arguments.value do
			local v5 = select(k, ...)

			if v4.value then
				scope.vars[v4.value.text] = v5
			end
		end

		if not data.body.block then
			return throw(p, data, "no block")
		end

		local v4 = object[coroutine.running()]
		local v5 = {
			trace = not v4 and {} or v4.trace or {},
			scope = scope,
			globals = p.globals,
			return_state = nil
		}
		visit_block(v5, data.body.block.value)

		if not v5.last_statement then
			return
		end

		local node = v5.last_statement.node

		if node.kind == "return" then
			local v6 = {}

			for k, value in node.values do
				local value2 = value.value

				if value2 then
					v6[k] = evaluate_expression(v5, value2)
				end
			end

			return unpack(v6, 1, #node.values)
		elseif v4 then
			v4.last_statement = {
				scope = scope,
				node = node
			}
		end
	end

	object2[conch_guest_fn] = true
	return conch_guest_fn
end

evaluate_expression = function(p, data)
	if data.kind == "binary" then
		return evaluate_binary(p, data)
	end

	if data.kind == "boolean" then
		return get_value(p, data.token)
	end

	if data.kind == "command" then
		if not data.command then
			return throw(p, data, "missing command")
		end

		local v2 = evaluate_command(p, data.command)
		return unpack(v2, 1, v2.n)
	elseif data.kind == "evaluate" then
		if data.command.value then
			return evaluate_expression(p, data.command.value)
		end

		return throw(p, data, "no expression within evaluate")
	else
		if data.kind == "lambda" then
			return (evaluate_lambda(p, data))
		end

		if data.kind == "nil" then
			return nil
		end

		if not (data.kind ~= "number" and data.kind ~= "string") then
			return get_value(p, data.token)
		end

		if data.kind == "table" then
			return evaluate_table(p, data)
		end

		if data.kind == "unary" then
			return evaluate_unary(p, data)
		end

		if data.kind == "var" then
			return evaluate_var(p, data)
		end

		if data.kind ~= "vector" then
			return throw(p, data, `could not evaluate {data.kind}`)
		end

		local value = data.contents.value
		local value2 = value[1] and value[1].value
		local value3 = value[2] and value[2].value
		local value4 = value[3] and value[3].value
		return (vector.create(
			not value2 and 0 or evaluate_expression(p, value2),
			not value3 and 0 or evaluate_expression(p, value3),
			not value4 and 0 or evaluate_expression(p, value4)
		))
	end
end

local function visit_stat_command(p, p2)
	return evaluate_command(p, p2)
end

local function visit_stat_for(state, data)
	local value = data.expression and data.expression.value
	local body = data.body

	if not value then
		return throw(state, data, "missing expression")
	end

	local v2 = evaluate_expression(state, value)

	if not body then
		return throw(state, data, "missing body")
	end

	local fn = evaluate_expression(state, body)
	push_conch_trace(state, fn, nil, data.span.z) -- equivalent call inferred; original call site unknown

	for k, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28 in v2 do
		call(
			state,
			data,
			fn,
			k,
			v4,
			v5,
			v6,
			v7,
			v8,
			v9,
			v10,
			v11,
			v12,
			v13,
			v14,
			v15,
			v16,
			v17,
			v18,
			v19,
			v20,
			v21,
			v22,
			v23,
			v24,
			v25,
			v26,
			v27,
			v28
		)
		local last_statement = state.last_statement

		if last_statement and last_statement.node.kind == "break" then
			state.last_statement = nil
			break
		end

		if last_statement and last_statement.node.kind == "continue" then
			state.last_statement = nil
		elseif last_statement and last_statement.node.kind == "return" then
			break
		end
	end

	pop_trace(state) -- equivalent call inferred; original call site unknown
	return nil
end

local function visit_stat_while(state, p)
	local value = p.condition and p.condition.value
	local value2 = p.block and p.block.value

	if not value then
		return throw(state, p, "missing condition")
	end

	if not value2 then
		return throw(state, p, "missing body")
	end

	while evaluate_expression(state, value) do
		visit_block(state, value2)
		local last_statement = state.last_statement

		if last_statement and last_statement.node.kind == "break" then
			state.last_statement = nil
			break
		end

		if last_statement and last_statement.node.kind == "continue" then
			state.last_statement = nil
		elseif last_statement and last_statement.node.kind == "return" then
			break
		end
	end

	return nil
end

local function visit_stat_assign(p, p2)
	if not p2.value then
		return throw(p, p2, "missing value")
	end

	write_variable(p, p2.identifier.text, evaluate_expression(p, p2.value)) -- equivalent call inferred; original call site unknown
	return nil
end

local function visit_stat_if(state, data)
	local function evaluate_branch(p)
		local value = p.condition and p.condition.value
		local value2 = p.block and p.block.value

		if not value then
			return throw(state, data, "missing condition")
		end

		if not value2 then
			return throw(state, data, "missing body")
		end

		if not evaluate_expression(state, value) then
			return false
		end

		visit_block(state, value2)
		return true
	end

	if evaluate_branch(data.first_branch) then
		return
	end

	for _, branch in data.branches do
		if evaluate_branch(branch.branch) then
			return
		end
	end

	if data.else_branch then
		if not data.else_branch.block then
			return
		end

		visit_block(state, data.else_branch.block.value)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function visit_lstat(state, last_statement)
	state.last_statement = {
		node = last_statement,
		scope = state.scope
	}
end

visit_block = function(state, value, flag: boolean?)
	if flag ~= true then
		state.scope = {
			up = state.scope,
			root = false,
			vars = {}
		}
	end

	local v2 = nil

	for _, v4 in value.body do
		if v4.kind == "assign" then
			if v4.value then
				write_variable(state, v4.identifier.text, evaluate_expression(state, v4.value)) -- equivalent call inferred; original call site unknown
			else
				throw(state, v4, "missing value")
			end
		elseif v4.kind == "command" then
			v2 = evaluate_command(state, v4)
		elseif v4.kind == "for" then
			visit_stat_for(state, v4)
		elseif v4.kind == "if" then
			visit_stat_if(state, v4)
		elseif v4.kind == "while" then
			visit_stat_while(state, v4)
		end

		if state.last_statement then
			break
		end
	end

	if value.last_statement then
		visit_lstat(state, value.last_statement) -- equivalent call inferred; original call site unknown
	end

	if not state.scope.up then
		return v2
	end

	state.scope = state.scope.up
	return v2
end

local function execute(state, p)
	local success, result = pcall(visit_block, state, p.block, true)

	if success then
		local v2 = {
			ok = true,
			values = result
		}
		local last_statement = state.last_statement
		state.last_statement = nil

		if not (last_statement and last_statement.node.kind == "return") then
			return v2
		end

		v2.values = table.create(#last_statement.node.values, nil)
		assert(v2.values)

		for k, value in last_statement.node.values do
			if not value.value then
				continue
			end

			local success2, result2 = pcall(evaluate_expression, state, value.value)

			if success2 then
				v2.values[k] = result2
			else
				reset_state(state) -- equivalent call inferred; original call site unknown
				return {
					ok = false,
					err = result2:gsub("", "")
				}
			end
		end

		return v2
	else
		reset_state(state) -- equivalent call inferred; original call site unknown
		return {
			ok = false,
			err = result:gsub("", "")
		}
	end
end

local Treewalker = {}

function Treewalker.create_state()
	return {
		trace = {},
		globals = {},
		last_statement = nil,
		scope = {
			vars = {},
			root = true,
			up = nil
		}
	}
end

function Treewalker.execute(p, p2)
	object[coroutine.running()] = p
	local v2 = execute(p, p2)
	object[coroutine.running()] = nil
	return v2
end

return Treewalker