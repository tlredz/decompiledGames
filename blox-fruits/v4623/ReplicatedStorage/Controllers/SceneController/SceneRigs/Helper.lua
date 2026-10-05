local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
require(game.ReplicatedStorage.Modules.Util.Trove)
require(game.ReplicatedStorage.Controllers.SceneController.Scene)
local TestRigUtil = require(game.ReplicatedStorage.Modules.Rig.TestRigUtil)
local SceneControllerUtil = require(game.ReplicatedStorage.Controllers.SceneController.SceneControllerUtil)
local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
local SequenceHistory = require(game.ReplicatedStorage.Controllers.SceneController.SequenceHistory)
require(game.ReplicatedStorage.Controllers.SceneController.SceneRigs.Helper.HelperTypes)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local RigClient = require(game.ReplicatedStorage.Controllers.SceneController.SceneRigs.Helper.RigClient)

function SpawnRig(p)
	local v

	if p.SkinStorageName then
		v = ItemConfig.match(p.SkinStorageName, "Skin")
	end

	if v and v:isErr() then
		v:inspectErr(warn)
	end

	local v2

	if v and v:isOk() then
		v2 = v:unwrap()
	end

	local spawnRig = TestRigUtil.spawnRig
	local physicalMoveset = p.PhysicalMoveset
	local v4

	if v2 then
		v4 = v2.Index.StorageKey
	end

	return spawnRig(localPlayer, physicalMoveset, v4)
end

local function fn(scene, maid)
	local isFirst = scene.Camera == nil
	local v2 = scene.Camera == nil
	local camera = scene.Camera or CameraController.new(workspace.CurrentCamera)
	local v3 = nil
	local v4 = "CameraSubject"
	local v5 = nil
	local v6 = 0

	if scene.Camera == nil then
		scene:SetCamera(camera)
		camera:TeleportTo(scene._FloorAttachment.WorldCFrame * CFrame.new(0, 5, 0))
		workspace.CurrentCamera.FieldOfView = 50
	end

	return {
		IsFirst = isFirst,
		IsFirstCF = function()
			return v2
		end,
		CameraController = camera,
		SetCFrame = function(self)
			v2 = false
			camera:SetCFrame(self)
		end,
		GetViewportOffset = function()
			return v6
		end,
		GetType = function()
			return v4
		end,
		GetViewportOffsetFn = function()
			return v5
		end,
		SetCameraType = function(p, p2, value)
			if v4 ~= p then
				if v3 then
					v3:Destroy()
				end

				v3 = maid:Extend()
				assert(v3):Add(function()
					v3 = nil
					v5 = nil
					v4 = "CameraSubject"
					v6 = 0
				end)
				v4 = p
			end

			v6 = value or 0
			v5 = p2

			if v4 == "Inspect" then
				scene:SetDragEnabled(true)
			else
				scene:SetDragEnabled(false)
			end
		end
	}
end

function Rig(object, maid)
	local v = nil
	local v2 = nil
	local model = nil
	return {
		TryGetRig = function()
			if model == nil or model.Parent == nil or object._Rig and object._Rig ~= model then
				model = TestRigUtil.tryFindRig(localPlayer)
			end

			return model
		end,
		RigClient = RigClient(),
		SpawnRig = function(self)
			if v2 then
				maid:Remove(v2)
			end

			v2 = maid:Add(SpawnRig(self))
		end,
		AssignRigToScene = function(callback)
			if v then
				maid:Remove(v)
			end

			v = maid:Add(TestRigUtil.waitForCommandRig(localPlayer, function(p)
				if p.Model ~= object._Rig then
					if callback then
						task.spawn(callback, p)
					end

					model = p.Model
					object:SpawnRig(p.Model)
				end
			end))
		end
	}
end

local function fn2(maid)
	local v = nil
	local v2 = nil
	local frozen = table.freeze({
		Name = "None",
		UID = "-1",
		Active = false,
		Finished = true,
		OnFinish = function() end
	})
	return {
		new = function(p, callback)
			local v3 = nil
			local HttpService = game:GetService("HttpService")
			v3 = {
				UID = HttpService:GenerateGUID(),
				Name = p.Name,
				Finished = false,
				Active = false,
				OnFinish = function()
					if not v2 or v2.UID ~= v3.UID then
						warn("uids not the same")
						return
					end

					v3.Finished = true
					p.OnFinish()
				end
			}
			v2 = v3

			if v then
				v:Destroy()
			end

			local maid2 = maid:Extend()
			v = maid2
			maid2:Add(function()
				if v == maid2 then
					v = nil
				end

				v3.Active = false
			end)
			maid2:Add(task.defer(function()
				v3.Active = true
				callback(maid2, v3)
			end))
			return function()
				maid2:Destroy()
			end
		end,
		GetCurrentSequence = function()
			return v2 or frozen
		end
	}
end

local function getFacing(instance)
	local facingCameraCF = SceneControllerUtil.getFacingCameraCF(instance:GetPivot())
	return facingCameraCF.Position + facingCameraCF.LookVector * 1000
end

return {
	new = function(data)
		local function fn3(_)
			print((`no sequence function assigned for {data.PhysicalMoveset}:{data.SkinStorageName}`))
			return function() end
		end

		local function fn4()
			data.Maid:Destroy()
		end

		local v = nil
		local v2 = {
			Data = data,
			Sequence = fn2(data.Maid),
			Camera = fn(data.Scene, data.Maid),
			Rig = Rig(data.Scene, data.Maid),
			Environment = 0,
			GetFacing = 0,
			SequenceHistory = 0,
			PlaySequence = 0,
			Init = 0,
			Destroy = 0
		}
		local _ = data.Scene
		local extended = data.Maid:Extend()
		v2.Environment = {
			Heartbeat = function(callback, callback2)
				local maid = extended
				local RunService = game:GetService("RunService")
				local connection = maid:Add(RunService.Heartbeat:Connect(function(dt)
					if callback2 == nil or callback2() == true then
						callback(dt)
					end
				end))
				return function()
					connection:Disconnect()
				end
			end
		}
		v2.GetFacing = getFacing
		v2.SequenceHistory = SequenceHistory

		function v2.PlaySequence(p)
			return fn3(p)
		end

		function v2.Init(data2)
			assert(data2.PlaySequence)
			fn3 = data2.PlaySequence

			if data2.TapInWorld then
				v.TapInWorld = data2.TapInWorld
			end

			if data2.Destroy then
				fn4 = data2.Destroy
			end

			return v
		end

		function v2.Destroy()
			fn4()
		end

		v = v2
		return v
	end
}