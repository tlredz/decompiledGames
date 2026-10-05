local SubmergedIslandController = {
	IsMapLoaded = true,
	SpawnPoint = nil
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Realm = require(game.ReplicatedStorage.Util.Realm)

if Realm.getIfCurrentRealmHasTagAsync("IsThirdSea") == false then
	return SubmergedIslandController
end

local Reparent = require(ReplicatedStorage.Reparent)
local StaticThread = require(game.ReplicatedStorage.Util.StaticThread)
local Net = require(game.ReplicatedStorage.Modules.Net)
local runAsync = require(game.ReplicatedStorage.Util.runAsync)
local submergedIsland = workspace.Map:WaitForChild("Submerged Island")
local localPlayer = game.Players.LocalPlayer
local position = submergedIsland:GetPivot().Position
local remoteFunction = Net:RemoteFunction("SubmarineTransportation")
local v = nil
local v2 = 0
local map = Reparent.CreateMap(submergedIsland)
local v3 = false

function SubmergedIslandController:IsMapInWorkspace()
	return SubmergedIslandController.IsMapLoaded
end

function SubmergedIslandController.LockState(_)
	SubmergedIslandController.IsLoopStateLocked = true
end

function SubmergedIslandController.UnlockState(_)
	SubmergedIslandController.IsLoopStateLocked = false
end

function SubmergedIslandController:LoadMap()
	if not self:IsMapInWorkspace() then
		v2 = tick() + 15
		Reparent.Parent(map, 0.001, function(p)
			if p then
				SubmergedIslandController.IsMapLoaded = true

				if not v3 then
					v3 = true

					for _, moduleScript in script.MapComponents:GetChildren() do
						require(moduleScript)
					end
				end

				task.delay(10, function()
					v:Start()
				end)
			end
		end)
	end
end

function SubmergedIslandController:UnloadMap()
	if self:IsMapInWorkspace() then
		Reparent.Unparent(map, 0.001, function(p)
			if p then
				SubmergedIslandController.IsMapLoaded = false
			end
		end)
	end
end

function SubmergedIslandController.RequestLeaveIslandAbnormally(_)
	runAsync(function()
		local MapTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.MapTransitionEffect)
		MapTransitionEffect.Play()
	end)
	task.wait(0.25)
	remoteFunction:InvokeServer("LeaveAbnormally")
	task.wait(1)
end

v = StaticThread.new(function(_)
	if SubmergedIslandController.IsLoopStateLocked then
		return false
	end

	local v4 = SubmergedIslandController.SpawnPoint.Value == "SubmergedIsland"
	local character = localPlayer.Character

	if not character then
		return false
	end

	local v5 = character:GetPivot().Position - position

	if v5.Magnitude > 5000 and not v4 then
		if SubmergedIslandController.IsMapLoaded and v2 < tick() then
			SubmergedIslandController:UnloadMap()
		end
	elseif SubmergedIslandController.IsMapLoaded then
		local _ = v5.Magnitude < 3000
	else
		SubmergedIslandController:LoadMap()
	end

	return false
end, 0.01)

function SubmergedIslandController.OnStart(_)
	SubmergedIslandController.SpawnPoint = localPlayer:WaitForChild("Data"):WaitForChild("LastSpawnPoint")

	if SubmergedIslandController.IsMapLoaded and not v3 then
		v3 = true

		for _, moduleScript in script.MapComponents:GetChildren() do
			require(moduleScript)
		end
	end

	v:Start()
end

return SubmergedIslandController