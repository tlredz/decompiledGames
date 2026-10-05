local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ServerClientPortal = require(CAM.Global.ServerClientPortal)
local Skill_Switch_Adder = require(CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local StatTypes = require(CAM.Global.Types.StatTypes)
local Utility = require(CAM.Global.Utility)
local Config = require(script.Parent.Config)
local BreathingBoostServer = {
	Id = {}
}
local name = script.Parent.Name
local v = name .. "Skill_Switch"
local object = setmetatable({}, {
	__mode = "k"
})

local function stop(p)
	local v2 = object[p]

	if v2 ~= nil then
		v2()
	end
end

function BreathingBoostServer.Hold(player, _, _)
	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local getvaluesfolder = Utility.getvaluesfolder(player)

	if humanoidRootPart == nil or humanoid == nil or getvaluesfolder == nil then
		return false
	end

	local stamina = getvaluesfolder:FindFirstChild("Stamina")
	local v2

	if stamina == nil then
		v2 = false
	else
		v2 = stamina:IsA("ValueBase") and typeof(stamina.Value) == "number"
	end

	if v2 and stamina.Value <= Config.STAMINA_FLOOR then
		return false
	end

	local v3 = object[player]

	if v3 ~= nil then
		v3()
	end

	local v4 = BreathingBoostServer.Id[player.UserId]
	EffectsEvent.ToAllInRange(humanoidRootPart, "BreathingBoostVFX", character, "Initiate")
	task.wait(Config.WINDUP)

	if v4 ~= BreathingBoostServer.Id[player.UserId] or (humanoidRootPart.Parent == nil or humanoid.Health <= 0) then
		return false
	end

	local boolValue = Instance.new("BoolValue")
	boolValue.Name = Config.BUFF_VALUE
	boolValue.Value = true
	boolValue:AddTag(StatTypes.ValueStatTag)
	boolValue:SetAttribute(StatTypes.StatToAttribute("Run Speed Factor"), Config.RUN_SPEED_FACTOR)
	boolValue:SetAttribute(StatTypes.StatToAttribute("Stamina Drain Rate"), Config.STAMINA_DRAIN)
	boolValue.Parent = getvaluesfolder
	local connections = {}
	local v5 = nil
	local flag = false
	local finish

	finish = function()
		if flag then
			return
		end

		flag = true

		if object[player] == finish then
			object[player] = nil
		end

		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)

		if boolValue.Parent ~= nil then
			boolValue:Destroy()
		end

		if v5 ~= nil and v5.__Active then
			v5:ToClient("End")
			v5:Destroy()
		end

		v5 = nil
		local child = player:FindFirstChild(v)

		if child ~= nil then
			child:Destroy()
		end

		if humanoidRootPart.Parent ~= nil then
			EffectsEvent.ToAllInRange(humanoidRootPart, "BreathingBoostVFX", character, "End")
		end
	end

	object[player] = finish

	if v2 then
		table.insert(connections, stamina:GetPropertyChangedSignal("Value"):Connect(function()
			if stamina.Value <= Config.STAMINA_FLOOR then
				finish()
			end
		end))
	end

	table.insert(connections, humanoid.Died:Connect(finish))
	task.delay(Config.DURATION, finish)
	v5 = ServerClientPortal.Create(player, name, Config.DURATION + 1)
	local v6 = false
	local v7 = 0
	v5:Connect(function(p)
		if flag then
			return
		end

		local v8 = p == true

		if v8 == v6 or os.clock() - v7 < 0.2 then
			return
		end

		local now = os.clock()
		v6 = v8
		v7 = now

		if humanoidRootPart.Parent == nil then
			return
		end

		EffectsEvent.ToAllInRange(humanoidRootPart, "BreathingBoostVFX", character, v6 and "Run" or "Stop")
	end)
	v5:ToClient("Start")
	Skill_Switch_Adder.Add(player, name, Config.DURATION)
	return true
end

function BreathingBoostServer.Switch(p)
	local v2 = object[p]

	if v2 ~= nil then
		v2()
	end
end

function BreathingBoostServer.Cancel(_) end

return BreathingBoostServer