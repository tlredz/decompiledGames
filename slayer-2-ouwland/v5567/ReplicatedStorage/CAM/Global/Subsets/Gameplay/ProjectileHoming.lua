local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local ProjectileHoming = {
	Pick = function(data)
		local aim = data.Aim

		if data.Caster == nil or aim == nil then
			return nil, aim
		end

		local maximizeRayServer, _, _, v = RaycastHelper.MaximizeRayServer(
			data.Caster,
			data.Origin,
			aim,
			data.Range,
			true,
			data.Radius or 10,
			data.Downcast or 15
		)
		local v2 = maximizeRayServer or aim

		if v == nil or v == data.Caster then
			return nil, v2
		end

		local v3

		if data.Select == true then
			v3 = Checker.check_can_select(data.Script, data.Caster, v) == true
		else
			v3 = Checker.check_victim(data.Script, data.Caster, v) ~= nil
		end

		if v3 then
			return v, v2
		end

		return nil, v2
	end
}

function ProjectileHoming.HoldLock(data)
	local lock = ProjectileHoming.NewLock(data.Pick)
	task.spawn(function()
		while data.While() == true do
			local aim = data.Aim()

			if aim ~= nil then
				lock:Update(data.Origin(), aim)
			end

			task.wait(data.Tick or 0.05)
		end
	end)
	return lock
end

function ProjectileHoming.PickClient(data)
	local aim = data.Aim

	if data.Caster == nil or aim == nil then
		return nil, aim
	end

	local maximizeRayClient, _, _, v = RaycastHelper.MaximizeRayClient(
		data.Origin,
		aim,
		data.Range,
		true,
		data.Radius or 10,
		data.Downcast or 15
	)
	local v2 = maximizeRayClient or aim

	if v == nil or v == data.Caster then
		return nil, v2
	end

	if Checker.check_can_select(data.Script, data.Caster, v) == true then
		return v, v2
	end

	return nil, v2
end

function ProjectileHoming.NewLock(data)
	local v = nil

	local function stillValid()
		if v == nil or not v:IsDescendantOf(workspace) or v:FindFirstChild("HumanoidRootPart") == nil then
			return false
		end

		return data.KeepUntilGone == true or Checker.check_can_select(data.Script, data.Caster, v) == true
	end

	return {
		Update = function(self, vector: Vector3, vector2: Vector3?)
			local v3

			if v == nil or not v:IsDescendantOf(workspace) or v:FindFirstChild("HumanoidRootPart") == nil then
				v3 = false
			else
				v3 = data.KeepUntilGone == true or Checker.check_can_select(data.Script, data.Caster, v) == true
			end

			if not v3 then
				v = nil
			end

			local v4

			if RunService:IsServer() then
				v4 = ProjectileHoming.Pick
			else
				v4 = ProjectileHoming.PickClient
			end

			local v5, v6 = v4({
				Script = data.Script,
				Caster = data.Caster,
				Origin = vector,
				Aim = vector2,
				Range = data.Range,
				Radius = data.Radius,
				Downcast = data.Downcast,
				Select = data.Select == nil or data.Select
			})

			if v5 ~= nil and v5 ~= v then
				v = v5
			end

			return v, v6
		end,
		Target = function(_)
			local v3

			if v == nil or not v:IsDescendantOf(workspace) or v:FindFirstChild("HumanoidRootPart") == nil then
				v3 = false
			else
				v3 = data.KeepUntilGone == true or Checker.check_can_select(data.Script, data.Caster, v) == true
			end

			if v3 then
				return v
			end

			return nil
		end,
		Clear = function(_)
			v = nil
		end
	}
end

function ProjectileHoming.Track(data)
	local v = false

	local function stop()
		v = true
	end

	local projectile = data.Projectile

	if projectile == nil or data.Target == nil then
		return stop
	end

	task.spawn(function()
		while not v and projectile.IsActive and (data.ShouldStop == nil or data.ShouldStop() ~= true) do
			local instance = projectile.Instance

			if instance == nil or instance.Parent == nil then
				break
			end

			local humanoidRootPart = data.Target:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				break
			end

			local v2 = humanoidRootPart.Position - instance.Position

			if v2.Magnitude > 0.1 then
				local mover = projectile.Mover or instance:FindFirstChild("Mover")

				if mover ~= nil then
					mover.VectorVelocity = v2.Unit * data.Speed
				end

				if data.Rotate == true then
					local rotator = projectile.Rotator or instance:FindFirstChild("Rotator")

					if rotator ~= nil then
						rotator.CFrame = Utility.SafeLookAt(
							instance.Position,
							humanoidRootPart.Position,
							instance.CFrame
						)
					end
				end
			end

			task.wait(data.Tick or 0.05)
		end
	end)
	return stop
end

function ProjectileHoming.Launch(p, data)
	local target, v2 = ProjectileHoming.Pick(p)

	if target == nil then
		return nil, v2, function() end
	end

	return target, v2, (ProjectileHoming.Track({
		Projectile = data.Projectile,
		Target = target,
		Speed = data.Speed,
		Tick = data.Tick,
		Rotate = data.Rotate,
		ShouldStop = data.ShouldStop
	}))
end

return ProjectileHoming