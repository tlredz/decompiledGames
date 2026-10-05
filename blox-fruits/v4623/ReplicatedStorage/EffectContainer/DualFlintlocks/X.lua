game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local dualFlintlocks_X = FX:WaitForChild("DualFlintlocks").DualFlintlocks_X
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }

local function ParticleState(folder, enabled, p, p2)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if p and emitter:GetAttribute("Color") == true then
			emitter.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			if emitter:GetAttribute("FloorHit") == true and p2 then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			elseif emitter:GetAttribute("FloorHit") ~= true then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		else
			emitter.Enabled = enabled
		end
	end
end

return function(player)
	local origin = player.origin
	local root = player.root

	if not root or (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	local startCFrame = player.StartCFrame

	if player.stage == 1 then
		local tool = player.Tool
		local holding = player.Holding or tool and tool:FindFirstChild("Holding")

		if not (holding and holding.Value) then
			return
		end

		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "DualFlintlocksX"
		folder.Parent = _WorldOrigin
		local clone = dualFlintlocks_X.ShootEffect:Clone()
		clone.Weld.Part0 = character.RightHand
		clone.Parent = folder
		local clone2 = dualFlintlocks_X.ShootEffect:Clone()
		clone2.Weld.Part0 = character.LeftHand
		clone2.Parent = folder
		local clone3 = dualFlintlocks_X.GeneralArea:Clone()
		clone3.CFrame = startCFrame
		clone3.Parent = folder
		local lastTime = os.clock()
		local lastTime2 = os.clock()
		os.clock()
		local areaVector = player.AreaVector
		local lastTime3 = tick()
		local v = Util.Sound:Play("BF_WPN_RefFlintlock_BulletStorm_01", humanoidRootPart)
		local humanoidRootPart2 = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local flag = false
		local v2 = false
		local v3 = false

		while (tool or holding) and humanoidRootPart do
			if tick() - lastTime3 > 3 then
				v3 = true
				break
			end

			if tick() - lastTime3 > 0.3 then
				if flag then
					break
				end

				if not (holding and holding.Value or v2) then
					task.spawn(function()
						if player.root == humanoidRootPart2 then
							game.ReplicatedStorage.Ping:InvokeServer()
						end

						task.wait(0.05)
						flag = true
					end)
					v2 = true
				end
			end

			local cFrame = root.CFrame

			if os.clock() - lastTime2 > 0.05 then
				lastTime2 = os.clock()

				if character == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(6, 10, 0.03333333333333333, 0.13333333333333333)
				end

				local position = (cFrame * CFrame.new(
					random:NextNumber(-areaVector.X / 2, areaVector.X / 2),
					areaVector.Y * random:NextNumber(0.5, 0.7),
					random:NextNumber(-areaVector.Z / 2, areaVector.Z / 2)
				)).Position
				local position2 = (cFrame * CFrame.new(
					random:NextNumber(-areaVector.X / 2, areaVector.X / 2),
					-areaVector.Y * random:NextNumber(0.5, 0.7),
					random:NextNumber(-areaVector.Z / 2, areaVector.Z / 2)
				)).Position
				local raycastResult = workspace:Raycast(position, humanoidRootPart.Position - position, raycastParams)

				if raycastResult then
					position = raycastResult.Position
				end

				local raycastResult2 = workspace:Raycast(position, position2 - position, raycastParams)

				if raycastResult2 then
					position2 = raycastResult2.Position
				end

				local clone4 = dualFlintlocks_X.Start:Clone()
				local clone5 = dualFlintlocks_X.End:Clone()
				clone4.Beam.Attachment0 = clone4.a
				clone4.Beam.Attachment1 = clone5.b
				clone4.CFrame = CFrame.lookAt(position, position2)
				clone5.CFrame = clone4.CFrame
				clone4.Parent = folder
				clone5.Parent = folder
				local number = random:NextNumber(0.07, 0.15)
				TweenService:Create(clone5, TweenInfo.new(number, Enum.EasingStyle.Linear), {
					Position = position2
				}):Play()
				task.delay(number, function()
					local clone6 = dualFlintlocks_X.BulletImpact:Clone()

					if raycastResult2 then
						clone6.CFrame = CFrame.lookAt(
							raycastResult2.Position,
							raycastResult2.Position + raycastResult2.Normal
						)
					else
						clone6.Position = position2
					end

					clone6.Parent = folder
					ParticleState(clone6)
					TweenService:Create(clone6.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
						Brightness = 0,
						Range = 0
					}):Play()
					local clone7 = dualFlintlocks_X.LineDisapear:Clone()
					clone7.Size = Vector3.new(0, 0, (position2 - position).Magnitude)
					clone7.CFrame = CFrame.lookAt((position2 + position) / 2, position2)
					clone7.Parent = folder
					task.delay(random:NextNumber(0.3, 0.5), function()
						ParticleState(clone7)
						local clone8 = dualFlintlocks_X.Explode:Clone()
						clone8.CFrame = clone6.CFrame
						clone8.Parent = folder
						ParticleState(clone8, nil, nil, raycastResult2)
						TweenService:Create(clone8.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
							Brightness = 0,
							Range = 0
						}):Play()
						clone4:Destroy()
						clone5:Destroy()
					end)
				end)
			end

			if os.clock() - lastTime >= random:NextNumber(0.02, 0.04) then
				lastTime = os.clock()
				local clone4 = dualFlintlocks_X.Clashes:Clone()
				clone4.Position = (cFrame * CFrame.new(
					random:NextNumber(-areaVector.X / 2, areaVector.X / 2),
					random:NextNumber(-areaVector.Y / 2, areaVector.Y / 2),
					random:NextNumber(-areaVector.Z / 2, areaVector.Z / 2)
				)).Position
				clone4.Parent = folder
				ParticleState(clone4)
			end

			task.wait()
		end

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		if character == game.Players.LocalPlayer.Character then
			Util.CameraShaker:ShakeOnce(6, 10, 0.03333333333333333, 0.3)
		end

		task.wait(0.1)

		if v and not v3 then
			v.TimePosition = 3.1
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(7)
		folder:Destroy()
	elseif player.stage == 2 then
		local folder = Instance.new("Folder")
		folder.Name = "DualFlintlocksX2"
		folder.Parent = _WorldOrigin
		local clone = dualFlintlocks_X.BigExplode:Clone()
		clone.CFrame = startCFrame
		clone.Parent = folder
		ParticleState(clone)
		TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()

		if (startCFrame.Position - currentCamera.CFrame.Position).Magnitude <= 110 then
			local clone2 = dualFlintlocks_X.ColorCorrection:Clone()
			clone2.Parent = game:GetService("Lighting")
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				Brightness = 0,
				TintColor = Color3.new(1, 1, 1)
			}):Play()
			Util.CameraShaker:ShakeOnce(16, 12, 0.1, 0.5)
			task.delay(0.5, clone2.Destroy, clone2)
		end

		task.wait(7)
		folder:Destroy()
	end
end