local Yeti = {}
require(game.ReplicatedStorage.Modules.Util.Trove)
require(game.ReplicatedStorage.Controllers.SceneController.Scene)
local TestRigUtil = require(game.ReplicatedStorage.Modules.Rig.TestRigUtil)
local SceneControllerUtil = require(game.ReplicatedStorage.Controllers.SceneController.SceneControllerUtil)
local Helper = require(game.ReplicatedStorage.Controllers.SceneController.SceneRigs.Helper)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = {
	MinDistance = 5,
	MaxDistance = 50,
	MinSpeed = 5,
	MaxSpeed = 20
}

function Yeti.Prewarm()
	SceneControllerUtil.prewarmVFX({ "Yeti" })
	SceneControllerUtil.prewarmVFX({ "FiendYeti" })
end

function Yeti.new(data)
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
	maid:Add(TestRigUtil.connectOnRigAdded(localPlayer, function(_)
		rig.AssignRigToScene()
	end))

	if not TestRigUtil.tryFindRig(localPlayer) then
		task.spawn(rig.SpawnRig, {
			PhysicalMoveset = data.PhysicalMoveset,
			SkinStorageName = data.SkinStorageName
		})
	end

	local cframe = CFrame.new()

	local function fn(dt: number, p, flag: boolean?)
		rigClient.SendPos(v2.GetFacing(p))
		local setCFrame = camera.SetCFrame
		local solveViewModelCF = SceneControllerUtil.solveViewModelCF
		local v3 = {
			dt = dt,
			Magnitude = NumberRange.new(50, 60),
			Offset = cframe,
			Lerp = 0,
			FollowRotation = 0
		}
		local lerp

		if not camera.IsFirstCF() then
			lerp = v
		end

		v3.Lerp = lerp
		v3.FollowRotation = flag ~= false
		setCFrame(solveViewModelCF(p, v3))
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
				local solveInspectionCF = SceneControllerUtil.solveInspectionCF(camera.CameraController._camera, {
					CameraController = camera.CameraController,
					ComputeScreenOffsetSize = camera.GetViewportOffsetFn(),
					ViewportOffset = camera.GetViewportOffset(),
					Size = v4 * 1.8,
					Origin = v5.Position
				})
				camera.SetCFrame(camera.IsFirstCF() and solveInspectionCF or camera.CameraController:GetCFrame():Lerp(
					solveInspectionCF,
					dt * SceneControllerUtil.getLerpSpeed(v3, v)
				))
			end
		end
	end))

	local function fn2(fn3, maid2)
		return TestRigUtil.waitForCommandRig(localPlayer, function(_)
			maid2:Add(task.defer(fn3))
		end)
	end

	local function fn3(fn4, maid2)
		return TestRigUtil.waitForCommandRig(localPlayer, function(p)
			cframe = CFrame.new(0, 2, 0)
			rigClient.Rage()
			maid2:Add(task.spawn(function()
				while true do
					rigClient.Rage()
					task.wait(10)
				end
			end))
			rigClient.SkillDown("V", SceneControllerUtil.getFacingCameraCF(p.Model:GetPivot()).Position)
			maid2:Add(task.delay(3, fn4))
		end)
	end

	local function fn4(p)
		return v2.Sequence.new(p, function(maid2, p2)
			cframe = CFrame.new(0, 0, 0)

			if p2.Name == "Idle" then
				maid2:Add(fn2(function()
					p2.OnFinish()
				end, maid2))
			elseif p2.Name == "Primary" then
				maid2:Add(task.delay(0, function()
					maid2:Add(fn3(function()
						cframe = CFrame.new(0, -2, 0)
						p2.OnFinish()
					end, maid2))
				end))
			end
		end)
	end

	return v2.Init({
		PlaySequence = fn4,
		Destroy = function()
			maid:Destroy()
		end
	})
end

return Yeti