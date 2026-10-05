local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local global = CAM:WaitForChild("Global")
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Checker = require(global.Checker)
local Utility = require(global.Utility)
local PartBox = require(global.PartBox)
local Clans = require(CAM.Clans)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local EnhancedHearingServer = {
	Id = {}
}

local function noteCaster(character, p, p2)
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder == nil then
		return
	end

	for _, objectValue in getvaluesfolder:GetChildren() do
		if objectValue.Name == Config.CASTER_NOTE_VALUE and objectValue:IsA("ObjectValue") and objectValue.Value == p then
			objectValue:Destroy()
		end
	end

	local v2 = Utility.AddTimedValue(getvaluesfolder, Config.CASTER_NOTE_VALUE, p2.duration, "ObjectValue", p)
	v2:SetAttribute("Damage", p2.damage)
	v2:SetAttribute("Skill", script.Parent.Name)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lineFor(character)
	local clanOfCharacter = Clans.ClanOfCharacter(character)
	return clanOfCharacter ~= nil and Config.BY_CLAN[clanOfCharacter] or Config.DEFAULT
end

function EnhancedHearingServer.Hold(player, _, p)
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
	local v2 = EnhancedHearingServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, 1)
	v3:Connect(function()
		v2 = -1
		v4()
	end)
	task.wait(Config.WINDUP)

	if v2 ~= EnhancedHearingServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		v4()
		return false
	end

	EffectsEvent.ToAllInRange(player, "EnhancedHearingVFX", character)
	local v5 = lineFor(character) -- equivalent call inferred; original call site unknown

	if p ~= nil and p.field ~= nil then
		p.field:Destroy()
		p.field = nil
	end

	local field = PartBox.new({
		Shape = "Ball",
		Center = humanoidRootPart.CFrame,
		Size = createVector(1, 1, 1) * ((v5.radius or Config.RADIUS) * 2),
		MaxDuration = Config.FIELD_DURATION,
		caster = character,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(p2, p3, p4)
			if p4 == "Perfect" then
				Combat_Util.Perfect(script, character, p2)
			elseif p4 == "Blocking" then
				Combat_Util.Block(script, character, p2, Config.BLOCK_BREAK)
			elseif p4 == true then
				Combat_Util.Aggro(script, character, p2)
				local v7 = Utility.AddTimedValue(p3, Config.MARK_VALUE, v5.duration, "ObjectValue", character)
				v7:SetAttribute("Damage", v5.damage)
				v7:SetAttribute("Caster", character.Name)
				v7:SetAttribute("Skill", script.Parent.Name)
				noteCaster(character, p2, v5)
			end
		end
	})

	if p ~= nil then
		p.field = field
	end

	v4()
	return true
end

function EnhancedHearingServer.Cancel(player, _, p)
	if player == nil then
		return
	end

	if p ~= nil and p.field ~= nil then
		p.field:Destroy()
		p.field = nil
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

return EnhancedHearingServer