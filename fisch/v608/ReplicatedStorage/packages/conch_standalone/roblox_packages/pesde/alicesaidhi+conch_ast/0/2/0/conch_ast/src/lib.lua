require("../roblox_packages/types")

local function char(value: string)
	return (string.byte(value))
end

local function parse(buf: buffer, flag: boolean?)
	local v = 0
	local count = 0
	local v2 = buffer.len(buf)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function peek()
		if v == v2 then
			return 0
		end

		return (buffer.readu8(buf, v))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bump()
		v = math.min(v + 1, v2)
	end

	local function bump_any()
		if peek() == 10 then
			count += 1
		end

		bump() -- equivalent call inferred; original call site unknown

		if v == v2 then
			return 0
		end

		return (buffer.readu8(buf, v))
	end

	local function eof(message: string)
		if v2 <= v then
			error(message, 0)
		end

		return false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bump_peek()
		bump() -- equivalent call inferred; original call site unknown

		if v == v2 then
			return 0
		end

		return (buffer.readu8(buf, v))
	end

	-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
	local function is_whitespace(p: number)
		return p == 32 or p == 9 or p == 13
	end

	-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
	local function is_digit(p: number)
		return p >= 48 and p <= 57
	end

	local function is_alpha(p: number)
		return p >= 97 and p <= 122 or (p >= 65 and p <= 90 or (p == 64 or p == 95 or p == 39 or p == 47 or p == 58))
	end

	local function string_backslash()
		local v3 = peek() -- equivalent call inferred; original call site unknown

		if v3 == 13 then
			if bump_peek() == 10 then
				bump() -- equivalent call inferred; original call site unknown
				count += 1
			end
		elseif v3 == 122 then
			bump() -- equivalent call inferred; original call site unknown

			while true do
				local v4 = peek() -- equivalent call inferred; original call site unknown

				if v4 ~= 32 and v4 ~= 9 and v4 ~= 13 then
					break
				end

				if peek() == 10 then
					count += 1
				end

				bump() -- equivalent call inferred; original call site unknown

				if v ~= v2 then
					buffer.readu8(buf, v)
				end
			end
		else
			if peek() == 10 then
				count += 1
			end

			bump() -- equivalent call inferred; original call site unknown

			if v == v2 then
				return
			else
				buffer.readu8(buf, v)
			end
		end
	end

	local function quoted_string()
		local v3 = peek() -- equivalent call inferred; original call site unknown
		local v4 = bump_peek() -- equivalent call inferred; original call site unknown

		while v4 ~= v3 do
			if v2 <= v then
				error("unterminated string", 0)
			end

			if v4 == 0 or v4 == 10 or v4 == 13 then
				has_error = true
				return "error"
			end

			if v4 == 92 then
				bump() -- equivalent call inferred; original call site unknown
				string_backslash()
			else
				bump() -- equivalent call inferred; original call site unknown
			end

			v4 = peek()
		end

		bump() -- equivalent call inferred; original call site unknown
		return "string"
	end

	local function number()
		local v3 = v
		local v4 = 10
		local v5 = peek() -- equivalent call inferred; original call site unknown

		if v5 == 48 then
			v5 = bump_peek()

			if v5 == 120 or v5 == 88 then
				v5 = bump_peek()
				v4 = 16
			elseif v5 == 98 or v5 == 66 then
				v5 = bump_peek()
				v4 = 2
			end
		end

		while true do
			if is_digit(v5) or v5 == 46 or v5 == 95 or v5 == 45 then
				v5 = bump_peek()
			else
				if v5 == 101 or v5 == 69 then
					v5 = bump_peek()

					if v5 == 43 or v5 == 45 then
						bump() -- equivalent call inferred; original call site unknown

						if v == v2 then
							v5 = 0
						else
							v5 = buffer.readu8(buf, v)
						end
					end
				end

				while true do
					if is_digit(v5) or is_alpha(v5) or v5 == 95 then
						v5 = bump_peek()
					else
						local v8

						if v4 == 10 then
							v8 = buffer.readstring(buf, v3, v - v3)
						else
							v8 = buffer.readstring(buf, v3 + 2, v - v3 - 2)
						end

						if tonumber(string.gsub(v8, "_", ""), v4) then
							return "number"
						end

						has_error = true
						return "error"
					end
				end
			end
		end
	end

	local read_kind

	read_kind = function()
		local v3 = peek() -- equivalent call inferred; original call site unknown

		if v3 == 0 then
			return "eof"
		end

		if is_whitespace(v3) then
			bump() -- equivalent call inferred; original call site unknown
			return "whitespace"
		end

		if is_alpha(v3) then
			local v4 = v

			while true do
				local v5 = bump_peek() -- equivalent call inferred; original call site unknown

				if is_alpha(v5) or is_digit(v5) or v5 == 45 or v5 == 46 then
					continue
				end

				local v7 = buffer.readstring(buf, v4, v - v4)

				if v7 == "true" then
					return "true"
				elseif v7 == "false" then
					return "false"
				elseif v7 == "nil" then
					return "nil"
				elseif v7 == "return" then
					return "return"
				elseif v7 == "for" then
					return "for"
				elseif v7 == "while" then
					return "while"
				elseif v7 == "if" then
					return "if"
				elseif v7 == "else" then
					return "else"
				elseif v7 == "break" then
					return "break"
				elseif v7 == "continue" then
					return "continue"
				end

				return "identifier"
			end
		else
			if is_digit(v3) or v3 == 45 then
				return (number())
			end

			if v3 == 34 then
				return (quoted_string())
			end

			if v3 == 46 then
				local v5 = peek() -- equivalent call inferred; original call site unknown

				if is_digit(v5) then
					v -= 1
					return (number())
				end

				bump() -- equivalent call inferred; original call site unknown
				return "."
			elseif v3 == 61 then
				if bump_peek() == 61 then
					return "=="
				end

				return "="
			elseif v3 == 126 then
				if bump_peek() == 61 then
					return "~="
				end

				has_error = true
				return "error"
			elseif v3 == 62 then
				if bump_peek() == 61 then
					return ">="
				end

				return ">"
			elseif v3 == 60 then
				if bump_peek() == 61 then
					return "<="
				end

				return "<"
			else
				if v3 == 36 then
					bump() -- equivalent call inferred; original call site unknown
					return "$"
				elseif v3 == 40 then
					bump() -- equivalent call inferred; original call site unknown
					return "("
				elseif v3 == 41 then
					bump() -- equivalent call inferred; original call site unknown
					return ")"
				elseif v3 == 123 then
					bump() -- equivalent call inferred; original call site unknown
					return "{"
				elseif v3 == 125 then
					bump() -- equivalent call inferred; original call site unknown
					return "}"
				elseif v3 == 91 then
					bump() -- equivalent call inferred; original call site unknown
					return "["
				elseif v3 == 93 then
					bump() -- equivalent call inferred; original call site unknown
					return "]"
				elseif v3 == 124 then
					bump() -- equivalent call inferred; original call site unknown
					return "|"
				elseif v3 == 10 then
					bump() -- equivalent call inferred; original call site unknown
					return "\n"
				elseif v3 == 59 then
					bump() -- equivalent call inferred; original call site unknown
					return ";"
				elseif v3 == 44 then
					bump() -- equivalent call inferred; original call site unknown
					return ","
				end

				if is_whitespace(v3) then
					bump() -- equivalent call inferred; original call site unknown
					return read_kind()
				end

				error(`no symbol matching {string.char(v3)}`, 0)
				return "error"
			end
		end
	end

	local function next_token()
		local v3 = v
		local kind3 = read_kind()

		while kind3 == "whitespace" or kind3 == "comment" do
			v3 = v
			kind3 = read_kind()
		end

		return {
			kind = kind3,
			text = buffer.readstring(buf, v3, v - v3),
			span = vector.create(v3, v, 0)
		}
	end

	local v3 = next_token()
	local kind = v3.kind
	local x = v3.span.x
	local v4 = next_token()
	local kind2 = v4.kind
	local x2 = v4.span.x

	local function consume()
		local v5 = v3
		local v6 = kind
		v3 = v4
		kind = kind2
		x = x2
		v4 = next_token()
		kind2 = v4.kind
		x2 = v4.span.x
		return v5, v6
	end

	local function current_is(p)
		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		return kind == p
	end

	local function lookahead_is(p)
		while kind2 == "\n" do
			v4 = next_token()
			kind2 = v4.kind
		end

		return kind2 == p
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function yield()
		if flag then
			local v5 = coroutine.yield()
			assert(typeof(v5) == "buffer")
			buf = v5
			v2 = buffer.len(v5)
			v3 = next_token()
			kind = v3.kind
			v4 = next_token()
			kind2 = v4.kind
		end
	end

	local function display(p)
		local kind3 = p.kind

		if kind3 == "identifier" or kind3 == "number" or kind3 == "string" then
			return kind3
		end

		if p.kind == "error" then
			return "error '" .. p.text .. "'"
		end

		return "'" .. kind3 .. "'"
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function report(message: string, vector2: Vector3?)
		local v5 = {
			message = message,
			span = vector2 or v3.span
		}
		error(`{v5.message} from {v5.span.x} to {v5.span.y}`, 0)
	end

	local function expect_failure(kind5)
		local v7 = {
			kind = kind5
		}
		local kind3 = v7.kind

		if kind3 ~= "identifier" and kind3 ~= "number" and kind3 ~= "string" then
			if v7.kind == "error" then
				kind3 = "error '" .. v7.text .. "'"
			else
				kind3 = "'" .. kind3 .. "'"
			end
		end

		local v8 = v3
		local kind4 = v8.kind

		if kind4 ~= "identifier" and kind4 ~= "number" and kind4 ~= "string" then
			if v8.kind == "error" then
				kind4 = "error '" .. v8.text .. "'"
			else
				kind4 = "'" .. kind4 .. "'"
			end
		end

		return report((`expected {kind3}, but got {kind4} of {kind} instead`))
	end

	local function expect(kind5)
		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == kind5 then
			local v5 = v3
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
			return v5
		else
			if kind ~= "eof" or not flag then
				return expect_failure(kind5)
			end

			yield() -- equivalent call inferred; original call site unknown

			while kind == "\n" do
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			end

			if kind == kind5 then
				local v5 = v3
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
				return v5
			else
				local v6 = {
					kind = kind5
				}
				local kind3 = v6.kind

				if kind3 ~= "identifier" and kind3 ~= "number" and kind3 ~= "string" then
					if v6.kind == "error" then
						kind3 = "error '" .. v6.text .. "'"
					else
						kind3 = "'" .. kind3 .. "'"
					end
				end

				local v7 = v3
				local kind4 = v7.kind

				if kind4 ~= "identifier" and kind4 ~= "number" and kind4 ~= "string" then
					if v7.kind == "error" then
						kind4 = "error '" .. v7.text .. "'"
					else
						kind4 = "'" .. kind4 .. "'"
					end
				end

				report(`expected {kind3}, but got {kind4} of {kind} instead`) -- equivalent call inferred; original call site unknown
				return nil
			end
		end
	end

	local parse_expression
	local parse_command
	local parse_block
	local parse_expression_or_command

	local function parse_var_root()
		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "identifier" then
			local token = expect("identifier")
			return {
				kind = "global",
				span = token.span,
				token = token
			}
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "$" then
			while kind2 == "\n" do
				v4 = next_token()
				kind2 = v4.kind
			end

			if kind2 == "identifier" then
				local v5 = expect("$")
				local name = expect("identifier")
				return {
					kind = "name",
					span = vector.create(v5.span.x, name.span.y, 0),
					name = name
				}
			end
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "$" then
			while kind2 == "\n" do
				v4 = next_token()
				kind2 = v4.kind
			end

			if kind2 == "(" then
				local v5 = expect("$")
				expect("(")
				local expr = parse_expression_or_command()
				local v7 = expect(")")
				return {
					kind = "paren",
					span = vector.create(v5.span.x, v7.span.y, 0),
					expr = expr
				}
			end
		end

		local v7 = v4
		local kind3 = v7.kind

		if kind3 ~= "identifier" and kind3 ~= "number" and kind3 ~= "string" then
			if v7.kind == "error" then
				kind3 = "error '" .. v7.text .. "'"
			else
				kind3 = "'" .. kind3 .. "'"
			end
		end

		return report((`expected identifier, got {kind3}`))
	end

	local function parse_var_suffix()
		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		local v5

		if kind == "." then
			v5 = true
		else
			v5 = false
		end

		if v5 then
			local v6 = expect(".")
			local name = expect("identifier")
			return {
				kind = "nameindex",
				span = vector.create(v6.span.x, name.span.y, 0),
				name = name
			}
		else
			while kind == "\n" do
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			end

			local v6

			if kind == "[" then
				v6 = true
			else
				v6 = false
			end

			if not v6 then
				return report("invalid")
			end

			local v7 = expect("[")
			local expr = parse_expression_or_command()
			local v9 = expect("]")
			return {
				kind = "exprindex",
				span = vector.create(v7.span.x, v9.span.y, 0),
				expr = expr
			}
		end
	end

	local function parse_var_suffixes()
		local result = {}

		while true do
			if kind == "\n" then
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			else
				if kind ~= "." then
					while kind == "\n" do
						v3 = v4
						kind = kind2
						x = x2
						v4 = next_token()
						kind2 = v4.kind
						x2 = v4.span.x
					end

					if kind ~= "[" then
						return result
					end
				end

				table.insert(result, (parse_var_suffix()))
			end
		end
	end

	local function parse_var()
		local prefix = parse_var_root()
		local suffixes = prefix.kind == "global" and {} or parse_var_suffixes()
		local x3 = prefix.span.x
		local v7

		if #suffixes > 0 then
			v7 = suffixes[#suffixes].span.y
		else
			v7 = prefix.span.y
		end

		return {
			span = vector.create(x3, v7, 0),
			prefix = prefix,
			suffixes = suffixes
		}
	end

	parse_expression_or_command = function()
		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "identifier" then
			return parse_command()
		end

		if kind ~= "eof" or not flag then
			return parse_expression()
		end

		yield() -- equivalent call inferred; original call site unknown
		return parse_expression_or_command()
	end

	local function parse_function_body()
		local x3 = expect("|").span.x
		local arguments = {}
		local v6 = true

		while true do
			if kind == "\n" then
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			elseif kind == "|" then
				expect("|")
				expect("{")
				local block = parse_block("}")
				return {
					span = vector.create(x3, expect("}").span.y, 0),
					arguments = arguments,
					block = block
				}
			elseif kind == "eof" and flag then
				yield() -- equivalent call inferred; original call site unknown
			else
				if not v6 then
					expect(",")
				end

				table.insert(arguments, expect("identifier"))
				v6 = false
			end
		end
	end

	local function parse_lambda()
		local body = parse_function_body()
		return {
			kind = "lambda",
			body = body,
			span = body.span
		}
	end

	function parse_table()
		local x3 = expect("{").span.x
		local fields = {}
		local v6 = true

		while true do
			if kind == "\n" then
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			else
				if kind == "}" then
					return {
						fields = fields,
						span = vector.create(x3, expect("}").span.y, 0)
					}
				end

				if not v6 then
					expect(",")
				end

				v6 = false

				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				if kind == "identifier" then
					while kind2 == "\n" do
						v4 = next_token()
						kind2 = v4.kind
					end

					if kind2 == "=" then
						local name = expect("identifier")
						expect("=")
						table.insert(fields, {
							kind = "namekey",
							name = name,
							value = parse_expression()
						})
						continue
					end
				end

				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				if kind == "[" then
					expect("[")
					local v7 = parse_expression()
					expect("]")
					expect("=")
					table.insert(fields, {
						kind = "exprkey",
						key = v7,
						value = parse_expression()
					})
				else
					table.insert(fields, {
						kind = "nokey",
						value = parse_expression()
					})
				end
			end
		end
	end

	function parse_vector()
		local v5 = expect("[")
		local count2 = 0
		local contents = {}

		while count2 < 3 do
			while kind == "\n" do
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			end

			if kind == "]" then
				break
			end

			if count2 ~= 0 then
				expect(",")
			end

			count2 += 1
			contents[count2] = parse_expression()
		end

		local v7 = expect("]")
		return {
			kind = "vector",
			span = vector.create(v5.span.x, v7.span.y, 0),
			contents = contents
		}
	end

	parse_expression = function()
		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "$" then
			while kind2 == "\n" do
				v4 = next_token()
				kind2 = v4.kind
			end

			if kind2 == "(" then
				local x3 = expect("$").span.x

				while kind2 == "\n" do
					v4 = next_token()
					kind2 = v4.kind
				end

				local body

				if kind2 == "$" then
					expect("(")
					body = parse_command()
				else
					while kind2 == "\n" do
						v4 = next_token()
						kind2 = v4.kind
					end

					if kind2 == "identifier" then
						expect("(")
						body = parse_command()
					else
						expect("(")
						body = parse_expression()
					end
				end

				return {
					kind = "evaluate",
					body = body,
					span = vector.create(x3, expect(")").span.y, 0)
				}
			end
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "$" then
			local var = parse_var()
			return {
				kind = "var",
				var = var,
				span = var.span
			}
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "string" then
			local token = expect("string")
			return {
				kind = "string",
				token = token,
				span = token.span
			}
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "number" then
			local token = expect("number")
			return {
				kind = "number",
				token = token,
				span = token.span
			}
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "true" then
			local token = expect("true")
			return {
				kind = "boolean",
				token = token,
				span = token.span
			}
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "false" then
			local token = expect("false")
			return {
				kind = "boolean",
				token = token,
				span = token.span
			}
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "identifier" then
			local v5 = expect("identifier")
			return {
				kind = "string",
				token = {
					kind = "string",
					text = `"{v5.text}"`,
					span = v5.span
				},
				span = v5.span
			}
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "|" then
			return parse_lambda()
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "{" then
			local table2 = parse_table()
			return {
				kind = "table",
				table = table2,
				span = table2.span
			}
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		if kind == "[" then
			return parse_vector()
		end

		if kind ~= "eof" or not flag then
			return report((`expected expression, got {kind}`))
		end

		yield() -- equivalent call inferred; original call site unknown
		return parse_expression()
	end

	parse_command = function()
		local prefix = parse_var()
		local arguments = {}

		while kind ~= "\n" do
			while kind == "\n" do
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			end

			if kind ~= "$" then
				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				if kind ~= "string" then
					while kind == "\n" do
						v3 = v4
						kind = kind2
						x = x2
						v4 = next_token()
						kind2 = v4.kind
						x2 = v4.span.x
					end

					if kind ~= "number" then
						while kind == "\n" do
							v3 = v4
							kind = kind2
							x = x2
							v4 = next_token()
							kind2 = v4.kind
							x2 = v4.span.x
						end

						if kind ~= "true" then
							while kind == "\n" do
								v3 = v4
								kind = kind2
								x = x2
								v4 = next_token()
								kind2 = v4.kind
								x2 = v4.span.x
							end

							if kind ~= "false" then
								while kind == "\n" do
									v3 = v4
									kind = kind2
									x = x2
									v4 = next_token()
									kind2 = v4.kind
									x2 = v4.span.x
								end

								if kind ~= "identifier" then
									while kind == "\n" do
										v3 = v4
										kind = kind2
										x = x2
										v4 = next_token()
										kind2 = v4.kind
										x2 = v4.span.x
									end

									if kind ~= "{" then
										while kind == "\n" do
											v3 = v4
											kind = kind2
											x = x2
											v4 = next_token()
											kind2 = v4.kind
											x2 = v4.span.x
										end

										if kind ~= "|" then
											while kind == "\n" do
												v3 = v4
												kind = kind2
												x = x2
												v4 = next_token()
												kind2 = v4.kind
												x2 = v4.span.x
											end

											if kind ~= "[" then
												break
											end
										end
									end
								end
							end
						end
					end
				end
			end

			table.insert(arguments, (parse_expression()))
		end

		local v7

		if #arguments > 0 then
			v7 = arguments[#arguments].span.y
		else
			v7 = prefix.span.y
		end

		return {
			kind = "command",
			prefix = prefix,
			arguments = arguments,
			span = vector.create(prefix.span.x, v7, 0)
		}
	end

	local function parse_if()
		local x3 = expect("if").span.x
		local flag2 = true
		local ifs = {}
		local fallback = nil
		local y = 0

		while true do
			if flag2 then
				expect("(")

				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				local condition

				if kind == "identifier" then
					condition = parse_command()
				else
					condition = parse_expression()
				end

				expect(")")
				expect("{")
				local block = parse_block("}")
				y = expect("}").span.y
				table.insert(ifs, {
					condition = condition,
					block = block
				})
				flag2 = false
			else
				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				if kind == "else" then
					while kind2 == "\n" do
						v4 = next_token()
						kind2 = v4.kind
					end

					if kind2 == "if" then
						expect("else")
						expect("if")
						expect("(")

						while kind == "\n" do
							v3 = v4
							kind = kind2
							x = x2
							v4 = next_token()
							kind2 = v4.kind
							x2 = v4.span.x
						end

						local condition

						if kind == "identifier" then
							condition = parse_command()
						else
							condition = parse_expression()
						end

						expect(")")
						expect("{")
						local block = parse_block("}")
						y = expect("}").span.y
						table.insert(ifs, {
							condition = condition,
							block = block
						})
						continue
					end
				end

				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				if kind == "else" then
					expect("else")
					expect("{")
					fallback = parse_block("}")
					y = expect("}").span.y
				end

				return {
					kind = "if",
					ifs = ifs,
					fallback = fallback,
					span = vector.create(x3, y, 0)
				}
			end
		end
	end

	local function parse_while()
		local x3 = expect("while").span.x
		expect("(")

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		local expression

		if kind == "identifier" then
			expression = parse_command()
		else
			expression = parse_expression()
		end

		expect(")")
		expect("{")
		return {
			kind = "while",
			expression = expression,
			block = parse_block("}"),
			span = vector.create(x3, expect("}").span.y, 0)
		}
	end

	local function parse_for()
		local x3 = expect("for").span.x
		expect("(")
		local expression = parse_expression_or_command()
		expect(")")
		local call = parse_function_body()
		return {
			kind = "for",
			expression = expression,
			call = call,
			span = vector.create(x3, call.span.y, 0)
		}
	end

	local function parse_return()
		local span = expect("return").span
		local x3 = span.x
		local y = span.y
		local values = {}

		while kind ~= "}" and kind ~= "eof" do
			if #values > 0 then
				expect(",")
			end

			local v6 = parse_expression()
			table.insert(values, v6)
			y = v6.span.y
		end

		return {
			kind = "return",
			values = values,
			span = vector.create(x3, y, 0)
		}
	end

	parse_block = function(p, value: number?)
		local v5 = value or 0
		local v6 = v5
		local last_statement = nil
		local body = {}

		while kind ~= p do
			if last_statement then
				report("expected to finish after last statement") -- equivalent call inferred; original call site unknown
			end

			while kind == "\n" do
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			end

			if kind == "identifier" then
				while kind2 == "\n" do
					v4 = next_token()
					kind2 = v4.kind
				end

				if kind2 == "=" then
					local left = expect("identifier")
					expect("=")
					table.insert(body, {
						kind = "assign",
						left = left,
						right = parse_expression_or_command()
					})
					v6 = x
					continue
				end
			end

			while kind == "\n" do
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			end

			if kind == "if" then
				table.insert(body, parse_if())
				v6 = x
			else
				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				if kind == "while" then
					table.insert(body, parse_while())
					v6 = x
				else
					while kind == "\n" do
						v3 = v4
						kind = kind2
						x = x2
						v4 = next_token()
						kind2 = v4.kind
						x2 = v4.span.x
					end

					if kind == "for" then
						table.insert(body, parse_for())
						v6 = x
					else
						while kind == "\n" do
							v3 = v4
							kind = kind2
							x = x2
							v4 = next_token()
							kind2 = v4.kind
							x2 = v4.span.x
						end

						if kind == "return" then
							last_statement = parse_return()
							v6 = x
						else
							while kind == "\n" do
								v3 = v4
								kind = kind2
								x = x2
								v4 = next_token()
								kind2 = v4.kind
								x2 = v4.span.x
							end

							if kind == "break" then
								last_statement = {
									kind = "break",
									span = expect("break").span
								}
								v6 = x
							else
								while kind == "\n" do
									v3 = v4
									kind = kind2
									x = x2
									v4 = next_token()
									kind2 = v4.kind
									x2 = v4.span.x
								end

								if kind == "continue" then
									last_statement = {
										kind = "continue",
										span = expect("continue")
									}
									v6 = x
								else
									while kind == "\n" do
										v3 = v4
										kind = kind2
										x = x2
										v4 = next_token()
										kind2 = v4.kind
										x2 = v4.span.x
									end

									if kind == "identifier" then
										table.insert(body, parse_command())
										v6 = x
									else
										while kind == "\n" do
											v3 = v4
											kind = kind2
											x = x2
											v4 = next_token()
											kind2 = v4.kind
											x2 = v4.span.x
										end

										if kind == "$" then
											table.insert(body, parse_command())
											v6 = x
										else
											while kind == "\n" do
												v3 = v4
												kind = kind2
												x = x2
												v4 = next_token()
												kind2 = v4.kind
												x2 = v4.span.x
											end

											if kind == ";" then
												v3 = v4
												kind = kind2
												x = x2
												v4 = next_token()
												kind2 = v4.kind
												x2 = v4.span.x
												v6 = x
											else
												if kind == "eof" and p ~= "eof" and flag then
													yield() -- equivalent call inferred; original call site unknown
												else
													if kind == p then
														v6 = x
														break
													end

													report(`cannot parse {kind}`) -- equivalent call inferred; original call site unknown
												end

												v6 = x
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end

		return {
			span = vector.create(v5, v6, 0),
			body = body,
			last_statement = last_statement
		}
	end

	return parse_block("eof")
end

local function generate(p: string, flag: boolean?)
	local src = p
	local thread = coroutine.create(parse)
	local get_result

	local function append(p2: string)
		src ..= p2
		local buffer2 = buffer.fromstring(src)
		return get_result(coroutine.resume(thread, buffer2, flag))
	end

	local function overwrite(str: string)
		src = str
		local buffer2 = buffer.fromstring(str)
		return get_result(coroutine.resume(thread, buffer2, flag))
	end

	get_result = function(flag2: boolean, why)
		if coroutine.status(thread) == "suspended" then
			return {
				status = "pending",
				src = src,
				append = append,
				set = overwrite
			}
		end

		if flag2 == false then
			return {
				status = "error",
				src = src,
				why = why
			}
		end

		if coroutine.status(thread) == "dead" then
			return {
				status = "finished",
				src = src,
				value = why
			}
		end

		error("?")
	end

	return overwrite(p)
end

return generate