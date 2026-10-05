local module = require("./optional_ast")
require("../roblox_packages/types")
return {
	generate_analysis_info = function(data)
		local logs = {}
		local where = data.where

		-- equivalent calls inferred from this helper; original call sites unknown
		local function LOG(kind, text: string)
			table.insert(logs, {
				kind = kind,
				text = text
			})
		end

		local function get_span(data2)
			local x

			if data2.left then
				x = data2.left.span.x
			elseif data2.value then
				x = data2.value.span.x
			else
				x = data2.right.span.x
			end

			local y

			if data2.right then
				y = data2.right.span.y
			elseif data2.value then
				y = data2.value.span.y
			else
				y = data2.left.span.y
			end

			return (vector.create(x, y, 0))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function get_text_token(token)
			local v2 = where - token.span.x
			return (string.sub(token.text, 1, v2))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function position_relative(span: Vector3)
			if where >= span.x and where <= span.y then
				return "within"
			end

			if where < span.x then
				return "before"
			end

			return "after"
		end

		local v2 = module(data.code)

		local function no_suggestions(text: string)
			local v3 = {
				at = where,
				text = text,
				logs = logs,
				suggestions = {},
				ast = 0
			}
			local ast = v2

			if ast then
				if v2.status == "finished" then
					ast = v2.value
				else
					ast = false
				end
			end

			v3.ast = ast
			return v3
		end

		if v2.status == "error" then
			LOG("error", v2.why) -- equivalent call inferred; original call site unknown
			return (no_suggestions(""))
		end

		local value = v2.value
		local process_block
		local process_expression
		local process_expression_or_command

		local function process_command(p, flag: boolean?)
			local v3 = position_relative(p.prefix.span) -- equivalent call inferred; original call site unknown

			if v3 == "within" then
				return process_variable(p.prefix, flag)
			end

			if v3 ~= "after" then
				return (no_suggestions(""))
			end

			local prefix = p.prefix.prefix
			local v4 = nil

			if prefix.kind == "global" then
				for _, command in data.commands do
					if command.name ~= prefix.token.text then
						continue
					end

					v4 = command
					break
				end
			end

			if not v4 then
				return (no_suggestions(""))
			end

			local vector2 = vector.create(p.prefix.span.y + 1, p.prefix.span.y + 1)
			local v5 = no_suggestions("")
			local v6 = 1

			for _, argument in p.arguments do
				local v8 = position_relative(argument.span) -- equivalent call inferred; original call site unknown

				if v8 == "within" then
					vector2 = argument.span
					v5 = process_expression(argument)
					break
				elseif v8 == "after" then
					vector2 = vector.create(argument.span.y + 1, argument.span.y + 1, 0)
					v6 += 1
				elseif v8 == "before" then
					break
				end
			end

			local argument = v4.arguments[v6]

			if #v4.arguments < v6 then
				argument = v4.arguments[#v4.arguments]

				if argument and argument.kind ~= "variadic" then
					if v5.text ~= v5.text:match("%s*") then
						LOG("warn", `no argument #{v6}`) -- equivalent call inferred; original call site unknown
					end

					return v5
				end
			end

			if argument and argument.suggestion_generator then
				local suggestion_generator = argument.suggestion_generator
				local text = v5.text
				local v8 = suggestion_generator(text)

				for k, v9 in v8 do
					v8[k] = {
						name = v9,
						type = text,
						replace = vector2,
						with = v9
					}
				end

				table.move(v8, 1, #v8, #v5.suggestions + 1, v5.suggestions)
			end

			v5.analyzing = v5.analyzing or argument
			return v5
		end

		function process_if(p)
			local condition = p.condition

			if position_relative(get_span(condition)) == "within" then
				return process_expression_or_command(condition.value)
			end

			if p.block then
				return process_block(p.block.value)
			end
		end

		function parse_if_stat(p)
			for _, v3 in p.ifs do
				local v4 = position_relative(v3.span) -- equivalent call inferred; original call site unknown

				if v4 == "before" then
					continue
				end

				if v4 == "after" then
					break
				else
					return process_if(v3)
				end
			end

			local fallback = p.fallback

			if fallback and position_relative(get_span(fallback)) == "within" then
				return process_block(fallback.value)
			end
		end

		local function process_function(p)
			if not p.block then
				return (no_suggestions(""))
			end

			if position_relative(get_span(p.block)) == "within" then
				return process_block(p.block.value)
			end

			return (no_suggestions(""))
		end

		function process_var_prefix(p, flag: boolean)
			local prefix = p.prefix
			local analyzing = nil
			local text = nil
			local suggestions = {}

			if prefix.kind == "global" then
				text = get_text_token(prefix.token)

				if flag and string.sub("true", 1, #text) == text then
					table.insert(suggestions, {
						name = "true",
						type = "true",
						replace = p.span,
						with = "true"
					})
				end

				if flag and string.sub("false", 1, #text) == text then
					table.insert(suggestions, {
						name = "false",
						type = "false",
						replace = p.span,
						with = "false"
					})
				end

				if flag and string.sub("nil", 1, #text) == text then
					table.insert(suggestions, {
						name = "nil",
						type = "nil",
						replace = p.span,
						with = "nil"
					})
				end

				if not flag and string.sub("for", 1, #text) == text then
					table.insert(suggestions, {
						name = "for",
						type = "for",
						replace = p.span,
						with = "for"
					})
				end

				if not flag and string.sub("if", 1, #text) == text then
					table.insert(suggestions, {
						name = "if",
						type = "if",
						replace = p.span,
						with = "if"
					})
				end

				if not flag and string.sub("while", 1, #text) == text then
					table.insert(suggestions, {
						name = "while",
						type = "while",
						replace = p.span,
						with = "while"
					})
				end

				if not flag and string.sub("else", 1, #text) == text then
					table.insert(suggestions, {
						name = "else",
						type = "else",
						replace = p.span,
						with = "else"
					})
				end

				for _, command in data.commands do
					local v6 = string.lower(text)

					if string.sub(string.lower(command.name), 1, #v6) ~= v6 then
						continue
					end

					if #v6 == #command.name then
						analyzing = command
					end

					table.insert(suggestions, {
						name = command.name,
						description = command.description,
						type = "Command",
						replace = p.span,
						with = command.name
					})
				end
			elseif prefix.kind == "name" then
				text = not prefix.name and "" or prefix.name.text or ""

				for k, variable in data.variables do
					local v6 = string.lower(text)

					if string.sub(string.lower(k), 1, #v6) ~= v6 then
						continue
					end

					analyzing = #v6 == #k and {
						kind = "argument",
						name = k,
						type = typeof(variable)
					} or analyzing
					table.insert(suggestions, {
						name = k,
						type = typeof(variable),
						replace = prefix.name and prefix.name.span or vector.create(prefix.span.x + 1, prefix.span.y),
						with = k
					})
				end
			elseif prefix.kind == "paren" and prefix.expr.value then
				return process_expression_or_command(prefix.expr.value)
			end

			return {
				at = where,
				text = text,
				logs = logs,
				ast = v2.value,
				analyzing = analyzing,
				suggestions = suggestions
			}
		end

		function process_variable(data2, flag: boolean)
			if position_relative(data2.prefix.span) == "within" then
				return process_var_prefix(data2, flag)
			end

			if not (data2.prefix.kind ~= "paren" and data2.prefix.kind ~= "global") then
				return (no_suggestions(""))
			end

			local prefix = data2.prefix
			local text = prefix.name and prefix.name.text

			if not text then
				return (no_suggestions(""))
			end

			local variable = data.variables[text]
			local vector2 = vector.create(data2.span.x, 0)
			local text2 = nil

			if variable == nil then
				LOG("warn", `no defined variable named "{text}"`) -- equivalent call inferred; original call site unknown
				return (no_suggestions(text))
			else
				for _, suffix in data2.suffixes do
					if type(variable) ~= "table" and type(variable) ~= "userdata" and type(variable) ~= "vector" then
						LOG("warn", `probably can't index "{text}" which is a "{typeof(variable)}"`) -- equivalent call inferred; original call site unknown
					end

					if position_relative(suffix.span) == "within" then
						if suffix.kind == "nameindex" then
							text2 = suffix.name and suffix.name.text

							if not text2 then
								return (no_suggestions(text2))
							end

							vector2 = suffix.name and suffix.name.span or vector.create(
								suffix.span.x + 1,
								suffix.span.x + 1
							)
						elseif suffix.kind == "exprindex" then
							return (no_suggestions(""))
						end

						break
					else
						if suffix.kind ~= "nameindex" then
							return (no_suggestions(""))
						end

						text2 = suffix.name and suffix.name.text

						if not text2 then
							return (no_suggestions(text2))
						end

						variable = variable[text2]
					end
				end

				local suggestions = {}
				local analyzing = variable[text2] and {
					kind = "argument",
					name = text2,
					type = typeof(variable[text2])
				} or nil

				if type(variable) == "table" then
					for k, item in variable do
						local v6 = string.lower(text2)

						if string.sub(string.lower(k), 1, #v6) ~= v6 then
							continue
						end

						table.insert(suggestions, {
							name = k,
							with = k,
							type = typeof(item),
							replace = vector2
						})
					end
				end

				return {
					at = where,
					text = text2,
					logs = logs,
					analyzing = analyzing,
					suggestions = suggestions
				}
			end
		end

		process_expression = function(data2)
			if data2.kind == "lambda" then
				return process_function(data2.body)
			end

			if data2.kind == "evaluate" then
				if position_relative(get_span(data2.body)) == "within" and data2.body.value then
					return process_expression_or_command(data2.body.value)
				end
			elseif data2.kind == "vector" then
				for _, v3 in data2.contents.value do
					if position_relative(v3.span) ~= "before" then
						return process_expression(v3)
					end
				end
			else
				if data2.kind == "identifier" then
					return (no_suggestions(data2.token.text))
				end

				if data2.kind == "string" then
					return (no_suggestions(string.sub(data2.token.text, 2, -2)))
				end

				if data2.kind == "number" then
					return (no_suggestions(data2.token.text))
				end

				if data2.kind == "var" then
					return process_variable(data2.var, true)
				end
			end

			return (no_suggestions(""))
		end

		local function process_return(p)
			for _, value2 in p.values do
				if position_relative(value2.span) ~= "before" then
					return process_expression_or_command(value2)
				end
			end

			return (no_suggestions(""))
		end

		process_expression_or_command = function(p)
			if p.kind == "command" then
				return process_command(p, true)
			end

			return process_expression(p)
		end

		local function process_assignment(p)
			if not (p.right and position_relative(p.operator.span) ~= "before") then
				return (no_suggestions(""))
			end

			return process_expression_or_command(p.right)
		end

		local function process_while(p)
			if position_relative(get_span(p.expression)) == "within" then
				return process_expression_or_command(p.expression.value, true)
			end

			local block = p.block

			if block and position_relative(get_span(block)) == "within" then
				return process_block(block.value)
			end

			return (no_suggestions(""))
		end

		function parse_for(p)
			if p.expression and position_relative(get_span(p.expression)) == "within" then
				if p.expression.value == nil then
					return (no_suggestions(""))
				end

				return process_expression(p.expression.value)
			end

			if p.call then
				return process_function(p.call)
			end
		end

		process_block = function(value2)
			for k, v3 in value2.body do
				local v4 = position_relative(v3.span) -- equivalent call inferred; original call site unknown

				if not (v4 ~= "before" and (v4 ~= "after" or not (k < #value2.body))) then
					continue
				end

				if v3 == nil then
					return (no_suggestions(""))
				end

				if v3.kind == "if" then
					return (parse_if_stat(v3))
				end

				if v3.kind == "assign" then
					return (process_assignment(v3))
				end

				if v3.kind == "command" then
					return (process_command(v3))
				end

				if v3.kind == "return" then
					return (process_return(v3))
				end

				if v3.kind == "for" then
					return (parse_for(v3))
				end

				if v3.kind == "while" then
					return (process_while(v3))
				end

				return (no_suggestions(""))
			end

			return (no_suggestions(""))
		end

		return process_block(value)
	end
}