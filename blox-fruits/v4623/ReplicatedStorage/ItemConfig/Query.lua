local RunService = game:GetService("RunService")
local Result = require(game.ReplicatedStorage.Packages.Result)
local Display = require(game.ReplicatedStorage.Packages.Display)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local Storage = require(script.Parent.Storage)
require(script.Parent.Types)
local Index = require(script.Index)
local Legacy = require(script.Legacy)
local BuildInfo = require(game.ReplicatedStorage.BuildInfo)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("ItemConfig"):tag("Boot"):traceback():build()
local ROOT_PATH_ID = Index.ROOT_PATH_ID
local v2

if BuildInfo.CORE_BRANCH == "dev" and RunService:IsStudio() == false then
	v2 = GlobalUtil.FFlags.IsSandboxed == false
else
	v2 = false
end

local v3 = {}
local v4 = {}
local itemConfigLists = {}
local v5 = Display.JSON.new():setSortKeys(true):setUseMetatable(false):setIndentWith(""):build()
v.info("starting query init")
local v6 = Storage.dumpItems()
v.trace((`completed dumping #{#v6} items`))
local loaded = nil
local generated = script.Parent:FindFirstChild("Generated")
local queryIndex

if generated then
	queryIndex = generated:FindFirstChild("QueryIndex")
end

if queryIndex and Storage.usesBakedConfigs() then
	local load = Index.load
	local module = require(queryIndex)
	loaded = load(module, v6)

	if not loaded then
		warn("ItemConfig.Generated.QueryIndex is stale, hydrating query index at runtime instead - rerun the data build")
	end
elseif queryIndex then
	warn("ItemConfig.Generated.Configs was not used, hydrating query index at runtime instead - rerun the data build")
end

local v7 = loaded or Index.new()
v.trace((`loaded #{v7.BitCount} baked items`))
Index.hydrate(v7, v6)
v.trace("finished indexing items")

function decomposeAt(p, path, list)
	if p == nil then
		return
	end

	if type(p) == "table" then
		local operation = p.Operation

		if operation then
			if operation == "EQ" then
				local internAtom = Index.internAtom(v7, path, p.Value)
				table.insert(list, {
					Tag = "Atom",
					Atom = internAtom,
					Key = "a" .. internAtom
				})
			elseif operation == "NEQ" then
				local internAtom = Index.internAtom(v7, path, p.Value)
				table.insert(list, {
					Tag = "NotAtom",
					Atom = internAtom,
					Key = "n" .. internAtom
				})
			else
				if operation ~= "OR" and operation ~= "NOR" then
					error((`unknown query operation: "{tostring(operation)}"`))
					return
				end

				local v8 = {}

				for _, value in p.Values do
					table.insert(v8, Index.internAtom(v7, path, value))
				end

				table.sort(v8)
				local v9 = nil
				local atoms = {}

				for _, v11 in v8 do
					if v11 == v9 then
						continue
					end

					table.insert(atoms, v11)
					v9 = v11
				end

				local joined = table.concat(atoms, ",")

				if operation == "OR" then
					table.insert(list, {
						Tag = "Or",
						Atoms = atoms,
						Key = "o[" .. joined .. "]"
					})
				else
					table.insert(list, {
						Tag = "NotOr",
						Atoms = atoms,
						Key = "x[" .. joined .. "]"
					})
				end
			end
		else
			assert(#p == 0, (`arrays are not a valid query format: {v5:display(p)}`))

			if path ~= ROOT_PATH_ID and next(p) == nil then
				table.insert(list, {
					Tag = "Exists",
					Path = path,
					Key = "e" .. path
				})
			end

			for k, v8 in p do
				decomposeAt(v8, Index.internPath(v7, path, k), list)
			end
		end
	else
		local internAtom = Index.internAtom(v7, path, p)
		table.insert(list, {
			Tag = "Atom",
			Atom = internAtom,
			Key = "a" .. internAtom
		})
	end
end

function buildAst(list)
	table.sort(list, function(a, b)
		return a.Key < b.Key
	end)
	local key = nil
	local children = {}

	for _, v9 in list do
		if v9.Key == key then
			continue
		end

		table.insert(children, v9)
		key = v9.Key
	end

	local v9 = table.create(#children)

	for k, v10 in children do
		v9[k] = v10.Key
	end

	return {
		Tag = "And",
		Children = children,
		Key = "&[" .. table.concat(v9, "&") .. "]"
	}
end

function decomposeQuery(p)
	local v8 = {}
	decomposeAt(p, ROOT_PATH_ID, v8)
	return buildAst(v8)
end

function scopeFor(p)
	local v8 = v7.AtomToPath[p]
	local v9 = v7.PathParent[v8]

	if v9 == nil then
		return v7.AllItems
	end

	return v7.PathExists[v9] or v7.Empty
end

function evalChild(data)
	if data.Tag == "Atom" then
		return v7.AtomBitsets[data.Atom] or v7.Empty
	end

	if data.Tag == "Exists" then
		return v7.PathExists[data.Path] or v7.Empty
	end

	if data.Tag == "NotAtom" then
		local v8 = v4[data.Key]

		if v8 then
			return v8
		end

		local v9 = v7.AtomBitsets[data.Atom] or v7.Empty
		local v10 = scopeFor(data.Atom)
		local result = table.create(v7.WordCount, 0)

		for i = 1, v7.WordCount do
			result[i] = bit32.band(v10[i], (bit32.bnot(v9[i])))
		end

		v4[data.Key] = result
		return result
	elseif data.Tag == "Or" then
		local v8 = v4[data.Key]

		if v8 then
			return v8
		end

		local empty = Index.newEmpty(v7)

		for _, atom in data.Atoms do
			empty = Index.bor(v7, empty, v7.AtomBitsets[atom] or v7.Empty)
		end

		v4[data.Key] = empty
		return empty
	else
		if data.Tag ~= "NotOr" then
			error("unreachable")
			return
		end

		local v8 = v4[data.Key]

		if v8 then
			return v8
		end

		local v9 = "o[" .. table.concat(data.Atoms, ",") .. "]"
		local v10 = v4[v9]

		if not v10 then
			v10 = Index.newEmpty(v7)
			assert(v10, "bad bitset")

			for _, atom in data.Atoms do
				v10 = Index.bor(v7, v10, v7.AtomBitsets[atom] or v7.Empty)
			end

			v4[v9] = v10
		end

		assert(v10, "bad bitset")
		local v11 = scopeFor(data.Atoms[1])
		local result = table.create(v7.WordCount, 0)

		for i = 1, v7.WordCount do
			result[i] = bit32.band(v11[i], (bit32.bnot(v10[i])))
		end

		v4[data.Key] = result
		return result
	end
end

function evalAnd(p)
	if #p.Children == 0 then
		return v7.AllItems
	end

	local v8 = v4[p.Key]

	if v8 then
		return v8
	end

	if #p.Children == 1 then
		local v9 = evalChild(p.Children[1])
		v4[p.Key] = v9
		return v9
	else
		local v9 = table.create(#p.Children)

		for k, v10 in p.Children do
			local bs2 = evalChild(v10)
			v9[k] = {
				bs = bs2,
				pop = Index.popcount(v7, bs2),
				key = v10.Key
			}
		end

		table.sort(v9, function(a, b)
			return a.pop < b.pop
		end)
		local bs = v9[1].bs
		local v10 = { v9[1].key }

		for i = 2, #v9 do
			bs = Index.band(v7, bs, v9[i].bs)
			table.insert(v10, v9[i].key)
			local clone = table.clone(v10)
			table.sort(clone)
			local v11 = "&[" .. table.concat(clone, "&") .. "]"
			v4[v11] = bs
		end

		return bs
	end
end

function evaluateQuery(p)
	local v8 = decomposeQuery(p)
	return evalAnd(v8), v8.Key
end

function combineAnd(items)
	local v8 = {}

	for _, item in items do
		decomposeAt(item, ROOT_PATH_ID, v8)
	end

	local ast = buildAst(v8)
	return evalAnd(ast), ast.Key
end

function combineOr(items)
	local v8 = {}
	local v9 = {}
	local v10 = {}

	for _, item in items do
		local v11, v12 = evaluateQuery(item)

		if v8[v12] then
			continue
		end

		v8[v12] = true
		table.insert(v9, v12)
		v10[v12] = v11
	end

	table.sort(v9)
	local v11 = "|[" .. table.concat(v9, "|") .. "]"
	local v12 = v4[v11]

	if v12 then
		return v12, v11
	end

	local empty = Index.newEmpty(v7)

	for _, v13 in v9 do
		empty = Index.bor(v7, empty, v10[v13])
	end

	v4[v11] = empty
	return empty, v11
end

function materialize(p, p2: string)
	local v8 = itemConfigLists[p2]

	if v8 then
		return v8
	end

	local itemConfigList = Index.toItemConfigList(v7, p)
	table.freeze(itemConfigList)
	itemConfigLists[p2] = itemConfigList
	return itemConfigList
end

local Query = {
	select = function(p)
		debug.profilebegin("ItemConfig.Query.select")

		if v2 then
			v3[v5:display(p)] = p
		end

		local clone = table.clone(materialize(evaluateQuery(p)))
		debug.profileend()
		return clone
	end,
	selectOne = function(p)
		debug.profilebegin("ItemConfig.Query.selectOne")

		if v2 then
			v3[v5:display(p)] = p
		end

		local v8 = materialize(evaluateQuery(p))
		debug.profileend()

		if #v8 == 1 then
			return Result.ok(v8[1])
		end

		return Result.err((`query '{v5:display(p)}' did not return exactly one item, received {#v8}: {not (#v8 <= 3) and "..." or Display.JSON.new():setSortKeys(true):setIndentWith(" "):display(v8)}`))
	end,
	selectFirst = function(p)
		debug.profilebegin("ItemConfig.Query.selectFirst")

		if v2 then
			v3[v5:display(p)] = p
		end

		local v8 = materialize(evaluateQuery(p))
		debug.profileend()

		if #v8 > 0 then
			return Result.ok(v8[1])
		end

		return Result.err((`query '{v5:display(p)}' did not find a single item`))
	end,
	join = function(...)
		debug.profilebegin("ItemConfig.Query.join")

		if v2 then
			for _, v8 in { ... } do
				v3[v5:display(v8)] = v8
			end
		end

		local clone = table.clone(materialize(combineOr({ ... })))
		debug.profileend()
		return clone
	end,
	joinOne = function(...)
		debug.profilebegin("ItemConfig.Query.joinOne")

		if v2 then
			for _, v8 in { ... } do
				v3[v5:display(v8)] = v8
			end
		end

		local v8 = materialize(combineOr({ ... }))
		debug.profileend()

		if #v8 == 1 then
			return Result.ok(v8[1])
		end

		return Result.err((`joining queries '{v5:display({ ... })}' did not return exactly one item, received {#v8}: {not (#v8 <= 3) and "..." or Display.JSON.new():setSortKeys(true):setIndentWith(" "):display(v8)}`))
	end,
	joinFirst = function(...)
		debug.profilebegin("ItemConfig.Query.joinFirst")

		if v2 then
			for _, v8 in { ... } do
				v3[v5:display(v8)] = v8
			end
		end

		local v8 = materialize(combineOr({ ... }))
		debug.profileend()

		if #v8 > 0 then
			return Result.ok(v8[1])
		end

		return Result.err((`joining queries '{v5:display({ ... })}' did not return a single item`))
	end,
	overlap = function(...)
		debug.profilebegin("ItemConfig.Query.overlap")

		if v2 then
			for _, v8 in { ... } do
				v3[v5:display(v8)] = v8
			end
		end

		local clone = table.clone(materialize(combineAnd({ ... })))
		debug.profileend()
		return clone
	end,
	overlapOne = function(...)
		debug.profilebegin("ItemConfig.Query.overlapOne")

		if v2 then
			for _, v8 in { ... } do
				v3[v5:display(v8)] = v8
			end
		end

		local v8, v9 = combineAnd({ ... })
		local v10 = materialize(v8, v9)
		debug.profileend()

		if #v10 == 1 then
			return Result.ok(v10[1])
		end

		return Result.err((`overlapping queries '{v5:display({ ... })}' did not return exactly one item, received {#v10}: {not (#v10 <= 3) and "..." or Display.JSON.new():setSortKeys(true):setIndentWith(" "):display(v10)}`))
	end,
	check = function(value, p, p2)
		if type(value) == "string" then
			value = ItemId.getId(value, p):unwrap()
		end

		local v8 = p2 or p
		assert(type(v8) == "table", "bad query")
		local v9 = v7.ItemIdToBit[value]

		if not v9 then
			return false
		end

		debug.profilebegin("ItemConfig.Query.check")
		local v10 = Index.testBit(evaluateQuery(v8), v9)
		debug.profileend()
		return v10
	end
}

function diffAgainstLegacy(p)
	local v8 = Query.select(p)
	local v9 = Legacy.select(Storage.dumpItems(), p)
	local v10 = {}
	local v11 = {}

	for _, v12 in v8 do
		v10[v12.Index.ItemId] = true
	end

	for _, v12 in v9 do
		v11[v12.Index.ItemId] = true
	end

	local missing = {}
	local extra = {}

	for k in v11 do
		if not v10[k] then
			table.insert(missing, k)
		end
	end

	for k in v10 do
		if not v11[k] then
			table.insert(extra, k)
		end
	end

	table.sort(missing)
	table.sort(extra)
	return {
		missing = missing,
		extra = extra,
		ok = #missing + #extra == 0
	}
end

if v2 and GlobalUtil.FFlags.IsSandboxed ~= true then
	task.spawn(function()
		while true do
			task.wait(30)
			v.info("re-running history")
			local count = 0

			for k, v8 in v3 do
				task.wait(0.1)
				count += 1
				local v9 = diffAgainstLegacy(v8)

				if not v9.ok then
					warn((`query failed: {k}: {v5:display(v9)}`))
				end
			end

			v.info((`completed checking {count} queries`))
		end
	end)
end

return Query