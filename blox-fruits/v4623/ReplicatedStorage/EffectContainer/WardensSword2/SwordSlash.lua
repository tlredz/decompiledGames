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
local multiTargetSlash = FX:WaitForChild("WardensSword").MultiTargetSlash
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt

local function putFolder(parent, name: string)
	local v = parent:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		v.Parent = parent
	end

	return v
end

local function putValueAsValueObject(parent, name: string, p, value: number)
	local v2 = {
		boolean = "BoolValue",
		CFrame = "CFrameValue",
		Color3 = "Color3Value",
		number = "NumberValue",
		Instance = "ObjectValue",
		Ray = "RayValue",
		string = "StringValue",
		Vector3 = "Vector3Value"
	}
	local instance = parent:FindFirstChild(name)

	if instance == nil then
		instance = Instance.new(v2[typeof(p)])
		instance.Name = name
		instance.Parent = parent
	end

	instance.Value = p
	destroyAfter(instance, value or 60)
end

local function getValueObject(instance, childName)
	return instance:FindFirstChild(childName)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function fn(light, duration)
	if light:IsA("Light") then
		TweenService:Create(light, TweenInfo.new(duration), {
			Brightness = 0
		}):Play()
		return
	end

	for _, light2 in pairs(light:GetDescendants()) do
		if light2:IsA("Light") then
			TweenService:Create(light2, TweenInfo.new(duration), {
				Brightness = 0
			}):Play()
		end
	end
end

local v = {
	"rbxassetid://12815976500",
	"rbxassetid://12815976500",
	"rbxassetid://12815976326",
	"rbxassetid://12815976326",
	"rbxassetid://12815976092",
	"rbxassetid://12815976092",
	"rbxassetid://12815975548",
	"rbxassetid://12815975348",
	"rbxassetid://12815975075",
	"rbxassetid://12815974829",
	"rbxassetid://12815974597",
	"rbxassetid://12815974377",
	"rbxassetid://12815974157",
	"rbxassetid://12815973949"
}

local function fn2(duration, clone)
	local decal = clone.Decal
	decal.Transparency = 0

	for _, texture in ipairs(v) do
		decal.Texture = texture
		task.wait(duration)
	end

	decal.Transparency = 1
	destroyAfter(decal, 1)
end

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	if player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(8, 13, 0.2, 0.7)
	end

	Util.Sound:Play("FocusShotProjectile(3)", hrp.CFrame.p)
	local enemyRoots = data.enemyRoots
	local _ = hrp.Parent
	task.spawn(function()
		task.spawn(function()
			if #enemyRoots > 0 then
				task.wait(0.23)

				for i, enemyRoot in ipairs(enemyRoots) do
					if enemyRoot == nil or enemyRoot.Parent == nil then
						table.remove(enemyRoots, i)
					end
				end

				for i, enemyRoot in ipairs(enemyRoots) do
					if i ~= #enemyRoots then
						local _ = enemyRoots[i + 1]
					end

					local clone = multiTargetSlash.Pose:Clone()
					clone.Parent = _WorldOrigin
					clone.CFrame = enemyRoot.CFrame * CFrame.new(0, 0, 7) * CFrame.Angles(0, 3.141592653589793, 0)
					local emitter = clone
					task.spawn(function()
						if emitter:IsA("ParticleEmitter") then
							local emitCount = emitter:GetAttribute("EmitCount") or 1
							local emitDelay = emitter:GetAttribute("EmitDelay") or nil

							if emitDelay then
								task.wait(emitDelay)
							end

							emitter:Emit(emitCount)
						else
							for i2, emitter2 in ipairs(emitter:GetDescendants()) do
								if not emitter2:IsA("ParticleEmitter") then
									continue
								end

								local v2 = emitter2
								task.spawn(function()
									local emitCount = v2:GetAttribute("EmitCount") or 1
									local emitDelay = v2:GetAttribute("EmitDelay") or nil

									if emitDelay then
										task.wait(emitDelay)
									end

									v2:Emit(emitCount)
								end)
							end
						end
					end)
					task.delay(0.6, function()
						local emitter2 = clone
						task.spawn(function()
							if emitter2:IsA("ParticleEmitter") then
								local emitCount = emitter2:GetAttribute("EmitCount") or 1
								local emitDelay = emitter2:GetAttribute("EmitDelay") or nil

								if emitDelay then
									task.wait(emitDelay)
								end

								emitter2:Emit(emitCount)
							else
								for i2, emitter3 in ipairs(emitter2:GetDescendants()) do
									if not emitter3:IsA("ParticleEmitter") then
										continue
									end

									local v3 = emitter3
									task.spawn(function()
										local emitCount = v3:GetAttribute("EmitCount") or 1
										local emitDelay = v3:GetAttribute("EmitDelay") or nil

										if emitDelay then
											task.wait(emitDelay)
										end

										v3:Emit(emitCount)
									end)
								end
							end
						end)
						clone.Transparency = 1
						destroyAfter(clone, 1)
					end)
					local clone2 = multiTargetSlash.EnemySlash:Clone()
					clone2.Parent = _WorldOrigin
					clone2.CFrame = CFrame.new(enemyRoot.Position, clone.CFrame.LookVector)
					local emitter2 = clone2
					task.spawn(function()
						if emitter2:IsA("ParticleEmitter") then
							local emitCount = emitter2:GetAttribute("EmitCount") or 1
							local emitDelay = emitter2:GetAttribute("EmitDelay") or nil

							if emitDelay then
								task.wait(emitDelay)
							end

							emitter2:Emit(emitCount)
						else
							for i2, emitter3 in ipairs(emitter2:GetDescendants()) do
								if not emitter3:IsA("ParticleEmitter") then
									continue
								end

								local v3 = emitter3
								task.spawn(function()
									local emitCount = v3:GetAttribute("EmitCount") or 1
									local emitDelay = v3:GetAttribute("EmitDelay") or nil

									if emitDelay then
										task.wait(emitDelay)
									end

									v3:Emit(emitCount)
								end)
							end
						end
					end)
					destroyAfter(clone2, 2)
					fn(clone2, 0.5)
				end
			end
		end)
		task.wait(0.4)
		local clone = multiTargetSlash.TeleportVFX:Clone()
		clone.Parent = _WorldOrigin
		clone.CFrame = hrp.CFrame
		task.spawn(function()
			if clone:IsA("ParticleEmitter") then
				local emitCount = clone:GetAttribute("EmitCount") or 1
				local emitDelay = clone:GetAttribute("EmitDelay") or nil

				if emitDelay then
					task.wait(emitDelay)
				end

				clone:Emit(emitCount)
			else
				for _, emitter in ipairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v2 = emitter
					task.spawn(function()
						local emitCount = v2:GetAttribute("EmitCount") or 1
						local emitDelay = v2:GetAttribute("EmitDelay") or nil

						if emitDelay then
							task.wait(emitDelay)
						end

						v2:Emit(emitCount)
					end)
				end
			end
		end)
		destroyAfter(clone, 2)
	end)
	local clone = multiTargetSlash.MultiTargetSlashVFX:Clone()
	clone.Parent = _WorldOrigin
	clone.CFrame = cFrame
	task.spawn(function()
		if clone:IsA("ParticleEmitter") then
			local emitCount = clone:GetAttribute("EmitCount") or 1
			local emitDelay = clone:GetAttribute("EmitDelay") or nil

			if emitDelay then
				task.wait(emitDelay)
			end

			clone:Emit(emitCount)
		else
			for _, emitter in ipairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					local emitCount = v2:GetAttribute("EmitCount") or 1
					local emitDelay = v2:GetAttribute("EmitDelay") or nil

					if emitDelay then
						task.wait(emitDelay)
					end

					v2:Emit(emitCount)
				end)
			end
		end
	end)
	fn(clone, 0.4)
	destroyAfter(clone, 3)
	task.wait(0.25)
	local raycastResult = Workspace:Raycast(
		cFrame.Position + createVector(0, 2, 0),
		createVector(0, -12, 0),
		raycastParams
	)
	local v2 = raycastResult and {
		Position = raycastResult.Position,
		Object = raycastResult.Instance
	} or nil

	if not v2 then
		return
	end

	local clone2 = multiTargetSlash.SlashGroundVFX:Clone()
	clone2.Parent = _WorldOrigin
	clone2.Position = v2.Position + createVector(0, 0.05, 0)
	task.spawn(function()
		if clone2:IsA("ParticleEmitter") then
			local emitCount = clone2:GetAttribute("EmitCount") or 1
			local emitDelay = clone2:GetAttribute("EmitDelay") or nil

			if emitDelay then
				task.wait(emitDelay)
			end

			clone2:Emit(emitCount)
		else
			for _, emitter in ipairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v3 = emitter
				task.spawn(function()
					local emitCount = v3:GetAttribute("EmitCount") or 1
					local emitDelay = v3:GetAttribute("EmitDelay") or nil

					if emitDelay then
						task.wait(emitDelay)
					end

					v3:Emit(emitCount)
				end)
			end
		end
	end)
	destroyAfter(clone2, 4.5)
	local clone3 = multiTargetSlash.SmokeDecal:Clone()
	clone3.Parent = _WorldOrigin
	destroyAfter(clone3, 5)
	clone3.CFrame = CFrame.new(v2.Position) * CFrame.new(0, 1, 0)
	local random = Random.new()
	clone3.Orientation = Vector3.new(0, random.NextNumber(random, -36000, 36000) / 100, 0)
	clone3.Mesh.Scale = createVector(1, 1, 1)
	task.spawn(function()
		fn2(0.041666666666666664, clone3)
	end)
	TweenService:Create(clone3, TweenInfo.new(4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Orientation = clone3.Orientation + createVector(0, 800, 0)
	}):Play()
	TweenService:Create(clone3.Mesh, TweenInfo.new(4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Scale = createVector(70, 70, 70),
		Offset = createVector(0, 5, 0)
	}):Play()
end