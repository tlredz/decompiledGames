local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local X = FX:WaitForChild("DragonTalon").X
local spring = Util.Spring
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

local function AlignCFrame(data, p)
	local v = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p2, unit2, v, unit3)
end

return function(player)
	local maid = player.Maid
	local origin = player.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local character = player.Character

	if player.Stage == 0 then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 5)
		local dragonTest = X.DragonTest
		local root = player.Root
		local clone = dragonTest:Clone()

		if maid then
			local function fn()
				clone:Destroy()
				folder:Destroy()
			end

			maid.AncestryChanged:Once(fn)
			maid.Destroying:Once(fn)

			if not maid.Parent then
				task.defer(fn)
			end
		end

		clone.Name = "DragonHeadTween"
		clone.CFrame = root.CFrame * CFrame.new(0, -10, 0)
		clone.Dragon:ScaleTo(0.3)
		clone.Parent = workspace._WorldOrigin
		local total = 0.0888
		local v = false
		pcall(function()
			while clone:IsDescendantOf(workspace._WorldOrigin) do
				task.wait()

				if total + 0.0148 < 0.296 then
					total += 0.0148
				else
					total = 0.296
				end

				if not v then
					clone.Dragon:ScaleTo(total)
				end

				if total >= 0.296 then
					v = true
					break
				elseif not clone:IsDescendantOf(workspace) then
					break
				end
			end
		end)
	elseif player.Stage == 1 then
		local proxy = player.Proxy

		if not (proxy and proxy:IsDescendantOf(workspace)) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 15)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local startCFrame = player.StartCFrame
		local holding = player.Holding

		if not holding then
			return
		end

		local _ = tick() + 5
		local clone = X.Phase1.StartImpact:Clone()
		clone.CFrame = startCFrame * CFrame.new(0, 0, -5)
		clone.Parent = folder
		Util.Sound:Play("DragonTalon.XFire", humanoidRootPart.Position)

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local clone2 = X.Phase1.Projectile:Clone()
		clone2.CFrame = startCFrame
		clone2.Parent = folder

		if _WorldOrigin:FindFirstChild("DragonHeadTween") then
			_WorldOrigin:FindFirstChild("DragonHeadTween"):Destroy()
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local v = Util.Sound:Play("DragonTalon.XTravel", clone2)

		if holding.Value == true then
			task.spawn(function()
				local clone3 = X.Phase2.WeldPart:Clone()
				clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -10, 0)
				clone3.Parent = folder
				clone3.Weld.Part1 = humanoidRootPart
				clone3.Weld.C0 = CFrame.new(0, 10, 0)
				local dTalonXRideLoop = Util.Anims:Get(character, "DTalon_XRideLoop")
				dTalonXRideLoop:Play()
				local Players = game:GetService("Players")
				local clone4, renderSteppedConnection

				if Players.LocalPlayer.Character == player.Character then
					clone4 = X.Phase2.CameraFocus:Clone()
					clone4.Parent = folder
					renderSteppedConnection = RunService.RenderStepped:Connect(function()
						clone4.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
					end)

					for _, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				else
					clone4 = nil
				end

				local clone5 = X.Phase2.FireAura:Clone()
				clone5.CFrame = humanoidRootPart.CFrame
				clone5.Parent = folder
				clone5.Anchored = false
				clone5.Weld.Part1 = humanoidRootPart
				clone5.Weld.C1 = CFrame.new(0, -2.5, 0)

				for _, emitter in pairs(clone5:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				local lastTime = tick()
				local v2 = player.Duration - 0.5

				while holding.Value == true and proxy:IsDescendantOf(workspace) and tick() - lastTime < v2 do
					clone3.CFrame = clone2.CFrame
					RunService.PreSimulation:Wait()
				end

				dTalonXRideLoop:Stop()
				Util.Sound:Play("DragonTalon.XFlip", humanoidRootPart.Position)
				local dTalonXRideJumpOff = Util.Anims:Get(character, "DTalon_XRideJumpOff")
				dTalonXRideJumpOff.Priority = Enum.AnimationPriority.Action
				dTalonXRideJumpOff:Play()
				Util.BodyMover.new(character):Create("BodyVelocity", {
					Duration = 0.2,
					Velocity = humanoidRootPart.CFrame.LookVector * -60 + createVector(0, 30, 0)
				})
				local cFrame = humanoidRootPart.CFrame
				clone5:Destroy()
				clone3.Weld.Enabled = false
				clone3:Destroy()
				humanoidRootPart.CFrame = cFrame

				if clone4 then
					for _, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					task.wait(0.5)
					renderSteppedConnection:Disconnect()
					clone4:Destroy()
				end
			end)
		end

		local range = player.Range
		local _ = player.Speed
		local _ = clone2.CFrame * CFrame.new(0, 0, -range)
		local duration = player.Duration
		local clone3 = X.Phase2.GroundBurn:Clone()
		clone3.CFrame = startCFrame
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local emitters = {}
		local v2 = false

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				table.insert(emitters, emitter)
			end
		end

		local lastTime = tick()
		local position = startCFrame.Position
		local lastTime2 = tick()
		local v3 = spring.new(0.6, 1.4, proxy.Value.Position)
		local v4 = 0.016666666666666666

		while tick() - lastTime < duration and proxy:IsDescendantOf(workspace) do
			v3:SetGoal(proxy.Value.Position)
			v3:Update(v4)
			task.spawn(function()
				if tick() - lastTime2 > 0.1 then
					lastTime2 = tick()
					local raycastResult = workspace:Raycast(
						clone2.Position + createVector(0, 1, 0),
						createVector(-0, -50, -0),
						raycastParams
					)

					if raycastResult then
						clone3.CFrame = CFrame.new(
							raycastResult.Position + createVector(0, 0.1, 0),
							raycastResult.Position + createVector(0, 0.1, 0) + clone2.CFrame.LookVector
						)

						if v2 == false then
							v2 = true

							for _, v5 in pairs(emitters) do
								v5.Enabled = true
							end
						end
					elseif v2 == true then
						v2 = false

						for _, v5 in pairs(emitters) do
							v5.Enabled = false
						end
					end
				end
			end)
			clone2.CFrame = CFrame.new(v3:GetPosition(), position - humanoidRootPart.CFrame.LookVector * 0.012345) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			)
			position = clone2.Position
			v4 = RunService.RenderStepped:Wait()
		end

		if v then
			sound:FadeOut(v, 0.2)
		end

		local tween = TweenService:Create(clone2, TweenInfo.new(0.1), {
			CFrame = CFrame.new(proxy.Value.Position) * (clone2.CFrame - clone2.Position)
		})
		tween:Play()
		tween.Completed:Wait()

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, descendant in pairs(clone2:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
				descendant.Enabled = false
			elseif descendant:IsA("MeshPart") then
				descendant.Transparency = 1
			elseif descendant:IsA("Trail") then
				descendant.Enabled = false
			end
		end
	elseif player.Stage == 2 then
		task.wait(0.03333333333333333)
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 15)
		local clone = X.Phase1.Explosion:Clone()
		clone.CFrame = player.ExplosionCFrame
		clone.Parent = folder
		Util.Sound:Play("DragonTalon.XExplosion", clone.Position)

		if (currentCamera.CFrame.p - player.ExplosionCFrame.Position).Magnitude <= 130 then
			Effect.new("ShakeCam"):play({
				25,
				10,
				0.25,
				0.5
			})
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		task.spawn(function()
			local floorBurn = player.FloorBurn
			local burnDuration = player.BurnDuration

			if floorBurn then
				local clone2 = X.Phase1.GroundBurn:Clone()
				clone2.CFrame = AlignCFrame(CFrame.new(floorBurn[1]), floorBurn[2]) + floorBurn[2] * 0.01
				clone2.Parent = folder

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.wait(burnDuration)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		end)
	end
end