local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local sound = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

function RandomCFRot()
	return CFrame.Angles(math.rad((math.random(360))), math.rad((math.random(360))), (math.rad((math.random(360)))))
end

return function(player)
	local character = player.Character
	local time = player.Time

	if character ~= nil and character ~= false and character.Parent ~= nil then
		if (character.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local clone = FX:WaitForChild("SerpentBow").snake:Clone()
		clone:SetPrimaryPartCFrame(character.CFrame)
		clone.center.Weld.Part0 = character
		clone.Parent = _WorldOrigin
		local children = clone:GetChildren()
		table.sort(children, function(a, b)
			if a.Name == "center" then
				return a.Name > b.Name
			end

			if b.Name == "center" then
				return b.Name < a.Name
			end

			return tonumber(a.Name) < tonumber(b.Name)
		end)
		local cFrame = player.CFrame
		sound:Play("gloopy", cFrame, nil, 1.5, 0.85)
		local clone2 = FX:WaitForChild("SerpentBow").PoisonStart:Clone()
		clone2:SetPrimaryPartCFrame(character.CFrame)
		local tween = TweenService:Create(
			clone2.ExplosSphere,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
			{
				Size = createVector(18.953999, 19.9965, 18.795),
				CFrame = clone2.ExplosSphere.CFrame * RandomCFRot(),
				Transparency = 1
			}
		)
		local tween2 = TweenService:Create(
			clone2.spike,
			TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				Size = createVector(28.51695, 28.406399, 28.681948),
				Transparency = 1
			}
		)
		Util.Debris:AddItem(clone2, 1)
		coroutine.resume(coroutine.create(function()
			wait(time * 0.6)
			clone2.ExplosSphere.ParticleEmitter2.Enabled = false
		end))
		tween:Play()
		tween2:Play()
		clone2.Parent = _WorldOrigin
		local connections = {}
		coroutine.resume(coroutine.create(function()
			if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
				return
			end

			local lastTime = tick()

			while tick() - lastTime < time * 1.2 do
				task.wait()

				for _ = 1, 2 do
					local clone3 = FX:WaitForChild("SerpentBow").Spark:Clone()
					clone3.Size = Vector3.new()
					clone3.Anchored = true
					clone3.CFrame = character.CFrame * CFrame.new(
						math.random(-20, 20),
						math.random(-10, 10),
						math.random(-20, 20)
					)
					clone3.Size = Vector3.new(
						math.random(0, 1) + math.random(1, 10) / 10,
						math.random(1, 10),
						math.random(0, 1) + math.random(1, 10) / 10
					) * character.Size / 2
					clone3.CFrame = CFrame.new(clone3.Position, character.Position) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					local tween3 = TweenService:Create(
						clone3,
						TweenInfo.new(math.random(1, 6) / 10, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							CFrame = CFrame.new(character.Position, clone3.Position) * CFrame.Angles(
								-1.5707963267948966,
								0,
								0
							),
							Transparency = 1,
							Size = Vector3.new(clone3.Size.X * 0.1, clone3.Size.Y * 0.3, clone3.Size.Z * 0.1)
						}
					)
					table.insert(connections, tween3.Completed:Connect(function()
						clone3:Destroy()
					end))
					clone3.Parent = _WorldOrigin
					tween3:Play()
				end
			end
		end))

		for _, v in ipairs(children) do
			if not tonumber(v.Name) then
				continue
			end

			TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Transparency = 0
			}):Play()

			if v.Name == "44" then
				TweenService:Create(v.accent, TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Transparency = 0.3
				}):Play()
			end
		end

		Util.Debris:AddItem(clone, time)

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local v = sound:Play("PoisonLoop", character, nil, 1.7, 0.3)
		local lastTime = tick()

		while tick() - lastTime < time do
			task.wait()
			local clone3 = FX:WaitForChild("SerpentBow").Spark:Clone()
			clone3.Massless = true
			clone3.CFrame = (character.Parent:FindFirstChild("Head") or clone["44"]).CFrame
			clone3.Size = Vector3.new()
			clone3.Anchored = false
			local weld = Instance.new("Weld")
			weld.Part0 = character.Parent:FindFirstChild("Head") or clone["44"]
			weld.Part1 = clone3
			weld.C0 = character.Parent:FindFirstChild("Head") and CFrame.new(
				0.400001526,
				0,
				-0.600006104,
				1.00000048,
				0,
				0,
				0,
				1,
				1.34110437e-7,
				0,
				1.34110437e-7,
				0.999999523
			) or CFrame.new(0, 0, 0.2)
			weld.Parent = character.Parent:FindFirstChild("Head") or clone["44"]
			local tween3 = TweenService:Create(
				clone3,
				TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Color = Color3.fromRGB(189, 82, 255),
					Size = createVector(0.052, 2.237, 0.052) * (math.random(100, 300) / 100 + 1) * character.Size / 2
				}
			)
			local tween4 = TweenService:Create(
				clone3,
				TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			)
			local tween5 = TweenService:Create(
				weld,
				TweenInfo.new(0.045, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					C0 = weld.C0 * RandomCFRot(),
					C1 = weld.C1 * RandomCFRot()
				}
			)
			table.insert(connections, tween4.Completed:Connect(function()
				clone3:Destroy()
				weld:Destroy()
			end))
			clone3.Parent = _WorldOrigin
			tween3:Play()
			tween4:Play()
			tween5:Play()
		end

		TweenService:Create(v, TweenInfo.new(0.8), {
			Volume = 0
		}):Play()
		wait(1.5)
		sound:Kill(v)

		for _, connection in pairs(connections) do
			connection:Disconnect()
		end
	end
end