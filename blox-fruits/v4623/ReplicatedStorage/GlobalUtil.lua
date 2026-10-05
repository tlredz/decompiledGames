local Type = require(game.ReplicatedStorage.Packages.Type)
require(game.ReplicatedStorage.Packages.Option)
require(game.ReplicatedStorage.Packages.Future)
require(game.ReplicatedStorage.Packages.Result)
require(game.ReplicatedStorage.Packages.Error)
local Global = require(game.ReplicatedStorage.Global)
local GlobalUtil = {}
local v = {
	TestGame = Type.boolean,
	IsUnitTest = Type.boolean,
	IsSandboxed = Type.boolean,
	TestGamePrint = Type.boolean,
	TestGameWarn = Type.boolean,
	__REACT_MICROPROFILER_LEVEL = Type.optional(Type.integer),
	__DEV__ = Type.boolean
}
GlobalUtil.FFlags = setmetatable({}, {
	__index = function(_, p: string)
		if p == "IsUnitTest" and workspace:HasTag("ENABLE_UNIT_TEST") then
			Global.IsUnitTest = true
		end

		local v2 = v[p]

		if v2 == nil then
			error((`unsupported fflag: {p}`))
		end

		if Type.boolean == v2 and Global[p] == nil then
			Global[p] = false
		end

		local v3 = Global[p]
		local v4, v5 = v2(v3)

		if v4 then
			return v3
		end

		warn((`Global["{p}"] doesn't match expected type: {v5}`))
		return v3
	end,
	__newindex = function(_, p: string, p2)
		local v2 = v[p]

		if v2 == nil then
			error((`unsupported fflag: {p}`))
		end

		local v3, v4 = v2(p2)
		assert(v3, (`fflag set failed for {p}: {v4}`))
		Global[p] = p2
	end
})

function GlobalUtil.setCurrentlyStoringItem(currentlyStoringItem: string?)
	Global.CurrentlyStoringItem = currentlyStoringItem
end

function GlobalUtil.tryGetCurrentlyStoringItem()
	return Global.CurrentlyStoringItem
end

function GlobalUtil.testPrintAsync(...)
	if GlobalUtil.FFlags.IsSandboxed then
		print(...)
		return
	end

	while not GlobalUtil.FFlags.TestGamePrint do
		task.wait()
	end

	Global.TestGamePrint(...)
end

function GlobalUtil.testWarnAsync(...)
	if GlobalUtil.FFlags.IsSandboxed then
		warn(...)
		return
	end

	while not GlobalUtil.FFlags.TestGameWarn do
		task.wait()
	end

	Global.TestGameWarn(...)
end

return GlobalUtil