local import = _G.import("event")
_G.import("global")
local import2 = _G.import("iterator")
_G.import("aura")
local import3 = _G.import("controller")
local import4 = _G.import("dictUtil")
_G.import("signalUtil")
local import5 = _G.import("settingCollection")
local import6 = _G.import("configuration")
local UserInputService = game:GetService("UserInputService")
game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local mouse = game.Players.LocalPlayer:GetMouse()
local keyCode = Enum.KeyCode
local _ = {
	"Save",
	"Block",
	"Set",
	"JumpSet",
	"Awaken",
	"Spike",
	"Bump",
	"TossCharge",
	"Cast1",
	"Cast2",
	"Cast3"
}
local v = {}
local v2 = {}
local v3 = {}
local lastTime = os.clock()

local function configKey(...)
	local v4 = { ... }
	local signalSet = table.remove(v4)
	local v6 = #v4
	local keySpecification = {}

	for _, v8 in pairs(v4) do
		local v9

		if v8 == "MouseButton1" or v8 == "MouseButton2" then
			v9 = Enum.UserInputType[v8]
		else
			v9 = keyCode[v8]
		end

		keySpecification[v9] = true
	end

	for k, _ in pairs(keySpecification) do
		local v8 = v[k] or {}
		v[k] = v8
		local v9 = {
			KeySpecification = keySpecification,
			SignalSet = signalSet
		}
		local v10 = nil

		for k2, v12 in pairs(v8) do
			if not (import4.count(v12.KeySpecification) <= v6) then
				continue
			end

			table.insert(v8, k2, v9)
			v10 = true
			break
		end

		if not v10 then
			table.insert(v8, v9)
		end
	end
end

local function getSignalSet(p, p2)
	local v4 = v[p]

	if not v4 then
		return
	end

	for _, v5 in pairs(v4) do
		local v6 = false

		for k, _ in pairs(v5.KeySpecification) do
			if p2[k] then
				continue
			end

			v6 = true
			break
		end

		if not v6 then
			return v5.SignalSet
		end
	end
end

local function mouseInputBegin(p, p2)
	lastTime = os.clock()
	v3.LastClicked = mouse.Hit

	if p2 then
		return
	end

	local userInputType = p.UserInputType
	v2[userInputType] = true
	local signalSet = getSignalSet(userInputType, v2)

	if signalSet then
		return unpack(signalSet.Begin or {})
	end
end

local function mouseInputEnd(p, _)
	lastTime = os.clock()
	local userInputType = p.UserInputType
	v2[userInputType] = nil
	local signalSet = getSignalSet(userInputType, {
		[userInputType] = true
	})

	if signalSet then
		return unpack(signalSet.End or {})
	end
end

local function keyboardInputBegin(p, p2)
	lastTime = os.clock()

	if p2 then
		return
	end

	local keyCode2 = p.KeyCode
	v2[keyCode2] = true
	local signalSet = getSignalSet(keyCode2, v2)
	return unpack(signalSet and signalSet.Begin or {})
end

local function keyboardInputEnd(p, _)
	lastTime = os.clock()
	local keyCode2 = p.KeyCode
	v2[keyCode2] = nil
	local signalSet = getSignalSet(keyCode2, {
		[keyCode2] = true
	})
	return unpack(signalSet and signalSet.End or {})
end

local v4 = { Enum.PreferredInput.KeyboardAndMouse, Enum.PreferredInput.Gamepad }
local v5 = {}
local v6 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function bindKey(p, p2, jSONEncode)
	v5[p] = v5[p] or {}
	table.insert(v5[p], p2)
	table.insert(v6[jSONEncode], p)
end

local function cacheKeybind(id, p2, data)
	if data.Type ~= "InputCapture" then
		return
	end

	local action = data.Action or {
		Id = id,
		Args = {}
	}
	local jSONEncode = HttpService:JSONEncode(action)
	local v7 = v6[jSONEncode]

	if v7 then
		for _, v8 in pairs(v7) do
			local v9 = v5[v8]
			table.remove(v9, import2.fromArray(v9):find(function(_, p3)
				return p3.Id == action.Id or data.EndAction and p3.Id == data.EndAction.Id
			end))
		end
	end

	v6[jSONEncode] = {}

	for _, v8 in pairs(v4) do
		local v9 = p2[v8.Value]
		bindKey(v9, action, jSONEncode) -- equivalent call inferred; original call site unknown

		if not data.EndAction then
			continue
		end

		bindKey(v9 .. "End", data.EndAction, jSONEncode) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cacheKeybinds(_)
	import5:run(function(_, _) end)
end

local v7 = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseButton2] = true
}

local function keybindAction(data, p)
	lastTime = os.clock()

	if p then
		return
	end

	local name = v7[data.UserInputType] and data.UserInputType.Name or data.KeyCode.Name

	if data.UserInputState.Name:sub(1, 3) == "End" then
		name ..= "End"
	end

	local v8 = v5[name]

	if not v8 then
		return
	end

	for _, v9 in pairs(v8) do
		if v9.Prerequisite and not v9.Prerequisite() then
			break
		else
			import.fire(v9.Id, unpack(v9.Args))
		end
	end
end

return {
	Priority = 1,
	Run = function()
		import.connect("dataLoaded", function(_, _)
			import3.defineInput("MouseButton1", "Begin", mouseInputBegin)
			import3.defineInput("MouseButton1", "End", mouseInputEnd)
			import3.defineInput("MouseButton2", "Begin", mouseInputBegin)
			import3.defineInput("MouseButton2", "End", mouseInputEnd)
			import3.defineInput("Keyboard", "Begin", keyboardInputBegin)
			import3.defineInput("Keyboard", "End", keyboardInputEnd)
			UserInputService.InputBegan:Connect(keybindAction)
			UserInputService.InputEnded:Connect(keybindAction)
			import.connect("settingChanged", function(_, ...)
				cacheKeybind(...)
			end)
			cacheKeybinds() -- equivalent call inferred; original call site unknown
			configKey("P", {
				Begin = { "showCmdr" }
			})

			repeat
				task.wait(1)
			until os.clock() - lastTime >= import6.AFK.Threshold

			import.fire("teleport", "Afk")
		end)
	end
}