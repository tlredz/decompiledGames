local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local clock = os.clock
local child = game.ReplicatedStorage:WaitForChild("Player_Service"):WaitForChild("Values"):WaitForChild(game.Players.LocalPlayer.Name)
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Character_info_provider = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Character_info_provider"))
local curPower = game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Skills_Provider"):WaitForChild("CurPower")

function get_equipped_Combat()
	if game.Players.LocalPlayer.Character == nil then
		return
	end

	local get_equipped_tool = Character_info_provider.Get_equipped_tool(game.Players.LocalPlayer)
	local v

	if get_equipped_tool ~= nil then
		v = Items[get_equipped_tool.Name] or nil
	end

	if v ~= nil and v.CombatPreset ~= nil and v.CombatPreset ~= "Combat" then
		return get_equipped_tool.Name
	end

	for _, v2 in ipairs(string.split(curPower.Value, ",")) do
		if game.ReplicatedStorage.Assets.Animations:FindFirstChild(v2 .. "_Combat_Anims") then
			return v2
		end
	end

	if get_equipped_tool == nil or (Items[get_equipped_tool.Name] == nil or not Items[get_equipped_tool.Name].HasCombat) and not game.ReplicatedStorage.Assets.Animations:FindFirstChild(get_equipped_tool.Name .. "_Combat_Anims") then
		return
	else
		return get_equipped_tool.Name
	end
end

local Main_Combat_Script_Client = require(script:WaitForChild("Main_Combat_Script_Client"))
local intValue = Instance.new("IntValue", script)
intValue.Value = 1
intValue.Name = "ComboValue"
local v = 1
intValue.Changed:Connect(function()
	local v2 = math.random(1, 99999)
	v = v2
	task.wait(Combat_presets.combo_duration)

	if v2 == v then
		Main_Combat_Script_Client.CanAirCombo = true
		intValue.Value = 1
		Main_Combat_Script_Client.UpdraftRequested = false
	end
end)
local now = 0
local combovalue = 5

function punch()
	local v2 = get_equipped_Combat()
	local v3 = nil

	if v2 == nil then
		return
	end

	local preset = Combat_presets.Presets[v2]
	local combatPreset

	if preset == nil then
		if Items[v2] == nil or Items[v2].Breathing == nil and not Items[v2].HasCombat and Items[v2].CombatPreset == nil then
			combatPreset = v2
		else
			combatPreset = Items[v2].CombatPreset or "Regular Katana"
			v3 = v2
		end

		preset = Combat_presets.Presets[combatPreset]
	else
		combatPreset = v2
	end

	if preset == nil then
		warn("[Combat] No combat preset found for \"" .. tostring(combatPreset) .. "\"; add it to Combat_presets or set a valid CombatPreset on the item")
		return
	end

	local _ = intValue.Value
	local default = preset.default or 0.25

	if combovalue >= (preset.Max or 5) and intValue.Value < (preset.Max or 5) then
		default = preset.final or default
	end

	if not (default < clock() - now) then
		return default - (clock() - now)
	end

	if not (Checker.check(game.Players.LocalPlayer, "combat") == true and combatPreset ~= nil) then
		return nil
	end

	local v4 = Main_Combat_Script_Client.Do(intValue, preset, combatPreset, v3)

	if child:FindFirstChild("ComboTrackerClient") == nil then
		local intValue2 = Instance.new("IntValue")
		intValue2.Name = "ComboTrackerClient"
		intValue2.Value = intValue.Value
		local numberValue = Instance.new("NumberValue", intValue2)
		numberValue.Name = "Time"
		numberValue.Value = os.clock()
		intValue2.Parent = child
	else
		child.ComboTrackerClient.Value = intValue.Value
		child.ComboTrackerClient.Time.Value = os.clock()
	end

	Combat_presets.Last_Combo = intValue.Value

	if intValue.Value == (preset.Max or 5) or intValue.Value == 7 then
		intValue.Value = 1
	else
		intValue.Value += 1
	end

	now = clock()
	combovalue = v4.combovalue or preset.Max or 5
	local default2 = preset.default or 0.25

	if combovalue >= (preset.Max or 5) and intValue.Value < (preset.Max or 5) then
		default2 = preset.final or default2
	end

	return default2
end

local localPlayer = game.Players.LocalPlayer
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local mouse = localPlayer:GetMouse()

function hovering_click_detector()
	local v2 = false
	local target = mouse.Target

	if target ~= nil and localPlayer ~= nil and localPlayer.Character ~= nil and localPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil then
		local clickDetector = target:FindFirstChildOfClass("ClickDetector")
		return clickDetector ~= nil and clickDetector.MaxActivationDistance >= (localPlayer.Character.HumanoidRootPart.Position - target.Position).Magnitude or false
	end

	return v2
end

local count = 0
local holdChain

holdChain = function(p: number)
	if p ~= count or not InputHandler.IsDown("Combat") then
		return
	end

	local v2 = punch()

	if v2 == nil then
		return
	end

	task.delay(v2, holdChain, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startHold()
	count += 1
	local v2 = count

	if v2 == count then
		if not InputHandler.IsDown("Combat") then
			return
		end

		local v3 = punch()

		if v3 == nil then
			return
		else
			task.delay(v3, holdChain, v2)
		end
	end
end

InputHandler.ListenTo("Combat", function(p, p2)
	if p == "Down" then
		if p2 == false and hovering_click_detector() == false then
			if Platform_Handler.Platform.Value == "Mobile" and intValue.Value > 1 then
				Main_Combat_Script_Client.UpdraftRequested = true
			end

			count += 1
			local v2 = count

			if v2 == count then
				if not InputHandler.IsDown("Combat") then
					return
				end

				local v3 = punch()

				if v3 == nil then
					return
				end

				task.delay(v3, holdChain, v2)
			end
		end
	elseif p == "Up" then
		count += 1
	end
end)
InputHandler.Available:Connect(function(flag: boolean)
	if flag and InputHandler.IsDown("Combat") then
		startHold() -- equivalent call inferred; original call site unknown
	end
end)