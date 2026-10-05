local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local FX = require(game.ReplicatedStorage.FX)
local M1 = FX:WaitForChild("Gas").M1

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { map }
local v = {
	TweenInfo.new(1.0666666666666667, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
}

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone.Parent = p2 or _WorldOrigin
		clone.PrimaryPart.CFrame = cFrame
	else
		clone.CFrame = cFrame
		clone.Parent = p2 or _WorldOrigin
	end

	return clone
end

return function(player)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local index = player.Index
	local cFrame = player.CFrame

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 800 then
		return
	end

	humanoidRootPart:SetAttribute("LastGasSlash", tick())

	if index ~= 0 then
		local clone = _WorldOrigin:FindFirstChild(character.Name .. "GasBlade")

		if not clone then
			local cFrame2 = humanoidRootPart.CFrame
			local gasBlade = M1.GasBlade
			local v2 = character.Name .. "GasBlade"
			clone = gasBlade:Clone()
			clone.Name = v2 or clone.Name

			if gasBlade:IsA("Model") then
				clone.Parent = _WorldOrigin
				clone.PrimaryPart.CFrame = cFrame2
			else
				clone.CFrame = cFrame2
				clone.Parent = _WorldOrigin
			end

			clone.Handle.Part0 = character.RightHand
			local cFrame3 = clone.Sword.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(1.57, 0, 1.57)
			local appear = M1.Appear
			local clone2 = appear:Clone()
			clone2.Name = clone2.Name

			if appear:IsA("Model") then
				clone2.Parent = _WorldOrigin
				clone2.PrimaryPart.CFrame = cFrame3
			else
				clone2.CFrame = cFrame3
				clone2.Parent = _WorldOrigin
			end

			Debris:AddItem(clone2, 1)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			clone.AnimationController:LoadAnimation(clone.Idle):Play()
		end

		if index == 1 then
			Sound:Play("BF_GASFRUIT_UNTR_M1_BasicSlash_1And2_0" .. tostring(math.random(2, 5)), humanoidRootPart)
			task.wait(0.1)
			local cFrame2 = cFrame * CFrame.new(0, 0, -8) * CFrame.Angles(0, 3.14, 0)
			local purpleSlash = M1.PurpleSlash
			local clone2 = purpleSlash:Clone()
			clone2.Name = clone2.Name

			if purpleSlash:IsA("Model") then
				clone2.Parent = _WorldOrigin
				clone2.PrimaryPart.CFrame = cFrame2
			else
				clone2.CFrame = cFrame2
				clone2.Parent = _WorldOrigin
			end

			Debris:AddItem(clone2, 2)
			task.wait()

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter.Name ~= "Slash" then
					local lifetime = emitter.Lifetime
					emitter.Lifetime = NumberRange.new(lifetime.Min * 0.8, lifetime.Max * 0.8)
					local speed = emitter.Speed
					emitter.Speed = NumberRange.new(speed.Min * 1.25, speed.Max * 1.25)
				end

				if emitter:GetAttribute("EmitDelay") and emitter:GetAttribute("EmitDelay") ~= 0 then
					local v3 = emitter
					task.delay(emitter:GetAttribute("EmitDelay"), function()
						v3:Emit(v3:GetAttribute("EmitCount"))
					end)
				else
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		elseif index == 2 then
			local cFrame2 = cFrame * CFrame.new(0, 1, -10) * CFrame.Angles(0, 3.14, 1.57)
			local purpleSlash = M1.PurpleSlash
			local clone2 = purpleSlash:Clone()
			clone2.Name = clone2.Name

			if purpleSlash:IsA("Model") then
				clone2.Parent = _WorldOrigin
				clone2.PrimaryPart.CFrame = cFrame2
			else
				clone2.CFrame = cFrame2
				clone2.Parent = _WorldOrigin
			end

			Debris:AddItem(clone2, 2)
			Sound:Play("BF_GASFRUIT_UNTR_M1_BasicSlash_1And2_01", humanoidRootPart)
			task.wait()

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter.Name == "Slash" then
					emitter.Rotation = NumberRange.new(0)
				else
					local lifetime = emitter.Lifetime
					emitter.Lifetime = NumberRange.new(lifetime.Min * 0.8, lifetime.Max * 0.8)
					local speed = emitter.Speed
					emitter.Speed = NumberRange.new(speed.Min * 1.25, speed.Max * 1.25)
					ScaleParticle({
						Emitter = emitter,
						Scale = 0.85,
						Time = 0.05,
						EasingStyle = Enum.EasingStyle.Linear,
						EasingDirection = Enum.EasingDirection.Out
					})
				end

				if emitter:GetAttribute("EmitDelay") and emitter:GetAttribute("EmitDelay") ~= 0 then
					local v3 = emitter
					task.delay(emitter:GetAttribute("EmitDelay"), function()
						v3:Emit(v3:GetAttribute("EmitCount"))
					end)
				else
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local v3 = {
				"rbxassetid://12558376366",
				"rbxassetid://12558376101",
				"rbxassetid://12558375916",
				"rbxassetid://12558375736",
				"rbxassetid://12558375599",
				"rbxassetid://12558375321",
				"rbxassetid://12558375128",
				"rbxassetid://12558374890",
				"rbxassetid://12558374679"
			}
			local cFrame3 = cFrame * CFrame.new(0, 1, -10) * CFrame.Angles(
				0,
				1.57,
				(math.rad((math.random(-180, 180))))
			)
			local spiral = M1.spiral
			local clone3 = spiral:Clone()
			clone3.Name = clone3.Name

			if spiral:IsA("Model") then
				clone3.Parent = _WorldOrigin
				clone3.PrimaryPart.CFrame = cFrame3
			else
				clone3.CFrame = cFrame3
				clone3.Parent = _WorldOrigin
			end

			TweenService:Create(clone3.Mesh, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = createVector(0.135, 0.135, 0.0165)
			}):Play()
			TweenService:Create(clone3.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 0.75
			}):Play()
			task.spawn(function()
				for i = 1, #v3 do
					local decal = clone3:FindFirstChild("Decal")
					decal.Texture = v3[i]
					task.wait(0.04)
				end

				clone3:Destroy()
			end)
			local ray = Ray.new((cFrame * CFrame.new(0, 0, -29)).Position, createVector(0, -5, 0))
			local part, _, _ = workspace:FindPartOnRayWithWhitelist(ray, { map })

			if part then
				for i = 1, 2 do
					local cFrame4 = cFrame * CFrame.new(0, i == 1 and -2.75 or -2.85, -26) * CFrame.Angles(0, 0, 0)
					local groundSlashPurple = i == 1 and M1.GroundSlashPurple or M1.Burn
					local clone4 = groundSlashPurple:Clone()
					clone4.Name = clone4.Name

					if groundSlashPurple:IsA("Model") then
						clone4.Parent = _WorldOrigin
						clone4.PrimaryPart.CFrame = cFrame4
					else
						clone4.CFrame = cFrame4
						clone4.Parent = _WorldOrigin
					end

					Debris:AddItem(clone4, 2)

					if i == 1 then
						for _, emitter in pairs(clone4:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if emitter:GetAttribute("EmitDelay") then
								local v7 = emitter
								task.delay(emitter:GetAttribute("EmitDelay"), function()
									v7:Emit(v7:GetAttribute("EmitCount"))
								end)
							else
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						TweenService:Create(
							clone4.tex,
							TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					else
						local v7 = clone4
						task.delay(0.1, function()
							TweenService:Create(v7.tex, v[1], {
								Transparency = 1
							}):Play()
						end)
					end
				end
			end
		elseif index == 3 then
			Sound:Play("BF_GASFRUIT_UNTR_M1_MultiSlash_3And4_0" .. tostring(math.random(1, 5)), humanoidRootPart)
			task.wait(0.15)
			local ray = Ray.new((cFrame * CFrame.new(0, 0, -21)).Position, createVector(0, -5, 0))
			local part, _, _ = workspace:FindPartOnRayWithWhitelist(ray, { map })

			if part then
				local cFrame2 = cFrame * CFrame.new(0, -2.5, -23) * CFrame.Angles(0, 1.57, 0)
				local dustTrail = M1.DustTrail
				local clone2 = dustTrail:Clone()
				clone2.Name = clone2.Name

				if dustTrail:IsA("Model") then
					clone2.Parent = _WorldOrigin
					clone2.PrimaryPart.CFrame = cFrame2
				else
					clone2.CFrame = cFrame2
					clone2.Parent = _WorldOrigin
				end

				Debris:AddItem(clone2, 2)

				for _, child in pairs(clone2:GetChildren()) do
					local lifetime = child.Lifetime
					child.Lifetime = NumberRange.new(lifetime.Min * 1.25, lifetime.Max * 1.25)
					local speed = child.Speed
					child.Speed = NumberRange.new(speed.Min * 0.8, speed.Max * 0.8)
					child.Color = ColorSequence.new(part.Color)
					child:Emit(child:GetAttribute("EmitCount"))
				end
			end

			local cFrame3 = cFrame * CFrame.new(0, 7, -23) * CFrame.Angles(0, 1.57, 0)
			local cutTrail = M1.CutTrail
			local clone2 = cutTrail:Clone()
			clone2.Name = clone2.Name

			if cutTrail:IsA("Model") then
				clone2.Parent = _WorldOrigin
				clone2.PrimaryPart.CFrame = cFrame3
			else
				clone2.CFrame = cFrame3
				clone2.Parent = _WorldOrigin
			end

			Debris:AddItem(clone2, 2)
			clone2.Slash1:Emit(1)
			task.delay(0.2, function()
				for _, child in pairs(clone2:GetChildren()) do
					child.Enabled = false
				end
			end)

			for i = 1, 8 do
				if i % 2 ~= 0 then
					local cFrame2 = cFrame * CFrame.new(math.random(-5, 5), 3, math.random(-30, -20)) * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					local purpleSlash = M1.PurpleSlash
					local clone3 = purpleSlash:Clone()
					clone3.Name = clone3.Name

					if purpleSlash:IsA("Model") then
						clone3.Parent = _WorldOrigin
						clone3.PrimaryPart.CFrame = cFrame2
					else
						clone3.CFrame = cFrame2
						clone3.Parent = _WorldOrigin
					end

					Debris:AddItem(clone3, 2)
					clone3.Cut.Position = Vector3.new()

					for _, child in pairs(clone3.Cut:GetChildren()) do
						if not (child.Name == "Cut" or child.Name == "minicut") then
							continue
						end

						local lifetime = child.Lifetime
						local v5 = child.Name == "minicut" and 0.75 or 0.65
						child.Lifetime = NumberRange.new(lifetime.Min * v5, lifetime.Max * v5)
						local speed = child.Speed
						child.Speed = NumberRange.new(speed.Min * 0.85, speed.Max * 0.85)

						if child.Name == "Cut" then
							child.Squash = NumberSequence.new({
								NumberSequenceKeypoint.new(0, -0.65),
								NumberSequenceKeypoint.new(1, 3)
							})
						end

						ScaleParticle({
							Emitter = child,
							Scale = 0.5,
							Time = 0.05,
							EasingStyle = Enum.EasingStyle.Linear,
							EasingDirection = Enum.EasingDirection.Out
						})
						child:Emit(child:GetAttribute("EmitCount"))
					end

					local v5 = cFrame * CFrame.new(math.random(-10, 10), 0, math.random(-35, -10))
					local cframe = CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
					local ray2 = Ray.new(v5.Position, createVector(0, -10, 0))
					local part2, _, _ = workspace:FindPartOnRayWithWhitelist(ray2, { map })

					if part2 then
						for i2 = 1, 2 do
							local cFrame4 = v5 * CFrame.new(0, i2 == 1 and -2.75 or -2.85, 0) * cframe
							local groundCutBlue = i2 == 1 and M1.GroundCutBlue or M1.CutBurn
							local clone4 = groundCutBlue:Clone()
							clone4.Name = clone4.Name

							if groundCutBlue:IsA("Model") then
								clone4.Parent = _WorldOrigin
								clone4.PrimaryPart.CFrame = cFrame4
							else
								clone4.CFrame = cFrame4
								clone4.Parent = _WorldOrigin
							end

							Debris:AddItem(clone4, 2)
							clone4.Size *= 0.8

							for _, emitter in pairs(clone4:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								if emitter:GetAttribute("EmitDelay") then
									local v8 = emitter
									task.delay(emitter:GetAttribute("EmitDelay"), function()
										v8:Emit(v8:GetAttribute("EmitCount"))
									end)
								else
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end

							if i2 == 1 then
								TweenService:Create(
									clone4.tex,
									TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
									{
										Color3 = Color3.new(1, 0.388235, 0.988235)
									}
								):Play()
								TweenService:Create(
									clone4.tex,
									TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							else
								local v8 = clone4
								task.delay(0.1, function()
									TweenService:Create(v8.tex, v[1], {
										Transparency = 1
									}):Play()
								end)
							end
						end
					end
				end

				local cFrame5 = cFrame * CFrame.new(math.random(-3, 3), 4, math.random(-33, -15)) * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				)
				local cutPart = M1.CutPart
				local clone3 = cutPart:Clone()
				clone3.Name = clone3.Name

				if cutPart:IsA("Model") then
					clone3.Parent = _WorldOrigin
					clone3.PrimaryPart.CFrame = cFrame5
				else
					clone3.CFrame = cFrame5
					clone3.Parent = _WorldOrigin
				end

				Debris:AddItem(clone3, 0.45)
				TweenService:Create(clone3, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Color = Color3.new(0, 0, 0)
				}):Play()
				task.wait(0.04)
				TweenService:Create(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Size = Vector3.new(clone3.Size.X, 0, 0)
				}):Play()
			end
		elseif index == 4 then
			local cFrame2 = cFrame * CFrame.new(0, 1.5, -18)
			local multiCutsPart = M1.multiCutsPart
			local clone2 = multiCutsPart:Clone()
			clone2.Name = clone2.Name

			if multiCutsPart:IsA("Model") then
				clone2.Parent = _WorldOrigin
				clone2.PrimaryPart.CFrame = cFrame2
			else
				clone2.CFrame = cFrame2
				clone2.Parent = _WorldOrigin
			end

			Debris:AddItem(clone2, 3)
			Sound:Play("BF_GASFRUIT_UNTR_M1_MultiSlash_3And4_0" .. tostring(math.random(1, 5)), humanoidRootPart)

			for i = 1, 12 do
				local v3 = CFrame.new(humanoidRootPart.Position) * (cFrame - cFrame.p)
				clone2.CFrame = v3 * CFrame.new(0, 1.5, -18)

				if math.random(1, 5) ~= 5 then
					local cFrame3 = v3 * CFrame.new(0, 0, -13) * CFrame.new(math.random(-7, 7), 3, math.random(-10, 5)) * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					local purpleSlash = M1.PurpleSlash
					local clone3 = purpleSlash:Clone()
					clone3.Name = clone3.Name

					if purpleSlash:IsA("Model") then
						clone3.Parent = _WorldOrigin
						clone3.PrimaryPart.CFrame = cFrame3
					else
						clone3.CFrame = cFrame3
						clone3.Parent = _WorldOrigin
					end

					Debris:AddItem(clone3, 2)
					clone3.Cut.Position = Vector3.new()

					for _, child in pairs(clone3.Cut:GetChildren()) do
						if not (child.Name == "Cut" or child.Name == "minicut") then
							continue
						end

						local lifetime = child.Lifetime
						local v5 = child.Name == "minicut" and 0.75 or 0.65
						child.Lifetime = NumberRange.new(lifetime.Min * v5, lifetime.Max * v5)
						local speed = child.Speed
						child.Speed = NumberRange.new(speed.Min * 0.85, speed.Max * 0.85)

						if child.Name == "Cut" then
							child.Squash = NumberSequence.new({
								NumberSequenceKeypoint.new(0, -0.3),
								NumberSequenceKeypoint.new(1, 3)
							})
						end

						ScaleParticle({
							Emitter = child,
							Scale = 0.4,
							Time = 0.05,
							EasingStyle = Enum.EasingStyle.Linear,
							EasingDirection = Enum.EasingDirection.Out
						})
						child:Emit(child:GetAttribute("EmitCount"))
					end
				end

				if i % 2 == 0 then
					local v4 = v3 * CFrame.new(0, 0, -13) * CFrame.new(math.random(-10, 10), 0, math.random(-5, -5))
					local cframe = CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
					local ray = Ray.new(v4.Position, createVector(0, -10, 0))
					local part, _, _ = workspace:FindPartOnRayWithWhitelist(ray, { map })

					if part then
						local cFrame3 = v4 * CFrame.new(0, -2.85, 0) * cframe
						local groundCutBlue2 = M1.GroundCutBlue2
						local clone3 = groundCutBlue2:Clone()
						clone3.Name = clone3.Name

						if groundCutBlue2:IsA("Model") then
							clone3.Parent = _WorldOrigin
							clone3.PrimaryPart.CFrame = cFrame3
						else
							clone3.CFrame = cFrame3
							clone3.Parent = _WorldOrigin
						end

						Debris:AddItem(clone3, 2)

						for _, emitter in pairs(clone3:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if emitter:GetAttribute("EmitDelay") then
								local v7 = emitter
								task.delay(emitter:GetAttribute("EmitDelay"), function()
									v7:Emit(v7:GetAttribute("EmitCount"))
								end)
							else
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						for _, emitter in pairs(clone3:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if emitter:GetAttribute("EmitDelay") then
								local v7 = emitter
								task.delay(emitter:GetAttribute("EmitDelay"), function()
									v7:Emit(v7:GetAttribute("EmitCount"))
								end)
							else
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						TweenService:Create(
							clone3.tex,
							TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Color3 = Color3.fromRGB(241, 47, 255)
							}
						):Play()
						TweenService:Create(
							clone3.tex,
							TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end
				end

				task.wait(0.05)
			end

			task.wait(0.1)

			if clone2:FindFirstChild("Attachment") then
				for _, child in pairs(clone2.Attachment:GetChildren()) do
					child.Enabled = false
				end
			end
		elseif index == 5 then
			for _, child in pairs(clone.MiddleFlame.Charge:GetChildren()) do
				local lifetime = child.Lifetime
				child.Lifetime = NumberRange.new(lifetime.Min * 0.75, lifetime.Max * 0.75)
				local speed = child.Speed
				child.Speed = NumberRange.new(speed.Min * 1.3333333333333333, speed.Max * 1.3333333333333333)
				child:Emit(child:GetAttribute("EmitCount"))
			end

			Sound:Play("BF_GASFRUIT_UNTR_M1_ExplosiveLunge_0" .. tostring(math.random(1, 4)), humanoidRootPart)
			local ray = Ray.new(humanoidRootPart.Position, createVector(0, -10, 0))
			local part, v3, _ = workspace:FindPartOnRayWithWhitelist(ray, { map })

			if part then
				local cFrame2 = cFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, 3.141592653589793, 0)
				local dust = M1.Dust
				local clone2 = dust:Clone()
				clone2.Name = clone2.Name

				if dust:IsA("Model") then
					clone2.Parent = _WorldOrigin
					clone2.PrimaryPart.CFrame = cFrame2
				else
					clone2.CFrame = cFrame2
					clone2.Parent = _WorldOrigin
				end

				Debris:AddItem(clone2, 1)

				for _, child in pairs(clone2.Attachment:GetChildren()) do
					child.Color = ColorSequence.new(part.Color)
					local speed = child.Speed
					child.Speed = NumberRange.new(speed.Min * 1.5, speed.Max * 1.5)
					child:Emit(child:GetAttribute("EmitCount"))
				end

				task.delay(0.333, function()
					local cFrame3 = humanoidRootPart.CFrame * CFrame.new(
						0,
						-math.abs(v3.Y - humanoidRootPart.Position.Y) + 0.05,
						-21
					) * CFrame.Angles(0, 0, 0)
					local burn = M1.Burn
					local clone3 = burn:Clone()
					clone3.Name = clone3.Name

					if burn:IsA("Model") then
						clone3.Parent = _WorldOrigin
						clone3.PrimaryPart.CFrame = cFrame3
					else
						clone3.CFrame = cFrame3
						clone3.Parent = _WorldOrigin
					end

					clone3.Size = createVector(24.005, 0.001, 56.98)
					clone3.tex.Texture = "rbxassetid://12897622646"
					Debris:AddItem(clone3, 3)
					task.delay(1, function()
						TweenService:Create(clone3.tex, v[3], {
							Transparency = 1
						}):Play()
					end)
				end)
			end

			task.wait(0.333)

			for _, child in pairs(clone.MiddleFlame.Burst:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end
	end

	task.delay(1.1, function()
		local child = tick() - humanoidRootPart:GetAttribute("LastGasSlash") > 1.09 and _WorldOrigin:FindFirstChild(character.Name .. "GasBlade")

		if child then
			Sound:Play("BF_GASFRUIT_UNTR_M1_Despawn", child.Sword.Position)
			local cFrame2 = child.Sword.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(1.57, 0, 1.57)
			local appear = M1.Appear
			local clone = appear:Clone()
			clone.Name = clone.Name

			if appear:IsA("Model") then
				clone.Parent = _WorldOrigin
				clone.PrimaryPart.CFrame = cFrame2
			else
				clone.CFrame = cFrame2
				clone.Parent = _WorldOrigin
			end

			Debris:AddItem(clone, 1)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			child.Name = "DESTROYING"

			for _, part in pairs(child:GetChildren()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end

			for _, child2 in pairs(child.MiddleFlame.Attachment:GetChildren()) do
				child2.Enabled = false
				child2:Clear()
			end

			for _, child2 in pairs(child.MiddleFlame.Charge:GetChildren()) do
				child2.Enabled = false
				child2:Clear()
			end

			for _, child2 in pairs(child.MiddleFlame.Handle:GetChildren()) do
				child2.Enabled = false
				child2:Clear()
			end

			Debris:AddItem(child, 1.5)
		end
	end)
end