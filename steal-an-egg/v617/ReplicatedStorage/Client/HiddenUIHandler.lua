local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUI = require(ReplicatedStorage.Client.GUI)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local v = {
	Changed = Signal.new()
}
local v2 = { GUI.HUD(), GUI.Backpack(), GUI.OfflineMoneyInPlot() }
local v3 = 0
local thread = nil

local function isHidden()
	return v3 > 0
end

local function update()
	thread = nil
	local enabled = not (v3 > 0)

	for _, v5 in v2 do
		v5.Enabled = enabled
	end

	if not enabled then
		Tabs.Deactivate()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleUpdate()
	if thread then
		task.cancel(thread)
	end

	thread = task.defer(update)
end

function v.IsHidden()
	return v3 > 0
end

function v.Acquire()
	v3 += 1
	scheduleUpdate() -- equivalent call inferred; original call site unknown
	v.Changed:Fire(true)
	local flag = false
	return function()
		if flag then
			return
		end

		flag = true
		v3 -= 1
		assert(v3 >= 0, "hidden UI holder count became negative")
		scheduleUpdate() -- equivalent call inferred; original call site unknown
		v.Changed:Fire(v3 > 0)
	end
end

return table.freeze(v)