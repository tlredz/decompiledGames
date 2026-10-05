require("./ast")
local visit_command
local visit_expr
local visit_block

local function visit_token(p, p2, p3)
	p.visit_token(p2, p3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function visit_delimited(data, p, callback, data2)
	local left = data2.left
	data.visit_token(p, left)

	if data2.value then
		callback(data, p, data2.value)
	end

	if data2.right then
		local right = data2.right
		data.visit_token(p, right)
	end
end

local function visit_separated(p, p2, callback, items)
	for _, item in items do
		callback(p, p2, item.value)

		if not item.separator then
			continue
		end

		local separator = item.separator
		p.visit_token(p2, separator)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function gen_separated(callback)
	return function(p, p2, p3)
		visit_separated(p, p2, callback, p3)
	end
end

local function visit_argument(p, p2, p3)
	p.visit_fn_argument(p, p2)
	p.visit_token(p2, p3)
end

local function visit_tablefield(data, p, data2)
	data.visit_tablefield(p, data2)

	if data2.kind == "expression_key" then
		data.visit_tablefield_exprkey(p, data2)

		if data2.key then
			visit_delimited(data, p, visit_expr, data2.key) -- equivalent call inferred; original call site unknown
		end

		if data2.equals then
			local equals = data2.equals
			data.visit_token(p, equals)
		end

		if data2.value then
			visit_expr(data, p, data2.value)
		end

		data.visit_tablefield_exprkey_end(p, data2)
	elseif data2.kind == "name_key" then
		data.visit_tablefield_namekey(p, data2)
		local name = data2.name
		data.visit_token(p, name)
		local equals = data2.equals
		data.visit_token(p, equals)

		if data2.value then
			visit_expr(data, p, data2.value)
		end

		data.visit_tablefield_namekey_end(p, data2)
	elseif data2.kind == "nokey" then
		data.visit_tablefield_nokey(p, data2)

		if data2.value then
			visit_expr(data, p, data2.value)
		end

		data.visit_tablefield_nokey_end(p, data2)
	end

	data.visit_tablefield_end(p, data2)
end

local function visit_var(data, p, p2)
	data.visit_var(p, p2)
	data.visit_var_root(p, p2.root)

	if p2.root.kind == "global" then
		data.visit_var_root_global(p, p2.root)
		local token = p2.root.token
		data.visit_token(p, token)
		data.visit_var_root_global_end(p, p2.root)
	elseif p2.root.kind == "name" then
		data.visit_var_root_variable(p, p2.root)
		local var = p2.root.var
		data.visit_token(p, var)

		if p2.root.name then
			local name = p2.root.name
			data.visit_token(p, name)
		end

		data.visit_var_root_variable_end(p, p2.root)
	elseif p2.root.kind == "paren" then
		data.visit_var_root_paren(p, p2.root)
		local var = p2.root.var
		data.visit_token(p, var)
		visit_delimited(data, p, visit_expr, p2.root.node) -- equivalent call inferred; original call site unknown
		data.visit_var_root_paren_end(p, p2.root)
	end

	data.visit_var_root_end(p, p2.root)

	for _, suffix in p2.suffixes do
		data.visit_var_suffix(p, suffix)

		if suffix.kind == "expression_index" then
			data.visit_var_suffix_expression(p, suffix)
			local period = suffix.period
			data.visit_token(p, period)
			visit_delimited(data, p, visit_expr, suffix.node) -- equivalent call inferred; original call site unknown
			data.visit_var_suffix_expression_end(p, suffix)
		elseif suffix.kind == "name_index" then
			data.visit_var_suffix_name(p, suffix)
			local period = suffix.period
			data.visit_token(p, period)

			if suffix.name then
				local name = suffix.name
				data.visit_token(p, name)
			end

			data.visit_var_suffix_name_end(p, suffix)
		end

		data.visit_var_suffix_end(p, suffix)
	end

	data.visit_var_end(p, p2)
end

visit_expr = function(data, p, data2)
	data.visit_expression(p, data2)

	if data2.kind == "binary" then
		data.visit_expr_binary(p, data2)
		visit_expr(data, p, data2.left)
		local operator = data2.operator
		data.visit_token(p, operator)

		if data2.right then
			visit_expr(data, p, data2.right)
		end

		data.visit_expr_binary_end(p, data2)
	elseif data2.kind == "boolean" then
		data.visit_expr_boolean(p, data2)
		local token = data2.token
		data.visit_token(p, token)
		data.visit_expr_boolean_end(p, data2)
	elseif data2.kind == "evaluate" then
		data.visit_expr_evaluate(p, data2)
		visit_delimited(data, p, visit_expr, data2.command) -- equivalent call inferred; original call site unknown
		data.visit_expr_evaluate_end(p, data2)
	elseif data2.kind == "lambda" then
		data.visit_expr_lambda(p, data2)
		local v2 = gen_separated(visit_argument) -- equivalent call inferred; original call site unknown
		visit_delimited(data, p, v2, data2.body.arguments) -- equivalent call inferred; original call site unknown

		if data2.body.block then
			visit_delimited(data, p, visit_block, data2.body.block) -- equivalent call inferred; original call site unknown
		end

		data.visit_expr_lambda_end(p, data2)
	elseif data2.kind == "nil" then
		data.visit_expr_nil(p, data2)
		local token = data2.token
		data.visit_token(p, token)
		data.visit_expr_nil_end(p, data2)
	elseif data2.kind == "number" then
		data.visit_expr_number(p, data2)
		local token = data2.token
		data.visit_token(p, token)
		data.visit_expr_number_end(p, data2)
	elseif data2.kind == "string" then
		data.visit_expr_string(p, data2)
		local token = data2.token
		data.visit_token(p, token)
		data.visit_expr_string_end(p, data2)
	elseif data2.kind == "table" then
		data.visit_table(p, data2)
		local v2 = gen_separated(visit_tablefield) -- equivalent call inferred; original call site unknown
		visit_delimited(data, p, v2, data2.values) -- equivalent call inferred; original call site unknown
		data.visit_table_end(p, data2)
	elseif data2.kind == "unary" then
		data.visit_expr_unary(p, data2)
		local operator = data2.operator
		data.visit_token(p, operator)

		if data2.value then
			visit_expr(data, p, data2.value)
		end

		data.visit_expr_unary_end(p, data2)
	elseif data2.kind == "command" then
		data.visit_token(p, data2.prefix)
		data.visit_expr_command(p, data2)

		if data2.command then
			visit_command(data, p, data2.command)
		end

		data.visit_expr_command_end(p, data2)
	elseif data2.kind == "var" then
		data.visit_expr_var(p, data2)
		visit_var(data, p, data2)
		data.visit_expr_var_end(p, data2)
	elseif data2.kind == "vector" then
		data.visit_expr_vector(p, data2)
		local v2 = gen_separated(visit_expr) -- equivalent call inferred; original call site unknown
		visit_delimited(data, p, v2, data2.contents) -- equivalent call inferred; original call site unknown
		data.visit_expr_vector_end(p, data2)
	end

	data.visit_expression_end(p, data2)
end

visit_command = function(data, p, p2)
	data.visit_command(p, p2)
	visit_var(data, p, p2.var)

	for _, argument in p2.arguments do
		visit_expr(data, p, argument)
	end

	data.visit_command_end(p, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function visit_if_branch(data, p, p2)
	data.visit_if_branch(p, p2)
	data.visit_if_branch_end(p, p2)
end

local function visit_stat(data, p, data2)
	data.visit_statement(p, data2)

	if data2.kind == "assign" then
		data.visit_stat_assign(p, data2)
		data.visit_token(p, data2.identifier)
		data.visit_token(p, data2.equals)

		if data2.value then
			visit_expr(data, p, data2.value)
		end

		data.visit_stat_assign_end(p, data2)
	elseif data2.kind == "command" then
		data.visit_stat_command(p, data2)
		visit_command(data, p, data2)
		data.visit_stat_command_end(p, data2)
	elseif data2.kind == "for" then
		data.visit_stat_for(p, data2)
		data.visit_token(p, data2.token)

		if data2.expression then
			visit_delimited(data, p, visit_expr, data2.expression) -- equivalent call inferred; original call site unknown
		end

		if data2.body then
			visit_expr(data, p, data2.body)
		end

		data.visit_stat_for_end(p, data2)
	elseif data2.kind == "if" then
		data.visit_stat_if(p, data2)
		data.visit_token(p, data2.token)

		if data2.first_branch then
			visit_if_branch(data, p, data2.first_branch) -- equivalent call inferred; original call site unknown
		end

		for _, branch in data2.branches do
			data.visit_elseif_branch(p, branch)
			data.visit_token(p, branch.ifelse)
			visit_if_branch(data, p, branch.branch) -- equivalent call inferred; original call site unknown
			data.visit_elseif_branch_end(p, branch)
		end

		if data2.else_branch then
			data.visit_else_branch(p, data2.else_branch)
			data.visit_token(p, data2.else_branch.token)

			if data2.else_branch.block then
				visit_delimited(data, p, visit_block, data2.else_branch.block) -- equivalent call inferred; original call site unknown
			end

			data.visit_else_branch_end(p, data2.else_branch)
		end

		data.visit_stat_if_end(p, data2)
	elseif data2.kind == "while" then
		data.visit_stat_while(p, data2)
		data.visit_token(p, data2.token)

		if data2.condition then
			visit_delimited(data, p, visit_expr, data2.condition) -- equivalent call inferred; original call site unknown
		end

		if data2.block then
			visit_delimited(data, p, visit_block, data2.block) -- equivalent call inferred; original call site unknown
		end

		data.visit_stat_while_end(p, data2)
	end

	data.visit_statement_end(p, data2)
end

local function visit_last_stat(data, p, last_statement)
	data.visit_last_statement(p, last_statement)

	if last_statement.kind == "break" then
		data.visit_break(p, last_statement)
		local token = last_statement.token
		data.visit_token(p, token)
		data.visit_break_end(p, last_statement)
	elseif last_statement.kind == "continue" then
		data.visit_continue(p, last_statement)
		local token = last_statement.token
		data.visit_token(p, token)
		data.visit_continue_end(p, last_statement)
	elseif last_statement.kind == "return" then
		data.visit_return(p, last_statement)
		local token = last_statement.token
		data.visit_token(p, token)
		visit_separated(data, p, visit_expr, last_statement.values)
		data.visit_return_end(p, last_statement)
	end

	data.visit_last_statement_end(p, last_statement)
end

visit_block = function(p, p2, block)
	p.visit_block(p2, block)

	for _, v in block.body do
		visit_stat(p, p2, v)
	end

	if block.last_statement then
		visit_last_stat(p, p2, block.last_statement)
	end

	p.visit_block_end(p2, block)
end

local Visit = {}
Visit.visit_block = visit_block

function Visit.visit_ast(p, p2, p3)
	visit_block(p, p2, p3.block)
end

function Visit.create_visitor()
	local function fn() end

	return {
		visit_block = fn,
		visit_block_end = fn,
		visit_token = fn,
		visit_fn_argument = fn,
		visit_command = fn,
		visit_command_end = fn,
		visit_statement = fn,
		visit_statement_end = fn,
		visit_stat_for = fn,
		visit_stat_for_end = fn,
		visit_stat_while = fn,
		visit_stat_while_end = fn,
		visit_stat_if = fn,
		visit_stat_if_end = fn,
		visit_stat_assign = fn,
		visit_stat_assign_end = fn,
		visit_stat_command = fn,
		visit_stat_command_end = fn,
		visit_if_branch = fn,
		visit_if_branch_end = fn,
		visit_elseif_branch = fn,
		visit_elseif_branch_end = fn,
		visit_else_branch = fn,
		visit_else_branch_end = fn,
		visit_last_statement = fn,
		visit_last_statement_end = fn,
		visit_return = fn,
		visit_return_end = fn,
		visit_break = fn,
		visit_break_end = fn,
		visit_continue = fn,
		visit_continue_end = fn,
		visit_table = fn,
		visit_table_end = fn,
		visit_tablefield = fn,
		visit_tablefield_end = fn,
		visit_tablefield_nokey = fn,
		visit_tablefield_nokey_end = fn,
		visit_tablefield_namekey = fn,
		visit_tablefield_namekey_end = fn,
		visit_tablefield_exprkey = fn,
		visit_tablefield_exprkey_end = fn,
		visit_var = fn,
		visit_var_end = fn,
		visit_var_suffix = fn,
		visit_var_suffix_end = fn,
		visit_var_suffix_expression = fn,
		visit_var_suffix_expression_end = fn,
		visit_var_suffix_name = fn,
		visit_var_suffix_name_end = fn,
		visit_var_root = fn,
		visit_var_root_end = fn,
		visit_var_root_paren = fn,
		visit_var_root_paren_end = fn,
		visit_var_root_variable = fn,
		visit_var_root_variable_end = fn,
		visit_var_root_global = fn,
		visit_var_root_global_end = fn,
		visit_expression = fn,
		visit_expression_end = fn,
		visit_expr_command = fn,
		visit_expr_command_end = fn,
		visit_expr_evaluate = fn,
		visit_expr_evaluate_end = fn,
		visit_expr_unary = fn,
		visit_expr_unary_end = fn,
		visit_expr_vector = fn,
		visit_expr_vector_end = fn,
		visit_expr_lambda = fn,
		visit_expr_lambda_end = fn,
		visit_expr_string = fn,
		visit_expr_string_end = fn,
		visit_expr_binary = fn,
		visit_expr_binary_end = fn,
		visit_expr_number = fn,
		visit_expr_number_end = fn,
		visit_expr_boolean = fn,
		visit_expr_boolean_end = fn,
		visit_expr_var = fn,
		visit_expr_var_end = fn,
		visit_expr_nil = fn,
		visit_expr_nil_end = fn
	}
end

return Visit