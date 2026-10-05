local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local global = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global")
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local SoothingVoiceServer = {
	Id = {}
}

function SoothingVoiceServer.Hold(player, _, _)
	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.WINDUP + Config.ENDLAG)
	local v2 = SoothingVoiceServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, Config.WINDUP)
	v3:Connect(function()
		v2 = -1
		v4()
	end)
	task.wait(Config.WINDUP)

	if v2 ~= SoothingVoiceServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		v4()
		return false
	end

	EffectsEvent.ToAllInRange(player, "SoothingVoiceVFX", character)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.HITBOX_OFFSET,
		hitboxSize = Config.HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(p, p2, _)
			Combat_Util.Aggro(script, character, p)
			Utility.AddTimedValue(p2, Config.PIERCE_VALUE, Config.PIERCE_DURATION):SetAttribute(
				"Skill",
				script.Parent.Name
			)
		end
	})
	v4()
	return true
end

function SoothingVoiceServer.Cancel(player, _, _)
	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return SoothingVoiceServer