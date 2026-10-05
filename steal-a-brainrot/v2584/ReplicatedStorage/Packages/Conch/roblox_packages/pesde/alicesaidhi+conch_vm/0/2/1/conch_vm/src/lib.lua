require("../roblox_packages/types")

local function error_handler(message: string)
	error(message)
end

local function LOG(...) end

local function create_vm()
	local now = os.clock()
	local locals = {}
	local globals = {}
	local commands = {}
	local stack = table.create(255)
	local instruction_at = 1
	local instruction_end = 0
	local arguments = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function PUSH(p)
		stack[arguments + 1] = p
		arguments += 1
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function POP()
		arguments -= 1
		return stack[arguments + 1]
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function POPN(arguments2: number)
		local v = arguments
		local v2 = arguments - arguments2 + 1
		arguments -= arguments2
		return unpack(stack, v2, v)
	end

	local function GET(p: number)
		if p < 0 then
			p = arguments + p + 1
		end

		if arguments < p then
			return nil
		end

		return stack[p]
	end

	local function call_success(results: number, _: string, flag: boolean, ...)
		if not flag then
			error(`{table.concat({ ... }, " ")}`, 0)
		end

		for i = 1, math.min(results, select("#", ...)) do
			PUSH(select(i, ...)) -- equivalent call inferred; original call site unknown
		end
	end

	local process

	process = function(data)
		local now2 = os.clock()

		if now + 30 < now2 then
			error("reached execution time limit", 0)
		end

		if data.kind == "call" then
			local v = { POPN(data.arguments) }
			local v2 = POP() -- equivalent call inferred; original call site unknown
			call_success(data.results, typeof(v2), pcall(v2, unpack(v)))
		elseif data.kind == "goto" then
			instruction_at = data.to - 1
		elseif data.kind == "index" then
			local v, v2 = POPN(2)
			local success, result = pcall(function()
				return v[v2]
			end)

			if not success then
				error(`attempt to index {typeof(v)} with {tostring(v2)}`, 0)
			end

			PUSH(result) -- equivalent call inferred; original call site unknown
		elseif data.kind == "jump_if" then
			if not POP() then
				instruction_at = data.to - 1
				arguments = 0
			end
		elseif data.kind == "jump_if_not_nil" then
			local v = 1

			if v < 0 then
				v = arguments + v + 1
			end

			local v2

			if not (arguments < v) then
				v2 = stack[v]
			end

			if v2 == nil then
				instruction_at = data.to - 1
				arguments = 0
			end
		elseif data.kind == "push_boolean" then
			PUSH(data.b) -- equivalent call inferred; original call site unknown
		elseif data.kind == "push_cmd" then
			PUSH(commands[data.name]) -- equivalent call inferred; original call site unknown
		elseif data.kind == "push_function" then
			local body = data.body

			local function VM_FN(...)
				local v = {
					start = now,
					locals = locals,
					globals = globals,
					commands = commands,
					stack = stack,
					n = arguments,
					instruction_at = instruction_at,
					instruction_end = instruction_end
				}
				local v2 = { ... }
				locals = {}
				now = os.clock()
				stack = v2
				arguments = data.arguments
				instruction_at = 1
				instruction_end = #body

				while instruction_at <= instruction_end do
					process(body[instruction_at])
					instruction_at += 1
				end

				locals = v.locals
				globals = v.globals
				commands = v.commands
				stack = v.stack
				now = v.start
				arguments = v.n
				instruction_at = v.instruction_at
				instruction_end = v.instruction_end
				return unpack(v2, 1, arguments)
			end

			PUSH(VM_FN) -- equivalent call inferred; original call site unknown
		elseif data.kind == "push_global" then
			PUSH(globals[data.name]) -- equivalent call inferred; original call site unknown
		elseif data.kind == "push_vector" then
			local v = POP() -- equivalent call inferred; original call site unknown
			local v2 = POP() -- equivalent call inferred; original call site unknown
			PUSH(vector.create(POP(), v2, v)) -- equivalent call inferred; original call site unknown
		elseif data.kind == "push_local" then
			PUSH(locals[data.index]) -- equivalent call inferred; original call site unknown
		elseif data.kind == "push_nil" then
			PUSH(nil) -- equivalent call inferred; original call site unknown
		elseif data.kind == "push_number" then
			PUSH(data.n) -- equivalent call inferred; original call site unknown
		elseif data.kind == "push_string" then
			PUSH(data.s) -- equivalent call inferred; original call site unknown
		elseif data.kind == "push_table" then
			PUSH(table.create(data.alloc)) -- equivalent call inferred; original call site unknown
		elseif data.kind == "set_global" then
			local v = globals
			local name = data.name
			v[name] = POP()
		elseif data.kind == "set_local" then
			local v = locals
			local index = data.index
			v[index] = POP()
		elseif data.kind == "set_table" then
			local v = POP() -- equivalent call inferred; original call site unknown
			local v2 = POP() -- equivalent call inferred; original call site unknown
			local v3 = arguments

			if v3 < 0 then
				v3 = arguments + v3 + 1
			end

			local v4

			if not (arguments < v3) then
				v4 = stack[v3]
			end

			v4[v2] = v
		elseif data.kind == "return" then
			LOG("stack", #stack, stack[1])
			instruction_at = instruction_end
		elseif data.kind == "reset" then
			arguments = 0
		elseif data.kind == "turn-into-iterator" then
			local v = POP() -- equivalent call inferred; original call site unknown

			if typeof(v) == "table" then
				local pairs2 = pairs
				local metatable = getmetatable(v)

				if typeof(metatable) == "table" then
					pairs2 = metatable.__iter or pairs2
				end

				local v2 = pairs(v)
				local v3 = {}

				local function fn()
					local v4 = { v2(v, unpack(v3)) }
					v3 = v4
					return unpack(v4)
				end

				PUSH(fn) -- equivalent call inferred; original call site unknown
			else
				PUSH(v) -- equivalent call inferred; original call site unknown
			end
		end
	end

	local function run(list)
		now = os.clock()
		instruction_at = 1
		instruction_end = #list

		while instruction_at <= instruction_end do
			process(list[instruction_at])
			instruction_at += 1
		end

		local v = arguments
		arguments = 0
		return v, unpack(stack, 1, v)
	end

	now = os.clock()
	return {
		commands = commands,
		globals = globals,
		locals = locals,
		run = run
	}
end

return create_vm