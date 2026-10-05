local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
game:GetService("TextChatService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui", 60)
local damageCounter = playerGui:WaitForChild("MainGui", 60):WaitForChild("DamageCounter", 60)
local currentCamera = workspace.CurrentCamera
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
local visualFX = ReplicatedStorage:WaitForChild("VisualFX")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local nPC_Storage = ReplicatedStorage:WaitForChild("NPC_Storage")
local modules = ReplicatedStorage:WaitForChild("Modules")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local assets = ReplicatedStorage:WaitForChild("Assets")
local dash = visualFX:WaitForChild("Dash")
local visual_Effects = visualFX:WaitForChild("Visual_Effects")
local race_Accessory = assets:WaitForChild("Race_Assets"):WaitForChild("Race_Accessory")
local accessories = assets:WaitForChild("Accessories")
local miscEvents = otherEvent:WaitForChild("MiscEvents")
local trollEvents = otherEvent:WaitForChild("TrollEvents")
local mainEvents = otherEvent:WaitForChild("MainEvents")
local soundEvents = otherEvent:WaitForChild("SoundEvents")
local guiEvents = otherEvent:WaitForChild("GuiEvents")
local showEvents = otherEvent:WaitForChild("ShowEvents")
local skillEvents = otherEvent:WaitForChild("SkillEvents")
local island = workspace:WaitForChild("Island")
local visuals = workspace:WaitForChild("Visuals")
workspace:WaitForChild("Character")
local popcat_Clickable = island:WaitForChild("FloppaIsland"):WaitForChild("Popcat_Clickable")
local weapon_Sound = sound_Effect:WaitForChild("Weapon_Sound")
local fightingStyle_Sound = sound_Effect:WaitForChild("FightingStyle_Sound")
sound_Effect:WaitForChild("Enemy")
local FadeModule = require(modules:WaitForChild("FadeModule"))
local CameraShaker = require(modules:WaitForChild("CameraShaker"))
require(modules:WaitForChild("AnimateUI"))
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
require(moduleScript:WaitForChild("Setting"))
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local FXModule = require(moduleScript:WaitForChild("FXModule"))
local NPCTalks = require(moduleScript:WaitForChild("NPCTalks"))
local Aura_Color = require(moduleScript:WaitForChild("Aura_Color"))
local PlaySound2 = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local Eagle_Snatch = require(moduleScript:WaitForChild("Eagle_Snatch"))
local connection = trollEvents:WaitForChild("Connection")
local modules2 = mainEvents:WaitForChild("Modules")
mainEvents:WaitForChild("Toggle")
miscEvents:WaitForChild("ClientAnnouncement")
miscEvents:WaitForChild("Notification")
local cameraShake = miscEvents:WaitForChild("CameraShake")
local popcat = miscEvents:WaitForChild("Popcat")
local sendSound = soundEvents:WaitForChild("SendSound")
local skillGui = guiEvents:WaitForChild("SkillGui")
local openGui = guiEvents:WaitForChild("OpenGui")
local clientEffect = skillEvents:WaitForChild("ClientEffect")
local show = showEvents:WaitForChild("Show")
local playerData = localPlayer:WaitForChild("PlayerData", 60)
local damageCounter2 = localPlayer:WaitForChild("PlayerSettings"):WaitForChild("DamageCounter")
local pop = playerData:WaitForChild("Pop")
local hitDamage = playerData:WaitForChild("HitDamage")
local currentCamera2 = workspace.CurrentCamera
local _ = Enum.EasingStyle.Sine
local _ = Enum.EasingDirection.Out
TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local thread = nil
local v = {}
local v2 = {
	Wings = CFrame.new(0, -0.2, 0.5),
	Wings_V2 = CFrame.new(0, -0.2, 0.5),
	SharkFin = CFrame.new(0, -0.2, 0.5),
	SharkFin_V2 = CFrame.new(0, -0.2, 0.5),
	BunnyEars = CFrame.new(0, 0.6, 0),
	BunnyEars_V2 = CFrame.new(0, 0.6, 0),
	["Floppa Hat"] = CFrame.new(0.05, 0.6, 0),
	["Egg Doge"] = CFrame.new(0, 0.6, 0),
	["Sus Face"] = CFrame.new(0.05, 1, -0.35),
	["Giant Banana"] = CFrame.new(0, -1, 0.5),
	Obamid = CFrame.new(0.1, 0.6, -0.15),
	["Moai Face"] = CFrame.new(0, 0.6, 0),
	["Rick Buddy"] = CFrame.new(0.4, 0.7, 0),
	MrBeast = CFrame.new(0, 0.6, 0),
	["Popcat Pet"] = CFrame.new(0.25, 0.7, 0),
	["Noob Friend"] = CFrame.new(0, 0.6, 0),
	["Pumpkin Head"] = CFrame.new(0, 0.6, 0),
	["Sus Pals"] = CFrame.new(0, 0.6, 0),
	["Nah, I'd Win."] = CFrame.new(0, 0.6, 0),
	["Nah, I'd Lose."] = CFrame.new(0, 0.6, 0),
	Valkyrie = CFrame.new(0, 0.6, 0),
	["Floppa Pet"] = CFrame.new(0.35, 0.8, 0)
}
local v3 = {
	Wings = "UpperTorso",
	Wings_V2 = "UpperTorso",
	SharkFin = "UpperTorso",
	SharkFin_V2 = "UpperTorso",
	BunnyEars = "Head",
	BunnyEars_V2 = "Head",
	["Floppa Hat"] = "Head",
	["Egg Doge"] = "Head",
	["Sus Face"] = "Head",
	["Giant Banana"] = "UpperTorso",
	Obamid = "Head",
	["Moai Face"] = "Head",
	["Rick Buddy"] = "Head",
	MrBeast = "Head",
	["Popcat Pet"] = "Head",
	["Noob Friend"] = "Head",
	["Pumpkin Head"] = "Head",
	["Sus Pals"] = "Head",
	["Nah, I'd Win."] = "Head",
	["Nah, I'd Lose."] = "Head",
	Valkyrie = "Head",
	["Floppa Pet"] = "UpperTorso"
}
local teleport = animation_Folder:WaitForChild("UFO"):WaitForChild("Teleport")
local pvpEnable_Tag = guiTemplate:WaitForChild("PvpEnable_Tag")
local burning = visual_Effects:WaitForChild("Burning")
local ice = visual_Effects:WaitForChild("Ice")
local stop_Part = visual_Effects:WaitForChild("Stop_Part")
local moai = visual_Effects:WaitForChild("Moai")
local iceFloor = visual_Effects:WaitForChild("IceFloor")
local reflexPart = visualFX:WaitForChild("ReflexPart")
local burning_Attachment = burning:WaitForChild("Burning_Attachment")
local Folders = {
	workspace.Skills,
	workspace.Region,
	workspace.Visuals,
	workspace.Location,
	workspace.Sea,
	workspace.Leaderboard,
	workspace.CameraFolder,
	workspace.SpawningPower,
	workspace.Character
}
local v4 = {
	"RightHand",
	"LeftHand",
	"LeftLowerArm",
	"RightLowerArm"
}

if UserInputService.TouchEnabled then
	damageCounter.Damage.UIStroke.Thickness = 1
end

local v5 = {
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot"
}
local v6 = {
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot"
}
local v7 = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(p)
	currentCamera2.CFrame *= p
end)
v7:Start()

local function DisableFreeCamera()
	if playerGui then
		local freecam = playerGui:FindFirstChild("Freecam")

		if freecam and localPlayer:GetRankInGroup(14223953) < 253 then
			freecam:Destroy()
		end
	end
end

local function CheckAlive_Player(player)
	if player and player.Parent and player.Character and player.Character.Parent and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Humanoid").Parent and player.Character:FindFirstChild("Humanoid").Health > 0 then
		return true
	end

	return false
end

local function CheckAlive_Character(instance)
	if instance and instance.Parent and instance:FindFirstChild("Humanoid") and instance:FindFirstChild("Humanoid").Parent and instance:FindFirstChild("Humanoid").Health > 0 then
		return true
	end

	return false
end

local function color3torgb(value)
	return value.R * 255, value.G * 255, value.B * 255
end

local function CheckIfAlive(instance)
	if instance and instance.Parent and instance:FindFirstChild("Humanoid") and instance:FindFirstChild("Humanoid").Parent and instance:FindFirstChild("Humanoid").Health > 0 then
		return true
	end

	return false
end

task.spawn(function()
	while localPlayer:GetAttribute("LoadedData") == nil do
		task.wait(1)
	end

	modules2:FireServer("FriendBoost")
end)
pcall(DisableFreeCamera)
Players.PlayerAdded:Connect(function(_)
	modules2:FireServer("FriendBoost")
end)
Players.PlayerRemoving:Connect(function(_)
	modules2:FireServer("FriendBoost")
end)
show.OnClientEvent:Connect(function(instance, p, p2, p3)
	if instance and instance.Parent then
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if instance:IsA("Model") and humanoidRootPart then
			if (currentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude <= 500 then
				FXModule.Damage(instance:FindFirstChild("HumanoidRootPart"), p, p2, p3)
			end
		elseif instance:IsA("BasePart") and (currentCamera.CFrame.Position - instance.Position).Magnitude <= 500 then
			FXModule.Damage(instance, p, p2, p3)
		end
	end
end)

local function Spin(instance)
	local primaryPart = instance.PrimaryPart
	TweenService:Create(
		primaryPart,
		TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0),
		{
			CFrame = primaryPart.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
		}
	):Play()
end

local function CFrameAccessoryToCharacter(parent, clone, p: string)
	local attachment = clone:FindFirstChildWhichIsA("Attachment", true)

	if attachment then
		local attachment2 = parent:FindFirstChild(attachment.Name, true)
		local handle = attachment2 and attachment2:IsA("Attachment") and clone:FindFirstChild("Handle")

		if handle then
			clone.Parent = parent
			handle.CFrame = attachment2.WorldCFrame * attachment.CFrame:Inverse()
			local weld = Instance.new("Weld")
			weld.Name = "AccessoryWeld"
			weld.Part0 = handle
			weld.Part1 = parent:FindFirstChild(v3[p])
			weld.C0 = attachment.CFrame
			weld.C1 = v2[clone.Name]
			weld.Parent = handle
		end
	end
end

local function Disonnection(connection2)
	if connection2 then
		connection2:Disconnect()
	end
end

function DestoryObject(p, instance)
	for _, child in ipairs(instance:GetChildren()) do
		if child.Name == p then
			child:Destroy()
		end
	end
end

function AxisFromFace(p)
	if p == Enum.NormalId.Front or p == Enum.NormalId.Back then
		return Enum.Axis.Z
	end

	if p == Enum.NormalId.Top or p == Enum.NormalId.Bottom then
		return Enum.Axis.Y
	end

	if p == Enum.NormalId.Right or p == Enum.NormalId.Left then
		return Enum.Axis.X
	end
end

function FlashStepEffect(color, material, instance)
	for _ = 1, 5 do
		local part = Instance.new("Part")
		part.Size = createVector(1, 1, 1)
		part.CanCollide = false
		part.Anchored = false
		part.Color = color
		part.Material = material
		part.Position = instance.Position
		part.Parent = workspace.Visuals
		local v8 = math.random(-75, 75)
		local v9 = math.random(-75, 75)
		part.AssemblyLinearVelocity = Vector3.new(v8, 75, v9)
		part.AssemblyAngularVelocity = Vector3.new(v8, 75, v9)
		task.delay(1, function()
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					Size = createVector(0, 0, 0),
					Transparency = 1
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				if part and part.Parent then
					part:Destroy()
				end
			end)
		end)
	end

	local v8 = instance.CFrame.UpVector * 25

	for _ = 1, 10 do
		for _ = 1, math.random(1, 3) do
			local clone = ReplicatedStorage.VisualFX.Dash.Sphere:Clone()
			clone.Anchored = true
			clone.CanCollide = false
			clone.Transparency = 0
			clone.Material = Enum.Material.Neon
			clone.Size = Vector3.new(0.07, 0.07, math.random(5, 7))

			if math.random(1, 4) == 1 then
				clone.Color = Color3.fromRGB(0, 0, 0)
			else
				clone.Color = Color3.new(1, 1, 1)
			end

			clone.CFrame = CFrame.new(instance.Position, instance.Position + v8) * CFrame.new(
				math.random(-25, 20) / 10,
				math.random(-4, 2),
				math.random(-2, 2)
			)
			clone.Parent = workspace.Visuals
			Debris:AddItem(clone, 0.3)
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Transparency = 1,
				Size = createVector(0, 0, 0),
				CFrame = clone.CFrame * CFrame.new(0, 0, math.random(2, 4))
			}):Play()
		end
	end
end

cameraShake.OnClientEvent:Connect(function()
	v7:Shake(CameraShaker.Presets.Earthquake)
end)
sendSound.OnClientEvent:Connect(function(p, childName, data)
	if childName == "SpinLoop" then
		local spin_Loop = sound_Effect:FindFirstChild("Spin_Loop")
		PlaySound2.PlaySound(p, spin_Loop)
	elseif childName == "FlashStep" then
		local flashStep = sound_Effect:FindFirstChild("FlashStep")
		PlaySound2.PlaySound(p, flashStep)
	elseif childName == "Popcat" then
		local popcat2 = sound_Effect:FindFirstChild("Popcat")
		PlaySound2.PlaySound(p, popcat2)
	elseif childName == "KO" then
		local kill = sound_Effect:FindFirstChild("Kill")
		PlaySound2.PlaySound(p, kill)
	elseif childName == "LevelUp" then
		local levelUp = sound_Effect:FindFirstChild("LevelUp")
		PlaySound2.PlaySound(p, levelUp)
	elseif childName == "SetSpawnPoint" then
		local setSpawnPoint = sound_Effect:FindFirstChild("SetSpawnPoint")

		if setSpawnPoint then
			PlaySound2.PlaySound(p, setSpawnPoint)
		end
	elseif childName == "Weapon_Sound" then
		local weapon = data.Weapon
		local action = data.Action
		local play = data.Play
		local trail = data.Trail
		local override = data.Override
		local rootPart = data.RootPart
		local animator = data.Animator
		local folder = data.Folder
		local curent_Count = data.Curent_Count
		local pop_Table = data.Pop_Table

		if play and weapon and action and rootPart then
			local v8 = weapon_Sound:FindFirstChild(weapon) or fightingStyle_Sound:FindFirstChild(weapon)
			local child = v8 and v8:FindFirstChild(action)

			if child then
				if override then
					local sound = rootPart:FindFirstChild(override)

					if sound and sound:IsA("Sound") then
						sound.Volume /= 2
					end
				end

				PlaySound2.PlaySound_RootPart(rootPart, child)
			end
		end

		if animator and folder and curent_Count then
			local child = animation_Folder:FindFirstChild(folder)
			local child2 = child and child:FindFirstChild(weapon)

			if child2 then
				if v[p.UserId] == nil then
					v[p.UserId] = {}
				end

				if v[p.UserId] then
					for i, v8 in ipairs(v[p.UserId]) do
						task.cancel(v8)
						v[p.UserId][i] = nil
					end
				end

				if trail then
					if typeof(trail) == "table" then
						trail.Trail.Enabled = true
						trail.Trail2.Enabled = true
					else
						trail.Enabled = true
					end
				end

				if pop_Table then
					pop_Table.Unpop.Transparency = 1
					pop_Table.Pop.Transparency = 0
				end

				local child3 = child2:FindFirstChild(curent_Count) or nil
				local track

				if child3 then
					track = animator:LoadAnimation(child3)
				end

				track:Play()

				if trail and v[p.UserId] then
					v[p.UserId][#v[p.UserId] + 1] = task.delay(track.Length, function()
						if typeof(trail) == "table" then
							if trail.Trail.Enabled then
								trail.Trail.Enabled = false
							end

							if trail.Trail2.Enabled then
								trail.Trail2.Enabled = false
							end
						elseif trail.Enabled then
							trail.Enabled = false
						end

						if pop_Table then
							pop_Table.Pop.Transparency = 1
							pop_Table.Unpop.Transparency = 0
						end

						if v[p.UserId] and #v[p.UserId] > 0 then
							v[p.UserId] = nil
						end
					end)
				end
			end
		end
	elseif childName == "PlaySound_Character" then
		local folder = data.Folder
		local enemy = data.Enemy
		local sound = data.Sound
		PlaySound2.PlaySound_Character(p, {
			Folder = folder,
			Enemy = enemy,
			Sound = sound
		})
	elseif childName == "DeleteSound_Character" then
		local rootPart = data.RootPart
		local deleteing_Sound = data.Deleteing_Sound
		PlaySound2.DeleteSound_Character(rootPart, deleteing_Sound)
	else
		local child = sound_Effect:FindFirstChild(childName)

		if child then
			PlaySound2.PlaySound(p, child)
		end
	end
end)
pop.Changed:Connect(function()
	if pop and pop.Parent then
		popcat_Clickable.Part.BillboardGui.Textlabel.Text = Abbreviate.Comma(pop.Value)
	end
end)
popcat.OnClientEvent:Connect(function(p, data)
	if data and (currentCamera.CFrame.Position - data.Body1.Position).Magnitude <= 500 then
		local popcat2 = sound_Effect:FindFirstChild("Popcat")
		PlaySound2.PlaySound(p, popcat2)
		data.Unpop.Transparency = 1
		data.Pop.Transparency = 0
		data.Body1.Transparency = 1
		data.Body2.Transparency = 0
		task.wait(0.05)
		data.Unpop.Transparency = 0
		data.Pop.Transparency = 1
		data.Body1.Transparency = 0
		data.Body2.Transparency = 1
	end
end)
skillGui.OnClientEvent:Connect(function(p)
	local action = p.Action

	if action and action == "RemoveList" then
		local playerGui2 = localPlayer:FindFirstChild("PlayerGui")

		if playerGui2 and playerGui2:FindFirstChild("SkillGuiFolder") then
			for _, screenGui in ipairs(playerGui2.SkillGuiFolder:GetChildren()) do
				if screenGui:IsA("ScreenGui") and screenGui.Enabled == true then
					screenGui.Enabled = false
				end
			end
		end
	end
end)
clientEffect.OnClientEvent:Connect(function(p, instance)
	if p == "Visual_Effect" then
		local type = instance.Type

		if type == "Burning" then
			local target_RootPart = instance.Target_RootPart
			local duration = instance.Duration or 2
			local now = os.time()

			if not target_RootPart or not target_RootPart.Parent or target_RootPart:FindFirstChild((`Burning_Attachment_{now}`)) ~= nil or target_RootPart.Parent.Name == "Meme Beast" or not ((currentCamera.CFrame.Position - target_RootPart.Position).Magnitude <= 750) then
				return
			end

			local clone = burning_Attachment:Clone()
			clone.Name = `Burning_Attachment_{now}`
			clone.Parent = target_RootPart

			for _, emitter in ipairs(clone:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
					continue
				end

				Generate.SetParticle(emitter)
				emitter.Enabled = true
			end

			Debris:AddItem(clone, duration + 0.5)
			task.wait(duration - 0.5)

			if not (clone and clone.Parent) then
				return
			end

			for _, emitter in ipairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") and emitter.Enabled then
					emitter.Enabled = false
				end
			end
		elseif type == "Frozen" then
			local target_RootPart = instance.Target_RootPart
			local duration = instance.Duration or 2

			if target_RootPart and target_RootPart.Parent and target_RootPart.Parent.Name ~= "Meme Beast" then
				local parent = target_RootPart.Parent

				if parent and parent.Parent and parent:FindFirstChild("Humanoid") and parent:FindFirstChild("Humanoid").Parent and parent:FindFirstChild("Humanoid").Health > 0 then
					if not ((currentCamera.CFrame.Position - target_RootPart.Position).Magnitude <= 750) then
						return
					end

					local clone = ice:Clone()
					clone.Parent = target_RootPart
					Debris:AddItem(clone, duration + 0.5)
					local weld = Instance.new("Weld")
					weld.Part0 = clone
					weld.Part1 = target_RootPart
					weld.Parent = clone
					TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(4.695, 6.718, 5.224),
						Transparency = 0.25
					}):Play()
					task.wait(duration - 0.5)

					if clone and clone.Parent then
						TweenService:Create(
							clone,
							TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = Vector3.new(clone.Size.X * 1.25, clone.Size.Y * 1.25, clone.Size.Z * 1.25),
								Transparency = 1
							}
						):Play()
					end

					return
				end
			end

			if not target_RootPart or not target_RootPart.Parent or target_RootPart.Parent.Name == "Meme Beast" or not ((currentCamera.CFrame.Position - target_RootPart.Position).Magnitude <= 750) then
				return
			end

			local clone = ice:Clone()
			clone.Anchored = true
			clone.CFrame = target_RootPart.CFrame
			clone.Parent = visuals
			Debris:AddItem(clone, duration + 0.5)
			TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(4.695, 6.718, 5.224),
				Transparency = 0.25
			}):Play()
			task.wait(duration - 0.5)

			if clone and clone.Parent then
				TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(clone.Size.X * 1.25, clone.Size.Y * 1.25, clone.Size.Z * 1.25),
					Transparency = 1
				}):Play()
			end
		elseif type == "Snow_Frozen" then
			local target_RootPart = instance.Target_RootPart
			local duration = instance.Duration or 2
			local parent, v8, part, lowerTorso, specialMesh, clone, part2

			if target_RootPart and target_RootPart.Parent and target_RootPart.Parent.Name ~= "Meme Beast" then
				local parent2 = target_RootPart.Parent

				if parent2 and parent2.Parent and parent2:FindFirstChild("Humanoid") and parent2:FindFirstChild("Humanoid").Parent and parent2:FindFirstChild("Humanoid").Health > 0 then
					if not ((currentCamera.CFrame.Position - target_RootPart.Position).Magnitude <= 750) then
						return
					end

					local parent3 = target_RootPart.Parent
					local v9 = false

					if not (parent3 and parent3.Parent) then
						return
					end

					for _, child in ipairs(parent3:GetChildren()) do
						if not table.find(v5, child.Name) then
							continue
						end

						if child.Transparency < 1 then
							local part3 = Instance.new("Part")
							part3.CanCollide = false
							part3.Transparency = 0.25
							part3.Massless = true
							part3.Size = child.Size + createVector(0.035, 0.035, 0.035)
							part3.Color = Color3.fromRGB(248, 248, 248)
							part3.Material = Enum.Material.Sand
							part3.Parent = target_RootPart
							Debris:AddItem(part3, duration + 0.5)
							local weld = Instance.new("Weld")
							weld.Parent = part3
							weld.Part0 = child
							weld.Part1 = part3
							task.delay(duration - 0.25, function()
								if part3 and part3.Parent then
									TweenService:Create(
										part3,
										TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()
								end
							end)
						else
							v9 = true
							break
						end
					end

					if not v9 then
						return
					end

					local lowerTorso2 = parent3:FindFirstChild("LowerTorso")

					if not (lowerTorso2 and lowerTorso2.Transparency < 1) then
						return
					end

					local specialMesh2 = lowerTorso2:FindFirstChild("SpecialMesh")
					local clone2

					if specialMesh2 then
						clone2 = specialMesh2:Clone()
					end

					local part3 = Instance.new("Part")
					part3.CanCollide = false
					part3.Transparency = 0.25
					part3.Massless = true
					part3.Size = lowerTorso2.Size + createVector(0.035, 0.035, 0.035)
					part3.Color = Color3.fromRGB(248, 248, 248)
					part3.Material = Enum.Material.Sand
					part3.Parent = target_RootPart
					Debris:AddItem(part3, duration + 0.5)

					if clone2 then
						clone2.TextureId = "rbxassetid://0"
						clone2.Parent = part3
					end

					local weld = Instance.new("Weld")
					weld.Parent = part3
					weld.Part0 = lowerTorso2
					weld.Part1 = part3
					task.wait(duration - 0.25)

					if part3 and part3.Parent then
						TweenService:Create(
							part3,
							TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end

					return
				end
			end

			if not target_RootPart or not target_RootPart.Parent or target_RootPart.Parent.Name == "Meme Beast" or not ((currentCamera.CFrame.Position - target_RootPart.Position).Magnitude <= 750) then
				return
			end

			parent = target_RootPart.Parent
			v8 = false

			if not (parent and parent.Parent) then
				return
			end

			for _, child in ipairs(parent:GetChildren()) do
				if not table.find(v5, child.Name) then
					continue
				end

				if child.Transparency < 1 then
					part = Instance.new("Part")
					part.CanCollide = false
					part.Transparency = 0.25
					part.Massless = true
					part.Size = child.Size + createVector(0.035, 0.035, 0.035)
					part.Color = Color3.fromRGB(248, 248, 248)
					part.Material = Enum.Material.Sand
					part.Anchored = true
					part.CFrame = child.CFrame
					part.Parent = visuals
					Debris:AddItem(part, duration + 0.5)
					local v10 = part
					task.delay(duration - 0.25, function()
						if v10 and v10.Parent then
							TweenService:Create(
								v10,
								TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
						end
					end)
				else
					v8 = true
					break
				end
			end

			if not v8 then
				return
			end

			lowerTorso = parent:FindFirstChild("LowerTorso")

			if not (lowerTorso and lowerTorso.Transparency < 1) then
				return
			end

			specialMesh = lowerTorso:FindFirstChild("SpecialMesh")

			if specialMesh then
				clone = specialMesh:Clone()
			end

			part2 = Instance.new("Part")
			part2.CanCollide = false
			part2.Transparency = 0.25
			part2.Massless = true
			part2.Size = lowerTorso.Size + createVector(0.035, 0.035, 0.035)
			part2.Color = Color3.fromRGB(248, 248, 248)
			part2.Material = Enum.Material.Sand
			part2.Anchored = true
			part2.CFrame = lowerTorso.CFrame
			part2.Parent = visuals
			Debris:AddItem(part2, duration + 0.5)

			if clone then
				clone.TextureId = "rbxassetid://0"
				clone.Parent = part2
			end

			task.wait(duration - 0.25)

			if part2 and part2.Parent then
				TweenService:Create(part2, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end
		elseif type == "Dough_Stunning" then
			local target_RootPart = instance.Target_RootPart
			local duration = instance.Duration or 2
			local parent, v8, children, part, lowerTorso, specialMesh, clone, part2

			if target_RootPart and target_RootPart.Parent and target_RootPart.Parent.Name ~= "Meme Beast" then
				local parent2 = target_RootPart.Parent

				if parent2 and parent2.Parent and parent2:FindFirstChild("Humanoid") and parent2:FindFirstChild("Humanoid").Parent and parent2:FindFirstChild("Humanoid").Health > 0 then
					if not ((currentCamera.CFrame.Position - target_RootPart.Position).Magnitude <= 750) then
						return
					end

					local parent3 = target_RootPart.Parent
					local v9 = false

					if not (parent3 and parent3.Parent) then
						return
					end

					local children2 = parent3:GetChildren()

					for _, part4 in ipairs(children2) do
						if not table.find(v6, part4.Name) then
							continue
						end

						if part4.Transparency < 1 then
							local part3 = Instance.new("Part")
							part3.CanCollide = false
							part3.Massless = true
							part3.Size = part4.Size + createVector(0.065, 0.065, 0.065)
							part3.Color = Color3.fromRGB(255, 255, 255)
							part3.Material = Enum.Material.Glass
							part3.Parent = visuals
							Debris:AddItem(part3, duration + 0.5)
							local weld = Instance.new("Weld")
							weld.Parent = part3
							weld.Part0 = part4
							weld.Part1 = part3
							task.delay(duration - 0.25, function()
								if part3 and part3.Parent then
									TweenService:Create(
										part3,
										TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()
								end
							end)
						else
							v9 = true
							break
						end
					end

					if not v9 then
						return
					end

					local lowerTorso2 = parent3:FindFirstChild("LowerTorso")

					if not (lowerTorso2 and lowerTorso2.Transparency < 1) then
						return
					end

					local specialMesh2 = lowerTorso2:FindFirstChild("SpecialMesh")
					local clone2

					if specialMesh2 then
						clone2 = specialMesh2:Clone()
					end

					local part3 = Instance.new("Part")
					part3.CanCollide = false
					part3.Massless = true
					part3.Size = lowerTorso2.Size + createVector(0.065, 0.065, 0.065)
					part3.Color = Color3.fromRGB(255, 255, 255)
					part3.Material = Enum.Material.Glass
					part3.Parent = visuals
					Debris:AddItem(part3, duration + 0.5)

					if clone2 then
						clone2.TextureId = "rbxassetid://0"
						clone2.Parent = part3
					end

					local weld = Instance.new("Weld")
					weld.Parent = part3
					weld.Part0 = lowerTorso2
					weld.Part1 = part3
					task.wait(duration - 0.25)

					if part3 and part3.Parent then
						TweenService:Create(
							part3,
							TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end

					return
				end
			end

			if not target_RootPart or not target_RootPart.Parent or target_RootPart.Parent.Name == "Meme Beast" or not ((currentCamera.CFrame.Position - target_RootPart.Position).Magnitude <= 750) then
				return
			end

			parent = target_RootPart.Parent
			v8 = false

			if not (parent and parent.Parent) then
				return
			end

			children = parent:GetChildren()

			for _, v10 in ipairs(children) do
				if not table.find(v6, v10.Name) then
					continue
				end

				if v10.Transparency < 1 then
					part = Instance.new("Part")
					part.Anchored = true
					part.CanCollide = false
					part.Massless = true
					part.Size = v10.Size + createVector(0.065, 0.065, 0.065)
					part.Color = Color3.fromRGB(255, 255, 255)
					part.Material = Enum.Material.Glass
					part.Parent = visuals
					Debris:AddItem(part, duration + 0.5)
					local v11 = part
					task.delay(duration - 0.25, function()
						if v11 and v11.Parent then
							TweenService:Create(
								v11,
								TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
						end
					end)
				else
					v8 = true
					break
				end
			end

			if not v8 then
				return
			end

			lowerTorso = parent:FindFirstChild("LowerTorso")

			if not (lowerTorso and lowerTorso.Transparency < 1) then
				return
			end

			specialMesh = lowerTorso:FindFirstChild("SpecialMesh")

			if specialMesh then
				clone = specialMesh:Clone()
			end

			part2 = Instance.new("Part")
			part2.Anchored = true
			part2.CanCollide = false
			part2.Massless = true
			part2.Size = lowerTorso.Size + createVector(0.065, 0.065, 0.065)
			part2.Color = Color3.fromRGB(255, 255, 255)
			part2.Material = Enum.Material.Glass
			part2.Parent = visuals
			Debris:AddItem(part2, duration + 0.5)

			if clone then
				clone.TextureId = "rbxassetid://0"
				clone.Parent = part2
			end

			task.wait(duration - 0.25)

			if part2 and part2.Parent then
				TweenService:Create(part2, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end
		elseif type == "Moai_Stun" then
			local target_RootPart = instance.Target_RootPart
			local duration = instance.Duration or 2

			if target_RootPart and target_RootPart.Parent and target_RootPart.Parent.Name ~= "Meme Beast" then
				local parent = target_RootPart.Parent

				if parent and parent.Parent and parent:FindFirstChild("Humanoid") and parent:FindFirstChild("Humanoid").Parent and parent:FindFirstChild("Humanoid").Health > 0 then
					if not ((currentCamera.CFrame.Position - target_RootPart.Position).Magnitude <= 750) then
						return
					end

					local parent2 = target_RootPart.Parent

					if not (parent2 and parent2.Parent) then
						return
					end

					local clone = moai:Clone()
					clone.Parent = target_RootPart
					Debris:AddItem(clone, duration + 0.5)
					local weld = Instance.new("Weld")
					weld.Part0 = clone
					weld.Part1 = target_RootPart
					weld.Parent = clone

					if weld then
						local leftFoot = parent2:FindFirstChild("LeftFoot")

						if leftFoot and leftFoot.Transparency >= 1 then
							weld.C1 = CFrame.new(0, 3, 0)
						else
							weld.C1 = CFrame.new(0, 1, 0)
						end
					end

					for _, emitter in ipairs(clone:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(3)
						end
					end

					TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(4.492, 9.216, 5.339),
						Transparency = 0
					}):Play()
					task.wait(duration - 0.5)

					if clone and clone.Parent then
						TweenService:Create(
							clone,
							TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end

					return
				end
			end

			if not target_RootPart or not target_RootPart.Parent or target_RootPart.Parent.Name == "Meme Beast" or not ((currentCamera.CFrame.Position - target_RootPart.Position).Magnitude <= 750) then
				return
			end

			local parent = target_RootPart.Parent

			if not (parent and parent.Parent) then
				return
			end

			local clone = moai:Clone()
			clone.Anchored = true
			clone.CFrame = target_RootPart.CFrame
			clone.Parent = target_RootPart
			Debris:AddItem(clone, duration + 0.5)

			if clone then
				local leftFoot = parent:FindFirstChild("LeftFoot")

				if leftFoot and leftFoot.Transparency >= 1 then
					clone.CFrame *= CFrame.new(0, 3, 0)
				else
					clone.CFrame *= CFrame.new(0, 1, 0)
				end
			end

			for _, emitter in ipairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(3)
				end
			end

			TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(4.492, 9.216, 5.339),
				Transparency = 0
			}):Play()
			task.wait(duration - 0.5)

			if clone and clone.Parent then
				TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end
		elseif type == "Stop_Card" then
			local target_RootPart = instance.Target_RootPart
			local duration = instance.Duration or 2

			if target_RootPart and target_RootPart.Parent and target_RootPart.Parent.Name ~= "Meme Beast" then
				local parent = target_RootPart.Parent

				if parent and parent.Parent and parent:FindFirstChild("Humanoid") and parent:FindFirstChild("Humanoid").Parent and parent:FindFirstChild("Humanoid").Health > 0 then
					if not ((currentCamera.CFrame.Position - target_RootPart.Position).Magnitude <= 750) then
						return
					end

					local parent2 = target_RootPart.Parent

					if not (parent2 and parent2.Parent) then
						return
					end

					local clone = stop_Part:Clone()
					clone.Parent = target_RootPart
					Debris:AddItem(clone, duration + 0.5)
					local weld = Instance.new("Weld")
					weld.Part0 = clone
					weld.Part1 = target_RootPart
					weld.Parent = clone

					if weld then
						local leftFoot = parent2:FindFirstChild("LeftFoot")

						if leftFoot and leftFoot.Transparency >= 1 then
							weld.C1 = CFrame.new(0, 5, 0)
						else
							weld.C1 = CFrame.new(0, 6, 0)
						end
					end

					local stop_Mark = clone:FindFirstChild("Stop_Mark")
					local mark = stop_Mark and stop_Mark:FindFirstChild("Mark")

					if not mark then
						return
					end

					TweenService:Create(mark, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						ImageTransparency = 0
					}):Play()
					task.wait(duration - 0.5)

					if clone and clone.Parent then
						TweenService:Create(mark, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							ImageTransparency = 1
						}):Play()
					end

					return
				end
			end

			if not target_RootPart or not target_RootPart.Parent or target_RootPart.Parent.Name == "Meme Beast" or not ((currentCamera.CFrame.Position - target_RootPart.Position).Magnitude <= 750) then
				return
			end

			local parent = target_RootPart.Parent

			if not (parent and parent.Parent) then
				return
			end

			local clone = stop_Part:Clone()
			clone.Anchored = true
			clone.CFrame = target_RootPart.CFrame
			clone.Parent = target_RootPart
			Debris:AddItem(clone, duration + 0.5)
			local leftFoot = parent:FindFirstChild("LeftFoot")

			if leftFoot and leftFoot.Transparency >= 1 then
				clone.CFrame *= CFrame.new(0, 5, 0)
			else
				clone.CFrame *= CFrame.new(0, 6, 0)
			end

			local stop_Mark = clone:FindFirstChild("Stop_Mark")
			local mark = stop_Mark and stop_Mark:FindFirstChild("Mark")

			if not mark then
				return
			end

			TweenService:Create(mark, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageTransparency = 0
			}):Play()
			task.wait(duration - 0.5)

			if clone and clone.Parent then
				TweenService:Create(mark, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageTransparency = 1
				}):Play()
			end
		elseif type == "GodMode" then
			local target_Character = instance.Target_Character

			if not (target_Character and target_Character.Parent) then
				return
			end

			local godMode = target_Character:GetAttribute("GodMode")
			local humanoidRootPart = target_Character:FindFirstChild("HumanoidRootPart")

			if not (godMode and humanoidRootPart and (currentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude <= 750) then
				return
			end

			local now = os.time()

			if humanoidRootPart:FindFirstChild((`Reflex_{now}`)) ~= nil then
				return
			end

			local clone = reflexPart:FindFirstChild(godMode):Clone()
			clone.Name = `Reflex_{now}`
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 2)

			for _, emitter in ipairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(3)
				end
			end
		elseif type == "ReverseMode" then
			local target_Character = instance.Target_Character

			if not (target_Character and target_Character.Parent) then
				return
			end

			local reverseMode = target_Character:GetAttribute("ReverseMode")
			local humanoidRootPart = target_Character:FindFirstChild("HumanoidRootPart")

			if not (reverseMode and humanoidRootPart and (currentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude <= 750) then
				return
			end

			local now = os.time()

			if humanoidRootPart:FindFirstChild((`Reflex_{now}`)) ~= nil then
				return
			end

			local clone = reflexPart:FindFirstChild(reverseMode):Clone()
			clone.Name = `Reflex_{now}`
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 2)

			for _, emitter in ipairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(3)
				end
			end
		else
			if type ~= "Reflex" then
				return
			end

			local target_Character = instance.Target_Character

			if not (target_Character and target_Character.Parent) then
				return
			end

			local reflex = target_Character:GetAttribute("Reflex")
			local child = reflexPart:FindFirstChild(reflex)

			if not (reflex and child and (currentCamera.CFrame.Position - target_Character.PrimaryPart.Position).Magnitude <= 500) then
				return
			end

			local now = os.time()

			if child:GetAttribute("Attachment") then
				for _, part in ipairs(target_Character:GetChildren()) do
					if not ((part:IsA("MeshPart") or part:IsA("BasePart")) and part:FindFirstChild((`Reflex_{now}`)) == nil) then
						continue
					end

					local clone = child:Clone()
					clone.Name = `Reflex_{now}`
					clone.Parent = part
					Debris:AddItem(clone, 2)

					for _, emitter in ipairs(clone:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(1)
						end
					end
				end
			else
				for _, part in ipairs(target_Character:GetChildren()) do
					if not ((part:IsA("MeshPart") or part:IsA("BasePart")) and part:FindFirstChild((`Reflex_{now}`)) == nil) then
						continue
					end

					for _, emitter in ipairs(child:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local clone = emitter:Clone()
						clone.Name = `Reflex_{now}`
						clone.Parent = part
						Debris:AddItem(clone, 2)
						clone:Emit(1)
					end
				end
			end
		end
	elseif p == "Visual_RaceAccessory" then
		local accessory_Type = instance.Accessory_Type
		local target_Humanoid = instance.Target_Humanoid
		local target_Race = instance.Target_Race

		if not (accessory_Type and target_Race and target_Humanoid and target_Humanoid.Parent) then
			return
		end

		local child = race_Accessory:FindFirstChild(target_Race)
		local parent = target_Humanoid.Parent

		if not (child and parent and parent.Parent) then
			return
		end

		local child2 = child:FindFirstChild(accessory_Type)

		if not child2 or parent:FindFirstChild(accessory_Type) ~= nil then
			return
		end

		CFrameAccessoryToCharacter(parent, child2:Clone(), accessory_Type)
	elseif p == "Visual_Accessory" then
		local type = instance.Type
		local target_Character = instance.Target_Character
		local accessory_Name = instance.Accessory_Name

		if not (type and accessory_Name and target_Character and target_Character.Parent) then
			return
		end

		if type == "Equip" then
			local child = accessories:FindFirstChild(accessory_Name)

			if not child or target_Character:FindFirstChild(accessory_Name) ~= nil then
				return
			end

			local clone = child:Clone()
			CFrameAccessoryToCharacter(target_Character, clone, accessory_Name)
			local transform = target_Character:GetAttribute("Transform")

			if not transform or transform ~= "Diamond" then
				return
			end

			local handle = clone:FindFirstChild("Handle")

			if not handle or handle:GetAttribute("Old_Color") then
				return
			end

			if handle.Transparency < 1 then
				if not handle.Massless then
					handle.Massless = true
				end

				handle:SetAttribute("Old_Color", handle.Color)
				handle:SetAttribute("Old_Material", handle.Material)

				if handle:IsA("MeshPart") then
					handle:SetAttribute("Old_Texture", handle.TextureID)
					handle.TextureID = "rbxassetid://18231265025"
				end

				handle.Material = Enum.Material.Plastic
				TweenService:Create(handle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Color = Color3.fromRGB(61, 252, 255)
				}):Play()
			end

			for _, descendant in pairs(handle:GetDescendants()) do
				if (descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation")) and descendant.Transparency < 1 then
					if not descendant.Massless then
						descendant.Massless = true
					end

					descendant:SetAttribute("Old_Color", descendant.Color)
					descendant:SetAttribute("Old_Material", descendant.Material)

					if descendant:IsA("MeshPart") then
						descendant:SetAttribute("Old_Texture", descendant.TextureID)
						descendant.TextureID = "rbxassetid://18231265025"
					end

					descendant.Material = Enum.Material.Plastic
					TweenService:Create(
						descendant,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Color = Color3.fromRGB(61, 252, 255)
						}
					):Play()
				elseif descendant:IsA("Decal") and descendant.Transparency < 1 then
					if descendant.Texture ~= "" then
						descendant:SetAttribute("Old_Color", descendant.Color3)
						descendant:SetAttribute("Old_Texture", descendant.Texture)
						TweenService:Create(
							descendant,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Color3 = Color3.fromRGB(255, 255, 255)
							}
						):Play()
						descendant.Texture = "rbxassetid://18231265025"
					end
				elseif descendant:IsA("SpecialMesh") then
					descendant:SetAttribute("Old_Texture", descendant.TextureId)
					descendant.TextureId = "rbxassetid://18231265025"
				elseif descendant:IsA("SurfaceAppearance") then
					local folder = Instance.new("Folder")
					folder.Name = "SurfaceAppearance_Folder"
					folder.Parent = handle

					if descendant.Parent and descendant.Parent == handle then
						descendant:SetAttribute("Old_Parent", descendant.Parent.Name)
						descendant.Parent = folder
					end
				end
			end
		else
			if type ~= "Unequip" then
				return
			end

			local child = target_Character:FindFirstChild(accessory_Name)
			local child2 = accessories:FindFirstChild(accessory_Name)

			if not child then
				return
			end

			if child2 then
				child:Destroy()
				return
			end

			local child3 = race_Accessory:FindFirstChild(instance.Target_Race)

			if child3 and child3:FindFirstChild(accessory_Name) then
				child:Destroy()
			end
		end
	elseif p == "Water_Passive" then
		if instance.Type ~= "Ice" then
			return
		end

		local target_Position = instance.Target_Position
		local target_Character = instance.Target_Character

		if not target_Character or not target_Character.Parent or target_Character:GetAttribute("Ice_PassiveCD") or not (target_Position and (target_Position - currentCamera.CFrame.Position).Magnitude <= 1500) then
			return
		end

		target_Character:SetAttribute("Ice_PassiveCD", true)
		task.delay(0.05, function()
			target_Character:SetAttribute("Ice_PassiveCD", nil)
		end)
		local clone = iceFloor:Clone()

		if localPlayer.Name ~= target_Character.Name then
			clone.CanCollide = true
		end

		clone.Anchored = true
		clone.Orientation = Vector3.new(1, math.random(-360, 360), 0)
		clone.Position = target_Position
		clone.Transparency = 0
		clone.Parent = visuals
		Debris:AddItem(clone, 2)
		task.wait(0.5)
		TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(0, 0, 0)
		}):Play()
	elseif p == "Ability" then
		local target = instance.Target
		local action = instance.Action
		local flashStepLvl = instance.FlashStepLvl
		local mouse = instance.Mouse
		local character

		if target then
			character = target.Character
		else
			character = nil
		end

		if action == "FlashStep" then
			if not (character and character.Parent and character:FindFirstChild("Humanoid") and character:FindFirstChild("Humanoid").Health > 0) then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and mouse and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1500 and (character:GetPrimaryPartCFrame().Position - mouse).Magnitude <= 500 * flashStepLvl) then
				return
			end

			local clone = ReplicatedStorage.VisualFX.Soru.FlashStep:Clone()
			clone.Anchored = true
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
			clone.Parent = visuals
			local wave = clone:FindFirstChild("Wave")

			if wave then
				wave.Orientation = createVector(-90, 0, 0)
				TweenService:Create(wave, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Size = createVector(20, 20, 5),
					Transparency = 1,
					Orientation = createVector(-90, -180, 0)
				}):Play()
				Debris:AddItem(clone, 1)
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = Folders
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				humanoidRootPart.CFrame.UpVector * -10,
				raycastParams
			)
			local color = Color3.fromRGB(105, 104, 106)
			local concrete = Enum.Material.Concrete

			if raycastResult and raycastResult.Instance and raycastResult.Instance.Color and raycastResult.Instance.Material then
				color = raycastResult.Instance.Color
				concrete = raycastResult.Instance.Material
			end

			local _, v8, _ = CFrame.new(
				humanoidRootPart.Position,
				humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector
			):ToOrientation()
			humanoidRootPart.CFrame = CFrame.new(mouse) * CFrame.new(0, 3, 0) * CFrame.fromOrientation(0, v8, 0)
			FlashStepEffect(color, concrete, humanoidRootPart)
			local clone2 = game.ReplicatedStorage.VisualFX.Soru.FlashStep:Clone()
			clone2.Anchored = true
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0)
			clone2.Parent = visuals
			local wave2 = clone2:FindFirstChild("Wave")

			if not wave2 then
				return
			end

			wave2.Orientation = createVector(-90, 0, 0)
			local tween = TweenService:Create(
				wave2,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					Size = createVector(20, 20, 5),
					Transparency = 1,
					Orientation = createVector(-90, -180, 0)
				}
			)
			tween:Play()
			tween.Completed:Wait()

			if not clone2 then
				return
			end

			clone2:Destroy()
		elseif action == "AirJump" then
			if not (character and character.Parent) then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if not (humanoidRootPart and humanoid and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1500) then
				return
			end

			local clone = ReplicatedStorage.VisualFX.Jump:WaitForChild("Ring"):Clone()
			clone.Size = createVector(3, 1, 3)
			clone.Transparency = 0.75
			clone.Color = Color3.fromRGB(255, 255, 255)

			if instance.IsMove == "Moving" then
				clone.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + humanoid.MoveDirection) * CFrame.Angles(
					-0.7853981633974483,
					0,
					0
				)
			elseif instance.IsMove == "NotMoving" then
				clone.CFrame = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector
				)
			end

			clone.Parent = workspace.Visuals
			Debris:AddItem(clone, 3)
			PlaySound.PlaySound(target, ReplicatedStorage.Sound_Effect.Jump)
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = createVector(17.5, 1.5, 17.5),
					CFrame = clone.CFrame * CFrame.new(0, -5, 0),
					Transparency = 1
				}
			)

			for _ = 1, 5 do
				local v8 = math.random(3, 6)
				local clone2 = ReplicatedStorage.VisualFX.Jump.Smoke:Clone()
				clone2.Color = Color3.fromRGB(203, 203, 203)
				clone2.CFrame = clone.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(
					math.random(360),
					math.random(360),
					math.random(360)
				)
				clone2.Size = Vector3.new(v8, v8, v8)
				clone2.Parent = workspace.Visuals
				Debris:AddItem(clone2, 0.5)
				TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1,
					Size = createVector(0, 0, 0),
					CFrame = clone2.CFrame * CFrame.new(math.random(-5, 5), -5, math.random(-5, 5)) * CFrame.Angles(
						math.random(360),
						math.random(360),
						math.random(360)
					)
				}):Play()
			end

			tween:Play()
			tween.Completed:Wait()

			if not clone then
				return
			end

			clone:Destroy()
		elseif action == "Dash" then
			if not (character and character.Parent) then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoidRootPart and humanoid then
				PlaySound.PlaySound(target, ReplicatedStorage.Sound_Effect.Dash)

				if (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
					if humanoid.FloorMaterial == Enum.Material.Air then
						local clone = ReplicatedStorage.VisualFX.Jump.Ring:Clone()
						clone.Size = createVector(3, 1, 3)
						clone.Transparency = 0.75
						clone.Color = Color3.fromRGB(255, 255, 255)

						if instance.DashDirection == "Move_Direction" then
							clone.CFrame = CFrame.new(
								humanoidRootPart.Position,
								humanoidRootPart.Position + humanoid.MoveDirection
							) * CFrame.Angles(-1.5707963267948966, 0, 0)
						elseif instance.DashDirection == "Camera_Direction" then
							clone.CFrame = CFrame.new(
								humanoidRootPart.Position,
								humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector
							) * CFrame.Angles(-1.5707963267948966, 0, 0)
						end

						for _ = 1, 5 do
							local v8 = math.random(3, 6)
							local clone2 = ReplicatedStorage.VisualFX.Jump.Smoke:Clone()
							clone2.Color = Color3.fromRGB(203, 203, 203)
							clone2.CFrame = clone.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(
								math.random(360),
								math.random(360),
								math.random(360)
							)
							clone2.Size = Vector3.new(v8, v8, v8)
							clone2.Parent = workspace.Visuals
							Debris:AddItem(clone2, 0.5)
							TweenService:Create(
								clone2,
								TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1,
									Size = createVector(0, 0, 0),
									CFrame = clone2.CFrame * CFrame.new(math.random(-5, 5), -5, math.random(-5, 5)) * CFrame.Angles(
										math.random(360),
										math.random(360),
										math.random(360)
									)
								}
							):Play()
						end

						clone.Parent = workspace.Visuals
						local tween = TweenService:Create(
							clone,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = createVector(20, 1.5, 20),
								CFrame = clone.CFrame * CFrame.new(0, 10, 0),
								Transparency = 1
							}
						)
						tween:Play()
						tween.Completed:Wait()

						if clone then
							clone:Destroy()
						end
					else
						local position = humanoidRootPart.Position
						local clone = dash.DashEffect:Clone()
						clone.Parent = workspace.Visuals
						clone.Weld.Part0 = humanoidRootPart
						clone.Weld.Part1 = clone
						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = Folders
						raycastParams.FilterType = Enum.RaycastFilterType.Exclude
						local raycastResult = workspace:Raycast(
							humanoidRootPart.Position,
							humanoidRootPart.CFrame.UpVector * -10,
							raycastParams
						)
						local colorSequence = ColorSequence.new(Color3.fromRGB(163, 162, 165))

						if raycastResult and raycastResult.Instance and raycastResult.Instance.Color then
							colorSequence = ColorSequence.new(raycastResult.Instance.Color)
						end

						clone.A0.Dust.Color = colorSequence
						clone.A1.Dust.Color = colorSequence
						local floorMaterialChangedConnection = humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
							if humanoid.FloorMaterial ~= Enum.Material.Air then
								local raycastResult2 = workspace:Raycast(
									humanoidRootPart.Position,
									humanoidRootPart.CFrame.UpVector * -10,
									raycastParams
								)

								if raycastResult2 and raycastResult2.Instance and raycastResult2.Instance.Color then
									colorSequence = ColorSequence.new(raycastResult2.Instance.Color)
								end

								clone.A0.Dust.Color = colorSequence
								clone.A1.Dust.Color = colorSequence
							end
						end)
						local heartbeatConnection = RunService.Heartbeat:Connect(function()
							if humanoid.FloorMaterial ~= Enum.Material.Air and (humanoidRootPart.Position - position).Magnitude > 2 then
								clone.A0.Dust:Emit(5)
								clone.A1.Dust:Emit(5)
								position = humanoidRootPart.Position
							end
						end)
						Debris:AddItem(clone, 2)
						task.delay(0.35, function()
							local connection2 = floorMaterialChangedConnection

							if connection2 then
								connection2:Disconnect()
							end

							local connection3 = heartbeatConnection

							if connection3 then
								connection3:Disconnect()
							end
						end)
					end
				end
			end
		elseif action == "Teleport" then
			if not (character and character.Parent) then
				return
			end

			local child = workspace.Visuals:FindFirstChild((`{character.Name}'s UFO`))

			if child then
				child:Destroy()
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1000) then
				return
			end

			local clone = ReplicatedStorage.VisualFX.UFO:Clone()
			clone.Name = `{character.Name}'s UFO`
			clone.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
			clone.Transparency = 1
			clone.Parent = workspace.Visuals
			Debris:AddItem(clone, 6)
			PlaySound.PlaySound(target, ReplicatedStorage.Sound_Effect.UFO_Flying)
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					CFrame = clone.CFrame * CFrame.new(0, -10, 0) * CFrame.fromOrientation(0, 3.141592653589793, 0),
					Transparency = 0
				}
			)
			tween:Play()
			local v8 = nil
			local teleportSuccessChangedConnection = nil
			local completedConnection = nil
			completedConnection = tween.Completed:Connect(function(p2)
				if p2 ~= Enum.PlaybackState.Cancelled then
					v8 = TweenService:Create(
						clone.BeamPart,
						TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{
							Size = clone.BeamPart.Size + Vector3.fromAxis(Enum.Axis.X) * 30,
							Position = clone.BeamPart.Position + Vector3.fromNormalId(Enum.NormalId.Bottom) * 30 / 2,
							Transparency = 0.2
						}
					)
					v8:Play()
					v8.Completed:Wait()

					if v8.PlaybackState ~= Enum.PlaybackState.Cancelled then
						local humanoid = character:FindFirstChild("Humanoid")

						if humanoid and humanoid:FindFirstChild("Animator") then
							local track = humanoid.Animator:LoadAnimation(teleport)
							track:Play()
							track:AdjustSpeed(0.5)
						end

						task.wait(2.5)
						PlaySound.DeleteSound(target, ReplicatedStorage.Sound_Effect.UFO_Flying)

						if clone and clone.Parent then
							TweenService:Create(
								clone,
								TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									CFrame = clone.CFrame * CFrame.new(0, 10, 0) * CFrame.fromOrientation(
										0,
										3.141592653589793,
										0
									),
									Transparency = 1
								}
							):Play()
							TweenService:Create(
								clone.BeamPart,
								TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									Size = clone.BeamPart.Size + Vector3.fromAxis(Enum.Axis.X) * -30,
									Position = clone.BeamPart.Position + Vector3.fromNormalId(Enum.NormalId.Bottom) * -30,
									Transparency = 1
								}
							):Play()
						end

						local connection2 = teleportSuccessChangedConnection

						if connection2 then
							connection2:Disconnect()
						end

						local connection3 = completedConnection

						if connection3 then
							connection3:Disconnect()
						end
					end
				end
			end)
			teleportSuccessChangedConnection = character:GetAttributeChangedSignal("TeleportSuccess"):Connect(function()
				if character:GetAttribute("TeleportSuccess") == false then
					if tween.PlaybackState == Enum.PlaybackState.Playing then
						tween:Cancel()
					end

					if v8 and v8.PlaybackState == Enum.PlaybackState.Playing then
						v8:Cancel()
					end

					if clone and clone.Parent then
						TweenService:Create(
							clone,
							TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								CFrame = clone.CFrame * CFrame.new(0, 10, 0) * CFrame.fromOrientation(
									0,
									3.141592653589793,
									0
								),
								Transparency = 1
							}
						):Play()
						TweenService:Create(
							clone.BeamPart,
							TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Size = clone.BeamPart.Size + Vector3.fromAxis(Enum.Axis.X) * -30,
								Position = clone.BeamPart.Position + Vector3.fromNormalId(Enum.NormalId.Bottom) * -30,
								Transparency = 1
							}
						):Play()
					end

					PlaySound.DeleteSound(target, ReplicatedStorage.Sound_Effect.UFO_Flying)
					local humanoid

					if character then
						humanoid = character:FindFirstChild("Humanoid")
					end

					local animator = humanoid and humanoid:FindFirstChild("Animator")

					if animator then
						for _, v9 in ipairs(animator:GetPlayingAnimationTracks()) do
							if v9.Name == "Teleport" then
								v9:Stop()
							end
						end
					end

					local connection2 = teleportSuccessChangedConnection

					if connection2 then
						connection2:Disconnect()
					end

					local connection3 = completedConnection

					if connection3 then
						connection3:Disconnect()
					end
				end
			end)
		elseif action == "Aura" then
			if not (character and character.Parent) then
				return
			end

			local state = instance.State
			local auraColor = instance.AuraColor
			local object = instance.Object
			local auraColor_Folder = character:FindFirstChild("AuraColor_Folder")

			if state == "Create" and auraColor_Folder then
				for _, childName in ipairs(v4) do
					if not character:FindFirstChild(childName) then
						continue
					end

					local clone = character:FindFirstChild(childName):Clone()
					clone.Name = `{childName}_AuraColor`
					clone:ClearAllChildren()
					clone.CastShadow = false
					clone.Transparency = 0
					clone.Massless = true

					if clone:IsA("MeshPart") then
						clone.TextureID = ""
					end

					clone.Size += createVector(0.05, 0.05, 0.05)
					clone.Color = Color3.fromRGB(255, 255, 255)
					clone.Material = Enum.Material.Neon
					clone.Parent = auraColor_Folder

					if auraColor == "Spectrum" then
						clone:AddTag("RainbowAura")
					end

					local weld = Instance.new("Weld")
					weld.Name = `{childName}_AuraColorWeld`
					weld.Parent = clone
					weld.Part0 = character:FindFirstChild(childName)
					weld.Part1 = clone
					local clone2 = character:FindFirstChild(childName):Clone()
					clone2.Name = `{childName}_ClonedBody`
					clone2:ClearAllChildren()
					clone2.CastShadow = false
					clone2.Transparency = 1
					clone2.Massless = true

					if clone2:IsA("MeshPart") then
						clone2.TextureID = ""
					end

					clone2.Size += createVector(0.025, 0.025, 0.025)
					clone2.Color = Color3.fromRGB(255, 255, 255)
					clone2.Material = Enum.Material.Metal
					clone2.Parent = auraColor_Folder
					local weld2 = Instance.new("Weld")
					weld2.Name = `{childName}_ClonedBodyWeld`
					weld2.Parent = clone2
					weld2.Part0 = character:FindFirstChild(childName)
					weld2.Part1 = clone2

					if auraColor == "Default" then
						local starterGear = target:FindFirstChild("StarterGear")

						if starterGear then
							local value = nil

							for _, tool in ipairs(starterGear:GetChildren()) do
								if not (tool:IsA("Tool") and tool:FindFirstChild("Handle")) then
									continue
								end

								local handle = tool:FindFirstChild("Handle")
								local trail

								if handle then
									trail = handle:FindFirstChild("Trail")
								end

								if not (trail and trail:IsA("Trail")) then
									continue
								end

								value = trail.Color.Keypoints[1].Value
								break
							end

							if value then
								if (clone.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
									TweenService:Create(
										clone,
										TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
										{
											Color = Color3.fromRGB(color3torgb(value))
										}
									):Play()
								else
									clone.Color = Color3.fromRGB(color3torgb(value))
								end
							end
						end
					elseif (clone.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
						TweenService:Create(
							clone,
							TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Color = Aura_Color.ConvertColor[auraColor]
							}
						):Play()
					else
						clone.Color = Aura_Color.ConvertColor[auraColor]
					end

					if character:GetAttribute("Invisible") then
						clone2:SetAttribute("Original_Transparency", 0)

						if (clone2.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
							TweenService:Create(
								clone2,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									Transparency = 1,
									Color = Color3.fromRGB(0, 0, 0)
								}
							):Play()
							local v8 = clone
							task.delay(0.25, function()
								v8:SetAttribute("Original_Transparency", 0.85)
								TweenService:Create(
									v8,
									TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end)
						else
							clone2.Transparency = 1
							clone2.Color = Color3.fromRGB(0, 0, 0)
							clone:SetAttribute("Original_Transparency", 0.85)
							clone.Transparency = 1
						end
					elseif (clone2.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
						TweenService:Create(
							clone2,
							TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Transparency = 0,
								Color = Color3.fromRGB(0, 0, 0)
							}
						):Play()
						local v8 = clone
						task.delay(0.25, function()
							TweenService:Create(
								v8,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									Transparency = 0.85
								}
							):Play()
						end)
					else
						clone2.Transparency = 0
						clone2.Color = Color3.fromRGB(0, 0, 0)
						clone.Transparency = 0.85
					end
				end
			elseif state == "Enable" then
				if auraColor == "Default" and character and character.Parent then
					local starterGear = target:FindFirstChild("StarterGear")

					if starterGear then
						local value = nil

						for _, tool in ipairs(starterGear:GetChildren()) do
							if not (tool:IsA("Tool") and tool:FindFirstChild("Handle")) then
								continue
							end

							local handle = tool:FindFirstChild("Handle")
							local trail

							if handle then
								trail = handle:FindFirstChild("Trail")
							end

							if not (trail and trail:IsA("Trail")) then
								continue
							end

							value = trail.Color.Keypoints[1].Value
							break
						end

						if value then
							local auraColor_Folder2 = character:FindFirstChild("AuraColor_Folder")

							if auraColor_Folder2 then
								for _, part in ipairs(auraColor_Folder2:GetChildren()) do
									if not (part:IsA("BasePart") and string.find(part.Name, "AuraColor")) then
										continue
									end

									if (part.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
										TweenService:Create(
											part,
											TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
											{
												Color = Color3.fromRGB(color3torgb(value))
											}
										):Play()
									else
										part.Color = Color3.fromRGB(color3torgb(value))
									end
								end
							end
						end
					end
				end

				for _, effect in ipairs(object:GetDescendants()) do
					if effect:IsA("ParticleEmitter") and effect.Name == "Aura_Lighting" then
						if effect:GetAttribute("Original_Color") == nil then
							effect:SetAttribute("Original_Color", effect.Color)
						end

						if auraColor == "Default" then
							effect.Color = effect:GetAttribute("Original_Color") or ColorSequence.new(Color3.fromRGB(
								255,
								255,
								255
							))
						elseif auraColor == "Spectrum" then
							effect.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
								ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
								ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
								ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
								ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
							})
						else
							effect.Color = ColorSequence.new(Aura_Color.ConvertColor[auraColor])
						end

						if not effect.Enabled then
							Generate.SetParticle(effect)
							effect.Enabled = true
						end
					elseif effect:IsA("Beam") and effect.Name == "Aura_Beam" then
						if effect:GetAttribute("Original_Beam") == nil then
							effect:SetAttribute("Original_Beam", effect.Color)
						end

						if auraColor == "Default" then
							effect.Color = effect:GetAttribute("Original_Beam") or ColorSequence.new(Color3.fromRGB(
								255,
								255,
								255
							))
						elseif auraColor == "Spectrum" then
							effect.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
								ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
								ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
								ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
								ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
							})
						elseif Aura_Color.ConvertColor[auraColor] then
							effect.Color = ColorSequence.new(Aura_Color.ConvertColor[auraColor])
						end

						if effect.Enabled == false then
							effect.Enabled = true
						end
					elseif effect:IsA("Trail") and effect.Name == "Trail" or effect.Name == "Trail2" then
						if effect:GetAttribute("Original_Trail") == nil then
							effect:SetAttribute("Original_Trail", effect.Color)
						end

						if auraColor == "Default" then
							effect.Color = effect:GetAttribute("Original_Trail") or ColorSequence.new(Color3.fromRGB(
								255,
								255,
								255
							))
						elseif auraColor == "Spectrum" then
							effect.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
								ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
								ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
								ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
								ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
							})
						elseif Aura_Color.ConvertColor[auraColor] then
							effect.Color = ColorSequence.new(Aura_Color.ConvertColor[auraColor])
						end
					end
				end
			elseif state == "Destroy" then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return
				end

				if (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
					if instance.Instant then
						for _, child in ipairs(auraColor_Folder:GetChildren()) do
							TweenService:Create(
								child,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
							Debris:AddItem(child, 0.1)
						end
					else
						for _, child in ipairs(auraColor_Folder:GetChildren()) do
							TweenService:Create(
								child,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
							Debris:AddItem(child, 0.5)
						end
					end
				else
					for _, child in ipairs(auraColor_Folder:GetChildren()) do
						child:Destroy()
					end
				end
			else
				if state ~= "Disable" then
					return
				end

				for _, effect in ipairs(object:GetDescendants()) do
					if effect:IsA("ParticleEmitter") and effect.Name == "Aura_Lighting" then
						if effect.Enabled == true then
							effect.Enabled = false
						end
					elseif effect:IsA("Beam") and effect.Name == "Aura_Beam" then
						if effect.Enabled == true then
							effect.Enabled = false
						end
					elseif effect:IsA("Trail") and effect.Name == "Trail" or effect.Name == "Trail2" then
						if effect:GetAttribute("Original_Trail") then
							effect.Color = effect:GetAttribute("Original_Trail")
						end

						if effect:GetAttribute("Original_LightEmission") and effect.LightEmission ~= effect:GetAttribute("Original_LightEmission") then
							effect.LightEmission = effect:GetAttribute("Original_LightEmission")
						end
					end
				end
			end
		elseif action == "Race_Skill" then
			local target_RootPart = instance.Target_RootPart
			local race = instance.Race
			local child = race and target_RootPart and target_RootPart.Parent and (target_RootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1000 and visualFX.RaceEffect.Race:FindFirstChild(race)

			if not child then
				return
			end

			local clone = child:Clone()
			clone.Name = "Race_Attachment"
			clone.Parent = target_RootPart
			Debris:AddItem(clone, 10)
			PlaySound.PlaySound_RootPart(target_RootPart, ReplicatedStorage.Sound_Effect.Race)

			for _, emitter in ipairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		else
			if action ~= "Disable_RaceSkill" then
				return
			end

			local target_RootPart = instance.Target_RootPart
			local target_Humanoid = instance.Target_Humanoid

			if target_RootPart and target_RootPart.Parent then
				local race_Attachment = target_RootPart:FindFirstChild("Race_Attachment")

				if race_Attachment then
					Debris:AddItem(race_Attachment, 2)

					for _, emitter in ipairs(race_Attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end
			end

			if target_Humanoid and target_Humanoid.Parent and target_Humanoid:GetAttribute("Rabbit_Speed") then
				target_Humanoid:SetAttribute("Rabbit_Speed", 0)
			end
		end
	elseif p == "Level_Up" then
		local target = instance.Target
		local effect = instance.Effect

		if not (target and target.Parent and target:FindFirstChild("Humanoid") and target:FindFirstChild("Humanoid").Parent and target:FindFirstChild("Humanoid").Health > 0) then
			return
		end

		local humanoidRootPart = target:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1000) then
			return
		end

		local clone = ReplicatedStorage.VisualFX.AttachmentEffect.FX:FindFirstChild(effect):Clone()
		clone.Parent = humanoidRootPart
		Debris:AddItem(clone, 2)

		for _, emitter in ipairs(clone:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(3)
			end
		end
	elseif p == "VisualEffect" then
		local target = instance.Target
		local trueAction = instance.TrueAction
		local humanoidRootPart = (target and target.Parent and target:FindFirstChild("Humanoid") and target:FindFirstChild("Humanoid").Parent and target:FindFirstChild("Humanoid").Health > 0 and true or false) and trueAction == "EnablePvp" and target:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local clone = pvpEnable_Tag:Clone()
		clone.Parent = humanoidRootPart
		clone.Enabled = true
		local lastTime = tick()

		while tick() - lastTime < 3 and target and target.Parent and target:FindFirstChild("Humanoid") and target:FindFirstChild("Humanoid").Parent and target:FindFirstChild("Humanoid").Health > 0 do
			if clone and clone.Parent then
				if localPlayer:GetAttribute("TH") then
					clone:FindFirstChild("Timer").Text = `กำลังเปิด Pvp ({Abbreviate.Format_Comma(3 - (tick() - lastTime), 1)} วินาที)`
					clone:FindFirstChild("Outline").Text = `กำลังเปิด Pvp ({Abbreviate.Format_Comma(3 - (tick() - lastTime), 1)} วินาที)`
				else
					clone:FindFirstChild("Timer").Text = `Enabling Pvp ({Abbreviate.Format_Comma(3 - (tick() - lastTime), 1)}s)`
					clone:FindFirstChild("Outline").Text = `Enabling Pvp ({Abbreviate.Format_Comma(3 - (tick() - lastTime), 1)}s)`
				end
			end

			task.wait(0.1)
		end

		if clone and clone.Parent then
			clone:Destroy()
		end
	elseif p == "PowerDrop" then
		local clone = ReplicatedStorage.VisualFX.Effect.PowerFalling:Clone()
		clone.Parent = workspace.Visuals
		clone.Anchored = true
		clone.Position = instance.Position
		task.delay(1, function()
			if clone then
				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				Debris:AddItem(clone, 1)
			end
		end)
	elseif p == "Eagle_Snatch" then
		Eagle_Snatch.Play(instance)
	elseif p == "LeaderboardTag" then
		if instance.TrueAction ~= "Add" then
			return
		end

		if instance.Parent:FindFirstChild(instance.TagNumber) == nil then
			local clone = game.ReplicatedStorage.GuiTemplate:FindFirstChild(instance.TagNumber):Clone()
			clone.Textlabel.Text = `[#{instance.TagTop}] - {instance.TagText}`
			clone.Textlabel.Stroke.Text = `[#{instance.TagTop}] - {instance.TagText}`
			clone.Parent = instance.Parent
			clone.Enabled = true
		else
			local child = instance.Parent:FindFirstChild(instance.TagNumber) and instance.Parent:FindFirstChild((tostring(instance.TagNumber)))

			if not child then
				return
			end

			child.Textlabel.Text = `[#{instance.TagTop}] - {instance.TagText}`
			child.Textlabel.Stroke.Text = `[#{instance.TagTop}] - {instance.TagText}`
		end
	elseif p == "BoatGui" then
		local boat = instance.Boat
		local boatName = instance.BoatName
		local boatOwner = instance.BoatOwner
		local child = Players:FindFirstChild(boatOwner)

		if boat and boatName and boatOwner and child then
			boat.Flag.BoatNameGui.Enabled = true
			boat.Flag.BoatNameGui.PlayerToHideFrom = child
			boat.Flag.BoatNameGui.NameText.Text = `{boatOwner}'s Boat`

			if boatName == "Cheems" then
				boat.FirePart.Fire.Enabled = true
			end
		end
	end
end)
connection.OnClientEvent:Connect(function(p, data)
	if p == "setcore" then
		repeat
			local v8 = pcall(function()
				StarterGui:SetCore("ResetButtonCallback", data.enabled)
			end)
			task.wait(0.25)
		until v8
	elseif p == "setcoregui" then
		StarterGui:SetCoreGuiEnabled(data.core, data.enabled)
	elseif p == "default_announcement" then
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = `[Announcement]: {data.Message}`,
			Color = Color3.fromRGB(100, 215, 255),
			Font = Enum.Font.Highway,
			FontWeight = Enum.FontWeight.Regular,
			FontSize = Enum.FontSize.Size24
		})
	end
end)
openGui.OnClientEvent:Connect(function(p, p2)
	if p == "Menu" then
		local action = p2.Action

		if action == "Close" then
			ReplicatedStorage.OtherEvent.GuiEvents.GuiEvent:Fire({
				MenuName = "Menu",
				Action = "Close"
			})
		end
	elseif p == "Fade" then
		local fadeGui = playerGui:FindFirstChild("FadeGui")
		local fade = fadeGui and fadeGui:FindFirstChild("Fade")

		if fade then
			fade.Position = UDim2.new(-1.5, 0, 0.5, 0)
			TweenService:Create(fade, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
				Position = UDim2.new(2.5, 0, 0.5, 0)
			}):Play()
		end
	elseif p == "MiniFade" then
		local fadeGui = playerGui:FindFirstChild("FadeGui")
		local fade = fadeGui and fadeGui:FindFirstChild("Fade")

		if fade then
			fade.Position = UDim2.new(-1.5, 0, 0.5, 0)
			TweenService:Create(fade, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
				Position = UDim2.new(2.5, 0, 0.5, 0)
			}):Play()
		end
	else
		NPCTalks.StartTalking(p, p2)
	end
end)

local function SetGradient(state, p: string)
	if p == "Red" then
		state.TextColor3 = Color3.fromRGB(255, 48, 44)
		state.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(255, 48, 44)
		state.UIStroke.Color = Color3.fromRGB(100, 20, 20)
	elseif p == "Yellow" then
		state.TextColor3 = Color3.fromRGB(238, 201, 86)
		state.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(238, 201, 86)
		state.UIStroke.Color = Color3.fromRGB(125, 100, 45)
	elseif p == "Green" then
		state.TextColor3 = Color3.fromRGB(89, 255, 0)
		state.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(89, 255, 0)
		state.UIStroke.Color = Color3.fromRGB(40, 115, 0)
	elseif p == "Cyan" then
		state.TextColor3 = Color3.fromRGB(55, 206, 223)
		state.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(55, 206, 223)
		state.UIStroke.Color = Color3.fromRGB(25, 100, 100)
	elseif p == "Blue" then
		state.TextColor3 = Color3.fromRGB(57, 104, 252)
		state.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(57, 104, 252)
		state.UIStroke.Color = Color3.fromRGB(25, 50, 100)
	elseif p == "Purple" then
		state.TextColor3 = Color3.fromRGB(137, 0, 254)
		state.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(137, 0, 254)
		state.UIStroke.Color = Color3.fromRGB(50, 0, 100)
	else
		state.TextColor3 = Color3.fromRGB(255, 48, 44)
		state.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(255, 48, 44)
		state.UIStroke.Color = Color3.fromRGB(100, 20, 20)
	end
end

local function VisibleText(instance)
	local damageCounter3 = instance:FindFirstChild("MainGui"):FindFirstChild("DamageCounter")

	if damageCounter3 then
		damageCounter3.Visible = true
	end
end

local v8 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function InVisibleText(playerGui2)
	local damageCounter3 = playerGui2:FindFirstChild("MainGui"):FindFirstChild("DamageCounter")

	if damageCounter3 then
		FadeModule.FadeOut(damageCounter3, 0.1)
		task.wait(0.1)
		damageCounter3.Visible = false
	end
end

local function HitComboChanged(text)
	if playerGui and text > 0 and damageCounter2.Value == true and damageCounter then
		if thread then
			task.cancel(thread)
			thread = nil
		end

		local now = os.clock()
		v8 = now
		damageCounter.Damage.Text = text

		if text > 0 and text < 2500 then
			local damage = damageCounter.Damage
			damage.TextColor3 = Color3.fromRGB(255, 48, 44)
			damage.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(255, 48, 44)
			damage.UIStroke.Color = Color3.fromRGB(100, 20, 20)
		elseif text >= 2500 and text < 4000 then
			local damage = damageCounter.Damage
			damage.TextColor3 = Color3.fromRGB(238, 201, 86)
			damage.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(238, 201, 86)
			damage.UIStroke.Color = Color3.fromRGB(125, 100, 45)
		elseif text >= 4000 and text < 7500 then
			local damage = damageCounter.Damage
			damage.TextColor3 = Color3.fromRGB(89, 255, 0)
			damage.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(89, 255, 0)
			damage.UIStroke.Color = Color3.fromRGB(40, 115, 0)
		elseif text >= 7500 and text < 10000 then
			local damage = damageCounter.Damage
			damage.TextColor3 = Color3.fromRGB(55, 206, 223)
			damage.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(55, 206, 223)
			damage.UIStroke.Color = Color3.fromRGB(25, 100, 100)
		elseif text >= 10000 and text < 20000 then
			local damage = damageCounter.Damage
			damage.TextColor3 = Color3.fromRGB(57, 104, 252)
			damage.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(57, 104, 252)
			damage.UIStroke.Color = Color3.fromRGB(25, 50, 100)
		elseif text >= 20000 then
			local damage = damageCounter.Damage
			damage.TextColor3 = Color3.fromRGB(137, 0, 254)
			damage.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(137, 0, 254)
			damage.UIStroke.Color = Color3.fromRGB(50, 0, 100)
		end

		local damageCounter3 = damageCounter.Visible == false and playerGui:FindFirstChild("MainGui"):FindFirstChild("DamageCounter")

		if damageCounter3 then
			damageCounter3.Visible = true
		end

		FadeModule.FadeIn(damageCounter, 0.1)
		damageCounter.Damage.Size = UDim2.new(0.885, 0, 0.75, 0)
		damageCounter.Frame.Bar.Size = UDim2.new(1, 0, 1, 0)
		TweenService:Create(damageCounter.Frame.Bar, TweenInfo.new(3, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 1, 0)
		}):Play()
		TweenService:Create(damageCounter.Damage, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0.885, 0, 0.5, 0)
		}):Play()
		thread = task.delay(3, function()
			if now == v8 and damageCounter and hitDamage and damageCounter:FindFirstChild("Frame") then
				InVisibleText(playerGui) -- equivalent call inferred; original call site unknown
				local damage = damageCounter.Damage
				damage.TextColor3 = Color3.fromRGB(255, 48, 44)
				damage.Parent.Frame.Bar.ImageColor3 = Color3.fromRGB(255, 48, 44)
				damage.UIStroke.Color = Color3.fromRGB(100, 20, 20)
				hitDamage.Value = 0
			end

			if thread then
				thread = nil
			end
		end)
	end
end

local function CharacterCloned()
	if localPlayer:GetAttribute("TeamSelected") == nil then
		local clone = ReplicatedStorage.Character_Storage.Loader:Clone()
		clone.Parent = workspace.PlayerDummy

		if clone:FindFirstChild("Humanoid") then
			clone.Humanoid:ApplyDescription(game.Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId))
			local track = clone.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Animation_Folder.FreeStyle.Dance1)

			if not track.IsPlaying then
				track:Play()
			end
		end
	end
end

local function LoadNPC_Animation()
	local maxwell = workspace.NPCs.FightingStyle_Npc:FindFirstChild("Maxwell") or nPC_Storage:FindFirstChild("Maxwell")
	local baller = workspace.NPCs.FightingStyle_Npc:FindFirstChild("Baller") or nPC_Storage:FindFirstChild("Baller")
	local halvedSorcerer = workspace.NPCs.Misc_Npc:FindFirstChild("Halved Sorcerer") or nPC_Storage:FindFirstChild("Halved Sorcerer")

	if maxwell then
		local animationController = maxwell:FindFirstChild("AnimationController")
		local animator = animationController and animationController:FindFirstChild("Animator")

		if animator then
			animator:LoadAnimation(ReplicatedStorage.Animation_Folder.NPCs.Maxwell_Dance):Play()
		end
	end

	if baller then
		local humanoid = baller:FindFirstChild("Humanoid")
		local animator = humanoid and humanoid:FindFirstChild("Animator")

		if animator then
			animator:LoadAnimation(ReplicatedStorage.Animation_Folder.NPCs.Baller_Idle):Play()
		end
	end

	if halvedSorcerer then
		local humanoid = halvedSorcerer:FindFirstChild("Humanoid")
		local animator = humanoid and humanoid:FindFirstChild("Animator")

		if animator then
			animator:LoadAnimation(ReplicatedStorage.Animation_Folder.NPCs.Sorcerer_Idle):Play()
		end
	end
end

local function Setup_BoatName()
	for _, child in ipairs(workspace.BoatFolder:GetChildren()) do
		local boatOwner = child:FindFirstChild("Boat Owner")
		local flag = child:FindFirstChild("Flag")

		if not (boatOwner and flag) then
			continue
		end

		flag.BoatNameGui.Enabled = true
		flag.BoatNameGui.NameText.Text = `{boatOwner.Value}'s Boat`
	end
end

local function Setup_MoneyBag(tool)
	if tool then
		local info = tool:IsA("Tool") and tool:GetAttribute("Amount") and tool:GetAttribute("Owner") and tool:WaitForChild("Handle"):FindFirstChild("Info")

		if info then
			if info.Enabled == false then
				info.Enabled = true
			end

			info.Frame.Amountlabel.Text = `${Abbreviate.Comma(tool:GetAttribute("Amount"))}`
		end
	else
		local tagged = CollectionService:GetTagged("MoneyBag")

		for _, tool2 in ipairs(tagged) do
			if not (tool2:IsA("Tool") and tool2:GetAttribute("Amount") and tool2:GetAttribute("Owner")) then
				continue
			end

			local info = tool2:WaitForChild("Handle"):FindFirstChild("Info")

			if not info then
				continue
			end

			if info.Enabled == false then
				info.Enabled = true
			end

			info.Frame.Amountlabel.Text = `${Abbreviate.Comma(tool2:GetAttribute("Amount"))}`
		end
	end
end

pcall(CharacterCloned)
LoadNPC_Animation()
Setup_BoatName()
Setup_MoneyBag()
hitDamage.Changed:Connect(HitComboChanged)
CollectionService:GetInstanceAddedSignal("MoneyBag"):Connect(Setup_MoneyBag)