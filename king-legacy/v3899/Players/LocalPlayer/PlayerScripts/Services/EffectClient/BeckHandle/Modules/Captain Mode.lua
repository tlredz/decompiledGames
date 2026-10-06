local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
return function(list)
	local _, v, v2, _ = unpack(list)
	local success, result = pcall(function()
		if type(v2) == "table" and v2.LoopDistance then
			return false
		end

		if v then
			return (localPlayer.Character.HumanoidRootPart.Position - v.p).Magnitude > 1000
		end

		return false
	end)

	if success then
		if result then
			return
		end

		if v2.Mode == "Z" then
			local tableCF = v2.TableCF
			spawn(function()
				for i = 1, 10 do
					local v3 = tableCF[i]
					local v4 = v3 * CFrame.new(0, 0, -75)
					local magnitude = (v3.p - v4.p).magnitude
					local clone = ReplicatedStorage.Chest.Etc.DragonClaw.Shockwave:Clone()
					clone.Color = Color3.fromRGB(255, 255, 255)
					clone.CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, 0) * CFrame.Angles(0, 3.141592653589793, 0)
					clone.Size = createVector(19.252, 19.252, 1.565)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1.5)
					TweenService:Create(
						clone,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(8.374, 8.374, 23.01),
							CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, -magnitude / 1.15) * CFrame.Angles(
								0,
								3.141592653589793,
								3.839724354387525
							)
						}
					):Play()
					TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					local clone2 = ReplicatedStorage.Chest.Etc.DragonClaw.Sphere:Clone()
					clone2.Color = Color3.fromRGB(255, 255, 255)
					clone2.CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, -5)
					clone2.Size = createVector(8, 8, 5)
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, 1)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(0, 0, magnitude - 5),
							CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, -magnitude / 2 + 5)
						}
					):Play()
					TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					local clone3 = ReplicatedStorage.Chest.Etc.DragonClaw.WindRing:Clone()
					clone3.Color = Color3.fromRGB(255, 255, 255)
					clone3.CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, -10) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone3.Size = createVector(8.897, 0.658, 8.897)
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 1)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(21.166, 1.565, 21.166),
							CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, 1) * CFrame.Angles(
								1.5707963267948966,
								0,
								0
							)
						}
					):Play()
					TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					wait(0.05)
				end
			end)
		end
	end
end