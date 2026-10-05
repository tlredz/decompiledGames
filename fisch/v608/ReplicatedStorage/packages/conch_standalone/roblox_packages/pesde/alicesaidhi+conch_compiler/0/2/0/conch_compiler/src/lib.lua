require("../roblox_packages/types")

-- equivalent calls inferred from this helper; original call sites unknown
local function DEFINE_LOCAL(p, text: string)
	table.insert(p.locals, text)
end

local compile

compile = function(block, up)
	local instructions = up.instructions
	local to = #instructions + 1
	local to2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function INSERT(p2)
		instructions[to] = p2
		to += 1
	end

	local function GET_VALUE(name: string)
		local index = table.find(up.locals, name)

		if index then
			instructions[to] = {
				kind = "push_local",
				index = index
			}
		else
			instructions[to] = {
				kind = "push_global",
				name = name
			}
		end

		to += 1
	end

	local function SET_VALUE(name: string)
		local index = table.find(up.locals, name)

		if index then
			instructions[to] = {
				kind = "set_local",
				index = index
			}
		else
			instructions[to] = {
				kind = "set_global",
				name = name
			}
		end

		to += 1
	end

	local compile_table
	local compile_command
	local compile_lambda
	local compile_var
	local compile_block
	local compile_vector
	local compile_expression

	compile_expression = function(data)
		if data.kind == "boolean" then
			INSERT({
				kind = "push_boolean",
				b = data.token.kind == "true"
			}) -- equivalent call inferred; original call site unknown
		elseif data.kind == "number" then
			INSERT({
				kind = "push_number",
				n = assert((tonumber(data.token.text)))
			}) -- equivalent call inferred; original call site unknown
		elseif data.kind == "evaluate" then
			if data.body.kind == "command" then
				compile_command(data.body, 1)
			else
				compile_expression(data.body)
			end
		elseif data.kind == "lambda" then
			compile_lambda(data.body)
		elseif data.kind == "nil" then
			instructions[to] = {
				kind = "push_nil"
			}
			to += 1
		elseif data.kind == "string" then
			INSERT({
				kind = "push_string",
				s = string.sub(data.token.text, 2, -2)
			}) -- equivalent call inferred; original call site unknown
		elseif data.kind == "table" then
			compile_table(data.table)
		elseif data.kind == "var" then
			compile_var(data.var)
		elseif data.kind == "vector" then
			compile_vector(data)
		end
	end

	compile_vector = function(data)
		local content = data.contents[1]
		local content2 = data.contents[2]
		local content3 = data.contents[3]

		if content then
			compile_expression(content)
		else
			instructions[to] = {
				kind = "push_number",
				n = 0
			}
			to += 1
		end

		if content2 then
			compile_expression(content2)
		else
			instructions[to] = {
				kind = "push_number",
				n = 0
			}
			to += 1
		end

		if content3 then
			compile_expression(content3)
		else
			instructions[to] = {
				kind = "push_number",
				n = 0
			}
			to += 1
		end

		instructions[to] = {
			kind = "push_vector"
		}
		to += 1
	end

	compile_table = function(table2)
		instructions[to] = {
			kind = "push_table",
			alloc = 1
		}
		to += 1
		local v3 = 1

		for _, field in table2.fields do
			if field.kind == "exprkey" then
				compile_expression(field.key)
				compile_expression(field.value)
				instructions[to] = {
					kind = "set_table"
				}
				to += 1
			elseif field.kind == "namekey" then
				INSERT({
					kind = "push_string",
					s = field.name.text
				}) -- equivalent call inferred; original call site unknown
				compile_expression(field.value)
				instructions[to] = {
					kind = "set_table"
				}
				to += 1
			elseif field.kind == "nokey" then
				instructions[to] = {
					kind = "push_number",
					n = v3
				}
				to += 1
				compile_expression(field.value)
				instructions[to] = {
					kind = "set_table"
				}
				to += 1
				v3 += 1
			end
		end
	end

	compile_command = function(p2, value: number?)
		compile_var(p2.prefix)

		for _, argument in p2.arguments do
			compile_expression(argument)
		end

		INSERT({
			kind = "call",
			arguments = #p2.arguments,
			results = value or 1e999
		}) -- equivalent call inferred; original call site unknown
	end

	compile_lambda = function(body)
		local v3 = {
			locals = {},
			upvalues = {},
			instructions = {},
			up = up
		}

		for k, argument in body.arguments do
			DEFINE_LOCAL(v3, argument.text) -- equivalent call inferred; original call site unknown
			table.insert(v3.instructions, {
				kind = "set_local",
				index = k
			})
		end

		compile(body.block, v3)
		INSERT({
			kind = "push_function",
			body = v3.instructions,
			arguments = #body.arguments
		}) -- equivalent call inferred; original call site unknown
	end

	compile_var = function(p2)
		local prefix = p2.prefix

		if prefix.kind == "global" then
			INSERT({
				kind = "push_cmd",
				name = prefix.token.text
			}) -- equivalent call inferred; original call site unknown
		elseif prefix.kind == "name" then
			GET_VALUE(prefix.name.text)
		elseif prefix.kind == "paren" then
			if prefix.expr.kind == "command" then
				compile_command(prefix.expr)
			else
				compile_expression(prefix.expr)
			end
		end

		for _, suffix in p2.suffixes do
			if suffix.kind == "exprindex" then
				if suffix.expr.kind == "command" then
					compile_command(suffix.expr, 1)
				else
					compile_expression(suffix.expr)
				end

				instructions[to] = {
					kind = "index"
				}
				to += 1
			elseif suffix.kind == "nameindex" then
				INSERT({
					kind = "push_string",
					s = suffix.name.text
				}) -- equivalent call inferred; original call site unknown
				instructions[to] = {
					kind = "index"
				}
				to += 1
			end
		end
	end

	local function compile_assignment(p2)
		local text = p2.left.text
		local right = p2.right

		if right.kind == "command" then
			compile_command(right)
		else
			compile_expression(right)
		end

		instructions[to] = {
			kind = "set_global",
			name = text
		}
		to += 1
	end

	local function compile_last(last_statement)
		if last_statement.kind == "return" then
			for _, value in last_statement.values do
				if value.kind == "command" then
					compile_command(value)
				else
					compile_expression(value)
				end
			end

			instructions[to] = {
				kind = "return"
			}
		elseif last_statement.kind == "break" then
			assert(to2, "cannot use continue outside a loop")
			instructions[to] = {
				kind = "goto-pending",
				type = "break"
			}
		else
			if last_statement.kind ~= "continue" then
				error((`unimplemented {last_statement.kind}`))
				return
			end

			assert(to2, "cannot use continue outside a loop")
			instructions[to] = {
				kind = "goto",
				to = to2
			}
		end

		to += 1
	end

	local function compile_if(p2)
		local v3 = to

		for _, v4 in p2.ifs do
			local v5 = to

			if v4.condition.kind == "command" then
				compile_command(v4.condition, 1)
			else
				compile_expression(v4.condition)
			end

			instructions[to] = {
				kind = "goto-pending",
				type = "next-if"
			}
			to += 1
			compile_block(v4.block)
			instructions[to] = {
				kind = "goto-pending",
				type = "if-end"
			}
			to += 1

			for i = to - 1, v5, -1 do
				local instruction = instructions[i]

				if instruction.kind == "goto-pending" and instruction.type == "next-if" then
					instructions[i] = {
						kind = "jump_if",
						to = to
					}
				end
			end
		end

		if p2.fallback then
			compile_block(p2.fallback)
		end

		for i = to - 1, v3, -1 do
			local instruction = instructions[i]

			if instruction.kind == "goto-pending" and instruction.type == "if-end" then
				instructions[i] = {
					kind = "goto",
					to = to
				}
			end
		end
	end

	local function compile_for(p2)
		local v3 = #p2.call.arguments
		local v4 = to2

		if p2.expression.kind == "command" then
			compile_command(p2.expression, 1)
		else
			compile_expression(p2.expression)
		end

		instructions[to] = {
			kind = "turn-into-iterator"
		}
		to += 1
		SET_VALUE("--iterator")
		local to3 = to
		to2 = to3
		GET_VALUE("--iterator")
		INSERT({
			kind = "call",
			arguments = 0,
			results = math.max(1, v3)
		}) -- equivalent call inferred; original call site unknown
		local v7 = {
			kind = "jump_if_not_nil",
			index = 1,
			to = 0
		}
		INSERT(v7) -- equivalent call inferred; original call site unknown
		local v8 = to

		for _, argument in p2.call.arguments do
			SET_VALUE(argument.text)
		end

		instructions[to] = {
			kind = "reset"
		}
		to += 1
		compile_block(p2.call.block)
		instructions[to] = {
			kind = "goto",
			to = to3
		}
		to += 1
		v7.to = to

		for i = to - 1, v8, -1 do
			local instruction = instructions[i]

			if instruction.kind == "goto-pending" and instruction.type == "break" then
				instructions[i] = {
					kind = "goto",
					to = to
				}
			end
		end

		to2 = v4
	end

	local function compile_while(p2)
		local to3 = to
		local v4 = to2
		to2 = to3

		if p2.expression.kind == "command" then
			compile_command(p2.expression, 0)
		else
			compile_expression(p2.expression)
		end

		local v5 = {
			kind = "jump_if",
			index = 1,
			to = 0
		}
		INSERT(v5) -- equivalent call inferred; original call site unknown
		local v6 = to
		compile_block(p2.block)
		instructions[to] = {
			kind = "goto",
			to = to3
		}
		to += 1
		v5.to = to

		for i = to - 1, v6, -1 do
			local instruction = instructions[i]

			if instruction.kind == "goto-pending" and instruction.type == "break" then
				instructions[i] = {
					kind = "goto",
					to = to
				}
			end
		end

		to2 = v4
	end

	compile_block = function(p2)
		for _, v3 in p2.body do
			if v3.kind == "assign" then
				compile_assignment(v3, up)
			elseif v3.kind == "command" then
				compile_command(v3, 0)
			elseif v3.kind == "for" then
				compile_for(v3)
			elseif v3.kind == "if" then
				compile_if(v3)
			elseif v3.kind == "while" then
				compile_while(v3)
			else
				error((`not implemented {v3.kind}`))
			end
		end

		if p2.last_statement then
			compile_last(p2.last_statement)
		end
	end

	compile_block(block)
	return up.instructions
end

return compile