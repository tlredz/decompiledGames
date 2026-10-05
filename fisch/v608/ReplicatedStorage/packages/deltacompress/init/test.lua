local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parentModule = require(script.Parent)
local RemotePacketSizeCounter = require(ReplicatedStorage.DevPackages.RemotePacketSizeCounter)
local deepCopy

deepCopy = function(items)
	if typeof(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in items do
		if type(item) == "table" then
			result[k] = deepCopy(item)
		else
			result[k] = item
		end
	end

	return result
end

local deepEqual

deepEqual = function(items, items2)
	if type(items) ~= "table" or type(items2) ~= "table" then
		return items == items2
	end

	for k, item in items do
		if not deepEqual(items2[k], item) then
			return false
		end
	end

	for k, item in items2 do
		if not deepEqual(items[k], item) then
			return false
		end
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function assertDeepEqual(p, p2, p3)
	assert(deepEqual(p, p2), p3)
end

local freezeIfTable

freezeIfTable = function(list)
	if typeof(list) == "table" then
		if not table.isfrozen(list) then
			table.freeze(list)
		end

		for _, v in list do
			freezeIfTable(v)
		end
	end
end

local function checkInner(p, vector2, p2, p3)
	if p2 then
		freezeIfTable(p)
		freezeIfTable(vector2)
	end

	local diffImmutable = parentModule.diffImmutable(p, vector2)
	assert(diffImmutable ~= nil, "diff was nil")
	local v

	if p2 then
		v = parentModule.applyImmutable(p, diffImmutable)
	else
		v = parentModule.applyMutable(p, diffImmutable)
	end

	if not p2 and typeof(p) == "table" and typeof(vector2) == "table" then
		assert(p == v, "old is not equal to applied")
	end

	if p3 then
		print("Applied =", v)
	end

	if typeof(vector2) == "CFrame" then
		assert(vector2:FuzzyEq(v))
		return
	end

	if typeof(vector2) == "table" then
		vector2 = deepCopy(vector2)
	end

	assertDeepEqual(v, vector2, "applied not equal") -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function check(p, p2, p3)
	checkInner(deepCopy(p), deepCopy(p2), true, p3)
	checkInner(deepCopy(p), deepCopy(p2), false, p3)
end

local function checkMutable(p, p2, p3)
	local v = deepCopy(p)
	freezeIfTable(p2)
	local diffMutable, v2 = parentModule.diffMutable(p, p2)
	assert(diffMutable ~= nil, "diff was nil")
	local v3 = parentModule.applyImmutable(v, diffMutable)

	if p3 then
		print("Applied =", v3)
	end

	assertDeepEqual(v2, p2, "newOld and new not equal") -- equivalent call inferred; original call site unknown
	assertDeepEqual(v3, p2, "applied not equal") -- equivalent call inferred; original call site unknown

	if typeof(p2) == "table" then
		assert(p ~= p2, "old and new are the same table")
		local checkForSameTable

		checkForSameTable = function(p4, items)
			for k, item in items do
				if type(item) ~= "table" then
					continue
				end

				assert(p4[k] ~= item, "old and new have a same table")
				checkForSameTable(p4[k], item)
			end
		end

		checkForSameTable(v2, p2)
	end
end

return function(data)
	local assertEqual = data.assertEqual
	data.test("number to bool", function()
		checkInner(100, true, true, nil)
		checkInner(100, true, false, nil)
	end)
	data.test("vector types", function()
		local vector2, v = Vector2.new(2.5, 30.1)
		checkInner(nil, deepCopy(vector2), true, v)
		checkInner(nil, deepCopy(vector2), false, v)
		checkInner(nil, deepCopy(createVector(2.5, 30.1, 204.3)), true, nil)
		checkInner(nil, deepCopy(createVector(2.5, 30.1, 204.3)), false, nil)
		local vector2int, v2 = Vector2int16.new(3.4, 9.2)
		checkInner(nil, deepCopy(vector2int), true, v2)
		checkInner(nil, deepCopy(vector2int), false, v2)
		local vector3int, v3 = Vector3int16.new(3.4, 9.2, 30.3)
		checkInner(nil, deepCopy(vector3int), true, v3)
		checkInner(nil, deepCopy(vector3int), false, v3)
	end)
	data.test("cframe", function()
		local identity = CFrame.identity
		checkInner(nil, deepCopy(identity), true, nil)
		checkInner(nil, deepCopy(identity), false, nil)
		local cframe, v = CFrame.lookAt(createVector(20, 40, 3290), createVector(1, 2, 3))
		checkInner(nil, deepCopy(cframe), true, v)
		checkInner(nil, deepCopy(cframe), false, v)
	end)
	data.test("number to empty string", function()
		checkInner(100, "", true, nil)
		checkInner(100, "", false, nil)
	end)
	data.test("number to number", function()
		checkInner(100, 120, true, nil)
		checkInner(100, 120, false, nil)
	end)
	data.test("bool to array", function()
		local v = { 1, 2, 3 }
		checkInner(true, deepCopy(v), true, nil)
		checkInner(true, deepCopy(v), false, nil)
	end)
	data.test("bool to dictionary", function()
		local v = {
			coins = 3
		}
		checkInner(true, deepCopy(v), true, nil)
		checkInner(true, deepCopy(v), false, nil)
	end)
	data.test("dictionary to bool", function()
		local v = {
			coins = 3
		}
		checkInner(deepCopy(v), true, true, nil)
		checkInner(deepCopy(v), true, false, nil)
	end)
	data.test("array to bool", function()
		local v = { 1, 2, 3 }
		checkInner(deepCopy(v), false, true, nil)
		checkInner(deepCopy(v), false, false, nil)
	end)
	data.test("bool to empty table", function()
		local v = {}
		checkInner(false, deepCopy(v), true, nil)
		checkInner(false, deepCopy(v), false, nil)
	end)
	data.test("non-table to table with arrays/dictionaries", function()
		local v = {
			"a",
			2,
			{},
			{ "a", "b", "c" },
			{
				a = "1",
				b = "2",
				c = "3"
			}
		}
		checkInner(false, deepCopy(v), true, nil)
		checkInner(false, deepCopy(v), false, nil)
		local v2 = {
			one = "a",
			two = 2,
			three = {},
			four = { "a", "b", "c" },
			five = {
				a = "1",
				b = "2",
				c = "3"
			}
		}
		checkInner(false, deepCopy(v2), true, nil)
		checkInner(false, deepCopy(v2), false, nil)
	end)
	data.nested("dictionary", function()
		data.test("to empty", function()
			check({
				a = "one",
				b = "two",
				c = "three"
			}, {}, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("no changes", function()
			assertEqual(parentModule.diffImmutable({
				foo = true
			}, {
				foo = true
			}), nil)
		end)
		data.test("removal", function()
			check({
				remove = "remove"
			}, {}, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("addition", function()
			check({}, {
				addition = true
			}, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("change", function()
			check({
				change = 5
			}, {
				change = 10
			}, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("removal + addition + change", function()
			check({
				remove = "remove",
				change = 5,
				noChange = true
			}, {
				change = 10,
				addition = true,
				noChange = true
			}, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("nested dictionary", function()
			check({
				nested = {
					noChange = true,
					change = 5,
					remove = true
				}
			}, {
				nested = {
					noChange = true,
					change = 10
				}
			}, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("nested dictionary no removals", function()
			check({
				stats = {
					deaths = 5,
					kills = 0
				}
			}, {
				stats = {
					deaths = 5,
					kills = 1
				}
			}, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("nested array", function()
			check({
				nested = { 1, 2, 3 }
			}, {
				nested = { 2, 1 }
			}, nil) -- equivalent call inferred; original call site unknown
		end)
	end)
	data.nested("array", function()
		data.test("to empty", function()
			check({ "one", "two", "three" }, {}, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("no changes", function()
			assertEqual(parentModule.diffImmutable({ "one", "two", "three" }, { "one", "two", "three" }), nil)
		end)
		data.test("removal", function()
			check({ "one", "two", "three" }, { "one", "two" }, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("addition", function()
			check({ "one", "two" }, { "one", "two", "three" }, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("change", function()
			check({ "same", "change" }, { "same", "different" }, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("addition + change", function()
			check({ "same", "change" }, { "same", "different", "addition" }, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("removal + change", function()
			check({ "same", "change", "remove" }, { "same", "different" }, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("array and dictionary inside array", function()
			check({
				{ "same", "change" },
				{
					foo = true,
					noChange = true
				},
				{}
			}, {
				{ "same", "different", "addition" },
				{
					foo = false,
					noChange = true
				}
			}, nil) -- equivalent call inferred; original call site unknown
		end)
	end)
	data.nested("array to dictionary", function()
		data.test("normal", function()
			check({ 1, 2, 3 }, {
				coins = 3
			}, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("nested in array", function()
			check({
				{ 1, 2, 3 }
			}, {
				{
					coins = 3
				}
			}, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("nested in dictionary", function()
			check({
				foo = { 1, 2, 3 }
			}, {
				foo = {
					coins = 3
				}
			}, nil) -- equivalent call inferred; original call site unknown
		end)
	end)
	data.nested("dictionary to array", function()
		data.test("normal", function()
			check({
				coins = 3
			}, { 1, 2, 3 }, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("nested in array", function()
			check({
				{
					coins = 3
				}
			}, {
				{ 1, 2, 3 }
			}, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("nested in dictionary", function()
			check({
				foo = {
					coins = 3
				}
			}, {
				foo = { 1, 2, 3 }
			}, nil) -- equivalent call inferred; original call site unknown
		end)
	end)
	data.test("array to nil", function()
		local v = { 1 }
		checkInner(deepCopy(v), nil, true, nil)
		checkInner(deepCopy(v), nil, false, nil)
	end)
	data.test("dictionary to nil", function()
		local v = {
			foo = true
		}
		checkInner(deepCopy(v), nil, true, nil)
		checkInner(deepCopy(v), nil, false, nil)
	end)
	data.test("bug case", function()
		check({
			stats = {
				globalStats = {
					secondsPlayed = 0
				},
				mechStats = {}
			}
		}, {
			stats = {
				globalStats = {
					secondsPlayed = 299
				},
				mechStats = {}
			}
		}, nil) -- equivalent call inferred; original call site unknown
	end)
	data.test("shouldn't change unchanged table when applyImmutable", function()
		local v = {
			foo = {
				bar = true
			},
			baz = {}
		}
		local diffImmutable = parentModule.diffImmutable(v, {
			foo = {
				bar = false
			},
			baz = {}
		})
		local v2 = deepCopy(v)
		local v3 = parentModule.applyImmutable(v2, diffImmutable)
		assertEqual(v2 ~= v3 and v2.foo ~= v3.foo, true)
		assertEqual(v2.baz == v3.baz, true)
	end)
	data.test("diff size", function()
		local v = {
			"xvKqT",
			"LpUoN",
			"aRzYl",
			"cQwVo",
			"mJuTe",
			"gYbFi",
			"vCnLd",
			"tXoPm",
			"hBwGq",
			"dJkUl",
			"uRtYi",
			"zNwVp",
			"qAzLf",
			"eKcTr",
			"pMvJd",
			"oBwUk",
			"fXqLn",
			"iGyRp",
			"nZcVo",
			"lKjTm",
			"sQbFi",
			"jWvUd",
			"yRnLp",
			"kXoQt",
			"aMjYi",
			"vPzTl",
			"cBwUr",
			"hXjVn",
			"dQkPo",
			"gZyFm",
			"oKcTr",
			"mJvUp",
			"fQbLi",
			"iGwYt",
			"nXoPk",
			"lRzVm",
			"sYjTo",
			"kWbUr",
			"aQnXp",
			"vZjLf",
			"cKjTr",
			"hPzWm",
			"dXqBo",
			"gRkYn",
			"oJcUi",
			"mWvLp",
			"fTzYo",
			"iQnPk",
			"nKjVr",
			"lZgTm"
		}
		local v2 = {}

		for _, v3 in v do
			v2[v3] = math.random()
		end

		local clone = table.clone(v2)
		clone[v[1]] = 4
		local diffImmutable = parentModule.diffImmutable(v2, clone)
		local dataByteSize = RemotePacketSizeCounter.GetDataByteSize(diffImmutable)
		local dataByteSize2 = RemotePacketSizeCounter.GetDataByteSize(clone)
		assertEqual(dataByteSize == 20, true)
		assertEqual(dataByteSize2 == 802, true)
	end)
	data.nested("diffMutable", function()
		data.test("no changes", function()
			local v = {
				foo = true
			}
			local v2 = deepCopy(v)
			local diffImmutable, v3 = parentModule.diffImmutable(v, {
				foo = true
			})
			assertEqual(diffImmutable, nil)
			assertEqual(v3, nil)
			assertDeepEqual(v, v2, nil) -- equivalent call inferred; original call site unknown
		end)
		data.test("non-tables", function()
			local diffMutable, v = parentModule.diffMutable("hello", 520)
			assert(diffMutable ~= nil, "diff was nil")
			local v2 = parentModule.applyImmutable("hello", diffMutable)
			assertDeepEqual(v, 520, "newOld and new not equal") -- equivalent call inferred; original call site unknown
			assertDeepEqual(v2, 520, "applied not equal") -- equivalent call inferred; original call site unknown
			local diffMutable2, v3 = parentModule.diffMutable("hello", nil)
			assert(diffMutable2 ~= nil, "diff was nil")
			local v4 = parentModule.applyImmutable("hello", diffMutable2)
			assertDeepEqual(v3, nil, "newOld and new not equal") -- equivalent call inferred; original call site unknown
			assertDeepEqual(v4, nil, "applied not equal") -- equivalent call inferred; original call site unknown
			local diffMutable3, v5 = parentModule.diffMutable(nil, false)
			assert(diffMutable3 ~= nil, "diff was nil")
			local v6 = parentModule.applyImmutable(nil, diffMutable3)
			assertDeepEqual(v5, false, "newOld and new not equal") -- equivalent call inferred; original call site unknown
			assertDeepEqual(v6, false, "applied not equal") -- equivalent call inferred; original call site unknown
		end)
		data.test("nil to table", function()
			checkMutable(nil, {
				a = "hello",
				b = {
					5,
					4,
					3,
					2,
					1
				},
				c = {
					foo = "bar"
				}
			})
		end)
		data.test("copies new tables in dictionary", function()
			checkMutable({
				a = true
			}, {
				a = { 1, 2, 3 },
				b = { true, false }
			})
		end)
		data.test("copies new tables in array", function()
			checkMutable({
				array = { 1, 2, 3 }
			}, {
				array = {
					1,
					{ "hello" },
					3,
					{ "abc" }
				}
			})
		end)
		data.test("handles nested diffs", function()
			checkMutable({
				array = {
					"a",
					"b",
					"c",
					1,
					2,
					3
				},
				dictionary = {
					foo = "bar"
				}
			}, {
				array = { "c", "b", "a" },
				dictionary = {
					foo = "baz"
				}
			})
		end)
	end)
end