local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Pain").V.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

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

local function getColorHSVDistance(color: Color3, color2: Color3)
	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local color3 = Color3.fromRGB(v2, v3, v4)
	local v5 = math.max(1, color2.R, color2.G, color2.B)
	local v6 = math.floor(color2.R / v5 * 255) % 256
	local v7 = math.floor(color2.G / v5 * 255) % 256
	local v8 = math.floor(color2.B / v5 * 255) % 256
	local color4 = Color3.fromRGB(v6, v7, v8)
	local HSV, _, _ = color3:ToHSV()
	local HSV2, _, _ = color4:ToHSV()
	local v9 = math.abs(HSV2 - HSV)
	return (math.min(v9, 1 - v9))
end

local function applyColorShiftHSV2(color: Color3, p: number, p2: number, p3: number)
	if getColorHSVDistance(color, Color3.new(1, 1, 0)) > 0.1111111111111111 then
		return color
	end

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

Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
local _ = {
	"rbxassetid://130452828882944",
	"rbxassetid://71120275331630",
	"rbxassetid://83529237504062",
	"rbxassetid://89359982828229",
	"rbxassetid://119164541102628",
	"rbxassetid://128504348629671",
	"rbxassetid://123584584840567"
}

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

local function TrailCurve(p, p2, position, position2, p3, p4, p5)
	local magnitude = (position - position2).Magnitude
	local v = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
	math.random(20, 30)
	local v2 = CFrame.new(position3, position3 + p2.LookVector) * p3.Position
	local v3 = CFrame.new(position4, position4 + p2.LookVector) * p4.Position
	local lastTime = tick()
	local v4 = magnitude / p5 / 60
	local _ = (magnitude / p5 + p5) / 60

	while tick() - lastTime < v4 do
		local v5 = (tick() - lastTime) / v4
		local v6 = cubicBezier(v5, position, v2, v3, position2)
		p.CFrame = CFrame.new(p.CFrame:Lerp(CFrame.new(v6, position2), v5).Position)
		RunService.Heartbeat:Wait()
	end
end

local function fn2(color: Color3, p, p2: string)
	local color3Constructor = Util.WrapColor3Constructor(color, p, p2)

	if areShiftedColorsEqual(
		p,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		color3Constructor = applyColorShiftHSV2(color3Constructor, 0.41666667, 1.165137614678899, 1)
	end

	return color3Constructor
end

local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(player, ...)
	local v = lightningBoltShafi.new(...)
	local curveSize = -math.random(5, 35)
	local curveSize2 = math.random(5, 35)
	v.CurveSize0 = curveSize
	v.CurveSize1 = curveSize2
	v.MinRadius = 3
	v.MaxRadius = 13
	v.Frequency = 0.5
	v.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(3, 4)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 10
	v.PulseLength = 1000000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = fn2(Color3.new(1, 0.380392, 0.380392), player, "PainFruitVFXColor")
	v.ColorOffsetSpeed = 3
	return v
end

return function(data)
	local player = data.Player
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		return
	end

	if stage == 2 then
		local proxy = data.Proxy

		if not proxy then
			return
		end

		local v = workspace._WorldOrigin:FindFirstChild("PainVBall_" .. data.Player.Name)
		local holdBall, painBall

		if v then
			holdBall = v:FindFirstChild("HoldBall")
			holdBall.Weld.Enabled = false
			painBall = v:FindFirstChild("HoldBall").PainBall
			painBall.CFrame = data.StartCFrame
			painBall.Anchored = true
		else
			v = Instance.new("Folder", workspace._WorldOrigin)
			holdBall = assets.Phase0.HoldBall:Clone()
			holdBall.Weld.Enabled = false
			painBall = holdBall.PainBall
			painBall.CFrame = data.StartCFrame
			painBall.Anchored = true
			fn(painBall, v, player, "PainFruitVFXColor")

			if data.Root then
				pcall(function()
					if data.Root:GetAttribute("PainSkin") and data.Root:GetAttribute("PainSkin") == "PAINSKINsuperspirit" then
						local hacker = assets.Phase0.Hacker
						holdBall.PainBall.Attachment:Destroy()
						local clone = hacker.Attachment:Clone()
						clone.Parent = holdBall.PainBall
					end
				end)
			end
		end

		holdBall:ScaleTo(0.75)
		v.Name = "Destroying"
		Util.Debris:AddItem(v, 15)
		local root = data.Root

		if root:GetAttribute("PainSkin") then
			local _ = root:GetAttribute("PainSkin") == "PAINSKINsuperspirit"
		end

		local clone = assets.Phase1.ChargeEmit:Clone()
		clone.CFrame = holdBall.PrimaryPart.CFrame
		fn(clone, v, player, "PainFruitVFXColor")
		Util.Sound:Play("V_Launch_Small_01_V1", clone.Position)
		local v2 = Util.Sound:Play("V_Traveling_Loop_01_V1", holdBall.PrimaryPart)
		TweenService:Create(v2, TweenInfo.new(0.4), {
			Volume = 1
		}):Play()

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end

		if holdBall:FindFirstChild("Aura") then
			for _, emitter in pairs(holdBall:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") and emitter:IsDescendantOf(holdBall.Aura) then
					emitter.Enabled = true
				end
			end
		end

		local _ = data.Lifetime
		local _ = data.Dist
		local _ = data.Lifetime
		local lifetime = data.Lifetime
		local v3 = data.Dist / lifetime
		local total = 0
		local v4 = false
		local v5 = nil
		local v6 = 0
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if proxy:IsDescendantOf(workspace) then
				total += dt
				local v7 = v3 * dt
				local Y = painBall.Size.Y
				local ray, v8, v9 = Util.Ray(
					painBall.Position + createVector(0, 1, 0) * Y * 0.5,
					createVector(-0, -1, -0) * (Y + 1),
					{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
				)

				if ray then
					local v10 = v8.Y + Y * 0.5 + 0
					v4 = true
					v5 = math.max(v5 or -1e999, v10)
				end

				local v10 = 0

				if v4 and v5 then
					local Y2 = painBall.Position.Y

					if Y2 < v5 then
						v10 = math.min(v3 * dt, v5 - Y2)
					elseif not select(
						1,
						Util.Ray(
							painBall.Position + createVector(0, 1, 0) * Y * 0.5,
							createVector(-0, -1, -0) * (Y + 1),
							{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
						)
					) then
						v4 = false
						v5 = nil
					end
				end

				local v11 = math.clamp(dt * 6, 0, 1)
				local v12 = math.max(0, v6 + (v10 - v6) * v11)
				local lookVector = painBall.CFrame.LookVector
				local v13 = lookVector * v7
				local vector2 = Vector3.new(0, v12, 0)
				local v14 = painBall.Position + v13 + vector2

				if ray then
					painBall.CFrame = Util.Misc.AlignCFrame(CFrame.lookAt(v14, v14 + lookVector), v9)
				else
					painBall.CFrame = CFrame.lookAt(v14, v14 + lookVector)
				end

				v6 = v12

				if lifetime <= total then
					heartbeatConnection:Disconnect()
				end
			elseif heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		end)
		local v7 = tick() + lifetime

		repeat
			task.wait()
		until v7 < tick() or not data.Proxy:IsDescendantOf(workspace)

		painBall:SetAttribute("Cooked", true)

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		for _, emitter in pairs(holdBall:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	elseif stage == 3 then
		local folder = Instance.new("Folder")
		fn(folder, _WorldOrigin, player, "PainFruitVFXColor")
		Util.Debris:AddItem(folder, 15)
		local cframe = CFrame.new(data.TargetPosition)
		local clone = assets.Phase2.HitImpact:Clone()
		clone.CFrame = cframe
		fn(clone, folder, player, "PainFruitVFXColor")

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

		Util.Sound:Play("V_Hit_Absorb_01_V1", cframe.Position)

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

		local clone2 = assets.Phase2.Circle:Clone()
		clone2.CFrame = cframe
		fn(clone2, folder, player, "PainFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				v:Emit(1)
				v.Enabled = true
				task.wait(0.5)
				v.Enabled = false
				v:Destroy()
			end)
		end

		task.spawn(function()
			for i = 1, 10 do
				local clone3 = FX:WaitForChild("Pain").V.Part:Clone()
				clone3.CFrame = cframe * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				) * CFrame.new(0, 0, -30)
				fn(clone3, folder, player, "PainFruitVFXColor")
				clone3.Attach1.WorldPosition = cframe.Position
				local shafiBolt = ShafiBolt(player, clone3.Attach0, clone3.Attach1, math.random(5, 8), 1, folder)

				if i % 2 == 0 then
					shafiBolt.Color = fn2(Color3.fromRGB(181, 40, 40), player, "PainFruitVFXColor")
					shafiBolt.Thickness = 0.65
				end

				task.spawn(function()
					task.wait(0.175 + math.random() * 0.25)
					shafiBolt:Destroy()
				end)
				task.wait(0.05)
			end
		end)
		task.wait(0.5)
		local hitRoot = data.HitRoot
		local clone3 = assets.Phase3.ExplosionStart:Clone()
		clone3:PivotTo(cframe)
		fn(clone3, folder, player, "PainFruitVFXColor")

		if hitRoot and hitRoot:IsA("BasePart") then
			task.spawn(function()
				local v = tick() + 1

				while tick() < v and hitRoot:IsDescendantOf(workspace) do
					cframe = hitRoot.CFrame
					clone3:PivotTo(hitRoot.CFrame)
					task.wait()
				end
			end)
		end

		clone3:ScaleTo(0.45)
		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:IsDescendantOf(clone3.Aura) then
					v.Enabled = true
					task.wait(0.25)
					v.Enabled = false
				elseif v:IsDescendantOf(clone3.Impact) then
					if v:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v:GetAttribute("EmitDelay"))
					end

					v:Emit(v:GetAttribute("EmitCount"))
				elseif v:IsDescendantOf(clone3.Explosion) then
					task.wait(0.285)
					v:Emit(v:GetAttribute("EmitCount"))
				end
			end)
		end

		task.spawn(function()
			local clone4 = assets.Phase3.SpinSlash:Clone()
			clone4:PivotTo(CFrame.new(cframe.Position))

			if hitRoot and hitRoot:IsA("BasePart") then
				task.spawn(function()
					local v = tick() + 1

					while tick() < v and hitRoot:IsDescendantOf(workspace) do
						clone4:PivotTo(hitRoot.CFrame)
						task.wait()
					end
				end)
			end

			fn(clone4, folder, player, "PainFruitVFXColor")
			local model = clone4.Model

			for i = 1, 5 do
				local _ = math.random(35, 65) / 100
				local clone5 = model:Clone()
				clone5:ScaleTo(i * 0.35 + 2.25)
				local primaryPart = clone5.PrimaryPart
				local v2 = clone4.PrimaryPart.CFrame * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				)
				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.Position
				angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15) * 2, 0)
				clone5:PivotTo(v2)
				fn(clone5, clone4, player, "PainFruitVFXColor")
				primaryPart.AlignPosition.Enabled = true
				angularVelocity.Enabled = true
				clone5:GetScale()
				local folder2 = clone5
				task.spawn(function()
					task.spawn(function()
						TweenService:Create(
							angularVelocity,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
									math.random(-15, 15) / 10,
									math.random(5, 15),
									math.random(-15, 15) / 10
								)
							}
						):Play()
					end)
					task.wait(0.035 * math.random() + 0.15)

					for i2, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.35 + math.random() * 0.125), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v4 = effect
							task.delay(1, function()
								v4:Destroy()
							end)
						elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					task.wait(1)
					angularVelocity.Enabled = false
					task.wait(3)
					angularVelocity:Destroy()
				end)
			end

			model:Destroy()
			task.spawn(function()
				local scale = clone4:GetScale()
				local v = scale * 0.1

				for i = scale * 100, v * 100, -13 do
					clone4:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)
		task.spawn(function()
			for _ = 1, 5 do
				task.spawn(function()
					local v = math.random(45, 65) / 130
					local clone4 = assets.Phase3.TrailModel:Clone()
					clone4.Start.CFrame = cframe * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					fn(clone4, folder, player, "PainFruitVFXColor")

					if areShiftedColorsEqual(
						player,
						"PainFruitVFXColor",
						Color3.fromRGB(255, 146, 220),
						Color3.fromRGB(128, 183, 255),
						Color3.fromRGB(85, 170, 255)
					) then
						Util.AdjustObjectDescendantsColors(clone4, function(_, p)
							if math.random() > 0.5 then
								p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
							end

							return p
						end)
					end

					clone4:ScaleTo(math.random(13, 18) / 10)
					local start = clone4.Start
					local trail = clone4.Trail
					local cframe2 = CFrame.new(0, 0, -math.random(100, 150) * 0.5)
					TweenService:Create(trail.Weld, TweenInfo.new(v / 2), {
						C1 = cframe2
					}):Play()
					trail.Weld.C1 = CFrame.new(0, 0, 0)
					task.delay(v / 2, function()
						TweenService:Create(trail.Weld, TweenInfo.new(v), {
							C1 = CFrame.new(0, 0, 0)
						}):Play()
					end)
					trail.Trail1.Lifetime = math.random(50, 200) / 1500
					local angularVelocity = start.AngularVelocity
					start.Anchored = false
					start.AlignPosition.Position = start.Position
					TweenService:Create(angularVelocity, TweenInfo.new(0.15), {
						AngularVelocity = Vector3.new(math.random(-20, 25), math.random(-20, 25), math.random(-20, 25))
					}):Play()

					for _, effect in pairs(clone4:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
							continue
						end

						effect.Enabled = true
						local v2 = effect
						task.delay(v + v / 2, function()
							v2.Enabled = false
						end)
					end

					task.wait(v)
					angularVelocity.Enabled = false
					task.wait(v)
					clone4:Destroy()
				end)
			end
		end)
	end
end