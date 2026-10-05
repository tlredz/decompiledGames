local Magnet = {}
require(game.ReplicatedStorage.Modules.Util.Trove)
require(game.ReplicatedStorage.Controllers.SceneController.Scene)
local TestRigUtil = require(game.ReplicatedStorage.Modules.Rig.TestRigUtil)
local SceneControllerUtil = require(game.ReplicatedStorage.Controllers.SceneController.SceneControllerUtil)
local Helper = require(game.ReplicatedStorage.Controllers.SceneController.SceneRigs.Helper)
local Anims = require(game.ReplicatedStorage.Util.Anims)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = false
local cframe = CFrame.new(0, -2, 0)
local v2 = {
	MinDistance = 0,
	MaxDistance = 50,
	MinSpeed = 5,
	MaxSpeed = 20
}

function Magnet.Prewarm()
	if v == false then
		v = true
		SceneControllerUtil.prewarmVFX({ "Magnet" })
		local v3 = {}

		for _, v4 in pairs(require(script.Animations)) do
			local raw = Anims:GetRaw(v4)

			if raw then
				table.insert(v3, raw)
			else
				warn((`no animation from name for preload={v4}`))
			end
		end

		local success, result = pcall(function(...) end)

		if not success then
			warn(result)
		end

		local FX = require(game.ReplicatedStorage.FX)
		local transformed = FX:WaitForChild("Magnet"):WaitForChild("Transformed")
		local children = {}

		for _, childName in { "Rockets", "RocketsArcsteel" } do
			local child = transformed:FindFirstChild(childName)

			if child then
				table.insert(children, child)
			end
		end

		local success2, result2 = pcall(function()
			local ContentProvider = game:GetService("ContentProvider")
			ContentProvider:PreloadAsync(children)
		end)

		if not success2 then
			warn(result2)
		end
	end
end

function Magnet.new(data)
	local maid = data.Scene._Maid:Extend()
	local v3 = Helper.new({
		Maid = maid,
		Scene = data.Scene,
		PhysicalMoveset = data.PhysicalMoveset,
		SkinStorageName = data.SkinStorageName
	})
	local camera = v3.Camera
	local rig = v3.Rig
	local rigClient = rig.RigClient
	local environment = v3.Environment
	maid:Add(TestRigUtil.connectOnRigAdded(localPlayer, function(_)
		rig.AssignRigToScene(function(p)
			local function fixBoundingBox()
				local magnetArms = p.Model:FindFirstChild("MagnetArms")

				if magnetArms then
					for _, child in pairs(magnetArms:GetChildren()) do
						if not child.Name:match("Rotation") then
							continue
						end

						local v4 = child
						task.defer(function()
							v4:Destroy()
						end)
					end
				end
			end

			fixBoundingBox()
			maid:Add(p.Model.ChildAdded:Connect(fixBoundingBox))
		end)
	end))

	if not TestRigUtil.tryFindRig(localPlayer) then
		task.spawn(rig.SpawnRig, {
			PhysicalMoveset = data.PhysicalMoveset,
			SkinStorageName = data.SkinStorageName
		})
	end

	local v4 = false

	local function getDistanceMul()
		if not v4 then
			return 3
		end

		if camera.GetType() == "Inspect" then
		end

		return 1.3
	end

	local function fn(dt: number, p2)
		rigClient.SendPos(v3.GetFacing(p2))
		local setCFrame = camera.SetCFrame
		local solveViewModelCF = SceneControllerUtil.solveViewModelCF
		local distanceMul

		if v4 then
			local _ = camera.GetType() == "Inspect"
			distanceMul = 1.3
		else
			distanceMul = 3
		end

		local lerp

		if not camera.IsFirstCF() then
			lerp = v2
		end

		local offset

		if v4 then
			offset = cframe
		end

		setCFrame(solveViewModelCF(p2, {
			dt = dt,
			DistanceMul = distanceMul,
			Lerp = lerp,
			FollowRotation = false,
			Offset = offset
		}))
	end

	local function fn2(p: number, p2)
		local extents, v5 = TestRigUtil.getExtents(p2)
		local viewportOffsetFn = camera.GetViewportOffsetFn()
		local v6

		if v4 then
			v6 = cframe
		else
			v6 = CFrame.new()
		end

		local v7 = extents * v6
		local solveInspectionCF = SceneControllerUtil.solveInspectionCF
		local _camera = camera.CameraController._camera
		local v8 = {
			CameraController = camera.CameraController,
			ComputeScreenOffsetSize = viewportOffsetFn,
			ViewportOffset = camera.GetViewportOffset(),
			Size = 0,
			Origin = 0
		}
		local v9

		if v4 then
			local _ = camera.GetType() == "Inspect"
			v9 = 1.3
		else
			v9 = 3
		end

		v8.Size = v5 * v9
		v8.Origin = v7.Position
		local v10 = solveInspectionCF(_camera, v8)
		camera.SetCFrame(camera.IsFirstCF() and v10 or camera.CameraController:GetCFrame():Lerp(
			v10,
			p * SceneControllerUtil.getLerpSpeed(p2, v2)
		))
	end

	environment.Heartbeat(function(dt: number)
		local v5 = rig.TryGetRig()

		if v5 then
			v4 = TestRigUtil.isTransformed(localPlayer, "MagnetRig")

			if camera.GetType() == "CameraSubject" then
				fn(dt, v5)
			elseif camera.GetType() == "Inspect" then
				fn2(dt, v5)
			end
		end
	end, function()
		return data.Scene._Initiated == true
	end)

	local function fn3(fn4, maid2)
		return TestRigUtil.waitForCommandRig(localPlayer, function(_)
			maid2:Add(task.defer(fn4))
		end)
	end

	local function fn4(fn5, maid2)
		return TestRigUtil.waitForCommandRig(localPlayer, function(p)
			rigClient.SkillDown("Z", v3.GetFacing(p.Model))
			maid2:Add(task.delay(0.5, function()
				rigClient.SkillUp("Z")
				maid2:Add(task.defer(fn5))
			end))
		end)
	end

	local function fn5(p)
		return v3.Sequence.new(p, function(maid2, p2)
			if p2.Name == "Idle" then
				maid2:Add(task.delay(0.25, function()
					maid2:Add(fn3(function()
						p2.OnFinish()
					end, maid2))
				end))
			elseif p2.Name == "Primary" then
				maid2:Add(TestRigUtil.waitForCommandRig(localPlayer, function(p3)
					rigClient.Rage()
					maid2:Add(task.spawn(function()
						while true do
							rigClient.Rage()
							task.wait(10)
						end
					end))
					rigClient.SkillDown("V", v3.GetFacing(p3.Model))
					maid2:Add(task.delay(5, function()
						maid2:Add(task.delay(0.8, function()
							maid2:Add(fn4(function()
								p2.OnFinish()
							end, maid2))
						end))
					end))
				end))
			elseif p2.Name == "Z" then
				maid2:Add(fn4(function()
					p2.OnFinish()
				end, maid2))
			end
		end)
	end

	return v3.Init({
		PlaySequence = fn5,
		TapInWorld = "Z",
		Destroy = function()
			maid:Destroy()
		end
	})
end

return Magnet