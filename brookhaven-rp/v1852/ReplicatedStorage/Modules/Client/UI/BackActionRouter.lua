local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BackActionRouter = {}
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local Signal = require(ReplicatedStorage.Packages.Signal)
local t = require(ReplicatedStorage.Packages.t)
local value = Enum.ContextActionPriority.High.Value
local v = {}
local flag = false
local count = 0
local count2 = 0
local v2 = 0
local v3 = true
BackActionRouter.OnBackActionHandled = Signal.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function isHandlerAvailable(p)
	return not (p.isAvailable and not p.isAvailable())
end

local function getTopHandler()
	local v4 = nil

	for _, v5 in v do
		if not isHandlerAvailable(v5) then
			continue
		end

		if v4 then
			if v5.sortOrder > v4.sortOrder then
				v4 = v5
			end
		else
			v4 = v5
		end
	end

	return v4
end

function BackActionRouter.RunTopHandler()
	if not v3 then
		return false
	end

	local topHandler = getTopHandler()

	if not topHandler then
		return false
	end

	topHandler.run()
	BackActionRouter.OnBackActionHandled:Fire()
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindAction()
	if flag then
		return
	end

	ContextActionService:BindActionAtPriority("GlobalBackAction", function(_, p)
		if p ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		if BackActionRouter.RunTopHandler() then
			return Enum.ContextActionResult.Sink
		end

		return Enum.ContextActionResult.Pass
	end, false, value, Enum.KeyCode.ButtonB)
	flag = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unbindAction()
	if not flag then
		return
	end

	ContextActionService:UnbindAction("GlobalBackAction")
	flag = false
end

local function addHandler(p)
	count += 1
	count2 += 1
	local handlerId = count
	v[handlerId] = {
		handlerId = handlerId,
		sortOrder = count2,
		isAvailable = p.isAvailable,
		run = p.run
	}
	v2 += 1

	if v2 ~= 1 or flag then
		return handlerId
	end

	bindAction() -- equivalent call inferred; original call site unknown
	return handlerId
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeHandler(p: number)
	if not v[p] then
		return
	end

	v[p] = nil
	v2 -= 1

	if v2 <= 0 then
		v2 = 0
		unbindAction() -- equivalent call inferred; original call site unknown
	end
end

function BackActionRouter.Bind(run, callback2)
	assert(t.callback(run), "BackActionRouter.Bind expected run function")
	assert(callback2 == nil or t.callback(callback2), "BackActionRouter.Bind expected isAvailable function")
	local v4 = {
		isAvailable = callback2,
		run = run
	}
	count += 1
	count2 += 1
	local handlerId = count
	v[handlerId] = {
		handlerId = handlerId,
		sortOrder = count2,
		isAvailable = v4.isAvailable,
		run = v4.run
	}
	v2 += 1

	if v2 == 1 and not (flag or flag) then
		ContextActionService:BindActionAtPriority("GlobalBackAction", function(_, p)
			if p ~= Enum.UserInputState.Begin then
				return Enum.ContextActionResult.Pass
			end

			if BackActionRouter.RunTopHandler() then
				return Enum.ContextActionResult.Sink
			end

			return Enum.ContextActionResult.Pass
		end, false, value, Enum.KeyCode.ButtonB)
		flag = true
	end

	local flag2 = false
	return function()
		if flag2 then
			return
		end

		flag2 = true
		removeHandler(handlerId) -- equivalent call inferred; original call site unknown
	end
end

function BackActionRouter.FrameworkInit()
	task.spawn(function()
		local v4, v5 = ABTest.GetExperimentVariable("console-controls", "enabled"):timeout(7):await()

		if v4 and typeof(v5) == "boolean" then
			v3 = v5
		end
	end)
end

function BackActionRouter.GetBoundCount()
	return v2
end

function BackActionRouter.IsEmpty()
	return getTopHandler() == nil
end

return BackActionRouter