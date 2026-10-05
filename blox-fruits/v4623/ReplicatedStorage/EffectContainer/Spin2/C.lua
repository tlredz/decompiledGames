local _ = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local script2 = script
local _WorldOrigin = workspace._WorldOrigin

local function StartProjectileSlash(p, folder, duration, magnitude, final)
	local clone = script2.Phase1.ProjectileSlash:Clone()
	clone.CFrame = p * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
	clone.Parent = folder
	local clone2 = script2.Phase1.StartImpact:Clone()
	clone2.CFrame = clone.CFrame * CFrame.new(0, 0, -5)
	clone2.Parent = folder

	for _, emitter in pairs(clone2:GetDescendants()) do
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

	local descendants = clone:GetDescendants()

	for _, beam in pairs(descendants) do
		if beam:IsA("Beam") then
			beam.Enabled = true
		end
	end

	Util.Sound:Play("PawCannonShoot2", clone, 10)
	local v = math.rad((math.random(-3, 3)))
	local v2 = math.rad((math.random(-3, 3)))
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			CFrame = clone.CFrame * CFrame.new(0, 0, -magnitude) * CFrame.Angles(v, 0, v2)
		}
	)
	tween:Play()
	tween.Completed:Wait()

	for _, effect in pairs(descendants) do
		if effect:IsA("Beam") then
			local v3 = effect
			task.spawn(function()
				local tween2 = TweenService:Create(
					v3,
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v3:Destroy()
			end)
		elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	local clone3 = script2.Phase1.ProjectileImpact:Clone()
	clone3.CFrame = clone.CFrame
	clone3.Parent = folder

	for _, emitter in pairs(clone3:GetDescendants()) do
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

	Util.Sound:Play("AirBurst", clone.CFrame, 20, final and 1 or 1.4, 0.425)
	local clone4 = script2.Phase1.Explosion:Clone()
	clone4.CFrame = clone.CFrame
	clone4.Parent = folder

	for _, emitter in pairs(clone4:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v3 = emitter
		task.spawn(function()
			if v3:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v3:GetAttribute("EmitDelay"))
			end

			v3:Emit(v3:GetAttribute("EmitCount") * (final and 1 or 0.2))
		end)
	end

	if final then
		for _ = 1, 5 do
			task.spawn(function()
				local clone5 = script2.Phase1.ProjectileSlash:Clone()
				clone5.CFrame = clone4.CFrame * CFrame.Angles(
					math.rad((math.random(-360, 360))),
					math.rad((math.random(-360, 360))),
					(math.rad((math.random(-360, 360))))
				)
				clone5.Parent = folder

				for _, beam in pairs(clone5:GetDescendants()) do
					if beam:IsA("Beam") then
						beam.Enabled = true
					end
				end

				local tween2 = TweenService:Create(
					clone5,
					TweenInfo.new(duration * 1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						CFrame = clone5.CFrame * CFrame.new(0, 0, -magnitude / 2.5) * CFrame.Angles(v, 0, v2)
					}
				)
				tween2:Play()
				task.spawn(function()
					task.wait(duration / 1.5)

					for _, effect in pairs(clone5:GetDescendants()) do
						if effect:IsA("Beam") then
							local v3 = effect
							task.spawn(function()
								local tween3 = TweenService:Create(
									v3,
									TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Width0 = 0,
										Width1 = 0
									}
								)
								tween3:Play()
								tween3.Completed:Wait()
								v3:Destroy()
							end)
						elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
				tween2.Completed:Wait()
			end)
		end
	end
end

return function(data)
	local root = data.Root
	local timestamp = data.Timestamp

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	if data.Start then
		local cFrame = root.CFrame
		local v = 0.5 - (Util.MasterClock:GetTime() - timestamp)
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, v + 0.5)
		task.spawn(function()
			local clone = script2.Phase1.Tornado:Clone()
			clone.CFrame = cFrame
			clone.Parent = folder
			clone.Weld.Part0 = root
			local clone2 = script2.Phase1.Tornado2:Clone()
			clone2.CFrame = cFrame
			clone2.Parent = folder
			clone2.Weld.Part0 = root

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local descendantsByDescendant = {}
			local weldsByWeld = {}

			for _, weld in pairs(clone2:GetChildren()) do
				local v2 = 1

				if not weld:IsA("Weld") then
					if weld.Name == "SpinA" then
						v2 = 0.45
					elseif weld.Name == "SpinB" then
						v2 = 0.6
					elseif weld.Name == "SpinC" then
						v2 = 0.5
					else
						v2 = v2
					end
				end

				if weld:IsA("Weld") and weld.Name ~= "Weld" then
					weldsByWeld[weld] = weld
					weld.C0 = weld.Part0.CFrame:ToObjectSpace(weld.Part1.CFrame) * CFrame.Angles(
						0,
						math.rad((math.random(-90, 90))),
						0
					)
				end

				weld:SetAttribute("Tweening", false)

				for _, descendant in pairs(weld:GetDescendants()) do
					if descendant:IsA("Beam") then
						descendantsByDescendant[descendant] = descendant
						descendant.CurveSize0 *= v2
						descendant.CurveSize1 *= v2
						descendant.Width0 *= v2
						descendant.Width1 *= v2
					elseif descendant:IsA("Attachment") then
						descendant.Position = Vector3.new(
							descendant.Position.X * v2,
							descendant.Position.Y * v2,
							descendant.Position.Z * v2
						)
					end
				end
			end

			local v2 = Util.Sound:Play("SpinningWithWind", root)
			local lastTime = tick()

			while true do
				if v <= tick() - lastTime then
					break
				end

				for _, v4 in pairs(weldsByWeld) do
					if v4:GetAttribute("Tweening") ~= false then
						continue
					end

					local v5 = v4
					task.spawn(function()
						v5:SetAttribute("Tweening", true)
						local v6 = math.random(150, 170)
						local v7 = math.random(5, 15) / 200
						local tween = TweenService:Create(
							v5,
							TweenInfo.new(v7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								C0 = v5.Part0.CFrame:ToObjectSpace(v5.Part1.CFrame) * CFrame.Angles(0, math.rad(v6), 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v5:SetAttribute("Tweening", false)
					end)
				end

				RunService.Heartbeat:Wait()

				if v <= tick() - lastTime then
					break
				end
			end

			Util.Sound:FadeOut(v2, 0.33)

			for _, v3 in pairs(descendantsByDescendant) do
				TweenService:Create(v3, TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	else
		local magnitude = (data.Position - root.Position).Magnitude
		local v = math.max(0.1, magnitude / 425 - (Util.MasterClock:GetTime() - timestamp))
		local final = data.Final
		local v2 = CFrame.new(root.Position, data.Position) * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 3)
		StartProjectileSlash(v2, folder, v, magnitude, final)
	end
end