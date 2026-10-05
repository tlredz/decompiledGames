local createVector = vector.create
require("./ast")

local function char(value: string)
	return (string.byte(value))
end

local function to_span(vector2: Vector3?, vector3: Vector3?, vector4: Vector3?, vector5: Vector3?, vector6: Vector3?, vector7: Vector3?, vector8: Vector3?, vector9: Vector3?)
	return (vector.create(
		vector2 and vector2.x or vector3 and vector3.x or vector4 and vector4.x or vector5 and vector5.x or vector6 and vector6.x or vector7 and vector7.x or vector8 and vector8.x or not vector9 and 0 or vector9.x or 0,
		vector9 and vector9.y or vector8 and vector8.y or vector7 and vector7.y or vector6 and vector6.y or vector5 and vector5.y or vector4 and vector4.y or vector3 and vector3.y or not vector2 and 0 or vector2.y or 0,
		vector2 and vector2.z or vector3 and vector3.z or vector4 and vector4.z or vector5 and vector5.z or vector6 and vector6.z or vector7 and vector7.z or vector8 and vector8.z or vector9 and vector9.z or 0
	))
end

local function parse(buf: buffer)
	local v = 0
	local count = 0
	local v2 = buffer.len(buf)
	local issues = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function peek()
		if v == v2 then
			return 0
		end

		return (buffer.readu8(buf, v))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function peek_2()
		if v2 <= v + 1 then
			return 0
		end

		return (buffer.readu8(buf, v + 1))
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

	-- equivalent calls inferred from this helper; original call sites unknown
	local function throw(formatted: string, vector2: Vector3)
		table.insert(issues, {
			why = `SyntaxError: {formatted}`,
			span = vector2
		})
	end

	local function panic(why: string?)
		if why then
			table.insert(issues, {
				why = why,
				span = createVector(0, 0, 0)
			})
		end

		error({
			result = nil,
			issues = issues
		})
	end

	local function eof(why: string)
		if v2 <= v then
			table.insert(issues, {
				why = why,
				span = vector.create(v, v, count)
			})
			error({
				result = nil,
				issues = issues
			}, 0)
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
		return p >= 97 and p <= 122 or (p >= 65 and p <= 90 or (p == 64 or p == 95))
	end

	local function string_backslash()
		local v4 = peek() -- equivalent call inferred; original call site unknown

		if v4 == 13 then
			if bump_peek() == 10 then
				bump() -- equivalent call inferred; original call site unknown
				count += 1
			end
		elseif v4 == 122 then
			bump() -- equivalent call inferred; original call site unknown

			while true do
				local v5 = peek() -- equivalent call inferred; original call site unknown

				if v5 ~= 32 and v5 ~= 9 and v5 ~= 13 then
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
		local v4 = peek() -- equivalent call inferred; original call site unknown
		local v5 = bump_peek() -- equivalent call inferred; original call site unknown

		while v5 ~= v4 and not eof("expected string to be finished at", v) do
			if v5 == 0 or v5 == 10 or v5 == 13 then
				return "error"
			end

			if v5 == 92 then
				bump() -- equivalent call inferred; original call site unknown
				string_backslash()
			else
				bump() -- equivalent call inferred; original call site unknown
			end

			v5 = peek()
		end

		bump() -- equivalent call inferred; original call site unknown
		return "string"
	end

	local function number()
		local v4 = v
		local v5 = 10
		local v6 = peek() -- equivalent call inferred; original call site unknown

		if v6 == 48 then
			v6 = bump_peek()

			if v6 == 120 or v6 == 88 then
				v6 = bump_peek()
				v5 = 16
			elseif v6 == 98 or v6 == 66 then
				v6 = bump_peek()
				v5 = 2
			end
		end

		while true do
			if is_digit(v6) or v6 == 46 or v6 == 95 then
				v6 = bump_peek()
			else
				if v6 == 101 or v6 == 69 then
					v6 = bump_peek()

					if v6 == 43 or v6 == 45 then
						bump() -- equivalent call inferred; original call site unknown

						if v == v2 then
							v6 = 0
						else
							v6 = buffer.readu8(buf, v)
						end
					end
				end

				while true do
					if is_digit(v6) or is_alpha(v6) or v6 == 95 then
						v6 = bump_peek()
					else
						local v9

						if v5 == 10 then
							v9 = buffer.readstring(buf, v4, v - v4)
						else
							v9 = buffer.readstring(buf, v4 + 2, v - v4 - 2)
						end

						if tonumber(string.gsub(v9, "_", ""), v5) then
							return "number"
						end

						return "error"
					end
				end
			end
		end
	end

	local function read_kind()
		local v4 = peek() -- equivalent call inferred; original call site unknown

		if v4 == 0 then
			return "eof"
		end

		if v4 == 61 then
			if bump_peek() ~= 61 then
				return "="
			end

			bump() -- equivalent call inferred; original call site unknown
			return "=="
		elseif v4 == 33 then
			if bump_peek() ~= 61 then
				return "!"
			end

			bump() -- equivalent call inferred; original call site unknown
			return "!="
		elseif v4 == 126 then
			if bump_peek() ~= 61 then
				return "error"
			end

			bump() -- equivalent call inferred; original call site unknown
			return "~="
		elseif v4 == 62 then
			if bump_peek() ~= 61 then
				return ">"
			end

			bump() -- equivalent call inferred; original call site unknown
			return ">="
		elseif v4 == 60 then
			if bump_peek() ~= 61 then
				return "<"
			end

			bump() -- equivalent call inferred; original call site unknown
			return "<="
		else
			if v4 == 42 then
				bump() -- equivalent call inferred; original call site unknown
				return "*"
			end

			if v4 == 47 then
				if bump_peek() ~= 47 then
					return "/"
				end

				bump() -- equivalent call inferred; original call site unknown
				return "//"
			else
				if v4 == 94 then
					bump() -- equivalent call inferred; original call site unknown
					return "^"
				elseif v4 == 37 then
					bump() -- equivalent call inferred; original call site unknown
					return "%"
				elseif v4 == 45 then
					bump() -- equivalent call inferred; original call site unknown
					return "-"
				elseif v4 == 43 then
					bump() -- equivalent call inferred; original call site unknown
					return "+"
				elseif v4 == 40 then
					bump() -- equivalent call inferred; original call site unknown
					return "("
				elseif v4 == 41 then
					bump() -- equivalent call inferred; original call site unknown
					return ")"
				elseif v4 == 36 then
					bump() -- equivalent call inferred; original call site unknown
					return "$"
				elseif v4 == 44 then
					bump() -- equivalent call inferred; original call site unknown
					return ","
				elseif v4 == 38 then
					bump() -- equivalent call inferred; original call site unknown
					return "&"
				elseif v4 == 123 then
					bump() -- equivalent call inferred; original call site unknown
					return "{"
				elseif v4 == 125 then
					bump() -- equivalent call inferred; original call site unknown
					return "}"
				elseif v4 == 91 then
					bump() -- equivalent call inferred; original call site unknown
					return "["
				elseif v4 == 93 then
					bump() -- equivalent call inferred; original call site unknown
					return "]"
				elseif v4 == 124 then
					bump() -- equivalent call inferred; original call site unknown
					return "|"
				elseif v4 == 10 then
					bump() -- equivalent call inferred; original call site unknown
					return "\n"
				elseif v4 == 59 then
					bump() -- equivalent call inferred; original call site unknown
					return ";"
				end

				if is_digit(v4) then
					return (number())
				end

				if is_alpha(v4) then
					local v6 = v

					while true do
						local v7 = bump_peek() -- equivalent call inferred; original call site unknown

						if is_alpha(v7) or is_digit(v7) or v7 == 45 or v7 == 58 then
							continue
						end

						local v9 = buffer.readstring(buf, v6, v - v6)

						if v9 == "true" then
							return "true"
						elseif v9 == "false" then
							return "false"
						elseif v9 == "nil" then
							return "nil"
						elseif v9 == "if" then
							return "if"
						elseif v9 == "else" then
							return "else"
						elseif v9 == "elseif" then
							return "elseif"
						elseif v9 == "while" then
							return "while"
						elseif v9 == "for" then
							return "for"
						elseif v9 == "return" then
							return "return"
						elseif v9 == "break" then
							return "break"
						elseif v9 == "continue" then
							return "continue"
						elseif v9 == "and" then
							return "and"
						elseif v9 == "or" then
							return "or"
						end

						return "identifier"
					end
				else
					if v4 == 34 or v4 == 39 then
						return (quoted_string())
					end

					if v4 == 46 then
						local v6 = peek_2() -- equivalent call inferred; original call site unknown

						if is_digit(v6) then
							return (number())
						end
					end

					if v4 == 46 then
						if bump_peek() ~= 46 then
							return "."
						end

						bump() -- equivalent call inferred; original call site unknown
						return ".."
					elseif is_whitespace(v4) then
						bump() -- equivalent call inferred; original call site unknown
						return "whitespace"
					else
						bump() -- equivalent call inferred; original call site unknown
						return "error"
					end
				end
			end
		end
	end

	local function next_token()
		local v4 = v
		local v5 = count
		local kind3 = read_kind()

		while kind3 == "whitespace" or kind3 == "comment" do
			v4 = v
			v5 = count
			kind3 = read_kind()
		end

		if kind3 == "error" then
			throw(`could not parse {buffer.readstring(buf, v4, v - v4)} into a token`, vector.create(v4, v, v5)) -- equivalent call inferred; original call site unknown
		end

		return {
			kind = kind3,
			text = buffer.readstring(buf, v4, v - v4),
			span = vector.create(v4, v, v5)
		}
	end

	local v4 = next_token()
	local kind = v4.kind
	local x = v4.span.x
	local v5 = next_token()
	local kind2 = v5.kind
	local x2 = v5.span.x

	local function consume()
		local v6 = v4
		local v7 = kind
		v4 = v5
		kind = kind2
		x = x2
		v5 = next_token()
		kind2 = v5.kind
		x2 = v5.span.x
		return v6, v7
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function skip_current()
		while kind == "\n" do
			v4 = v5
			kind = kind2
			x = x2
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function current_is(p)
		skip_current() -- equivalent call inferred; original call site unknown
		return kind == p
	end

	local function lookahead_is(p)
		while kind2 == "\n" do
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
		end

		return kind2 == p
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function display(p)
		local kind3 = p.kind

		if kind3 == "identifier" or kind3 == "number" or kind3 == "string" then
			return p.text
		end

		if p.kind == "error" then
			return "error '" .. p.text .. "'"
		end

		return "'" .. kind3 .. "'"
	end

	local function expected_but(p: string)
		local v8 = display(v4) -- equivalent call inferred; original call site unknown
		throw(`expected {p}, but got {v8} of {kind} instead`, v4.span) -- equivalent call inferred; original call site unknown
		v4 = v5
		kind = kind2
		x = x2
		v5 = next_token()
		kind2 = v5.kind
		x2 = v5.span.x
		return nil
	end

	local function expect(p)
		skip_current() -- equivalent call inferred; original call site unknown

		if kind == p then
			local v6 = v4
			v4 = v5
			kind = kind2
			x = x2
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
			return v6
		else
			local v8 = display(v4) -- equivalent call inferred; original call site unknown
			throw(`expected {p}, but got {v8} of {kind} instead`, v4.span) -- equivalent call inferred; original call site unknown
			v4 = v5
			kind = kind2
			x = x2
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
			return false
		end
	end

	local function expect_fatal(kind3)
		skip_current() -- equivalent call inferred; original call site unknown

		if kind == kind3 then
			local v6 = v4
			v4 = v5
			kind = kind2
			x = x2
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
			return v6
		else
			local v7 = display({
				kind = kind3
			}) -- equivalent call inferred; original call site unknown
			local v10 = display(v4) -- equivalent call inferred; original call site unknown
			throw(`expected {v7}, but got {v10} of {kind} instead`, v4.span) -- equivalent call inferred; original call site unknown
			v4 = v5
			kind = kind2
			x = x2
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
			return panic()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function is_delimiter()
		skip_current() -- equivalent call inferred; original call site unknown
		return kind == "}" or kind == "]" or kind == ")" or kind == ";" or kind == "\n" or kind == "eof"
	end

	local parse_last_statement
	local parse_simple_expression
	local parse_expression
	local parse_expression_command
	local parse_if_node
	local parse_while_node
	local parse_for_node
	local parse_assign
	local parse_command
	local parse_lambda
	local parse_var
	local parse_vector

	local function separated(callback, p)
		local v6, v7, v8, v9, v10, v11, kind3, result, separator, text, y
		local controlFlowState = 35

		while true do
			if controlFlowState == 0 then
				v4 = v5
				kind = kind2
				x = x2
				v5 = next_token()
				kind2 = v5.kind
				x2 = v5.span.x
				controlFlowState = 2
				continue
			elseif controlFlowState == 1 then
				if kind == "}" or kind == "]" or kind == ")" or kind == ";" or kind == "\n" or kind == "eof" then
					controlFlowState = 17
				else
					controlFlowState = 5
				end

				continue
			elseif controlFlowState == 2 then
				if kind == "\n" then
					controlFlowState = 0
				else
					controlFlowState = 1
				end

				continue
			else
				if controlFlowState == 3 then
					controlFlowState = 8
					continue
				end

				if controlFlowState == 4 then
					controlFlowState = 8
					continue
				end

				if controlFlowState == 5 then
					if p then
						controlFlowState = 11
					else
						controlFlowState = 4
					end

					continue
				else
					if controlFlowState == 6 then
						return result
					end

					if controlFlowState == 7 then
						if kind == "\n" then
							controlFlowState = 9
						else
							controlFlowState = 10
						end

						continue
					elseif controlFlowState == 8 then
						if kind == "\n" then
							controlFlowState = 12
						else
							controlFlowState = 13
						end

						continue
					elseif controlFlowState == 9 then
						v4 = v5
						kind = kind2
						x = x2
						v5 = next_token()
						kind2 = v5.kind
						x2 = v5.span.x
						controlFlowState = 7
						continue
					elseif controlFlowState == 10 then
						if kind == p then
							controlFlowState = 24
						else
							controlFlowState = 3
						end

						continue
					else
						if controlFlowState == 11 then
							controlFlowState = 7
							continue
						end

						if controlFlowState == 12 then
							v4 = v5
							kind = kind2
							x = x2
							v5 = next_token()
							kind2 = v5.kind
							x2 = v5.span.x
							controlFlowState = 8
							continue
						elseif controlFlowState == 13 then
							v6 = x
							v7 = count
							v8 = callback()
							controlFlowState = 16
							continue
						elseif controlFlowState == 14 then
							v4 = v5
							kind = kind2
							x = x2
							v5 = next_token()
							kind2 = v5.kind
							x2 = v5.span.x
							controlFlowState = 16
							continue
						elseif controlFlowState == 15 then
							if kind == "," then
								controlFlowState = 23
							else
								controlFlowState = 22
							end

							continue
						elseif controlFlowState == 16 then
							if kind == "\n" then
								controlFlowState = 14
							else
								controlFlowState = 15
							end

							continue
						else
							if controlFlowState == 17 then
								controlFlowState = 6
								continue
							end

							if controlFlowState == 18 then
								if kind == "\n" then
									controlFlowState = 20
								else
									controlFlowState = 21
								end

								continue
							elseif controlFlowState == 19 then
								y = v6
								controlFlowState = 34
								continue
							elseif controlFlowState == 20 then
								v4 = v5
								kind = kind2
								x = x2
								v5 = next_token()
								kind2 = v5.kind
								x2 = v5.span.x
								controlFlowState = 18
								continue
							elseif controlFlowState == 21 then
								if kind == "," then
									controlFlowState = 25
								else
									controlFlowState = 26
								end

								continue
							elseif controlFlowState == 22 then
								separator = nil
								controlFlowState = 27
								continue
							else
								if controlFlowState == 23 then
									controlFlowState = 18
									continue
								end

								if controlFlowState == 24 then
									controlFlowState = 6
									continue
								end

								if controlFlowState == 25 then
									separator = v4
									v4 = v5
									kind = kind2
									x = x2
									v5 = next_token()
									kind2 = v5.kind
									x2 = v5.span.x
									controlFlowState = 27
									continue
								elseif controlFlowState == 26 then
									v10 = "expected ,, but got %* of %* instead"
									v11 = v4
									kind3 = v11.kind

									if kind3 == "identifier" or kind3 == "number" or kind3 == "string" then
										controlFlowState = 28
									else
										controlFlowState = 29
									end

									continue
								elseif controlFlowState == 27 then
									v9 = {
										value = v8,
										separator = separator,
										span = 0
									}

									if separator then
										controlFlowState = 33
									else
										controlFlowState = 19
									end

									continue
								elseif controlFlowState == 28 then
									text = v11.text
									controlFlowState = 30
									continue
								elseif controlFlowState == 29 then
									if v11.kind == "error" then
										controlFlowState = 31
									else
										controlFlowState = 32
									end

									continue
								elseif controlFlowState == 30 then
									throw(v10:format(text, kind), v4.span) -- equivalent call inferred; original call site unknown
									v4 = v5
									kind = kind2
									x = x2
									v5 = next_token()
									kind2 = v5.kind
									x2 = v5.span.x
									separator = false
									controlFlowState = 27
									continue
								else
									if controlFlowState == 31 then
										text = "error '" .. v11.text .. "'"
										controlFlowState = 30
									elseif controlFlowState == 32 then
										text = "'" .. kind3 .. "'"
										controlFlowState = 30
									elseif controlFlowState == 33 then
										y = separator.span.y or v6
										controlFlowState = 34
									else
										if controlFlowState == 34 then
											v9.span = vector.create(v6, y, v7)
											table.insert(result, v9)
										else
											if controlFlowState ~= 35 then
												break
											end

											result = {}
										end

										controlFlowState = 2
									end

									continue
								end
							end
						end
					end
				end
			end
		end
	end

	local function parse_block_node()
		local v6, v7, v8, kind3, body, text
		local controlFlowState = 45

		while true do
			if controlFlowState == 0 then
				v4 = v5
				kind = kind2
				x = x2
				v5 = next_token()
				kind2 = v5.kind
				x2 = v5.span.x
				controlFlowState = 2
				continue
			elseif controlFlowState == 1 then
				if kind == "eof" then
					controlFlowState = 8
				else
					controlFlowState = 33
				end

				continue
			elseif controlFlowState == 2 then
				if kind == "\n" then
					controlFlowState = 0
				else
					controlFlowState = 1
				end

				continue
			else
				if controlFlowState == 3 then
					controlFlowState = 10
					continue
				end

				if controlFlowState == 4 then
					if kind == "\n" then
						controlFlowState = 6
					else
						controlFlowState = 7
					end

					continue
				elseif controlFlowState == 5 then
					if kind == "\n" then
						controlFlowState = 11
					else
						controlFlowState = 12
					end

					continue
				elseif controlFlowState == 6 then
					v4 = v5
					kind = kind2
					x = x2
					v5 = next_token()
					kind2 = v5.kind
					x2 = v5.span.x
					controlFlowState = 4
					continue
				elseif controlFlowState == 7 then
					if kind == "}" or kind == "]" or kind == ")" or kind == ";" or kind == "\n" or kind == "eof" then
						controlFlowState = 15
					else
						controlFlowState = 9
					end

					continue
				else
					if controlFlowState == 8 then
						controlFlowState = 5
						continue
					end

					if controlFlowState == 9 then
						controlFlowState = 10
						continue
					end

					if controlFlowState == 10 then
						if kind == ";" then
							controlFlowState = 17
						else
							controlFlowState = 14
						end

						continue
					elseif controlFlowState == 11 then
						v4 = v5
						kind = kind2
						x = x2
						v5 = next_token()
						kind2 = v5.kind
						x2 = v5.span.x
						controlFlowState = 5
						continue
					elseif controlFlowState == 12 then
						if kind == ";" then
							controlFlowState = 3
						else
							controlFlowState = 36
						end

						continue
					else
						if controlFlowState == 13 then
							controlFlowState = 30
							continue
						end

						if controlFlowState == 14 then
							controlFlowState = 18
							continue
						end

						if controlFlowState == 15 then
							controlFlowState = 5
							continue
						end

						if controlFlowState == 16 then
							return {
								body = body,
								last_statement = parse_last_statement(),
								span = vector.create(v6, x)
							}
						end

						if controlFlowState == 17 then
							v4 = v5
							kind = kind2
							x = x2
							v5 = next_token()
							kind2 = v5.kind
							x2 = v5.span.x
							controlFlowState = 10
							continue
						elseif controlFlowState == 18 then
							if kind == "\n" then
								controlFlowState = 19
							else
								controlFlowState = 20
							end

							continue
						elseif controlFlowState == 19 then
							v4 = v5
							kind = kind2
							x = x2
							v5 = next_token()
							kind2 = v5.kind
							x2 = v5.span.x
							controlFlowState = 18
							continue
						elseif controlFlowState == 20 then
							if kind == "if" then
								controlFlowState = 21
							else
								controlFlowState = 22
							end

							continue
						elseif controlFlowState == 21 then
							table.insert(body, parse_if_node())
							controlFlowState = 23
							continue
						elseif controlFlowState == 22 then
							if kind == "while" then
								controlFlowState = 24
							else
								controlFlowState = 25
							end

							continue
						else
							if controlFlowState == 23 then
								controlFlowState = 2
								continue
							end

							if controlFlowState == 24 then
								table.insert(body, parse_while_node())
								controlFlowState = 23
								continue
							elseif controlFlowState == 25 then
								if kind == "for" then
									controlFlowState = 26
								else
									controlFlowState = 27
								end

								continue
							elseif controlFlowState == 26 then
								table.insert(body, parse_for_node())
								controlFlowState = 23
								continue
							elseif controlFlowState == 27 then
								if kind2 == "=" then
									controlFlowState = 28
								else
									controlFlowState = 29
								end

								continue
							elseif controlFlowState == 28 then
								table.insert(body, parse_assign())
								controlFlowState = 23
								continue
							elseif controlFlowState == 29 then
								if kind == "break" or kind == "return" or kind == "continue" then
									controlFlowState = 35
								else
									controlFlowState = 13
								end

								continue
							elseif controlFlowState == 30 then
								if kind == "\n" then
									controlFlowState = 31
								else
									controlFlowState = 32
								end

								continue
							elseif controlFlowState == 31 then
								v4 = v5
								kind = kind2
								x = x2
								v5 = next_token()
								kind2 = v5.kind
								x2 = v5.span.x
								controlFlowState = 30
								continue
							elseif controlFlowState == 32 then
								if kind == "}" or kind == "]" or kind == ")" or kind == ";" or kind == "\n" or kind == "eof" or kind == "eof" then
									controlFlowState = 34
								else
									controlFlowState = 37
								end

								continue
							else
								if controlFlowState == 33 then
									controlFlowState = 4
									continue
								end

								if controlFlowState == 34 then
									controlFlowState = 16
									continue
								end

								if controlFlowState == 35 then
									controlFlowState = 16
									continue
								end

								if controlFlowState == 36 then
									controlFlowState = 16
									continue
								end

								if controlFlowState == 37 then
									if kind == "identifier" or kind == "$" then
										controlFlowState = 38
									else
										controlFlowState = 39
									end

									continue
								elseif controlFlowState == 38 then
									table.insert(body, parse_command())
									controlFlowState = 23
									continue
								elseif controlFlowState == 39 then
									v7 = "expected statement, but got %* of %* instead"
									v8 = v4
									kind3 = v8.kind

									if kind3 == "identifier" or kind3 == "number" or kind3 == "string" then
										controlFlowState = 40
									else
										controlFlowState = 41
									end

									continue
								elseif controlFlowState == 40 then
									text = v8.text
									controlFlowState = 42
									continue
								elseif controlFlowState == 41 then
									if v8.kind == "error" then
										controlFlowState = 43
									else
										controlFlowState = 44
									end

									continue
								elseif controlFlowState == 42 then
									throw(v7:format(text, kind), v4.span) -- equivalent call inferred; original call site unknown
									v4 = v5
									kind = kind2
									x = x2
									v5 = next_token()
									kind2 = v5.kind
									x2 = v5.span.x
									controlFlowState = 23
									continue
								else
									if controlFlowState == 43 then
										text = "error '" .. v8.text .. "'"
										controlFlowState = 42
									elseif controlFlowState == 44 then
										text = "'" .. kind3 .. "'"
										controlFlowState = 42
									else
										if controlFlowState ~= 45 then
											break
										end

										v6 = x
										body = {}
										controlFlowState = 2
									end

									continue
								end
							end
						end
					end
				end
			end
		end
	end

	local function parse_statement_node()
		if current_is("if") then
			return parse_if_node()
		end

		if current_is("while") then
			return parse_while_node()
		end

		if current_is("for") then
			return parse_for_node()
		end

		if not current_is("identifier") then
			return parse_command()
		end

		while kind2 == "\n" do
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
		end

		local v6

		if kind2 == "=" then
			v6 = true
		else
			v6 = false
		end

		if v6 then
			return parse_assign()
		end

		return parse_command()
	end

	parse_last_statement = function()
		if current_is("continue") then
			local token = expect_fatal("continue")
			return {
				kind = "continue",
				token = token,
				span = token.span
			}
		end

		if current_is("break") then
			local token = expect_fatal("break")
			return {
				kind = "break",
				token = token,
				span = token.span
			}
		end

		if not current_is("return") then
			return nil
		end

		local token2 = expect_fatal("return")
		return {
			kind = "return",
			token = token2,
			values = separated(parse_expression_command),
			span = token2.span
		}
	end

	local function parse_delimiter(p, p2, callback)
		skip_current() -- equivalent call inferred; original call site unknown
		local left

		if kind == p then
			left = v4
			v4 = v5
			kind = kind2
			x = x2
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
		else
			local v9 = display(v4) -- equivalent call inferred; original call site unknown
			throw(`expected {p}, but got {v9} of {kind} instead`, v4.span) -- equivalent call inferred; original call site unknown
			v4 = v5
			kind = kind2
			x = x2
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
			left = false
		end

		local v7 = callback()
		skip_current() -- equivalent call inferred; original call site unknown
		local v8

		if kind == p2 then
			v8 = v4
			v4 = v5
			kind = kind2
			x = x2
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
		else
			local v11 = display(v4) -- equivalent call inferred; original call site unknown
			throw(`expected {p2}, but got {v11} of {kind} instead`, v4.span) -- equivalent call inferred; original call site unknown
			v4 = v5
			kind = kind2
			x = x2
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
			v8 = false
		end

		if left then
			return {
				left = left,
				value = v7,
				right = v8 or nil
			}
		end

		return false
	end

	local function parse_function_body()
		local arguments = parse_delimiter("|", "|", function()
			return (separated(function()
				skip_current() -- equivalent call inferred; original call site unknown

				if kind == "identifier" then
					local v7 = v4
					v4 = v5
					kind = kind2
					x = x2
					v5 = next_token()
					kind2 = v5.kind
					x2 = v5.span.x
					return v7
				else
					local v9 = display(v4) -- equivalent call inferred; original call site unknown
					throw(`expected identifier, but got {v9} of {kind} instead`, v4.span) -- equivalent call inferred; original call site unknown
					v4 = v5
					kind = kind2
					x = x2
					v5 = next_token()
					kind2 = v5.kind
					x2 = v5.span.x
					return false
				end
			end, "|"))
		end)
		local v7 = parse_delimiter("{", "}", parse_block_node)

		if not arguments then
			return panic("no arguments obtained")
		end

		local v8 = {
			arguments = arguments,
			block = v7 or nil,
			span = 0
		}
		local span = arguments and arguments.left.span
		local span2 = arguments and arguments.right and arguments.right.span
		local v10

		if v7 and v7.left then
			v10 = v7.left.span or nil
		end

		v8.span = to_span(span, span2, v10, v7 and v7.right and v7.right.span or nil)
		return v8
	end

	local function parse_if_branch()
		local v6 = parse_delimiter("(", ")", parse_expression_command)
		local v7 = parse_delimiter("{", "}", parse_block_node)
		local v8 = {
			condition = v6 or nil,
			block = v7 or nil,
			span = 0
		}
		local span

		if v6 and v6.left then
			span = v6.left.span or nil
		end

		local span2

		if v6 and v6.value then
			span2 = v6.value.span or nil
		end

		local span3 = v6 and v6.right and v6.right.span or nil
		local span4

		if v7 and v7.left then
			span4 = v7.left.span or nil
		end

		local v10

		if v7 and v7.value then
			v10 = v7.value.span or nil
		end

		v8.span = to_span(span, span2, span3, span4, v10, v7 and v7.right and v7.right.span or nil)
		return v8
	end

	local function parse_elseif_branch()
		local ifelse = expect_fatal("elseif")
		local branch = parse_if_branch()
		local span = ifelse.span
		local span2 = branch.span
		return {
			ifelse = ifelse,
			branch = branch,
			span = vector.create(
				span and span.x or not span2 and 0 or span2.x or 0,
				span2 and span2.y or not span and 0 or span.y or 0,
				span and span.z or span2 and span2.z or 0
			)
		}
	end

	parse_if_node = function()
		local token = expect_fatal("if")
		local first_branch = parse_if_branch()
		local branches = {}

		while true do
			if kind == "\n" then
				v4 = v5
				kind = kind2
				x = x2
				v5 = next_token()
				kind2 = v5.kind
				x2 = v5.span.x
			elseif kind == "elseif" then
				local ifelse = expect_fatal("elseif")
				local branch = parse_if_branch()
				local span = ifelse.span
				local span2 = branch.span
				local v11 = {
					ifelse = ifelse,
					branch = branch,
					span = vector.create(
						span and span.x or not span2 and 0 or span2.x or 0,
						span2 and span2.y or not span and 0 or span.y or 0,
						span and span.z or span2 and span2.z or 0
					)
				}
				table.insert(branches, v11)
			else
				local else_branch = nil
				skip_current() -- equivalent call inferred; original call site unknown

				if kind == "else" then
					local token2 = expect_fatal("else")
					local v11 = parse_delimiter("{", "}", parse_block_node)
					else_branch = {
						token = token2,
						block = v11 or nil,
						span = 0
					}
					local span = token2.span
					local span2

					if v11 and v11.left then
						span2 = v11.left.span or nil
					end

					local span3

					if v11 and v11.value then
						span3 = v11.value.span or nil
					end

					local span4 = v11 and v11.right and v11.right.span or nil
					else_branch.span = vector.create(
						span and span.x or span2 and span2.x or span3 and span3.x or not span4 and 0 or span4.x or 0,
						span4 and span4.y or span3 and span3.y or span2 and span2.y or not span and 0 or span.y or 0,
						span and span.z or span2 and span2.z or span3 and span3.z or span4 and span4.z or 0
					)
				end

				local span = token.span
				local span2 = first_branch.span
				local span3

				if #branches > 0 then
					span3 = branches[#branches].span
				end

				local span4 = else_branch and else_branch.span
				return {
					kind = "if",
					token = token,
					first_branch = first_branch,
					branches = branches,
					else_branch = else_branch,
					span = vector.create(
						span and span.x or span2 and span2.x or span3 and span3.x or not span4 and 0 or span4.x or 0,
						span4 and span4.y or span3 and span3.y or span2 and span2.y or not span and 0 or span.y or 0,
						span and span.z or span2 and span2.z or span3 and span3.z or span4 and span4.z or 0
					)
				}
			end
		end
	end

	parse_while_node = function()
		local token = expect_fatal("while")
		local v7 = parse_delimiter("(", ")", parse_expression_command)
		local v8 = parse_delimiter("{", "}", parse_block_node)
		local v9 = {
			kind = "while",
			token = token,
			condition = v7 or nil,
			block = v8 or nil,
			span = 0
		}
		local span = token and token.span
		local span2

		if v7 and v7.left then
			span2 = v7.left.span or nil
		end

		local span3

		if v7 and v7.value then
			span3 = v7.value.span or nil
		end

		local span4 = v7 and v7.right and v7.right.span or nil
		local span5

		if v8 and v8.left then
			span5 = v8.left.span or nil
		end

		local span6

		if v8 and v8.value then
			span6 = v8.value.span or nil
		end

		local span7 = v8 and v8.right and v8.right.span or nil
		v9.span = vector.create(
			span and span.x or span2 and span2.x or span3 and span3.x or span4 and span4.x or span5 and span5.x or span6 and span6.x or not span7 and 0 or span7.x or 0,
			span7 and span7.y or span6 and span6.y or span5 and span5.y or span4 and span4.y or span3 and span3.y or span2 and span2.y or not span and 0 or span.y or 0,
			span and span.z or span2 and span2.z or span3 and span3.z or span4 and span4.z or span5 and span5.z or span6 and span6.z or span7 and span7.z or 0
		)
		return v9
	end

	parse_assign = function()
		local identifier = expect_fatal("identifier")
		local equals = expect_fatal("=")
		local v8 = parse_expression_command()
		local span = identifier and identifier.span
		local span2 = equals and equals.span
		local span3 = v8 and v8.span
		return {
			kind = "assign",
			identifier = identifier,
			equals = equals,
			value = v8 or nil,
			span = vector.create(
				span and span.x or span2 and span2.x or not span3 and 0 or span3.x or 0,
				span3 and span3.y or span2 and span2.y or not span and 0 or span.y or 0,
				span and span.z or span2 and span2.z or span3 and span3.z or 0
			)
		}
	end

	parse_for_node = function()
		local token = expect_fatal("for")
		local v7 = parse_delimiter("(", ")", parse_expression_command)
		local body = parse_expression_command()
		local v9 = {
			kind = "for",
			token = token,
			expression = v7 or nil,
			body = body,
			span = 0
		}
		local span = token.span
		local span2

		if v7 and v7.left then
			span2 = v7.left.span or nil
		end

		local span3

		if v7 and v7.value then
			span3 = v7.value.span or nil
		end

		local span4 = v7 and v7.right and v7.right.span or nil
		local span5 = body and body.span or nil
		v9.span = vector.create(
			span and span.x or span2 and span2.x or span3 and span3.x or span4 and span4.x or not span5 and 0 or span5.x or 0,
			span5 and span5.y or span4 and span4.y or span3 and span3.y or span2 and span2.y or not span and 0 or span.y or 0,
			span and span.z or span2 and span2.z or span3 and span3.z or span4 and span4.z or span5 and span5.z or 0
		)
		return v9
	end

	parse_command = function()
		local var = parse_var()
		local arguments = {}

		while kind ~= "\n" do
			skip_current() -- equivalent call inferred; original call site unknown

			if kind == "if" then
				break
			end

			skip_current() -- equivalent call inferred; original call site unknown

			if kind == "else" then
				break
			end

			skip_current() -- equivalent call inferred; original call site unknown

			if kind == "elseif" then
				break
			end

			skip_current() -- equivalent call inferred; original call site unknown

			if kind == "while" then
				break
			end

			skip_current() -- equivalent call inferred; original call site unknown

			if kind == "for" then
				break
			end

			skip_current() -- equivalent call inferred; original call site unknown

			if kind == "return" then
				break
			end

			skip_current() -- equivalent call inferred; original call site unknown

			if kind == "break" then
				break
			end

			skip_current() -- equivalent call inferred; original call site unknown

			if kind == "continue" or is_delimiter() then
				break
			end

			skip_current() -- equivalent call inferred; original call site unknown

			if kind == "," then
				break
			end

			skip_current() -- equivalent call inferred; original call site unknown

			if kind == "identifier" and kind2 ~= "." then
				local token = expect_fatal("identifier")
				table.insert(arguments, {
					kind = "string",
					token = token,
					span = token.span
				})
			else
				table.insert(arguments, parse_simple_expression())
			end
		end

		local span = var.span
		local span2

		if #arguments > 0 then
			span2 = arguments[#arguments].span
		end

		skip_current() -- equivalent call inferred; original call site unknown
		local span3

		if kind == "eof" then
			local v9 = v4
			v4 = v5
			kind = kind2
			x = x2
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
			span3 = v9.span
		end

		return {
			kind = "command",
			var = var,
			arguments = arguments,
			span = vector.create(
				span and span.x or span2 and span2.x or not span3 and 0 or span3.x or 0,
				span3 and span3.y or span2 and span2.y or not span and 0 or span.y or 0,
				span and span.z or span2 and span2.z or span3 and span3.z or 0
			)
		}
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function parse_tablefield_nokey()
		local v6 = parse_expression_command()
		return {
			kind = "nokey",
			value = v6,
			span = v6 and v6.span or createVector(0, 0, 0)
		}
	end

	local function parse_tablefield_namekey()
		local name = expect_fatal("identifier")
		local equals = expect_fatal("=")
		local v8 = parse_expression_command()
		local span = name.span
		local span2 = equals.span
		local span3 = v8 and v8.span
		return {
			kind = "name_key",
			name = name,
			equals = equals,
			value = v8,
			span = vector.create(
				span and span.x or span2 and span2.x or not span3 and 0 or span3.x or 0,
				span3 and span3.y or span2 and span2.y or not span and 0 or span.y or 0,
				span and span.z or span2 and span2.z or span3 and span3.z or 0
			)
		}
	end

	local function parse_tablefield_expressionkey()
		local left = expect_fatal("[")
		local v7 = parse_expression_command()
		skip_current() -- equivalent call inferred; original call site unknown

		if kind == "]" then
			while kind2 == "\n" do
				v5 = next_token()
				kind2 = v5.kind
				x2 = v5.span.x
			end

			if kind2 == "=" then
				local v8 = {
					left = left,
					value = v7,
					right = expect_fatal("]")
				}
				skip_current() -- equivalent call inferred; original call site unknown
				local v9

				if kind == "=" then
					v9 = v4
					v4 = v5
					kind = kind2
					x = x2
					v5 = next_token()
					kind2 = v5.kind
					x2 = v5.span.x
				else
					local v12 = display(v4) -- equivalent call inferred; original call site unknown
					throw(`expected =, but got {v12} of {kind} instead`, v4.span) -- equivalent call inferred; original call site unknown
					v4 = v5
					kind = kind2
					x = x2
					v5 = next_token()
					kind2 = v5.kind
					x2 = v5.span.x
					v9 = false
				end

				local v10 = parse_expression_command()
				local v11 = {
					kind = "expression_key",
					key = v8 or nil,
					equals = v9 or nil,
					value = v10,
					span = 0
				}
				local span

				if v8 and v8.left then
					span = v8.left.span or nil
				end

				local span2

				if v8 and v8.value then
					span2 = v8.value.span or nil
				end

				local span3 = v8 and v8.right and v8.right.span or nil
				local span4 = v9 and v9.span or nil
				local span5 = v10 and v10.span
				v11.span = vector.create(
					span and span.x or span2 and span2.x or span3 and span3.x or span4 and span4.x or not span5 and 0 or span5.x or 0,
					span5 and span5.y or span4 and span4.y or span3 and span3.y or span2 and span2.y or not span and 0 or span.y or 0,
					span and span.z or span2 and span2.z or span3 and span3.z or span4 and span4.z or span5 and span5.z or 0
				)
				return v11
			end
		end

		local separator = expect_fatal(",")
		local span = v7 and v7.span
		local span2 = separator.span
		local v10 = {
			{
				value = v7,
				separator = separator,
				span = vector.create(
					span and span.x or not span2 and 0 or span2.x or 0,
					span2 and span2.y or not span and 0 or span.y or 0,
					span and span.z or span2 and span2.z or 0
				)
			}
		}

		while true do
			if kind == "\n" then
				v4 = v5
				kind = kind2
				x = x2
				v5 = next_token()
				kind2 = v5.kind
				x2 = v5.span.x
			else
				if kind ~= "}" and kind ~= "]" and kind ~= ")" and kind ~= ";" and kind ~= "\n" and kind ~= "eof" then
					skip_current() -- equivalent call inferred; original call site unknown
					local v11 = x
					local v12 = parse_expression_command()
					skip_current() -- equivalent call inferred; original call site unknown

					if kind == "," then
						local separator2 = expect_fatal(",")
						table.insert(v10, {
							value = v12,
							separator = separator2,
							span = vector.create(v11, separator2.span.y)
						})
						continue
					end
				end

				skip_current() -- equivalent call inferred; original call site unknown
				local v11

				if kind == "]" then
					v11 = v4
					v4 = v5
					kind = kind2
					x = x2
					v5 = next_token()
					kind2 = v5.kind
					x2 = v5.span.x
				else
					local v14 = display(v4) -- equivalent call inferred; original call site unknown
					throw(`expected ], but got {v14} of {kind} instead`, v4.span) -- equivalent call inferred; original call site unknown
					v4 = v5
					kind = kind2
					x = x2
					v5 = next_token()
					kind2 = v5.kind
					x2 = v5.span.x
					v11 = false
				end

				local span3 = left.span
				local span4 = v7 and v7.span or nil
				local span5 = v10[#v10] and v10[#v10].span or nil
				local span6 = v11 and v11.span or nil
				local v12 = {
					kind = "vector",
					contents = {
						left = left,
						right = v11 or nil,
						value = v10
					},
					span = vector.create(
						span3 and span3.x or span4 and span4.x or span5 and span5.x or not span6 and 0 or span6.x or 0,
						span6 and span6.y or span5 and span5.y or span4 and span4.y or not span3 and 0 or span3.y or 0,
						span3 and span3.z or span4 and span4.z or span5 and span5.z or span6 and span6.z or 0
					)
				}
				return {
					kind = "nokey",
					value = v12,
					span = v12.span
				}
			end
		end
	end

	local function parse_tablefield()
		skip_current() -- equivalent call inferred; original call site unknown

		if kind == "identifier" then
			while kind2 == "\n" do
				v5 = next_token()
				kind2 = v5.kind
				x2 = v5.span.x
			end

			if kind2 == "=" then
				return (parse_tablefield_namekey())
			end
		end

		skip_current() -- equivalent call inferred; original call site unknown

		if kind == "[" then
			return (parse_tablefield_expressionkey())
		end

		return parse_tablefield_nokey()
	end

	local function parse_table()
		local values = parse_delimiter("{", "}", function()
			return (separated(parse_tablefield))
		end)

		if not values then
			return panic("no table")
		end

		local span = values.left and values.left.span
		local span2 = values.value and values.value[1] and values.value[1].span
		local span3 = values.value and values.value[#values.value] and values.value[#values.value].span
		local span4 = values.right and values.right.span
		return {
			kind = "table",
			values = values,
			span = vector.create(
				span and span.x or span2 and span2.x or span3 and span3.x or not span4 and 0 or span4.x or 0,
				span4 and span4.y or span3 and span3.y or span2 and span2.y or not span and 0 or span.y or 0,
				span and span.z or span2 and span2.z or span3 and span3.z or span4 and span4.z or 0
			)
		}
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function parse_unary_operator()
		if kind ~= "-" and kind ~= "!" then
			return nil
		end

		local v6 = v4
		v4 = v5
		kind = kind2
		x = x2
		v5 = next_token()
		kind2 = v5.kind
		x2 = v5.span.x
		return v6
	end

	local function current_binary_operator()
		if kind == "+" or kind == "-" or kind == "*" or kind == "/" or kind == "//" or kind == "%" or kind == "^" or kind == ".." or kind == "<" or kind == "<=" or kind == ">" or kind == ">=" or kind == "==" or kind == "~=" or kind == "!=" or kind == "and" or kind == "or" then
			return v4
		end

		return nil
	end

	local function binary_operator_priority(p)
		local kind3 = p.kind

		if kind3 == "+" or kind3 == "-" then
			return 6, 6
		end

		if kind3 == "*" or kind3 == "/" or kind3 == "//" or kind3 == "%" then
			return 7, 7
		end

		if kind3 == "^" then
			return 10, 9
		elseif kind3 == ".." then
			return 5, 4
		end

		if kind3 == "==" or kind3 == "~=" or kind3 == "!=" then
			return 3, 3
		end

		if kind3 == "<" or kind3 == "<=" or kind3 == ">" or kind3 == ">=" then
			return 3, 3
		end

		if kind3 == "and" then
			return 2, 2
		elseif kind3 == "or" then
			return 1, 1
		end

		return panic(kind3), 0
	end

	parse_simple_expression = function()
		local operator = parse_unary_operator() -- equivalent call inferred; original call site unknown

		if operator then
			local v7 = parse_expression(8)
			local span = operator.span
			local span2 = v7 and v7.span
			return {
				kind = "unary",
				operator = operator,
				value = v7,
				span = vector.create(
					span and span.x or not span2 and 0 or span2.x or 0,
					span2 and span2.y or not span and 0 or span.y or 0,
					span and span.z or span2 and span2.z or 0
				)
			}
		else
			skip_current() -- equivalent call inferred; original call site unknown

			if kind == "error" then
				return expect_fatal("error")
			end

			skip_current() -- equivalent call inferred; original call site unknown

			if kind == "(" then
				local command = parse_delimiter("(", ")", parse_expression_command)
				assert(command)
				local span = command and command.left and command.left.span
				local span2 = command and command.value and command.value.span
				local span3 = command and command.right and command.right.span
				return {
					kind = "evaluate",
					command = command,
					span = vector.create(
						span and span.x or span2 and span2.x or not span3 and 0 or span3.x or 0,
						span3 and span3.y or span2 and span2.y or not span and 0 or span.y or 0,
						span and span.z or span2 and span2.z or span3 and span3.z or 0
					)
				}
			else
				skip_current() -- equivalent call inferred; original call site unknown

				if kind == "nil" then
					local token = expect_fatal("nil")
					return {
						kind = "nil",
						token = token,
						span = token.span
					}
				end

				skip_current() -- equivalent call inferred; original call site unknown

				if kind ~= "false" then
					skip_current() -- equivalent call inferred; original call site unknown

					if kind ~= "true" then
						skip_current() -- equivalent call inferred; original call site unknown

						if kind == "number" then
							local token = expect_fatal("number")
							return {
								kind = "number",
								token = token,
								span = token.span
							}
						end

						skip_current() -- equivalent call inferred; original call site unknown

						if kind == "string" then
							local token = expect_fatal("string")
							return {
								kind = "string",
								token = token,
								span = token.span
							}
						end

						skip_current() -- equivalent call inferred; original call site unknown

						if kind == "{" then
							return parse_table()
						end

						skip_current() -- equivalent call inferred; original call site unknown

						if kind == "|" then
							return parse_lambda()
						end

						skip_current() -- equivalent call inferred; original call site unknown

						if kind == "$" then
							return parse_var()
						end

						skip_current() -- equivalent call inferred; original call site unknown

						if kind == "identifier" then
							return parse_var()
						end

						skip_current() -- equivalent call inferred; original call site unknown

						if kind == "[" then
							return parse_vector()
						end

						skip_current() -- equivalent call inferred; original call site unknown

						if kind == "&" then
							local span = expect_fatal("&").span
							table.insert(issues, {
								why = "SyntaxError: you are not allowed to run a command here due to ambiguous syntax. please wrap the command with ()",
								span = span
							})
							local v9 = display(v4) -- equivalent call inferred; original call site unknown
							throw(`expected expression, but got {v9} of {kind} instead`, v4.span) -- equivalent call inferred; original call site unknown
							v4 = v5
							kind = kind2
							x = x2
							v5 = next_token()
							kind2 = v5.kind
							x2 = v5.span.x
							return nil
						elseif current_binary_operator() then
							local span = v4.span
							table.insert(issues, {
								why = "SyntaxError: you are not allowed to use binary operators here due to ambiguous syntax. please wrap the expression with ()",
								span = span
							})
							v4 = v5
							kind = kind2
							x = x2
							v5 = next_token()
							kind2 = v5.kind
							x2 = v5.span.x
							return nil
						else
							local v9 = display(v4) -- equivalent call inferred; original call site unknown
							throw(`expected expression, but got {v9} of {kind} instead`, v4.span) -- equivalent call inferred; original call site unknown
							v4 = v5
							kind = kind2
							x = x2
							v5 = next_token()
							kind2 = v5.kind
							x2 = v5.span.x
							return nil
						end

						return parse_var()
					end
				end

				local token2 = v4
				v4 = v5
				kind = kind2
				x = x2
				v5 = next_token()
				kind2 = v5.kind
				x2 = v5.span.x
				return {
					kind = "boolean",
					token = token2,
					span = token2.span
				}
			end
		end
	end

	local function parse_simple_expression_command()
		skip_current() -- equivalent call inferred; original call site unknown

		if kind ~= "&" then
			return parse_simple_expression()
		end

		local prefix = expect_fatal("&")
		local command = parse_command()
		local span = prefix.span
		local span2 = command and command.span
		return {
			kind = "command",
			prefix = prefix,
			command = command,
			span = vector.create(
				span and span.x or not span2 and 0 or span2.x or 0,
				span2 and span2.y or not span and 0 or span.y or 0,
				span and span.z or span2 and span2.z or 0
			)
		}
	end

	parse_expression = function(value: number?)
		local v6 = value or 0
		local operator = parse_unary_operator() -- equivalent call inferred; original call site unknown
		local left

		if operator then
			local v9 = parse_expression(8)
			left = {
				kind = "unary",
				operator = operator,
				value = v9,
				span = 0
			}
			local span = operator.span
			local span2 = v9.span
			left.span = vector.create(
				span and span.x or not span2 and 0 or span2.x or 0,
				span2 and span2.y or not span and 0 or span.y or 0,
				span and span.z or span2 and span2.z or 0
			)
		else
			left = parse_simple_expression()
		end

		while true do
			local operator2 = current_binary_operator()

			if operator2 == nil then
				break
			end

			local v10, v11 = binary_operator_priority(operator2)

			if v10 < v6 then
				break
			end

			v4 = v5
			kind = kind2
			x = x2
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
			local right = parse_expression(v11)

			if not left then
				return panic("no left hand side")
			end

			local span = left and left.span or nil
			local span2 = operator2 and operator2.span or nil
			left = {
				kind = "binary",
				left = left,
				operator = operator2,
				right = right,
				span = vector.create(
					span and span.x or not span2 and 0 or span2.x or 0,
					span2 and span2.y or not span and 0 or span.y or 0,
					span and span.z or span2 and span2.z or 0
				)
			}
		end

		if left then
			return left
		end

		return panic("no expression")
	end

	parse_expression_command = function()
		if current_is("&") then
			return parse_simple_expression_command()
		end

		return parse_expression()
	end

	parse_lambda = function()
		local body = parse_function_body()
		return {
			kind = "lambda",
			span = body and body.span,
			body = body
		}
	end

	parse_vector = function()
		local contents = parse_delimiter("[", "]", function()
			return (separated(parse_expression_command))
		end)

		if not contents then
			return panic("no values")
		end

		local span = contents.left and contents.left.span
		local span2 = contents.value and contents.value[1] and contents.value[1].span
		local span3 = contents.value and contents.value[#contents.value] and contents.value[#contents.value].span
		local span4 = contents.right and contents.right.span
		return {
			kind = "vector",
			contents = contents,
			span = vector.create(
				span and span.x or span2 and span2.x or span3 and span3.x or not span4 and 0 or span4.x or 0,
				span4 and span4.y or span3 and span3.y or span2 and span2.y or not span and 0 or span.y or 0,
				span and span.z or span2 and span2.z or span3 and span3.z or span4 and span4.z or 0
			)
		}
	end

	local function parse_var_root()
		skip_current() -- equivalent call inferred; original call site unknown

		if kind == "identifier" then
			local token = expect_fatal("identifier")
			return {
				kind = "global",
				token = token,
				span = token.span
			}
		end

		skip_current() -- equivalent call inferred; original call site unknown

		if kind == "$" then
			while kind2 == "\n" do
				v5 = next_token()
				kind2 = v5.kind
				x2 = v5.span.x
			end

			if kind2 == "(" then
				local var = expect_fatal("$")
				local node = parse_delimiter("(", ")", parse_expression_command)

				if not node then
					return panic("no expression")
				end

				local span = var.span
				local span2 = node.left and node.left.span
				local span3 = node.value and node.value.span
				local span4 = node.right and node.right.span
				return {
					kind = "paren",
					var = var,
					node = node,
					span = vector.create(
						span and span.x or span2 and span2.x or span3 and span3.x or not span4 and 0 or span4.x or 0,
						span4 and span4.y or span3 and span3.y or span2 and span2.y or not span and 0 or span.y or 0,
						span and span.z or span2 and span2.z or span3 and span3.z or span4 and span4.z or 0
					)
				}
			end
		end

		skip_current() -- equivalent call inferred; original call site unknown

		if kind == "$" then
			local var = expect_fatal("$")
			skip_current() -- equivalent call inferred; original call site unknown
			local v7

			if kind == "identifier" then
				v7 = v4
				v4 = v5
				kind = kind2
				x = x2
				v5 = next_token()
				kind2 = v5.kind
				x2 = v5.span.x
			else
				local v10 = display(v4) -- equivalent call inferred; original call site unknown
				throw(`expected identifier, but got {v10} of {kind} instead`, v4.span) -- equivalent call inferred; original call site unknown
				v4 = v5
				kind = kind2
				x = x2
				v5 = next_token()
				kind2 = v5.kind
				x2 = v5.span.x
				v7 = false
			end

			local span = var.span
			local span2 = v7 and v7.span or nil
			return {
				kind = "name",
				var = var,
				name = v7 or nil,
				span = vector.create(
					span and span.x or not span2 and 0 or span2.x or 0,
					span2 and span2.y or not span and 0 or span.y or 0,
					span and span.z or span2 and span2.z or 0
				)
			}
		else
			throw(`could not parse into var. got {kind}`, v4.span) -- equivalent call inferred; original call site unknown
			return panic()
		end
	end

	local function parse_var_suffix()
		skip_current() -- equivalent call inferred; original call site unknown

		if kind == "." then
			while kind2 == "\n" do
				v5 = next_token()
				kind2 = v5.kind
				x2 = v5.span.x
			end

			if kind2 == "[" then
				local period = expect_fatal(".")
				local node = parse_delimiter("[", "]", parse_expression_command)

				if not node then
					return panic("unreachable")
				end

				local span

				if node.left then
					span = node.left.span or nil
				end

				local span2

				if node.value then
					span2 = node.value.span or nil
				end

				local span3 = node.right and node.right.span or nil
				return {
					kind = "expression_index",
					node = node,
					period = period,
					span = vector.create(
						span and span.x or span2 and span2.x or not span3 and 0 or span3.x or 0,
						span3 and span3.y or span2 and span2.y or not span and 0 or span.y or 0,
						span and span.z or span2 and span2.z or span3 and span3.z or 0
					)
				}
			end
		end

		skip_current() -- equivalent call inferred; original call site unknown

		if kind ~= "." then
			return panic("unreachable")
		end

		local period2 = expect_fatal(".")
		skip_current() -- equivalent call inferred; original call site unknown
		local v7

		if kind == "identifier" then
			v7 = v4
			v4 = v5
			kind = kind2
			x = x2
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
		else
			local v10 = display(v4) -- equivalent call inferred; original call site unknown
			throw(`expected identifier, but got {v10} of {kind} instead`, v4.span) -- equivalent call inferred; original call site unknown
			v4 = v5
			kind = kind2
			x = x2
			v5 = next_token()
			kind2 = v5.kind
			x2 = v5.span.x
			v7 = false
		end

		local span = period2.span
		local span2 = v7 and v7.span or nil
		return {
			kind = "name_index",
			period = period2,
			name = v7 or nil,
			span = vector.create(
				span and span.x or not span2 and 0 or span2.x or 0,
				span2 and span2.y or not span and 0 or span.y or 0,
				span and span.z or span2 and span2.z or 0
			)
		}
	end

	parse_var = function()
		local root = parse_var_root()
		local suffixes = {}

		while kind == "." do
			table.insert(suffixes, parse_var_suffix())
		end

		local span = root.span
		local span2 = suffixes[#suffixes] and suffixes[#suffixes].span
		return {
			kind = "var",
			root = root,
			suffixes = suffixes,
			span = vector.create(
				span and span.x or not span2 and 0 or span2.x or 0,
				span2 and span2.y or not span and 0 or span.y or 0,
				span and span.z or span2 and span2.z or 0
			)
		}
	end

	local v6 = {
		block = parse_block_node()
	}

	if #issues > 0 then
		error({
			result = v6,
			issues = issues
		})
	else
		return {
			result = v6,
			issues = issues
		}
	end
end

return parse