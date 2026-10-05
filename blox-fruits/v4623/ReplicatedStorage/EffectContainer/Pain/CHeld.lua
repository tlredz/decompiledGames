local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local _ = Util.Debris
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Pain").CHeld.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
local v = {
	"rbxassetid://134347232979664",
	"rbxassetid://114088858846398",
	"rbxassetid://97955422280786",
	"rbxassetid://75661586924959",
	"rbxassetid://111237144265294"
}
local v2 = {
	"rbxassetid://128425773830588",
	"rbxassetid://70841623014498",
	"rbxassetid://71676079418095",
	"rbxassetid://116790910781018",
	"rbxassetid://106484059362775"
}

local function areShiftedColorsEqual(instance, childName: string, color: Color3, color2: Color3, color3: Color3)
	local child = instance:FindFirstChild(childName)

	if child == nil then
		return false
	end

	local shifted = child:FindFirstChild("Shifted")

	if shifted == nil then
		return false
	end

	local shifted_Color1 = shifted:GetAttribute("Shifted_Color1")
	local shifted_Color2 = shifted:GetAttribute("Shifted_Color2")
	local shifted_Color3 = shifted:GetAttribute("Shifted_Color3")

	if shifted_Color1 == nil or shifted_Color2 == nil or shifted_Color3 == nil then
		return false
	end

	return color == shifted_Color1 and color2 == shifted_Color2 and color3 == shifted_Color3
end

local function applyColorShiftHSV(color: Color3, p: number, p2: number, p3: number)
	local v3 = math.max(1, color.R, color.G, color.B)
	local v4 = math.floor(color.R / v3 * 255) % 256
	local v5 = math.floor(color.G / v3 * 255) % 256
	local v6 = math.floor(color.B / v3 * 255) % 256
	local HSV, v7, v8 = Color3.fromRGB(v4, v5, v6):ToHSV()
	local v9 = (HSV + p) % 1
	local v10 = math.clamp(v7 * p2, 0, 1)
	local v11 = math.clamp(v8 * p3, 0, 1)
	return Color3.fromHSV(v9, v10, v11 * v3)
end

local function getColorHSVDistance(color: Color3, color2: Color3)
	local v3 = math.max(1, color.R, color.G, color.B)
	local v4 = math.floor(color.R / v3 * 255) % 256
	local v5 = math.floor(color.G / v3 * 255) % 256
	local v6 = math.floor(color.B / v3 * 255) % 256
	local color3 = Color3.fromRGB(v4, v5, v6)
	local v7 = math.max(1, color2.R, color2.G, color2.B)
	local v8 = math.floor(color2.R / v7 * 255) % 256
	local v9 = math.floor(color2.G / v7 * 255) % 256
	local v10 = math.floor(color2.B / v7 * 255) % 256
	local color4 = Color3.fromRGB(v8, v9, v10)
	local HSV, _, _ = color3:ToHSV()
	local HSV2, _, _ = color4:ToHSV()
	local v11 = math.abs(HSV2 - HSV)
	return (math.min(v11, 1 - v11))
end

local function applyColorShiftHSV2(color: Color3, p: number, p2: number, p3: number)
	if getColorHSVDistance(color, Color3.new(1, 1, 0)) > 0.1111111111111111 then
		return color
	end

	local v3 = math.max(1, color.R, color.G, color.B)
	local v4 = math.floor(color.R / v3 * 255) % 256
	local v5 = math.floor(color.G / v3 * 255) % 256
	local v6 = math.floor(color.B / v3 * 255) % 256
	local HSV, v7, v8 = Color3.fromRGB(v4, v5, v6):ToHSV()
	local v9 = (HSV + p) % 1
	local v10 = math.clamp(v7 * p2, 0, 1)
	local v11 = math.clamp(v8 * p3, 0, 1)
	return Color3.fromHSV(v9, v10, v11 * v3)
end

local function applyColorShiftHSV3(_: Color3, _: number, _: number, _: number)
	return Color3.new(1, 1, 0)
end

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if enabled == nil then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			emitter.Enabled = enabled
		end

		if not (emitter.Lifetime.Max <= max) then
			max = emitter.Lifetime.Max
		end
	end

	return max
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local random = Random.new()

local function fn(p, p2, player, p3, p4)
	Util.SetParentOverrideWithColor(p, p2, player, p3, p4)

	if areShiftedColorsEqual(
		player,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(p, function(_, p5)
			return applyColorShiftHSV2(p5, 0.41666667, 1.165137614678899, 1) or p5
		end)
	end
end

return function(player)
	local player2 = player.Player
	local origin = player.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1300 then
		return
	end

	local stage = player.Stage

	if stage == 1 then
		local holding = player.Holding

		if not (holding and holding:IsDescendantOf(workspace) and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		fn(folder, _WorldOrigin, player2, "PainFruitVFXColor")
		folder.Name = "PainCBeam_" .. player.Player.Name
		local root = player.Root
		local head = root.Parent:FindFirstChild("Head")
		local cFrame = head and head.CFrame or root.CFrame
		os.clock()
		local clone = assets.CRevamp.StartBeamModel:Clone()
		local startingBeam = clone.StartingBeam
		startingBeam.CFrame = cFrame
		fn(clone, folder, player2, "PainFruitVFXColor")
		local clone2 = assets.CRevamp.ChargeAura:Clone()
		clone2.Anchored = false
		clone2.Weld.Part0 = root
		fn(clone2, folder, player2, "PainFruitVFXColor")
		local v3 = Util.Sound:Play("C_Held_ElectricalCharge_01", root)
		local startingMode = player.StartingMode or "Low"
		local v4 = false
		local flag = false
		Util.Sound:Play("C_HeldBeam_Activation_03_V1", root.Position)
		local childAddedConnection = nil
		childAddedConnection = root.ChildAdded:Connect(function(child)
			if child.Name == "PainCBeam" then
				local mode = child:GetAttribute("Mode")

				if startingMode == "Low" then
					if mode == "Mid" then
						Util.Sound:Play("C_HeldBeam_Activation_02_V1", root.Position)

						if v3 then
							Util.Sound:FadeOut(v3, 0.2)
						end

						v3 = Util.Sound:Play("C_Held_ElectricalCharge_02", root)
						v4 = true
					end
				elseif startingMode == "Mid" and mode == "High" then
					Util.Sound:Play("C_HeldBeam_Activation_01_V1", root.Position)

					if v3 then
						Util.Sound:FadeOut(v3, 0.2)
					end

					v3 = Util.Sound:Play("C_Held_ElectricalCharge_03", root)
					flag = true
					childAddedConnection:Disconnect()
				end
			end
		end)
		local lastTime = os.clock()
		os.clock()
		local heartbeatConnection = nil

		while holding and holding.Value == true do
			task.wait()
			local cFrame2 = head and head.CFrame or root.CFrame

			if flag then
				if startingMode == "Mid" then
					startingMode = "High"
					heartbeatConnection:Disconnect()
					local v5 = cFrame2
					heartbeatConnection = RunService.Heartbeat:Connect(function()
						if os.clock() - lastTime < 0.03 then
							return
						end

						lastTime = os.clock()
						local clone3 = assets.CRevamp.Electricity:Clone()
						random:NextNumber(0, 360)
						random:NextNumber(360, 720)
						local position2 = v5.Position + Vector3.new(
							random:NextNumber(-50, 50),
							random:NextNumber(0, 50),
							random:NextNumber(-50, 50)
						)
						local v7 = v5.Position + Vector3.new(
							random:NextNumber(-50, 50),
							random:NextNumber(0, 50),
							random:NextNumber(-50, 50)
						)
						local v8 = v5.Position + Vector3.new(
							random:NextNumber(-50, 50),
							random:NextNumber(0, 50),
							random:NextNumber(-50, 50)
						)
						local position = v5.Position
						clone3.Trail.Lifetime = random:NextNumber(0.05, 0.1)
						clone3.Position = position2
						fn(clone3, folder, player2, "PainFruitVFXColor")

						for i = 0, 1, RunService.Heartbeat:Wait() / random:NextNumber(0.08, 0.15) do
							local v9 = position2 + (v7 - position2) * i
							local v10 = v7 + (v8 - v7) * i
							local v11 = v8 + (position - v8) * i
							local v12 = v9 + (v10 - v9) * i
							clone3.Position = v12 + (v10 + (v11 - v10) * i - v12) * i
							RunService.Heartbeat:Wait()
						end

						task.wait(2)
						clone3:Destroy()
					end)
					local clone3 = assets.CRevamp.PowerUp:Clone()
					clone3.CFrame = root.CFrame
					fn(clone3, folder, player2, "PainFruitVFXColor")
					task.delay(ParticleState(clone3), clone3.Destroy, clone3)
					clone:ScaleTo(2.25)
					ParticleState(clone2, true)
				end
			elseif v4 and startingMode == "Low" then
				startingMode = "Mid"
				local v5 = cFrame2
				heartbeatConnection = RunService.Heartbeat:Connect(function()
					if os.clock() - lastTime < 0.03 then
						return
					end

					lastTime = os.clock()
					local clone3 = assets.CRevamp.WindupTrail:Clone()
					random:NextNumber(0, 360)
					random:NextNumber(360, 720)
					local position2 = v5.Position + Vector3.new(
						random:NextNumber(-10, 10),
						random:NextNumber(-10, 10),
						random:NextNumber(-10, 10)
					)
					local v7 = v5.Position + Vector3.new(
						random:NextNumber(-10, 10),
						random:NextNumber(-10, 10),
						random:NextNumber(-10, 10)
					)
					local v8 = v5.Position + Vector3.new(
						random:NextNumber(-10, 10),
						random:NextNumber(-10, 10),
						random:NextNumber(-10, 10)
					)
					local position = v5.Position
					clone3.Position = position2
					fn(clone3, folder, player2, "PainFruitVFXColor")

					for i = 0, 1, RunService.Heartbeat:Wait() / random:NextNumber(0.1, 0.2) do
						local v9 = position2 + (v7 - position2) * i
						local v10 = v7 + (v8 - v7) * i
						local v11 = v8 + (position - v8) * i
						local v12 = v9 + (v10 - v9) * i
						clone3.Position = v12 + (v10 + (v11 - v10) * i - v12) * i
						RunService.Heartbeat:Wait()
					end

					task.wait(2)
					clone3:Destroy()
				end)
				ParticleState(clone2.Attachment, true)
				local clone3 = assets.CRevamp.PowerUp:Clone()
				clone3.CFrame = root.CFrame
				fn(clone3, folder, player2, "PainFruitVFXColor")
				clone:ScaleTo(1.5)
				task.delay(ParticleState(clone3), clone3.Destroy, clone3)
			end
		end

		if v3 then
			Util.Sound:FadeOut(v3, 0.2)
		end

		if childAddedConnection then
			childAddedConnection:Disconnect()
		end

		task.delay(ParticleState(startingBeam, false), clone.Destroy, clone)
		task.delay(ParticleState(clone2, false), clone2.Destroy, clone2)

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		Util.Debris:AddItem(folder, 10)
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		fn(folder, workspace._WorldOrigin, player2, "PainFruitVFXColor")
		Util.Debris:AddItem(folder, 10)
		local clone = assets.CRevamp.BeamModel:Clone()
		local beamDistance = player.BeamDistance
		local _ = player.Character
		local magnitude = 0
		local mode = player.Mode
		local startCFrame = player.StartCFrame
		local v3 = mode == "High" and 2 or mode == "Mid" and 1.5 or 1
		task.delay(0.1, function()
			workspace:Raycast(startCFrame.Position, startCFrame.LookVector * beamDistance, raycastParams)
			local clone2 = assets.CRevamp.ElectricBeam:Clone()
			clone2.CFrame = startCFrame
			clone2.Part.CFrame = startCFrame
			fn(clone2, folder, player2, "PainFruitVFXColor")
			clone2.Part.CFrame = startCFrame * CFrame.new(0, 0, -beamDistance * 3)
			local clone3 = assets.CRevamp.PreChargeAura:Clone()
			clone3.CFrame = startCFrame * CFrame.new(0, 0, -beamDistance / 2)
			clone3.Size = Vector3.new(30 * v3, 30 * v3, beamDistance)
			fn(clone3, folder, player2, "PainFruitVFXColor")
			task.wait(beamDistance / 1500 * 0.7)
			TweenService:Create(
				clone2.Beam,
				TweenInfo.new(beamDistance / 1500, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Width0 = 0,
					Width1 = 0
				}
			):Play()
			TweenService:Create(
				clone2.Beam1,
				TweenInfo.new(beamDistance / 1500, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				{
					Width0 = 0,
					Width1 = 0
				}
			):Play()
			task.wait(beamDistance / 1500)
			task.delay(ParticleState(clone3, false), clone3.Destroy, clone3)
			task.wait(1)
			clone2:Destroy()
		end)
		local clone2 = assets.CRevamp.Bubble:Clone()
		clone2.CFrame = startCFrame
		fn(clone2, folder, player2, "PainFruitVFXColor")
		task.wait(0.2)
		task.delay(ParticleState(clone2), clone2.Destroy, clone2)
		local v4 = mode == "Mid" and 2 or 3
		Util.Sound:Play("C_HeldBeam_Fire_V2_0" .. tostring(v4), startCFrame.Position)
		local v5 = mode == "Mid" and 0.75 or mode == "Low" and 0.5 or 1
		local clone3 = assets.CRevamp.PreExplosion:Clone()
		Util.ResizeModel(clone3, v5 * 2)
		clone3.CFrame = startCFrame
		fn(clone3, folder, player2, "PainFruitVFXColor")
		local clone4 = assets.BigGhost:Clone()
		clone4:ScaleTo(v5 * 2)
		local v6 = startCFrame * CFrame.new(0, v5 * -6, 7.5)
		clone4:PivotTo(v6)
		Util.SetParentOverrideWithColor(clone4, folder, player2, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone4, function(_, p)
				return Color3.new(1, 1, 0) or p
			end)
		end

		task.spawn(function()
			local plane002 = clone4:WaitForChild("Plane.002")
			local color = Color3.fromRGB(113, 15, 36)
			local color3Constructor = Util.WrapColor3Constructor(color, player2, "PainFruitVFXColor")
			local color2 = Color3.fromRGB(241, 76, 81)
			local color3Constructor2 = Util.WrapColor3Constructor(color2, player2, "PainFruitVFXColor")
			local v9 = time()
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				if not clone4:IsDescendantOf(workspace) then
					heartbeatConnection:Disconnect()
					return
				end

				local v10 = time() - v9
				plane002.Color = color3Constructor:Lerp(color3Constructor2, math.cos(v10 * 3.141592653589793 * 8) ^ 2)
				clone4:PivotTo(v6 * CFrame.new(random:NextUnitVector() * v5))
			end)
		end)
		Util.Anims:Get(clone4, "PainBigGhostRoar"):Play(0, nil, 1.48)
		task.delay(ParticleState(clone3), clone3.Destroy, clone3)
		task.wait(0.05)
		local clone5 = assets.CRevamp.LaunchModel:Clone()
		clone5:ScaleTo(v5 * 2)
		local launch = clone5.Launch
		launch.CFrame = startCFrame
		fn(launch, folder, player2, "PainFruitVFXColor")
		task.delay(ParticleState(launch), launch.Destroy, launch)
		local player3 = player.Player
		local Players = game:GetService("Players")

		if player3 == Players.LocalPlayer then
			TweenService:Create(currentCamera, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				FieldOfView = 60
			}):Play()
			task.delay(0.04, function()
				TweenService:Create(
					currentCamera,
					TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 80
					}
				):Play()
				task.wait(0.07)
				TweenService:Create(
					currentCamera,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end)
		end

		if mode == "High" then
			local clone6 = assets.CRevamp.ColorCorrection:Clone()
			fn(clone6, Lighting, player2, "PainFruitVFXColor")
			task.wait(0.03)
			clone6:Destroy()
			local clone7 = assets.CRevamp.ColorCorrection2:Clone()
			fn(clone7, Lighting, player2, "PainFruitVFXColor")
			task.wait(0.03)
			clone7:Destroy()
			clone:ScaleTo(3)
		else
			if mode == "Mid" then
				clone:ScaleTo(2)
			end

			task.wait(0.06)
		end

		local clone6 = assets.CRevamp.Start:Clone()
		Util.ResizeModel(clone6, v5 * 2)
		clone6.CFrame = startCFrame * CFrame.new(0, 0, (v5 - 0.5) * -14)
		fn(clone6, folder, player2, "PainFruitVFXColor")
		local beamPart = clone.BeamPart
		beamPart.CFrame = startCFrame
		local beamPart2 = beamPart.BeamPart2
		beamPart2.CFrame = startCFrame
		local clone7 = assets.Phase1.Back:Clone()
		Util.ResizeModel(clone7, v5 * 2)
		clone7.CFrame = startCFrame * CFrame.new(0, 3, 7) * CFrame.new(0, 0, 13)
		fn(clone7, folder, player2, "PainFruitVFXColor")
		fn(clone, folder, player2, "PainFruitVFXColor")
		local v7 = Util.Sound:Play("C_HeldBeam_BeamFiringLoop_V2_03", startCFrame.Position)
		ParticleState(clone7, true)
		local clone8 = assets.CRevamp.BeamAura:Clone()

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			task.spawn(function()
				clone8:WaitForChild("BeamAuraMid"):WaitForChild("DarkShard"):Destroy()
			end)
		end

		clone8.CFrame = startCFrame * CFrame.new(0, 0, -magnitude / 2)
		clone8.Size = Vector3.new(clone8.Size.X * v3, clone8.Size.Y * v3, magnitude)
		clone8.BeamAuraMid.Size = Vector3.new(
			clone8.Size.X * (beamDistance / 160),
			clone8.Size.Y * (beamDistance / 160),
			magnitude
		)
		fn(clone8, folder, player2, "PainFruitVFXColor")

		if mode ~= "Low" then
			ParticleState(clone8.BeamAuraMid, true)
		end

		local lastTime = os.clock()
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			if os.clock() - lastTime < 0.05 then
				return
			end

			lastTime = os.clock()
			local clone9 = assets.CRevamp.Trail:Clone()
			local number = random:NextNumber(0, 360)
			local number2 = random:NextNumber(360, 620)
			local v8 = random:NextNumber(13, 26) * (beamDistance / 160)
			local number3 = random:NextNumber(0, magnitude)
			local number4 = random:NextNumber(magnitude / 2, magnitude)
			clone9.CFrame = startCFrame * CFrame.new(
				math.sin((math.rad(number))) * v8,
				math.cos((math.rad(number))) * v8,
				-number3
			)
			fn(clone9, folder, player2, "PainFruitVFXColor")
			local heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
				number += number2 * dt
				number3 += number4 * dt
				clone9.CFrame = startCFrame * CFrame.new(
					math.sin((math.rad(number))) * v8,
					math.cos((math.rad(number))) * v8,
					-number3
				)
			end)
			task.wait(random:NextNumber(0.2, 0.65))
			heartbeatConnection2:Disconnect()
			task.wait(1)
			clone9:Destroy()
		end)
		local lastTime2 = os.clock()
		local v8 = 1
		local heartbeatConnection2 = RunService.Heartbeat:Connect(function()
			if os.clock() - lastTime2 < 0.05 then
				return
			end

			lastTime2 = os.clock()
			local v9 = random:NextNumber(20, 30) * (mode == "Mid" and 1.5 or mode == "High" and 2 or 1) * v8 * 0.75
			local clone9 = assets.CRevamp.Mesh:Clone()
			clone9.CFrame = startCFrame * CFrame.Angles(-1.5707963267948966, random:NextNumber(0, 6.283185307179586), 0)
			clone9.Mesh.Scale = Vector3.new(v9, -30, v9)
			clone9.Mesh.Offset = createVector(0, 60, 0)
			fn(clone9, folder, player2, "PainFruitVFXColor")
			TweenService:Create(
				clone9.Mesh,
				TweenInfo.new(#v2 * RunService.Heartbeat:Wait(), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Offset = createVector(0, 120, 0),
					Scale = Vector3.new(v9, -60, v9)
				}
			):Play()

			for _, texture in v2 do
				clone9.Decal.Texture = texture
				task.wait()
			end

			clone9:Destroy()
		end)
		local lastTime3 = os.clock()
		local heartbeatConnection3 = RunService.Heartbeat:Connect(function()
			if os.clock() - lastTime3 < 0.03 then
				return
			end

			lastTime3 = os.clock()
			local v9 = random:NextNumber(15, 20) * (mode == "Mid" and 1.5 or mode == "High" and 2 or 1) * v8 * 0.65
			local clone9 = assets.CRevamp.Circular:Clone()
			clone9.CFrame = startCFrame * CFrame.Angles(1.5707963267948966, random:NextNumber(0, 6.283185307179586), 0)
			clone9.Mesh.Scale = Vector3.new(v9, -30, v9)
			clone9.Mesh.Offset = createVector(0, -60, 0)
			fn(clone9, folder, player2, "PainFruitVFXColor")
			TweenService:Create(
				clone9.Mesh,
				TweenInfo.new(#v * RunService.Heartbeat:Wait(), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Offset = createVector(0, -120, 0),
					Scale = Vector3.new(v9, -60, v9)
				}
			):Play()

			for _, texture in v do
				clone9.Decal.Texture = texture
				task.wait()
			end

			clone9:Destroy()
		end)
		local v9 = true
		local raycastResult = nil
		local magnitude2 = nil
		local v10 = nil
		local heartbeatConnection4 = nil
		heartbeatConnection4 = RunService.Heartbeat:Connect(function(dt)
			local cFrame = beamPart2.CFrame * CFrame.new(0, 0, -1500 * (beamDistance / 160) * dt)
			raycastResult = workspace:Raycast(beamPart2.Position, cFrame.Position - beamPart2.Position, raycastParams)

			if not raycastResult and not (beamDistance <= (startCFrame.Position - beamPart2.Position).Magnitude) then
				beamPart2.CFrame = cFrame
				magnitude = (cFrame.Position - startCFrame.Position).Magnitude
				clone8.CFrame = startCFrame * CFrame.new(0, 0, -magnitude / 2)
				clone8.Size = Vector3.new(clone8.Size.X, clone8.Size.Y, magnitude)
				clone8.BeamAuraMid.Size = Vector3.new(clone8.Size.X, clone8.Size.Y, magnitude)
				return
			end

			heartbeatConnection4:Disconnect()

			if raycastResult then
				beamPart2.Position = raycastResult.Position
				v10 = Util.Sound:Play("C_HeldBeam_DebrisDamage_GroundLoop_01", beamPart2.Position)

				if magnitude2 == nil then
					magnitude2 = (startCFrame.Position - beamPart2.Position).Magnitude
				end

				local position = raycastResult.Position
				task.spawn(function()
					repeat
						local clone9 = assets.CRevamp.ExplosionModel:Clone()
						clone9:PivotTo(CFrame.new(position))
						fn(clone9, folder, player2, "PainFruitVFXColor")

						if mode == "Mid" then
							clone9:ScaleTo(1.2)
						elseif mode == "High" then
							clone9:ScaleTo(1.4)
						end

						task.delay(ParticleState(clone9), clone9.Destroy, clone9)
						task.wait(random:NextNumber(0.1, 0.2))
					until v9 == false
				end)
				task.spawn(function()
					local random2 = Random.new()

					repeat
						local cframe = CFrame.new(position, position + startCFrame.LookVector)

						for _ = 1, math.random(1, 3) do
							local v12 = cframe
							task.spawn(function()
								local clone9 = assets.Phase2.GhostModel:Clone()
								clone9:ScaleTo(clone9:GetScale() + math.random(-1, 1))
								local v13 = v12
								local v14 = v12.Position + v13.RightVector * random2:NextNumber(-50, 50) + v13.UpVector * random2:NextNumber(
									-50,
									50
								)
								local v15 = v14 + Vector3.new(
									random2:NextNumber(-60, 60),
									random2:NextNumber(-40, 60),
									random2:NextNumber(-60, 60)
								)
								local v16 = v14 + Vector3.new(
									random2:NextNumber(-60, 60),
									random2:NextNumber(-60, 60),
									random2:NextNumber(-80, 60)
								)
								local v17 = v12.Position + Vector3.new(
									random2:NextNumber(-60, 60) / 10,
									random2:NextNumber(-50, 60) / 10,
									random2:NextNumber(-60, 60) / 10
								)
								clone9:SetPrimaryPartCFrame(CFrame.new(v14))
								Util.SetParentOverrideWithColor(clone9, folder, player2, "PainFruitVFXColor")
								local number = random2:NextNumber(0.25, 0.35)
								ParticleState(clone9)
								local v18 = v14

								for i = 0, 1, RunService.Heartbeat:Wait() / number do
									local v19 = v14 + (v15 - v14) * i
									local v20 = v15 + (v16 - v15) * i
									local v21 = v16 + (v17 - v16) * i
									local v22 = v19 + (v20 - v19) * i
									local v23 = v22 + (v20 + (v21 - v20) * i - v22) * i

									if v23 == v18 then
										continue
									end

									clone9:SetPrimaryPartCFrame(CFrame.lookAt(v23, v18) * CFrame.Angles(
										0,
										3.141592653589793,
										0
									))
									RunService.Heartbeat:Wait()
									v18 = v23
								end

								ParticleState(clone9, false)

								for i, part in pairs(clone9:GetChildren()) do
									if part:IsA("MeshPart") then
										part.Transparency = 1
									end
								end
							end)
						end

						task.wait(random2:NextNumber(0.03, 0.05) * 2)
					until v9 ~= true
				end)
			end

			local position = beamPart.Position
			local position2 = beamPart.BeamPart2.Position
			local v12 = 1 / (mode == "High" and 2 or mode == "Mid" and 1.5 or 1)
			local curveSize0 = clone.BeamPart.Beams.Beam.CurveSize0
			local width0 = clone.BeamPart.Beams.Beam.Width0
			local lastTime4 = os.clock()
			local v13 = -1

			while true do
				local number = random:NextNumber(0.03, 0.08)
				v8 = random:NextNumber(1 * (1 + v13 * 0.4 * v12), 1 * (1 + v13 * 0.2 * v12))
				v13 *= -1

				if mode ~= "Low" then
					local v14 = magnitude2 == nil and 1 or magnitude2 / beamDistance
					v8 *= math.clamp(v14, 0.65, 1)
				end

				for _, beam in clone.BeamPart.Beams:GetChildren() do
					if beam:IsA("Beam") then
						TweenService:Create(
							beam,
							TweenInfo.new(number, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CurveSize0 = curveSize0 * v8,
								CurveSize1 = -curveSize0 * v8,
								Width0 = width0 * v8,
								Width1 = width0 * v8
							}
						):Play()
					end
				end

				for i = 0, 1, RunService.Heartbeat:Wait() / number do
					local scale = clone:GetScale()
					clone:ScaleTo(scale + (v8 - scale) * i)
					beamPart.Position = position
					beamPart.BeamPart2.Position = position2
					task.wait()
				end

				task.wait()

				if not (os.clock() - lastTime4 >= 1.7) then
					continue
				end

				v9 = false

				if v7 then
					Util.Sound:FadeOut(v7, 0.2)
				end

				if v10 then
					Util.Sound:FadeOut(v10, 0.2)
				end

				task.delay(ParticleState(clone6, false), clone6.Destroy, clone6)
				task.delay(ParticleState(clone8, false), clone8.Destroy, clone8)
				ParticleState(clone7, false)
				ParticleState(clone4.DashAura, false)
				heartbeatConnection:Disconnect()
				heartbeatConnection2:Disconnect()
				heartbeatConnection3:Disconnect()
				local clone9 = assets.CRevamp.DisappearModel:Clone()
				clone9:ScaleTo(mode == "Mid" and 1.2 or mode == "High" and 1.5 or 1)
				local disappear = clone9.Disappear
				disappear.CFrame = startCFrame * CFrame.new(0, 0, -magnitude / 2)
				disappear.Size = Vector3.new(clone8.Size.X * v3, clone8.Size.Y * v3, magnitude)
				fn(clone9, folder, player2, "PainFruitVFXColor")
				task.delay(ParticleState(disappear), clone9.Destroy, clone9)

				for _, beam in clone:GetDescendants() do
					if beam:IsA("Beam") then
						TweenService:Create(beam, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Width0 = 0,
							Width1 = 0,
							CurveSize0 = 0,
							CurveSize1 = 0
						}):Play()
					end
				end

				local clone10 = assets.EndImpact:Clone()
				clone10.CFrame = clone4.PrimaryPart.CFrame * CFrame.new(0, 6, 0)
				Util.ResizeModel(clone10, v5 * 3)
				fn(clone10, folder, player2, "PainFruitVFXColor")
				clone4:Destroy()

				for _, emitter in pairs(clone10:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v14 = emitter
					task.spawn(function()
						if v14:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v14:GetAttribute("EmitDelay"))
						end

						v14:Emit(v14:GetAttribute("EmitCount"))
					end)
				end

				task.wait(0.2)
				clone:Destroy()
				break
			end
		end)
	end
end