local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Log = require(ReplicatedStorage.Packages.Log)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = {
	[Enum.PreferredInput.Gamepad] = "Console",
	[Enum.PreferredInput.KeyboardAndMouse] = "Desktop",
	[Enum.PreferredInput.Touch] = "Mobile"
}
local v2 = {
	Changed = Signal.new()
}
local v3 = Log.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function detect()
	return v[UserInputService.PreferredInput] or "Desktop"
end

local v4 = detect() -- equivalent call inferred; original call site unknown

function v2.Platform()
	return v4
end

function v2.IsConsole()
	return v4 == "Console"
end

function v2.IsDesktop()
	return v4 == "Desktop"
end

function v2.IsMobile()
	return v4 == "Mobile"
end

function v2.Observe(onChanged)
	local changedConnection = v2.Changed:Connect(onChanged)
	onChanged(v4)
	return function()
		changedConnection:Disconnect()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function announce(p: string)
	v3:AtInfo():Log((`client now presents as {p}`))
end

local function reconcile()
	local v5 = detect() -- equivalent call inferred; original call site unknown

	if v5 == v4 then
		return
	end

	v4 = v5
	v2.Changed:Fire(v5)
	announce(v5) -- equivalent call inferred; original call site unknown
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(reconcile)
announce(v4) -- equivalent call inferred; original call site unknown
return table.freeze(v2)