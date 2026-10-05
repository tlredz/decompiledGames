local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(CAM.Global.Utility)
local Checker = require(CAM.Global.Checker)
local Menum = require(CAM.Global.Menum)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local SkillPassiveToggleSignal = require(CAM.Global.Subsets.Gameplay.SkillPassiveToggleSignal)
local Config = require(script.Parent.Config)
local MusicalScoreServer = {
	Id = {}
}

local function commit(character, humanoidRootPart, instance, recorded: string)
	for _, child in instance:GetChildren() do
		if child.Name == "SkillToggle" and child:GetAttribute("OnlySkill") == recorded then
			child:Destroy()
		end
	end

	local v = SkillPassiveToggleSignal.new(character, script.Parent.Name, {
		amount = 1,
		toggleType = Menum.toggleSkillType.iframe,
		mode = Menum.toggleSkillMode.skill,
		duration = Config.IMPRINT_DURATION
	})

	if v == nil then
		return
	end

	v:SetAttribute("OnlySkill", recorded)
	v:SetAttribute("LatchFor", Config.DODGE_WINDOW)
	EffectsEvent.ToAllInRange(humanoidRootPart, "MusicalScoreVFX", character)
end

function MusicalScoreServer.Hold(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.WINDUP)
	local v = MusicalScoreServer.Id[player.UserId]
	local v2, v3 = ManuelCancel.new(player, Config.WINDUP)
	v2:Connect(function()
		v = -1
		v3()
	end)
	task.wait(Config.WINDUP)

	if v ~= MusicalScoreServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		v3()
		return false
	end

	local counter = getvaluesfolder:FindFirstChild("Counter")

	if counter ~= nil then
		counter:Destroy()
	end

	local v4 = Utility.AddTimedValue(
		getvaluesfolder,
		"Counter",
		Config.LISTEN_DURATION,
		"StringValue",
		script.Parent.Name
	)
	v4:SetAttribute("Type", Menum.CounterType.AllExceptCombat)
	v4:SetAttribute("Record", true)
	v4:GetAttributeChangedSignal("Recorded"):Connect(function()
		local recorded = v4:GetAttribute("Recorded")

		if recorded == nil then
			return
		end

		v4:Destroy()
		commit(character, humanoidRootPart, getvaluesfolder, recorded)
		EffectsEvent.ToAllInRange(humanoidRootPart, "MusicalScoreVFX", character)
	end)
	EffectsEvent.ToAllInRange(humanoidRootPart, "MusicalScoreVFX", character)
	v3()
	return true
end

function MusicalScoreServer.Toggle(player, p, _: number?, _)
	local character = player.Character

	if character == nil or p == nil then
		return
	end

	Checker.PlayDodge(character)
	EffectsEvent.ToAllInRange(player, "MusicalScoreVFX", character)
end

function MusicalScoreServer.Cancel(_) end

return MusicalScoreServer