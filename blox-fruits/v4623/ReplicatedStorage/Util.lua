local Players = game:GetService("Players")
local Error = require(game.ReplicatedStorage.Packages.Error)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")
local v = RunService:IsClient() and (Players.LocalPlayer and true or false)
local Global = require(game.ReplicatedStorage.Global)
Global.Encode = require(script.EncodeObj)

local function fn() end

local Global2 = require(game.ReplicatedStorage.Global)
Global2.TestGamePrint = fn
local Global3 = require(game.ReplicatedStorage.Global)
Global3.TestGameWarn = fn
task.spawn(function()
	repeat
		task.wait()
		local Global4 = require(game.ReplicatedStorage.Global)
	until Global4.TestGame ~= nil

	local warn2 = warn
	local getfenv2 = getfenv
	local tostring2 = tostring
	local print2 = print
	local v2 = {}
	local Global4 = require(game.ReplicatedStorage.Global)
	local Global5 = require(game.ReplicatedStorage.Global)
	local testGamePrint

	if Global5.TestGame then
		testGamePrint = function(...)
			v2.script = getfenv2(2).script
			local v4 = Error.trace(1)

			if not v4[1] then
				print2("[TestGame]:", ...)
				return
			end

			print2(`[TestGame|{v4[1].Source}:{tostring2(v4[1].LineNumber)}]:`, ...)
		end
	else
		testGamePrint = fn
	end

	Global4.TestGamePrint = testGamePrint
	local Global6 = require(game.ReplicatedStorage.Global)
	local Global7 = require(game.ReplicatedStorage.Global)
	local testGameWarn

	if Global7.TestGame then
		testGameWarn = function(...)
			v2.script = getfenv2(2).script
			local v5 = Error.trace(1)

			if not v5[1] then
				warn2("[TestGame]:", ...)
				return
			end

			warn2(`[TestGame|{v5[1].Source}:{tostring2(v5[1].LineNumber)}]:`, ...)
		end
	else
		testGameWarn = fn
	end

	Global6.TestGameWarn = testGameWarn
	local setfenv2 = setfenv
	local Global8 = require(game.ReplicatedStorage.Global)
	setfenv2(Global8.TestGameWarn, v2)
	local setfenv3 = setfenv
	local Global9 = require(game.ReplicatedStorage.Global)
	setfenv3(Global9.TestGamePrint, v2)
end)
local moduleScripts = {}
local v2 = {}
local modulesByName = {}

if v then
	local next2 = next
	local children, v3 = script:GetChildren()

	for _, moduleScript in next2, children, v3 do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		table.insert(moduleScripts, moduleScript)
		local v4 = moduleScript
		local v5 = task.spawn(function()
			local module = require(v4)
			modulesByName[v4.Name] = module
			table.insert(v2, v4)
		end)
		local v6 = moduleScript
		task.delay(20, function()
			if coroutine.status(v5) ~= "dead" then
				warn("WHY U NOT DONE", v6)
			end
		end)
	end

	while #moduleScripts ~= #v2 do
		task.wait()
	end
else
	local next2 = next
	local children, v3 = script:GetChildren()

	for _, moduleScript in next2, children, v3 do
		if not (moduleScript:IsA("ModuleScript") and (moduleScript:GetAttribute("LoadOnServer") or GlobalUtil.FFlags.IsSandboxed)) then
			continue
		end

		if GlobalUtil.FFlags.IsSandboxed == false then
			local v4 = moduleScript
			task.spawn(function()
				local v5 = modulesByName
				local name = v4.Name
				local module = require(v4)
				v5[name] = module
			end)
		else
			local name = moduleScript.Name
			local module = require(moduleScript)
			modulesByName[name] = module
		end
	end
end

local Util = {}

if not GlobalUtil.FFlags.IsSandboxed then
	return (setmetatable({}, {
		__index = function(_, p)
			return v and modulesByName[p] or require(script[p])
		end
	}))
end

for k, v3 in next, modulesByName, nil do
	Util[k] = v3
end

return Util