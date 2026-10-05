local createVector = vector.create
local _ = game.Players.LocalPlayer
local _ = workspace._WorldOrigin
local currentCamera = workspace.CurrentCamera
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local X = FX:WaitForChild("WaterKungfu").X
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function Tween(p, duration, p2, p3, p4)
	local tween = TweenService:Create(p, TweenInfo.new(duration, p2, p3), p4)
	tween:Play()
	return tween
end

local function Emit(emitter)
	if not emitter then
		return
	end

	if emitter:IsA("ParticleEmitter") then
		local emitDelay = emitter:GetAttribute("EmitDelay") or 0
		local emitDuration = emitter:GetAttribute("EmitDuration")
		task.delay(emitDelay, function()
			emitter:Emit(emitter:GetAttribute("EmitCount"))

			if emitDuration then
				emitter.Enabled = true
				task.delay(emitDuration, function()
					emitter.Enabled = false
				end)
			end
		end)
	else
		for _, emitter2 in pairs(emitter:GetDescendants()) do
			if not emitter2:IsA("ParticleEmitter") then
				continue
			end

			local emitDelay = emitter2:GetAttribute("EmitDelay") or 0
			local v = emitter2
			local v2 = emitter2:GetAttribute("EmitDuration")
			task.delay(emitDelay, function()
				v:Emit(v:GetAttribute("EmitCount"))

				if v2 then
					v.Enabled = true
					task.delay(v2, function()
						v.Enabled = false
					end)
				end
			end)
		end
	end
end

local function DisableAllFXs(folder)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
			continue
		end

		effect.Enabled = false
	end
end

return function(data)
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 500 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local clone = X.ChargeFX.A1:Clone()
		clone.Parent = data.RightHand
		local clone2 = X.ChargeFX.A1:Clone()
		clone2.Parent = data.LeftHand
		Emit(clone)
		Emit(clone2)
		local v = Util.Sound:Play("BF_WaterFu_X_Held_02", data.Root)

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		DisableAllFXs(clone)
		DisableAllFXs(clone2)
		Util.Debris:AddItem(clone, 1)
		Util.Debris:AddItem(clone2, 1)
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(folder, 5)
		local root = data.Root
		local proxy = data.Proxy

		if not proxy then
			return
		end

		coroutine.wrap(function()
			for _ = 1, 1 do
				local clone = X.FireFX:Clone()
				clone.CFrame = root.CFrame * CFrame.new(0, 0, -2)
				clone.Parent = folder
				Util.Debris:AddItem(clone, 1)
				Emit(clone)
				task.wait(0.125)
			end
		end)()
		coroutine.wrap(function()
			local clone = X.Bullet:Clone()
			clone.CFrame = root.CFrame * CFrame.new(0, 0, -3)
			clone.CFrame = data.randCFrame
			clone.Parent = folder
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.P = 1250
			bodyVelocity.MaxForce = createVector(9000000000, 9000000000, 9000000000)
			bodyVelocity.Parent = clone
			bodyVelocity.Velocity = data.velocity
			Emit(clone)

			repeat
				task.wait()
			until not proxy:IsDescendantOf(workspace) or proxy:GetAttribute("Exploded")

			clone.Transparency = 1
			clone.CanQuery = false
			clone.Anchored = true
			DisableAllFXs(clone.Root)
			Util.Debris:AddItem(clone, 1)
			local clone2 = X.Explosion:Clone()
			clone2.Position = clone.Position
			clone2.Parent = folder
			Emit(clone2)
			Util.Debris:AddItem(clone2, 2)
			Util.Sound:Play("BF_WaterFu_X_WaterBullet_Impact_0" .. tostring(math.random(1, 5)), clone2.Position)
			task.delay(0.15, function()
				for _ = 1, 2 do
					local v = clone2.Position + createVector(0, 5, 0)
					local v2 = clone2.CFrame.LookVector * Random.new():NextNumber(-50, 50) + clone2.CFrame.RightVector * Random.new():NextNumber(
						-50,
						50
					) + clone2.CFrame.UpVector * -15
					local raycastResult = workspace:Raycast(v, v2, raycastParams)

					if raycastResult then
						local clone3 = X.Puddle:Clone()
						clone3.Position = raycastResult.Position
						clone3.Parent = folder
						Util.Debris:AddItem(clone3, 3)
						Emit(clone3)
					end

					task.wait(0.05)
				end
			end)
		end)()
	end
end