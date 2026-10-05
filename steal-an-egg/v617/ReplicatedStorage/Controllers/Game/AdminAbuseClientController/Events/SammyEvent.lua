local SammyEvent = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SammyGuardSystem = require(script.SammyGuardSystem)
local StealingSystem = require(script.StealingSystem)
local Trove = require(ReplicatedStorage.Packages.Trove)
local UISystem = require(script.UISystem)
local CollectSystem = require(script.CollectSystem)
local collectSystem = CollectSystem(SammyEvent)
local LightingController = require(ReplicatedStorage.Controllers.Game.LightingController)
local sammyEventVisuals = ReplicatedStorage.Assets.SammyEventVisuals
local maid = Trove.new()
local v2 = false
local skipCutscenes = false

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayMusic()
	script.Music:Play()
	maid:Add(function()
		script.Music:Stop()
	end)
end

local function MuteDefaultMusic()
	TweenService:Create(SoundService.Music.GameMusic, TweenInfo.new(0.5), {
		Volume = 0
	}):Play()
	maid:Add(function()
		TweenService:Create(SoundService.Music.GameMusic, TweenInfo.new(0.5), {
			Volume = 1
		}):Play()
	end)
end

local function SetupSammyLightingAndMap()
	LightingController.SetLayer("SammyEventLighting", "SammyEvent", 999, 0.01)
	maid:Add(function()
		LightingController.ClearLayer("SammyEventLighting")
	end)
	local clone = sammyEventVisuals.Map:Clone()
	clone.Parent = Workspace
	maid:Add(clone)
end

local function warmSammyAssets()
	local v3 = {
		MeshPart = true,
		Decal = true,
		Animation = true,
		ParticleEmitter = true,
		Beam = true,
		ImageLabel = true
	}
	local descendants = {}

	for _, folder in {
		ReplicatedStorage.Assets.SammyEventVisuals,
		ReplicatedStorage.CutsceneAssets.SammyEventIntroVFX,
		ReplicatedStorage.CutsceneAssets.SammyEventIntroRigs,
		ReplicatedStorage.CutsceneAssets.SammyEventOutro1VFX,
		ReplicatedStorage.CutsceneAssets.SammyEventOutro1Rigs,
		ReplicatedStorage.CutsceneAssets.SammyEventOutro2VFX,
		ReplicatedStorage.CutsceneAssets.SammyEventOutro2Rigs,
		script,
		StarterGui.SammyEventUI
	} do
		for _, descendant in folder:GetDescendants() do
			local flag = false

			for className in v3 do
				if not descendant:IsA(className) then
					continue
				end

				flag = true
				break
			end

			if flag then
				table.insert(descendants, descendant)
			end
		end
	end

	print((`[{script.Name}] Preloading {#descendants} assets for sammy event`))
	ContentProvider:PreloadAsync(descendants)
	print((`[{script.Name}] Preloading completed`))
end

task.spawn(function()
	local now = os.time()

	if RunService:IsStudio() and now < 1789830000 then
		warmSammyAssets()
	elseif now < 1789826400 then
		task.wait(1789826400 - now)
		task.delay(math.random(180), warmSammyAssets)
	elseif now < 1789830000 then
		task.delay(math.random(60), warmSammyAssets)
	end
end)
SammyEvent.AssetTrove = maid

function SammyEvent.IsEventActive()
	return v2
end

function SammyEvent.StartEvent(_, p: number, options)
	local v3 = options or {}
	maid:Clean()
	v2 = true
	skipCutscenes = v3.SkipCutscenes
	Workspace:SetAttribute(
		"ScrambleHUDAwaitingSammyOutro",
		not skipCutscenes and Workspace:GetAttribute("ScrambleHUDUnlocked") ~= true
	)
	local serverTimeNow = Workspace:GetServerTimeNow()

	if not (v3.SkipCutscenes or v3.WasInProgress) then
		local IntroCutscene = require(script.Cutscenes.IntroCutscene)
		IntroCutscene(maid).Run()
	end

	local v4 = Workspace:GetServerTimeNow() - serverTimeNow
	SetupSammyLightingAndMap()
	MuteDefaultMusic()
	PlayMusic() -- equivalent call inferred; original call site unknown
	collectSystem.Start()
	SammyGuardSystem.Start(maid)
	StealingSystem.Start(maid)
	UISystem.Start(maid, Workspace:GetServerTimeNow() + p - v4)
end

function SammyEvent.StopEvent(_)
	v2 = false
	UISystem.Stop()
	StealingSystem.Stop()
	collectSystem.Clear()
	maid:Clean()

	if not skipCutscenes then
		local OutroCutscene1 = require(script.Cutscenes.OutroCutscene1)
		OutroCutscene1(maid).Run()
		local OutroCutscene2 = require(script.Cutscenes.OutroCutscene2)
		OutroCutscene2(maid).Run()
		maid:Clean()
	end

	Workspace:SetAttribute("ScrambleHUDAwaitingSammyOutro", nil)
end

return SammyEvent