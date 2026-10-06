local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")

function ver1(p)
	local clone = replicatedStorage.Chest.SwordEffect.Muramasa.slash:Clone()
	clone.CFrame = p.cf * CFrame.Angles(0, 0, 1.5707963267948966)
	clone.Parent = workspace.Effects
	clone.Mesh.Scale = Vector3.new()
	clone.Mesh.Offset = Vector3.new()
	clone.Attachment.Flames.Enabled = true
	clone.Attachment.rock.Enabled = true
	clone.Attachment1.SmokeEnd.Enabled = true
	clone.Attachment2.SmokeEnd.Enabled = true
	clone.Bottom.Color3 = Color3.fromRGB(2000, 565, 300)
	clone.Bottom.Transparency = -7
	clone.Top.Color3 = Color3.fromRGB(2000, 565, 300)
	clone.PointLight.Range = 0
	clone.PointLight.Brightness = 0
	TweenService:Create(clone.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Range = 20,
		Brightness = 1
	}):Play()
	_G.PU:Dust(clone, 3)
	TweenService:Create(clone.Bottom, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Color3 = Color3.fromRGB(2000, 365, 70)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.new(0, 0, -120)
	}):Play()
	task.spawn(function()
		TweenService:Create(clone.Mesh, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Scale = createVector(30, 0.001, 20.391)
		}):Play()
		TweenService:Create(clone.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Offset = createVector(0, 0, 18.5)
		}):Play()
	end)
	local v = {}
	task.spawn(function()
		PeodizService.HeartbeatWait({
			Time = 1,
			Tween = {
				EasingStyle = Enum.EasingStyle.Quad,
				EasingDirection = Enum.EasingDirection.Out
			}
		}, function(p2)
			local v2 = math.floor(p2 * 10)

			if v[math.floor(v2)] or math.floor(v2) == 10 then
				return
			end

			v[math.floor(v2)] = true

			if clone and clone:FindFirstChild("Attachment") then
				if clone.Attachment:FindFirstChild("Flames") then
					clone.Attachment.Flames:Emit(10)
				end

				if clone.Attachment:FindFirstChild("Specs") then
					clone.Attachment.Specs:Emit(math.random(3, 5))
				end

				if clone.Attachment:FindFirstChild("shard") then
					clone.Attachment.shard:Emit(2)
				end
			end
		end)
		task.delay(10, function()
			table.clear(v)
		end)
	end)
	task.spawn(function()
		wait(0.25)
		task.spawn(function()
			wait(0.065)

			if clone:FindFirstChild("Attachment") then
				if clone.Attachment:FindFirstChild("Flames") then
					clone.Attachment.Flames.Enabled = false
				end

				if clone.Attachment:FindFirstChild("rock") then
					clone.Attachment.rock.Enabled = false
				end
			end

			if clone:FindFirstChild("Attachment1") and clone.Attachment1:FindFirstChild("SmokeEnd") then
				clone.Attachment1.SmokeEnd.Enabled = false
			end

			if clone:FindFirstChild("Attachment2") and clone.Attachment2:FindFirstChild("SmokeEnd") then
				clone.Attachment2.SmokeEnd.Enabled = false
			end
		end)
		task.spawn(function()
			wait(0.1)

			if clone and clone:FindFirstChild("Animate") then
				local Animate = require(clone.Animate)
				Animate()
			end
		end)

		if clone:FindFirstChild("Bottom") then
			TweenService:Create(clone.Bottom, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end

		wait(0.125)

		if clone:FindFirstChild("PointLight") then
			TweenService:Create(
				clone.PointLight,
				TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Brightness = 0,
					Range = 20
				}
			):Play()
		end

		wait(0.2)
		local v2 = 0
		task.spawn(function()
			PeodizService.new({
				Time = 0.5,
				Tween = {
					EasingStyle = Enum.EasingStyle.Exponential,
					EasingDirection = Enum.EasingDirection.Out
				}
			}, function(p2)
				v2 = p2 * 1

				if clone:FindFirstChild("Trail") then
					clone.Trail.Transparency = NumberSequence.new(v2)
				end
			end)
		end)
	end)
end

function ver2(p)
	for i = 1, 3 do
		local v2 = i
		local v3 = p.cf * CFrame.Angles(0, math.rad(i * 22.5 + -45), 0)
		task.spawn(function()
			if v2 == 2 then
				local clone = replicatedStorage.Chest.SwordEffect.Muramasa.slash:Clone()
				clone.CFrame = v3 * CFrame.Angles(0, 0, 1.5707963267948966)
				clone.Parent = workspace.Effects
				clone.Mesh.Scale = Vector3.new()
				clone.Mesh.Offset = Vector3.new()
				clone.Attachment.Flames.Size = NumberSequence.new(15, 10)
				clone.Attachment1.SmokeEnd.Size = NumberSequence.new(15, 0)
				clone.Attachment2.SmokeEnd.Size = NumberSequence.new(15, 0)
				clone.Attachment.Flames.Enabled = true
				clone.Attachment.rock.Enabled = true
				clone.Attachment1.SmokeEnd.Enabled = true
				clone.Attachment2.SmokeEnd.Enabled = true
				clone.Bottom.Color3 = Color3.fromRGB(2000, 565, 300)
				clone.Bottom.Transparency = -7
				clone.Top.Color3 = Color3.fromRGB(2000, 565, 300)
				clone.PointLight.Range = 0
				clone.PointLight.Brightness = 0
				game.TweenService:Create(
					clone.PointLight,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Range = 27,
						Brightness = 1.5
					}
				):Play()
				_G.PU:Dust(clone, 3)
				local cFrameValue = Instance.new("CFrameValue")
				cFrameValue.Value = clone.CFrame
				local cFrameValue2 = Instance.new("CFrameValue")
				game.TweenService:Create(
					cFrameValue2,
					TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Value = CFrame.Angles(0, 0.08726646259971647, 0) * CFrame.new(0, 0, 0)
					}
				):Play()
				cFrameValue.Changed:Connect(function()
					clone.CFrame = cFrameValue.Value * cFrameValue2.Value
				end)
				game.TweenService:Create(
					clone.Bottom,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Color3 = Color3.fromRGB(2000, 365, 70)
					}
				):Play()
				game.TweenService:Create(
					cFrameValue,
					TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Value = clone.CFrame * CFrame.new(0, 0, -140)
					}
				):Play()
				task.spawn(function()
					game.TweenService:Create(
						clone.Mesh,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Scale = createVector(40, 0.001, 27.391)
						}
					):Play()
					game.TweenService:Create(
						clone.Mesh,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Offset = createVector(0, 0, 20.5)
						}
					):Play()
				end)
				local v4 = {}
				task.spawn(function()
					PeodizService.HeartbeatWait({
						Time = 1.25,
						Tween = {
							EasingStyle = Enum.EasingStyle.Quad,
							EasingDirection = Enum.EasingDirection.Out
						}
					}, function(p2)
						local v5 = math.floor(p2 * 10)

						if v4[math.floor(v5)] or math.floor(v5) == 10 then
							return
						end

						v4[math.floor(v5)] = true
						clone.Attachment.Flames:Emit(3)
						clone.Attachment.Specs:Emit(math.random(3, 5))
						clone.Attachment.shard:Emit(5)
					end)
					task.delay(10, function()
						table.clear(v4)
					end)
				end)
				task.spawn(function()
					wait(0.3)
					task.spawn(function()
						wait(0.075)

						if clone:FindFirstChild("Attachment") then
							if clone.Attachment:FindFirstChild("Flames") then
								clone.Attachment.Flames.Enabled = false
							end

							if clone.Attachment:FindFirstChild("rock") then
								clone.Attachment.rock.Enabled = false
							end
						end

						if clone:FindFirstChild("Attachment1") and clone.Attachment1:FindFirstChild("SmokeEnd") then
							clone.Attachment1.SmokeEnd.Enabled = false
						end

						if clone:FindFirstChild("Attachment2") and clone.Attachment2:FindFirstChild("SmokeEnd") then
							clone.Attachment2.SmokeEnd.Enabled = false
						end
					end)
					task.spawn(function()
						wait(0.1)

						if clone and clone:FindFirstChild("Animate") then
							local Animate = require(clone.Animate)
							Animate()
						end
					end)

					if clone:FindFirstChild("Bottom") then
						game.TweenService:Create(
							clone.Bottom,
							TweenInfo.new(0.52, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end

					wait(0.125)

					if clone:FindFirstChild("PointLight") then
						game.TweenService:Create(
							clone.PointLight,
							TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Brightness = 0,
								Range = 20
							}
						):Play()
					end

					wait(0.2)
				end)
			else
				local clone = replicatedStorage.Chest.SwordEffect.Muramasa.slash:Clone()
				clone.CFrame = v3 * CFrame.Angles(0, 0, 1.5707963267948966)
				clone.Parent = workspace.Effects
				clone.Mesh.Scale = Vector3.new()
				clone.Mesh.Offset = Vector3.new()
				clone.Attachment.Flames.Enabled = true
				clone.Attachment.rock.Enabled = true
				clone.Attachment1.SmokeEnd.Enabled = true
				clone.Attachment2.SmokeEnd.Enabled = true
				clone.Bottom.Color3 = Color3.fromRGB(2000, 565, 300)
				clone.Bottom.Transparency = -7
				clone.Top.Color3 = Color3.fromRGB(2000, 565, 300)
				clone.PointLight.Range = 0
				clone.PointLight.Brightness = 0
				game.TweenService:Create(
					clone.PointLight,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Range = 20,
						Brightness = 1
					}
				):Play()
				_G.PU:Dust(clone, 3)
				local cFrameValue = Instance.new("CFrameValue")
				cFrameValue.Value = clone.CFrame
				local cFrameValue2 = Instance.new("CFrameValue")
				game.TweenService:Create(
					cFrameValue2,
					TweenInfo.new(1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Value = CFrame.Angles(0, 0.08726646259971647, 0) * CFrame.new(0, 0, 0)
					}
				):Play()
				game.TweenService:Create(
					cFrameValue,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Value = clone.CFrame * CFrame.new(0, 0, -120)
					}
				):Play()
				cFrameValue.Changed:Connect(function()
					clone.CFrame = cFrameValue.Value * cFrameValue2.Value
				end)
				game.TweenService:Create(
					clone.Bottom,
					TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Color3 = Color3.fromRGB(2000, 365, 70)
					}
				):Play()
				task.spawn(function()
					game.TweenService:Create(
						clone.Mesh,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Scale = createVector(30, 0.001, 20.391)
						}
					):Play()
					game.TweenService:Create(
						clone.Mesh,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Offset = createVector(0, 0, 18.5)
						}
					):Play()
				end)
				local v4 = {}
				task.spawn(function()
					PeodizService.HeartbeatWait({
						Time = 1,
						Tween = {
							EasingStyle = Enum.EasingStyle.Quad,
							EasingDirection = Enum.EasingDirection.Out
						}
					}, function(p2)
						local v5 = math.floor(p2 * 9)

						if v4[math.floor(v5)] or math.floor(v5) == 9 then
							return
						end

						v4[math.floor(v5)] = true
						clone.Attachment.Flames:Emit(2)
						clone.Attachment.Specs:Emit(math.random(3, 5))
						clone.Attachment.shard:Emit(5)
					end)
					task.delay(10, function()
						table.clear(v4)
					end)
				end)
				task.spawn(function()
					wait(0.25)
					task.spawn(function()
						wait(0.065)

						if clone:FindFirstChild("Attachment") then
							if clone.Attachment:FindFirstChild("Flames") then
								clone.Attachment.Flames.Enabled = false
							end

							if clone.Attachment:FindFirstChild("rock") then
								clone.Attachment.rock.Enabled = false
							end
						end

						if clone:FindFirstChild("Attachment1") and clone.Attachment1:FindFirstChild("SmokeEnd") then
							clone.Attachment1.SmokeEnd.Enabled = false
						end

						if clone:FindFirstChild("Attachment2") and clone.Attachment2:FindFirstChild("SmokeEnd") then
							clone.Attachment2.SmokeEnd.Enabled = false
						end
					end)
					task.spawn(function()
						wait(0.1)

						if clone and clone:FindFirstChild("Animate") then
							local Animate = require(clone.Animate)
							Animate()
						end
					end)

					if clone:FindFirstChild("Bottom") then
						game.TweenService:Create(
							clone.Bottom,
							TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end

					wait(0.125)

					if clone:FindFirstChild("PointLight") then
						game.TweenService:Create(
							clone.PointLight,
							TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Brightness = 0,
								Range = 20
							}
						):Play()
					end

					wait(0.2)
				end)
			end
		end)
	end
end

function ver3(p)
	for i = 1, 3 do
		local v2 = i
		local v3 = p.cf * CFrame.Angles(0, math.rad(i * 22.5 + -45), 0)
		task.spawn(function()
			if v2 == 2 then
				local clone = replicatedStorage.Chest.SwordEffect.Muramasa.slash:Clone()
				clone.CFrame = v3 * CFrame.Angles(0, 0, 1.5707963267948966)
				clone.Parent = workspace.Effects
				clone.Mesh.Scale = Vector3.new()
				clone.Mesh.Offset = Vector3.new()
				clone.Attachment.Flames.Size = NumberSequence.new(15, 10)
				clone.Attachment1.SmokeEnd.Size = NumberSequence.new(15, 0)
				clone.Attachment2.SmokeEnd.Size = NumberSequence.new(15, 0)
				clone.Attachment.Flames.Enabled = true
				clone.Attachment.rock.Enabled = true
				clone.Attachment1.SmokeEnd.Enabled = true
				clone.Attachment2.SmokeEnd.Enabled = true
				clone.Bottom.Color3 = Color3.fromRGB(2000, 565, 300)
				clone.Bottom.Transparency = -7
				clone.Top.Color3 = Color3.fromRGB(2000, 565, 300)
				clone.PointLight.Range = 0
				clone.PointLight.Brightness = 0
				game.TweenService:Create(
					clone.PointLight,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Range = 27,
						Brightness = 1.5
					}
				):Play()
				_G.PU:Dust(clone, 3)
				local cFrameValue = Instance.new("CFrameValue")
				cFrameValue.Value = clone.CFrame
				local cFrameValue2 = Instance.new("CFrameValue")
				game.TweenService:Create(
					cFrameValue2,
					TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Value = CFrame.Angles(0, 0.08726646259971647, 0) * CFrame.new(0, 0, 0)
					}
				):Play()
				cFrameValue.Changed:Connect(function()
					clone.CFrame = cFrameValue.Value * cFrameValue2.Value
				end)
				game.TweenService:Create(
					clone.Bottom,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Color3 = Color3.fromRGB(2000, 365, 70)
					}
				):Play()
				game.TweenService:Create(
					cFrameValue,
					TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Value = clone.CFrame * CFrame.new(0, 0, -140)
					}
				):Play()
				task.spawn(function()
					game.TweenService:Create(
						clone.Mesh,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Scale = createVector(40, 0.001, 27.391)
						}
					):Play()
					game.TweenService:Create(
						clone.Mesh,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Offset = createVector(0, 0, 20.5)
						}
					):Play()
				end)
				local v4 = {}
				task.spawn(function()
					PeodizService.HeartbeatWait({
						Time = 1.25,
						Tween = {
							EasingStyle = Enum.EasingStyle.Quad,
							EasingDirection = Enum.EasingDirection.Out
						}
					}, function(p2)
						local v5 = math.floor(p2 * 10)

						if v4[math.floor(v5)] or math.floor(v5) == 10 then
							return
						end

						v4[math.floor(v5)] = true
						clone.Attachment.Flames:Emit(3)
						clone.Attachment.Specs:Emit(math.random(3, 5))
						clone.Attachment.shard:Emit(5)
					end)
					task.delay(10, function()
						table.clear(v4)
					end)
				end)
				task.spawn(function()
					wait(1)
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://8748165909",
						Volume = 2
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = p.parent
					sound:Play()
					PeodizService.ForLoop({
						Step = 4
					}, function(p2)
						local v5 = math.floor(p2 * 4)
						local cframe = v3 * CFrame.new(0, 0, v5 * -28) * CFrame.new(0, 0, -24.347826086956523)
						local orientation, v6, v7 = cframe:ToOrientation()
						local ray = Ray.new(cframe.p + createVector(0, 5, 0), createVector(0, -25, 0))
						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = { workspace.Island }
						raycastParams.FilterType = Enum.RaycastFilterType.Include
						local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
						local instance = raycastResult and raycastResult.Instance
						local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
						local clone2 = replicatedStorage.Chest.SwordEffect.Muramasa.Crack:Clone()
						clone2.Parent = workspace.Effects
						clone2.Size = createVector(0, 0, 0)
						clone2.CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v6, 0) * CFrame.Angles(
							0,
							6.283185307179586 * math.random(),
							0
						)
						clone2.Attachment.Swirl:Emit(5)
						_G.PU:Dust(clone2, 2)
						game.TweenService:Create(
							clone2,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = createVector(21.887, 0, 21.887) * (v5 / 5 * 2 + 1) * 1.5
							}
						):Play()
						game.TweenService:Create(
							clone2.dark,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 0.5
							}
						):Play()
						game.TweenService:Create(
							clone2.neon,
							TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 0
							}
						):Play()
						local cFrame = CFrame.new(position) * CFrame.fromOrientation(0, v6, 0) * CFrame.Angles(
							-0.4363323129985824,
							0,
							(math.rad((math.random(-15, 15))))
						) * CFrame.new(0, 2 + math.random(60, 80) / 10 * (v5 / 5), 0) * CFrame.Angles(
							0,
							6.283185307179586 * math.random(),
							0
						)
						local clone3 = replicatedStorage.Chest.SwordEffect.Muramasa.LavaSpike:Clone()
						clone3.Parent = workspace.Effects
						clone3:SetPrimaryPartCFrame(cFrame)
						_G.PU:Dust(clone3, 3)
						clone3.Neon.Size = clone3.Neon.Size * (v5 / 5 * 2 + 1)
						clone3["rock.001"].Size = clone3["rock.001"].Size * (v5 / 5 * 2 + 1)
						clone3:SetPrimaryPartCFrame(cFrame * CFrame.new(0, -clone3.Neon.Size.Y, 0))
						clone2.Specs:Emit((v5 / 5 * 2 + 1.5) * 5)
						clone2.shard:Emit((v5 / 5 * 2 + 1.5) * 5)
						clone2.Flames:Emit(12)
						clone2.rock:Emit((v5 / 5 * 2 + 1) * 5)
						clone2.Flames.Size = NumberSequence.new((v5 / 2 * 1.25 + 1) * 10, (v5 / 2 * 1.25 + 1) * 5)
						game.TweenService:Create(
							clone3["rock.001"],
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								CFrame = cFrame
							}
						):Play()
						game.TweenService:Create(
							clone3.Neon,
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								CFrame = cFrame
							}
						):Play()
						game.TweenService:Create(
							clone2.PointLight,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Range = (v5 / 5 * 2 + 1) * 15,
								Brightness = 1.15
							}
						):Play()
						task.spawn(function()
							wait(1.5)
							game.TweenService:Create(
								clone3.Neon,
								TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									CFrame = cFrame * CFrame.new(0, -clone3.Neon.Size.Y / 2, 0)
								}
							):Play()
							game.TweenService:Create(
								clone3["rock.001"],
								TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									CFrame = cFrame * CFrame.new(0, -clone3.Neon.Size.Y / 2, 0)
								}
							):Play()
							game.TweenService:Create(
								clone3.Neon,
								TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
							game.TweenService:Create(
								clone3["rock.001"],
								TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
							game.TweenService:Create(
								clone2.PointLight,
								TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Brightness = 0,
									Range = 5
								}
							):Play()
							game.TweenService:Create(
								clone2.dark,
								TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
							game.TweenService:Create(
								clone2.neon,
								TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
						end)
					end)
				end)
				task.spawn(function()
					wait(0.3)
					task.spawn(function()
						wait(0.075)

						if clone:FindFirstChild("Attachment") then
							if clone.Attachment:FindFirstChild("Flames") then
								clone.Attachment.Flames.Enabled = false
							end

							if clone.Attachment:FindFirstChild("rock") then
								clone.Attachment.rock.Enabled = false
							end
						end

						if clone:FindFirstChild("Attachment1") and clone.Attachment1:FindFirstChild("SmokeEnd") then
							clone.Attachment1.SmokeEnd.Enabled = false
						end

						if clone:FindFirstChild("Attachment2") and clone.Attachment2:FindFirstChild("SmokeEnd") then
							clone.Attachment2.SmokeEnd.Enabled = false
						end
					end)
					task.spawn(function()
						wait(0.1)

						if clone and clone:FindFirstChild("Animate") then
							local Animate = require(clone.Animate)
							Animate()
						end
					end)

					if clone:FindFirstChild("Bottom") then
						game.TweenService:Create(
							clone.Bottom,
							TweenInfo.new(0.52, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end

					wait(0.125)

					if clone:FindFirstChild("PointLight") then
						game.TweenService:Create(
							clone.PointLight,
							TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Brightness = 0,
								Range = 20
							}
						):Play()
					end

					wait(0.2)
				end)
			else
				local clone = replicatedStorage.Chest.SwordEffect.Muramasa.slash:Clone()
				clone.CFrame = v3 * CFrame.Angles(0, 0, 1.5707963267948966)
				clone.Parent = workspace.Effects
				clone.Mesh.Scale = Vector3.new()
				clone.Mesh.Offset = Vector3.new()
				clone.Attachment.Flames.Enabled = true
				clone.Attachment.rock.Enabled = true
				clone.Attachment1.SmokeEnd.Enabled = true
				clone.Attachment2.SmokeEnd.Enabled = true
				clone.Bottom.Color3 = Color3.fromRGB(2000, 565, 300)
				clone.Bottom.Transparency = -7
				clone.Top.Color3 = Color3.fromRGB(2000, 565, 300)
				clone.PointLight.Range = 0
				clone.PointLight.Brightness = 0
				game.TweenService:Create(
					clone.PointLight,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Range = 20,
						Brightness = 1
					}
				):Play()
				_G.PU:Dust(clone, 3)
				local cFrameValue = Instance.new("CFrameValue")
				cFrameValue.Value = clone.CFrame
				local cFrameValue2 = Instance.new("CFrameValue")
				game.TweenService:Create(
					cFrameValue2,
					TweenInfo.new(1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Value = CFrame.Angles(0, 0.08726646259971647, 0) * CFrame.new(0, 0, 0)
					}
				):Play()
				game.TweenService:Create(
					cFrameValue,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Value = clone.CFrame * CFrame.new(0, 0, -120)
					}
				):Play()
				cFrameValue.Changed:Connect(function()
					clone.CFrame = cFrameValue.Value * cFrameValue2.Value
				end)
				game.TweenService:Create(
					clone.Bottom,
					TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Color3 = Color3.fromRGB(2000, 365, 70)
					}
				):Play()
				task.spawn(function()
					game.TweenService:Create(
						clone.Mesh,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Scale = createVector(30, 0.001, 20.391)
						}
					):Play()
					game.TweenService:Create(
						clone.Mesh,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Offset = createVector(0, 0, 18.5)
						}
					):Play()
				end)
				local v4 = {}
				task.spawn(function()
					PeodizService.HeartbeatWait({
						Time = 1,
						Tween = {
							EasingStyle = Enum.EasingStyle.Quad,
							EasingDirection = Enum.EasingDirection.Out
						}
					}, function(p2)
						local v5 = math.floor(p2 * 9)

						if v4[math.floor(v5)] or math.floor(v5) == 9 then
							return
						end

						v4[math.floor(v5)] = true
						clone.Attachment.Flames:Emit(5)
						clone.Attachment.Specs:Emit(math.random(3, 5))
						clone.Attachment.shard:Emit(5)
					end)
					task.delay(10, function()
						table.clear(v4)
					end)
				end)
				task.spawn(function()
					wait(1)
					PeodizService.ForLoop({
						Step = 4
					}, function(p2)
						local v5 = math.floor(p2 * 4)
						local cframe = v3 * CFrame.new(0, 0, v5 * -24) * CFrame.new(0, 0, -12)
						local orientation, v6, v7 = cframe:ToOrientation()
						local ray = Ray.new(cframe.p + createVector(0, 5, 0), createVector(0, -25, 0))
						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = { workspace.Island }
						raycastParams.FilterType = Enum.RaycastFilterType.Include
						local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
						local instance = raycastResult and raycastResult.Instance
						local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
						local clone2 = replicatedStorage.Chest.SwordEffect.Muramasa.Crack:Clone()
						clone2.Parent = workspace.Effects
						clone2.Size = createVector(0, 0, 0)
						clone2.CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v6, 0) * CFrame.Angles(
							0,
							6.283185307179586 * math.random(),
							0
						)
						clone2.Attachment.Swirl:Emit(5)
						_G.PU:Dust(clone2, 2)
						game.TweenService:Create(
							clone2,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = createVector(21.887, 0, 21.887) * (v5 / 5 * 2 + 1) * 1.5
							}
						):Play()
						game.TweenService:Create(
							clone2.dark,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 0.5
							}
						):Play()
						game.TweenService:Create(
							clone2.neon,
							TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 0
							}
						):Play()
						local cFrame = CFrame.new(position) * CFrame.fromOrientation(0, v6, 0) * CFrame.Angles(
							-0.4363323129985824,
							0,
							(math.rad((math.random(-15, 15))))
						) * CFrame.new(0, 2 + math.random(60, 80) / 10 * (v5 / 5), 0) * CFrame.Angles(
							0,
							6.283185307179586 * math.random(),
							0
						)
						local clone3 = replicatedStorage.Chest.SwordEffect.Muramasa.LavaSpike:Clone()
						clone3.Parent = workspace.Effects
						clone3:SetPrimaryPartCFrame(cFrame)
						_G.PU:Dust(clone3, 3)
						clone3.Neon.Size = clone3.Neon.Size * (v5 / 5 * 2 + 1)
						clone3["rock.001"].Size = clone3["rock.001"].Size * (v5 / 5 * 2 + 1)
						clone3:SetPrimaryPartCFrame(cFrame * CFrame.new(0, -clone3.Neon.Size.Y, 0))
						clone2.Specs:Emit((v5 / 5 * 2 + 1.5) * 5)
						clone2.shard:Emit((v5 / 5 * 2 + 1.5) * 5)
						clone2.Flames:Emit(12)
						clone2.rock:Emit((v5 / 5 * 2 + 1) * 5)
						clone2.Flames.Size = NumberSequence.new((v5 / 2 * 1.25 + 1) * 10, (v5 / 2 * 1.25 + 1) * 5)
						game.TweenService:Create(
							clone3["rock.001"],
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								CFrame = cFrame
							}
						):Play()
						game.TweenService:Create(
							clone3.Neon,
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								CFrame = cFrame
							}
						):Play()
						game.TweenService:Create(
							clone2.PointLight,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Range = (v5 / 5 * 2 + 1) * 15,
								Brightness = 1.15
							}
						):Play()
						task.spawn(function()
							wait(1.5)

							if clone3:FindFirstChild("Neon") then
								game.TweenService:Create(
									clone3.Neon,
									TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
									{
										CFrame = cFrame * CFrame.new(0, -clone3.Neon.Size.Y / 2, 0)
									}
								):Play()
								game.TweenService:Create(
									clone3.Neon,
									TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end

							if clone3:FindFirstChild("rock.001") then
								game.TweenService:Create(
									clone3["rock.001"],
									TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
									{
										CFrame = cFrame * CFrame.new(0, -clone3.Neon.Size.Y / 2, 0)
									}
								):Play()
								game.TweenService:Create(
									clone3["rock.001"],
									TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end

							if clone2:FindFirstChild("PointLight") then
								game.TweenService:Create(
									clone2.PointLight,
									TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
									{
										Brightness = 0,
										Range = 5
									}
								):Play()
							end

							if clone2:FindFirstChild("dark") then
								game.TweenService:Create(
									clone2.dark,
									TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end

							if clone2:FindFirstChild("neon") then
								game.TweenService:Create(
									clone2.neon,
									TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end
						end)
					end)
				end)
				task.spawn(function()
					wait(0.25)
					task.spawn(function()
						wait(0.065)

						if clone:FindFirstChild("Attachment") then
							if clone.Attachment:FindFirstChild("Flames") then
								clone.Attachment.Flames.Enabled = false
							end

							if clone.Attachment:FindFirstChild("rock") then
								clone.Attachment.rock.Enabled = false
							end
						end

						if clone:FindFirstChild("Attachment1") and clone.Attachment1:FindFirstChild("SmokeEnd") then
							clone.Attachment1.SmokeEnd.Enabled = false
						end

						if clone:FindFirstChild("Attachment2") and clone.Attachment2:FindFirstChild("SmokeEnd") then
							clone.Attachment2.SmokeEnd.Enabled = false
						end
					end)
					task.spawn(function()
						wait(0.1)

						if clone and clone:FindFirstChild("Animate") then
							local Animate = require(clone.Animate)
							Animate()
						end
					end)

					if clone then
						if clone:FindFirstChild("Bottom") then
							game.TweenService:Create(
								clone.Bottom,
								TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
						end

						wait(0.125)

						if clone:FindFirstChild("PointLight") then
							game.TweenService:Create(
								clone.PointLight,
								TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Brightness = 0,
									Range = 20
								}
							):Play()
						end

						wait(0.2)
					end
				end)
			end
		end)
	end
end

return function(data, _)
	if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - data.cf.p).Magnitude < 30 then
		_G.shake("Bump")
	end

	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8748165437",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = data.parent
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8748164748",
		Volume = 2
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = data.parent
	sound2:Play()

	if data.ver == 1 then
		ver1(data)
	end

	if data.ver == 2 then
		ver2(data)
	end

	if data.ver == 3 then
		task.spawn(function()
			wait(1)

			if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - data.cf.p).Magnitude < 50 then
				_G.shake("Explosion")
			end
		end)
		ver3(data)
	end
end