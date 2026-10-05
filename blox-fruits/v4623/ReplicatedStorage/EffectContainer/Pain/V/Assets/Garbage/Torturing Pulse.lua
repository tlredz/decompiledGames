local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local mouse = Players.LocalPlayer:GetMouse()
local currentCamera = workspace.CurrentCamera
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Players }
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map.Map }
local overlapParams2 = OverlapParams.new()
overlapParams2.FilterType = Enum.RaycastFilterType.Include
overlapParams2.FilterDescendantsInstances = { workspace.Players }
local random = Random.new()
local v = {
	"rbxassetid://130452828882944",
	"rbxassetid://71120275331630",
	"rbxassetid://83529237504062",
	"rbxassetid://89359982828229",
	"rbxassetid://119164541102628",
	"rbxassetid://128504348629671",
	"rbxassetid://123584584840567"
}

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == true or enabled == false then
			effect.Enabled = enabled
		elseif effect:IsA("ParticleEmitter") then
			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			continue
		end

		if not effect:IsA("ParticleEmitter") or effect.Lifetime.Max <= max then
			continue
		end

		max = effect.Lifetime.Max
	end

	return max
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

local v2 = {}
local FX = require(game.ReplicatedStorage.FX)
local torturingPulse = FX:WaitForChild("Pain").V.Assets.Garbage["Torturing Pulse"]
return function(p, instance)
	v2[instance] = p

	if p == "End" then
		v2[instance] = nil
		return
	end

	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	instance:WaitForChild("Humanoid")
	local clone = torturingPulse.Charge:Clone()
	clone.CFrame = humanoidRootPart.CFrame
	Util.SetParentOverrideWithColor(clone, workspace.Effects, player, "PainFruitVFXColor")
	local clone2 = torturingPulse.ChargeOrbModel:Clone()
	local chargeOrb = clone2.ChargeOrb
	chargeOrb.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)
	Util.SetParentOverrideWithColor(clone2, workspace.Effects, player, "PainFruitVFXColor")
	humanoidRootPart.Anchored = true
	local lastTime = os.clock()
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, mouse.Hit.Position)
		chargeOrb.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)

		if os.clock() - lastTime < 0.05 then
			return
		end

		lastTime = os.clock()
		local clone3 = torturingPulse.Shockwave:Clone()
		clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(
			0,
			random:NextNumber(0, 6.283185307179586),
			0
		)
		Util.SetParentOverrideWithColor(clone3, workspace.Effects, player, "PainFruitVFXColor")
		clone3.Mesh.Scale = createVector(10, 10, 10)
		clone3.Mesh.Offset = createVector(0, 2, 0)
		TweenService:Create(clone3.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Offset = createVector(0, 1, 0),
			Scale = createVector(25, 5, 25)
		}):Play()

		for _, texture in v do
			clone3.Decal.Texture = texture
			task.wait(0.016666666666666666)
		end

		clone3:Destroy()
	end)

	repeat
		task.wait()
	until instance.Parent == nil or instance == nil or not v2[instance]

	local _ = mouse.Hit.Position

	if instance.Parent == nil or instance == nil then
		return
	end

	local particleState = ParticleState(clone, false)
	task.delay(particleState, clone.Destroy, clone)

	for i = 0, 1, RunService.Heartbeat:Wait() / 0.24 do
		clone2:ScaleTo(1 + 19 * TweenService:GetValue(i, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out))
		chargeOrb.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)
		RunService.Heartbeat:Wait()
	end

	local clone3 = torturingPulse.ChargeEmit:Clone()
	clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)
	Util.SetParentOverrideWithColor(clone3, workspace.Effects, player, "PainFruitVFXColor")
	local particleState2 = ParticleState(clone3)
	task.delay(particleState2, clone3.Destroy, clone3)
	clone2:Destroy()
	task.wait(0.06)
	heartbeatConnection:Disconnect()
	humanoidRootPart.Anchored = false
	local clone4 = torturingPulse.PainBall:Clone()
	clone4.CFrame = CFrame.lookAt(humanoidRootPart.Position, mouse.Hit.Position) * CFrame.new(0, 5, -3)
	Util.SetParentOverrideWithColor(clone4, workspace.Effects, player, "PainFruitVFXColor")
	local raycastResult = nil
	local raycastResult2 = nil
	local clone5 = torturingPulse.FloorEffect:Clone()
	clone5.CFrame = humanoidRootPart.CFrame
	Util.SetParentOverrideWithColor(clone5, workspace.Effects, player, "PainFruitVFXColor")
	local v5 = false
	local heartbeatConnection2 = nil
	heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
		raycastResult = workspace:Raycast(clone4.Position, clone4.CFrame.LookVector * 450 * dt, raycastParams)
		print(raycastResult)

		if raycastResult then
			heartbeatConnection2:Disconnect()
			local particleState3 = ParticleState(clone5, false)
			task.delay(particleState3, clone5.Destroy, clone5)
			task.delay(ParticleState(clone4, false), clone4.Destroy, clone4)
			local clone6 = torturingPulse.FinalExplosion.NormalExplosion:Clone()
			clone6.Position = raycastResult.Position
			Util.SetParentOverrideWithColor(clone6, workspace.Effects, player, "PainFruitVFXColor")
			task.delay(ParticleState(clone6), clone6.Destroy, clone6)
			local clone7 = torturingPulse.InsideRed:Clone()
			clone7.Position = raycastResult.Position
			Util.SetParentOverrideWithColor(clone7, workspace.Effects, player, "PainFruitVFXColor")
			TweenService:Create(clone7, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
				Size = createVector(100, 100, 100)
			}):Play()
			local clone8 = torturingPulse.FloorWindup:Clone()
			clone8.Position = raycastResult.Position
			Util.SetParentOverrideWithColor(clone8, workspace.Effects, player, "PainFruitVFXColor")
			TweenService:Create(clone8, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Size = createVector(100, 5, 100)
			}):Play()
			local lastTime2 = os.clock()
			local heartbeatConnection3 = RunService.Heartbeat:Connect(function()
				if os.clock() - lastTime2 < 0.04 then
					return
				end

				lastTime2 = os.clock()
				local clone9 = torturingPulse.Deform:Clone()
				clone9.Size = createVector(120, 120, 120)
				clone9.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)
				Util.SetParentOverrideWithColor(clone9, workspace.Effects, player, "PainFruitVFXColor")
				TweenService:Create(clone9, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					Size = clone7.Size + createVector(50, 50, 50),
					Transparency = 1
				}):Play()
				task.wait(0.1)
				clone9:Destroy()
			end)
			task.wait(0.5)
			local clone9 = torturingPulse.BigCharge:Clone()
			clone9.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(0, clone9.Size.Y / 2, 0)
			Util.SetParentOverrideWithColor(clone9, workspace.Effects, player, "PainFruitVFXColor")
			ParticleState(clone9)
			task.spawn(function()
				for _ = 1, 2 do
					local clone10 = torturingPulse.Impact1:Clone()
					Util.SetParentOverrideWithColor(clone10, Lighting, player, "PainFruitVFXColor")
					task.wait(0.03)
					clone10:Destroy()
					local clone11 = torturingPulse.Impact2:Clone()
					Util.SetParentOverrideWithColor(clone11, Lighting, player, "PainFruitVFXColor")
					task.wait(0.03)
					clone11:Destroy()
				end
			end)
			task.delay(ParticleState(clone8, false), clone8.Destroy, clone8)
			heartbeatConnection3:Disconnect()
			TweenService:Create(clone7, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			task.delay(0.1, clone7.Destroy, clone7)
			local clone10 = torturingPulse.FinalExplosion.BeginingExplosion:Clone()
			clone10.Mesh.Scale = createVector(0, 0, 0)
			clone10.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
			Util.SetParentOverrideWithColor(clone10, workspace.Effects, player, "PainFruitVFXColor")
			TweenService:Create(clone10.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Scale = createVector(35, 35, 35)
			}):Play()
			TweenService:Create(clone10.Decal, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Color3 = Util.WrapColor3Constructor(Color3.new(2, 2, 2), player, "PainFruitVFXColor")
			}):Play()
			task.wait(0.15)
			TweenService:Create(clone10.Mesh, TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Scale = createVector(35, 50, 35)
			}):Play()
			task.wait(0.09)
			task.spawn(function()
				for _ = 1, 7 do
					task.spawn(function()
						local clone11 = torturingPulse.PainFaces:Clone()
						local cframe = CFrame.lookAt(
							raycastResult.Position,
							raycastResult.Position + raycastResult.Normal
						)
						local position = raycastResult.Position + cframe.RightVector * random:NextNumber(-50, 50) + cframe.UpVector * random:NextNumber(
							-50,
							50
						)
						local v8 = position + Vector3.new(
							random:NextNumber(-80, 80),
							random:NextNumber(40, 80),
							random:NextNumber(-80, 80)
						)
						local v9 = position + Vector3.new(
							random:NextNumber(-80, 80),
							random:NextNumber(60, 90),
							random:NextNumber(-80, 80)
						)
						local v10 = position + Vector3.new(
							random:NextNumber(-80, 80),
							random:NextNumber(70, 100),
							random:NextNumber(-80, 80)
						)
						clone11.Position = position
						Util.SetParentOverrideWithColor(clone11, workspace.Effects, player, "PainFruitVFXColor")
						local number = random:NextNumber(0.4, 1)
						clone11.Particle.Face.Lifetime = NumberRange.new(number, number)
						ParticleState(clone11)
						local v11 = position

						for i = 0, 1, RunService.Heartbeat:Wait() / number do
							local v12 = position + (v8 - position) * i
							local v13 = v8 + (v9 - v8) * i
							local v14 = v9 + (v10 - v9) * i
							local v15 = v12 + (v13 - v12) * i
							local v16 = v15 + (v13 + (v14 - v13) * i - v15) * i

							if v16 == v11 then
								continue
							end

							clone11.CFrame = CFrame.lookAt(v16, v11) * CFrame.Angles(0, 3.141592653589793, 0)
							RunService.Heartbeat:Wait()
							v11 = v16
						end

						ParticleState(clone11, false)
					end)
					task.wait(random:NextNumber(0.03, 0.05))
				end
			end)
			clone10:Destroy()
			local clone11 = torturingPulse.FinalExplosion.FloorExplosion:Clone()
			clone11.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
			Util.SetParentOverrideWithColor(clone11, workspace.Effects, player, "PainFruitVFXColor")
			task.delay(ParticleState(clone11), clone11.Destroy, clone11)
			local clone12 = torturingPulse.Cylinder:Clone()
			clone12.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				random:NextNumber(0, 6.283185307179586),
				0
			) * CFrame.new(0, 50, 0)
			Util.SetParentOverrideWithColor(clone12, workspace.Effects, player, "PainFruitVFXColor")
			local partBoundsInBox = workspace:GetPartBoundsInBox(
				CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.new(0, 50, 0),
				createVector(150, 100, 150),
				overlapParams2
			)
			local v7 = {}

			for _, part in partBoundsInBox do
				if not part:IsA("BasePart") or not part.Parent:FindFirstChildOfClass("Humanoid") or v7[part.Parent] then
					continue
				end

				v7[part.Parent] = true
				local humanoidRootPart2 = part.Parent:WaitForChild("HumanoidRootPart")
				local clone13 = torturingPulse.PainGhost:Clone()
				local number = random:NextNumber(0, 360)
				local number2 = random:NextNumber(0, 360)
				local position = humanoidRootPart2.Position
				local v8 = math.sin((math.rad(number))) * 3
				local v9 = math.sin((math.rad(number2))) * 3
				local position2 = position + Vector3.new(v8, v9, math.cos((math.rad(number))) * 3)
				local v11 = nil
				clone13.Position = position2
				Util.SetParentOverrideWithColor(clone13, workspace.Effects, player, "PainFruitVFXColor")
				local heartbeatConnection4 = RunService.Heartbeat:Connect(function(dt2)
					number += 450 * dt2
					number2 += 350 * dt2
					v11 = humanoidRootPart2.Position + Vector3.new(
						math.sin((math.rad(number))) * 3,
						math.sin((math.rad(number2))) * 3,
						math.cos((math.rad(number))) * 3
					)
					clone13.CFrame = CFrame.lookAt(v11, position2) * CFrame.Angles(0, 3.141592653589793, 0)
					position2 = v11
				end)
				local v14 = 100
				local v15 = (v14 - 60) / 5
				local now = os.clock() - 60 / v14
				local clone14 = torturingPulse.RedColorCorrection:Clone()
				Util.SetParentOverrideWithColor(clone14, Lighting, player, "PainFruitVFXColor")
				local clone15 = torturingPulse.Blur:Clone()
				Util.SetParentOverrideWithColor(clone15, Lighting, player, "PainFruitVFXColor")
				local clone16 = torturingPulse.ScreenEffect:Clone()
				clone16.CFrame = currentCamera.CFrame
				Util.SetParentOverrideWithColor(clone16, workspace.Effects, player, "PainFruitVFXColor")
				task.delay(3.75, function()
					clone16.Effects.Grid.Flow.Rate = 30
					task.wait(1)
					clone16.Effects.Grid.Flow.Enabled = false
				end)
				local GUID = HttpService:GenerateGUID(false)
				local v17 = clone16
				RunService:BindToRenderStep("Camera Effect" .. GUID, Enum.RenderPriority.Camera.Value, function()
					v17.CFrame = currentCamera.CFrame
				end)
				local v19 = clone16
				local heartbeatConnection5 = RunService.Heartbeat:Connect(function(dt2)
					v14 -= v15 * dt2
					v19.Effects.Grid.Grid.Lifetime = NumberRange.new(60 / v14, 60 / v14)
					v19.Effects.Grid.Grid.Rate = v14 / 60
					v19.Effects.Attachment.HeartBeat.Lifetime = NumberRange.new(60 / v14, 60 / v14)
					v19.Effects.Attachment.HeartBeat.Rate = v14 / 60

					if os.clock() - now < 60 / v14 then
						return
					end

					now = os.clock()
					TweenService:Create(
						clone14,
						TweenInfo.new(60 / (v14 * 2), Enum.EasingStyle.Circular, Enum.EasingDirection.In),
						{
							Brightness = -1.7,
							Contrast = -5,
							Saturation = -3,
							TintColor = Util.WrapColor3Constructor(Color3.new(1, 1, 1), player, "PainFruitVFXColor")
						}
					):Play()
					TweenService:Create(
						clone15,
						TweenInfo.new(60 / (v14 * 2), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = (v14 - 60) / 40 * 15
						}
					):Play()
					task.delay(60 / (v14 * 2), function()
						TweenService:Create(
							clone14,
							TweenInfo.new(60 / (v14 * 2), Enum.EasingStyle.Circular, Enum.EasingDirection.In),
							{
								Brightness = -1.2,
								Contrast = -5,
								Saturation = -3,
								TintColor = Util.WrapColor3Constructor(Color3.new(1, 1, 1), player, "PainFruitVFXColor")
							}
						):Play()
						TweenService:Create(
							clone15,
							TweenInfo.new(60 / (v14 * 2), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = 0
							}
						):Play()
					end)

					for i = 1, 2 do
						TweenService:Create(
							currentCamera,
							TweenInfo.new(60 / (v14 * 3.5 * i), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								FieldOfView = i * 1.2 * (v14 / 60) + 70
							}
						):Play()
						task.wait(60 / (v14 * 3.5 * i))
						TweenService:Create(
							currentCamera,
							TweenInfo.new(60 / (v14 * 3.5 * i), Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								FieldOfView = 70
							}
						):Play()
						task.wait(60 / (v14 * 3.5 * i))
					end
				end)
				local v22 = clone14
				local v23 = clone16
				local v25 = clone13
				task.delay(5, function()
					task.delay(60 / (v14 * 2), function()
						TweenService:Create(
							v22,
							TweenInfo.new(60 / (v14 * 2), Enum.EasingStyle.Linear, Enum.EasingDirection.In),
							{
								Contrast = 0,
								Saturation = 0,
								Brightness = 0,
								TintColor = Util.WrapColor3Constructor(Color3.new(1, 1, 1), player, "PainFruitVFXColor")
							}
						):Play()
						task.wait(60 / (v14 * 2))
						v22:Destroy()
						task.wait((ParticleState(v23, false)))
						v23:Destroy()
						RunService:UnbindFromRenderStep("Camera Effect" .. GUID)
					end)
					heartbeatConnection5:Disconnect()
					heartbeatConnection4:Disconnect()
					local clone17 = torturingPulse.PainGhostDisappear:Clone()
					clone17.CFrame = v25.CFrame
					Util.SetParentOverrideWithColor(clone17, workspace.Effects, player, "PainFruitVFXColor")
					v25:Destroy()
					task.delay(ParticleState(clone17), clone17.Destroy, clone17)
				end)
			end

			task.spawn(function()
				local v8 = {
					"rbxassetid://88771098185018",
					"rbxassetid://96005854960728",
					"rbxassetid://117325338135183",
					"rbxassetid://93453260088779",
					"rbxassetid://78476917309896",
					"rbxassetid://98893789629427",
					"rbxassetid://72761888588062",
					"rbxassetid://75710440595597",
					"rbxassetid://102806897654090",
					"rbxassetid://86092907664424"
				}
				local v9 = RunService.Heartbeat:Wait() * #v8
				clone12.Mesh.Scale = createVector(10, 100, 10)
				clone12.Decal.Transparency = 0.4
				clone12.Decal.Color3 = Util.WrapColor3Constructor(Color3.new(1, 1, 1), player, "PainFruitVFXColor")
				TweenService:Create(clone12.Mesh, TweenInfo.new(v9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Scale = createVector(150, 100, 150)
				}):Play()
				TweenService:Create(
					clone12.Decal,
					TweenInfo.new(v9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Transparency = 0.7
					}
				):Play()

				for _, texture in v8 do
					clone12.Decal.Texture = texture
					task.wait()
				end

				clone12:Destroy()
			end)
			task.spawn(function()
				for _ = 1, 9 do
					local clone13 = torturingPulse.PainSmoke:Clone()
					local painSmoke = clone13.PainSmoke
					painSmoke.CFrame = CFrame.lookAt(
						raycastResult.Position,
						raycastResult.Position + raycastResult.Normal
					) * CFrame.Angles(-1.5707963267948966, random:NextNumber(0, 6.283185307179586), 0)
					Util.SetParentOverrideWithColor(clone13, workspace.Effects, player, "PainFruitVFXColor")
					local number = random:NextNumber(0.6, 1.55)
					TweenService:Create(
						painSmoke,
						TweenInfo.new(number, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							CFrame = painSmoke.CFrame * CFrame.new(0, 0, random:NextNumber(60, 130))
						}
					):Play()
					task.spawn(function()
						for i = 0, 1, RunService.Heartbeat:Wait() / number do
							clone13:ScaleTo(1 - i)
							print(1 - i)
							task.wait()
						end

						task.delay(ParticleState(painSmoke, false), clone13.Destroy, clone13)
					end)
				end
			end)

			for _ = 1, 3 do
				local clone13 = torturingPulse.Cylinder:Clone()
				clone13.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
					-1.5707963267948966,
					random:NextNumber(0, 6.283185307179586),
					0
				) * CFrame.new(0, 50, 0)
				Util.SetParentOverrideWithColor(clone13, workspace.Effects, player, "PainFruitVFXColor")
				task.spawn(function()
					local v9 = {
						"rbxassetid://88771098185018",
						"rbxassetid://99015514972091",
						"rbxassetid://105738007671741",
						"rbxassetid://117325338135183",
						"rbxassetid://93453260088779",
						"rbxassetid://78476917309896",
						"rbxassetid://98893789629427",
						"rbxassetid://72761888588062",
						"rbxassetid://75710440595597",
						"rbxassetid://102806897654090",
						"rbxassetid://86092907664424"
					}
					local v10 = RunService.Heartbeat:Wait() * #v9
					TweenService:Create(
						clone13.Mesh,
						TweenInfo.new(v10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Scale = createVector(110, 50, 110)
						}
					):Play()
					clone13.Decal.Transparency = 1
					TweenService:Create(
						clone13.Decal,
						TweenInfo.new(v10, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0.6
						}
					):Play()

					for k, texture in v9 do
						clone13.Decal.Texture = texture
						task.wait()
					end

					clone13:Destroy()
				end)
				task.wait(0.1)
			end
		else
			clone4.CFrame *= CFrame.new(0, 0, -450 * dt)
			local position = raycastResult2 and raycastResult2.Position
			raycastResult2 = workspace:Raycast(
				clone4.Position + Vector3.new(0, clone4.Size.Y / 2, 0),
				Vector3.new(0, -clone4.Size.Y * 1.5, 0),
				raycastParams
			)
			local position2 = raycastResult2 and raycastResult2.Position

			if position and position2 then
				if v5 == false then
					ParticleState(clone5, true)
					v5 = true
				end

				clone5.CFrame = CFrame.lookAt(position2, position)
			elseif v5 == true then
				ParticleState(clone5, false)
			end
		end
	end)
	task.wait(1.2)
	local particleState4 = ParticleState(clone5, false)
	task.delay(particleState4, clone5.Destroy, clone5)

	if not heartbeatConnection2.Connected then
		return
	end

	heartbeatConnection2:Disconnect()
	local clone6 = torturingPulse.Explosion:Clone()
	clone6.CFrame = clone4.CFrame
	Util.SetParentOverrideWithColor(clone4, workspace.Effects, player, "PainFruitVFXColor")
	local particleState5 = ParticleState(clone6)
	task.delay(particleState5, clone6.Destroy, clone6)
	local particleState6 = ParticleState(clone4, false)
	clone4.Transparency = 1
	task.wait(particleState6)
	clone4:Destroy()
end