local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local _ = workspace.Map
local debris = Util.Debris
local meshRockModule = Util.MeshRockModule
local v = {
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(1.25, Enum.EasingStyle.Exponential),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine),
	TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(1.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
}

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame)
	else
		clone.CFrame = cFrame
	end

	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	local subEffect = player.SubEffect

	if subEffect == 1 then
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if character and humanoidRootPart then
			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 1000 then
				return
			end

			local transparenciesByDescendant = {}

			for _, descendant in pairs(character:GetDescendants()) do
				if descendant:IsDescendantOf(character.Humanoid) then
					continue
				end

				if not (descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("Part") or descendant:IsA("Decal")) then
					continue
				end

				transparenciesByDescendant[descendant] = descendant.Transparency
				descendant.Transparency = 1
			end

			local v2 = false
			local childAddedConnection = nil
			childAddedConnection = character.ChildAdded:Connect(function(stringValue)
				if stringValue.Name == "FloorTravelDone" and stringValue:IsA("StringValue") then
					v2 = true

					if childAddedConnection then
						childAddedConnection:Disconnect()
					end
				end
			end)
			local rightUpperLeg = character:FindFirstChild("RightUpperLeg")
			local rightLowerLeg = character:FindFirstChild("RightLowerLeg")
			local v3 = not (rightUpperLeg and rightLowerLeg) and 0 or rightUpperLeg.Size.Y + rightLowerLeg.Size.Y
			task.spawn(function()
				local v4 = Util.Sound:Play("MagmaIdle", humanoidRootPart, nil, 1, 1)
				v4.Looped = true
				Util.Sound:Play("MagmaTravelSummon", humanoidRootPart, nil, 1 + math.random(-10, 10) / 100, 1.2)

				while not v2 and character ~= nil and humanoid ~= nil and character.Parent ~= nil and humanoid.Parent ~= nil do
					local v5 = humanoidRootPart.Position + createVector(0, 5, 0)
					local ray, v6, v7 = Util.Ray(
						v5,
						CFrame.new(v5).upVector.Unit * -10,
						{ workspace.Characters, workspace.Enemies },
						false
					)
					local cFrame = CFrame.new(v6, v6 + v7) * CFrame.Angles(-1.5707963267948966, 0, 0)

					if not ray then
						cFrame = CFrame.new(
							humanoidRootPart.Position - createVector(0, 2, 0),
							humanoidRootPart.Position + createVector(0, 1, 0)
						) * CFrame.Angles(-1.5707963267948966, 0, 0)
					end

					if not ray then
						local _ = humanoidRootPart.Position - Vector3.new(0, humanoidRootPart.Size.Y / 2 + v3 - 0.1, 0)
					end

					local puddle = script.puddle
					local clone = puddle:Clone()
					clone.Name = clone.Name

					if puddle:IsA("Model") then
						clone:SetPrimaryPartCFrame(cFrame)
					else
						clone.CFrame = cFrame
					end

					clone.Parent = _WorldOrigin
					debris:AddItem(clone, 2)
					clone.CFrame *= CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)

					for _, child in pairs(clone:GetChildren()) do
						child:Emit(child:GetAttribute("EmitCount"))
					end

					TweenService:Create(clone, v[1], {
						Size = Vector3.new(clone.Size.X * 3, clone.Size.Y, clone.Size.Z * 3)
					}):Play()
					task.delay(0.15, function()
						TweenService:Create(clone, v[2], {
							Size = Vector3.new(clone.Size.X * 1.35, clone.Size.Y, clone.Size.Z * 1.35),
							CFrame = clone.CFrame * CFrame.Angles(0, 1.0471975511965976, 0)
						}):Play()
						task.wait(0.75)
						TweenService:Create(clone, v[3], {
							Size = Vector3.new()
						}):Play()
					end)
					task.wait(0.2)
				end

				if v4 then
					v4:Destroy()
				end

				if childAddedConnection then
					childAddedConnection:Disconnect()
				end

				for _, descendant in pairs(character:GetDescendants()) do
					if descendant:IsDescendantOf(character.Humanoid) then
						continue
					end

					if not (descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("Part") or descendant:IsA("Decal")) then
						continue
					end

					if not transparenciesByDescendant[descendant] then
						continue
					end

					descendant.Transparency = transparenciesByDescendant[descendant]
				end

				transparenciesByDescendant = nil
			end)
		end
	elseif subEffect == 2 then
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if character then
			local stringValue = Instance.new("StringValue")
			debris:AddItem(stringValue, 2)
			stringValue.Name = "FloorTravelDone"
			stringValue.Parent = character

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 1000 then
				return
			end

			if humanoidRootPart then
				local v2 = humanoidRootPart.Position + createVector(0, 5, 0)
				local _, v3, v4 = Util.Ray(
					v2,
					CFrame.new(v2).upVector.Unit * -10,
					{ workspace.Characters, workspace.Enemies },
					false
				)
				local cFrame = CFrame.new(v3, v3 + v4) * CFrame.Angles(-1.5707963267948966, 0, 0)
				local puddle = script.puddle
				local clone = puddle:Clone()
				clone.Name = clone.Name

				if puddle:IsA("Model") then
					clone:SetPrimaryPartCFrame(cFrame)
				else
					clone.CFrame = cFrame
				end

				clone.Parent = _WorldOrigin
				debris:AddItem(clone, 2)
				clone.CFrame *= CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)

				for _, child in pairs(clone:GetChildren()) do
					child:Emit(child:GetAttribute("EmitCount"))
				end

				TweenService:Create(clone, v[1], {
					Size = Vector3.new(clone.Size.X * 10, clone.Size.Y, clone.Size.Z * 10)
				}):Play()
				task.delay(0.15, function()
					TweenService:Create(clone, v[2], {
						Size = Vector3.new(clone.Size.X * 1.35, clone.Size.Y, clone.Size.Z * 1.35),
						CFrame = clone.CFrame * CFrame.Angles(0, 1.0471975511965976, 0)
					}):Play()
					task.wait(1)
					TweenService:Create(clone, v[3], {
						Size = Vector3.new()
					}):Play()
				end)
				local cFrame2 = CFrame.new(v3, v3 + v4 * 10) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					math.random(-10, 10) / 10 * 3.141592653589793,
					0
				) * CFrame.new(0, 3, 0)
				local shockwave = script.Shockwave
				local clone2 = shockwave:Clone()
				clone2.Name = clone2.Name

				if shockwave:IsA("Model") then
					clone2:SetPrimaryPartCFrame(cFrame2)
				else
					clone2.CFrame = cFrame2
				end

				clone2.Parent = _WorldOrigin
				debris:AddItem(clone2, 0.5)
				TweenService:Create(clone2, v[4], {
					CFrame = clone2.CFrame * CFrame.new(0, -3, 0),
					Size = Vector3.new(clone2.Size.X * 2.35, 0, clone2.Size.Z * 2.35),
					Transparency = 1
				}):Play()
				local v7 = humanoidRootPart.Position + createVector(0, 5, 0)
				local _, _, _ = Util.Ray(
					v7,
					CFrame.new(v7).upVector.Unit * -15,
					{ workspace.Characters, workspace.Enemies },
					false
				)
				local cFrame3 = humanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 0, 1.57)
				local eff = script.eff
				local clone3 = eff:Clone()
				clone3.Name = clone3.Name

				if eff:IsA("Model") then
					clone3:SetPrimaryPartCFrame(cFrame3)
				else
					clone3.CFrame = cFrame3
				end

				clone3.Parent = _WorldOrigin
				debris:AddItem(clone3, 2)
				Util.Sound:Play("MagmaFistExplode", humanoidRootPart, nil, 1.4 + math.random(-10, 10) / 100, 1)

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				meshRockModule({
					Cframe = humanoidRootPart.CFrame,
					Amount = 8,
					Iteration = 10,
					Max = 3,
					FirstDuration = 0.2,
					RocksLength = 1.65
				})
			end
		end
	end
end