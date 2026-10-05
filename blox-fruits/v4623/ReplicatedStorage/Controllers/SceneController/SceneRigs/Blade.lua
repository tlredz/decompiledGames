local Blade = {}
require(game.ReplicatedStorage.Modules.Util.Trove)
require(game.ReplicatedStorage.Controllers.SceneController.Scene)
local TestRigUtil = require(game.ReplicatedStorage.Modules.Rig.TestRigUtil)
local SceneControllerUtil = require(game.ReplicatedStorage.Controllers.SceneController.SceneControllerUtil)
local Helper = require(game.ReplicatedStorage.Controllers.SceneController.SceneRigs.Helper)
local cframe = CFrame.new(0, 0.5, 0)
local v = {
	MinDistance = 0,
	MaxDistance = 50,
	MinSpeed = 5,
	MaxSpeed = 20
}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function Blade.Prewarm()
	SceneControllerUtil.prewarmVFX({ "Blade" })
end

function Blade.new(data)
	local scene = assert(data.Scene)
	local maid = scene._Maid:Extend()
	local v3 = Helper.new({
		Maid = maid,
		Scene = scene,
		PhysicalMoveset = data.PhysicalMoveset,
		SkinStorageName = data.SkinStorageName
	})
	local sequence = v3.Sequence
	local camera = v3.Camera
	local cameraController = camera.CameraController
	local rig = v3.Rig
	local rigClient = rig.RigClient
	maid:Add(TestRigUtil.connectOnRigAdded(localPlayer, function(_)
		rig.AssignRigToScene()
	end))

	if not TestRigUtil.tryFindRig(localPlayer) then
		task.spawn(rig.SpawnRig, {
			PhysicalMoveset = data.PhysicalMoveset,
			SkinStorageName = data.SkinStorageName
		})
	end

	local function fn(dt: number, p)
		rigClient.SendPos(v3.GetFacing(p))
		local setCFrame = camera.SetCFrame
		local solveViewModelCF = SceneControllerUtil.solveViewModelCF
		local v4 = {
			dt = dt,
			DistanceMul = sequence.GetCurrentSequence().Name == "Primary" and 4 or 3,
			Lerp = 0,
			FollowRotation = false,
			Offset = 0
		}
		local lerp

		if not camera.IsFirstCF() then
			lerp = v
		end

		v4.Lerp = lerp
		v4.Offset = cframe
		setCFrame(solveViewModelCF(p, v4))
	end

	local RunService = game:GetService("RunService")
	maid:Add(RunService.Heartbeat:Connect(function(dt: number)
		if not scene._Initiated then
			return
		end

		local v4 = rig.TryGetRig()

		if v4 then
			if camera.GetType() == "CameraSubject" then
				fn(dt, v4)
			elseif camera.GetType() == "Inspect" then
				local extents, v5 = TestRigUtil.getExtents(v4)
				local v6 = extents * cframe
				local solveInspectionCF = SceneControllerUtil.solveInspectionCF(cameraController._camera, {
					CameraController = cameraController,
					ComputeScreenOffsetSize = camera.GetViewportOffsetFn(),
					ViewportOffset = camera.GetViewportOffset(),
					Size = v5 * (sequence.GetCurrentSequence().Name == "Primary" and 4 or 3),
					Origin = v6.Position
				})
				camera.SetCFrame(camera.IsFirstCF() and solveInspectionCF or cameraController:GetCFrame():Lerp(
					solveInspectionCF,
					dt * SceneControllerUtil.getLerpSpeed(v4, v)
				))
			end
		end
	end))

	local function fn2(callback, maid2)
		return TestRigUtil.waitForCommandRig(localPlayer, function(p)
			rigClient.SkillDown("Z", v3.GetFacing(p.Model))
			maid2:Add(task.spawn(callback))
		end)
	end

	return v3.Init({
		Destroy = function()
			maid:Destroy()
		end,
		PlaySequence = function(p)
			return sequence.new(p, function(maid2, p2)
				if p2.Name == "Idle" then
					maid2:Add(task.delay(0, function()
						maid2:Add(fn2(function()
							p2.OnFinish()
						end, maid2))
					end))
				elseif p2.Name == "Primary" then
					maid2:Add(task.delay(0, function()
						maid2:Add(TestRigUtil.waitForCommandRig(localPlayer, function(p3)
							rigClient.SkillDown("X", v3.GetFacing(p3.Model))
							maid2:Add(task.delay(3.5, function()
								maid2:Add(fn2(p2.OnFinish, maid2))
							end))
						end))
					end))
				end
			end)
		end
	})
end

return Blade