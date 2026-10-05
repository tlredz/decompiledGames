local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local Players = game:GetService("Players")
local CAM = ReplicatedStorage.CAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(CAM.Global.Utility)
local PartBox = require(CAM.Global.PartBox)
local manage_cd = require(CAM.Global.Subsets.Gameplay.manage_cd)
local Config = require(script.Parent.Config)
local PharmaceuticalSkillsServer = {
	Id = {}
}

local function resetCooldowns(instance)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter == nil then
		return
	end

	local filter_cd_name = manage_cd.filter_cd_name(playerFromCharacter, script.Parent.Name)
	local SHCS = instance:FindFirstChild("SHCS")

	if SHCS ~= nil then
		for _, numberValue in SHCS:GetChildren() do
			if numberValue:IsA("NumberValue") and numberValue.Name ~= filter_cd_name then
				numberValue:Destroy()
			end
		end
	end

	EffectsEvent.ToClient(playerFromCharacter, "reset_cooldowns", filter_cd_name)
end

local function admit(instance, instance2, p)
	if instance2 == nil then
		return
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if not (playerFromCharacter ~= nil and instance2:FindFirstChild(Config.OCCUPANT_VALUE) == nil) then
		return
	end

	Utility.AddValue(instance2, Config.OCCUPANT_VALUE)

	if p[playerFromCharacter] then
		return
	end

	p[playerFromCharacter] = true
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid ~= nil and humanoid.Health > 0 then
		humanoid.Health = math.min(humanoid.Health + humanoid.MaxHealth * Config.HEAL_RATIO, humanoid.MaxHealth)
	end

	resetCooldowns(instance)
end

local function openRing(character, cframe: CFrame)
	local v = {}
	local v2 = PartBox.new({
		Shape = "Cylinder",
		Center = cframe,
		Size = Config.ZONE_SIZE,
		MaxDuration = Config.DURATION,
		Allies = true,
		TouchCooldown = 0,
		caster = character,
		hitDetected = function(p, p2)
			admit(p, p2, v)
		end
	})

	if v2 == nil then
		return
	end

	v2.Left:Connect(function(_, instance)
		if instance == nil then
			return
		end

		local child = instance:FindFirstChild(Config.OCCUPANT_VALUE)

		if child ~= nil then
			child:Destroy()
		end
	end)
end

function PharmaceuticalSkillsServer.Hold(player, _, _)
	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.WINDUP)
	local v = PharmaceuticalSkillsServer.Id[player.UserId]
	task.wait(Config.WINDUP)

	if v ~= PharmaceuticalSkillsServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		return false
	end

	local cframe = CFrame.new(humanoidRootPart.Position)
	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"PharmaceuticalSkillsVFX",
		character,
		humanoidRootPart.CFrame,
		Config.DURATION,
		Config.VFX_LINGER
	)
	openRing(character, cframe)
	return true
end

function PharmaceuticalSkillsServer.Cancel(player, _, _)
	local character = player and player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
end

return PharmaceuticalSkillsServer