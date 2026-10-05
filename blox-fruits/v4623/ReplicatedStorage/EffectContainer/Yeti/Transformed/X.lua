local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
Random.new()
local FX = require(ReplicatedStorage.FX)
local x_Tr = FX:WaitForChild("YetiEffects").X_Tr

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		else
			emitter:Emit(1)
		end
	end
end

return function(data)
	local player = data.player
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 2500 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local root = data.Root
		local player2 = data.Player

		local function fn()
			return CFrame.new(2, 20, -1.5) * CFrame.Angles(
				math.sin(tick() / 10) * 0.3,
				math.cos(tick() / 10) * 0.3,
				math.sin(tick() / 10) * 0.3
			)
		end

		local clone = x_Tr.Glacier:Clone()
		clone.Massless = true
		clone.Anchored = true
		clone.Name = "GlacierBall_" .. root.Parent.Name
		clone.CFrame = root.CFrame * fn()
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		local v = Util.Sound:Play("YETI_TSFM_X_GlacialToss_Hold_01", root)
		emitAll(clone.ExpandStart)
		local clone2 = x_Tr.Forming:Clone()
		clone2.CFrame = root.CFrame * fn()
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone2, 2)
		emitAll(clone2)
		local thread = task.spawn(function()
			task.wait(0.23)
			Util.Sound:Play("YETI_TNSFM_X_GlacialToss_RockAppear_01_V2", clone)

			if v then
				TweenService:Create(v, TweenInfo.new(0.5), {
					Volume = 0.85
				}):Play()
			end

			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
				Size = createVector(35.717, 35.387, 35.126)
			}):Play()
			emitAll(clone.ExpandEnd)
			clone.Specs.Enabled = true
			clone.Star.Enabled = true
			clone.Aura.Enabled = true
			clone.Aura2.Enabled = true
			clone.Star.Enabled = true
			clone.DropGlass.Enabled = true

			if clone.Name ~= "DESTROYING" then
				for _ = 1, 15 do
					local v2 = math.random(30, 50) / 10
					local clone3 = x_Tr.RockFly:Clone()
					Util.Debris:AddItem(clone3, 5)
					clone3.Size = Vector3.new(v2, v2, v2)
					clone3.CFrame = clone.CFrame * CFrame.Angles(
						math.rad((math.random(-360, 360))),
						math.rad((math.random(-360, 360))),
						(math.rad((math.random(-360, 360))))
					)
					clone3.CanCollide = false
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
					clone3.Velocity = clone3.CFrame.lookVector.Unit * Vector3.new(
						math.random(80, 120),
						math.random(80, 160),
						math.random(80, 120)
					)
					clone3.RotVelocity = Vector3.new(math.random(-7, 7), math.random(-7, 7), math.random(-7, 7))
					clone3.CFrame *= CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
				end
			end
		end)

		if player2 == game.Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(2, 15, 0.05, 0.5, createVector(0.9, 0.9, 0.9), createVector(0.9, 0.9, 0.9))
			task.spawn(function()
				local clone3 = script.DepthOfField:Clone()
				Util.SetParentOverrideWithColor(clone3, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone3, 2)
				TweenService:Create(clone3, TweenInfo.new(0.017, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					FarIntensity = 1,
					FocusDistance = 1.74,
					InFocusRadius = 0,
					NearIntensity = 0
				}):Play()
				task.wait(0.017)
				TweenService:Create(clone3, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					FarIntensity = 1,
					FocusDistance = 3.74,
					InFocusRadius = 24.35,
					NearIntensity = 0
				}):Play()
				task.wait(0.05)
				TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					FarIntensity = 0,
					FocusDistance = 0,
					InFocusRadius = 0,
					NearIntensity = 0
				}):Play()
			end)
			task.spawn(function()
				local clone3 = script.LTN:Clone()
				Util.SetParentOverrideWithColor(clone3, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone3, 2)
				TweenService:Create(clone3, TweenInfo.new(0.05), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(75, 156, 255),
						player,
						"YetiFruitVFXColor"
					),
					Brightness = 0.4,
					Contrast = 1,
					Saturation = 0.8
				}):Play()
				task.wait(0.05)
				TweenService:Create(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"YetiFruitVFXColor"
					),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				}):Play()
			end)
			task.spawn(function()
				task.wait(0.1)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.067, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 95
					}
				):Play()
				task.wait(0.067)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end)
		end

		local thread2 = task.spawn(function()
			for _ = 1, 25 do
				local clone3 = x_Tr.IceWind:Clone()
				clone3.CFrame = root.CFrame * fn() * CFrame.Angles(
					math.rad(math.random(850, 900) / 10),
					math.rad(math.random(-2556, 2556) / 10),
					(math.rad(math.random(-556, 556) / 10))
				)
				clone3.Anchored = false
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
				local v2 = math.random(10, 15) / 5
				local v3 = 35

				if math.random(2) == 1 then
					v3 *= -1
				end

				for _, attachment in pairs(clone3:GetDescendants()) do
					if not attachment:IsA("Attachment") then
						continue
					end

					attachment.Position = Vector3.new(0, attachment.Name == "Top" and v2 or -v2, 0)
					attachment.Position += Vector3.new(0, v3, 0)
				end

				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
				bodyVelocity.Velocity = clone3.CFrame.LookVector * math.random(60, 80)
				Util.SetParentOverrideWithColor(bodyVelocity, clone3, player, "YetiFruitVFXColor")
				local v4 = math.random(15, 25) / 1.5
				clone3.RotVelocity = clone3.CFrame.LookVector * v4
				coroutine.resume(coroutine.create(function()
					task.wait(math.random(15, 25) / 100)
					clone3.Anchored = true
					Util.Debris:AddItem(clone3, 1.5)
				end))
				v3 -= 2
			end
		end)

		local function fn2()
			if v then
				Util.Sound:FadeOut(v, 0.2)
			end

			task.wait(1)

			if clone.Name ~= "DESTROYING" then
				clone.Name = "DESTROYING"
				task.cancel(thread)
				task.cancel(thread2)
				clone:Destroy()
			end
		end

		if data.ProxyEnd then
			data.ProxyEnd.Destroying:Once(fn2)
			data.ProxyEnd.AncestryChanged:Once(fn2)
		elseif data.Proxy and data.Proxy.Parent then
			data.Proxy.Destroying:Once(fn2)
			data.Proxy.AncestryChanged:Once(fn2)
		end

		task.delay(30, fn2)

		if data.HoldingProxy then
			if data.HoldingProxy.Value then
				data.HoldingProxy.Changed:Once(fn2)
			else
				task.spawn(fn2)
			end
		end

		task.spawn(function()
			while clone.Name ~= "DESTROYING" and clone:IsDescendantOf(workspace) do
				clone.CFrame = root.CFrame * fn()
				task.wait()
			end
		end)
	elseif stage == 2 then
		if not data.Proxy then
			return
		end

		local proxy = data.Proxy
		local root = data.Root
		local player2 = data.Player
		local mousePos = data.MousePos
		local lifetime = data.Lifetime

		if player2 == game.Players.LocalPlayer then
			task.spawn(function()
				task.wait(0.1)
				Util.CameraShaker:ShakeOnce(8, 5, 0.05, 0.4, createVector(0.9, 0.9, 0.9), createVector(0.9, 0.9, 0.9))
				local clone = script.DepthOfField:Clone()
				Util.SetParentOverrideWithColor(clone, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone, 2)
				TweenService:Create(clone, TweenInfo.new(0.017, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					FarIntensity = 1,
					FocusDistance = 1.74,
					InFocusRadius = 0,
					NearIntensity = 0
				}):Play()
				task.wait(0.017)
				TweenService:Create(clone, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					FarIntensity = 1,
					FocusDistance = 1.74,
					InFocusRadius = 24.35,
					NearIntensity = 0
				}):Play()
				task.wait(0.05)
				TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					FarIntensity = 0,
					FocusDistance = 0,
					InFocusRadius = 0,
					NearIntensity = 0
				}):Play()
			end)
			task.spawn(function()
				task.wait(0.1)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.067, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 60
					}
				):Play()
				task.wait(0.067)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end)
		end

		local folder = _WorldOrigin:FindFirstChild("GlacierBall_" .. root.Parent.Name)

		if not folder then
			return
		end

		folder.Name = "DESTROYING"
		folder.CFrame = root.CFrame * CFrame.new(0, 4, -4)
		Util.Sound:Play("YETI_TSFM_X_GlacialToss_Throw_03", root.Position)
		folder.Aura.Lifetime = NumberRange.new(1, 1.2)
		Util.Sound:Play("TransBearIceBallThrow", folder, nil, 1 + math.random(-5, 5) / 100, 10)
		local _ = (mousePos - folder.Position).unit
		folder.Massless = false
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "YetiFruitVFXColor")
		folder.Anchored = false
		local cframe = CFrame.new(root.CFrame.p, mousePos)
		local bodyVelocity = Instance.new("BodyVelocity", folder)
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyVelocity.Velocity = cframe.LookVector * 8 * 85
		task.spawn(function()
			task.wait(0.25)
			bodyVelocity:Destroy()
		end)

		for _, trail in pairs(folder:GetDescendants()) do
			if trail:IsA("Trail") then
				trail.Enabled = true
			end
		end

		local clone = x_Tr.PushForce:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, -2, -10)
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 3)
		emitAll(clone)
		local clone2 = x_Tr.Pushback:Clone()
		clone2.CFrame = root.CFrame * CFrame.new(0, 20, -32) * CFrame.Angles(0, 3.141592653589793, 0)
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone2, 3)
		emitAll(clone2)
		task.spawn(function()
			task.wait(0.25)
			bodyVelocity:Destroy()
		end)
		local clone3 = x_Tr.Shock.ShootFloor:Clone()
		local clone4 = x_Tr.Shock.Floor:Clone()
		local clone5 = x_Tr.Shock.Shock:Clone()
		local clone6 = x_Tr.Shock.Air1:Clone()
		local clone7 = x_Tr.Shock.Air2:Clone()
		Util.SetParentOverrideWithColor(clone3, root, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone4, root, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone5, root, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone6, root, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone7, root, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone3, 2.5)
		Util.Debris:AddItem(clone4, 2.5)
		Util.Debris:AddItem(clone5, 2.5)
		Util.Debris:AddItem(clone6, 2.5)
		Util.Debris:AddItem(clone7, 2.5)
		task.spawn(function()
			emitAll(clone3)
			emitAll(clone4)
			emitAll(clone5)
			emitAll(clone6)
			emitAll(clone7)
		end)
		task.spawn(function()
			for _ = 1, 15 do
				if folder.Anchored ~= false then
					continue
				end

				emitAll(folder.Ring)
				task.wait(0.25)
			end
		end)
		task.spawn(function()
			for _ = 1, 25 do
				if folder.Anchored ~= false then
					continue
				end

				folder.Fall:Emit(2)
				task.wait(0.1)
			end
		end)
		local lastTime = tick()
		local v = false

		while proxy and tick() - lastTime < lifetime do
			task.wait()

			if proxy:IsDescendantOf(workspace) then
				if proxy:GetAttribute("Exploding") and not v then
					local exploding = proxy:GetAttribute("Exploding")
					folder.Anchored = true
					folder.Transparency = 1
					folder.CFrame = exploding
					folder.Star.Enabled = false
					folder.Aura.Enabled = false
					folder.Aura2.Enabled = false
					folder.Star.Enabled = false
					folder.DropGlass.Enabled = false
					Util.Debris:AddItem(folder, 2.5)
					task.spawn(function()
						Util.Sound:Play("Ice_unfreeze2", exploding.Position)
						Util.Sound:Play("YETI_TSFM_X_GlacialToss_Explosion_01", exploding.Position)
						local unit = folder.Velocity.Magnitude > 0.1 and folder.Velocity.Unit or folder.CFrame.LookVector
						local v3 = folder.Position - unit * 10
						local rayMap, v4, v5 = Util.RayMap(v3, unit * 40)

						if not rayMap then
							rayMap, v4, v5 = Util.RayMap(v3, createVector(-0, -40, -0))
						end

						if rayMap then
							local v6 = v5 * 0.1
							local cFrame = root.CFrame
							local clone8 = x_Tr.Bottom2:Clone()
							clone8.CFrame = Util.Misc.AlignCFrame(CFrame.new(v4, v4 + unit), v5)
							Util.SetParentOverrideWithColor(clone8, _WorldOrigin, player, "YetiFruitVFXColor")
							Util.Debris:AddItem(clone8, 3)
							local clone9 = x_Tr.Bottom:Clone()
							clone9.CFrame = clone8.CFrame * CFrame.new(0, 0.07, 0)
							Util.SetParentOverrideWithColor(clone9, _WorldOrigin, player, "YetiFruitVFXColor")
							Util.Debris:AddItem(clone9, 3)
							emitAll(clone9)
							local clone10 = x_Tr.DecalRingBlue1.ring1_1:Clone()
							local clone11 = x_Tr.DecalRingBlue1.ring1_2:Clone()
							clone10.CFrame = clone9.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(
								0,
								-1.5707963267948966,
								3.141592653589793
							)
							clone11.CFrame = clone9.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(
								0,
								1.5707963267948966,
								3.141592653589793
							)
							Util.SetParentOverrideWithColor(clone10, _WorldOrigin, player, "YetiFruitVFXColor")
							Util.SetParentOverrideWithColor(clone11, _WorldOrigin, player, "YetiFruitVFXColor")
							Util.Debris:AddItem(clone10, 3)
							Util.Debris:AddItem(clone11, 3)
							TweenService:Create(
								clone10,
								TweenInfo.new(0.317, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
								{
									CFrame = clone10.CFrame * CFrame.new(0, -15, 0)
								}
							):Play()
							TweenService:Create(
								clone11,
								TweenInfo.new(0.317, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
								{
									CFrame = clone10.CFrame * CFrame.new(0, -15, 0)
								}
							):Play()
							TweenService:Create(
								clone10.ring1_1,
								TweenInfo.new(0.317, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
								{
									Scale = createVector(-348.827, 0.542, -348.827)
								}
							):Play()
							TweenService:Create(
								clone11.ring1_2,
								TweenInfo.new(0.317, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
								{
									Scale = createVector(348.827, 0.542, 348.827)
								}
							):Play()
							TweenService:Create(
								clone10.Decal1_1,
								TweenInfo.new(0.31, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
								{
									Transparency = 1
								}
							):Play()
							TweenService:Create(
								clone11.Decal1_2,
								TweenInfo.new(0.31, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
								{
									Transparency = 1
								}
							):Play()
						end

						if (workspace.CurrentCamera.CFrame.p - exploding.Position).Magnitude <= 100 then
							task.spawn(function()
								Util.CameraShaker:ShakeOnce(
									8,
									11,
									0.05,
									0.8,
									createVector(1, 1, 1),
									createVector(1, 1, 1)
								)
								local clone8 = script.LTN:Clone()
								Util.SetParentOverrideWithColor(clone8, game.Lighting, player, "YetiFruitVFXColor")
								Util.Debris:AddItem(clone8, 2)
								TweenService:Create(clone8, TweenInfo.new(0.01), {
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(147, 223, 255),
										player,
										"YetiFruitVFXColor"
									),
									Brightness = 0.5,
									Contrast = 1,
									Saturation = 0.2
								}):Play()
								task.wait(0.01)
								TweenService:Create(clone8, TweenInfo.new(0.01), {
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(169, 222, 255),
										player,
										"YetiFruitVFXColor"
									),
									Brightness = 0.3,
									Contrast = 0.4,
									Saturation = 0.5
								}):Play()
								task.wait(0.01)
								TweenService:Create(
									clone8,
									TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										TintColor = Util.WrapColor3ConstructorForTintColor(
											Color3.fromRGB(255, 255, 255),
											player,
											"YetiFruitVFXColor"
										),
										Brightness = 0,
										Contrast = 0,
										Saturation = 0
									}
								):Play()
								TweenService:Create(
									workspace.Camera,
									TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										FieldOfView = 83
									}
								):Play()
								task.wait(0.082)
								TweenService:Create(
									workspace.Camera,
									TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
									{
										FieldOfView = 70
									}
								):Play()
							end)
						end
					end)

					for _, emitter in pairs(folder:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Enabled = false
						emitter.Rate = 0
					end

					local snowballAmount = data.SnowballAmount
					local cFrame = folder.CFrame
					local direction = data.direction
					local unit = Vector3.new(direction.X, 0, direction.Z).unit
					local folder2 = Instance.new("Folder", _WorldOrigin)
					Util.Debris:AddItem(folder2, 10)
					local v3 = {}
					local now = 0

					for i = 1, snowballAmount do
						local v4 = data.SnowballData[i]

						if not (v4 and v4.Proxy) then
							continue
						end

						local proxy2 = v4.Proxy
						local speed = v4.Speed
						local upwardBoost = data.UpwardBoost
						local forwardBoost = v4.ForwardBoost
						local clone8 = x_Tr.MiniGlacier:Clone()
						clone8.CFrame = proxy2.CFrame
						clone8.Size = v4.Size
						table.insert(v3, clone8)
						local horizontalAngle = v4.horizontalAngle
						local verticalAngle = v4.verticalAngle
						local velocity = (CFrame.new(cFrame.Position, cFrame.Position + unit) * CFrame.Angles(
							verticalAngle,
							0,
							0
						) * CFrame.Angles(0, horizontalAngle, 0)).LookVector * (forwardBoost * speed) + Vector3.new(
							0,
							upwardBoost,
							0
						)
						local bodyVelocity2 = Instance.new("BodyVelocity")
						bodyVelocity2.MaxForce = createVector(1, 1, 1) * 1e999
						bodyVelocity2.Velocity = velocity
						Util.SetParentOverrideWithColor(bodyVelocity2, clone8, player, "YetiFruitVFXColor")
						Util.SetParentOverrideWithColor(clone8, folder2, player, "YetiFruitVFXColor")
						local v7 = v4
						task.spawn(function()
							emitAll(clone8.Ring)
							task.wait(v7.deletionTimer)
							bodyVelocity2:Destroy()
						end)
						local v10 = clone8
						task.spawn(function()
							local v11 = false

							while proxy2 do
								task.wait()

								if proxy2:IsDescendantOf(workspace) then
									if proxy2:GetAttribute("Exploding") and not v11 then
										v11 = true
										v10.CFrame = proxy2:GetAttribute("Exploding")
										Util.Sound:Play(
											"YETI_SnowballImpact_LargeHeavy_0" .. tostring(math.random(1, 6)) .. "_V2",
											v10.Position
										)
										v10.EnableSmoke.Enabled = false
										v10.Ring.Rings.Enabled = false
										v10.Ring.Wind.Enabled = false
										v10.Anchored = true
										v10.Transparency = 1
										emitAll(v10.Break)
										v10.Transparency = 1

										if tick() - now > 0.016666666666666666 then
											now = tick()
											Util.Sound:Play("iceshatter", v10.Position)
										end

										local ray = Util.Ray
										local v12 = v10.Position + createVector(0, 2, 0)
										local v13 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
										local v14, v15, v16 = ray(v12, createVector(-0, -40, -0), v13, false)

										if v14 ~= nil then
											local alignCFrame = Util.Misc.AlignCFrame(CFrame.new(v15, v15 + v16), v16)
											local clone9 = x_Tr.snowpile:Clone()
											clone9.CFrame = alignCFrame
											Util.SetParentOverrideWithColor(
												clone9,
												_WorldOrigin,
												player,
												"YetiFruitVFXColor"
											)
											emitAll(clone9)
											Util.Debris:AddItem(clone9, 3.5)
										end
									end
								else
									if not v10 then
										break
									end

									v10:Destroy()
									break
								end
							end
						end)
					end

					break
				end
			else
				if not folder then
					break
				end

				folder:Destroy()
				break
			end
		end

		if folder then
			Util.Debris:AddItem(folder, 2.5)
		end
	end
end