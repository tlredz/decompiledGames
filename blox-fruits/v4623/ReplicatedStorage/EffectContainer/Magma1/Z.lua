local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = Util.MasterClock

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

local TweenService = game:GetService("TweenService")
local resume = coroutine.resume
local create = coroutine.create
local map = workspace.Map
local debris = Util.Debris
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
	local character = player.Character
	local isAdding = player.isAdding
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if character and humanoidRootPart and humanoid then
		local random = Random.new()

		if isAdding then
			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 700 then
				return
			end

			Util.Sound:Play("MagmaFistSpawn", humanoidRootPart.Position, nil, 1 + math.random(-10, 10) / 100, 1)

			for i = 1, 2 do
				local v2 = i == 1 and "Left" or "Right"
				local cFrame = humanoidRootPart.CFrame
				local model = script[v2]
				local v3 = character.Name .. "MAGMAARM"
				local clone = model:Clone()
				clone.Name = v3 or clone.Name

				if model:IsA("Model") then
					clone:SetPrimaryPartCFrame(cFrame)
				else
					clone.CFrame = cFrame
				end

				clone.Parent = character or _WorldOrigin
				clone.Weld.Part0 = character[v2 .. "LowerArm"]

				for _, emitter in pairs(clone[v2]:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				local v5 = i
				resume(create(function()
					while clone ~= nil and clone.Parent ~= nil and not character:FindFirstChild("MagmaClapFired") do
						local cFrame2 = humanoidRootPart.CFrame * CFrame.new(
							v5 == 1 and random:NextNumber(-15, -1) or random:NextNumber(1, 15),
							0,
							random:NextNumber(-1, 1)
						)
						local ball = script.ball
						local clone2 = ball:Clone()
						clone2.Name = clone2.Name

						if ball:IsA("Model") then
							clone2:SetPrimaryPartCFrame(cFrame2)
						else
							clone2.CFrame = cFrame2
						end

						clone2.Parent = _WorldOrigin
						clone2.Size *= random:NextNumber(0.5, 1)
						clone2.Orientation = Vector3.new(0, math.random(0, 90), 0)
						local v7 = false
						task.delay(3, function()
							if clone2 ~= nil and clone2.Parent ~= nil and not v7 then
								clone2:Destroy()
							end
						end)
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(500000, 500000, 500000)
						bodyVelocity.Velocity = createVector(0, -15, 0)
						bodyVelocity.Parent = clone2
						local touchedConnection = nil
						clone2.CanTouch = true
						local v10 = clone2
						touchedConnection = clone2.Touched:Connect(function(otherPart)
							if otherPart:IsDescendantOf(map) and otherPart.CanCollide ~= false then
								touchedConnection:Disconnect()
								bodyVelocity:Destroy()
								v10.Anchored = true
								v7 = true
								v10.CFrame *= CFrame.new(0, -0.25, 0)
								TweenService:Create(v10, v[4], {
									Size = Vector3.new(v10.Size.X, 0.2, v10.Size.Z)
								}):Play()
								task.delay(0.35, function()
									TweenService:Create(v10, v[5], {
										Size = Vector3.new()
									}):Play()
									debris:AddItem(v10, 0.55)
								end)
							end
						end)
						task.wait(random:NextNumber(0.5, 0.75))
					end
				end))
			end
		else
			local timestamp = player.Timestamp
			local clapDelay = player.ClapDelay
			local rootCFrame = player.RootCFrame or humanoidRootPart.CFrame
			local v2 = Util.MasterClock:GetTime() - timestamp
			task.wait((math.max(clapDelay - v2, 0.05)))
			local stringValue = Instance.new("StringValue")
			debris:AddItem(stringValue, 1)
			stringValue.Name = "MagmaClapFired"
			stringValue.Parent = character
			Util.Sound:Play("MagmaClapExplosion", rootCFrame.Position, nil, 1 + math.random(-10, 10) / 100, 1)
			local position = rootCFrame.Position
			local character2 = game.Players.LocalPlayer.Character

			if character2 ~= nil then
				local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 and (humanoidRootPart2.Position - position).magnitude <= 75 then
					Util.CameraShaker:Shake(Util.CameraShaker.Presets.Explosion2)
				end
			end

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude < 50 then
				local clone = script.ColorCorrection:Clone()
				debris:AddItem(clone, 1)
				clone.Parent = game.Lighting
				TweenService:Create(clone, v[2], {
					Brightness = 0,
					TintColor = Color3.new(1, 1, 1)
				}):Play()
				local clone2 = script.Blur:Clone()
				debris:AddItem(clone2, 1)
				clone2.Parent = game.Lighting
				TweenService:Create(clone2, v[1], {
					Size = 0
				}):Play()
			end

			local cFrame = rootCFrame * CFrame.new(0, -1, -15)
			local sphere = script.Sphere
			local clone = sphere:Clone()
			clone.Name = clone.Name

			if sphere:IsA("Model") then
				clone:SetPrimaryPartCFrame(cFrame)
			else
				clone.CFrame = cFrame
			end

			clone.Parent = _WorldOrigin
			debris:AddItem(clone, 1)
			TweenService:Create(clone, v[4], {
				Transparency = 1,
				Size = clone.Size * 7
			}):Play()
			local cFrame2 = rootCFrame * CFrame.new(0, -2, -15)
			local explosion = script.Explosion
			local clone2 = explosion:Clone()
			clone2.Name = clone2.Name

			if explosion:IsA("Model") then
				clone2:SetPrimaryPartCFrame(cFrame2)
			else
				clone2.CFrame = cFrame2
			end

			clone2.Parent = _WorldOrigin
			debris:AddItem(clone2, 1.5)

			for _, descendant in pairs(clone2:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant:Emit(descendant:GetAttribute("EmitCount"))
				elseif descendant:IsA("PointLight") then
					TweenService:Create(descendant, v[3], {
						Brightness = 0,
						Range = 0
					}):Play()
				end
			end

			task.wait(0.15)

			for _, child in pairs(character:GetChildren()) do
				if child.Name ~= character.Name .. "MAGMAARM" then
					continue
				end

				local v5 = child:FindFirstChild("Left") and "Left" or "Right"
				local v6 = child
				pcall(function()
					v6.Weld:Destroy()
				end)
				local v7 = child
				pcall(function()
					v7[v5].Anchored = true
				end)
				child:Destroy()
			end
		end
	end
end