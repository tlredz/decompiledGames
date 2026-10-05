local CelebrationRealmController = {
	IsMapLoaded = true,
	SpawnPoint = nil
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Flags = require(game.ReplicatedStorage.Modules.Flags)

if not Flags.CELEBRATION_REALM.ENABLED then
	return CelebrationRealmController
end

require(ReplicatedStorage.Reparent)
require(game.ReplicatedStorage.Util.StaticThread)
require(game.ReplicatedStorage.Packages.Result)
local Net = require(game.ReplicatedStorage.Modules.Net)
local runAsync = require(game.ReplicatedStorage.Util.runAsync)
require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)
local Realm = require(game.ReplicatedStorage.Util.Realm)
local localPlayer = game.Players.LocalPlayer
local remoteFunction = Net:RemoteFunction("CelebrationTeleport")
local v = nil

local function secondsUntilNextHourHalfMarker2(p: number?)
	local v2 = p or os.time()
	local v3 = os.date("*t", v2)
	local v4 = v3.sec + v3.min * 60 + v3.hour * 3600

	for i = 0, 24 do
		if v4 < i * 3600 + 1800 then
			return i * 3600 + 1800 - v4
		end
	end
end

tick()

function CelebrationRealmController.IsMapInWorkspace(_)
	return CelebrationRealmController.IsMapLoaded
end

function CelebrationRealmController.LockState(_)
	CelebrationRealmController.IsLoopStateLocked = true
end

function CelebrationRealmController.UnlockState(_)
	CelebrationRealmController.IsLoopStateLocked = false
end

function CelebrationRealmController:RequestLeaveIsland()
	runAsync(function()
		local WhiteCloudsTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.WhiteCloudsTransitionEffect)
		WhiteCloudsTransitionEffect.Play()
	end)
	local Sound = require(game.ReplicatedStorage.Util.Sound)
	local v2 = Sound:Play("GravFruit_M1_Meteor_IncomingLoop_01_V2", workspace._WorldOrigin)
	v2.PlaybackSpeed = 0.75
	v2.Volume = 0.65
	task.wait(1)
	remoteFunction:InvokeServer("Leave")
	task.wait(1.5)
	task.spawn(function()
		local Sound2 = require(game.ReplicatedStorage.Util.Sound)
		Sound2:FadeOut(v2)
	end)
	local WhiteCloudsTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.WhiteCloudsTransitionEffect)
	WhiteCloudsTransitionEffect.StopEarly()
	task.wait(1)
	v2:Stop()
end

local function GetBaseOni1Dialogue()
	require(game.ReplicatedStorage.Util.runAsync)

	if Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent") then
		return {
			Text = { "Tired so soon? I can take you back to the regular sea. Ready to go?" },
			Option1 = {
				Label = "Yes",
				JumpTo = function()
					remoteFunction:InvokeServer("CelebrationTeleport")
				end
			}
		}
	end

	return {
		Text = { "The Party Realm is waiting. I can teleport you straight into the fun. Want me to take you there?" },
		Option1 = {
			Label = "Yes",
			JumpTo = function()
				remoteFunction:InvokeServer("CelebrationTeleport")
			end
		}
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function REALM_TELEPORTER_INTERACT()
	return {
		Title = "Celebration Teleporter",
		Get = GetBaseOni1Dialogue
	}
end

function CelebrationRealmController.InitializeNPC(p)
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	v = DialogueController
	task.spawn(function()
		task.spawn(p.new, "Celebration Teleporter", function(_)
			return REALM_TELEPORTER_INTERACT()
		end, 4)
	end)
end

function CelebrationRealmController.OnStart()
	if Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent") then
		task.spawn(function()
			while task.wait(1) do
				pcall(function()
					local character = localPlayer.Character

					if character and character:GetPivot().Position.Y < 4500 then
						CelebrationRealmController:RequestLeaveIsland()
					end
				end)
			end
		end)
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	v = DialogueController
	local NPCTable = require(game.ReplicatedStorage.NPCTable)
	NPCTable.onLoaded(CelebrationRealmController.InitializeNPC)
end

CelebrationRealmController.Enabled = true
return CelebrationRealmController