local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Pain").Ghost.Assets
workspace:WaitForChild("_WorldOrigin")

local function areShiftedColorsEqual(player, childName: string, color: Color3, color2: Color3, color3: Color3)
	local child = player:FindFirstChild(childName)

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
	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local HSV, v5, v6 = Color3.fromRGB(v2, v3, v4):ToHSV()
	local v7 = (HSV + p) % 1
	local v8 = math.clamp(v5 * p2, 0, 1)
	local v9 = math.clamp(v6 * p3, 0, 1)
	return Color3.fromHSV(v7, v8, v9 * v)
end

Random.new()

local function GetNumberDependingDistance(p, p2, p3, p4, p5)
	if p <= p4 then
		return p2
	end

	if p4 < p and p <= p5 then
		return p2 + (p3 - p2) * ((p - p4) / (p5 - p4))
	end

	return p3
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
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

return function(data)
	local player = data.Player
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1500 then
		return
	end

	local stage = data.Stage
	local proxy = data.Proxy
	local player2 = data.Player

	if stage ~= 1 then
		return
	end

	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, workspace._WorldOrigin, player, "PainFruitVFXColor", true)
	Util.SyncColorsOnChange(folder, player, "PainFruitVFXColor", true)
	Util.Debris:AddItem(folder, 30)
	local clone = assets.Phase1.StartImpact:Clone()
	clone.CFrame = data.StartCFrame
	Util.SetParentOverrideWithColor(clone, folder, player, "PainFruitVFXColor", true)

	if areShiftedColorsEqual(
		player,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 146, 220),
		Color3.fromRGB(128, 183, 255),
		Color3.fromRGB(85, 170, 255)
	) then
		Util.AdjustObjectDescendantsColors(clone, function(_, p)
			if math.random() > 0.5 then
				p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
			end

			return p
		end)
	end

	Util.SyncColorsOnChange(clone, player, "PainFruitVFXColor", true)
	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

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

	task.wait(0.1)

	if not (proxy and proxy:IsDescendantOf(workspace)) then
		return
	end

	local position = data.StartCFrame.Position
	local id = data.Id
	math.random(1, 3)
	local v = id % 3 == 0 and 3 or id % 2 == 0 and 2 or 1
	local clone2 = assets.Ghosts:FindFirstChild("Ghost" .. tostring(v)):Clone()
	local flag

	if proxy:GetAttribute("Recolor") then
		flag = true
		local body = clone2:FindFirstChild("Body") or clone2:FindFirstChild("Body.001") or clone2:FindFirstChild("Body.002")

		if body then
			body.Color = Util.WrapColor3Constructor(Color3.fromRGB(91, 0, 0), player, "PainFruitVFXColor", true)
		end
	else
		flag = false
	end

	clone2:ScaleTo(0.5)
	clone2:PivotTo(CFrame.lookAt(position, workspace.CurrentCamera.CFrame.Position, createVector(0, 1, 0)))
	Util.SetParentOverrideWithColor(clone2, folder, player, "PainFruitVFXColor", true)

	if areShiftedColorsEqual(
		player,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 146, 220),
		Color3.fromRGB(128, 183, 255),
		Color3.fromRGB(85, 170, 255)
	) then
		Util.AdjustObjectDescendantsColors(clone2, function(_, p)
			if math.random() > 0.5 then
				p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
			end

			return p
		end)
	end

	local face2 = areShiftedColorsEqual(
		player,
		"PainFruitVFXColor",
		Color3.fromRGB(82, 55, 255),
		Color3.fromRGB(28, 14, 95),
		Color3.fromRGB(112, 117, 255)
	) and (clone2:FindFirstChild("face 2") or clone2:FindFirstChild("face") or clone2:FindFirstChild("mouth.002"))

	if face2 then
		face2.Color = Color3.fromRGB(96, 72, 102)
	end

	local face22 = areShiftedColorsEqual(
		player,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) and (clone2:FindFirstChild("face 2") or clone2:FindFirstChild("face") or clone2:FindFirstChild("mouth.002"))

	if face22 then
		face22.Color = Color3.fromRGB(0, 170, 255)
	end

	Util.SyncColorsOnChange(clone2, player, "PainFruitVFXColor", true)

	local function makeProxyPartAtBone(bot, _, cframe: CFrame?)
		local cFrame = cframe or CFrame.new()
		local part = Instance.new("Part")
		part.CastShadow = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		part.Anchored = false
		part.Locked = true
		part.Size = createVector(2, 0.2, 2)
		part.Name = "ProxyPart_" .. bot.Name
		local attachment = Instance.new("Attachment")
		attachment.CFrame = cFrame
		Util.SetParentOverrideWithColor(attachment, part, player, "PainFruitVFXColor", true)
		Util.SyncColorsOnChange(attachment, player, "PainFruitVFXColor", true)
		local rigidConstraint = Instance.new("RigidConstraint")
		rigidConstraint.Attachment0 = bot
		rigidConstraint.Attachment1 = attachment
		Util.SetParentOverrideWithColor(rigidConstraint, part, player, "PainFruitVFXColor", true)
		Util.SyncColorsOnChange(rigidConstraint, player, "PainFruitVFXColor", true)
		part.Transparency = 1
		Util.SetParentOverrideWithColor(part, clone2.RootPart, player, "PainFruitVFXColor", true)
		Util.SyncColorsOnChange(part, player, "PainFruitVFXColor", true)
		return part
	end

	local proxyPartAtBone = makeProxyPartAtBone(clone2.PrimaryPart.Bot)
	clone2.Aura.Weld.C0 = CFrame.new(0, 0, 0)
	clone2.Aura.Weld.C1 = CFrame.new(0, 0, 0)
	clone2.Aura.Weld.Part0 = proxyPartAtBone
	clone2.Aura.Weld.C0 = CFrame.new(0, 2.5, 0)
	local lastTime = tick()
	Util.Anims:Get(clone2, "PainGhostSpawn"):Play()

	while tick() - lastTime < 1 do
		clone2:ScaleTo(0.5 + 0.5 * ((tick() - lastTime) / 1))
		task.wait()
	end

	clone2:ScaleTo(1)
	task.wait()
	local v2 = Util.Anims:Get(clone2, clone2.Name == "Ghost3" and "PainGhost2" or "PainGhost")
	v2.Looped = true
	v2:Play()
	local v3 = Util.Sound:Play("F_GhostIdle_Loop_01_V1", clone2.PrimaryPart)
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local position2 = workspace.CurrentCamera.CFrame.Position
		local cframe = CFrame.lookAt(position, position2, createVector(0, 1, 0))
		clone2:PivotTo((clone2:GetPivot():Lerp(cframe, (math.clamp(dt * 5, 0, 1)))))
	end)
	local heartbeatConnection2 = nil

	if not flag then
		heartbeatConnection2 = RunService.Heartbeat:Connect(function(_)
			if flag then
				if heartbeatConnection2 then
					heartbeatConnection2:Disconnect()
				end
			elseif proxy and proxy:IsDescendantOf(workspace) then
				if clone2 and clone2:IsDescendantOf(workspace) then
					if proxy:GetAttribute("Recolor") then
						flag = true
						local body = clone2:FindFirstChild("Body") or clone2:FindFirstChild("Body.001") or clone2:FindFirstChild("Body.002")

						if body then
							body.Color = Util.WrapColor3Constructor(
								Color3.fromRGB(91, 0, 0),
								player,
								"PainFruitVFXColor",
								true
							)
						end
					end
				elseif heartbeatConnection2 then
					heartbeatConnection2:Disconnect()
				end
			elseif heartbeatConnection2 then
				heartbeatConnection2:Disconnect()
			end
		end)
	end

	repeat
		task.wait()
	until not proxy or not proxy:IsDescendantOf(workspace) or proxy:GetAttribute("Active") == false

	local flag2 = false

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	if proxy:GetAttribute("ToTarget") then
		local proxyRoot = proxy:FindFirstChild("ProxyRoot")

		if proxyRoot and proxyRoot.Value then
			local v4 = false

			if proxyRoot.Value then
				local _ = proxyRoot.Value.Parent
			end

			local value = proxyRoot.Value

			if value and clone2 then
				local speed = proxy:GetAttribute("Speed") or 350
				flag2 = true
				local v5 = math.random() * 6.283185307179586
				local v6 = math.random() * 6.283185307179586
				local heartbeatConnection3 = nil
				heartbeatConnection3 = RunService.Heartbeat:Connect(function(dt)
					if value and value.Parent and clone2 and clone2.Parent then
						if proxy and proxy:IsDescendantOf(workspace) then
							local pivot = clone2:GetPivot()
							local position2 = pivot.Position
							local v7 = value.Position - position2
							local magnitude = v7.Magnitude
							local lookVector = magnitude < 0.001 and pivot.LookVector or v7 / magnitude
							local unit = (math.abs((lookVector:Dot(createVector(0, 1, 0)))) > 0.98 and createVector(
								1,
								0,
								0
							) or createVector(0, 1, 0)):Cross(lookVector).Unit
							local unit2 = lookVector:Cross(unit).Unit
							v5 += 4.39822971502571 * dt
							v6 += 6.911503837897546 * dt
							local v8 = unit * (math.sin(v5) * 6)
							local v9 = unit2 * (math.cos(v6) * 2.5)
							local v10 = position2 + lookVector * math.min(speed * dt, magnitude) + v8 + v9
							local v11 = (v10 - position2) / math.max(dt, 0.001)

							if v11.Magnitude > 0.001 then
								lookVector = v11.Unit or lookVector
							end

							clone2:PivotTo(pivot:Lerp(
								CFrame.lookAt(v10, v10 + lookVector, unit2),
								1 - math.exp(-10 * dt)
							))
						else
							if heartbeatConnection3 then
								heartbeatConnection3:Disconnect()
							end

							v4 = true
						end
					elseif heartbeatConnection3 then
						heartbeatConnection3:Disconnect()
					end
				end)
			end

			repeat
				task.wait()
			until v4 or not (proxy and proxy:IsDescendantOf(workspace))
		end
	elseif proxy:GetAttribute("TargetPlayer") then
		local v4 = false
		local character = player2.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if character and humanoidRootPart then
			local pivot = clone2:GetPivot()
			local position2 = pivot.Position
			local lastTime2 = tick()
			local heartbeatConnection3 = nil
			heartbeatConnection3 = RunService.Heartbeat:Connect(function(_)
				if clone2 and clone2.Parent and humanoidRootPart and humanoidRootPart.Parent then
					local v5 = (tick() - lastTime2) / 0.5
					local v6 = v5 > 1 and 1 or v5
					local position4 = position2
					local position3 = humanoidRootPart.Position
					local v8 = position3 - position4
					local magnitude = v8.Magnitude
					local v9 = magnitude > 1e-6 and v8 / magnitude or pivot.LookVector
					local v10 = magnitude <= 10 and 3 or not (magnitude > 10 and magnitude <= 200) and 30 or 3 + 27 * ((magnitude - 10) / 190)
					local v11 = position4 + v9 * (magnitude * 0.25) + createVector(0, 1, 0) * v10
					local v12 = position3 - v9 * (magnitude * 0.25) + createVector(0, 1, 0) * (v10 * 0.5)
					local v13 = cubicBezier(v6, position4, v11, v12, position3)
					local v14 = math.min(1, v6 + 0.01)
					local v15 = cubicBezier(v14, position4, v11, v12, position3) - v13

					if v15.Magnitude < 1e-6 then
						v15 = v9
					end

					clone2:PivotTo(CFrame.lookAt(v13, v13 + v15.Unit, createVector(0, 1, 0)))

					if v6 >= 1 then
						v4 = true

						if heartbeatConnection3 then
							heartbeatConnection3:Disconnect()
						end
					end
				elseif heartbeatConnection3 then
					heartbeatConnection3:Disconnect()
				end
			end)
		end

		repeat
			task.wait()
		until v4 or not (proxy and proxy:IsDescendantOf(workspace))
	end

	if heartbeatConnection2 then
		heartbeatConnection2:Disconnect()
	end

	if v3 then
		Util.Sound:FadeOut(v3, 0.2)
	end

	Util.Sound:Play("F_Ghost_Disappear_0" .. tostring(math.random(1, 5)) .. "_V1", clone2.PrimaryPart.Position)
	local clone3 = assets.Phase1.EndImpact:Clone()

	if flag2 then
		Util.ResizeModel(clone3, 1.5)
	end

	clone3.CFrame = clone2.PrimaryPart.CFrame
	Util.SetParentOverrideWithColor(clone3, folder, player, "PainFruitVFXColor", true)

	if areShiftedColorsEqual(
		player,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 146, 220),
		Color3.fromRGB(128, 183, 255),
		Color3.fromRGB(85, 170, 255)
	) then
		Util.AdjustObjectDescendantsColors(clone3, function(_, p)
			if math.random() > 0.5 then
				p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
			end

			return p
		end)
	end

	Util.SyncColorsOnChange(clone3, player, "PainFruitVFXColor", true)
	DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v4 = emitter
		task.spawn(function()
			if v4:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v4:GetAttribute("EmitDelay"))
			end

			v4:Emit(v4:GetAttribute("EmitCount"))
		end)
	end

	pcall(function()
		clone2:Destroy()
	end)
end