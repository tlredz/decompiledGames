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
local x_Un = FX:WaitForChild("YetiEffects").X_Un

local function emitAll(folder)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect:GetAttribute("EmitDuration")
			local v2 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v) and v ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v3 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v3)
					task.wait(v)

					if v3 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		else
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect
			local v3 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v:Emit(emitCount or 0)

				if tonumber(v3) and v3 ~= 0 then
					v.Enabled = true

					if not v:GetAttribute("pr3") then
						v:SetAttribute("pr3", 0)
					end

					local v4 = (v:GetAttribute("pr3") + 1) % 1000
					v:SetAttribute("pr3", v4)
					task.wait(v3)

					if v4 == v:GetAttribute("pr3") then
						v.Enabled = false
					end
				end
			end)
		end
	end
end

return function(data)
	local player = data.player
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1800 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local clone = x_Un.Snowball:Clone()
		clone.Massless = true
		local clone2 = x_Un.SnowWeld:Clone()
		local root = data.Root
		Util.SetParentOverrideWithColor(clone2, clone, player, "YetiFruitVFXColor")
		clone2.Part0 = root.Parent:FindFirstChild("RightHand")
		clone2.Part1 = clone
		clone2.Enabled = false
		clone.Name = "SnowBall_" .. root.Parent.Name
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		task.spawn(function()
			while clone2.Part1 and clone2.Part0 and clone2:IsDescendantOf(workspace) do
				clone2.Part1.CFrame = clone2.Part0.CFrame * clone2.C0
				task.wait()
			end
		end)
		local v = Util.Sound:Play("YETI_UNTSFM_X_GlacialToss_Hold_01", root)
		local thread = task.spawn(function()
			task.wait(0.1)
			Util.Sound:Play("YETI_UNTSFM_X_GlacialToss_RockAppear_01_V2", clone)
			emitAll(clone.HandCharge)

			if v then
				TweenService:Create(v, TweenInfo.new(0.5), {
					Volume = 0.85
				}):Play()
			end

			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(7.759, 7.759, 7.759)
			}):Play()
			emitAll(clone.ChargeBack)
			emitAll(clone.Charge)

			for _, emitter in pairs(clone.Hold:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		end)

		local function fn()
			if v then
				Util.Sound:FadeOut(v, 0.2)
			end

			task.wait(1)

			if clone.Name ~= "DESTROYING" then
				clone.Name = "DESTROYING"
				task.cancel(thread)
				clone:Destroy()
			end

			task.wait(1)
			v:Destroy()
		end

		if data.ProxyEnd then
			data.ProxyEnd.Destroying:Once(fn)
			data.ProxyEnd.AncestryChanged:Once(fn)
		elseif data.Proxy and data.Proxy.Parent then
			data.Proxy.Destroying:Once(fn)
			data.Proxy.AncestryChanged:Once(fn)
		end

		task.delay(30, fn)

		if data.HoldingProxy then
			if data.HoldingProxy.Value then
				data.HoldingProxy.Changed:Once(fn)
			else
				task.spawn(fn)
			end
		end
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
				local clone = script.LTN:Clone()
				Util.SetParentOverrideWithColor(clone, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone, 2)
				TweenService:Create(clone, TweenInfo.new(0.01), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(152, 228, 255),
						player,
						"YetiFruitVFXColor"
					),
					Brightness = 0.4,
					Contrast = 1,
					Saturation = 0.2
				}):Play()
				task.wait(0.01)
				TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
						FieldOfView = 93
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

		local folder = _WorldOrigin:FindFirstChild("SnowBall_" .. root.Parent.Name)

		if not folder then
			return
		end

		folder.Name = "DESTROYING"
		folder.Massless = false
		folder:WaitForChild("SnowWeld", 5):Destroy()
		folder.CFrame = root.CFrame * CFrame.new(0, 4, -4)

		for _, emitter in pairs(folder.Hold:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Destroy()
			end
		end

		Util.Sound:Play("YETI_UNTSFM_X_GlacialToss_Fire_01")
		emitAll(folder.Throw)
		folder.FallingSnow2.Enabled = true
		folder.FallingSnow.Enabled = true
		folder.Snowtrail.Enabled = true
		folder.Snowtrail2.Enabled = true
		task.spawn(function()
			for _ = 1, 15 do
				if folder.Anchored ~= false then
					continue
				end

				task.wait(0.15)
				emitAll(folder.Ring)
			end
		end)
		local clone = x_Un.Shock.Shock:Clone()
		local clone2 = x_Un.Shock.Air1:Clone()
		local clone3 = x_Un.Shock.Air2:Clone()
		Util.SetParentOverrideWithColor(clone, root, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone2, root, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone3, root, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 2.5)
		Util.Debris:AddItem(clone2, 2.5)
		Util.Debris:AddItem(clone3, 2.5)
		task.spawn(function()
			task.wait(0.105)
			emitAll(clone)
			emitAll(clone2)
			emitAll(clone3)
		end)
		task.spawn(function()
			task.wait(0.125)
			local lookVector = root.CFrame.LookVector
			local v = root.Position + lookVector * 1
			local ray = Util.Ray
			local v2 = { workspace.Characters, workspace.Enemies }
			local v3, _, v4 = ray(v, createVector(0, -10, 0), v2)

			if v3 then
				local _ = v4 * 0.1
				local _ = root.CFrame
				local clone4 = x_Un.Shock.Smoke:Clone()
				Util.SetParentOverrideWithColor(clone4, root, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone4, 3)
				emitAll(clone4)
				clone4.Smoke.Color = ColorSequence.new(v3.Color)
			end
		end)
		local _ = (mousePos - folder.Position).unit
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "YetiFruitVFXColor")
		folder.Anchored = false
		local cframe = CFrame.new(root.CFrame.p, mousePos)
		local range = data.Range
		local speed = data.Speed
		local bodyVelocity = Instance.new("BodyVelocity", folder)
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyVelocity.Velocity = cframe.LookVector * range * speed
		task.spawn(function()
			task.wait(0.25)
			bodyVelocity:Destroy()
		end)
		local lastTime = tick()
		local v = false

		while proxy and tick() - lastTime < lifetime do
			task.wait()

			if proxy:IsDescendantOf(workspace) then
				if proxy:GetAttribute("Exploding") then
					if v then
						break
					end

					local exploding = proxy:GetAttribute("Exploding")
					folder.Anchored = true
					folder.CFrame = exploding
					folder.Transparency = 1
					folder.FallingSnow.Enabled = false
					folder.FallingSnow2.Enabled = false
					Util.Debris:AddItem(folder, 3)
					task.spawn(function()
						local clone4 = x_Un.Bottom:Clone()
						local unit = folder.Velocity.Magnitude > 0.1 and folder.Velocity.Unit or folder.CFrame.LookVector
						local v2 = folder.Position - unit * 10
						local rayMap, v3, v4 = Util.RayMap(v2, unit * 40)

						if not rayMap then
							rayMap, v3, v4 = Util.RayMap(v2, createVector(-0, -40, -0))
						end

						if rayMap then
							clone4.CFrame = Util.Misc.AlignCFrame(CFrame.new(v3, v3 + unit), v4)
							Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "YetiFruitVFXColor")
							Util.Debris:AddItem(clone4, 2.5)
							emitAll(clone4)
						end
					end)
					emitAll(folder.Impact)

					for _, emitter in pairs(folder:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Enabled = false
						emitter.Rate = 0
					end

					Util.Sound:Play("YETI_UNTSFM_X_GlacialToss_Explosion_02", exploding.Position)
					local snowballAmount = data.SnowballAmount
					local direction = data.direction
					local upwardBoost = data.UpwardBoost
					local unit = Vector3.new(direction.X, 0, direction.Z).unit
					local folder2 = Instance.new("Folder", _WorldOrigin)
					Util.Debris:AddItem(folder2, 10)
					local v2 = {}
					local now = 0

					for i = 1, snowballAmount do
						local v3 = data.SnowballData[i]

						if not (v3 and v3.Proxy) then
							continue
						end

						local proxy2 = v3.Proxy
						local speed2 = v3.Speed
						local forwardBoost = v3.ForwardBoost
						local clone4 = x_Un.Snowballsmall:Clone()
						Util.SetParentOverrideWithColor(clone4, folder2, player, "YetiFruitVFXColor")
						clone4.CFrame = proxy2.CFrame
						clone4.Size = proxy2.Size
						table.insert(v2, clone4)
						local horizontalAngle = v3.horizontalAngle
						local verticalAngle = v3.verticalAngle
						local velocity = (CFrame.new(folder.Position, folder.Position + unit) * CFrame.Angles(
							verticalAngle,
							horizontalAngle,
							0
						)).LookVector * (forwardBoost * speed2) + Vector3.new(0, upwardBoost, 0)
						local bodyVelocity2 = Instance.new("BodyVelocity")
						bodyVelocity2.MaxForce = createVector(1, 1, 1) * 1e999
						bodyVelocity2.Velocity = velocity
						Util.SetParentOverrideWithColor(bodyVelocity2, clone4, player, "YetiFruitVFXColor")
						task.spawn(function()
							for i2 = 1, 7 do
								if clone4:FindFirstChild("EnableSmoke") == nil then
									break
								end

								clone4.EnableSmoke:Emit(5)
								task.wait(0.055)
							end
						end)
						local v6 = clone4
						local v7 = v3
						task.spawn(function()
							emitAll(v6.Ring)
							task.wait(v7.deletionTimer)
							bodyVelocity2:Destroy()
						end)
						local folder3 = clone4
						task.spawn(function()
							local v10 = false

							while proxy2 do
								task.wait()

								if proxy2:IsDescendantOf(workspace) then
									if proxy2:GetAttribute("Exploding") and not v10 then
										folder3.Anchored = true
										folder3.CFrame = proxy2:GetAttribute("Exploding")
										folder3.Transparency = 1
										Util.Sound:Play(
											"YETI_SnowballImpact_Small_0" .. tostring(math.random(1, 6)) .. "_V2",
											folder3.Position
										)
										emitAll(folder3)
										v10 = true

										for i2, emitter in pairs(folder3:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") then
												emitter.Enabled = false
											end
										end

										if tick() - now > 0.016666666666666666 then
											now = tick()
											Util.Sound:Play("Ice_snow", folder3.CFrame)
										end

										local ray = Util.Ray
										local v11 = folder3.Position + createVector(0, 2, 0)
										local v12 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
										local v13, v14, v15 = ray(v11, createVector(-0, -5, -0), v12, false)

										if v13 ~= nil then
											local alignCFrame = Util.Misc.AlignCFrame(CFrame.new(v14, v14 + v15), v15)
											local clone5 = x_Un.snowpile:Clone()
											clone5.CFrame = alignCFrame
											Util.SetParentOverrideWithColor(
												clone5,
												_WorldOrigin,
												player,
												"YetiFruitVFXColor"
											)
											emitAll(clone5)
											Util.Debris:AddItem(clone5, 3.5)
										end
									end
								else
									if not folder3 then
										break
									end

									folder3:Destroy()
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
			Util.Debris:AddItem(folder, 3)
		end
	end
end