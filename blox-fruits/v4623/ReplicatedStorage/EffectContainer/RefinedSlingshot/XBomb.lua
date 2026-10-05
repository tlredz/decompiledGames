local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local refinedSlingshot_X = FX:WaitForChild("RefinedSlingshot").RefinedSlingshot_X
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

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
Util.ResizeModel(refinedSlingshot_X.Explode, 1.375, refinedSlingshot_X.Explode.Position)
return function(player)
	local origin = player.origin
	local _ = player.dir

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	if player.stage == 1 then
		local tool = player.tool
		local holding = player.holding or tool and tool:FindFirstChild("Holding")

		if not holding then
			return
		end

		local hrp = player.hrp
		local holdKey = player.holdKey or player.userId or not player.Character and "unknown" or player.Character.Name or "unknown"
		local folder = Instance.new("Folder")
		folder.Name = "RefinedSlingshotBomb" .. tostring(player.iteration) .. "_" .. tostring(holdKey)
		folder.Parent = _WorldOrigin
		local equippedAttachment = Util.GetEquippedAttachment(player.Character, player.Attachment)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getAttachmentCFrame()
			if equippedAttachment then
				return equippedAttachment.WorldCFrame
			end

			return hrp.CFrame
		end

		local clone = refinedSlingshot_X.BombModel:Clone()
		local bomb = clone.Bomb
		clone:ScaleTo(0.3)
		local attachmentCFrame = getAttachmentCFrame() -- equivalent call inferred; original call site unknown
		bomb.CFrame = attachmentCFrame * CFrame.new(0.3, -0.6, -0.4) * CFrame.Angles(
			0,
			0.6108652381980153,
			-1.5707963267948966
		)
		clone.Parent = folder
		local v = sound:Play("BF_WPN_Slingshot_X_Bomb_Fuse_01", bomb)

		while holding and holding.Value do
			local attachmentCFrame2 = getAttachmentCFrame() -- equivalent call inferred; original call site unknown
			bomb.CFrame = attachmentCFrame2 * CFrame.new(0.3, -0.6, -0.4) * CFrame.Angles(
				0,
				0.6108652381980153,
				-1.5707963267948966
			)
			task.wait()
		end

		if v then
			sound:FadeOut(v, 5)
		end

		Util.Debris:AddItem(folder, 15)
	else
		if player.stage ~= 2 then
			return
		end

		local holdKey = player.holdKey or player.userId or not player.Character and "unknown" or player.Character.Name or "unknown"
		local child = _WorldOrigin:FindFirstChild("RefinedSlingshotBomb" .. tostring(player.iteration) .. "_" .. tostring(holdKey))
		local stateProxy = player.stateProxy
		local _ = player.maxRange
		local projectileSpeed = player.projectileSpeed
		local _ = player.lifetime
		local idleTime = player.idleTime
		local miniCount = player.MiniCount

		if not child then
			return
		end

		child.Name = ""
		local bombModel = child.BombModel
		local startCFrame = player.startCFrame
		local bomb = bombModel.Bomb
		bomb.Anchored = true
		bomb.CFrame = startCFrame
		bomb.Trail.Enabled = false
		local lastTime = os.clock()
		local scale = bombModel:GetScale()

		while os.clock() - lastTime < 0.16666666666666666 do
			bombModel:ScaleTo(scale + (1 - scale) * (os.clock() - lastTime) / 0.16666666666666666)
			bomb.CFrame = startCFrame
			task.wait()
		end

		bombModel:ScaleTo(1)
		bomb.Trail.Enabled = true
		local clone = refinedSlingshot_X.Launch:Clone()
		clone.CFrame = startCFrame
		clone.Parent = child

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		sound:Play("BF_WPN_Slingshot_X_BombFire_01_V2", clone.Position)
		local targetPosition = player.targetPosition
		bomb.CFrame = startCFrame
		local position = bomb.Position
		workspace:Raycast(bomb.Position, bomb.CFrame.LookVector * 10, raycastParams)
		local position2 = startCFrame.Position
		local v = (targetPosition - position2 - createVector(0, -7.5, 0)) * projectileSpeed

		local function Weld(stateProxy2, bomb2)
			local weld = Instance.new("Weld")
			weld.Part0 = stateProxy2
			weld.Part1 = bomb2
			local cframe = CFrame.new(stateProxy2.Position)
			local C0 = stateProxy2.CFrame:inverse() * cframe
			local C1 = bomb2.CFrame:inverse() * cframe
			weld.C0 = C0
			weld.C1 = C1
			weld.Parent = stateProxy2
		end

		bomb.Anchored = false
		bomb.Massless = true
		bomb.CanCollide = false
		local lastTime2 = os.clock()
		task.wait()
		local raycastResult

		while true do
			local v2 = os.clock() - lastTime2
			raycastResult = workspace:Raycast(startCFrame.Position, startCFrame.LookVector * 8, raycastParams)

			if raycastResult then
				break
			end

			local position3 = CFrame.new(createVector(0, -7.5, 0) * (projectileSpeed * v2) ^ 2 + v * v2 + position2).Position
			startCFrame = CFrame.lookAt(position3, position) * CFrame.Angles(0, 3.141592653589793, 0)
			bomb.CFrame = startCFrame
			task.wait()
			position = position3
		end

		TweenService:Create(bomb.EndBeam, TweenInfo.new(idleTime * 0.9, Enum.EasingStyle.Linear), {
			Position = bomb.BeginingBeam.Position
		}):Play()
		TweenService:Create(bomb.Beam, TweenInfo.new(idleTime * 0.9, Enum.EasingStyle.Linear), {
			CurveSize0 = 0,
			CurveSize1 = 0
		}):Play()
		bomb.CFrame = CFrame.new(raycastResult.Position + raycastResult.Normal * bomb.Size.X / 1.9) * (bomb.CFrame - bomb.Position)
		bomb.Anchored = false
		bomb.Massless = true
		bomb.CanCollide = true
		bomb.Trail.Enabled = false
		task.spawn(function()
			bomb.CanCollide = false
			bomb.CFrame = stateProxy.CFrame
			Weld(stateProxy, bomb)
		end)
		local lastTime3 = os.clock()

		repeat
			task.wait()
		until not stateProxy or not stateProxy:IsDescendantOf(workspace) or stateProxy:GetAttribute("Exploding")

		if not stateProxy then
			child:Destroy()
			return
		end

		if os.clock() - lastTime3 <= idleTime then
			TweenService:Create(bomb, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Color = Color3.new(1, 0, 0)
			}):Play()

			for _, emitter in pairs(bomb:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(0.15)
		end

		local clone2 = refinedSlingshot_X.Explode:Clone()
		clone2.Position = bomb.Position
		clone2.Parent = child

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		sound:Play("BF_WPN_Ink_ClusterBombExplosion_01", clone2.Position)
		TweenService:Create(clone2.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()
		bomb:Destroy()

		for i = 1, miniCount do
			local v2 = i
			task.spawn(function()
				local v3 = player.MiniData[v2]
				local clone3 = refinedSlingshot_X.BombModel:Clone()
				local bomb2 = clone3.Bomb
				clone3:ScaleTo(0.3)
				bomb2.CanCollide = true
				bomb2.Anchored = false
				bomb2.Position = clone2.Position + v3[1]
				bomb2.Parent = child
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = v3[2]
				bodyVelocity.Parent = bomb2
				task.wait(0.1)
				bodyVelocity:Destroy()
				task.wait(v3[3])
				local clone4 = refinedSlingshot_X.SmallExplosion:Clone()
				clone4.Position = bomb2.Position
				clone4.Parent = child

				for i2, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				TweenService:Create(
					clone4.PointLight,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Range = 0,
						Brightness = 0
					}
				):Play()

				for i2, emitter in pairs(bomb2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				bomb2.Beam.Width0 = 0
				bomb2.Beam.Width1 = 0
				bomb2.Transparency = 1
				bomb2.Spikes.Transparency = 1
				bomb2.Anchored = true
			end)
		end

		task.wait(10)
		child:Destroy()
	end
end