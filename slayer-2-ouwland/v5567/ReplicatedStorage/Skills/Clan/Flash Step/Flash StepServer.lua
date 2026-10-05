local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local Utility = require(CAM.Global.Utility)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)

-- equivalent calls inferred from this helper; original call sites unknown
local function reappear(p)
	if p == nil then
		return
	end

	local invisibility = p.invisibility
	p.invisibility = nil

	if invisibility ~= nil and invisibility.Parent ~= nil then
		invisibility:Destroy()
	end
end

local FlashStepServer = {}
FlashStepServer.Id = {}

function FlashStepServer.Hold(player, _, p)
	local character = player.Character

	if character == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder == nil then
		return
	end

	reappear(p) -- equivalent call inferred; original call site unknown
	p.invisibility = Utility.AddValue(getvaluesfolder, Config.INVISIBILITY_VALUE, Config.MAX_HOLD + Config.ENDLAG)
	p.invisibility:SetAttribute("KeepsAggro", true)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart ~= nil then
		EffectsEvent.ToAllInRange(humanoidRootPart, "FlashStepVFX", character, "Vanish")
	end
end

function FlashStepServer.UnHold(player, _, p)
	reappear(p) -- equivalent call inferred; original call site unknown
	local character = player.Character

	if character == nil then
		return false
	end

	Utility.AddValue(Utility.getvaluesfolder(character), "pause_gameplay", Config.ENDLAG)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart ~= nil then
		EffectsEvent.ToAllInRange(humanoidRootPart, "FlashStepVFX", character, "Reappear")
	end

	return false
end

function FlashStepServer.Cancel(player, _, p)
	reappear(p) -- equivalent call inferred; original call site unknown
	local character = player and player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "FlashStepVFX", character, "Reappear")
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
end

return FlashStepServer