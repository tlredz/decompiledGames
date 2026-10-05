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
		return p >= 97 and p <= 122 or (p >= 65 and p <= 90 or (p == 95 or p == 64 or p == 39 or p == 47 or p == 58))
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
				error("expected string to be finished at", 0)
			end

			if v4 == 0 or v4 == 10 or v4 == 13 then
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

	local function current_is(p: string)
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

	local function lookahead_is(p: string)
		while kind2 == "\n" do
			v4 = next_token()
			kind2 = v4.kind
		end

		return kind2 == p
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

	local function expect_failure(kind5: string)
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

			yield()

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

			if kind2 == "(" then
				local operator = expect("$")
				local left = expect("(")

				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				if kind ~= "eof" then
					while kind == "\n" do
						v3 = v4
						kind = kind2
						x = x2
						v4 = next_token()
						kind2 = v4.kind
						x2 = v4.span.x
					end

					if kind ~= ";" then
						local v7 = parse_expression_or_command()

						while kind == "\n" do
							v3 = v4
							kind = kind2
							x = x2
							v4 = next_token()
							kind2 = v4.kind
							x2 = v4.span.x
						end

						if kind ~= "}" then
							return {
								kind = "paren",
								span = vector.create(operator.span.x, v7.span.y, 0),
								expr = {
									left = left,
									value = v7
								},
								operator = operator
							}
						end

						local right = expect("}")
						return {
							kind = "paren",
							span = vector.create(operator.span.x, right.span.y, 0),
							expr = {
								left = left,
								right = right,
								value = v7
							},
							operator = operator
						}
					end
				end

				return {
					kind = "paren",
					span = vector.create(operator.span.x, left.span.y, 0),
					expr = {
						left = left
					},
					operator = operator
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
			local operator = expect("$")

			while kind == "\n" do
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			end

			if kind ~= "identifier" then
				return {
					kind = "name",
					span = vector.create(operator.span.x, operator.span.y, 0),
					operator = operator
				}
			end

			local name = expect("identifier")
			return {
				kind = "name",
				span = vector.create(operator.span.x, name.span.y, 0),
				name = name,
				operator = operator
			}
		else
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

		if kind == "." then
			local operator = expect(".")

			while kind == "\n" do
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			end

			if kind == "identifier" == false then
				return {
					kind = "nameindex",
					span = vector.create(operator.span.x, operator.span.y, 0),
					operator = operator
				}
			end

			local name = expect("identifier")
			return {
				kind = "nameindex",
				span = vector.create(operator.span.x, name.span.y, 0),
				operator = operator,
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

			if kind ~= "[" then
				return report("invalid")
			end

			local left = expect("[")

			if kind == "eof" then
				return {
					kind = "exprindex",
					span = vector.create(left.span.x, left.span.y, 0),
					expr = {
						left = left
					}
				}
			end

			local v6 = parse_expression_or_command()

			if kind ~= "]" then
				return {
					kind = "exprindex",
					span = vector.create(left.span.x, v6.span.y, 0),
					expr = {
						left = left,
						value = v6
					}
				}
			end

			local right = expect("]")
			return {
				kind = "exprindex",
				span = vector.create(left.span.x, right.span.y, 0),
				expr = {
					left = left,
					right = right,
					value = v6
				}
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

		local v5

		if kind == "identifier" then
			v5 = true
		else
			v5 = false
		end

		if v5 then
			return parse_command()
		end

		return parse_expression()
	end

	local function parse_function_body()
		local left = expect("|")
		local v6 = true
		local v7 = {}

		while true do
			if kind == "\n" then
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			else
				if kind ~= "|" then
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
						table.insert(v7, expect("identifier"))
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

				local right

				if kind == "|" then
					right = expect("|")
				end

				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				local left2

				if kind == "{" then
					left2 = expect("{")
				end

				local v10 = parse_block("}")

				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				local right2

				if kind == "}" then
					right2 = expect("}")
				end

				local result = {
					arguments = {
						left = left,
						right = right,
						value = v7
					},
					block = (left2 or v10 or right2) and {
						left = left2,
						right = right2,
						value = v10
					} or nil,
					span = 0
				}
				local x3 = left.span.x
				local v12

				if right2 then
					v12 = right2.span.y
				else
					v12 = v10.span.y
				end

				result.span = vector.create(x3, v12, 0)
				return result
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
		local left = expect("{")
		local v6 = true
		local v7 = {}

		while true do
			if kind == "\n" then
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			else
				if kind ~= "}" then
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

					local v8, left2, v10, v11, right, v13, operator, v15, x3, y, v16

					if kind == "identifier" then
						while kind2 == "\n" do
							v4 = next_token()
							kind2 = v4.kind
						end

						if kind2 == "=" then
							local name = expect("identifier")
							local operator2 = expect("=")

							if kind == "eof" then
								table.insert(v7, {
									kind = "namekey",
									span = vector.create(name.span.x, operator2.span.y, 0),
									name = name,
									operator = operator2
								})
							else
								table.insert(v7, {
									kind = "namekey",
									name = name,
									value = parse_expression()
								})
								continue
							end
						else
							while kind == "\n" do
								v8 = kind2
								v3 = v4
								kind = v8
								x = x2
								v4 = next_token()
								kind2 = v4.kind
								x2 = v4.span.x
							end

							if kind == "[" then
								left2 = expect("[")

								if kind == "eof" then
									table.insert(v7, {
										kind = "exprkey",
										span = vector.create(left2.span.x, left2.span.y, 0),
										key = {
											left = left2
										}
									})
								else
									v10 = parse_expression()

									while kind == "\n" do
										v11 = kind2
										v3 = v4
										kind = v11
										x = x2
										v4 = next_token()
										kind2 = v4.kind
										x2 = v4.span.x
									end

									if kind == "]" then
										right = expect("]")
									end

									while kind == "\n" do
										v13 = kind2
										v3 = v4
										kind = v13
										x = x2
										v4 = next_token()
										kind2 = v4.kind
										x2 = v4.span.x
									end

									if kind == "=" then
										operator = expect("=")
									end

									if kind == "eof" then
										v15 = {
											kind = "exprkey",
											span = 0,
											key = 0,
											operator = 0
										}
										x3 = left2.span.x

										if operator then
											y = operator.span.y
										elseif right then
											y = right.span.y
										else
											y = v10.span.y
										end

										v15.span = vector.create(x3, y, 0)
										v15.key = {
											left = left2,
											right = right,
											value = v10
										}
										v15.operator = operator
										table.insert(v7, v15)
									else
										v16 = parse_expression()
										table.insert(v7, {
											kind = "exprkey",
											span = vector.create(left2.span.x, v16.span.y, 0),
											key = {
												left = left2,
												right = right,
												value = v10
											},
											operator = operator,
											value = v16
										})
										continue
									end
								end
							elseif kind ~= "eof" then
								table.insert(v7, {
									kind = "nokey",
									value = parse_expression()
								})
								continue
							end
						end
					else
						while kind == "\n" do
							v8 = kind2
							v3 = v4
							kind = v8
							x = x2
							v4 = next_token()
							kind2 = v4.kind
							x2 = v4.span.x
						end

						if kind == "[" then
							left2 = expect("[")

							if kind == "eof" then
								table.insert(v7, {
									kind = "exprkey",
									span = vector.create(left2.span.x, left2.span.y, 0),
									key = {
										left = left2
									}
								})
							else
								v10 = parse_expression()

								while kind == "\n" do
									v11 = kind2
									v3 = v4
									kind = v11
									x = x2
									v4 = next_token()
									kind2 = v4.kind
									x2 = v4.span.x
								end

								if kind == "]" then
									right = expect("]")
								end

								while kind == "\n" do
									v13 = kind2
									v3 = v4
									kind = v13
									x = x2
									v4 = next_token()
									kind2 = v4.kind
									x2 = v4.span.x
								end

								if kind == "=" then
									operator = expect("=")
								end

								if kind == "eof" then
									v15 = {
										kind = "exprkey",
										span = 0,
										key = 0,
										operator = 0
									}
									x3 = left2.span.x

									if operator then
										y = operator.span.y
									elseif right then
										y = right.span.y
									else
										y = v10.span.y
									end

									v15.span = vector.create(x3, y, 0)
									v15.key = {
										left = left2,
										right = right,
										value = v10
									}
									v15.operator = operator
									table.insert(v7, v15)
								else
									v16 = parse_expression()
									table.insert(v7, {
										kind = "exprkey",
										span = vector.create(left2.span.x, v16.span.y, 0),
										key = {
											left = left2,
											right = right,
											value = v10
										},
										operator = operator,
										value = v16
									})
									continue
								end
							end
						elseif kind ~= "eof" then
							table.insert(v7, {
								kind = "nokey",
								value = parse_expression()
							})
							continue
						end
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

				if kind == "}" then
					local right = expect("}")
					return {
						fields = {
							left = left,
							right = right,
							value = v7
						},
						span = vector.create(left.span.x, right.span.y, 0)
					}
				end

				local y = left.span.y

				if #v7 > 0 then
					y = v7[#v7].span.y
				end

				return {
					fields = {
						left = left,
						value = v7
					},
					span = vector.create(left.span.x, y, 0)
				}
			end
		end
	end

	local function parse_vector()
		local left = expect("[")
		local x3 = left.span.x
		local y = left.span.y
		local count2 = 0
		local v6 = {}

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

			while kind == "\n" do
				v3 = v4
				kind = kind2
				x = x2
				v4 = next_token()
				kind2 = v4.kind
				x2 = v4.span.x
			end

			if kind == "eof" then
				break
			end

			if count2 ~= 0 then
				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				if kind == "," then
					expect(",")
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

			if kind == "eof" then
				break
			end

			count2 += 1
			local v7 = parse_expression()
			v6[count2] = v7
			y = v7.span.y
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		local right

		if kind == "]" then
			right = expect("]")
		end

		if right then
			y = right.span.y
		end

		return {
			kind = "vector",
			span = vector.create(x3, y, 0),
			contents = {
				left = left,
				right = right,
				value = v6
			}
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
				local operator = expect("$")
				local left = expect("(")

				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				local v7, v8, right

				if kind == "$" then
					v7 = parse_command()
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
						v7 = parse_command()
					else
						if kind == "eof" then
							return {
								kind = "evaluate",
								body = {
									left = left
								},
								operator = operator,
								span = vector.create(operator.span.x, left.span.y, 0)
							}
						end

						v7 = parse_expression()
					end
				end

				while kind == "\n" do
					v8 = kind2
					v3 = v4
					kind = v8
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				if kind ~= ")" then
					return {
						kind = "evaluate",
						body = {
							left = left,
							value = v7
						},
						operator = operator,
						span = vector.create(operator.span.x, v7.span.y, 0)
					}
				end

				right = expect(")")
				return {
					kind = "evaluate",
					body = {
						left = left,
						right = right,
						value = v7
					},
					operator = operator,
					span = vector.create(operator.span.x, right.span.y, 0)
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

			if kind2 == "identifier" then
				local var = parse_var()
				return {
					kind = "var",
					var = var,
					span = var.span
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
			local token = expect("identifier")
			return {
				kind = "identifier",
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

		return report((`expected expression, got {kind}`))
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
		local flag2 = true
		local ifs = {}
		local else_keyword = nil
		local fallback = nil

		while true do
			if flag2 then
				local keyword = expect("if")

				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				local left

				if kind == "(" then
					left = expect("(")
				end

				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				local v10

				if kind == "identifier" then
					v10 = parse_command()
				else
					v10 = parse_expression()
				end

				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				local right

				if kind == ")" then
					right = expect(")")
				end

				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				local left2

				if kind == "{" then
					left2 = expect("{")
				end

				local v13 = parse_block("}")

				while kind == "\n" do
					v3 = v4
					kind = kind2
					x = x2
					v4 = next_token()
					kind2 = v4.kind
					x2 = v4.span.x
				end

				local right2

				if kind == "}" then
					right2 = expect("}")
				end

				local x3 = keyword.span.x
				local v16

				if right2 then
					v16 = right2.span.y
				else
					v16 = v13.span.y
				end

				local v15 = {
					keyword = keyword,
					condition = {
						left = left,
						right = right,
						value = v10
					},
					block = {
						left = left2,
						right = right2,
						value = v13
					},
					span = vector.create(x3, v16, 0)
				}
				table.insert(ifs, v15)
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
						local elsekeyword = expect("else")
						local keyword = expect("if")

						while kind == "\n" do
							v3 = v4
							kind = kind2
							x = x2
							v4 = next_token()
							kind2 = v4.kind
							x2 = v4.span.x
						end

						local left

						if kind == "(" then
							left = expect("(")
						end

						while kind == "\n" do
							v3 = v4
							kind = kind2
							x = x2
							v4 = next_token()
							kind2 = v4.kind
							x2 = v4.span.x
						end

						local v11

						if kind == "identifier" then
							v11 = parse_command()
						else
							v11 = parse_expression()
						end

						while kind == "\n" do
							v3 = v4
							kind = kind2
							x = x2
							v4 = next_token()
							kind2 = v4.kind
							x2 = v4.span.x
						end

						local right

						if kind == ")" then
							right = expect(")")
						end

						while kind == "\n" do
							v3 = v4
							kind = kind2
							x = x2
							v4 = next_token()
							kind2 = v4.kind
							x2 = v4.span.x
						end

						local left2

						if kind == "{" then
							left2 = expect("{")
						end

						local v14 = parse_block("}")

						while kind == "\n" do
							v3 = v4
							kind = kind2
							x = x2
							v4 = next_token()
							kind2 = v4.kind
							x2 = v4.span.x
						end

						local right2

						if kind == "}" then
							right2 = expect("}")
						end

						local x3 = elsekeyword.span.x
						local v17

						if right2 then
							v17 = right2.span.y
						else
							v17 = v14.span.y
						end

						local v16 = {
							elsekeyword = elsekeyword,
							keyword = keyword,
							condition = {
								left = left,
								right = right,
								value = v11
							},
							block = {
								left = left2,
								right = right2,
								value = v14
							},
							span = vector.create(x3, v17, 0)
						}
						table.insert(ifs, v16)
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
					else_keyword = expect("else")

					while kind == "\n" do
						v3 = v4
						kind = kind2
						x = x2
						v4 = next_token()
						kind2 = v4.kind
						x2 = v4.span.x
					end

					local left

					if kind == "{" then
						left = expect("{")
					end

					local v9 = parse_block("}")

					while kind == "\n" do
						v3 = v4
						kind = kind2
						x = x2
						v4 = next_token()
						kind2 = v4.kind
						x2 = v4.span.x
					end

					local right

					if kind == "}" then
						right = expect("}")
					end

					fallback = {
						left = left,
						right = right,
						value = v9
					}
				end

				local x3 = ifs[1].span.x
				local y

				if fallback and fallback.right then
					y = fallback.right.span.y
				elseif fallback then
					y = fallback.value.span.y
				else
					y = ifs[#ifs].span.y
				end

				return {
					kind = "if",
					ifs = ifs,
					else_keyword = else_keyword,
					fallback = fallback,
					span = vector.create(x3, y, 0)
				}
			end
		end
	end

	local function parse_while()
		local keyword = expect("while")

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		local left

		if kind == "(" then
			left = expect("(")
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		local v7

		if kind == "identifier" then
			v7 = parse_command()
		else
			v7 = parse_expression()
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		local right

		if kind == ")" then
			right = expect(")")
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		local left2

		if kind == "{" then
			left2 = expect("{")
		end

		local v10 = parse_block("}")

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		local right2

		if kind == "}" then
			right2 = expect("}")
		end

		local x3 = keyword.span.x
		local v13

		if right2 then
			v13 = right2.span.y
		else
			v13 = v10.span.y
		end

		return {
			kind = "while",
			keyword = keyword,
			expression = {
				left = left,
				right = right,
				value = v7
			},
			block = {
				left = left2,
				right = right2,
				value = v10
			},
			span = vector.create(x3, v13, 0)
		}
	end

	local function parse_for()
		local keyword = expect("for")

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		local left

		if kind == "(" then
			left = expect("(")
		end

		local v7 = parse_expression_or_command()

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		local right

		if kind == ")" then
			right = expect(")")
		end

		while kind == "\n" do
			v3 = v4
			kind = kind2
			x = x2
			v4 = next_token()
			kind2 = v4.kind
			x2 = v4.span.x
		end

		local call

		if kind == "|" then
			call = parse_function_body()
		end

		local x3 = keyword.span.x
		local y

		if call then
			y = call.span.y
		elseif right then
			y = right.span.y
		else
			y = v7.span.y
		end

		return {
			kind = "for",
			keyword = keyword,
			expression = {
				left = left,
				right = right,
				value = v7
			},
			call = call,
			span = vector.create(x3, y, 0)
		}
	end

	local function parse_return()
		local keyword = expect("return")
		local y = keyword.span.y
		local values = {}

		while kind ~= "}" and kind ~= "eof" do
			if #values > 0 then
				expect(",")
			end

			local v7 = parse_expression()
			table.insert(values, v7)
			y = v7.span.y
		end

		return {
			kind = "return",
			values = values,
			keyword = keyword,
			span = vector.create(keyword.span.x, y, 0)
		}
	end

	parse_block = function(p: string, p2: number?)
		local v5 = p2 or x
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
					local operator = expect("=")
					local right = parse_expression_or_command()
					table.insert(body, {
						kind = "assign",
						span = vector.create(left.span.x, right.span.y, 0),
						operator = operator,
						left = left,
						right = right
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
								local keyword = expect("break")
								last_statement = {
									kind = "break",
									span = keyword.span,
									keyword = keyword
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
									local keyword = expect("continue")
									last_statement = {
										kind = "continue",
										span = keyword.span,
										keyword = keyword
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
												if kind == "eof" then
													break
												end

												if kind == p then
													v6 = x
													break
												end

												report(`cannot parse {kind}`) -- equivalent call inferred; original call site unknown
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

local function generate(p: string)
	local src = p
	local thread = coroutine.create(parse)
	local get_result

	local function overwrite(str: string)
		src = str
		local buffer2 = buffer.fromstring(str)
		return get_result(coroutine.resume(thread, buffer2, yield))
	end

	get_result = function(flag: boolean, why)
		if flag == false then
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