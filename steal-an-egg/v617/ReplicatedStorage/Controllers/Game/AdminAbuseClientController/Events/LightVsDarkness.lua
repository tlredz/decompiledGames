local LightVsDarkness = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ActiveAssetsController = require(script.Parent.Parent.Parent.Plots.ActiveAssetsController)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local PlacedEggRenderer = require(ReplicatedStorage.Shared.Eggs.PlacedEggRenderer)
local SubBiomeCycle = require(ReplicatedStorage.Shared.Util.SubBiomeCycle)
local Trove = require(ReplicatedStorage.Packages.Trove)
local RingSystem = require(script.RingSystem)
local ringSystem = RingSystem(LightVsDarkness)
local FlyingSystem = require(script.FlyingSystem)
local flyingSystem = FlyingSystem(LightVsDarkness)
local TeamSystem = require(script.TeamSystem)
local teamSystem = TeamSystem(LightVsDarkness)
local UISystem = require(script.UISystem)
local PowerUpSystem = require(script.PowerUpSystem)
local powerUpSystem = PowerUpSystem(LightVsDarkness)
local MusicSystem = require(script.MusicSystem)
local musicSystem = MusicSystem(LightVsDarkness)
local color = Color3.fromRGB(255, 138, 236)
local maid = Trove.new()
local v6 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function setPlotsHidden(flag: boolean)
	ActiveAssetsController.SetAllPetsHidden(flag)
	PlacedEggRenderer.SetAllHidden(flag)
end

LightVsDarkness.AssetTrove = maid

function LightVsDarkness.IsEventActive()
	return v6
end

function LightVsDarkness.StartEvent(_, p: number, p2)
	maid:Clean()
	v6 = true
	local v7

	if p2 and p2.WasInProgress then
		v7 = 0
	else
		local serverTimeNow = Workspace:GetServerTimeNow()
		local IntroCutscene = require(script.Cutscenes.IntroCutscene)
		local introCutscene = IntroCutscene(maid)
		setPlotsHidden(true) -- equivalent call inferred; original call site unknown
		maid:Add(function()
			setPlotsHidden(false) -- equivalent call inferred; original call site unknown
		end)
		introCutscene.Run()
		setPlotsHidden(false) -- equivalent call inferred; original call site unknown
		v7 = Workspace:GetServerTimeNow() - serverTimeNow
	end

	ringSystem.Start()
	flyingSystem.Start()
	teamSystem.Start()
	powerUpSystem.Start()
	musicSystem.Start()
	UISystem.Start(maid, Workspace:GetServerTimeNow() + p - v7 - 5)
end

function LightVsDarkness.StopEvent(_)
	v6 = false
	maid:Clean()
	flyingSystem.Stop()
	teamSystem.Stop()
	powerUpSystem.Stop()
	musicSystem.Stop()
	UISystem.Stop()
	task.wait(0.1)
	local LIGHT_VS_DARK_WINNER = Workspace:GetAttribute("LIGHT_VS_DARK_WINNER")

	if not LIGHT_VS_DARK_WINNER then
		error("Winner is nil")
		return
	end

	if LIGHT_VS_DARK_WINNER == "Light" then
		local EndCutsceneLight = require(script.Cutscenes.EndCutsceneLight)
		EndCutsceneLight(maid).Run()
		maid:Clean()
	elseif LIGHT_VS_DARK_WINNER == "Darkness" then
		local EndCutsceneDark = require(script.Cutscenes.EndCutsceneDark)
		EndCutsceneDark(maid).Run()
		maid:Clean()
	end

	if SubBiomeCycle.RevealPhaseAt("Light Dark", Workspace:GetServerTimeNow()) == "RevealNight" then
		Toast.Show({
			Lane = "Banner",
			Text = "⚔️ The battle was won... the Light and Dark biomes have arrived! One of 3 biomes can appear each night!",
			Color = color,
			Seconds = 8
		})
	end
end

return LightVsDarkness