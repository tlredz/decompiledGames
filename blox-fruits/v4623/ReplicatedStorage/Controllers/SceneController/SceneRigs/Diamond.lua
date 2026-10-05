local Diamond = {}
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

function Diamond.Prewarm()
	SceneControllerUtil.prewarmVFX({ "Diamond" })
end

function Diamond.new(data)
	local maid = data.Scene._Maid:Extend()
	local v2 = Helper.new({
		Maid = maid,
		Scene = data.Scene,
		PhysicalMoveset = data.PhysicalMoveset,
		SkinStorageName = data.SkinStorageName
	})
	local camera = v2.Camera
	local cameraController = camera.CameraController
	local rig = v2.Rig
	local rigClient = rig.RigClient
	local getFacing = v2.GetFacing
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
		rigClient.SendPos(getFacing(p))
		local setCFrame = camera.SetCFrame
		local solveViewModelCF = SceneControllerUtil.solveViewModelCF
		local lerp

		if not camera.IsFirstCF() then
			lerp = v
		end

		setCFrame(solveViewModelCF(p, {
			dt = dt,
			DistanceMul = 3,
			Lerp = lerp,
			FollowRotation = true,
			Offset = cframe
		}))
	end

	local RunService = game:GetService("RunService")
	maid:Add(RunService.Heartbeat:Connect(function(dt: number)
		if not data.Scene._Initiated then
			return
		end

		local v3 = rig.TryGetRig()

		if v3 then
			if camera.GetType() == "CameraSubject" then
				fn(dt, v3)
			elseif camera.GetType() == "Inspect" then
				local extents, v4 = TestRigUtil.getExtents(v3)
				local v5 = extents * cframe
				local solveInspectionCF = SceneControllerUtil.solveInspectionCF(cameraController._camera, {
					CameraController = cameraController,
					ComputeScreenOffsetSize = camera.GetViewportOffsetFn(),
					ViewportOffset = camera.GetViewportOffset(),
					Size = v4 * 3,
					Origin = v5.Position
				})
				camera.SetCFrame(camera.IsFirstCF() and solveInspectionCF or cameraController:GetCFrame():Lerp(
					solveInspectionCF,
					dt * SceneControllerUtil.getLerpSpeed(v3, v)
				))
			end
		end
	end))

	local function fn2(callback, maid2)
		return TestRigUtil.waitForCommandRig(localPlayer, function(p)
			rigClient.SkillDown("Z", getFacing(p.Model))
			maid2:Add(task.defer(callback))
		end)
	end

	local function fn3(fn4, maid2)
		return fn2(fn4, maid2)
	end

	return v2.Init({
		Destroy = function()
			maid:Destroy()
		end,
		PlaySequence = function(p)
			return v2.Sequence.new(p, function(maid2, p2)
				if p2.Name == "Idle" then
					maid2:Add(task.delay(0, function()
						maid2:Add(fn2(function()
							p2.OnFinish()
						end, maid2))
					end))
				elseif p2.Name == "Primary" then
					maid2:Add(task.delay(0, function()
						maid2:Add(fn3(function()
							p2.OnFinish()
						end, maid2))
					end))
				end
			end)
		end
	})
end

return Diamond