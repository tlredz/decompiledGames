local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "RootRampageController"
})
local currentCamera = workspace.CurrentCamera
local random = Random.new()

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function quadraticBezier(p, p2, p3, p4)
	local v3 = p + (p2 - p) * p4
	return v3 + (p2 + (p3 - p2) * p4 - v3) * p4
end

local function CreateRampageRootsForHitbox(p, p2, p3)
	local v3 = 25
	local result = {}

	for _ = 1, 3 do
		local number = random:NextNumber(-2, 2)
		local number2 = random:NextNumber(-2, 2)
		local number3 = random:NextNumber(-4, 4)
		local number4 = random:NextNumber(4, 6)
		local vector2 = vector.create(math.cos(p2) * 1.5, number4 + math.sin(p2) * 2, math.cos(p2 * 0.5) * 1.5)
		local _ = p.CFrame * CFrame.new(number, -1.5, -4 + number2).Position
		local position = p.CFrame * CFrame.new(number + number3, -1.5, 4 + number2).Position
		p.CFrame = p.CFrame
		local v5

		if workspace:Raycast(
			p.CFrame * CFrame.new(number, 1, -4 + number2).Position,
			createVector(0, -3, 0),
			_G.MapParams
		) then
			v5 = p.CFrame * CFrame.new(number, -1.5, -4 + number2).Position
			p.CFrame = p.CFrame
		else
			v5 = p.CFrame * CFrame.new(number, random:NextNumber(-4, 4), -4 + number2).Position
			vector2 = vector.create(
				random:NextNumber(-10, 10) * math.cos(p2),
				random:NextNumber(-10, 10) * math.cos(p2),
				random:NextNumber(-10, 10) * math.cos(p2)
			)
		end

		if workspace:Raycast(
			p.CFrame * CFrame.new(number + number3, 1, 4 + number2).Position,
			createVector(0, -3, 0),
			_G.MapParams
		) then
			position = p.CFrame * CFrame.new(number + number3, -1.5, 4 + number2).Position
		elseif p.CFrame then
			v5 = p.CFrame * CFrame.new(number, random:NextNumber(-2, 2), -6 + number2).Position
			position = p.CFrame * CFrame.new(number, -1.5, 10 + number2).Position
		end

		local v6 = (position + v5) / 2 + vector2
		local number5 = random:NextNumber(1.5, 2)
		v3 *= random:NextInteger(0, 1) * 2 - 1

		if not p3 then
			local clone = replicatedStorage.Utils.Hanami.RootsDust:Clone()
			clone.Position = position
			clone.Size = vector.create(number5, 0.25, number5)
			v2:PlayParticles(clone)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)
		end

		local v7 = position

		for i = 1, 5 do
			local v8 = i / 5
			local v9 = number5 * (random:NextNumber(0.75, 1.25) + math.cos(v8 * 3.141592653589793) * 0.25)
			local part = Instance.new("Part")
			part.Name = i
			part.CanCollide = true
			part.Anchored = true
			part.Color = Color3.fromRGB(67, 47, 35)
			part.Material = Enum.Material.Wood
			table.insert(result, part)
			local v10 = position + (v6 - position) * v8
			local position2 = v10 + (v6 + (v5 - v6) * v8 - v10) * v8
			part.Size = vector.create(v9, v9, (position2 - v7).Magnitude * 1.25)
			part.Position = position2
			local v12 = (i - 1) * math.rad(v3)
			part.CFrame = CFrame.new(position2, v7) * CFrame.new(0, 0, -(v7 - position2).Magnitude / 2) * CFrame.Angles(
				0,
				0,
				v12
			)
			part.Parent = workspace.Effects

			if not p3 then
				task.wait(0.009999999999999998)
			end

			v7 = position2
		end
	end

	return result
end

local function CreateSurfRootsForHitbox(p, folder)
	local v3 = 25
	local result = {}

	for _ = 1, 3 do
		local number = random:NextNumber(-2, 2)
		local number2 = random:NextNumber(-2, 2)
		local number3 = random:NextNumber(-4, 4)
		local vector2 = vector.create(0, random:NextNumber(4, 6), 0)
		local _ = p.CFrame * CFrame.new(number, -1.5, -4 + number2).Position
		local position = p.CFrame * CFrame.new(number + number3, -1.5, 4 + number2).Position
		p.CFrame = p.CFrame
		local v5

		if workspace:Raycast(
			p.CFrame * CFrame.new(number, 1, -4 + number2).Position,
			createVector(0, -3, 0),
			_G.MapParams
		) then
			v5 = p.CFrame * CFrame.new(number, -1.5, -4 + number2).Position
			p.CFrame = p.CFrame
		else
			v5 = p.CFrame * CFrame.new(number, random:NextNumber(-4, 4), -4 + number2).Position
			vector2 = vector.create(random:NextNumber(-2, 2), random:NextNumber(-4, 4), random:NextNumber(-2, 2))
		end

		if workspace:Raycast(
			p.CFrame * CFrame.new(number + number3, 1, 4 + number2).Position,
			createVector(0, -3, 0),
			_G.MapParams
		) then
			position = p.CFrame * CFrame.new(number + number3, -1.5, 4 + number2).Position
		elseif p.CFrame then
			v5 = p.CFrame * CFrame.new(number, random:NextNumber(-2, 2), -6 + number2).Position
			position = p.CFrame * CFrame.new(number, -1.5, 10 + number2).Position
		end

		local v6 = (position + v5) / 2 + vector2
		local number4 = random:NextNumber(1.5, 2)
		v3 *= random:NextInteger(0, 1) * 2 - 1
		local clone = replicatedStorage.Utils.Hanami.RootsDust:Clone()
		clone.Position = position
		clone.Size = vector.create(number4, 0.25, number4)
		v2:PlayParticles(clone)
		clone.Parent = folder
		Debris:AddItem(clone, 2)
		local v7 = position

		for i = 1, 5 do
			local v8 = i / 5
			local v9 = number4 * (random:NextNumber(0.75, 1.25) + math.cos(v8 * 3.141592653589793) * 0.25)
			local part = Instance.new("Part")
			part.Name = i
			part.CanCollide = true
			part.Anchored = true
			part.Color = Color3.fromRGB(67, 47, 35)
			part.Material = Enum.Material.Wood
			table.insert(result, part)
			local v10 = position + (v6 - position) * v8
			local position2 = v10 + (v6 + (v5 - v6) * v8 - v10) * v8
			part.Size = vector.create(v9, v9, (position2 - v7).Magnitude * 1.25)
			part.Position = position2
			local v12 = (i - 1) * math.rad(v3)
			part.CFrame = CFrame.new(position2, v7) * CFrame.new(0, 0, -(v7 - position2).Magnitude / 2) * CFrame.Angles(
				0,
				0,
				v12
			)
			part.Parent = folder
			task.wait(0.009999999999999998)
			v7 = position2
		end
	end

	return result
end

function controller.KnitStart(_)
	local v3 = {
		Windup = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Hanami.RootRampage.Start, humanoidRootPart, game.SoundService.Effect)
			local v4 = v2
			local OST = sounds.Hanami.RootRampage.OST

			if instance == localPlayer.Character then
				humanoidRootPart = workspace or humanoidRootPart
			end

			local v5 = v4:PlaySound(OST, humanoidRootPart, game.SoundService.Music)
			instance2.AncestryChanged:Connect(function()
				if v5.Parent then
					TweenService:Create(v5, TweenInfo.new(1), {
						Volume = 0
					}):Play()
					task.wait(1)
					v5:Destroy()
				end
			end)
		end,
		Roots = function(player, instance, object, size)
			local part

			if localPlayer == player then
				local character = localPlayer.Character

				if not character then
					return
				end

				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return
				end

				part = Instance.new("Part")
				part.Anchored = true
				part.Size = createVector(1, 1, 1)
				part.CanCollide = false
				part.Transparency = 1
				part.CFrame = humanoidRootPart.CFrame
				part.Parent = workspace.Effects
				currentCamera.CameraSubject = part
				task.spawn(function()
					while object.Parent do
						object:FireServer(currentCamera.CFrame.LookVector)
						task.wait()
					end

					local position = part.Position
					local lastTime = tick()

					repeat
						local v4 = (tick() - lastTime) / 0.15
						local position2 = humanoidRootPart.Position
						part.Position = position:Lerp(position2, v4)
						task.wait()
					until v4 >= 1

					currentCamera.CameraSubject = character.Humanoid
				end)
			else
				part = nil
			end

			local domainTag = player and player.Character.Info:FindFirstChild("DomainTag")
			local v4 = {}
			local v5 = {}
			local v6 = {}
			local total = 0
			task.spawn(function()
				while instance.Parent do
					local v7 = task.wait()
					total += 50 * v7
				end
			end)
			instance.OnClientEvent:Connect(function(p2, cFrame, p4, p5)
				if p2 == "PB" then
					currentCamera.CFrame = CFrame.lookAlong(currentCamera.CFrame.Position, cFrame)
					return
				end

				if part and p4 then
					TweenService:Create(part, TweenInfo.new(0.15), {
						CFrame = cFrame * CFrame.new(0, 5, 0)
					}):Play()
				end

				local v7 = {
					CFrame = cFrame,
					Size = size
				}
				local rampageRootsForHitbox = CreateRampageRootsForHitbox(v7, total)

				if v4[p5] then
					pcall(function()
						v6[p5].Parent = rampageRootsForHitbox[#rampageRootsForHitbox]
					end)
				else
					v2:PlaySound(
						sounds.Hanami.RootRampage.RootAppear,
						rampageRootsForHitbox[1],
						game.SoundService.Effect
					)
					v6[p5] = v2:PlaySound(
						sounds.Hanami.RootRampage.RootLoop,
						rampageRootsForHitbox[#rampageRootsForHitbox],
						game.SoundService.Effect
					)
					Debris:AddItem(v6[p5], 8)
					v4[p5] = {}
					v5[p5] = {}
				end

				table.insert(v5[p5], v7)
				local v9 = #v5[p5] <= 3 or nil

				for _, v10 in rampageRootsForHitbox do
					if v9 then
						v10.CanCollide = false
					end

					table.insert(v4[p5], v10)
				end
			end)
			local particleDissipationHolder = replicatedStorage.Utils.Hanami.ParticleDissipationHolder
			instance.AncestryChanged:Once(function()
				for _, v7 in v4 do
					v7[#v7]:ClearAllChildren()
				end

				task.wait(domainTag and 5 or 30)

				for _, v7 in v4 do
					local v8 = v7
					task.spawn(function()
						for k, v9 in v8 do
							v9.Transparency = 1
							v9.CanCollide = false
							Debris:AddItem(v9, 2)

							if k % 9 == 0 then
								task.wait(0.025)
							end
						end
					end)
				end

				for _, v7 in v5 do
					local v8 = v7
					task.spawn(function()
						for k, v9 in v8 do
							local part2 = Instance.new("Part", workspace.Effects)
							part2.Transparency = 1
							part2.CanCollide = false
							part2.Anchored = true
							part2.CastShadow = false
							part2.CFrame = v9.CFrame
							part2.Size = v9.Size * createVector(0.7, 0.7, 1)

							for i, child in particleDissipationHolder:GetChildren() do
								local clone = child:Clone()
								clone.Shape = Enum.ParticleEmitterShape.Box
								clone.Size = NumberSequence.new({
									NumberSequenceKeypoint.new(0, part2.Size.X * 2, 0),
									NumberSequenceKeypoint.new(1, part2.Size.X * 2, 0)
								})
								clone.Parent = part2
							end

							v2:PlayParticles(part2)
							Debris:AddItem(part2, 2)
							task.wait(0.05)
						end
					end)
				end
			end)
		end,
		ReplicateRoots = function(items, value, size)
			local v4 = {}

			for k, item in items do
				v4[k] = {}

				for _, cFrame in item do
					local rampageRootsForHitbox = CreateRampageRootsForHitbox({
						CFrame = cFrame,
						Size = size
					}, 0, true)

					for _, v7 in rampageRootsForHitbox do
						table.insert(v4[k], v7)
					end
				end
			end

			local particleDissipationHolder = replicatedStorage.Utils.Hanami.ParticleDissipationHolder
			local flag = false

			local function clearParts()
				if flag then
					return
				end

				flag = true

				for _, v5 in v4 do
					local v6 = v5
					task.spawn(function()
						for k, parent in v6 do
							for i, child in particleDissipationHolder:GetChildren() do
								local clone = child:Clone()
								clone.Shape = Enum.ParticleEmitterShape.Box
								clone.Size = NumberSequence.new({
									NumberSequenceKeypoint.new(0, parent.Size.X * 2, 0),
									NumberSequenceKeypoint.new(1, parent.Size.X * 2, 0)
								})
								clone.Parent = parent
							end

							v2:PlayParticles(parent)
							parent.Transparency = 1
							parent.CanCollide = false
							Debris:AddItem(parent, 2)

							if k % 9 == 0 then
								task.wait(0.025)
							end
						end
					end)
				end
			end

			task.delay(typeof(value) == "number" and value or 30, clearParts)
		end,
		StartSurf = function(instance, p, instance2, p2)
			if instance2 == localPlayer.Character then
				local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")
				task.spawn(function()
					local clone = utils.Megumi.HitArea:Clone()
					clone.Size = createVector(40, 0, 40)
					clone.Parent = workspace.Effects

					while p2.Parent do
						humanoidRootPart.CFrame = CFrame.lookAlong(
							humanoidRootPart.Position,
							currentCamera.CFrame.LookVector
						)
						local raycastResult = workspace:Raycast(
							humanoidRootPart.Position,
							createVector(0, -70, 0),
							_G.MapParams
						)

						if raycastResult then
							clone.Position = raycastResult.Position + createVector(0, 0.1, 0)
							local v4 = raycastResult.Distance * math.tan((math.rad(p))) * 2
							clone.Size = Vector3.new(v4, 0, v4)

							if not clone.Parent then
								clone.Parent = workspace.Effects
							end
						else
							clone.Parent = nil
						end

						task.wait()
					end

					for _, child in clone:GetChildren() do
						TweenService:Create(child, TweenInfo.new(0.5), {
							Transparency = 1
						}):Play()
					end

					Debris:AddItem(clone, 0.5)
				end)
			end

			local v4 = {}
			local particleDissipationHolder = replicatedStorage.Utils.Hanami.ParticleDissipationHolder
			local flag = nil

			local function clearPart(parent)
				for _, child in particleDissipationHolder:GetChildren() do
					local clone = child:Clone()
					clone.Shape = Enum.ParticleEmitterShape.Box
					clone.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, parent.Size.X * 2, 0),
						NumberSequenceKeypoint.new(1, parent.Size.X * 2, 0)
					})
					clone.Parent = parent
				end

				v2:PlayParticles(parent)
				parent.Transparency = 1
				parent.CanCollide = false
				Debris:AddItem(parent, 2)
			end

			local folder = Instance.new("Folder", workspace.Effects)

			local function startClearing()
				if flag then
					return
				end

				flag = true

				for _, v5 in v4 do
					v5.Parent = workspace.Effects
					clearPart(v5)
				end

				folder:Destroy()
			end

			local flag2 = nil
			local clonesByHumanoidRootPart = {}
			local v5 = nil
			instance.OnClientEvent:Connect(function(p3, ...)
				if p3 == "Surf" then
					if flag then
						return
					end

					local v6 = {
						CFrame = ({ ... })[1],
						Size = createVector(6, 6, 20)
					}

					if not v5 then
						v2:PlaySound(
							sounds.Hanami.RootRampage.RootAppear,
							instance2.HumanoidRootPart,
							game.SoundService.Effect
						)
						v5 = v2:PlaySound(
							sounds.Hanami.RootRampage.RootLoop,
							instance2.HumanoidRootPart,
							game.SoundService.Effect
						)
					end

					local surfRootsForHitbox = CreateSurfRootsForHitbox(v6, folder)

					for _, v8 in surfRootsForHitbox do
						table.insert(v4, v8)
					end
				elseif p3 == "WoodenBall" then
					startClearing()
					flag = true
					local v6 = ({ ... })[1]
					local v7 = ({ ... })[2]
					TweenService:Create(v5, TweenInfo.new(1), {
						Volume = 0
					}):Play()
					task.delay(1, function()
						v5:Destroy()
					end)
					v2:PlaySound(sounds.Hanami.AOESpikes.WoodBallsAppear, v6, game.SoundService.Effect)

					for _, v8 in v7 do
						local humanoidRootPart = v8:FindFirstChild("HumanoidRootPart")

						if not humanoidRootPart then
							continue
						end

						local clone = utils.Megumi.HitArea:Clone()
						clone.Size = createVector(8, 0, 8)
						clonesByHumanoidRootPart[humanoidRootPart] = clone
						task.delay(0.5, function()
							for i, child in clone:GetChildren() do
								TweenService:Create(child, TweenInfo.new(0.3), {
									Transparency = 1
								}):Play()
							end
						end)
						Debris:AddItem(clone, 0.8)
					end

					flag2 = true

					while flag2 do
						for k, v8 in clonesByHumanoidRootPart do
							if not k.Parent then
								continue
							end

							local raycastResult = workspace:Raycast(k.Position, createVector(-0, -5, -0), _G.MapParams)

							if raycastResult then
								v8.Position = raycastResult.Position + createVector(0, 0.1, 0)
								v8.Parent = workspace.Effects
							else
								v8.Parent = nil
							end
						end

						task.wait()
					end
				elseif p3 == "Spikes" then
					local v6 = ({ ... })[1]
					local v7 = ({ ... })[2]
					flag2 = false

					if v6 then
						TweenService:Create(v6, TweenInfo.new(0.2), {
							Size = createVector(9, 9, 9),
							Position = v6.Position - createVector(0, 3.5, 0)
						}):Play()

						local function createSpike(p4, p5, p6)
							local v8 = math.floor(p5 / 5)
							local random2 = Random.new()
							local position = v6.Position
							local v9 = v6.Position + p4 * p5
							local v10 = p6 / v8
							v2:PlaySound(
								sounds.Hanami.AOESpikes[`Spear{random2:NextInteger(1, 2)}`],
								v6,
								game.SoundService.Effect
							)
							local position2 = v6.Position
							local v11 = {}

							for i = 1, v8 do
								local v12 = i / v8
								local v13 = v12 * -1.4 + 2
								local v14 = (i <= 1 or not (i < v8)) and createVector(0, 0, 0) or vector.create(
									random2:NextNumber(-0.3, 0.3),
									random2:NextNumber(-0.3, 0.3),
									random2:NextNumber(-0.2, 0.2)
								)
								local v15 = position + (v9 - position) * v12 + v14

								if i == v8 then
									v15 = v9
								end

								local magnitude = (v15 - position2).Magnitude
								local part = Instance.new("Part")
								part.Transparency = 1
								part.Name = ("Segment"):format(i)
								part.CanCollide = false
								part.Anchored = false
								part.Material = Enum.Material.Wood
								part.Color = Color3.fromRGB(67, 47, 35)
								part.Size = vector.create(v13, v13, magnitude)
								part.CFrame = CFrame.lookAt((position2 + v15) / 2, position2)
								local weld = Instance.new("Weld")
								weld.C0 = part.CFrame:ToObjectSpace(v6.CFrame)
								weld.Part0 = part
								weld.Part1 = v6
								weld.Parent = part
								part.Parent = v6
								table.insert(v11, part)
								position2 = v15
							end

							for _, v12 in v11 do
								v12.Transparency = 0
								task.wait(v10)
							end
						end

						for _, v8 in v7 do
							local v9 = v8[1]
							local v10 = v8[2]
							local humanoidRootPart = v9:FindFirstChild("HumanoidRootPart")

							if not humanoidRootPart then
								continue
							end

							local v11 = clonesByHumanoidRootPart[humanoidRootPart]
							local raycastResult = workspace:Raycast(v10, createVector(-0, -5, -0), _G.MapParams)

							if raycastResult then
								v11.Position = raycastResult.Position + createVector(0, 0.1, 0)
								v11.Parent = workspace.Effects
							else
								v11:Destroy()
							end
						end

						task.wait(0.2)

						for _, v8 in v7 do
							local v9 = math.random(1, 5) / 100
							task.delay(v9, createSpike, v8[3], v8[4], 0.15 - v9)
						end
					end
				elseif p3 == "DestroyWoodenBall" then
					local parent2 = ({ ... })[1]

					local function prepareClearing(parent)
						parent.Transparency = 1

						for _, child in particleDissipationHolder:GetChildren() do
							local clone = child:Clone()
							clone.Shape = Enum.ParticleEmitterShape.Box
							clone.Size = NumberSequence.new({
								NumberSequenceKeypoint.new(0, parent.Size.X * 2, 0),
								NumberSequenceKeypoint.new(1, parent.Size.X * 2, 0)
							})
							clone.Parent = parent
						end
					end

					prepareClearing(parent2)

					for _, v7 in parent2:QueryDescendants("BasePart") do
						prepareClearing(v7)
					end

					v2:PlayParticles(parent2)
				end
			end)
			instance.AncestryChanged:Once(startClearing)
		end
	}
	v.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("RootRampageService")
	v2 = Knit.GetController("FXController")
end

return controller