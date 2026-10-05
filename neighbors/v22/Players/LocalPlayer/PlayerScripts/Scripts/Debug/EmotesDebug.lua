local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if not RunService:IsStudio() then
	return
end

local Iris = require(ReplicatedStorage.Modules.Iris)
local Network = require(ReplicatedStorage.Modules.Network)
local Emotes = require(ReplicatedStorage.Assets.Data.Store.Emotes)
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}

for k in Emotes do
	table.insert(v, k)
end

table.sort(v)

local function registerFieldState(value: string, p: string, object)
	local v3 = v2[value]

	if not v3 then
		v3 = {}
		v2[value] = v3
	end

	if v3[p] then
		return
	end

	v3[p] = object
	object:onChange(function(p2)
		local emote = Emotes[value]

		if emote then
			emote[p] = p2
		end

		if not applyingRemoteChange then
			Network:fire("EmoteTuneSet", value, p, p2)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rebuildEmoteWheel()
	local emoteWheel = localPlayer.PlayerGui:FindFirstChild("EmoteWheel")
	local radial = emoteWheel and emoteWheel:FindFirstChild("Radial")

	if not radial then
		return
	end

	local success, result = pcall(require, radial)

	if success then
		result:Rebuild()
	end
end

Network:listen("EmoteTuneSync", function(p: string, p2: string, p3)
	local emote = Emotes[p]

	if not emote then
		return
	end

	emote[p2] = p3
	local v3 = v2[p] and v2[p][p2]

	if v3 then
		applyingRemoteChange = true
		v3:set(p3)
		applyingRemoteChange = false
	end
end)
Iris.Init(nil, nil, true)
local state = Iris.State(false)
local state2 = Iris.State(v[1])
UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.K then
		state:set(not state.value)
	end
end)
Iris:Connect(function()
	if not state.value then
		return
	end

	Iris.Window({ "Emote Tuner" }, {
		isOpened = state
	})
	local state3 = Iris.State("")
	Iris.InputText({ "Search", "emote name" }, {
		text = state3
	})
	local value = string.lower(state3.value)

	if value == "" then
		Iris.ComboArray({ "Emote" }, {
			index = state2
		}, v)
	else
		local count = 0

		for _, v3 in v do
			local emote = Emotes[v3]
			local display = emote and emote.Display
			local v4 = string.find(string.lower(v3), value, 1, true) ~= nil
			local v5

			if display == nil then
				v5 = false
			else
				v5 = string.find(string.lower(display), value, 1, true) ~= nil
			end

			if not (v4 or v5) then
				continue
			end

			count += 1

			if count <= 10 then
				Iris.Selectable({ v3, v3 }, {
					index = state2
				})
			end
		end

		if count == 0 then
			Iris.Text({ "No emotes match" })
		elseif count > 10 then
			Iris.Text({ (`{count - 10} more hidden, keep typing`) })
		end
	end

	local value2 = state2.value
	local v3 = value2 and Emotes[value2]

	if v3 then
		Iris.PushId(value2)
		Iris.Text({ (`AnimationId: {v3.AnimationId}`) })
		Iris.Text({ (`Sync: {v3.Sync == true}`) })
		local state4 = Iris.State(v3.Offset or 2)
		registerFieldState(value2, "Offset", state4)
		Iris.DragNum({
			"Offset",
			0.05,
			0,
			10
		}, {
			number = state4
		})
		local state5 = Iris.State(v3.EmoteDelay or 0)
		registerFieldState(value2, "EmoteDelay", state5)
		Iris.DragNum({
			"EmoteDelay",
			0.05,
			0,
			5
		}, {
			number = state5
		})
		local state6 = Iris.State(v3.Grounded == true)
		registerFieldState(value2, "Grounded", state6)
		Iris.Checkbox({ "Grounded (emote no-clip)" }, {
			isChecked = state6
		})
		local state7 = Iris.State(v3.CanMove == true)
		registerFieldState(value2, "CanMove", state7)
		Iris.Checkbox({ "CanMove" }, {
			isChecked = state7
		})
		Iris.PopId()
	end

	if Iris.Button({ "Rebuild Emote Wheel" }).clicked() then
		rebuildEmoteWheel() -- equivalent call inferred; original call site unknown
	end

	Iris.End()
end)