local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local Utility = require(ReplicatedStorage.Chest.Modules.Utility)
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local floor = 1

function SpawnFX(parent, instance)
	local etc = ReplicatedStorage.Chest.Etc

	if not instance or (workspace.CurrentCamera.CFrame.Position - instance.Position).Magnitude > 400 then
		return
	end

	task.spawn(function()
		local highlight = Instance.new("Highlight")
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillColor = Color3.fromRGB(255, 255, 0)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0
		highlight.Name = "Spawn Highlight"
		highlight.OutlineTransparency = 0
		highlight.Parent = parent
		_G.PU:Dust(highlight, 1)
		TweenService:Create(highlight, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			FillTransparency = 1,
			OutlineTransparency = 1
		}):Play()
		local clone = etc.PartSpawn:Clone()
		clone.CFrame = instance.CFrame
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 1)
		local v = parent:GetExtentsSize().Y / 7

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			_G.ParticleSize(emitter, v)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://11636218429",
			Volume = 0.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		Utility.EmitParticles(clone.AttachmentNew)
	end)
end

function LoadDungeonSlowly(instance, p)
	local clone = instance:Clone()
	clone:PivotTo(CFrame.new(20000, 15000, 20000))
	local model = Instance.new("Model")
	model.Name = "(Real) " .. p .. " Dungeon"
	model.Parent = workspace.Island

	if clone:GetAttribute("DungeonType") then
		model:SetAttribute("DungeonType", clone:GetAttribute("DungeonType"))
	end

	local v = math.floor((math.clamp(240 / (1 / RunService.Heartbeat:Wait()), 4, 25)))

	for _, child in pairs(clone:GetChildren()) do
		if child:IsA("Folder") then
			local folder = Instance.new("Folder")
			folder.Name = child.Name
			folder.Parent = model

			for i, child2 in pairs(child:GetChildren()) do
				child2.Parent = folder

				if i % v == 1 then
					RunService.RenderStepped:Wait()
				end
			end
		elseif child:IsA("BasePart") then
			child.Parent = model

			if child.Name == "Center" then
				model.PrimaryPart = child
			end
		else
			child.Parent = model
		end
	end

	clone:Destroy()
	return model
end

function BackupClearDungeon()
	for _, model in pairs(ReplicatedStorage.DungeonAssets:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		local child = workspace.Island:FindFirstChild("(Real) " .. model.Name)

		if child then
			child:Destroy()
		end
	end
end

local v = nil
local v2 = nil

function CreateDungeon(p)
	BackupClearDungeon()
	local difficulty = p.Difficulty
	local child = ReplicatedStorage.DungeonAssets:FindFirstChild(difficulty .. " Dungeon")

	if not child then
		return
	end

	local folder = nil
	v2 = nil
	local success, result = pcall(function()
		folder = LoadDungeonSlowly(child, difficulty)
	end)

	if not success then
		warn(result)
		return
	end

	folder:SetAttribute("Loaded", true)
	v2 = true
	v = true
	local v3 = 1
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoid and humanoidRootPart then
		math.random(1, 999999)
		task.spawn(function()
			while true do
				task.wait(0.1)
				local dungeonFloor = ReplicatedStorage:GetAttribute("DungeonFloor")

				if dungeonFloor and v3 ~= dungeonFloor then
					v3 = dungeonFloor
					local v4 = dungeonFloor

					local function StartElevator()
						local child2 = folder:FindFirstChild("Floor" .. tostring(v4))

						if not child2 then
							return true
						end

						local child3 = folder:FindFirstChild("Floor" .. tostring(v4 - 1))

						if not (child3 and child2) then
							return
						end

						local success2, result2 = pcall(function()
							if folder:GetAttribute("DungeonType") ~= "Up" then
								folder.Void:PivotTo(folder["Floor" .. v4].CFrame - createVector(0, 5, 0))
								return
							end

							local child4 = folder:FindFirstChild("Floor" .. v4 + 1)

							if child4 then
								folder.Void:PivotTo(child4.CFrame - createVector(0, 5, 0))
								return
							end

							for i, part in pairs(folder.Void:GetChildren()) do
								if not part:IsA("BasePart") then
									continue
								end

								part.Transparency = 1
								part.CanCollide = nil
							end
						end)

						if result2 then
							warn(result2)
						end

						task.spawn(function()
							local v5 = v3
							local clone = ReplicatedStorage.Chest.Etc.ElevatorFX:Clone()
							_G.PU:Dust(clone, 10)
							clone:PivotTo(folder.Elevator.PrimaryPart.CFrame)
							clone.Parent = workspace.Effects
							local sound = PeoUtils.CreateSound({
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.InverseTapered,
								SoundId = "rbxassetid://72430653899978",
								Volume = 1
							})
							_G.PU:Dust(sound, 5)
							sound.Parent = clone
							sound:Play()
							local sound2 = PeoUtils.CreateSound({
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.InverseTapered,
								SoundId = "rbxassetid://113292837869288",
								Volume = 1,
								Looped = true
							})
							_G.PU:Dust(sound2, 10)
							sound2.Parent = clone
							sound2:Play()
							Utility.EmitParticles(clone.Center)
							Utility.ParticleHandler(clone, true)
							local cFrame = child3.CFrame

							local function IsInBox(cframe)
								local extentsSize = folder.Elevator:GetExtentsSize()
								local abs = (cframe:Inverse() * humanoidRootPart.Position):Abs()
								return abs.X < extentsSize.X / 2 and abs.Y >= 0 and abs.Z < extentsSize.Z / 2
							end

							PeodizService.new({
								Time = 7.5
							}, function(p2)
								if v5 ~= v4 or not v then
									return true
								end

								if folder:FindFirstChild("Elevator") then
									local cframe = child3.CFrame:Lerp(child2.CFrame, p2)
									folder.Elevator:PivotTo(cframe)
									clone:PivotTo(folder.Elevator.PrimaryPart.CFrame)
									local extentsSize = folder.Elevator:GetExtentsSize()
									local abs = (cframe:Inverse() * humanoidRootPart.Position):Abs()
									local v6

									if abs.X < extentsSize.X / 2 and abs.Y >= 0 then
										v6 = abs.Z < extentsSize.Z / 2
									else
										v6 = false
									end

									if v6 then
										humanoidRootPart.CFrame = cframe * cFrame:Inverse() * humanoidRootPart.CFrame
									end

									cFrame = cframe
								end
							end)
							Utility.EmitParticles(clone.Center)
							Utility.ParticleHandler(clone, false)
							_G.PU:Dust(clone, 5)

							if sound2 and sound2.Parent then
								TweenService:Create(sound2, TweenInfo.new(0.5), {
									Volume = 0
								}):Play()
								_G.PU:Dust(sound2, 1)
							end

							local sound3 = PeoUtils.CreateSound({
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.InverseTapered,
								SoundId = "rbxassetid://72430653899978",
								Volume = 1
							})
							_G.PU:Dust(sound3, 5)
							sound3.Parent = clone
							sound3:Play()
						end)
						return true
					end

					local lastTime = tick()

					while not StartElevator() and v and not (tick() - lastTime > 30) and localPlayer.Character and character and humanoid and not (humanoid and humanoid.Health <= 0) do
						task.wait()
					end

					if tick() - lastTime > 30 then
						pcall(function()
							folder.Void:Destroy()
							folder.Elevator:Destroy()
						end)
					end
				end

				if not (not v or not localPlayer.Character or not character or not humanoid or humanoid and humanoid.Health <= 0) then
					continue
				end

				v = nil
				v2 = nil
				task.wait(10)

				for i, part in pairs(folder:GetDescendants()) do
					if not part:IsA("BasePart") then
						continue
					end

					part:Destroy()

					if i % 3 == 1 then
						RunService.Heartbeat:Wait()
					end
				end

				folder:Destroy()
				break
			end
		end)
	end
end

function EndDungeon()
	v = nil
end

function UpdateDungeonFloor(p)
	if not p.Floor then
		return
	end

	if not v2 then
		local lastTime = tick()

		while not (v2 or tick() - lastTime > 30) do
			task.wait(0.1)
		end

		if tick() - lastTime > 30 then
			return
		end
	end

	local floor2 = p.Floor

	if floor < floor2 then
		floor = p.Floor
	end
end

function CreateEnemy(p)
	local enemies = p.Enemies

	if #enemies <= 0 then
		return
	end

	for _, enemy in pairs(enemies) do
		local parent = enemy
		task.defer(function()
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
			local humanoid = parent:FindFirstChild("Humanoid")

			if not (humanoidRootPart and humanoid) then
				return
			end

			local appearance = parent:GetAttribute("Appearance") or "Pirate"
			local success, result = pcall(function()
				local v4 = nil
				local clone = ReplicatedStorage.Chest.Etc.DungeonEnemies[appearance]:Clone()

				if clone:GetAttribute("Boss") then
					parent:SetAttribute("Boss", true)
				end

				if clone:GetAttribute("UIOffset") then
					parent:SetAttribute("UIOffset", clone:GetAttribute("UIOffset"))
				end

				if clone:GetAttribute("RigType") == "Motor" then
					for i, child in pairs(clone:GetChildren()) do
						if child:IsA("Folder") then
							child.Parent = parent
						end

						if child:IsA("BasePart") then
							child.Massless = true
						end
					end

					local motor6D = Instance.new("Motor6D")
					motor6D.Part0 = humanoidRootPart
					motor6D.Part1 = clone.RootPart
					motor6D.C0 = clone:GetAttribute("C0") or CFrame.new(0, 0, 0)
					motor6D.C1 = clone:GetAttribute("C1") or CFrame.new(0, 0, 0)
					motor6D.Parent = humanoidRootPart
					clone.Parent = parent
					return true
				else
					local root = clone:FindFirstChild("LowerTorso") and clone.LowerTorso:FindFirstChild("Root")

					if root then
						root.Part0 = humanoidRootPart

						for i, part in pairs(clone:GetChildren()) do
							if part.Name == "HumanoidRootPart" then
								continue
							end

							if part:IsA("BasePart") then
								part.CollisionGroup = "Mob"
							end

							part.Parent = parent
						end

						v4 = true
					end

					clone:Destroy()
					return v4
				end
			end)

			if success and result then
				local walk = parent.AnimPack:FindFirstChild("Walk") or parent.AnimPack:FindFirstChild("WalkAnim")
				local track = humanoid:LoadAnimation(parent.AnimPack.Idle)
				local track2 = humanoid:LoadAnimation(walk)
				local head = parent:FindFirstChild("Head") or parent:FindFirstChild("HumanoidRootPart")

				if head then
					if parent:GetAttribute("Boss") then
						local clone = ReplicatedStorage.Chest.Gui.TargetBossGUI:Clone()
						clone.Adornee = head
						clone.StudsOffsetWorldSpace = parent:GetAttribute("UIOffset") or createVector(0, 0, 0)
						clone.Parent = parent
					else
						local clone = ReplicatedStorage.Chest.Gui.TargetGUI:Clone()
						clone.Adornee = head
						clone.Parent = parent
					end
				end

				local connections = {}

				local function DisconnectEvents()
					for k, connection in pairs(connections) do
						if connection and connection.Connected then
							connection:Disconnect()
						end
					end

					track:Stop()
					track2:Stop()
					track = nil
					track2 = nil
				end

				table.insert(connections, humanoid.Running:Connect(function(p2)
					task.wait()

					if p2 > 0 then
						if not track2.IsPlaying then
							track2:Play()
						end

						if track.IsPlaying then
							track:Stop()
						end
					else
						if track2.IsPlaying then
							track2:Stop()
						end

						if not track.IsPlaying then
							track:Play()
						end
					end
				end))
				table.insert(connections, parent.AncestryChanged:Connect(function()
					task.wait()

					if parent:IsDescendantOf(workspace) then
						return
					end

					DisconnectEvents()
				end))
				table.insert(connections, humanoid.Died:Connect(function()
					task.wait()
					DisconnectEvents()
				end))
				SpawnFX(parent, humanoidRootPart)
			else
				humanoidRootPart.Transparency = 0
				warn(result)
			end
		end)
	end
end

function ClearDungeonUI(p)
	local clone = ReplicatedStorage.Chest.Gui.DungeonClearUI:Clone()
	clone.Parent = localPlayer.PlayerGui
	clone.Event:Fire(p)
end

function DungeonUI(data)
	local character = localPlayer.Character

	if not character then
		return
	end

	local enemyCount = data.EnemyCount
	local timeLeft = data.TimeLeft
	local currentFloor = data.CurrentFloor
	local dungeonEnd = data.DungeonEnd
	local clone = ReplicatedStorage.Chest.Gui.DungeonUI:Clone()
	clone.Parent = localPlayer.PlayerGui
	local dungeonFrame = clone:WaitForChild("DungeonFrame")
	local frame = dungeonFrame:WaitForChild("Frame")
	local timeFrame = frame:WaitForChild("TimeFrame")
	local floorsFrame = frame:WaitForChild("FloorsFrame")
	local enemiesFrame = frame:WaitForChild("EnemiesFrame")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateUISize()
		dungeonFrame.Position = UDim2.new(0.5, -clone.AbsoluteSize.Y, 0, 0)
	end

	clone:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		UpdateUISize() -- equivalent call inferred; original call site unknown
	end)
	UpdateUISize() -- equivalent call inferred; original call site unknown

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateUI()
		enemiesFrame.TextLabel.Text = enemyCount.Value
		floorsFrame.TextLabel.Text = currentFloor.Value .. "/5"
		timeFrame.TextLabel.Text = timeLeft.Value
	end

	while not dungeonEnd.Value and character:IsDescendantOf(game) do
		UpdateUI() -- equivalent call inferred; original call site unknown
		task.wait(0.5)
	end

	clone:Destroy()
end

function Chaos_Crab_Cutscene(p)
	local target = p.Target

	if not target then
		return
	end

	local humanoid = target:FindFirstChild("Humanoid")
	local humanoidRootPart = target:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoid) then
		return
	end

	currentCamera.FieldOfView = 30
	local v4 = nil
	_G.PU.PlayOneShotAnim({
		Animator = humanoid,
		Animation = ReplicatedStorage.Chest.Animation["Chaos Crab"].Intro
	}).Stopped:Connect(function()
		v4 = true
	end)
	task.delay(0.55, function()
		local cframe = CFrame.new(humanoidRootPart.Position)
		_G.CameraShake:ShakeOnce(7, 19, 0, 0.5)
		local clone = ReplicatedStorage.Chest.Etc.Tentacle.WaterSplash:Clone()
		clone:ScaleTo(3)
		clone:PivotTo(cframe)
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 1.5)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 50,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://126257100926642",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		Utility.EmitParticles(clone)
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 50,
			RollOffMode = Enum.RollOffMode.Inverse,
			SoundId = "rbxassetid://90746165441740",
			Volume = 1.25
		})
		_G.PU:Dust(sound2, 5)
		sound2.Parent = humanoidRootPart
		sound2:Play()
	end)
	local lastTime = tick()

	while true do
		RunService.RenderStepped:Wait()

		if v4 or tick() - lastTime > 7.5 then
			break
		end

		local position = humanoidRootPart.Position
		local chaosCrabLv10000 = target:FindFirstChild("Chaos Crab [Lv. 10000]")

		if chaosCrabLv10000 then
			local dEFspine001 = chaosCrabLv10000:FindFirstChild("DEF-spine.001", true)

			if dEFspine001 then
				position = dEFspine001.WorldCFrame.Position
			end
		end

		currentCamera.CFrame = CFrame.new(currentCamera.CFrame.Position + createVector(0, 5, 0), position)
	end

	currentCamera.FieldOfView = 70
end

return function(p)
	local mode = p.Mode

	if mode == "CreateDungeon" then
		return CreateDungeon(p)
	elseif mode == "EndDungeon" then
		return EndDungeon()
	elseif mode == "UpdateDungeonFloor" then
		return UpdateDungeonFloor(p)
	elseif mode == "CreateEnemy" then
		return CreateEnemy(p)
	elseif mode == "DungeonUI" then
		return DungeonUI(p)
	elseif mode == "ClearDungeonUI" then
		return ClearDungeonUI(p)
	elseif mode == "Chaos Crab Cutscene" then
		return Chaos_Crab_Cutscene(p)
	end
end