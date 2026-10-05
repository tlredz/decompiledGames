local Gravity = {}
require(game.ReplicatedStorage.Modules.Util.Trove)
require(game.ReplicatedStorage.Controllers.SceneController.Scene)
local TestRigUtil = require(game.ReplicatedStorage.Modules.Rig.TestRigUtil)
local SceneControllerUtil = require(game.ReplicatedStorage.Controllers.SceneController.SceneControllerUtil)
local Helper = require(game.ReplicatedStorage.Controllers.SceneController.SceneRigs.Helper)
local cframe = CFrame.new(0, 0.5, 0)
local cframe2 = CFrame.new(0, -5, 0)
local v = {
	MinDistance = 0,
	MaxDistance = 50,
	MinSpeed = 10,
	MaxSpeed = 30
}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function Gravity.Prewarm()
	SceneControllerUtil.prewarmVFX({ "Gravity" })
end

function Gravity.new(data)
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

	local offset = cframe

	local function getDistanceMul()
		local currentSequence = v2.Sequence.GetCurrentSequence()
		local heldSkills = rigClient.GetHeldSkills()
		local v4

		if currentSequence then
			local _ = currentSequence.Name == "Primary"
			v4 = 6
		else
			v4 = 3
		end

		if heldSkills.F then
			offset = cframe2
			return v4
		end

		offset = cframe
		return v4
	end

	local function fn(dt: number, p)
		rigClient.SendPos(getFacing(p))
		local setCFrame = camera.SetCFrame
		local solveViewModelCF = SceneControllerUtil.solveViewModelCF
		local currentSequence = v2.Sequence.GetCurrentSequence()
		local heldSkills = rigClient.GetHeldSkills()
		local distanceMul

		if currentSequence then
			local _ = currentSequence.Name == "Primary"
			distanceMul = 6
		else
			distanceMul = 3
		end

		if heldSkills.F then
			offset = cframe2
		else
			offset = cframe
		end

		local lerp

		if not camera.IsFirstCF() then
			lerp = v
		end

		setCFrame(solveViewModelCF(p, {
			dt = dt,
			DistanceMul = distanceMul,
			Lerp = lerp,
			FollowRotation = false,
			Offset = offset
		}))
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
				local v6 = extents * offset
				local solveInspectionCF = SceneControllerUtil.solveInspectionCF
				local _camera = cameraController._camera
				local v7 = {
					CameraController = cameraController,
					ComputeScreenOffsetSize = camera.GetViewportOffsetFn(),
					ViewportOffset = camera.GetViewportOffset(),
					Size = 0,
					Origin = 0
				}
				local currentSequence = v2.Sequence.GetCurrentSequence()
				local heldSkills = rigClient.GetHeldSkills()
				local v8

				if currentSequence then
					local _ = currentSequence.Name == "Primary"
					v8 = 6
				else
					v8 = 3
				end

				if heldSkills.F then
					offset = cframe2
				else
					offset = cframe
				end

				v7.Size = v5 * v8
				v7.Origin = v6.Position
				local v9 = solveInspectionCF(_camera, v7)
				camera.SetCFrame(camera.IsFirstCF() and v9 or cameraController:GetCFrame():Lerp(
					v9,
					dt * SceneControllerUtil.getLerpSpeed(v4, v)
				))
			end
		end
	end))

	local function fn2(p)
		return v2.Sequence.new(p, function(maid2, p2)
			maid2:Add(TestRigUtil.waitForCommandRig(localPlayer, function(p3)
				if p2.Name == "Idle" then
					local onFinish = p2.OnFinish
					local maid3 = maid2
					maid3:Add(TestRigUtil.waitForCommandRig(localPlayer, function(p4)
						rigClient.SkillDown("V", getFacing(p4.Model))
						maid3:Add(task.defer(onFinish))
					end))
				elseif p2.Name == "Primary" then
					maid2:Add(task.delay(0, function()
						rigClient.SkillDown("Z", getFacing(p3.Model))
						maid2:Add(task.delay(2, function()
							rigClient.SkillUp()
							maid2:Add(task.delay(0.5, function()
								local onFinish = p2.OnFinish
								local maid3 = maid2
								maid3:Add(TestRigUtil.waitForCommandRig(localPlayer, function(p4)
									rigClient.SkillDown("V", getFacing(p4.Model))
									maid3:Add(task.defer(onFinish))
								end))
							end))
						end))
					end))
				end
			end))
		end)
	end

	return v2.Init({
		PlaySequence = fn2,
		Destroy = function()
			maid:Destroy()
		end
	})
end

return Gravity