local class = {}
class.__index = class
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Director"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local v = {}
local v2 = {}

local function testprint(...)
	local Global = require(game.ReplicatedStorage.Global)
	Global = Global.TestGame
end

RunService.Heartbeat:Connect(function()
	if FX.FX_UNLOADING_ENABLED == false then
		return
	end

	local now = tick()

	for k in v2 do
		local v3 = v[k]

		if v3 == nil then
			v2[k] = nil
		elseif now - v3.EmptyTimestamp >= FX.FX_REMOVAL_LIFETIME then
			v2[k] = nil
			testprint((`[FXInherit] {k} has been unloaded`))
			FX:Return(k)
		end
	end
end)

function class:Init()
	local fXNames = string.split(self.Instance:GetAttribute("FolderReferences"), "##")
	self.FXNames = fXNames
	testprint((`[FXInherit] preloading FX for {self.Instance:GetFullName()}`))

	for _, v4 in fXNames do
		if v4 == "" then
			continue
		end

		testprint((`[FXInherit] preloading FX.{v4} from {self.Instance:GetFullName()}`))
		local v5 = v[v4]

		if v5 == nil then
			v5 = {
				EmptyTimestamp = 0,
				List = {}
			}
			v[v4] = v5
		end

		v5.List[self.Instance] = true

		if v2[v4] then
			v2[v4] = nil
		end

		task.spawn(FX.Get, FX, v4)
	end
end

function class.Destroy(p)
	testprint((`[FXInherit] inheritor {p.Instance:GetFullName()} is being removed`))

	for _, fXName in p.FXNames do
		local v3 = v[fXName]

		if not (v3 and v3.List[p.Instance]) then
			continue
		end

		v3.List[p.Instance] = nil

		if not (next(v3.List) == nil and FX.FX_UNLOADING_ENABLED) then
			continue
		end

		v3.EmptyTimestamp = tick()
		v2[fXName] = true
		testprint((`{fXName} has been queued for removal`))
	end
end

return {
	new = function(instance, _)
		return (setmetatable({
			Instance = instance,
			FXNames = {}
		}, class))
	end,
	ancestor = nil
}