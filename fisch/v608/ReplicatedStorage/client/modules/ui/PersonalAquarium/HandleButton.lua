local ReplicatedStorage = game:GetService("ReplicatedStorage")
require("./Types")
local ui = ReplicatedStorage.resources.sounds.sfx.ui
local sounds = script.Parent.Sounds
local v = nil
local clone = ui.click1:Clone()
clone.Volume = 1.5
clone.Parent = sounds
local endedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function resetRunningSound()
	if v then
		v:Stop()
		v = nil
	end

	if endedConnection then
		endedConnection:Disconnect()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function forcePlaySound(object)
	resetRunningSound() -- equivalent call inferred; original call site unknown
	v = object
	object:Play()
	endedConnection = object.Ended:Once(function()
		v = nil
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function animator(uIStroke)
	local flag = false
	return function()
		if flag then
			return
		end

		flag = true
		uIStroke.Enabled = false
		task.wait(0.2)

		if uIStroke and uIStroke.Parent then
			uIStroke.Enabled = true
		end

		flag = false
	end
end

local function handleButton(instance, callback, flag: boolean?)
	local uIStroke = instance:FindFirstChildWhichIsA("UIStroke")
	local v2

	if uIStroke then
		v2 = animator(uIStroke)
	else
		v2 = nil
	end

	local activatedConnection = instance.Activated:Connect(function()
		if v2 then
			task.defer(v2)
		end

		forcePlaySound(clone) -- equivalent call inferred; original call site unknown
		callback()
	end)
	return flag and function(callback2)
		activatedConnection:Disconnect()
		activatedConnection = instance.Activated:Connect(function()
			task.defer(v2)
			forcePlaySound(clone) -- equivalent call inferred; original call site unknown
			callback2()
		end)
	end or nil
end

return handleButton