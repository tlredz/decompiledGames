local Parameter = require(script.Parent.Parameter)
local ENV = require(script.Parent.ENV)
local Debug = require(script.Parent.Debug)

function Test(data)
	if type(data) == "table" and data.Type == "SimpleTest" and typeof(data.Iterations) == "number" and typeof(data.Parameters) == "table" and typeof(data.Func) == "function" then
		return true, nil
	end

	return false, "Expected a SimpleTest"
end

function TestMap(items)
	if type(items) ~= "table" then
		return false, "Expected a table of SimpleTests"
	end

	local count = 0

	for k, item in items do
		count += 1
		local v, v2 = Test(item)

		if not v then
			return false, (`Expected a table of SimpleTests, but key "{k}" is not a SimpleTest: {v2}`)
		end
	end

	if count == 0 then
		return false, "Expected a non-empty table of SimpleTests"
	end

	return true, nil
end

function TestTree(items)
	if type(items) ~= "table" then
		return false, "Expected a tree of SimpleTests"
	end

	local count = 0

	for k, item in items do
		count += 1
		local v, v2 = Test(item)

		if not v then
			return false, (`Expected a tree of SimpleTests, but key "{k}" is not a SimpleTest: {v2}`)
		end

		local v3, v4 = TestTree(item)

		if not v3 then
			return false, (`Expected a tree of SimpleTests, but key "{k}" is not a SimpleTest or TestTree: {v4}`)
		end
	end

	if count == 0 then
		return false, "Expected a non-empty tree of SimpleTests"
	end

	return true, nil
end

function pollForPause(p: number)
	local lastTime = tick()
	return function()
		if p <= tick() - lastTime then
			lastTime = tick()

			if ENV.PAUSE_DURATION > 0 then
				task.wait(ENV.PAUSE_DURATION)
			end
		end
	end
end

local Test_2 = {}
Test_2.Type = {
	Test = Test,
	TestMap = TestMap,
	TestTree = TestTree
}

function Test_2.new(p, func, p2: number?)
	local clone = table.clone(p)
	table.freeze(clone)
	local v = {
		Type = "SimpleTest",
		Iterations = p2 or ENV.DEFAULT_ITERATIONS,
		Parameters = clone,
		Func = func
	}
	table.freeze(v)
	return v
end

function Test_2.run(data, p)
	local v = table.create(data.Iterations)
	local v2 = p or Random.new()
	assert(v2, "bad rng")
	Debug.log((`Running test with {data.Iterations} iterations and {#data.Parameters} parameters...`))
	local v3 = pollForPause(0.03333333333333333)
	Debug.log((`Generating permutations for test with {#data.Parameters} parameters...`))
	local v4 = {}
	local v5 = true

	for k, parameter in data.Parameters do
		v3()
		local permute = Parameter.Any.permute(parameter, data.Iterations)
		v4[k] = permute
		Debug.log((`Generated {typeof(permute) ~= "number" and #permute or permute} permutations for parameter #{k} "{parameter.Key}" which has type "{parameter.Type}"`))

		if typeof(permute) == "number" then
			v5 = false
		end
	end

	while not v5 do
		v3()
		local v6 = 0
		local count = 0
		local v7 = 1
		local v8 = 0

		for k, v9 in v4 do
			if typeof(v9) == "number" and v6 < v9 then
				v7 *= v9
				v8 = k
				v6 = v9
			end

			count += 1
		end

		if data.Iterations <= v7 then
			Debug.log((`Total permutations across all parameters is {v7} which is sufficient for {data.Iterations} iterations, no need to clear any more permutations`))
			break
		end

		if v6 == 0 or count == 0 then
			break
		end

		if ENV.IS_VERBOSE then
			local parameter = data.Parameters[v8]
			Debug.log((`Cleared permutations for parameter #{v8} "{parameter.Key}" which has type "{parameter.Type}" because it had the most permutations at {v6}`))
		end

		v4[v8] = nil
		v5 = true

		for k, _ in v4 do
			local permute = Parameter.Any.permute(data.Parameters[k], data.Iterations)
			v4[k] = permute

			if typeof(permute) == "number" then
				v5 = false
			end
		end
	end

	Debug.log("Completed generating permutations.")
	local v6 = {}

	for k, v7 in v4 do
		if typeof(v7) == "table" then
			v6[k] = v7
		end
	end

	local count = 0
	local v7 = 1

	for _, v8 in v6 do
		if not v8 then
			continue
		end

		count += 1
		v7 *= #v8
	end

	assert(v7 < data.Iterations, (`permute failed, generated {v7} values`))
	Debug.log((`Using permutations for {count} parameters, resulting in {v7} total permutations which will be repeated across the {data.Iterations} iterations`))
	Debug.log((`Generating parameter sets for {data.Iterations} iterations...`))

	local function forParamIndex(items)
		assert(v2, "bad rng")
		local v8 = table.create(#data.Parameters)

		for k, item in items do
			local parameter = data.Parameters[k]
			local v9 = v6[k]
			local v10

			if v9 then
				v10 = v9[item % #v9 + 1]
			else
				v10 = Parameter.Any.generate(parameter, v2)
			end

			v8[k] = v10
		end

		table.freeze(v8)
		v[#v + 1] = v8
	end

	local v8 = table.create(#data.Parameters, 1)

	while #v < data.Iterations do
		for k in v8 do
			local v9 = v6[k]

			if not v9 then
				continue
			end

			v3()
			local v10 = v8[k]

			if #v9 < v10 then
				v8[k] = 1
			else
				v8[k] = v10 + 1
			end

			forParamIndex(v8)
		end
	end

	table.freeze(v)
	Debug.log("Completed generating parameter sets.")
	local result = table.create(data.Iterations)
	Debug.log((`Running {data.Iterations} test cases`))

	for k, v9 in v do
		v3()
		local parameters = table.create(#v9)

		for i = 1, #v9 do
			parameters[i] = {
				key = `{data.Parameters[i].Key}({data.Parameters[i].Type})`,
				value = Parameter.Any.serialize(data.Parameters[i], v9[i])
			}
			table.freeze(parameters[i])
		end

		table.freeze(parameters)
		local v11 = nil
		local v12 = v9
		local success, result2 = pcall(function()
			local func = data.Func(table.unpack(v12, 1, #data.Parameters))
			assert(typeof(func) == "boolean", (`Test function must return a boolean, got {typeof(func)}`))
			local v14

			if func then
				v14 = {
					Type = "Success",
					Parameters = parameters
				}
			else
				v14 = {
					Type = "Failure",
					Parameters = parameters
				}
			end

			v11 = v14
			return nil
		end)

		if not success then
			assert(typeof(result2) == "string", (`bad error message: "{result2}"`))
			v11 = {
				Type = "Error",
				Message = result2,
				Parameters = parameters
			}
		end

		assert(v11, "bad result")
		table.freeze(v11)
		result[k] = v11
	end

	table.freeze(result)
	Debug.log("Completed running test.")
	return result
end

return Test_2