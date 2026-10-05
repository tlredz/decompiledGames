local Lightning = {}
require(game.ReplicatedStorage.Modules.Util.Trove)
require(game.ReplicatedStorage.Controllers.SceneController.Scene)
local TestRigUtil = require(game.ReplicatedStorage.Modules.Rig.TestRigUtil)
local SceneControllerUtil = require(game.ReplicatedStorage.Controllers.SceneController.SceneControllerUtil)
local Helper = require(game.ReplicatedStorage.Controllers.SceneController.SceneRigs.Helper)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local cframe = CFrame.new(0, 0.5, 0)
local v = {
	MinDistance = 0,
	MaxDistance = 50,
	MinSpeed = 10,
	MaxSpeed = 30
}

function Lightning.Prewarm()
	SceneControllerUtil.prewarmVFX({ "Lightning2" })
end

function Lightning.new(data)
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

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getDistanceMul()
		return v2.Sequence.GetCurrentSequence().Active and 5 or 3
	end

	local function fn(dt: number, p)
		rigClient.SendPos(getFacing(p))
		local setCFrame = camera.SetCFrame
		local solveViewModelCF = SceneControllerUtil.solveViewModelCF
		local v3 = {
			dt = dt,
			DistanceMul = getDistanceMul(),
			Lerp = 0,
			FollowRotation = false,
			Offset = 0
		}
		local lerp

		if not camera.IsFirstCF() then
			lerp = v
		end

		v3.Lerp = lerp
		v3.Offset = cframe
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
					Size = v4 * getDistanceMul(),
					Origin = v5.Position
				})
				camera.SetCFrame(camera.IsFirstCF() and solveInspectionCF or camera.CameraController:GetCFrame():Lerp(
					solveInspectionCF,
					dt * SceneControllerUtil.getLerpSpeed(v3, v)
				))
			end
		end
	end))

	local function fn2(p)
		return v2.Sequence.new(p, function(maid2, p2)
			if p2.Name == "Primary" then
				maid2:Add(task.delay(0, function()
					maid2:Add(TestRigUtil.waitForCommandRig(localPlayer, function(_)
						rigClient.SkillDown("X")
						maid2:Add(task.delay(1, function()
							rigClient.SkillUp("X")
							maid2:Add(task.delay(2, function()
								local onFinish = p2.OnFinish
								local maid3 = maid2
								maid3:Add(TestRigUtil.waitForCommandRig(localPlayer, function(_)
									maid3:Add(task.defer(onFinish))
								end))
							end))
						end))
					end))
				end))
			elseif p2.Name == "Idle" then
				local onFinish = p2.OnFinish
				maid2:Add(TestRigUtil.waitForCommandRig(localPlayer, function(_)
					maid2:Add(task.defer(onFinish))
				end))
			end
		end)
	end

	return v2.Init({
		PlaySequence = fn2,
		Destroy = function()
			maid:Destroy()
		end
	})
end

return Lightning