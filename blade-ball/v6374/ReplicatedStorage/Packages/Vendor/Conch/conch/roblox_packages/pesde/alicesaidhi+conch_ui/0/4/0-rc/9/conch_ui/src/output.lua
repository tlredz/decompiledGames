local module = require("./theme")

local function char(value: string)
	return string.byte(value)
end

local function next_pow_of_2(p: number)
	local v

	if p > 0 then
		v = p <= 4294967296
	else
		v = false
	end

	assert(v)
	local v2 = p - 1
	local v3 = bit32.bor(v2, (bit32.rshift(v2, 1)))
	local v4 = bit32.bor(v3, (bit32.rshift(v3, 2)))
	local v5 = bit32.bor(v4, (bit32.rshift(v4, 4)))
	local v6 = bit32.bor(v5, (bit32.rshift(v5, 8)))
	return bit32.bor(v6, (bit32.rshift(v6, 16))) + 1
end

local function BUFFER_RESIZE(source: buffer, p: number)
	local v

	if p > 0 then
		v = p <= 4294967296
	else
		v = false
	end

	assert(v)
	local v2 = p - 1
	local v3 = bit32.bor(v2, (bit32.rshift(v2, 1)))
	local v4 = bit32.bor(v3, (bit32.rshift(v3, 2)))
	local v5 = bit32.bor(v4, (bit32.rshift(v4, 4)))
	local v6 = bit32.bor(v5, (bit32.rshift(v5, 8)))
	local buf = buffer.create(bit32.bor(v6, (bit32.rshift(v6, 16))) + 1)
	buffer.copy(buf, 0, source)
	return buf
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RESIZE(buf: buffer, p: number)
	if not (buffer.len(buf) < p) then
		return buf
	end

	local v

	if p > 0 then
		v = p <= 4294967296
	else
		v = false
	end

	assert(v)
	local v2 = p - 1
	local v3 = bit32.bor(v2, (bit32.rshift(v2, 1)))
	local v4 = bit32.bor(v3, (bit32.rshift(v3, 2)))
	local v5 = bit32.bor(v4, (bit32.rshift(v4, 4)))
	local v6 = bit32.bor(v5, (bit32.rshift(v5, 8)))
	local buf2 = buffer.create(bit32.bor(v6, (bit32.rshift(v6, 16))) + 1)
	buffer.copy(buf2, 0, buf)
	return buf2
end

local buffer2 = buffer.fromstring("</font>")
local buffer3 = buffer.fromstring("</b>")
local buffer4 = buffer.fromstring("</i>")
local buffer5 = buffer.fromstring("</u>")
local buffer6 = buffer.fromstring("</s>")
local buffer7 = buffer.fromstring("</mark>")
local buffer8 = buffer.fromstring("<font color=\"#")
local buffer9 = buffer.fromstring("<b>")
local buffer10 = buffer.fromstring("<i>")
local buffer11 = buffer.fromstring("<u>")
local buffer12 = buffer.fromstring("<s>")
local buffer13 = buffer.fromstring("<mark color=\"#")
local v = 62
local v2 = {
	[60] = buffer.fromstring("&lt;"),
	[62] = buffer.fromstring("&gt;"),
	[34] = buffer.fromstring("&quot;"),
	[39] = buffer.fromstring("&apos;"),
	[38] = buffer.fromstring("&amp;")
}
local ansi_pallete = module.ansi_pallete

local function write(state, buf: buffer)
	local max_line_length = state.max_line_length
	local v3 = buffer.len(buf)
	local chars_left = state.chars_left
	local at = state.at
	local richtext = RESIZE(state.richtext, at + buffer.len(buf)) -- equivalent call inferred; original call site unknown

	if at > 24000000 then
		buffer.copy(richtext, 0, richtext, 1000000, at - 1000000)
		at -= 1000000
	end

	local count = 0

	local function consume()
		count += 1

		if v3 < count - 1 then
			return 0
		end

		return (buffer.readu8(buf, count - 1))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function peek()
		if v3 < count then
			return 0
		end

		return (buffer.readu8(buf, count))
	end

	local function is_escapecode_stop()
		return peek() == 59 or (peek() == 109 or count >= buffer.len(buf))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function append(buf2: buffer)
		richtext = RESIZE(richtext, at + buffer.len(buf2)) -- equivalent call inferred; original call site unknown
		buffer.copy(richtext, at, buf2, 0)
		at += buffer.len(buf2)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function write_char(value: number)
		richtext = RESIZE(richtext, at + 1) -- equivalent call inferred; original call site unknown
		buffer.writeu8(richtext, at, value)
		at += 1
	end

	local function pop_tag(active_tag)
		if active_tag.kind == "bgcolor" then
			append(buffer7) -- equivalent call inferred; original call site unknown
		elseif active_tag.kind == "bold" then
			append(buffer3) -- equivalent call inferred; original call site unknown
		elseif active_tag.kind == "color" then
			append(buffer2) -- equivalent call inferred; original call site unknown
		elseif active_tag.kind == "italic" then
			append(buffer4) -- equivalent call inferred; original call site unknown
		elseif active_tag.kind == "strikethrough" then
			append(buffer6) -- equivalent call inferred; original call site unknown
		elseif active_tag.kind == "underline" then
			append(buffer5) -- equivalent call inferred; original call site unknown
		end
	end

	local function append_tag(p)
		if p.kind == "bgcolor" then
			append(buffer13) -- equivalent call inferred; original call site unknown
			append(buffer.fromstring(p.color:ToHex())) -- equivalent call inferred; original call site unknown
			write_char(34) -- equivalent call inferred; original call site unknown
			write_char(v) -- equivalent call inferred; original call site unknown
		elseif p.kind == "bold" then
			append(buffer9) -- equivalent call inferred; original call site unknown
		elseif p.kind == "color" then
			append(buffer8) -- equivalent call inferred; original call site unknown
			append(buffer.fromstring(p.color:ToHex())) -- equivalent call inferred; original call site unknown
			write_char(34) -- equivalent call inferred; original call site unknown
			write_char(v) -- equivalent call inferred; original call site unknown
		elseif p.kind == "italic" then
			append(buffer10) -- equivalent call inferred; original call site unknown
		elseif p.kind == "strikethrough" then
			append(buffer12) -- equivalent call inferred; original call site unknown
		elseif p.kind == "underline" then
			append(buffer11) -- equivalent call inferred; original call site unknown
		end

		table.insert(state.active_tags, p)
	end

	local function flush_tags()
		for i = #state.active_tags, 1, -1 do
			pop_tag(state.active_tags[i])
		end

		table.clear(state.active_tags)
	end

	local function reset_tag(p)
		local active_tags = {}

		for _, active_tag in state.active_tags do
			pop_tag(active_tag)

			if p == active_tag.kind then
				break
			else
				table.insert(active_tags, active_tag)
			end
		end

		for i = #active_tags, 1, -1 do
			append_tag(active_tags[i])
		end
	end

	while count < buffer.len(buf) do
		count += 1
		local v6 = v3 < count - 1 and 0 or buffer.readu8(buf, count - 1)

		if v6 == 27 and peek() == 91 then
			count += 1

			if not (v3 < count - 1) then
				buffer.readu8(buf, count - 1)
			end

			while peek() ~= 109 and count < buffer.len(buf) do
				if peek() == 59 then
					count += 1

					if not (v3 < count - 1) then
						buffer.readu8(buf, count - 1)
					end
				end

				local v7 = count

				while peek() ~= 59 and peek() ~= 109 and not (buffer.len(buf) <= count) and count < buffer.len(buf) do
					count += 1

					if not (v3 < count - 1) then
						buffer.readu8(buf, count - 1)
					end
				end

				local v8 = buffer.readstring(buf, v7, count - v7)

				if v8 == "0" then
					flush_tags()
				elseif v8 == "1" then
					append_tag({
						kind = "bold",
						line = #state.richtext_lines
					})
				elseif v8 == "2" then
					warn("todo: dim/faint mode")
				elseif v8 == "3" then
					append_tag({
						kind = "italic",
						line = #state.richtext_lines
					})
				elseif v8 == "4" then
					append_tag({
						kind = "underline",
						line = #state.richtext_lines
					})
				elseif v8 == "5" then
					warn("todo: blinking mode")
				elseif v8 == "7" then
					warn("todo: inverse mode")
				elseif v8 == "8" then
					warn("todo: invis mode")
				elseif v8 == "9" then
					append_tag({
						kind = "strikethrough",
						line = #state.richtext_lines
					})
				elseif v8 == "21" then
					reset_tag("bold")
				elseif v8 == "22" then
					warn("todo: dim/faint mode")
				elseif v8 == "23" then
					reset_tag("italic")
				elseif v8 == "24" then
					reset_tag("underline")
				elseif v8 == "25" then
					warn("todo: blinking mode")
				elseif v8 == "27" then
					warn("todo: inverse mode")
				elseif v8 == "28" then
					warn("todo: invis mode")
				elseif v8 == "29" then
					reset_tag("strikethrough")
				elseif v8 == "30" then
					append_tag({
						kind = "color",
						color = ansi_pallete[0],
						line = #state.richtext_lines
					})
				elseif v8 == "31" then
					append_tag({
						kind = "color",
						color = ansi_pallete[1],
						line = #state.richtext_lines
					})
				elseif v8 == "32" then
					append_tag({
						kind = "color",
						color = ansi_pallete[2],
						line = #state.richtext_lines
					})
				elseif v8 == "33" then
					append_tag({
						kind = "color",
						color = ansi_pallete[3],
						line = #state.richtext_lines
					})
				elseif v8 == "34" then
					append_tag({
						kind = "color",
						color = ansi_pallete[4],
						line = #state.richtext_lines
					})
				elseif v8 == "35" then
					append_tag({
						kind = "color",
						color = ansi_pallete[5],
						line = #state.richtext_lines
					})
				elseif v8 == "36" then
					append_tag({
						kind = "color",
						color = ansi_pallete[6],
						line = #state.richtext_lines
					})
				elseif v8 == "37" then
					append_tag({
						kind = "color",
						color = ansi_pallete[7],
						line = #state.richtext_lines
					})
				elseif v8 == "38" then
					append_tag({
						kind = "color",
						color = ansi_pallete[8],
						line = #state.richtext_lines
					})
				elseif v8 == "39" then
					append_tag({
						kind = "color",
						color = ansi_pallete[9],
						line = #state.richtext_lines
					})
				elseif v8 == "310" then
					append_tag({
						kind = "color",
						color = ansi_pallete[10],
						line = #state.richtext_lines
					})
				elseif v8 == "311" then
					append_tag({
						kind = "color",
						color = ansi_pallete[11],
						line = #state.richtext_lines
					})
				elseif v8 == "312" then
					append_tag({
						kind = "color",
						color = ansi_pallete[12],
						line = #state.richtext_lines
					})
				elseif v8 == "313" then
					append_tag({
						kind = "color",
						color = ansi_pallete[13],
						line = #state.richtext_lines
					})
				elseif v8 == "314" then
					append_tag({
						kind = "color",
						color = ansi_pallete[14],
						line = #state.richtext_lines
					})
				elseif v8 == "315" then
					append_tag({
						kind = "color",
						color = ansi_pallete[15],
						line = #state.richtext_lines
					})
				elseif v8 == "40" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[0],
						line = #state.richtext_lines
					})
				elseif v8 == "41" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[1],
						line = #state.richtext_lines
					})
				elseif v8 == "42" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[2],
						line = #state.richtext_lines
					})
				elseif v8 == "43" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[3],
						line = #state.richtext_lines
					})
				elseif v8 == "44" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[4],
						line = #state.richtext_lines
					})
				elseif v8 == "45" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[5],
						line = #state.richtext_lines
					})
				elseif v8 == "46" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[6],
						line = #state.richtext_lines
					})
				elseif v8 == "47" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[7],
						line = #state.richtext_lines
					})
				elseif v8 == "48" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[8],
						line = #state.richtext_lines
					})
				elseif v8 == "49" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[9],
						line = #state.richtext_lines
					})
				elseif v8 == "410" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[10],
						line = #state.richtext_lines
					})
				elseif v8 == "411" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[11],
						line = #state.richtext_lines
					})
				elseif v8 == "412" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[12],
						line = #state.richtext_lines
					})
				elseif v8 == "413" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[13],
						line = #state.richtext_lines
					})
				elseif v8 == "414" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[14],
						line = #state.richtext_lines
					})
				elseif v8 == "415" then
					append_tag({
						kind = "bgcolor",
						color = ansi_pallete[15],
						line = #state.richtext_lines
					})
				end
			end

			count += 1

			if not (v3 < count - 1) then
				buffer.readu8(buf, count - 1)
			end
		else
			if chars_left == 0 or v6 == 10 then
				table.insert(state.start_tags_per_line, table.clone(state.active_tags))
				table.insert(state.richtext_lines, at)

				if v6 ~= 10 then
					local v7 = richtext
					local v8 = at + 1

					if buffer.len(v7) < v8 then
						local v9

						if v8 > 0 then
							v9 = v8 <= 4294967296
						else
							v9 = false
						end

						assert(v9)
						local v10 = v8 - 1
						local v11 = bit32.bor(v10, (bit32.rshift(v10, 1)))
						local v12 = bit32.bor(v11, (bit32.rshift(v11, 2)))
						local v13 = bit32.bor(v12, (bit32.rshift(v12, 4)))
						local v14 = bit32.bor(v13, (bit32.rshift(v13, 8)))
						local buf2 = buffer.create(bit32.bor(v14, (bit32.rshift(v14, 16))) + 1)
						buffer.copy(buf2, 0, v7)
						richtext = buf2
					else
						richtext = v7
					end

					buffer.writeu8(richtext, at, 10)
					at += 1
				end

				chars_left = max_line_length
			end

			local v7 = richtext
			local v8 = at + 1

			if buffer.len(v7) < v8 then
				local v9

				if v8 > 0 then
					v9 = v8 <= 4294967296
				else
					v9 = false
				end

				assert(v9)
				local v10 = v8 - 1
				local v11 = bit32.bor(v10, (bit32.rshift(v10, 1)))
				local v12 = bit32.bor(v11, (bit32.rshift(v11, 2)))
				local v13 = bit32.bor(v12, (bit32.rshift(v12, 4)))
				local v14 = bit32.bor(v13, (bit32.rshift(v13, 8)))
				local buf2 = buffer.create(bit32.bor(v14, (bit32.rshift(v14, 16))) + 1)
				buffer.copy(buf2, 0, v7)
				richtext = buf2
			else
				richtext = v7
			end

			if v2[v6] then
				local v9 = v2[v6]
				local v10 = richtext
				local v11 = at + buffer.len(v9)

				if buffer.len(v10) < v11 then
					local v12

					if v11 > 0 then
						v12 = v11 <= 4294967296
					else
						v12 = false
					end

					assert(v12)
					local v13 = v11 - 1
					local v14 = bit32.bor(v13, (bit32.rshift(v13, 1)))
					local v15 = bit32.bor(v14, (bit32.rshift(v14, 2)))
					local v16 = bit32.bor(v15, (bit32.rshift(v15, 4)))
					local v17 = bit32.bor(v16, (bit32.rshift(v16, 8)))
					local buf2 = buffer.create(bit32.bor(v17, (bit32.rshift(v17, 16))) + 1)
					buffer.copy(buf2, 0, v10)
					richtext = buf2
				else
					richtext = v10
				end

				buffer.copy(richtext, at, v9, 0)
				at += buffer.len(v9)
			else
				buffer.writeu8(richtext, at, v6)
				at += 1
			end

			if v6 ~= 10 then
				chars_left -= 1
			end

			if v6 == 9 then
				chars_left = math.floor(chars_left / 4) * 4
			end
		end
	end

	state.at = at
	state.chars_left = chars_left
	state.richtext = richtext
end

local function view_from(data, p: number)
	local v3 = math.clamp(p - data.visible_lines + 1, 0, math.max(1, #data.richtext_lines - data.visible_lines) + 1)
	local v4 = data.richtext_lines[p + 1] or data.at
	local v5 = data.richtext_lines[v3] or 0
	local v6 = v4 - v5
	local v7 = math.max(v6, 1)
	local v8

	if v7 > 0 then
		v8 = v7 <= 4294967296
	else
		v8 = false
	end

	assert(v8)
	local v9 = v7 - 1
	local v10 = bit32.bor(v9, (bit32.rshift(v9, 1)))
	local v11 = bit32.bor(v10, (bit32.rshift(v10, 2)))
	local v12 = bit32.bor(v11, (bit32.rshift(v11, 4)))
	local v13 = bit32.bor(v12, (bit32.rshift(v12, 8)))
	local buf = buffer.create(bit32.bor(v13, (bit32.rshift(v13, 16))) + 1)
	local total = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function append(buf2: buffer)
		buf = RESIZE(buf, total + buffer.len(buf2)) -- equivalent call inferred; original call site unknown
		buffer.copy(buf, total, buf2, 0)
		total += buffer.len(buf2)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function write_char(value: number)
		buf = RESIZE(buf, total + 1) -- equivalent call inferred; original call site unknown
		buffer.writeu8(buf, total, value)
		total += 1
	end

	local function write_tag(p2)
		if p2.kind == "bgcolor" then
			append(buffer13) -- equivalent call inferred; original call site unknown
			append(buffer.fromstring(p2.color:ToHex())) -- equivalent call inferred; original call site unknown
			write_char(34) -- equivalent call inferred; original call site unknown
			write_char(v) -- equivalent call inferred; original call site unknown
		elseif p2.kind == "bold" then
			append(buffer9) -- equivalent call inferred; original call site unknown
		elseif p2.kind == "color" then
			append(buffer8) -- equivalent call inferred; original call site unknown
			append(buffer.fromstring(p2.color:ToHex())) -- equivalent call inferred; original call site unknown
			write_char(34) -- equivalent call inferred; original call site unknown
			write_char(v) -- equivalent call inferred; original call site unknown
		elseif p2.kind == "italic" then
			append(buffer10) -- equivalent call inferred; original call site unknown
		elseif p2.kind == "strikethrough" then
			append(buffer12) -- equivalent call inferred; original call site unknown
		elseif p2.kind == "underline" then
			append(buffer11) -- equivalent call inferred; original call site unknown
		end
	end

	local function pop_tag(active_tag)
		if active_tag.kind == "bgcolor" then
			append(buffer7) -- equivalent call inferred; original call site unknown
		elseif active_tag.kind == "bold" then
			append(buffer3) -- equivalent call inferred; original call site unknown
		elseif active_tag.kind == "color" then
			append(buffer2) -- equivalent call inferred; original call site unknown
		elseif active_tag.kind == "italic" then
			append(buffer4) -- equivalent call inferred; original call site unknown
		elseif active_tag.kind == "strikethrough" then
			append(buffer6) -- equivalent call inferred; original call site unknown
		elseif active_tag.kind == "underline" then
			append(buffer5) -- equivalent call inferred; original call site unknown
		end
	end

	if data.start_tags_per_line[v3] then
		for _, v14 in data.start_tags_per_line[v3] do
			write_tag(v14)
		end
	end

	local v14 = buf
	local v15 = total + v6

	if buffer.len(v14) < v15 then
		local v16

		if v15 > 0 then
			v16 = v15 <= 4294967296
		else
			v16 = false
		end

		assert(v16)
		local v17 = v15 - 1
		local v18 = bit32.bor(v17, (bit32.rshift(v17, 1)))
		local v19 = bit32.bor(v18, (bit32.rshift(v18, 2)))
		local v20 = bit32.bor(v19, (bit32.rshift(v19, 4)))
		local v21 = bit32.bor(v20, (bit32.rshift(v20, 8)))
		local buf2 = buffer.create(bit32.bor(v21, (bit32.rshift(v21, 16))) + 1)
		buffer.copy(buf2, 0, v14)
		buf = buf2
	else
		buf = v14
	end

	buffer.copy(buf, total, data.richtext, v5, v6)
	total += v6

	for i = #data.active_tags, 1, -1 do
		local active_tag = data.active_tags[i]

		if v4 < active_tag.line then
			break
		else
			pop_tag(active_tag)
		end
	end

	return buffer.readstring(buf, 0, total)
end

local function clear(p)
	p.active_tags = {}
	p.at = 0
	p.chars_left = p.max_line_length
	p.richtext = buffer.create(0)
	p.richtext_lines = { 0 }
	p.start_tags_per_line = {
		{}
	}
end

return {
	create_stream = function()
		return {
			active_tags = {},
			at = 0,
			chars_left = 120,
			richtext = buffer.create(0),
			richtext_lines = { 0 },
			start_tags_per_line = {
				{}
			},
			visible_lines = 160,
			max_line_length = 120,
			write = write,
			clear = clear,
			getformatted = view_from
		}
	end,
	write = write,
	view_from = view_from
}