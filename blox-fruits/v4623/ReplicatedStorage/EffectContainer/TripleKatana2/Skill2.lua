local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local skill2 = FX:WaitForChild("TripleKatana").Skill2
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }
return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local _ = data.origin
	local _ = data.fireDir
	local skill = skill2
	local parent = _WorldOrigin
	local originCFrame = data.originCFrame
	local dashDistance = data.dashDistance
	local cFrame = originCFrame * CFrame.new(0, 0, -dashDistance)
	local clone = skill.Start:Clone()
	clone.CFrame = data.originCFrame
	clone.Parent = parent
	destroyAfter(clone, 7)
	clone.Massless = true
	clone.Weld.Part0 = hrp

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local clone2 = skill.Dash:Clone()
	clone2.CFrame = cFrame
	clone2.Dash2.Size = Vector3.new(1, 1, dashDistance / 1.25)
	clone2.Dash2.CFrame = cFrame * CFrame.new(0, 0, clone2.Dash2.Size.Z / 2)
	clone2.Parent = parent
	destroyAfter(clone2, 2)
	local clone3 = skill.Smoke:Clone()
	clone3.CFrame = cFrame
	clone3.Parent = clone2
	destroyAfter(clone3, 2)

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v4 = emitter
		coroutine.wrap(function()
			if v4:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v4:GetAttribute("EmitDelay"))
			end

			v4:Emit(v4:GetAttribute("EmitCount"))
		end)()
	end

	local position = clone2.Dash2.Position
	local v4 = 12
	local part, _ = Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(
			position + Vector3.new(0, v4 / 10, 0),
			CFrame.new(position + Vector3.new(0, v4 / 10, 0), position + Vector3.new(0, -v4, 0)).LookVector * v4
		),
		raycastParams.FilterDescendantsInstances
	)

	if part then
		coroutine.wrap(function()
			local clone4 = skill.GroundTrail:Clone()
			clone4.CFrame = originCFrame
			clone4.Parent = parent
			destroyAfter(clone4, 3)
			task.wait()
			task.wait()
			local tween = TweenService:Create(
				clone4,
				TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{
					CFrame = clone4.CFrame * CFrame.new(0, 0, -dashDistance + 5)
				}
			)
			tween:Play()
			v4 = 10
			local v5 = time()

			for _ = 1, 600 do
				task.wait()
				local part2, _ = Workspace:FindPartOnRayWithIgnoreList(
					Ray.new(
						clone4.Position + Vector3.new(0, v4 / 2, 0),
						CFrame.new(
							clone4.Position + Vector3.new(0, v4 / 10, 0),
							clone4.Position + Vector3.new(0, -v4, 0)
						).LookVector * v4
					),
					raycastParams.FilterDescendantsInstances
				)

				if part2 then
					if tween.Completed == true or time() - v5 > 10 then
						break
					end
				else
					tween:Pause()
					break
				end
			end
		end)()
	end

	task.spawn(function()
		for _ = 1, 5 do
			Util.Sound:Play("QuickSlice", hrp)
			task.wait(0.04)
		end
	end)
	task.wait(0.15)
	clone.Weld:Destroy()
	clone.Anchored = true

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end