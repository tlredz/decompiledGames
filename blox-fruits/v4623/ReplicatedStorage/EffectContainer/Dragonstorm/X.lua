local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Lighting = game:GetService("Lighting")
game:GetService("Players")
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local _ = currentCamera.FieldOfView
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local X = FX:WaitForChild("Dragonstorm").X
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Characters }

local function ParticleState(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if effect:IsA("ParticleEmitter") and enabled == nil then
			effect:Emit(effect:GetAttribute("EmitCount"))
		elseif enabled ~= nil then
			effect.Enabled = enabled
		end
	end
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

for _, emitter in pairs(X:GetDescendants()) do
	if not emitter:IsA("ParticleEmitter") then
		continue
	end

	local v

	if emitter.Parent.Name == "Smoke" then
		v = 0.75
	elseif emitter.Parent.Name == "FloorFlameTriangle" then
		v = 1.1
	elseif emitter.Parent.Name == "Ember" or emitter.Parent.Name == "OrbAppear" or emitter.Parent.Name == "Orb" or emitter.Parent.Parent.Name == "Orb" or emitter.Parent.Name == "Windup" or emitter.Parent.Name == "TrailWindup" then
		v = 1
	else
		v = 0.5
	end

	emitter.Rate *= v
end

return function(player)
	local origin = player.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1000 then
		return
	end

	local stage = player.Stage

	if stage == 1 then
		local holding = player.Holding

		if not (holding and holding.Value) then
			return
		end

		local equippedAttachment = Util.GetEquippedAttachment(player.Character, player.Attachment)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getAttachmentPosition()
			if equippedAttachment then
				return equippedAttachment.WorldPosition
			end

			return player.Root.Position
		end

		local playerKey = player.PlayerKey or player.Player and player.Player.UserId or not player.Character and "unknown" or player.Character.Name or "unknown"
		local folder = Instance.new("Folder")
		folder.Name = "DragonGatlingX_" .. tostring(playerKey)
		folder.Parent = _WorldOrigin
		local root = player.Root
		local clone = X.OrbAppear:Clone()
		local cframe = CFrame.lookAt(createVector(0, 0, 0), root.CFrame.LookVector)
		local attachmentPosition = getAttachmentPosition() -- equivalent call inferred; original call site unknown
		clone.CFrame = (cframe + attachmentPosition) * CFrame.new(0, 0, -3)
		clone.Parent = folder
		ParticleState(clone)
		sound:Play("DragonStorm_X_ActivateCharge_01", root)
		local v = sound:Play("DragonStorm_X_Charge_Loop_01", root)
		TweenService:Create(v, TweenInfo.new(0.5), {
			Volume = 1.25
		}):Play()
		local clone2 = X.OrbModel:Clone()
		local orb = clone2.Orb
		clone2:ScaleTo(clone2:GetScale() * 0.5)
		local cframe2 = CFrame.lookAt(createVector(0, 0, 0), root.CFrame.LookVector)
		local attachmentPosition2 = getAttachmentPosition() -- equivalent call inferred; original call site unknown
		orb.CFrame = (cframe2 + attachmentPosition2) * CFrame.new(0, 0, -3)
		clone2.Parent = folder
		local clone3 = X.Windup:Clone()
		local attachmentPosition3 = getAttachmentPosition() -- equivalent call inferred; original call site unknown
		clone3.Position = attachmentPosition3
		clone3.Parent = folder
		local lastTime = os.clock()
		local lastTime2 = os.clock()
		local lastTime3 = os.clock()
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			if os.clock() - lastTime2 >= 0.14 then
				lastTime2 = os.clock()
				local clone4 = X.Ember:Clone()
				local cframe3 = CFrame.lookAt(createVector(0, 0, 0), root.CFrame.LookVector)
				local attachmentPosition4 = getAttachmentPosition() -- equivalent call inferred; original call site unknown
				local cFrame = (cframe3 + attachmentPosition4) * CFrame.new(
					random:NextNumber(-20, 20),
					random:NextNumber(0, 20),
					random:NextNumber(-10, 10)
				)
				local number = random:NextNumber(0, 360)
				local v3 = (random:NextInteger(0, 1) * 2 - 1) * random:NextNumber(1460, 2120)
				local number2 = random:NextNumber(1, 5)
				local total = 0
				local number3 = random:NextNumber(40, 70)
				local position = cFrame.Position
				local position2 = nil
				clone4.CFrame = cFrame
				clone4.Parent = folder
				local heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
					number += v3 * dt
					total += number3 * dt
					position2 = (cFrame * CFrame.new(
						math.sin((math.rad(number))) * number2,
						math.cos((math.rad(number))) * number2,
						-total
					)).Position
					clone4.CFrame = CFrame.lookAt(position2, position) * CFrame.Angles(0, 3.141592653589793, 0)
					position = position2
				end)
				task.delay(random:NextNumber(0.2, 0.4), function()
					heartbeatConnection2:Disconnect()
					ParticleState(clone4, false)
				end)
			end

			if os.clock() - lastTime3 >= 0.2 then
				lastTime3 = os.clock()
				local clone4 = X.TrailWindup:Clone()
				local number = random:NextNumber(0, 360)
				local number2 = random:NextNumber(900, 1400)
				local number3 = random:NextNumber(6, 8)
				CFrame.new(0, 0, random:NextNumber(-4, 2))
				clone4.CFrame = orb.CFrame * CFrame.new(
					math.sin((math.rad(number))) * number3,
					math.cos((math.rad(number))) * number3,
					0
				)
				clone4.Parent = folder
				local heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
					number += number2 * dt
					clone4.CFrame = orb.CFrame * CFrame.new(
						math.sin((math.rad(number))) * number3,
						math.cos((math.rad(number))) * number3,
						0
					)
				end)
				task.delay(random:NextNumber(0.7, 1.3), function()
					heartbeatConnection2:Disconnect()
					ParticleState(clone4, false)
				end)
			end

			if os.clock() - lastTime >= 0.15 then
				lastTime = os.clock()
				local number = random:NextNumber(1, 12)
				local clone4 = X.Beam:Clone()
				clone4:ScaleTo(number ^ random:NextNumber(0.2, 0.4) / 2)
				local beams = clone4.Beams
				beams.CFrame = orb.CFrame * CFrame.new(0, 0, number) * CFrame.Angles(
					0,
					0,
					random:NextNumber(0, 6.283185307179586)
				)
				clone4.Parent = folder
				local number2 = random:NextNumber(0.1, 0.3)
				TweenService:Create(beams, TweenInfo.new(number2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Orientation = beams.Orientation + Vector3.new(0, 0, random:NextNumber(180, 420))
				}):Play()
				TweenService:Create(
					beams.Beam,
					TweenInfo.new(number2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				):Play()
			end
		end)

		while true do
			local cframe3 = CFrame.lookAt(createVector(0, 0, 0), root.CFrame.LookVector)
			local attachmentPosition4 = getAttachmentPosition() -- equivalent call inferred; original call site unknown
			orb.CFrame = (cframe3 + attachmentPosition4) * CFrame.new(0, 0, -3)
			task.wait()

			if holding and holding.Value then
				continue
			end

			if v then
				sound:FadeOut(v, 0.15)
			end

			local clone4 = X.StartStar:Clone()
			local cframe4 = CFrame.lookAt(createVector(0, 0, 0), root.CFrame.LookVector)
			local attachmentPosition5 = getAttachmentPosition() -- equivalent call inferred; original call site unknown
			clone4.CFrame = (cframe4 + attachmentPosition5) * CFrame.Angles(0, 3.141592653589793, 0)
			clone4.Parent = folder
			ParticleState(clone4)
			ParticleState(clone3, false)
			heartbeatConnection:Disconnect()
			Util.Debris:AddItem(folder, 20)
			task.wait(2)

			if not folder:GetAttribute("Transferred") then
				folder:Destroy()
			end

			return
		end
	elseif stage == 2 then
		local playerKey = player.PlayerKey or player.Player and player.Player.UserId or not player.Character and "unknown" or player.Character.Name or "unknown"
		local parent = _WorldOrigin:FindFirstChild("DragonGatlingX_" .. tostring(playerKey))
		local projectileSpeed = player.ProjectileSpeed
		local lifetime = player.Lifetime
		local _ = player.projectileSpeed
		local orbModel, orb

		if parent then
			parent.Name = "DragonGatlingX_" .. tostring(playerKey) .. "_" .. player.Iteration
			orbModel = parent:FindFirstChild("OrbModel")

			if not orbModel then
				local clone_2 = X.OrbModel:Clone()
				clone_2.Parent = parent
				orbModel = nil
			end

			orb = parent.OrbModel.Orb
			orb.CFrame = player.StartCFrame
		else
			parent = Instance.new("Folder")
			parent.Name = "DragonGatlingX_" .. tostring(playerKey) .. "_" .. player.Iteration
			parent.Parent = _WorldOrigin
			orbModel = X.OrbModel:Clone()
			orb = orbModel.Orb
			orb.CFrame = player.StartCFrame
			orbModel.Parent = parent
		end

		parent:SetAttribute("Transferred", true)
		local clone = X.Shoot:Clone()
		clone.CFrame = player.StartCFrame
		clone.Parent = parent
		ParticleState(clone)
		sound:Play("DragonStorm_X_Fire_01", clone.Position)
		local player2 = player.Player
		local Players = game:GetService("Players")

		if player2 == Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(25, 25, 0.05, 1)
			task.spawn(function()
				local clone2 = X.ColorCorrectionShot:Clone()
				local brightness = clone2.Brightness
				local contrast = clone2.Contrast
				local saturation = clone2.Saturation
				local tintColor = clone2.TintColor
				clone2.Brightness = 0
				clone2.Contrast = 0
				clone2.Saturation = 0
				clone2.TintColor = Color3.new(1, 1, 1)
				clone2.Parent = Lighting
				TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Brightness = brightness,
					Contrast = contrast,
					Saturation = saturation,
					TintColor = tintColor
				}):Play()
				task.wait(0.2)
				TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Brightness = 0,
					Contrast = 0,
					Saturation = 0,
					TintColor = Color3.new(1, 1, 1)
				}):Play()
				task.wait(0.2)
				clone2:Destroy()
			end)
		end

		for i = 1, 3 do
			local clone2 = X.DragonParticle:Clone()
			local v2 = (i - 1) * 120
			local total = 0
			local v3 = -projectileSpeed * 0.9
			local cFrame = orb.CFrame
			local position = (cFrame * CFrame.new(math.sin((math.rad(v2))) * 25, math.cos((math.rad(v2))) * 25, total)).Position
			local position2 = nil
			clone2.Position = position
			clone2.Parent = parent
			local v4 = tick()

			local function fn()
				local v5 = tick() - v4
				return lifetime + 0.15 < v5
			end

			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				if fn() then
					ParticleState(clone2, false)
					heartbeatConnection:Disconnect()
				else
					v2 += 600 * dt
					total += v3 * dt
					position2 = (cFrame * CFrame.new(
						math.sin((math.rad(v2))) * 25,
						math.cos((math.rad(v2))) * 25,
						total
					)).Position
					clone2.CFrame = CFrame.lookAt(position2, position) * CFrame.Angles(0, 3.141592653589793, 0)
					position = position2
				end
			end)
			local v8 = clone2
			task.delay(random:NextNumber(0.7, 0.9), function()
				if not heartbeatConnection.Connected then
					return
				end

				fn = function()
					return false
				end

				ParticleState(v8, false)
				task.wait(0.3)
				heartbeatConnection:Disconnect()
			end)
		end

		orbModel:ScaleTo(0.5)
		ParticleState(orb, true)
		local raycastResult = nil
		local lastTime = os.clock()
		local raycastResult2 = workspace:Raycast(orb.Position, createVector(0, -12, 0), raycastParams)
		local raycastResult3 = nil
		local raycastResult4 = workspace:Raycast(orb.Position, createVector(0, -12, 0), raycastParams)
		local raycastResult5 = nil
		local lastTime2 = os.clock()
		local lastTime3 = os.clock()
		local v2 = false
		local clone2 = X.FloorEffect:Clone()
		ParticleState(clone2, v2)
		clone2.Parent = parent
		os.clock()
		local count = 0
		local heartbeatConnection = nil
		local clone3 = X.Dragon:Clone()
		task.spawn(function()
			local trail = clone3.Trail
			orb.Attachment:Destroy()
			ParticleState(orb, false)
			clone3.RootPart.Weld.Part0 = orb
			clone3.Parent = parent
			ParticleState(clone3.Appear)
			task.wait(lifetime)
			ParticleState(trail, false)
			ParticleState(clone3, false)
			task.wait(0.3)

			for _, part in clone3:GetChildren() do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end
		end)
		local lastTime4 = os.clock()
		local v3 = false
		local scale = clone3:GetScale()
		task.delay(lifetime * 0.4, function()
			local lifetime2 = lifetime
			local rootPart = clone3.RootPart
			local bone002 = rootPart.tail.Bone["Bone.002"]
			local bone004 = rootPart.tail.Bone["Bone.004"]
			TweenService:Create(
				bone002,
				TweenInfo.new(lifetime2 * 0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
				{
					CFrame = CFrame.new(0, 4.764, -0.937) * CFrame.Angles(1.2280834748732898, 0, 0)
				}
			):Play()
			TweenService:Create(
				bone004,
				TweenInfo.new(lifetime2 * 0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
				{
					CFrame = CFrame.new(-0, 4.015, -3.49) * CFrame.Angles(-1.8949284034997715, 0, 0)
				}
			):Play()
			task.wait(lifetime2 * 0.3)
			TweenService:Create(
				bone002,
				TweenInfo.new(lifetime2 * 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
				{
					CFrame = CFrame.new(0, 3.436, 0) * CFrame.Angles(0.532150888933071, 0, 0)
				}
			):Play()
			TweenService:Create(
				bone004,
				TweenInfo.new(lifetime2 * 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
				{
					CFrame = CFrame.new(0, 3.435, 0) * CFrame.Angles(0.04771730174952497, 0, 0)
				}
			):Play()
		end)
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			local v4 = (os.clock() - lastTime4) / lifetime
			local v5 = 1

			if v4 < 0.25 then
				v5 = v4 / 0.25
			elseif v4 > 0.9 then
				v5 = 1 - (v4 - 0.9) / 0.1

				if clone3:FindFirstChild("Trail") then
					local trail = clone3.Trail
					trail.Parent = parent
					task.delay(3, function()
						trail:Destroy()
					end)
				end
			end

			if v5 ~= scale then
				clone3:ScaleTo((math.max(0.001, scale * v5)))
			end

			raycastResult = workspace:Raycast(orb.Position, orb.CFrame.LookVector * dt * projectileSpeed, raycastParams)

			if lifetime <= os.clock() - lastTime4 then
				ParticleState(orb, false)
				heartbeatConnection:Disconnect()
			else
				raycastResult4 = workspace:Raycast(
					(orb.CFrame * CFrame.new(0, 0, 4)).Position,
					createVector(0, -20, 0),
					raycastParams
				)
				raycastResult5 = workspace:Raycast(
					(orb.CFrame * CFrame.new(0, 0, 4.1)).Position,
					createVector(0, -20, 0),
					raycastParams
				)

				if raycastResult4 and raycastResult5 then
					clone2.CFrame = CFrame.lookAt(raycastResult4.Position, raycastResult5.Position) * CFrame.new(
						0,
						0.1,
						0
					)

					if v2 == false and not v3 then
						v2 = true
						ParticleState(clone2, true)
					end
				elseif v2 == true and not v3 then
					ParticleState(clone2, false)
					v2 = false
				end

				orb.CFrame *= CFrame.new(0, 0, -dt * projectileSpeed)

				if os.clock() - lastTime2 >= 0.023 then
					lastTime2 = os.clock()
					raycastResult3 = workspace:Raycast(orb.Position, createVector(0, -20, 0), raycastParams)

					if raycastResult3 and raycastResult2 then
						local position = raycastResult2.Position
						local position2 = raycastResult3.Position
						local magnitude = (position - position2).Magnitude
						local clone4 = X.FloorFire:Clone()
						clone4.CFrame = CFrame.lookAt(position, position2) * CFrame.new(0, 0.1, -magnitude / 2)
						clone4.Size = Vector3.new(20, 1, magnitude)
						clone4.Parent = parent
						count += 1
						task.delay(0.1, function()
							ParticleState(clone4, false)
						end)
						raycastResult2 = raycastResult3
					end
				end

				if os.clock() - lastTime3 >= 0.017 then
					lastTime3 = os.clock()

					for _ = 1, math.random(1, 2) do
						local clone4 = X["MiniCrackle" .. random:NextInteger(1, 2)]:Clone()
						clone4.CFrame = orb.CFrame * CFrame.new(
							random:NextNumber(-10, 10),
							random:NextNumber(1, 8),
							random:NextNumber(-10, 10)
						)
						clone4.Parent = parent
						local bodyForce = Instance.new("BodyForce")
						bodyForce.Force = Vector3.new(0, clone4:GetMass() * workspace.Gravity * 0.9, 0)
						bodyForce.Parent = clone4
						clone4.Velocity = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).Unit * math.random(
							8,
							16
						)
						task.delay(random:NextNumber(0.75, 1.35), function()
							ParticleState(clone4, false)
							task.wait(1)
							bodyForce:Destroy()
						end)
					end
				end

				if os.clock() - lastTime >= 0.02 then
					lastTime = os.clock()
					local clone4 = X.Star:Clone()
					local number = random:NextNumber(0, 360)
					local number2 = random:NextNumber(180, 360)
					local v7 = random:NextNumber(2, 7) * 4
					local total = 0
					local v8 = -random:NextNumber(75, 100) * 1.5
					local v9 = orb.CFrame * CFrame.new(
						random:NextNumber(-10, 10),
						random:NextNumber(-1, 6),
						random:NextNumber(-10, 10)
					)
					clone4.CFrame = v9 * CFrame.new(
						math.sin((math.rad(number))) * v7,
						math.cos((math.rad(number))) * v7,
						total
					)
					clone4.Parent = parent
					local heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt2)
						total += v8 * dt2
						number += number2 * dt2
						clone4.CFrame = v9 * CFrame.new(
							math.sin((math.rad(number))) * v7,
							math.cos((math.rad(number))) * v7,
							total
						)
					end)
					task.wait(random:NextNumber(0.7, 1.4) * 0.75)
					heartbeatConnection2:Disconnect()
					ParticleState(clone4, false)
				end
			end
		end)
		task.wait(lifetime - 0.1)
		v3 = true
		ParticleState(clone2, false)
	elseif stage == 3 then
		local playerKey = player.PlayerKey or player.Player and player.Player.UserId or not player.Character and "unknown" or player.Character.Name or "unknown"
		local parent = _WorldOrigin:FindFirstChild("DragonGatlingX_" .. tostring(playerKey) .. "_" .. player.Iteration)
		local subProjectiles = player.SubProjectiles
		local orb

		if parent then
			parent.Name = "DragonGatlingX_" .. tostring(playerKey) .. "_" .. player.Iteration

			if not parent:FindFirstChild("OrbModel") then
				local clone_3 = X.OrbModel:Clone()
				clone_3.Parent = parent
				local _ = (nil).Orb
			end

			orb = parent.OrbModel.Orb
			orb.Position = player.TargetPos
		else
			parent = Instance.new("Folder")
			parent.Name = "DragonGatlingX_" .. tostring(playerKey) .. "_" .. player.Iteration
			parent.Parent = _WorldOrigin
			local clone = X.OrbModel:Clone()
			orb = clone.Orb
			orb.Position = player.TargetPos
			clone.Parent = parent
		end

		local cFrame = CFrame.new(player.TargetPos) * (orb.CFrame - orb.Position)

		if player.Norm then
			cFrame = Util.Misc.AlignCFrame(
				CFrame.lookAt(createVector(0, 0, 0), orb.CFrame.LookVector) + player.TargetPos,
				player.Norm
			)
		end

		local clone = X.Preasure:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 15, 0)
		clone.Parent = parent
		local clone2 = X.PreSplitEnable:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = parent
		task.wait(0.1)
		local clone3 = X.PreSplit:Clone()
		clone3.Position = player.TargetPos
		clone3.Parent = parent
		ParticleState(clone3)
		sound:Play("DragonStorm_X_Explosion_01", player.TargetPos)
		task.wait(0.05)

		for _ = 1, 3 do
			task.spawn(function()
				local number = random:NextNumber(10, 80)
				local clone4 = X.Beam:Clone()
				clone4:ScaleTo(1 + number / 15)
				local beams = clone4.Beams
				beams.CFrame = cFrame * CFrame.new(0, 0, -number) * CFrame.Angles(
					0,
					0,
					random:NextNumber(0, 6.283185307179586)
				)
				beams.Parent = parent
				local number2 = random:NextNumber(0.2, 0.4)
				TweenService:Create(beams, TweenInfo.new(number2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Orientation = beams.Orientation + Vector3.new(0, 0, random:NextNumber(360, 720))
				}):Play()
				TweenService:Create(
					beams.Beam,
					TweenInfo.new(number2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				):Play()
			end)
		end

		local clone4 = X.StarEmit:Clone()
		clone4.CFrame = clone3.CFrame
		clone4.Parent = parent
		ParticleState(clone4)
		task.wait(0.1)
		ParticleState(clone2, false)
		local clone5 = X.Split:Clone()
		clone5.CFrame = cFrame
		clone5.Parent = parent
		ParticleState(clone, false)
		ParticleState(clone5)

		if (workspace.CurrentCamera.CFrame.p - cFrame.Position).Magnitude < 160 then
			task.spawn(function()
				Util.CameraShaker:ShakeOnce(40, 40, 0.05, 1.2)
				local clone6 = X.Blur:Clone()
				clone6.Parent = Lighting
				local clone7 = X.ColorCorrection:Clone()
				clone7.Parent = Lighting
				TweenService:Create(clone7, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				}):Play()
				TweenService:Create(clone6, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = 0
				}):Play()
				TweenService:Create(
					currentCamera,
					TweenInfo.new(0.05, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
					{
						FieldOfView = 80
					}
				):Play()
				task.wait(0.05)
				TweenService:Create(
					currentCamera,
					TweenInfo.new(0.05, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
				task.wait(0.1)
				TweenService:Create(clone7, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TintColor = Color3.new(0.835294, 0.835294, 0.835294)
				}):Play()
				task.wait(0.15)
				clone6:Destroy()
				TweenService:Create(clone7, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TintColor = Color3.new(1, 1, 1)
				}):Play()
				task.wait(0.1)
				clone7:Destroy()
			end)
		end

		if player.FloorFlameTriangleRay then
			local clone6 = X.FloorFlameTriangle:Clone()
			clone6.CFrame = CFrame.lookAt(player.FloorFlameTriangleRay[1], player.FloorFlameTriangleRay[2]) * CFrame.new(
				0,
				0,
				clone6.Size.Z / 2
			)
			clone6.Parent = parent
			task.delay(4, function()
				ParticleState(clone6, false)
			end)
		end

		task.spawn(function()
			for i = 1, subProjectiles do
				local v3 = player.SubData[i]
				local projectileSpeed = v3.ProjectileSpeed
				local clone6 = X.SmallOrb:Clone()
				clone6.CFrame = v3.SmallOrbCFrame
				clone6.Parent = parent
				local smallProjectileLifetime = v3.SmallProjectileLifetime
				local heartbeatConnection = nil
				local v4 = os.clock()
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					if not (smallProjectileLifetime <= os.clock() - v4) then
						clone6.CFrame *= CFrame.new(0, 0, -dt * projectileSpeed)
						return
					end

					heartbeatConnection:Disconnect()
					ParticleState(clone6, false)
					local clone7 = X["Explosion" .. random:NextInteger(1, 3)]:Clone()
					clone7.CFrame = clone6.CFrame
					clone7.Parent = parent

					for i2 = 1, 3 do
						local clone8 = X["Crackle" .. random:NextInteger(1, 2)]:Clone()
						clone8.CFrame = clone6.CFrame * CFrame.Angles(
							math.rad((random:NextNumber(0, 180))),
							math.rad((random:NextNumber(-90, 90))),
							0
						)
						clone8.Parent = parent
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.Velocity = clone8.CFrame.LookVector * random:NextNumber(150, 250)
						bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
						bodyVelocity.Parent = clone8
						local number = random:NextNumber(0.1, 0.3)
						TweenService:Create(
							bodyVelocity,
							TweenInfo.new(number, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
							{
								Velocity = bodyVelocity.Velocity * 0.5
							}
						):Play()
						task.delay(number, function()
							bodyVelocity:Destroy()
							task.wait(random:NextNumber(0.3, 0.6))
							ParticleState(clone8, false)
						end)
					end

					for i2 = 1, 5 do
						local clone8 = X.StarDust:Clone()
						clone8.CFrame = clone7.CFrame * CFrame.new(
							random:NextNumber(-10, 10),
							random:NextNumber(23, 37),
							random:NextNumber(-10, 10)
						)
						clone8.Parent = parent
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.Velocity = Vector3.new(
							random:NextNumber(-1, 1),
							random:NextNumber(0, 1),
							random:NextNumber(-1, 1)
						).Unit * random:NextNumber(30, 70)
						TweenService:Create(
							bodyVelocity,
							TweenInfo.new(random:NextNumber(0.2, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Velocity = Vector3.new(0, -random:NextNumber(3, 8), 0)
							}
						):Play()
						bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
						bodyVelocity.Parent = clone8
						task.delay(random:NextNumber(0.2, 1), function()
							ParticleState(clone8, false)
							task.wait(1)
							bodyVelocity:Destroy()
						end)
					end

					ParticleState(clone7)
				end)
			end

			task.wait(random:NextNumber(0.02, 0.05))
		end)
		local clone6 = X.PostSplitEnable:Clone()
		clone6.CFrame = cFrame * CFrame.new(0, 0, -clone6.Size.Z / 2)
		clone6.Parent = parent
		task.wait(0.2)

		for i = 1, 3 do
			local clone7 = X.FireTrailPart:Clone()
			local v3 = (i - 1) * 120
			local total = 10
			local total2 = 0
			local v4 = cFrame
			clone7.CFrame = v4 * CFrame.new(math.sin((math.rad(v3))) * total, math.cos((math.rad(v3))) * total, total2)
			clone7.Parent = parent
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total2 += -600 * dt
				v3 += 1440 * dt
				total += 200 * dt
				clone7.CFrame = v4 * CFrame.new(
					math.sin((math.rad(v3))) * total,
					math.cos((math.rad(v3))) * total,
					total2
				)
			end)
			local v7 = clone7
			task.delay(0.3, function()
				ParticleState(v7, false)
				task.wait(0.3)
				heartbeatConnection:Disconnect()
			end)
		end

		task.wait(0.2)
		ParticleState(clone6, false)
		task.wait(10)

		if parent then
			parent:Destroy()
		end
	elseif stage == 4 then
		local root = player.Root
		local proxy = player.Proxy
		local clone = X.Burn:Clone()
		clone.CFrame = root.CFrame
		clone.Parent = _WorldOrigin

		while proxy:IsDescendantOf(workspace) and root do
			clone.CFrame = root.CFrame
			task.wait()
		end

		ParticleState(clone, false)
		task.wait(2)
		clone:Destroy()
	end
end