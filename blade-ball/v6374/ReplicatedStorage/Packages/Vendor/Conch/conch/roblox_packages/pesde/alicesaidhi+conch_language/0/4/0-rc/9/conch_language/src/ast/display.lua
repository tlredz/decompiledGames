require("./ast")
local buf = buffer.create(1024)
local total = 0
local v = 0
local total2 = 0

local function write_str(str: string)
	local v2 = buffer.len(buf)

	if v2 <= total + #str then
		local v3 = v2 + v2 / 2

		while v3 <= total + #str do
			v3 += v3 / 2
		end

		local buf2 = buffer.create(v3)
		buffer.copy(buf2, 0, buf, 0, total)
		buf = buf2
	end

	buffer.writestring(buf, total, str, #str)
	total += #str
	total2 += #str
end

local function char(value: string)
	return (string.byte(value))
end

local function write_char(value: number)
	local v2 = buffer.len(buf)

	if v2 <= total + 1 then
		local v3 = v2 + v2 / 2

		while v3 <= total + 1 do
			v3 += v3 / 2
		end

		local buf2 = buffer.create(v3)
		buffer.copy(buf2, 0, buf, 0, total)
		buf = buf2
	end

	buffer.writeu8(buf, total, value)
	total2 += 1
	total += 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function write_line()
	write_char(10)
	write_str(string.rep("\t", v))
end

local function display_token(p)
	write_str(p.text)

	if p.kind == "and" or p.kind == "or" or p.kind == "break" or p.kind == "continue" or p.kind == "else" or p.kind == "elseif" or p.kind == "true" or p.kind == "false" or p.kind == "nil" or p.kind == "if" or p.kind == "while" or p.kind == "else" or p.kind == "for" or p.kind == "return" or p.kind == "break" or p.kind == "number" then
		write_char(32)
	end
end

local display_expression
local display_if_branch
local display_command
local display_block

local function display_delimited(data, callback)
	assert(data)
	assert(data.left)
	assert(data.value)
	assert(data.right)
	v += 1
	display_token(data.left)
	write_line() -- equivalent call inferred; original call site unknown
	callback(data.value)
	v -= 1
	write_line() -- equivalent call inferred; original call site unknown
	display_token(data.right)
end

local function display_separated(items, callback)
	for _, item in items do
		callback(item.value)

		if item.separator then
			display_token(item.separator)
		end

		write_line() -- equivalent call inferred; original call site unknown
	end
end

local function generate_separated(callback)
	return function(p)
		display_separated(p, callback)
	end
end

local function display_function_body(body)
	display_delimited(body.arguments, generate_separated(display_token))
	display_delimited(body.block, display_block)
end

local function display_tablefield(data)
	if data.kind == "expression_key" then
		assert(data.equals)
		assert(data.value)
		display_delimited(data.key, display_expression)
		display_token(data.equals)
		display_expression(data.value)
	elseif data.kind == "name_key" then
		assert(data.value)
		display_token(data.name)
		display_token(data.equals)
		display_expression(data.value)
	elseif data.kind == "nokey" then
		assert(data.value)
		display_expression(data.value)
	end
end

local function display_table(data)
	display_delimited(data.values, generate_separated(display_tablefield))
end

local function display_var_root(root)
	if root.kind == "global" then
		display_token(root.token)
	elseif root.kind == "name" then
		assert(root.name)
		display_token(root.var)
		display_token(root.name)
	elseif root.kind == "paren" then
		display_token(root.var)
		display_delimited(root.node, display_expression)
	end
end

function display_var_suffix(data)
	if data.kind == "expression_index" then
		display_token(data.period)
		display_delimited(data.node, display_expression)
	elseif data.kind == "name_index" then
		assert(data.name)
		display_token(data.period)
		display_token(data.name)
	end
end

local function display_var(p)
	display_var_root(p.root)

	for _, suffix in p.suffixes do
		display_var_suffix(suffix)
	end

	write_char(32)
end

display_expression = function(data)
	if data.kind == "binary" then
		assert(data.right)
		display_expression(data.left)
		display_token(data.operator)
		display_expression(data.right)
	elseif data.kind == "boolean" then
		display_token(data.token)
	elseif data.kind == "command" then
		write_char(38)
		assert(data.command)
		display_command(data.command)
	elseif data.kind == "evaluate" then
		display_delimited(data.command, display_expression)
	elseif data.kind == "lambda" then
		display_function_body(data.body)
	elseif data.kind == "nil" then
		display_token(data.token)
	elseif data.kind == "number" then
		display_token(data.token)
	elseif data.kind == "string" then
		display_token(data.token)
	elseif data.kind == "table" then
		display_table(data)
	elseif data.kind == "unary" then
		assert(data.value)
		display_token(data.operator)
		display_expression(data.value)
	elseif data.kind == "var" then
		display_var(data)
	elseif data.kind == "vector" then
		display_delimited(data.contents, generate_separated(display_expression))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function display_break(p)
	display_token(p.token)
end

local function display_continue(p)
	display_break(p) -- equivalent call inferred; original call site unknown
end

local function display_return(p)
	display_break(p) -- equivalent call inferred; original call site unknown
	display_separated(p.values, display_expression)
end

local function display_last_statement(last_statement)
	write_line() -- equivalent call inferred; original call site unknown

	if last_statement.kind == "break" then
		display_break(last_statement)
	elseif last_statement.kind == "continue" then
		display_continue(last_statement)
	elseif last_statement.kind == "return" then
		display_return(last_statement)
	end
end

local function display_else_branch(else_branch)
	display_break(else_branch) -- equivalent call inferred; original call site unknown
	display_delimited(else_branch.block, display_block)
end

local function display_elseif_branch(branch)
	display_token(branch.ifelse)
	display_if_branch(branch.branch)
end

display_if_branch = function(p)
	display_delimited(p.condition, display_expression)
	display_delimited(p.block, display_block)
end

local function display_while(p)
	display_break(p) -- equivalent call inferred; original call site unknown
	display_delimited(p.condition, display_expression)
	display_delimited(p.block, display_block)
end

local function display_if(data)
	display_break(data) -- equivalent call inferred; original call site unknown
	display_if_branch(data.first_branch)

	if data.branches then
		for _, branch in data.branches do
			display_elseif_branch(branch)
		end
	end

	if data.else_branch then
		display_else_branch(data.else_branch)
	end
end

local function display_for(p)
	assert(p.body)
	display_break(p) -- equivalent call inferred; original call site unknown
	display_delimited(p.expression, display_expression)
	display_expression(p.body)
end

display_command = function(p)
	display_var(p.var)

	for _, argument in p.arguments do
		display_expression(argument)
		write_char(32)
	end
end

local function display_assign(data)
	assert(data.value)
	display_token(data.identifier)
	display_token(data.equals)
	display_expression(data.value)
end

local function display_statement(p)
	if p.kind == "assign" then
		display_assign(p)
	elseif p.kind == "command" then
		display_command(p)
	elseif p.kind == "for" then
		display_for(p)
	elseif p.kind == "if" then
		display_if(p)
	elseif p.kind == "while" then
		display_while(p)
	end
end

display_block = function(p)
	write_line() -- equivalent call inferred; original call site unknown

	for _, v2 in p.body do
		display_statement(v2)
		write_line() -- equivalent call inferred; original call site unknown
	end

	if not p.last_statement then
		return
	end

	display_last_statement(p.last_statement)
end

local function wrap(callback)
	return function(...)
		total = 0
		v = 0
		callback(...)
		return buffer.readstring(buf, 0, total - 1)
	end
end

local v2 = display_assign
local Display = {
	display_assign = function(...)
		total = 0
		v = 0
		v2(...)
		return buffer.readstring(buf, 0, total - 1)
	end,
	display_block = 0,
	display_break = 0,
	display_command = 0,
	display_continue = 0,
	display_delimited = 0,
	display_else_branch = 0,
	display_elseif_branch = 0,
	display_expression = 0,
	display_for = 0,
	display_function_body = 0,
	display_if = 0,
	display_if_branch = 0,
	display_last_statement = 0,
	display_return = 0,
	display_separated = 0,
	display_statement = 0,
	display_table = 0,
	display_tablefield = 0,
	display_token = 0,
	display_var = 0,
	display_var_root = 0,
	display_var_suffix = 0,
	display_while = 0
}
local v3 = display_block

function Display.display_block(...)
	total = 0
	v = 0
	v3(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v4 = display_break

function Display.display_break(...)
	total = 0
	v = 0
	v4(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v5 = display_command

function Display.display_command(...)
	total = 0
	v = 0
	v5(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v6 = display_continue

function Display.display_continue(...)
	total = 0
	v = 0
	v6(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v7 = display_delimited

function Display.display_delimited(...)
	total = 0
	v = 0
	v7(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v8 = display_else_branch

function Display.display_else_branch(...)
	total = 0
	v = 0
	v8(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v9 = display_elseif_branch

function Display.display_elseif_branch(...)
	total = 0
	v = 0
	v9(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v10 = display_expression

function Display.display_expression(...)
	total = 0
	v = 0
	v10(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v11 = display_for

function Display.display_for(...)
	total = 0
	v = 0
	v11(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v12 = display_function_body

function Display.display_function_body(...)
	total = 0
	v = 0
	v12(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v13 = display_if

function Display.display_if(...)
	total = 0
	v = 0
	v13(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v14 = display_if_branch

function Display.display_if_branch(...)
	total = 0
	v = 0
	v14(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v15 = display_last_statement

function Display.display_last_statement(...)
	total = 0
	v = 0
	v15(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v16 = display_return

function Display.display_return(...)
	total = 0
	v = 0
	v16(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v17 = display_separated

function Display.display_separated(...)
	total = 0
	v = 0
	v17(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v18 = display_statement

function Display.display_statement(...)
	total = 0
	v = 0
	v18(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v19 = display_table

function Display.display_table(...)
	total = 0
	v = 0
	v19(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v20 = display_tablefield

function Display.display_tablefield(...)
	total = 0
	v = 0
	v20(...)
	return buffer.readstring(buf, 0, total - 1)
end

function Display.display_token(...)
	total = 0
	v = 0
	display_token(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v21 = display_var

function Display.display_var(...)
	total = 0
	v = 0
	v21(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v22 = display_var_root

function Display.display_var_root(...)
	total = 0
	v = 0
	v22(...)
	return buffer.readstring(buf, 0, total - 1)
end

local display_var_suffix2 = display_var_suffix

function Display.display_var_suffix(...)
	total = 0
	v = 0
	display_var_suffix2(...)
	return buffer.readstring(buf, 0, total - 1)
end

local v23 = display_while

function Display.display_while(...)
	total = 0
	v = 0
	v23(...)
	return buffer.readstring(buf, 0, total - 1)
end

return Display