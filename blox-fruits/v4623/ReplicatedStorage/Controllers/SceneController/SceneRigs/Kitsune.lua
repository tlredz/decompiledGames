local Kitsune = {}
require(game.ReplicatedStorage.Modules.Util.Trove)
require(game.ReplicatedStorage.Controllers.SceneController.Scene)
local TestRigUtil = require(game.ReplicatedStorage.Modules.Rig.TestRigUtil)
local SceneControllerUtil = require(game.ReplicatedStorage.Controllers.SceneController.SceneControllerUtil)
local Helper = require(game.ReplicatedStorage.Controllers.SceneController.SceneRigs.Helper)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local cframe = CFrame.new(0, 0, 0)
local cframe2 = CFrame.new(0, 0, 0)
local v = {
	MinDistance = 0,
	MaxDistance = 15,
	MinSpeed = 5,
	MaxSpeed = 15
}

function Kitsune.Prewarm()
	SceneControllerUtil.prewarmVFX({ "Kitsune" })
end

function Kitsune.new(data)
	local maid = data.Scene._Maid:Extend()
	local v2 = Helper.new({
		Maid = maid,
		Scene = data.Scene,
		PhysicalMoveset = data.PhysicalMoveset,
		SkinStorageName = data.SkinStorageName
	})
	local camera = v2.Camera
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

	local v3 = false

	local function fn(dt: number, p)
		rigClient.SendPos(getFacing(p))
		local setCFrame = camera.SetCFrame
		local solveViewModelCF = SceneControllerUtil.solveViewModelCF
		local v4 = {
			dt = dt,
			DistanceMul = v3 and 6 or 3,
			Offset = 0,
			Lerp = 0,
			FollowRotation = false
		}
		local offset

		if v3 then
			offset = cframe
		else
			offset = cframe2
		end

		v4.Offset = offset
		local lerp

		if not camera.IsFirstCF() then
			lerp = v
		end

		v4.Lerp = lerp
		setCFrame(solveViewModelCF(p, v4))
	end

	local RunService = game:GetService("RunService")
	maid:Add(RunService.Heartbeat:Connect(function(dt: number)
		if not data.Scene._Initiated then
			return
		end

		local v4 = rig.TryGetRig()

		if v4 then
			if camera.GetType() == "CameraSubject" then
				fn(dt, v4)
			elseif camera.GetType() == "Inspect" then
				local extents, v5 = TestRigUtil.getExtents(v4)
				local v6

				if v3 then
					v6 = cframe
				else
					v6 = cframe2
				end

				local v7 = extents * v6
				local solveInspectionCF = SceneControllerUtil.solveInspectionCF(camera.CameraController._camera, {
					CameraController = camera.CameraController,
					ComputeScreenOffsetSize = camera.GetViewportOffsetFn(),
					ViewportOffset = camera.GetViewportOffset(),
					Size = v5 * (v3 and 6 or 3),
					Origin = v7.Position
				})
				camera.SetCFrame(camera.IsFirstCF() and solveInspectionCF or camera.CameraController:GetCFrame():Lerp(
					solveInspectionCF,
					dt * SceneControllerUtil.getLerpSpeed(v4, v)
				))
			end

			v3 = TestRigUtil.isTransformed(localPlayer)
		end
	end))

	local function fn2(fn3, maid2)
		return TestRigUtil.waitForCommandRig(localPlayer, function(_)
			maid2:Add(task.defer(fn3))
		end)
	end

	local function fn3(fn4, maid2)
		return TestRigUtil.waitForCommandRig(localPlayer, function(p)
			rigClient.Rage()
			maid2:Add(task.spawn(function()
				while true do
					rigClient.Rage()
					task.wait(10)
				end
			end))
			rigClient.SkillDown("V", SceneControllerUtil.getFacingCameraCF(p.Model:GetPivot()).Position)
			maid2:Add(task.delay(2, fn4))
		end)
	end

	return v2.Init({
		PlaySequence = function(p)
			return v2.Sequence.new(p, function(maid2, p2)
				if p2.Name == "Idle" then
					maid2:Add(fn2(function()
						p2.OnFinish()
					end, maid2))
				elseif p2.Name == "Primary" then
					maid2:Add(task.delay(0.25, function()
						maid2:Add(fn3(function()
							p2.OnFinish()
						end, maid2))
					end))
				else
					error((`unknown name={p2.Name}`))
				end
			end)
		end,
		Destroy = function()
			maid:Destroy()
		end
	})
end

return Kitsune