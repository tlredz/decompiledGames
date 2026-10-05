local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(CAM.Global.Utility)
local Skill_Switch_Adder = require(CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local Config = require(script.Parent.Config)
local SpeedReflexServer = {
	Id = {}
}
local name = script.Parent.Name
local v = {
	Stun = true,
	CombatStun = true,
	Strict_Stun = true,
	RagDoll = true
}

function SpeedReflexServer.Hold(player, _, p)
	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	local v2 = SpeedReflexServer.Id[player.UserId]
	task.wait(Config.WINDUP)

	if v2 ~= SpeedReflexServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		return false
	end

	p.markCF = humanoidRootPart.CFrame
	Skill_Switch_Adder.Add(player, name, Config.SWITCH_WINDOW)
	EffectsEvent.ToAllInRange(humanoidRootPart, "SpeedReflexVFX", character, "Clone", p.markCF, Config.SWITCH_WINDOW)
	return true
end

function SpeedReflexServer.Switch(player, _, p)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local markCF

	if p ~= nil then
		markCF = p.markCF or nil
	end

	if humanoidRootPart == nil or markCF == nil then
		return
	end

	p.markCF = nil
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder ~= nil then
		for _, child in getvaluesfolder:GetChildren() do
			if v[child.Name] then
				child:Destroy()
			end
		end
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	local position = humanoidRootPart.Position
	character:PivotTo(markCF)
	EffectsEvent.ToAllInRange(humanoidRootPart, "SpeedReflexVFX", character, "Recall", markCF, position)
end

function SpeedReflexServer.Cancel(player, _, _)
	local character = player and player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
end

return SpeedReflexServer