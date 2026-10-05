local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
workspace:WaitForChild("BoatFolder")
workspace:WaitForChild("Raids")
local character = workspace:WaitForChild("Character")
local spawnLocations = workspace:WaitForChild("Location"):WaitForChild("SpawnLocations")
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
local islandThemes = ReplicatedStorage:WaitForChild("IslandThemes")
local modules = ReplicatedStorage:WaitForChild("Modules")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local assets = ReplicatedStorage:WaitForChild("Assets")
local skillFolder = ReplicatedStorage:WaitForChild("SkillFolder")
local misc = modules:WaitForChild("Misc")
local tool = animation_Folder:WaitForChild("Tool")
local race_Assets = assets:WaitForChild("Race_Assets")
local accessories = assets:WaitForChild("Accessories")
local race_Accessory = race_Assets:WaitForChild("Race_Accessory")
local miscEvents = otherEvent:WaitForChild("MiscEvents")
local Zone = require(misc:WaitForChild("Zone"))
require(moduleScript:WaitForChild("Abbreviate"))
local Aura_Color = require(moduleScript:WaitForChild("Aura_Color"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local SetText = require(moduleScript:WaitForChild("SetText"))
local seaTheme = islandThemes:WaitForChild("Sea Theme")
local playerSettings = localPlayer:WaitForChild("PlayerSettings", 60)
local spawnPoint = localPlayer:WaitForChild("PlayerData", 60):WaitForChild("SpawnPoint")
local musicVolume = playerSettings:WaitForChild("MusicVolume")
local soundEffects = playerSettings:WaitForChild("SoundEffects")
local spawnPoint2 = miscEvents:WaitForChild("SpawnPoint")
local v = {
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
local v2 = nil
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
local v4 = {
	"RightHand",
	"LeftHand",
	"LeftLowerArm",
	"RightLowerArm"
}
local v5 = {}

while localPlayer:GetAttribute("LoadedData") == nil do
	task.wait(1)
end

seaTheme.Volume = musicVolume.Value
seaTheme:Play()
local changedConnection = musicVolume.Changed:Connect(function()
	seaTheme.Volume = musicVolume.Value
end)

while localPlayer:GetAttribute("TeamSelected") == nil do
	task.wait(1)
end

if changedConnection then
	changedConnection:Disconnect()
end

script:SetAttribute("LastText", os.time())

local function CheckPlayer()
	if localPlayer and localPlayer.Parent and localPlayer.Character and localPlayer.Character.Parent and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character:FindFirstChild("Humanoid").Health > 0 and os.time() - localPlayer.Character:GetAttribute("SpawnTime") >= 2 then
		return true
	end

	return false
end

local function floorNumber(value)
	return (math.floor(value or 0))
end

local function color3torgb(value)
	return value.R * 255, value.G * 255, value.B * 255
end

local function PauseAllMusics(name)
	for _, child in ipairs(islandThemes:GetChildren()) do
		if not (child.IsPlaying and child.Name ~= name) then
			continue
		end

		child.Volume = 0
		child:Pause()
	end
end

local function PlaySeaTheme()
	if seaTheme.IsPaused then
		if math.floor(seaTheme.Volume or 0) == 0 and v2 == nil then
			v2 = TweenService:Create(
				seaTheme,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
				{
					Volume = musicVolume.Value
				}
			)
			v2:Play()
		end

		seaTheme:Resume()
	elseif not seaTheme.IsPlaying then
		if math.floor(seaTheme.Volume or 0) == 0 and v2 == nil then
			v2 = TweenService:Create(
				seaTheme,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
				{
					Volume = musicVolume.Value
				}
			)
			v2:Play()
		end

		seaTheme:Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetupVolume()
	for _, child in ipairs(islandThemes:GetChildren()) do
		child.Volume = musicVolume.Value
	end
end

local function SetupSoundEffects()
	for _, sound in ipairs(CollectionService:GetTagged("SFX")) do
		if sound:IsA("Sound") then
			sound.Volume = soundEffects.Value / (sound:GetAttribute("Volume_Divide") or 1)
		end
	end
end

local function Highlight_On(starterGear, model, value, folder)
	if value == "Default" and model and model.Parent and starterGear then
		local value2 = nil

		for _, tool2 in ipairs(starterGear:GetChildren()) do
			if not (tool2:IsA("Tool") and tool2:FindFirstChild("Handle")) then
				continue
			end

			local handle = tool2:FindFirstChild("Handle")
			local trail

			if handle then
				trail = handle:FindFirstChild("Trail")
			end

			if not (trail and trail:IsA("Trail")) then
				continue
			end

			value2 = trail.Color.Keypoints[1].Value
			break
		end

		if value2 then
			local auraColor_Folder = model:FindFirstChild("AuraColor_Folder")

			if auraColor_Folder then
				for _, part in ipairs(auraColor_Folder:GetChildren()) do
					if not (part:IsA("BasePart") and string.find(part.Name, "AuraColor")) then
						continue
					end

					TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Color = Color3.fromRGB(color3torgb(value2))
					}):Play()
				end
			end
		end
	end

	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") and effect.Name == "Aura_Lighting" then
			if effect:GetAttribute("Original_Color") == nil then
				effect:SetAttribute("Original_Color", effect.Color)
			end

			if value == "Default" then
				effect.Color = effect:GetAttribute("Original_Color") or ColorSequence.new(Color3.fromRGB(255, 255, 255))
			elseif value == "Spectrum" then
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
				effect.Color = ColorSequence.new(Aura_Color.ConvertColor[value])
			end

			if not effect.Enabled then
				Generate.SetParticle(effect)
				effect.Enabled = true
			end
		elseif effect:IsA("Beam") and effect.Name == "Aura_Beam" then
			if effect:GetAttribute("Original_Beam") == nil then
				effect:SetAttribute("Original_Beam", effect.Color)
			end

			if value == "Default" then
				effect.Color = effect:GetAttribute("Original_Beam") or ColorSequence.new(Color3.fromRGB(255, 255, 255))
			elseif value == "Spectrum" then
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
				effect.Color = ColorSequence.new(Aura_Color.ConvertColor[value])
			end

			if not effect.Enabled then
				effect.Enabled = true
			end
		elseif effect:IsA("Trail") and effect.Name == "Trail" or effect.Name == "Trail2" then
			if effect:GetAttribute("Original_Trail") == nil then
				effect:SetAttribute("Original_Trail", effect.Color)
			end

			if value == "Default" then
				effect.Color = effect:GetAttribute("Original_Trail") or ColorSequence.new(Color3.fromRGB(255, 255, 255))
			elseif value == "Spectrum" then
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
				effect.Color = ColorSequence.new(Aura_Color.ConvertColor[value])
			end
		end
	end
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
			weld.C1 = v[clone.Name]
			weld.Parent = handle
		end
	end
end

local function Set_RaceAccessory(model, value: string, childName: string)
	local child = race_Accessory:FindFirstChild(value)

	if child then
		local child2 = child:FindFirstChild(childName)

		if child2 and model:FindFirstChild(childName) == nil then
			CFrameAccessoryToCharacter(model, child2:Clone(), childName)
		end
	end
end

local function SetupCharacter()
	local DISTANCE_THRESHOLD = 1000

	for _, model in ipairs(character:GetChildren()) do
		if not (model:IsA("Model") and model.Name ~= localPlayer.Name) then
			continue
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(model)

		if playerFromCharacter and playerFromCharacter.Team then
			local playerData = playerFromCharacter:FindFirstChild("PlayerData")
			local ability = playerFromCharacter:FindFirstChild("Ability")

			if playerData and ability then
				local race = playerData:FindFirstChild("Race")
				local accessoryEquip = playerData:WaitForChild("AccessoryEquip")

				if accessoryEquip and accessoryEquip.Value ~= "None" then
					local child = accessories:FindFirstChild(accessoryEquip.Value)

					if child and model:FindFirstChild(accessoryEquip.Value) == nil then
						CFrameAccessoryToCharacter(model, child:Clone(), accessoryEquip.Value)
					end
				end

				if race then
					if race.Value == "Fish" then
						local fishAwaken = ability:FindFirstChild("FishAwaken")

						if fishAwaken and fishAwaken.Value == true then
							Set_RaceAccessory(model, race.Value, "SharkFin_V2")
						else
							Set_RaceAccessory(model, race.Value, "SharkFin")
						end
					elseif race.Value == "Rabbit" then
						local rabbitAwaken = ability:FindFirstChild("RabbitAwaken")

						if rabbitAwaken and rabbitAwaken.Value == true then
							Set_RaceAccessory(model, race.Value, "BunnyEars_V2")
						else
							Set_RaceAccessory(model, race.Value, "BunnyEars")
						end
					elseif race.Value == "Bird" then
						local birdAwaken = ability:FindFirstChild("BirdAwaken")

						if birdAwaken and birdAwaken.Value == true then
							Set_RaceAccessory(model, race.Value, "Wings_V2")
						else
							Set_RaceAccessory(model, race.Value, "Wings")
						end
					end
				end
			end

			local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart:FindFirstChild("Died") then
				humanoidRootPart.Died.SoundId = "rbxassetid://958257111"
				humanoidRootPart.Died.RollOffMaxDistance = 1000
				humanoidRootPart.Died.RollOffMinDistance = 50
			end
		end

		if model:GetAttribute("Using_Aura") then
			local auraColor_Folder = model:FindFirstChild("AuraColor_Folder")
			local playerFromCharacter2 = Players:GetPlayerFromCharacter(model)

			if playerFromCharacter2 and auraColor_Folder then
				local playerData = playerFromCharacter2:FindFirstChild("PlayerData")
				local auraColor

				if playerData then
					auraColor = playerData:FindFirstChild("AuraColor")
				end

				if auraColor then
					local starterGear = playerFromCharacter2:FindFirstChild("StarterGear")
					local backpack = playerFromCharacter2:FindFirstChild("Backpack")

					if starterGear and backpack then
						for _, tool2 in ipairs(model:GetChildren()) do
							if not (tool2:IsA("Tool") and tool2:FindFirstChild("Handle") and tool2:GetAttribute("Aura") == false) then
								continue
							end

							Highlight_On(starterGear, model, auraColor.Value, tool2)
						end

						for _, tool2 in ipairs(backpack:GetChildren()) do
							if not (tool2:IsA("Tool") and tool2:FindFirstChild("Handle") and tool2:GetAttribute("Aura") == false) then
								continue
							end

							Highlight_On(starterGear, model, auraColor.Value, tool2)
						end
					end

					for _, childName in ipairs(v4) do
						if not model:FindFirstChild(childName) then
							continue
						end

						local clone = model:FindFirstChild(childName):Clone()
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

						if auraColor.Value == "Spectrum" then
							clone:AddTag("RainbowAura")
						end

						local weld = Instance.new("Weld")
						weld.Name = `{childName}_AuraColorWeld`
						weld.Parent = clone
						weld.Part0 = model:FindFirstChild(childName)
						weld.Part1 = clone
						local clone2 = model:FindFirstChild(childName):Clone()
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
						weld2.Part0 = model:FindFirstChild(childName)
						weld2.Part1 = clone2

						if auraColor.Value == "Default" then
							if starterGear then
								local value = nil

								for _, tool2 in ipairs(starterGear:GetChildren()) do
									if not (tool2:IsA("Tool") and tool2:FindFirstChild("Handle")) then
										continue
									end

									local handle = tool2:FindFirstChild("Handle")
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
									if (clone.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
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
						elseif (clone.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
							TweenService:Create(
								clone,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									Color = Aura_Color.ConvertColor[auraColor.Value]
								}
							):Play()
						else
							clone.Color = Aura_Color.ConvertColor[auraColor.Value]
						end

						if model:GetAttribute("Invisible") then
							clone2:SetAttribute("Original_Transparency", 0)

							if (clone2.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
								TweenService:Create(
									clone2,
									TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										Transparency = 1,
										Color = Color3.fromRGB(0, 0, 0)
									}
								):Play()
								local v6 = clone
								task.delay(0.25, function()
									v6:SetAttribute("Original_Transparency", 0.85)
									TweenService:Create(
										v6,
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
						elseif (clone2.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
							TweenService:Create(
								clone2,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									Transparency = 0,
									Color = Color3.fromRGB(0, 0, 0)
								}
							):Play()
							local v6 = clone
							task.delay(0.25, function()
								TweenService:Create(
									v6,
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
				end
			end
		end

		if model:GetAttribute("Invisible") then
			if model:GetAttribute("Using_Aura") then
				local auraColor_Folder = model:FindFirstChild("AuraColor_Folder")

				for _, child in ipairs(auraColor_Folder:GetChildren()) do
					child:SetAttribute("Original_Transparency", child.Transparency)
					child.Transparency = 1
				end
			end

			for _, child in ipairs(model:GetChildren()) do
				if child:IsA("BasePart") or child:IsA("MeshPart") and child.Transparency < 1 then
					child:SetAttribute("Original_Transparency", child.Transparency)
					child.Transparency = 1
				elseif child:IsA("Accessory") then
					local handle = child:FindFirstChild("Handle")

					if handle then
						if handle.Transparency < 1 then
							handle:SetAttribute("Original_Transparency", handle.Transparency)
							handle.Transparency = 1
						end

						for _, descendant in pairs(handle:GetDescendants()) do
							if descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation") or descendant:IsA("Decal") and descendant.Transparency < 1 then
								descendant:SetAttribute("Original_Transparency", descendant.Transparency)
								descendant.Transparency = 1
							elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") and descendant.Enabled then
								descendant.Enabled = false
							end
						end
					end
				end
			end
		elseif model:GetAttribute("Transform") then
			local transform = model:GetAttribute("Transform")

			if transform == "Gold" then
				local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and not humanoidRootPart:FindFirstChild("Gold_Attachment") then
					local clone = skillFolder["Gold Power"].C.Gold_Attachment:Clone()
					clone.Parent = humanoidRootPart

					for _, emitter in ipairs(clone:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						emitter.Enabled = true
					end
				end

				local folder = Instance.new("Folder")
				folder.Name = "Golden_Folder"
				folder.Parent = model

				for _, part in ipairs(model:GetChildren()) do
					if not (part:IsA("MeshPart") and part.Transparency < 1) then
						continue
					end

					local clone = part:Clone()
					clone.Name = `{part}_ClonedBody`
					clone:ClearAllChildren()
					clone.Transparency = 1
					clone.Massless = true
					clone.TextureID = ""
					clone.Size += createVector(0.015, 0.015, 0.015)
					clone.Color = Color3.fromRGB(255, 255, 255)
					clone.Material = Enum.Material.Glass
					clone.Parent = folder
					local weld = Instance.new("Weld")
					weld.Name = `{part}_ClonedBodyWeld`
					weld.Parent = clone
					weld.Part0 = part
					weld.Part1 = clone

					if (clone.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
						TweenService:Create(
							clone,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 0,
								Color = Color3.fromRGB(239, 184, 56)
							}
						):Play()
					else
						clone.Transparency = 0
						clone.Color = Color3.fromRGB(239, 184, 56)
					end
				end
			elseif transform == "Diamond" then
				for _, child in ipairs(model:GetChildren()) do
					if child:IsA("MeshPart") and child.Transparency < 1 then
						child:SetAttribute("Old_Texture", child.TextureID)
						child.TextureID = "rbxassetid://18231265025"
					elseif child:IsA("Shirt") then
						if child.ShirtTemplate ~= "" then
							child:SetAttribute("Old_ShirtTemplate", child.ShirtTemplate)
							child.ShirtTemplate = "http://www.roblox.com/asset/?id=0"
						end
					elseif child:IsA("Pants") then
						if child.PantsTemplate ~= "" then
							child:SetAttribute("Old_PantsTemplate", child.PantsTemplate)
							child.PantsTemplate = "http://www.roblox.com/asset/?id=0"
						end
					elseif child:IsA("ShirtGraphic") then
						if child.Graphic ~= "" then
							child:SetAttribute("Old_TShirtTemplate", child.Graphic)
							child.Graphic = "http://www.roblox.com/asset/?id=0"
						end
					elseif child:IsA("Accessory") then
						local handle = child:FindFirstChild("Handle")

						if handle then
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
								TweenService:Create(
									handle,
									TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Color = Color3.fromRGB(61, 252, 255)
									}
								):Play()
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
						end
					end
				end
			end
		end
	end
end

local function SetupEffect(instance)
	if instance then
		if instance:IsA("ParticleEmitter") and instance.Enabled == false then
			instance.Enabled = true
		elseif instance:IsA("Smoke") and instance.Enabled == false then
			instance.Enabled = true
		elseif instance:IsA("Fire") and instance.Enabled == false then
			instance.Enabled = true
		end
	else
		for _, instance2 in ipairs(CollectionService:GetTagged("ClientEffect")) do
			if instance2:IsA("ParticleEmitter") and instance2.Enabled == false then
				instance2.Enabled = true
			elseif instance2:IsA("Smoke") and instance2.Enabled == false then
				instance2.Enabled = true
			elseif instance2:IsA("Fire") and instance2.Enabled == false then
				instance2.Enabled = true
			end
		end
	end
end

local function Setup_ToolAnimations(instance)
	if instance then
		local animationController = instance:WaitForChild("AnimationController", 5)

		if animationController then
			local animator = animationController:WaitForChild("Animator", 5)
			local child = animator and tool:FindFirstChild(instance.Name)

			if child then
				animator:LoadAnimation(child):Play()
			end
		end
	else
		for _, v6 in ipairs(CollectionService:GetTagged("Animated_Model")) do
			local animationController = v6:WaitForChild("AnimationController", 5)

			if not animationController then
				continue
			end

			local animator = animationController:WaitForChild("Animator", 5)

			if not animator then
				continue
			end

			local child = tool:FindFirstChild(v6.Name)

			if child then
				animator:LoadAnimation(child):Play()
			end
		end
	end
end

if seaTheme.IsPlaying then
	seaTheme:Pause()
end

for i, child in ipairs(workspace.Region.MusicArea:GetChildren()) do
	v5[i] = Zone.new(child)
	local v6 = child
	v5[i].localPlayerEntered:Connect(function()
		script:SetAttribute("LastText", os.time())
		SetText.SetText(localPlayer, "CustomMessage", {
			Message = `「 {v6.Name} 」`,
			Duration = 3,
			Type = "Zone"
		})
		local child2 = spawnLocations:FindFirstChild(v6.Name)

		if child2 and not child2:GetAttribute("Ignore") and spawnPoint.Value ~= child2.Name then
			spawnPoint2:FireServer(child2.Name)
		end

		local islandTheme = islandThemes[v6.Name]

		if islandTheme then
			if v2 then
				v2:Cancel()
				v2 = nil
				seaTheme:Pause()
			end

			PauseAllMusics(v6.Name)

			if islandTheme.IsPaused then
				if math.floor(islandTheme.Volume or 0) ~= musicVolume.Value then
					islandTheme.Volume = musicVolume.Value
				end

				islandTheme:Resume()
			elseif islandTheme.IsPlaying then
				if islandTheme.IsPlaying and math.floor(islandTheme.Volume or 0) ~= musicVolume.Value then
					islandTheme.Volume = musicVolume.Value
				end
			else
				if math.floor(islandTheme.Volume or 0) ~= musicVolume.Value then
					islandTheme.Volume = musicVolume.Value
				end

				islandTheme:Play()
			end
		end
	end)
	local v7 = child
	v5[i].localPlayerExited:Connect(function()
		if CheckPlayer() then
			if os.time() - script:GetAttribute("LastText") >= 1 then
				script:SetAttribute("LastText", os.time())

				if localPlayer:GetAttribute("Raiding") then
					if localPlayer:GetAttribute("TH") then
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "「 เกาะดันเจี้ยน 」",
							Duration = 3,
							Type = "Zone"
						})
					else
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "「 Raid Island 」",
							Duration = 3,
							Type = "Zone"
						})
					end
				elseif localPlayer:GetAttribute("TH") then
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "「 ทะเล 」",
						Duration = 3,
						Type = "Zone"
					})
				else
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "「 Sea 」",
						Duration = 3,
						Type = "Zone"
					})
				end
			end

			local islandTheme = islandThemes[v7.Name]

			if islandTheme and islandTheme.IsPlaying then
				if v2 then
					v2:Cancel()
					v2 = nil
					seaTheme:Pause()
				end

				islandTheme.Volume = 0
				islandTheme:Pause()
				PlaySeaTheme()
			end
		end
	end)
end

SetupVolume() -- equivalent call inferred; original call site unknown
SetupSoundEffects()
CollectionService:GetInstanceAddedSignal("ClientEffect"):Connect(SetupEffect)
CollectionService:GetInstanceAddedSignal("Animated_Model"):Connect(Setup_ToolAnimations)
musicVolume.Changed:Connect(SetupVolume)
soundEffects.Changed:Connect(SetupSoundEffects)
SetupEffect()
SetupCharacter()
Setup_ToolAnimations()