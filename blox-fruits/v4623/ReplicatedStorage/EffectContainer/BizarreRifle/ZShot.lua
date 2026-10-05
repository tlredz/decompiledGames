game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local bizarreRifleZ = FX:WaitForChild("BizarreRifle").BizarreRifleZ

for _, part in pairs(bizarreRifleZ:GetChildren()) do
	if not part:IsA("BasePart") then
		continue
	end

	if part.Name:find("Portal") then
		Util.ResizeModel(part, 0.7, part.Position)
	elseif part.Name == "Explode" then
		Util.ResizeModel(part, 0.75, part.Position)
	else
		Util.ResizeModel(part, 0.5, part.Position)
	end
end

local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function ParticleState(folder, enabled, p)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if p and emitter:GetAttribute("Color") == true then
			emitter.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			emitter.Enabled = enabled
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OpenPortal(cFrame, parent, p)
	task.spawn(function()
		local clone = bizarreRifleZ.Portal:Clone()

		if p then
			Util.ResizeModel(clone, p, clone.Position)
		end

		clone.CFrame = cFrame
		clone.Parent = parent

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local _ = math.random(10, 13) / 10
		sound:Play("BF_WPN_BizzareRifle_Z_PortalOpen_0" .. tostring(math.random(1, 6)) .. "_V2", clone.Position)

		if not p then
			local clone2 = bizarreRifleZ.OuterPortal:Clone()
			clone2.CFrame = cFrame
			clone2.Parent = parent

			for _ = 1, 3 do
				TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					CFrame = clone2.CFrame * CFrame.Angles(0, 0, 0.6283185307179586)
				}):Play()
				task.wait(0.3)
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end
	end)
end

local random = Random.new()

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

return function(player)
	local WAIT_INTERVAL = 5
	local origin = player.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 900 then
		return
	end

	if player.stage == 1 then
		local tool = player.tool
		local holding = player.holding or tool and tool:FindFirstChild("Holding")

		if not holding then
			return
		end

		local equippedAttachment = Util.GetEquippedAttachment(player.Character, player.Attachment)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getAttachmentCFrame()
			if equippedAttachment then
				return equippedAttachment.WorldCFrame
			end

			return player.hrp.CFrame
		end

		local folder = Instance.new("Folder")
		folder.Name = "BizarreHoldEffect_" .. player.player.Name
		folder.Parent = _WorldOrigin
		local clone = bizarreRifleZ.Projectile:Clone()
		local attachmentCFrame = getAttachmentCFrame() -- equivalent call inferred; original call site unknown
		clone.CFrame = attachmentCFrame * CFrame.new(0, 0, -3)
		clone.Parent = folder
		local v = sound:Play("BF_WPN_BizzareRifle_ZHold_01_V2", clone)
		local lastTime = tick()

		while holding and holding.Value do
			task.wait()

			if tick() - lastTime >= random:NextNumber(0.02, 0.05) then
				lastTime = tick()
				task.spawn(function()
					local clone2 = bizarreRifleZ.Trail:Clone()
					local position2 = clone.Position + Vector3.new(
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30)
					) * 0.5
					local v3 = clone.Position + Vector3.new(
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30)
					) * 0.5
					local v4 = clone.Position + Vector3.new(
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30)
					) * 0.5
					local position = clone.Position
					clone2.Position = position2
					clone2.Parent = folder
					local lastTime2 = tick()

					while tick() - lastTime2 < 0.15 do
						local v5 = (tick() - lastTime2) / 0.15
						local v6 = position2 + (v3 - position2) * v5
						local v7 = v3 + (v4 - v3) * v5
						local v8 = v4 + (position - v4) * v5
						local v9 = v6 + (v7 - v6) * v5
						clone2.Position = v9 + (v7 + (v8 - v7) * v5 - v9) * v5
						task.wait()
					end

					clone2.Position = position

					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
			end

			local attachmentCFrame2 = getAttachmentCFrame() -- equivalent call inferred; original call site unknown
			clone.CFrame = attachmentCFrame2 * CFrame.new(0, 0, -3)
		end

		if v then
			sound:FadeOut(v, 0.2)
		end

		Util.Debris:AddItem(folder, 20)
	elseif player.stage == 2 then
		local parent = _WorldOrigin:FindFirstChild("BizarreHoldEffect_" .. player.player.Name)
		local proxy = player.Proxy

		if not proxy then
			return
		end

		local projectile

		if parent then
			parent.Name = "BizarreProjectile_" .. player.player.Name
			projectile = parent.Projectile
		else
			parent = Instance.new("Folder")
			parent.Name = "BizarreProjectile_" .. player.player.Name
			parent.Parent = _WorldOrigin
			projectile = bizarreRifleZ.Projectile:Clone()
			projectile.CFrame = player.hrp.CFrame * CFrame.new(0, 0, -8)
			projectile.Parent = parent
		end

		Util.Debris:AddItem(parent, 20)
		local cFrame = player.hrp.CFrame * CFrame.new(0, 0, -8)
		local clone = bizarreRifleZ.Shoot:Clone()
		clone.CFrame = cFrame
		clone.Parent = parent

		if player.player == game.Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(3, 9, 0.05, 0.2)
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		sound:Play("BF_WPN_BizzareRifle_Z_Fire_01_V2", clone.Position)
		OpenPortal(cFrame:Lerp(player.teleportCFrame, 0) * CFrame.new(0, 0, -1.5), parent, 0.6) -- equivalent call inferred; original call site unknown
		projectile.Trail.Enabled = false
		projectile.CFrame = player.teleportCFrame
		OpenPortal(projectile.CFrame, parent, nil) -- equivalent call inferred; original call site unknown
		projectile.Trail.Enabled = true
		proxy.AttributeChanged:Connect(function(p)
			if p == "Teleporting" then
				projectile.Trail.Enabled = false
				task.wait(0.016666666666666666)
				proxy.CFrame = CFrame.new(proxy:GetAttribute("Teleporting")) * (proxy.CFrame - proxy.Position)
				projectile.CFrame = proxy.CFrame
				task.wait(0.016666666666666666)
				projectile.Trail.Enabled = true
			end
		end)
		local lastTime = tick()

		while tick() - lastTime < player.lifetime - player.teleportDuration do
			projectile.CFrame = proxy.CFrame

			if not proxy:IsDescendantOf(workspace) then
				break
			end

			task.wait()
		end

		projectile.Trail.Enabled = false
		local folder = projectile

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(WAIT_INTERVAL)
		parent:Destroy()
	elseif player.stage == 3 then
		local parent = _WorldOrigin:FindFirstChild("BizarreProjectile_" .. player.player.Name)
		local projectile

		if parent then
			projectile = parent.Projectile
		else
			parent = Instance.new("Folder")
			parent.Name = "BizarreProjectile_" .. player.player.Name
			parent.Parent = _WorldOrigin
			projectile = bizarreRifleZ.Projectile:Clone()
			projectile.CFrame = player.hrp.CFrame * CFrame.new(0, 0, -8)
			projectile.Parent = parent
		end

		local trail = projectile.Trail
		OpenPortal(player.portalStart, parent, nil) -- equivalent call inferred; original call site unknown
		task.wait(0.15)
		projectile.CFrame = player.portalStart

		for _, emitter in pairs(projectile:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		trail.Enabled = true
		local v4 = (player.portalStart.Position - player.portalEnd.Position).Magnitude / player.speed
		TweenService:Create(projectile, TweenInfo.new(v4, Enum.EasingStyle.Linear), {
			CFrame = player.portalEnd
		}):Play()
		task.spawn(function()
			task.wait(v4 * 0.7)
			OpenPortal(player.portalEnd, parent, nil) -- equivalent call inferred; original call site unknown
			task.wait(v4 * 0.2)
			local folder = projectile

			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			trail.Enabled = false
		end)
	elseif player.stage == 4 then
		local parent = _WorldOrigin:FindFirstChild("BizarreProjectile_" .. player.player.Name)
		local projectile

		if parent then
			projectile = parent.Projectile
		else
			parent = Instance.new("Folder")
			parent.Name = "BizarreProjectile_" .. player.player.Name
			parent.Parent = _WorldOrigin
			projectile = bizarreRifleZ.Projectile:Clone()
			projectile.CFrame = player.hrp.CFrame * CFrame.new(0, 0, -8)
			projectile.Parent = parent
		end

		local trail = projectile.Trail
		OpenPortal(player.portalStart, parent, nil) -- equivalent call inferred; original call site unknown
		task.wait(0.15)
		projectile.CFrame = player.portalStart
		local v3 = (player.portalStart.Position - player.portalEnd.Position).Magnitude / player.speed

		for _, emitter in pairs(projectile:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		trail.Enabled = true
		TweenService:Create(projectile, TweenInfo.new(v3, Enum.EasingStyle.Linear), {
			CFrame = player.portalEnd
		}):Play()
		task.wait(v3)

		for _, emitter in pairs(projectile:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local portalEnd = player.portalEnd
		local clone = bizarreRifleZ.Explode:Clone()
		clone.CFrame = portalEnd
		clone.Parent = parent
		Util.ResizeModel(clone, 0.65, clone.Position)
		sound:Play("ElectricStrike", clone.Position)
		sound:Play("BF_WPN_BizarreRifle_Portal_Explosion_Big_01", clone.Position)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		if (currentCamera.CFrame.Position - clone.Position).Magnitude <= 120 then
			local clone2 = bizarreRifleZ.ColorCorrection:Clone()
			clone2.Parent = game:GetService("Lighting")
			TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				TintColor = Color3.new(1, 1, 1)
			}):Play()
			task.wait(0.3)
			clone2:Destroy()
		end

		task.wait(WAIT_INTERVAL)
		parent:Destroy()
	elseif player.stage == 99 then
		local folder = Instance.new("Folder", workspace._WorldOrigin)
		Util.Debris:AddItem(folder, 2)
		OpenPortal(player.PortalCFrame, folder, nil) -- equivalent call inferred; original call site unknown
	elseif player.stage == 20 then
		local parent = _WorldOrigin:FindFirstChild("BizarreProjectile_" .. player.player.Name)
		local hitbox = player.hitbox

		if not hitbox then
			return
		end

		local projectile

		if parent then
			projectile = parent.Projectile
		else
			parent = Instance.new("Folder")
			parent.Name = "BizarreZEffect"
			parent.Parent = _WorldOrigin
			projectile = bizarreRifleZ.Projectile:Clone()
			projectile.CFrame = player.hrp.CFrame * CFrame.new(0, 0, -8)
			projectile.Parent = parent
		end

		Util.Debris:AddItem(parent, 20)
		local cFrame = player.hrp.CFrame * CFrame.new(0, 0, -8)
		local clone = bizarreRifleZ.Shoot:Clone()
		clone.CFrame = cFrame
		clone.Parent = parent

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		OpenPortal(cFrame:Lerp(player.teleportCFrame, 0.5), parent, nil) -- equivalent call inferred; original call site unknown
		local tween = TweenService:Create(projectile, TweenInfo.new(player.teleportDuration, Enum.EasingStyle.Linear), {
			CFrame = cFrame:Lerp(player.teleportCFrame, 0.5)
		})
		tween:Play()
		tween.Completed:Wait()
		projectile.Trail.Enabled = false
		projectile.CFrame = player.teleportCFrame
		OpenPortal(projectile.CFrame, parent, nil) -- equivalent call inferred; original call site unknown
		projectile.Trail.Enabled = true
		local lastTime = tick()

		while tick() - lastTime < player.lifetime - player.teleportDuration do
			projectile.CFrame = hitbox.CFrame

			if not hitbox:IsDescendantOf(workspace) then
				break
			end

			task.wait()
		end

		projectile.Trail.Enabled = false

		for _, emitter in pairs(projectile:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(WAIT_INTERVAL)
		parent:Destroy()
	elseif player.stage == 30 then
		local targetCFrame = player.targetCFrame or CFrame.new(player.targetPos)
		local folder = Instance.new("Folder")
		folder.Name = "BizarreZExplosion"
		folder.Parent = _WorldOrigin
		local clone = bizarreRifleZ.Explode:Clone()
		clone.CFrame = targetCFrame
		clone.Parent = folder
		Util.ResizeModel(clone, 0.65, clone.Position)
		sound:Play("ElectricStrike", clone.Position)
		sound:Play("BF_WPN_BizarreRifle_Portal_Explosion_Big_01", clone.Position)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		if (currentCamera.CFrame.Position - clone.Position).Magnitude <= 120 then
			Effect.new("ShakeCam"):play({
				24,
				15,
				0.1,
				0.5
			})
			local clone2 = bizarreRifleZ.ColorCorrection:Clone()
			clone2.Parent = game:GetService("Lighting")
			TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				TintColor = Color3.new(1, 1, 1)
			}):Play()
			task.wait(0.3)
			clone2:Destroy()
		end

		task.wait(WAIT_INTERVAL)
		folder:Destroy()
	end
end