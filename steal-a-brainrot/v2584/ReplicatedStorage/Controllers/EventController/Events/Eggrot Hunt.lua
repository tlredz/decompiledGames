local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Shared.EventTypes)
local BaseIndexController = require(ReplicatedStorage.Controllers.BaseIndexController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local WorldBrainrotController = require(ReplicatedStorage.Controllers.WorldBrainrotController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local CandyMerchantUI = require(script.CandyMerchantUI)
local GalaxyDoorVisuals = require(script.GalaxyDoorVisuals)
local VolcanoCraftingUI = require(script.VolcanoCraftingUI)
local JumpShopUI = require(script.JumpShopUI)
local CloudVisuals = require(script.CloudVisuals)
local CoinVisuals = require(script.CoinVisuals)
local UFOVisuals = require(script.UFOVisuals)
local VolcanoVisuals = require(script.VolcanoVisuals)
local CageVisuals = require(script.CageVisuals)
local HarpVisuals = require(script.HarpVisuals)
local JumpShopTutorial = require(script.JumpShopTutorial)
local name = script.Name

local function isLocalPlayerInZone(items)
	local character = Players.LocalPlayer and Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return false
	end

	for _, item in items do
		if MathUtils.isPointInVolume(humanoidRootPart.Position, item.CFrame, item.Size) then
			return true
		end
	end

	return false
end

local maid = Trove.new()
local EggrotHunt = {}

function EggrotHunt.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	maid:Add(function()
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
	end)
	EffectController:Activate("Blink")
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
	maid:Add(BaseIndexController:Register({
		Id = "Easter",
		IndexName = "Easter",
		SkinName = "Easter",
		ScreenGuiName = "EasterBase",
		FramePath = "EasterBase",
		MotorTag = "EasterBaseMotor",
		PromptTag = "EasterBasePrompt"
	}))
	maid:Add(Observers.observeTag("HideInEggrotHunt", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			p.Parent = parent
		end
	end))
	maid:Add(CloudVisuals:Start())
	maid:Add(UFOVisuals:Start())
	maid:Add(CandyMerchantUI:Start())
	maid:Add(GalaxyDoorVisuals:Start())
	maid:Add(JumpShopUI:Start())
	maid:Add(JumpShopTutorial:Start())
	local renderedBrainrots = {}
	ReplicatorClient.get("EggrotHunt/Brainrots")
	local v2, v3 = CageVisuals:Start(renderedBrainrots)
	maid:Add(v2)
	maid:Add(WorldBrainrotController:RenderPool({
		PoolId = "EggrotHunt/Brainrots",
		ReplicatorId = "EggrotHunt/Brainrots",
		ShowTimer = true,
		ShowDropButton = true,
		GrabHoldDuration = 2,
		GrabMaxDistance = 10,
		RenderedBrainrots = renderedBrainrots,
		OnRendered = function(p: string)
			local v4 = renderedBrainrots[p]

			if v4 and v4.prompt then
				v3(p)
			end
		end
	}))
	maid:Add(VolcanoVisuals:Start(renderedBrainrots))
	maid:Add(VolcanoCraftingUI:Start())
	maid:Add(HarpVisuals:Start(renderedBrainrots))
	maid:Add(RunService.Heartbeat:Connect(function()
		local character = Players.LocalPlayer and Players.LocalPlayer.Character

		if not character then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			return
		end

		local _speed = humanoid:GetAttribute("_speed")

		if _speed and humanoid.WalkSpeed < _speed then
			humanoid.WalkSpeed = _speed
		end
	end))
	local v4 = 0
	maid:Add(Observers.observeTag("JumpPad", function(part)
		if not part:IsA("BasePart") then
			return nil
		end

		local touchedConnection = part.Touched:Connect(function(otherPart)
			if not otherPart.Parent then
				return
			end

			local now = os.clock()

			if now - v4 < 0.5 then
				return
			end

			local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

			if playerFromCharacter and playerFromCharacter == Players.LocalPlayer then
				v4 = now
				SoundController:PlaySound("Sounds.Events.Easter.Trampoline", part.Position, false)
			end
		end)
		return function()
			touchedConnection:Disconnect()
		end
	end, { workspace }))
	return nil
end

function EggrotHunt.OnStop(_)
	maid:Destroy()
end

function EggrotHunt:OnLoad()
	CoinVisuals:OnLoad()
end

return EggrotHunt