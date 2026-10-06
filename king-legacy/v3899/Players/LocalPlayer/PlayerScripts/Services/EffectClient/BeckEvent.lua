local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local characterWorkshop = workspace.CharacterWorkshop
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local chest = ReplicatedStorage:WaitForChild("Chest")
local modules = chest:WaitForChild("Modules")
local Utility = require(modules.Utility)
local IslandInfo = require(modules:WaitForChild("IslandInfo"))
local FastRenderer = require(modules.FastRenderer)
local CollectibleList = require(modules:WaitForChild("CollectibleList"))
local WorldsId = require(modules:WaitForChild("WorldsId"))
local MaterialList = require(modules:WaitForChild("MaterialList"))
local SwordList = require(modules:WaitForChild("SwordList"))
local AccessoriesList = require(modules:WaitForChild("AccessoriesList"))
local TierColor = require(modules:WaitForChild("TierColor"))
local PeodizService = require(modules:WaitForChild("PeodizService"))
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local currentCamera = workspace.CurrentCamera
local v = {
	[WorldsId.Testing.GoldenArena] = true,
	[WorldsId.KingLegacy.GoldenArena] = true
}
local DecalAngles = require(ReplicatedStorage.Chest.Modules.DecalAngles)
local CustomNames = require(chest.Modules.CustomNames)

function GenerateTextSystem(data)
	return ("<font color='#" .. (data.Color and data.Color:ToHex() or Color3.fromRGB(255, 255, 255):ToHex()) .. "'>") .. ("<font face='" .. (data.Font or "Gotham") .. "'>") .. ("<font size='" .. (data.FontSize or "18") .. "'>") .. data.Text .. "</font></font></font>"
end

function Suffix(p)
	local v2 = math.floor(p)

	if p >= 1000 and p < 1000000 then
		return tostring(math.floor(p / 1000 * 100) / 100) .. "K"
	end

	if p >= 1000000 and p < 1000000000 then
		return tostring(math.floor(p / 1000000 * 100) / 100) .. "M"
	end

	if p >= 1000000000 and p < 1000000000000 then
		return tostring(math.floor(p / 1000000000 * 100) / 100) .. "B"
	end

	if p >= 1000000000000 and p < 1000000000000000 then
		return tostring(math.floor(p / 1000000000000 * 100) / 100) .. "T"
	end

	if p >= 1000000000000000 then
		return tostring(math.floor(p / 1000000000000000 * 100) / 100) .. "Q"
	end

	return v2
end

ReplicatedStorage.Chest.Remotes.Events.ScreenShakeSwordHit.OnClientEvent:Connect(function(_)
	_G.BeckCameraShake(_G.CameraShakerModule.Presets.SwordHit)
end)
local v2 = {
	WhooshAquaticAnchor = {
		SoundId = "rbxassetid://10895719516",
		Volume = 0.1
	},
	WhooshAxe = {
		SoundId = "rbxassetid://6871821418",
		Volume = 0.1
	},
	WhooshBaton = {
		SoundId = "rbxassetid://6871821418",
		Volume = 0.1
	},
	WhooshBig = {
		SoundId = "rbxassetid://10689191236",
		Volume = 0.25
	},
	WhooshCombat = {
		SoundId = "rbxassetid://4998916098",
		Volume = 0.15,
		PlaybackSpeed = 1.3
	},
	WhooshCombatFast = {
		SoundId = "rbxassetid://10499289939",
		Volume = 0.2
	},
	WhooshDagger = {
		SoundId = "rbxassetid://11048506157",
		Volume = 0.15
	},
	WhooshDrakenFangs = {
		SoundId = "rbxassetid://8373257361",
		Volume = 0.1,
		PlaybackSpeed = 2
	},
	WhooshHammer = {
		SoundId = "rbxassetid://11051570906",
		Volume = 0.25
	},
	WhooshKatana = {
		SoundId = "rbxassetid://98027496650602",
		Volume = 0.1
	},
	WhooshNB = {
		SoundId = "rbxassetid://9099051717",
		Volume = 0.1,
		PlaybackSpeed = 0.75
	},
	WhooshNoSharp = {
		SoundId = "rbxassetid://11051713180",
		Volume = 0.15
	},
	WhooshPondere = {
		SoundId = "rbxassetid://8364577736",
		Volume = 0.1,
		PlaybackSpeed = 2.5
	},
	WhooshRapier = {
		SoundId = "rbxassetid://10029943632",
		Volume = 0.2,
		PlaybackSpeed = 1.5
	},
	WhooshSweetLozenge = {
		SoundId = "rbxassetid://8373257361",
		Volume = 0.1
	},
	WhooshDawnbreaker = {
		SoundId = "rbxassetid://115808947848727",
		Volume = 0.25
	},
	["Whoosh Bloodshell Edge"] = {
		SoundId = "rbxassetid://71074493246362",
		Volume = 0.25
	},
	Acrodagger = {
		SoundId = "rbxassetid://137720090365468",
		Volume = 0.2
	}
}

function CreateSound(p)
	local rootPart = p.RootPart
	local sound = p.Sound
	local playbackSpeed = 1
	local soundId, volume

	if sound and v2[sound] then
		soundId = v2[sound].SoundId
		volume = v2[sound].Volume

		if v2[sound].PlaybackSpeed then
			playbackSpeed = v2[sound].PlaybackSpeed
		end
	else
		soundId = "rbxassetid://4571259077"
		volume = 0.75
	end

	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 100,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.Linear,
		SoundId = soundId,
		Volume = volume,
		PlaybackSpeed = playbackSpeed
	})
	_G.PU:Dust(sound2, 2)
	sound2.Parent = rootPart
	sound2:Play()
end

function SlashDecal(p, player)
	local DELAY_DURATION = 0.25
	local rootPart = player.RootPart
	local animationPlaying = player.AnimationPlaying
	local type = player.Type
	local color = player.Color
	local scale = player.Scale
	local sound = player.Sound
	local _ = player.Character
	local sound2 = sound or "Whoosh"
	local scale2 = scale or createVector(8, 0.5, 8)
	local color2 = color or Color3.fromRGB(1000, 1000, 1000)
	local decalAngle = DecalAngles[type]

	if not decalAngle then
		return
	end

	if _G.CheckAwakeClient(p, type) then
		type ..= " Awake"
	end

	if type == "Triple Katana" or type == "Authentic Triple Katana" or player.MultiSwords then
		local child = characterWorkshop:FindFirstChild(p.Name .. "Real Sword")

		if child then
			CreateSound({
				RootPart = rootPart,
				Sound = sound2
			})

			if decalAngle["Stab" .. animationPlaying] then
				task.delay(DELAY_DURATION, function()
					local v6 = rootPart.CFrame * decalAngle[animationPlaying]
					local clone = ReplicatedStorage.Chest.SwordEffect.SoulCane.rapierfx:Clone()
					_G.PU:Dust(clone, 2)
					local center = clone.Center
					center.Attachment.BarrageWaves.Color = ColorSequence.new(color2)
					center.Attachment.Lines.Color = ColorSequence.new(color2)
					clone.part0.Decal.Color3 = color2
					clone.part1.Decal.Color3 = color2
					clone:PivotTo(v6)
					clone.Parent = workspace.Effects
					local weld = Instance.new("Weld")
					_G.PU:Dust(weld, 2)
					weld.Part0 = rootPart
					weld.Part1 = center
					weld.C0 = CFrame.new(0, 0, -4)
					weld.Parent = center
					local mesh = clone.part0.Mesh
					local mesh2 = clone.part1.Mesh
					local decal = clone.part0.Decal
					local decal2 = clone.part1.Decal
					mesh.Scale = createVector(0.114, 0.119, 0.113)
					mesh2.Scale = createVector(0.211, 0.112, 0.133)
					center.Attachment.BarrageWaves:Emit(2)
					center.Attachment.Lines:Emit(8)
					wait()
					TweenService:Create(
						mesh,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Scale = createVector(0.114, 0, 0)
						}
					):Play()
					TweenService:Create(
						mesh2,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Scale = createVector(0.211, 0, 0)
						}
					):Play()
					task.wait(0.25)

					if decal and decal.Parent then
						decal.Transparency = 1
					end

					if decal2 and decal2.Parent then
						decal2.Transparency = 1
					end
				end)
			else
				if child:FindFirstChild("LeftHandModel") then
					task.delay(DELAY_DURATION, function()
						local clone = ReplicatedStorage.Chest.SwordEffect.SlashAni:Clone()
						clone.Massless = true
						clone.Anchored = false
						clone.Mesh.Scale = scale2
						clone.CFrame = rootPart.CFrame * decalAngle[animationPlaying]
						clone.Parent = workspace.Effects
						_G.PU:Dust(clone, 1)

						if player.SecondColor then
							local Animate = require(clone.Animate)
							Animate(player.SecondColor)
						else
							local Animate = require(clone.Animate)
							Animate(color2)
						end

						local weld = Instance.new("Weld")
						weld.Part0 = rootPart
						weld.Part1 = clone
						weld.C0 = decalAngle[animationPlaying]
						weld.Parent = clone
						_G.PU:Dust(weld, 1)
					end)
				end

				if child:FindFirstChild("RightHandModel") then
					task.delay(DELAY_DURATION, function()
						local v7

						if animationPlaying == 1 then
							v7 = 5
						elseif animationPlaying == 2 then
							v7 = 6
						elseif animationPlaying == 3 then
							v7 = 7
						elseif animationPlaying == 4 then
							v7 = 8
						else
							v7 = animationPlaying
						end

						if decalAngle[v7] then
							local clone = ReplicatedStorage.Chest.SwordEffect.SlashAni:Clone()
							clone.Massless = true
							clone.Anchored = false
							clone.Mesh.Scale = scale2
							clone.CFrame = rootPart.CFrame * decalAngle[v7]
							clone.Parent = workspace.Effects
							_G.PU:Dust(clone, 1)
							local Animate = require(clone.Animate)
							Animate(color2)
							local weld = Instance.new("Weld")
							weld.Part0 = rootPart
							weld.Part1 = clone
							weld.C0 = decalAngle[v7]
							weld.Parent = clone
							_G.PU:Dust(weld, 1)
						end
					end)
				end
			end
		end
	else
		CreateSound({
			RootPart = rootPart,
			Sound = sound2
		})
		task.delay(DELAY_DURATION, function()
			if decalAngle["Stab" .. animationPlaying] then
				local v6 = rootPart.CFrame * decalAngle[animationPlaying]
				local clone = ReplicatedStorage.Chest.SwordEffect.SoulCane.rapierfx:Clone()
				_G.PU:Dust(clone, 2)
				local center = clone.Center
				center.Attachment.BarrageWaves.Color = ColorSequence.new(color2)
				center.Attachment.Lines.Color = ColorSequence.new(color2)
				clone.part0.Decal.Color3 = color2
				clone.part1.Decal.Color3 = color2
				clone:PivotTo(v6)
				clone.Parent = workspace.Effects
				local weld = Instance.new("Weld")
				_G.PU:Dust(weld, 2)
				weld.Part0 = rootPart
				weld.Part1 = center
				weld.C0 = CFrame.new(0, 0, -4)
				weld.Parent = center
				local mesh = clone.part0.Mesh
				local mesh2 = clone.part1.Mesh
				local decal = clone.part0.Decal
				local decal2 = clone.part1.Decal
				mesh.Scale = createVector(0.114, 0.119, 0.113)
				mesh2.Scale = createVector(0.211, 0.112, 0.133)
				center.Attachment.BarrageWaves:Emit(2)
				center.Attachment.Lines:Emit(8)
				wait()
				TweenService:Create(mesh, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Scale = createVector(0.114, 0, 0)
				}):Play()
				TweenService:Create(
					mesh2,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Scale = createVector(0.211, 0, 0)
					}
				):Play()
				task.wait(0.25)

				if decal and decal.Parent then
					decal.Transparency = 1
				end

				if decal2 and decal2.Parent then
					decal2.Transparency = 1
				end
			else
				local clone = ReplicatedStorage.Chest.SwordEffect.SlashAni:Clone()
				clone.Massless = true
				clone.Anchored = false
				clone.Mesh.Scale = scale2
				clone.CFrame = rootPart.CFrame * decalAngle[animationPlaying]
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1)
				local Animate = require(clone.Animate)
				Animate(color2)
				local weld = Instance.new("Weld")
				weld.Part0 = rootPart
				weld.Part1 = clone
				weld.C0 = decalAngle[animationPlaying]
				weld.Parent = clone
				_G.PU:Dust(weld, 1)
			end
		end)
	end
end

ReplicatedStorage.Chest.Remotes.Events:WaitForChild("SwordM1", 30).OnClientEvent:Connect(function(p, player)
	local _ = player.Character
	local type = player.Type
	local localPlayer = game.Players.LocalPlayer
	local character = localPlayer.Character

	if not character then
		while not character do
			character = localPlayer.Character
			wait(0.15)
		end
	end

	pcall(function()
		if (character.HumanoidRootPart.Position - player.RootPart.Position).Magnitude > 100 then
		end
	end)

	if not DecalAngles[type] then
		return
	end

	if type ~= "TEST" then
		task.spawn(function()
			SlashDecal(p, player)
		end)
	end
end)
ReplicatedStorage.Chest.Remotes.Events.RaidSummon.OnClientEvent:Connect(function(p, cFrame, p2)
	local localPlayer = game.Players.LocalPlayer

	if p2 == "Oars" then
		pcall(function()
			if (p.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude > 500 then
			end
		end)
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = "Orc Lord were summoned at Zombie Island !!!",
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 0, 0),
			FontSize = 18
		}))
		spawn(function()
			for i = 1, 30 do
				local clone = ReplicatedStorage.Chest.Etc.SummonPart:Clone()
				clone.Parent = workspace.Effects
				clone.CFrame = cFrame.Handle.CFrame * CFrame.new(
					math.random(-160, 160) / 10,
					math.random(-160, 160) / 10,
					math.random(-160, 160) / 10
				) * CFrame.Angles(
					math.rad((math.random(-360, 360))),
					math.rad((math.random(-360, 360))),
					(math.rad((math.random(-360, 360))))
				)
				local v3 = math.random(50, 125) / 100
				clone.Mesh.Scale = createVector(0, 0, 0)
				local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
				local v4 = {
					Scale = Vector3.new(v3, v3, v3)
				}
				game.TweenService:Create(clone.Mesh, tweenInfo, v4):Play()
				clone.A1.Position = Vector3.new(v3 / 2, 0, 0)
				clone.A2.Position = Vector3.new(-v3 / 2, 0, 0)
				local v5 = i
				spawn(function()
					wait(v5 / 20 + 0.25)
					local tweenInfo2 = TweenInfo.new(
						0.25,
						Enum.EasingStyle.Exponential,
						Enum.EasingDirection.Out,
						0,
						false,
						0
					)
					local v7 = {
						CFrame = cFrame.Handle.CFrame * CFrame.Angles(
							math.rad((math.random(-360, 360))),
							math.rad((math.random(-360, 360))),
							(math.rad((math.random(-360, 360))))
						)
					}
					game.TweenService:Create(clone, tweenInfo2, v7):Play()
					wait(0.25)
					local v8 = math.random(50, 125) / 100
					local v9 = math.random(20, 50)
					clone.Mesh.Scale = Vector3.new(v8, v9, v8)
					local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 1, true, 0)
					game.TweenService:Create(clone.Mesh, tweenInfo3, {
						Scale = createVector(1, 1, 1)
					}):Play()
					local tweenInfo4 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1, true, 0)
					local v10 = {
						Orientation = Vector3.new(math.random(-45, 45), math.random(-45, 45), math.random(-45, 45))
					}
					game.TweenService:Create(clone, tweenInfo4, v10):Play()
					_G.PU:Dust(clone, 1)
				end)
			end
		end)
	elseif p2 == "Dragon" then
		if (p.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude > 500 then
			return
		end

		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = "The Dragon were summoned at Skull Island !!!",
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 0, 0),
			FontSize = 18
		}))
		spawn(function()
			local handle = cFrame.Handle
			PeodizService.ForLoop({
				Step = 25,
				WaitTime = 0.1
			}, function(_)
				local attachment = Instance.new("Attachment", handle)
				attachment.Position = createVector(0, 0, 0)
				local clone = game.ReplicatedStorage.Chest.FruitEffect.Flame.FlameBeam:Clone()
				clone.Parent = handle
				clone.Attachment0 = attachment
				clone.Width0 = math.random(60, 100)
				clone.Attachment1 = handle.Attachment0
				local cframe = CFrame.new(0, 0, -math.random(50, 90))
				game.TweenService:Create(
					attachment,
					TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						WorldPosition = handle.CFrame * CFrame.Angles(
							math.rad((math.random(1, 360))),
							math.rad((math.random(1, 360))),
							(math.rad((math.random(1, 360))))
						) * CFrame.new(0, 0, -150) * cframe.p
					}
				):Play()
				game.TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Width0 = 0
				}):Play()
				_G.PU:Dust(attachment, 1)
				_G.PU:Dust(clone, 1)
			end)
		end)
		spawn(function()
			for _ = 1, 30 do
				local cFrame2 = cFrame.Handle.CFrame
				local clone = game.ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
				clone.Color = Color3.fromRGB(255, 85, 0)
				clone.CFrame = cFrame2 * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, -30)
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(0.5, 0.5, 3),
					CFrame = clone.CFrame * CFrame.new(0, 0, 30),
					Transparency = 1
				}):Play()
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1)
				wait()
			end
		end)
		spawn(function()
			for i = 1, 15 do
				local clone = ReplicatedStorage.Chest.Etc.SummonPart:Clone()
				clone.Trail.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
				clone.Color = Color3.fromRGB(255, 85, 0)
				clone.Parent = workspace.Effects
				clone.CFrame = cFrame.Handle.CFrame * CFrame.new(
					math.random(-160, 160) / 10,
					math.random(-160, 160) / 10,
					math.random(-160, 160) / 10
				) * CFrame.Angles(
					math.rad((math.random(-360, 360))),
					math.rad((math.random(-360, 360))),
					(math.rad((math.random(-360, 360))))
				)
				local v3 = math.random(50, 125) / 100
				clone.Mesh.Scale = createVector(0, 0, 0)
				local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
				local v4 = {
					Scale = Vector3.new(v3, v3, v3)
				}
				game.TweenService:Create(clone.Mesh, tweenInfo, v4):Play()
				clone.A1.Position = Vector3.new(v3 / 2, 0, 0)
				clone.A2.Position = Vector3.new(-v3 / 2, 0, 0)
				local v5 = i
				spawn(function()
					wait(v5 / 20 + 0.25)
					local tweenInfo2 = TweenInfo.new(
						0.25,
						Enum.EasingStyle.Exponential,
						Enum.EasingDirection.Out,
						0,
						false,
						0
					)
					local v7 = {
						CFrame = cFrame.Handle.CFrame * CFrame.Angles(
							math.rad((math.random(-360, 360))),
							math.rad((math.random(-360, 360))),
							(math.rad((math.random(-360, 360))))
						)
					}
					game.TweenService:Create(clone, tweenInfo2, v7):Play()
					wait(0.25)
					local v8 = math.random(50, 125) / 100
					local v9 = math.random(20, 50)
					clone.Mesh.Scale = Vector3.new(v8, v9, v8)
					local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 1, true, 0)
					game.TweenService:Create(clone.Mesh, tweenInfo3, {
						Scale = createVector(1, 1, 1)
					}):Play()
					local tweenInfo4 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1, true, 0)
					local v10 = {
						Orientation = Vector3.new(math.random(-45, 45), math.random(-45, 45), math.random(-45, 45))
					}
					game.TweenService:Create(clone, tweenInfo4, v10):Play()
					_G.PU:Dust(clone, 1)
				end)
			end
		end)
	elseif p2 == "Santa_2022" then
		if (p.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude > 500 then
			return
		end

		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = "Something is happening at the Santa factory!",
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 0, 0),
			FontSize = 18
		}))
		spawn(function()
			for _ = 1, 30 do
				local cFrame2 = cFrame.Handle.CFrame
				local clone = game.ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
				clone.CastShadow = false
				clone.Transparency = -1
				clone.Color = math.random(1, 2) == 1 and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
				clone.CFrame = cFrame2 * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, -100)
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(0.5, 0.5, 15),
					CFrame = clone.CFrame * CFrame.new(0, 0, 100)
				}):Play()
				_G.PU:Dust(clone, 0.25)
				wait()
			end

			spawn(function()
				local handle = cFrame.Handle
				local cFrame2 = cFrame.Handle.CFrame
				spawn(function()
					local IMAGE_ID = "rbxassetid://7152273035"
					local clone = ReplicatedStorage.Chest.FruitEffect.BossEf.Santa.SantaParticle:Clone()
					clone.CFrame = cFrame2
					clone.Attachment.Ring.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 100)
					})
					clone.Attachment2.Rocks.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.12, 4.875, 2.685),
						NumberSequenceKeypoint.new(1, 0)
					})
					clone.Attachment2.Rocks.Speed = NumberRange.new(100, 150)
					clone.Attachment2.Position = clone.Attachment2.Position + createVector(0, 5, 0)
					clone.Attachment2.Sm.LightEmission = 1
					clone.Attachment2.Sm.Lifetime = NumberRange.new(3)
					clone.Attachment2.Rocks.Lifetime = NumberRange.new(1, 1.5)
					clone.Attachment2.Rocks.LightEmission = 1
					clone.Attachment2.Rocks.Texture = "rbxassetid://1084970835"
					clone.Attachment2.Rocks.Lifetime = NumberRange.new(0.5, 5)
					clone.Attachment2.Rocks1.Color = ColorSequence.new(Color3.fromRGB(0, 0, 255))
					clone.Attachment2.Rocks1.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.12, 4.875, 2.685),
						NumberSequenceKeypoint.new(1, 0)
					})
					clone.Attachment2.Rocks1.Speed = NumberRange.new(100, 150)
					clone.Attachment2.Rocks1.Lifetime = NumberRange.new(1, 1.5)
					clone.Attachment2.Rocks1.LightEmission = 1
					clone.Attachment2.Rocks1.Texture = IMAGE_ID
					clone.Attachment2.Rocks1.Lifetime = NumberRange.new(0.5, 5)
					clone.Attachment2.Rocks2.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
					clone.Attachment2.Rocks2.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.12, 4.875, 2.685),
						NumberSequenceKeypoint.new(1, 0)
					})
					clone.Attachment2.Rocks2.Speed = NumberRange.new(100, 150)
					clone.Attachment2.Rocks2.Lifetime = NumberRange.new(1, 1.5)
					clone.Attachment2.Rocks2.LightEmission = 1
					clone.Attachment2.Rocks2.Texture = IMAGE_ID
					clone.Attachment2.Rocks2.Lifetime = NumberRange.new(0.5, 5)
					clone.Attachment2.Rocks3.Color = ColorSequence.new(Color3.fromRGB(85, 255, 0))
					clone.Attachment2.Rocks3.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.12, 4.875, 2.685),
						NumberSequenceKeypoint.new(1, 0)
					})
					clone.Attachment2.Rocks3.Speed = NumberRange.new(100, 150)
					clone.Attachment2.Rocks3.Lifetime = NumberRange.new(1, 1.5)
					clone.Attachment2.Rocks3.LightEmission = 1
					clone.Attachment2.Rocks3.Texture = IMAGE_ID
					clone.Attachment2.Rocks3.Lifetime = NumberRange.new(0.5, 5)
					clone.Attachment2.Impact.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
					clone.Attachment2.Impact.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 150)
					})
					clone.Attachment2.Circle.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
					clone.Attachment2.Circle.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 120)
					})
					clone.Parent = workspace.Effects
					clone.Attachment2.Circle:Emit(1)
					clone.Attachment2.Impact:Emit(1)
					clone.Attachment2.Rocks:Emit(10)
					clone.Attachment2.Rocks1:Emit(10)
					clone.Attachment2.Rocks2:Emit(10)
					clone.Attachment2.Rocks3:Emit(10)
					_G.PU:Dust(clone, 4)
					local part = Instance.new("Part")
					part.Shape = Enum.PartType.Ball
					part.Transparency = -1
					part.Anchored = true
					part.CanCollide = false
					part.Size = Vector3.new()
					part.Material = Enum.Material.ForceField
					part.Color = Color3.fromRGB(255, 255, 255)
					part.CastShadow = false
					part.CFrame = cFrame2
					part.Parent = workspace.Effects
					_G.PU:Dust(part, 1)
					TweenService:Create(
						part,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(125, 125, 125),
							Transparency = 1
						}
					):Play()
					local clone2 = ReplicatedStorage.Chest.Etc.PartSound:Clone()
					clone2.CFrame = cFrame2
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, 5)
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://8405022366",
						Volume = 2
					})
					_G.PU:Dust(sound, 5)
					sound.Parent = clone2
					sound:Play()
					local clone3 = ReplicatedStorage.Chest.Etc.PartSound:Clone()
					clone3.CFrame = cFrame2
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 5)
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://8405098116",
						Volume = 2
					})
					_G.PU:Dust(sound2, 5)
					sound2.Parent = clone3
					sound2:Play()
				end)
				PeodizService.ForLoop({
					Step = 10
				}, function(_)
					local attachment = Instance.new("Attachment", handle)
					attachment.Position = createVector(0, 0, 0)
					local clone = game.ReplicatedStorage.Chest.FruitEffect.Flame.FlameBeam:Clone()
					clone.Color = math.random(1, 2) == 1 and ColorSequence.new(Color3.fromRGB(255, 0, 0)) or ColorSequence.new(Color3.fromRGB(
						255,
						255,
						255
					))
					clone.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.1, 0),
						NumberSequenceKeypoint.new(0.6, 0),
						NumberSequenceKeypoint.new(1, 0)
					})
					clone.Parent = handle
					clone.Attachment0 = attachment
					clone.Width0 = math.random(25, 50)
					clone.Attachment1 = handle.Attachment0
					local cframe = CFrame.new(0, 0, -math.random(50, 90))
					TweenService:Create(
						attachment,
						TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							WorldPosition = handle.CFrame * CFrame.Angles(
								math.rad((math.random(1, 360))),
								math.rad((math.random(1, 360))),
								(math.rad((math.random(1, 360))))
							) * CFrame.new(0, 0, -50) * cframe.p
						}
					):Play()
					TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Width0 = 0
					}):Play()
					_G.PU:Dust(attachment, 1)
					_G.PU:Dust(clone, 1)
				end)
			end)
		end)
	elseif p2 == "Expert Swordman" then
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = "A mysterious swordsman has visited this sea...!",
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 0, 0),
			FontSize = 18
		}))
	elseif p2 == "King Samurai" then
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = "Strongest Samurai is back...!",
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 0, 0),
			FontSize = 18
		}))
	elseif p2 == "Ms Mother" then
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = "The monster has returned to her island...!",
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 0, 0),
			FontSize = 18
		}))
	elseif p2 == "JackO" then
		task.spawn(function()
			local clone = ReplicatedStorage.Chest.SwordEffect.PumpkinSmasher.exp:Clone()
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)

			for _, emitter in pairs(clone.FX:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end)
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = "It is Halloween time!",
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 85, 0),
			FontSize = 18
		}))
	elseif p2 == "Santa" then
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = "Ho-Ho-Ho... Merry Christmas!~~",
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 0, 0),
			FontSize = 18
		}))
	elseif p2 == "PlayerBounty5M" then
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = "Be careful! " .. cFrame .. " has joined the sea!",
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 0, 0),
			FontSize = 18
		}))
	elseif p2 == "PlayerBounty10M" then
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = "Dangerous! " .. cFrame .. " has joined the sea!",
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 0, 0),
			FontSize = 18
		}))
	elseif p2 == "PlayerBounty50M" then
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = "Run Away! " .. cFrame .. " has joined the sea!",
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 0, 0),
			FontSize = 18
		}))
	elseif p2 == "PlayerBounty100M" then
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = "Top Bounty! " .. cFrame .. " has joined the sea!",
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 0, 0),
			FontSize = 18
		}))
	elseif p2 == "Announcement" then
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = cFrame,
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 247, 19),
			FontSize = 24
		}))
	end
end)
ReplicatedStorage.Chest.Remotes.Events.PopupEvent.OnClientEvent:Connect(function(p, list, beli, exp2, p4, p5)
	local localPlayer = game.Players.LocalPlayer
	local popup = localPlayer.PlayerGui:FindFirstChild("Popup")

	if not popup then
		return
	end

	if p == "ToolDrop" then
		local _ = list.Amount
		local v3 = list

		if CustomNames[list] then
			list = CustomNames[list]
		end

		local clone = ReplicatedStorage.Chest.Gui.NewDrop:Clone()
		local v4 = localPlayer.PlayerStats.Language.Value == "TH" and "</font> ตรวจสอบเมนู Inventory!" or "</font> Check Your Inventory!"

		if beli then
			v4 = localPlayer.PlayerStats.Language.Value == "TH" and "</font> แต่มีอยู่แล้วหนิ โชคดีจัดๆ!" or "</font> But you already own the item. How lucky!"
		end

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.TextLabel.Text = "ได้รับ <font color=\"#00ffff\">" .. list .. v4
		else
			clone.TextLabel.Text = "Obtained <font color=\"#00ffff\">" .. list .. v4
		end

		local v5 = SwordList[v3] or AccessoriesList[v3]

		if v5 then
			if v5.Image then
				clone.ImageLabel.Image = v5.Image
			end

			if v5.Tier and TierColor[v5.Tier] then
				clone.Frame.BackgroundColor3 = TierColor[v5.Tier]
			end
		end

		clone.Parent = popup.Frame
		clone.ImageLabel.Position = UDim2.new(
			0.5,
			-(clone.TextLabel.TextBounds.X / 2) - clone.ImageLabel.AbsoluteSize.X / 2,
			0.5,
			0
		)
		local soundId, volume

		if beli then
			soundId = "rbxassetid://3199296371"
			volume = 0.5
		else
			soundId = "rbxassetid://8614300513"
			volume = 0.15
		end

		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = soundId,
			Volume = volume,
			Name = "ItemDrop"
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = workspace.Effects
		sound:Play()
	elseif p == "ToolRemove" then
		local clone = ReplicatedStorage.Chest.Gui.SwordDrop:Clone()
		clone.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "ลบ <font color=\"#ff0000\">" .. list .. "</font>"
		else
			clone.Text = "Removed <font color=\"#ff0000\">" .. list .. "</font>"
		end

		clone.Parent = popup.Frame
	elseif p == "Just Bought Sound" then
		pcall(function()
			local clone = ReplicatedStorage.Chest.Etc.EtcParti.ScreenBuy:Clone()
			_G.PU:Dust(clone, 10)
			clone.Parent = workspace.Effects
			task.spawn(function()
				FastRenderer.new({
					Time = 5
				}, function()
					local viewportSize = currentCamera.ViewportSize
					local v3 = viewportSize.X / viewportSize.Y
					clone.CFrame = currentCamera.CFrame * CFrame.new(0, -0.075, -v3 / 1.5)
				end)
			end)
			task.spawn(function()
				Utility.EmitParticles(clone.Emit)
				Utility.ParticleHandler(clone.Attachment, true)
				clone.Star2.Enabled = true
				task.wait(2)
				Utility.ParticleHandler(clone.Attachment, false)
				clone.Star2.Enabled = false
			end)
		end)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://3406813517",
			Volume = 0.5,
			Name = "ItemDrop"
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = workspace.Effects
		sound:Play()
	elseif p == "AddTitle" then
		local title = list.Title
		local clone = ReplicatedStorage.Chest.Gui.SwordDrop:Clone()
		clone.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "<font color=\"#ffffff\">ปลดล็อคฉายาใหม่:</font> <font color=\"#ffff7f\">" .. title .. "</font>"
		else
			clone.Text = "<font color=\"#ffffff\">New title unlocked:</font> <font color=\"#ffff7f\">" .. title .. "</font>"
		end

		clone.Parent = popup.Frame
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://135165335432475",
			Volume = 0.7,
			Name = "ItemDrop"
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = workspace.Effects
		sound:Play()
	elseif p == "RemoveTitle" then
		local title = list.Title
		local clone = ReplicatedStorage.Chest.Gui.SwordDrop:Clone()
		clone.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "<font color=\"#ffffff\">ลบฉายา:</font> <font color=\"#ffff7f\">" .. title .. "</font>"
		else
			clone.Text = "<font color=\"#ffffff\">Remove title unlocked:</font> <font color=\"#ffff7f\">" .. title .. "</font>"
		end

		clone.Parent = popup.Frame
	elseif p == "AddMaterial" then
		local v3 = list
		local amount = v3.Amount
		local materialName = v3.MaterialName or "N/A"
		local fixedName

		if MaterialList[materialName].FixedName then
			fixedName = MaterialList[materialName].FixedName
		else
			fixedName = materialName
		end

		local clone = ReplicatedStorage.Chest.Gui.NewDrop:Clone()

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.TextLabel.Text = "<font color=\"#ff00ff\">ได้รับ</font> <font color=\"#ffffff\">" .. fixedName .. "</font> <font color=\"#ff00ff\">x" .. amount .. ".</font>"
		else
			clone.TextLabel.Text = "<font color=\"#ff00ff\">Obtained</font> <font color=\"#ffffff\">" .. fixedName .. "</font> <font color=\"#ff00ff\">x" .. amount .. ".</font>"
		end

		if MaterialList[materialName] then
			clone.ImageLabel.Image = MaterialList[materialName].Image

			if TierColor[MaterialList[materialName].Tier] then
				clone.Frame.BackgroundColor3 = TierColor[MaterialList[materialName].Tier]
			end
		end

		clone.Parent = popup.Frame
		clone.ImageLabel.Position = UDim2.new(
			0.5,
			-(clone.TextLabel.TextBounds.X / 2) - clone.ImageLabel.AbsoluteSize.X / 2,
			0.5,
			0
		)
	elseif p == "AddCollectible" then
		local v3 = list
		local amount = v3.Amount
		local materialName = v3.MaterialName or "N/A"

		if CustomNames[materialName] then
			materialName = CustomNames[materialName]
		end

		local clone = ReplicatedStorage.Chest.Gui.SwordDrop:Clone()
		clone.RichText = true

		if v3.GiftPlayer then
			if v3.GiftPlayer then
				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "<font color=\"#00ff00\">ได้รับ</font> <font color=\"#ffffff\">" .. materialName .. "</font> <font color=\"#00ff00\">x" .. amount .. ".</font> จาก <font color=\"#55ff00\">" .. v3.GiftPlayer .. "</font>"
				else
					clone.Text = "<font color=\"#00ff00\">Obtained</font> <font color=\"#ffffff\">" .. materialName .. "</font> <font color=\"#00ff00\">x" .. amount .. ".</font> from <font color=\"#55ff00\">" .. v3.GiftPlayer .. "</font>"
				end
			end
		elseif localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "<font color=\"#00ff00\">ได้รับ</font> <font color=\"#ffffff\">" .. materialName .. "</font> <font color=\"#00ff00\">x" .. amount .. ".</font>"
		else
			clone.Text = "<font color=\"#00ff00\">Obtained</font> <font color=\"#ffffff\">" .. materialName .. "</font> <font color=\"#00ff00\">x" .. amount .. ".</font>"
		end

		clone.Parent = popup.Frame
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://15153613827",
			Volume = 0.25,
			Name = "ItemDrop"
		})
		_G.PU:Dust(sound, 5)
		sound.Parent = workspace.Effects
		sound:Play()
	elseif p == "FruitTrade" then
		local v3 = list
		local v4 = tostring(string.gsub(v3, "Fruit", " Fruit"))
		local clone = ReplicatedStorage.Chest.Gui.SwordDrop:Clone()
		clone.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "กระเป๋าผลไม้เต็ม! <font color=\"#ff55ff\">" .. v4 .. "</font> ถูกส่งเข้า<font color=\"#ff6767\">กระเป๋าทั่วไป!</font>"
		else
			clone.Text = "Fruit Storage is full! <font color=\"#ff55ff\">" .. v4 .. "</font> has been sent to the <font color=\"#ff6767\">Backpack!</font>"
		end

		clone.Parent = popup.Frame
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8614300513",
			Volume = 0.15,
			Name = "ItemDrop"
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = workspace.Effects
		sound:Play()
	elseif p == "FruitTradeStorage" then
		local v3 = list
		local v4 = tostring(string.gsub(v3, "Fruit", " Fruit"))
		local clone = ReplicatedStorage.Chest.Gui.SwordDrop:Clone()
		clone.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "<font color=\"#ff55ff\">" .. v4 .. "</font> ถูกส่งเข้า<font color=\"#ffff7f\">กระเป๋าผลไม้!</font>"
		else
			clone.Text = "<font color=\"#ff55ff\">" .. v4 .. "</font> has been sent to the <font color=\"#ffff7f\">Fruit Storage!</font>"
		end

		clone.Parent = popup.Frame
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8614300513",
			Volume = 0.15,
			Name = "ItemDrop"
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = workspace.Effects
		sound:Play()
	elseif p == "Buy Fruit Black Market" then
		local v3 = list
		local v4 = tostring((string.sub(v3, 1, #v3 / 2))) .. " Fruit"

		if CustomNames[v4] then
			v4 = CustomNames[v4]
		end

		local clone = ReplicatedStorage.Chest.Gui.SwordDrop:Clone()
		clone.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "ได้รับ <font color=\"#55ff00\">" .. v4 .. "</font> ตรวจสอบเมนู Backpack!"
		else
			clone.Text = "Obtained <font color=\"#55ff00\">" .. v4 .. "</font> Check Your Backpack!"
		end

		clone.Parent = popup.Frame
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8614300513",
			Volume = 0.15,
			Name = "ItemDrop"
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = workspace.Effects
		sound:Play()
	elseif p == "RemoveMaterial" then
		local v3 = list
		local amount = v3.Amount
		local materialName = v3.MaterialName
		local clone = ReplicatedStorage.Chest.Gui.SwordDrop:Clone()
		clone.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "ได้ใช้ <font color=\"#b4d2e4\">" .. materialName .. "</font> x" .. amount .. "."
		else
			clone.Text = "Used <font color=\"#b4d2e4\">" .. materialName .. "</font> x" .. amount .. "."
		end

		clone.Parent = popup.Frame
	elseif p == "RemoveCollectible" then
		local v3 = list
		local amount = v3.Amount
		local collectibleName = v3.CollectibleName
		local name = CollectibleList[collectibleName].Name or collectibleName
		local clone = ReplicatedStorage.Chest.Gui.SwordDrop:Clone()
		clone.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "กำจัด <font color=\"#b4d2e4\">" .. name .. "</font> x" .. amount .. "."
		else
			clone.Text = "Removed <font color=\"#b4d2e4\">" .. name .. "</font> x" .. amount .. "."
		end

		clone.Parent = popup.Frame
	elseif p == "SummonToolDrop" then
		local clone = ReplicatedStorage.Chest.Gui.ItemDrop:Clone()
		clone.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 180, 180)),
			ColorSequenceKeypoint.new(0.35, Color3.fromRGB(180, 180, 180)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		})
		clone.Size = UDim2.new(1, 0, 0.034, 0)
		clone.Text = "You just received an item"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "คุณได้รับไอเทมที่"
		end

		clone.Parent = popup.Frame
		local clone2 = ReplicatedStorage.Chest.Gui.ItemDrop:Clone()
		clone2.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 180, 180)),
			ColorSequenceKeypoint.new(0.35, Color3.fromRGB(180, 180, 180)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		})
		clone2.RichText = true
		clone2.Size = UDim2.new(1, 0, 0.034, 0)
		clone2.Text = "that can <font color=\"#ff5959\">summon a boss</font>"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone2.Text = "สามารถ<font color=\"#ff5959\">เสกบอส</font>ได้"
		end

		clone2.Parent = popup.Frame
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8614300513",
			Volume = 0.15,
			Name = "ItemDrop"
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = workspace.Effects
		sound:Play()
	elseif p == "Level Up" then
		local suffix_Comma = _G.Suffix_Comma(list)
		local clone = ReplicatedStorage.Chest.Gui.LevelUp:Clone()
		clone.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "เลเวลอัพ! <font color=\"#ffff00\">(" .. suffix_Comma .. ")</font>"
		else
			clone.Text = "Level up! <font color=\"#ffff00\">(" .. suffix_Comma .. ")</font>"
		end

		clone.Parent = popup.Frame
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://15153585659",
			Volume = 0.1,
			Name = "LevelUp"
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = workspace.Effects
		sound:Play()
	elseif p == "Bought Fruit Black Market" then
		local v3 = list

		if v3.Beli then
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.RichText = true
			local _ = localPlayer.PlayerStats.RealBeliX2.Value > 1

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ได้ใช้ <font color=\"#00ff00\">$ " .. _G.Suffix_Comma(v3.Beli) .. "</font>"
			else
				clone.Text = "Used <font color=\"#00ff00\">$ " .. _G.Suffix_Comma(v3.Beli) .. "</font>"
			end

			clone.Parent = popup.Frame
		end

		if v3.Gem then
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.RichText = true

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ได้ใช้ <font color=\"#ff55ff\">" .. _G.Suffix_Comma(v3.Gem) .. " มณี</font>"
			else
				clone.Text = "Spent <font color=\"#ff55ff\">" .. _G.Suffix_Comma(v3.Gem) .. " Gem</font>"
			end

			clone.Parent = popup.Frame
		end
	elseif p == "StatsPopup" then
		local v3 = list
		local sound = v3.Sound

		if sound then
			if sound == "Code Success" then
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://6792280577",
					Volume = 0.5,
					Name = "Code Success"
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = workspace.Effects
				sound2:Play()
			elseif sound == "Code Fail" then
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://2390695935",
					Volume = 1,
					Name = "Code Fail"
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = workspace.Effects
				sound2:Play()
			end
		else
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15153502536",
				Volume = 0.1,
				Name = "Money"
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = workspace.Effects
			sound2:Play()
		end

		if v3.Beli then
			ReplicatedStorage.Chest.Remotes.Bindables.Popup:Fire("Beli", v3)
		end

		if v3.Exp and localPlayer.PlayerStats.lvl.Value < _G.LevelMaxClient then
			local exp = math.round(v3.Exp)
			ReplicatedStorage.Chest.Remotes.Bindables.Popup:Fire("Exp", {
				Exp = exp
			})
		end

		if v3.BtpExp and ReplicatedStorage:FindFirstChild("Battlepass") then
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.RichText = true

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ได้รับ <font color=\"#C800FF\">" .. Suffix(v3.BtpExp) .. " ค่าประสบการณ์แบทเทิลพาส</font>"
			else
				clone.Text = "Earned <font color=\"#C800FF\">" .. Suffix(v3.BtpExp) .. " Pass Exp</font>"
			end

			clone.Parent = popup.Frame
		end

		if v3.Gem then
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.RichText = true

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ได้รับ <font color=\"#ff55ff\">" .. Suffix(v3.Gem) .. " มณี</font>"
			else
				clone.Text = "Earned <font color=\"#ff55ff\">" .. Suffix(v3.Gem) .. " Gem</font>"
			end

			clone.Parent = popup.Frame
			ReplicatedStorage.Chest.Remotes.Bindables.Popup:Fire("Gem", v3)
		end

		if v3.Candy then
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.RichText = true

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ได้รับ <font color=\"#ffaa00\">" .. Suffix(v3.Candy) .. " แคนดี้</font>"
			else
				clone.Text = "Earned <font color=\"#ffaa00\">" .. Suffix(v3.Candy) .. " Candy</font>"
			end

			clone.Parent = popup.Frame
		end
	elseif p == "QuestPopup" then
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.TextColor3 = Color3.fromRGB(255, 85, 0)
		clone.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "ภารกิจเสร็จสิ้น"
		else
			clone.Text = "Quest Completed"
		end

		clone.Parent = popup.Frame
		local position

		if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local humanoidRootPart = localPlayer.Character.HumanoidRootPart
			position = humanoidRootPart and humanoidRootPart.Position
		end

		ReplicatedStorage.Chest.Remotes.Bindables.Popup:Fire("Beli", {
			Beli = beli,
			CoinPos = position
		})
		ReplicatedStorage.Chest.Remotes.Bindables.Popup:Fire("Exp", {
			Exp = exp2
		})
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://15153587039",
			Volume = 0.4,
			Name = "Quest"
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = workspace.Effects
		sound:Play()
	elseif p == "MuramasaZ" or p == "MuramasaX" then
		local v3 = {
			MuramasaZ = "Shattering Flame",
			MuramasaX = "Vanishing Thurst"
		}
		local v4 = {
			MuramasaZ = "Undying Flame",
			MuramasaX = "Calamity Slash"
		}
		local clone = ReplicatedStorage.Chest.Gui.LevelUp:Clone()

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "< " .. v3[p] .. " ตื่นเป็น " .. v4[p] .. " >"
		else
			clone.Text = "< " .. v3[p] .. " Awaked to " .. v4[p] .. " >"
		end

		clone.Parent = popup.Frame
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://15153585659",
			Volume = 0.1,
			Name = "LevelUp"
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = workspace.Effects
		sound:Play()
	elseif p == "BountyPopup" then
		local v3 = unpack(list)
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "คุณได้ <font color=\"#ff4242\">" .. p4 .. " ค่าหัว</font>จาก <font color=\"#aaffff\">" .. p5.Name .. "</font>"
		else
			clone.Text = "You get <font color=\"#ff4242\">" .. p4 .. " Bounty</font> from <font color=\"#aaffff\">" .. p5.Name .. "</font>"
		end

		clone.Parent = popup.Frame
		local clone2 = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone2.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone2.Text = "รวม: [" .. v3 .. "/3 ครั้ง]"
		else
			clone2.Text = "Total: [" .. v3 .. "/3 Times]"
		end

		clone2.Parent = popup.Frame
	elseif p == "LostBountyPopup" then
		local v3 = unpack(list)
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "คุณเสีย <font color=\"#ff4242\">" .. p4 .. " ค่าหัว</font>ให้ <font color=\"#aaffff\">" .. p5.Name .. "</font>"
		else
			clone.Text = "You lost <font color=\"#ff4242\">" .. p4 .. " Bounty</font> to <font color=\"#aaffff\">" .. p5.Name .. "</font>"
		end

		clone.Parent = popup.Frame
		local clone2 = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone2.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone2.Text = "รวม: [" .. v3 .. "/3 ครั้ง]"
		else
			clone2.Text = "Total: [" .. v3 .. "/3 Times]"
		end

		clone2.Parent = popup.Frame
	elseif p == "No Bounty Reward" then
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.RichText = true

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "ไม่ได้รางวัล <font color=\"#ff4242\">เลเวลต่าง</font> กันเกิน"
		else
			clone.Text = "No reward <font color=\"#ff4242\">Level Different</font> too high."
		end

		clone.Parent = popup.Frame
	elseif p == "IsInShipZone" then
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "<ไม่มีพื้นที่สำหรับเทียบท่าเรือ>"
		else
			clone.Text = "<There is no docking area>"
		end

		clone.Parent = popup.Frame
	elseif p == "Joining Friend" then
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "< กำลังตามไปเซิฟเพื่อน... >"
		else
			clone.Text = "< Joining Friend... >"
		end

		clone.Parent = popup.Frame
	elseif p == "Joining Error" then
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "< ไม่พบชื่อผู้เล่นนี้... >"
		else
			clone.Text = "< Not found this player name... >"
		end

		clone.Parent = popup.Frame
	elseif p == "Joining Not Friend" then
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "< ผู้เล่นนี้ไม่ได้อยู่ในรายชื่อเพื่อนของคุณ... >"
		else
			clone.Text = "< This Player is not on your friend list... >"
		end

		clone.Parent = popup.Frame
	elseif p == "Conqueror Same Bounty" then
		local v3 = unpack(list)
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.RichText = true
		local text = "<font color=\"#ffaa00\">" .. v3 .. "</font> has the same bounty as you"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			text = "<font color=\"#ffaa00\">" .. v3 .. "</font> ค่าหัวเท่าคุณ"
		end

		clone.Text = text
		clone.Parent = popup.Frame
	elseif p == "Conqueror More Bounty" then
		local v3, v4, v5 = unpack(list)
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.RichText = true
		local text = "<font color=\"#ffaa00\">" .. v3 .. "</font> has more bounty than you (Diff: " .. _G.Suffix_Comma(v5 - v4) .. ")"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			text = "<font color=\"#ffaa00\">" .. v3 .. "</font> ค่าหัวเยอะกว่าคุณ (ต่าง: " .. _G.Suffix_Comma(v5 - v4) .. ")"
		end

		clone.Text = text
		clone.Parent = popup.Frame
	elseif p == "CleanFruit" then
		if list == 5 then
			if list == 5 then
				for i = 1, 5 do
					if localPlayer and localPlayer:FindFirstChild("PlayerStats") then
						if localPlayer.PlayerStats.Language.Value == "TH" then
							game.StarterGui:SetCore("SendNotification", {
								Title = "ระบบเก็บกวาดผล",
								Text = "ผลทั้งหมดบนพื้นจะถูกลบใน " .. 6 - i .. " วิ",
								Duration = 1,
								Icon = "rbxassetid://6882010230"
							})
						else
							game.StarterGui:SetCore("SendNotification", {
								Title = "Cleaning Fruit",
								Text = "Every Fruits on the ground is clearing in " .. 6 - i .. "sec",
								Duration = 1,
								Icon = "rbxassetid://6882010230"
							})
						end
					end

					local sound = Instance.new("Sound")
					sound.Volume = 0.05
					sound.SoundId = "rbxassetid://6877818361"
					sound.Parent = workspace
					sound:Play()
					_G.PU:Dust(sound, sound.TimeLength + 1)
					wait(1)
				end

				if localPlayer and localPlayer:FindFirstChild("PlayerStats") then
					if localPlayer.PlayerStats.Language.Value == "TH" then
						game.StarterGui:SetCore("SendNotification", {
							Title = "ระบบเก็บกวาดผล",
							Text = "ผลทั้งหมดบนพื้นถูกลบเรียบร้อยแล้ว",
							Duration = 1,
							Icon = "rbxassetid://6882010230"
						})
					else
						game.StarterGui:SetCore("SendNotification", {
							Title = "Success",
							Text = "Every Fruit has been cleared from the grond",
							Duration = 1,
							Icon = "rbxassetid://6882010230"
						})
					end

					local sound = Instance.new("Sound")
					sound.Volume = 0.3
					sound.SoundId = "rbxassetid://6882173609"
					sound.Parent = workspace
					sound:Play()
					_G.PU:Dust(sound, 2)
				end
			end
		else
			spawn(function()
				if localPlayer and localPlayer:FindFirstChild("PlayerStats") then
					if localPlayer.PlayerStats.Language.Value == "TH" then
						game.StarterGui:SetCore("SendNotification", {
							Title = "ระบบเก็บกวาดผล...",
							Text = "ผลทั้งหมดบนพื้นจะถูกลบใน " .. list .. " วิ",
							Duration = 10,
							Icon = "rbxassetid://6882010230"
						})
					else
						game.StarterGui:SetCore("SendNotification", {
							Title = "Cleaning Fruit...",
							Text = "Every Fruits on the ground is clearing in " .. list .. "sec",
							Duration = 10,
							Icon = "rbxassetid://6882010230"
						})
					end
				end
			end)
		end
	elseif p == "Shutdown Server" then
		local text = list
		local shuttingDownGui = localPlayer.PlayerGui:FindFirstChild("ShuttingDownGui")

		if shuttingDownGui then
			if shuttingDownGui then
				shuttingDownGui.Frame.Count.Text = text
			end
		else
			local clone = game.ReplicatedStorage.Chest.Gui.ShuttingDownGui:Clone()
			clone.Parent = localPlayer.PlayerGui
			clone.Frame.Count.Text = text
		end
	elseif p == "Spawn Boss With Name" then
		local v3 = unpack(list)
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.RichText = true
		clone.Text = "You have summon <font color=\"#ff5500\">" .. v3 .. "</font>"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "คุณได้อัญเชิญ <font color=\"#ff5500\">" .. v3 .. "</font>"
		end

		clone.Parent = popup.Frame
	elseif p == "BattleCount" then
		local v3 = list
		local battleTimeLeft = popup.Frame:FindFirstChild("Battle Time Left")

		if battleTimeLeft then
			battleTimeLeft.Text = "Time Left: " .. v3
			battleTimeLeft:SetAttribute("DebrisTime", 5)
		else
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.Name = "Battle Time Left"
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.RichText = true
			clone.Text = "Time Left: " .. v3
			clone:SetAttribute("DebrisTime", 2)
		end
	end
end)
local rotation = -10
ReplicatedStorage.Chest.Remotes.Bindables.TextAlert.Event:Connect(function(childName, list)
	local localPlayer = game.Players.LocalPlayer
	local popup = localPlayer.PlayerGui:WaitForChild("Popup")
	UDim2.new(1, 0, 0.068, 0)

	if childName == "Custom Text" then
		local name = list.Name
		local message = list.Message
		local color = list.Color or Color3.fromRGB(255, 255, 255)

		if not (name and message) then
			return
		end

		local overlay = list.Overlay

		if popup.Frame:FindFirstChild(name) and not overlay then
			return
		end

		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.Name = name
		clone.TextColor3 = color
		clone.RichText = true
		clone.Text = message
		clone.Parent = popup.Frame
	elseif childName == "BattleCount" then
		local text = list.Text
		local battleTimeLeft = popup.Frame:FindFirstChild("Battle Time Left")

		if battleTimeLeft then
			battleTimeLeft.Text = "Time Left: " .. text
			battleTimeLeft:SetAttribute("DebrisTime", 5)
		else
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.Name = "Battle Time Left"
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.RichText = true
			clone.Text = "Time Left: " .. text
			clone:SetAttribute("DebrisTime", 2)
			clone.Parent = popup.Frame
		end
	elseif childName == "Small Place" then
		local name = list.Name
		local overlay = list.Overlay

		if popup.Frame:FindFirstChild(name) and not overlay then
			return
		end

		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.RichText = true
		clone.Text = "Can't transform in this place!"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "แปลงร่างที่นี่ไม่ได้"
		end

		clone.TextColor3 = Color3.fromRGB(255, 124, 124)
		clone.Parent = popup.Frame
	elseif childName == "CrewUpdate" then
		local text = list.Text
		local clone = ReplicatedStorage.Chest.Gui.NewDrop:Clone()
		clone.TextLabel.Text = text
		clone.Frame.BackgroundColor3 = Color3.fromRGB(32, 255, 32)

		if list.Failed then
			clone.Frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		end

		clone.Parent = popup.Frame
	else
		if popup.Frame:FindFirstChild(childName) then
			return
		end

		if childName == "Stats Require" then
			local v4, v5, v6 = unpack(list)
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.Name = "Require" .. v5 .. v4
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.RichText = true

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "<font color=\"#ff4b4b\">สกิลถูกล็อค!</font> ต้องการ" .. " <font color=\"#ffff7f\">[" .. v6 .. "]</font> " .. (v4 == "Defense" and "พลังป้องกัน" or v4 == "Melee" and "พลังต่อสู้" or v4 == "sword" and "พลังดาบ" or v4 == "DF" and "พลังผลไม้" or v4)
			else
				clone.Text = "<font color=\"#ff4b4b\">Skill locked!</font> <font color=\"#ffff7f\">[" .. v6 .. "]</font> " .. (v4 == "sword" and "Sword" or v4 == "DF" and "Legacy Fruit" or v4) .. " required."
			end

			clone.Parent = popup.Frame
		elseif childName == "Jump Left" then
			local v4, v5 = unpack(list)
			local jumpLeftCurrent = popup.Frame:FindFirstChild("Jump Left Current")

			if jumpLeftCurrent then
				if localPlayer.PlayerStats.Language.Value == "TH" then
					jumpLeftCurrent.Text = "กระโดด<font color=\"#55ffff\"> (" .. v4 .. "/" .. v5 .. ") </font>ครั้ง"
				else
					jumpLeftCurrent.Text = "Jumped<font color=\"#55ffff\"> (" .. v4 .. "/" .. v5 .. ") </font>Times"
				end

				if rotation == -10 then
					rotation = 10
				elseif rotation == 10 then
					rotation = -10
				end

				jumpLeftCurrent.Rotation = 0
				TweenService:Create(
					jumpLeftCurrent,
					TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
					{
						Rotation = rotation
					}
				):Play()
				jumpLeftCurrent:SetAttribute("DebrisTime", 5)
			else
				local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
				clone.Name = "Jump Left Current"
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RichText = true
				clone:SetAttribute("DebrisTime", 2)
				clone.Parent = popup.Frame

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "กระโดด<font color=\"#55ffff\"> (" .. v4 .. "/" .. v5 .. ") </font>ครั้ง"
				else
					clone.Text = "Jumped <font color=\"#55ffff\"> (" .. v4 .. "/" .. v5 .. ") </font>Times"
				end
			end
		elseif childName == "Jump Max" then
			local v4, v5 = unpack(list)
			local jumpLeftCurrent = popup.Frame:FindFirstChild("Jump Left Current")

			if jumpLeftCurrent then
				if localPlayer.PlayerStats.Language.Value == "TH" then
					jumpLeftCurrent.Text = "ชาร์จกระโดดเต็มแล้ว<font color=\"#55ffff\"> (" .. v4 .. "/" .. v5 .. ") </font>ครั้ง"
				else
					jumpLeftCurrent.Text = "Fully Charged Jumps <font color=\"#55ffff\"> (" .. v4 .. "/" .. v5 .. ") </font>"
				end

				if rotation == -10 then
					rotation = 10
				elseif rotation == 10 then
					rotation = -10
				end

				jumpLeftCurrent.Rotation = 0
				TweenService:Create(
					jumpLeftCurrent,
					TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
					{
						Rotation = rotation
					}
				):Play()
				jumpLeftCurrent:SetAttribute("DebrisTime", 5)
			else
				local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
				clone.Name = "Jump Left Current"
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RichText = true
				clone:SetAttribute("DebrisTime", 2)
				clone.Parent = popup.Frame

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "ชาร์จกระโดดเต็มแล้ว<font color=\"#55ffff\"> (" .. v4 .. "/" .. v5 .. ") </font>ครั้ง"
				else
					clone.Text = "Fully Charged Jumps <font color=\"#55ffff\"> (" .. v4 .. "/" .. v5 .. ") </font>"
				end
			end
		elseif childName == "Island Name" then
			local v4 = unpack(list)
			local areaText = popup:FindFirstChild("AreaText")

			if areaText then
				areaText:Destroy()
			end

			if IslandInfo[v4] then
				local clone = ReplicatedStorage.Chest.Etc.AreaText:Clone()
				_G.PU:Dust(clone, 4)
				clone.Size = UDim2.new(0.2, 0, 0, currentCamera.ViewportSize.Y * 0.1)
				clone.Place.TextLabel.Text = IslandInfo[v4].Name
				clone.Info.TextLabel.Text = IslandInfo[v4].InfoText
				clone.LocalScript.Disabled = false
				clone.Parent = popup
			end
		else
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if childName == "LeeAlert" and list and typeof(list) == "table" and list.Text then
				clone.Text = list.Text

				if list.Color then
					clone.TextColor3 = list.Color
				end
			end

			if childName == "Creating Crew" then
				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "<กำลังสร้างแคลน...>"
				else
					clone.Text = "<Creating Crew...>"
				end
			elseif childName == "Leaving Crew" then
				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "<กำลังออกจากแคลน...>"
				else
					clone.Text = "<Leaving Crew...>"
				end
			elseif childName == "Leaved Crew" then
				clone.TextColor3 = Color3.fromRGB(0, 255, 0)

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "<ออกจากแคลนแล้ว>"
				else
					clone.Text = "<Leaved Crew>"
				end
			elseif childName == "Created Crew" then
				clone.TextColor3 = Color3.fromRGB(0, 255, 0)

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "<สร้างแคลนเสร็จสิ้น>"
				else
					clone.Text = "<Created Crew>"
				end
			elseif childName == "Crew Error" then
				clone.TextColor3 = Color3.fromRGB(255, 93, 96)

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "<ข้อผิดพลาด: ชื่อ/รูป>"
				else
					clone.Text = "<Error: Name or Decal>"
				end
			elseif childName == "Trade Error" then
				clone.TextColor3 = Color3.fromRGB(255, 93, 96)

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "<ข้อผิดพลาด: " .. unpack(list) .. ">"
				else
					clone.Text = "<Error: " .. unpack(list) .. ">"
				end
			elseif childName == "Trade Disabled" then
				local player = list.Player or "N/A"
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "<font color=\"#ff0000\">" .. player .. "</font> ได้ปิดใช้งานการส่งคำขอแลกเปลี่ยน"
				else
					clone.Text = "<font color=\"#ff0000\">" .. player .. "</font> has disabled trade requests."
				end
			elseif childName == "Trade Accepted" then
				local player = list.Player or "N/A"
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "<font color=\"#55ff00\">" .. player .. "</font> ได้ยอมรับคำขอแลกเปลี่ยน"
				else
					clone.Text = "<font color=\"#55ff00\">" .. player .. "</font> has accepted trade requests."
				end
			elseif childName == "Trade Success" then
				clone.TextColor3 = Color3.fromRGB(85, 255, 0)

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "<แลกเปลี่ยนสำเร็จ>"
				else
					clone.Text = "<Trade Success>"
				end
			elseif childName == "Trade Cancel" then
				clone.TextColor3 = Color3.fromRGB(255, 93, 96)

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "<ยกเลิกการแลกเปลี่ยน>"
				else
					clone.Text = "<Trade Cancel>"
				end
			elseif childName == "Wearing Bullitus" then
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RichText = true

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "คุณไม่สามารถแปลงร่างตอนใช้<font color=\"#00aaff\">ฟองน้ำ</font>ได้"
				else
					clone.Text = "You can not transform while using <font color=\"#00aaff\">Bullitus</font>"
				end
			elseif childName == "No Dodge Left" then
				clone.Name = "No Dodge Left"
				clone.TextColor3 = Color3.fromRGB(255, 93, 96)

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "หลบไม่ได้แล้ว!"
				else
					clone.Text = "No Dodge Left!"
				end
			elseif childName == "Go Talk To Traveler" then
				clone.Name = "Go Talk To Traveler"
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RichText = true
				clone.Text = "Talk with <font color=\"#00aaff\">Traveler</font> at War Island"

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "ไปคุยกับ <font color=\"#00aaff\">Traveler</font> ที่เกาะ War Island"
				end

				local clone2 = ReplicatedStorage.Chest.Gui.Bounty:Clone()
				clone2.Name = "Go Talk To Traveler2"
				clone2.RichText = true
				clone2.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone2.Text = "You can go to <font color=\"#00ffff\">second sea</font>"

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone2.Text = "คุณสารมารถไป<font color=\"#00ffff\">ทะเลที่สอง</font>ได้"
				end

				clone2.Parent = popup.Frame
			elseif childName == "Go Talk To Seaman" then
				clone.Name = "Go Talk To Seaman"
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RichText = true
				clone.Text = "Talk with <font color=\"#00aaff\">The Squid</font> at Viridans port"

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "ไปคุยกับ <font color=\"#00aaff\">The Squid</font> ที่ท่าเรือ Viridans"
				end

				local clone2 = ReplicatedStorage.Chest.Gui.Bounty:Clone()
				clone2.Name = "Go Talk To Seaman2"
				clone2.RichText = true
				clone2.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone2.Text = "You can go to <font color=\"#00ffff\">third sea</font>"

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone2.Text = "คุณสารมารถไป<font color=\"#00ffff\">ทะเลที่สาม</font>ได้"
				end

				clone2.Parent = popup.Frame
			elseif childName == "Legacy Pose Mode Quest" then
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RichText = true

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "เปลี่ยนโหมดนำทาง<font color=\"#ffff00\"> (เควส)</font>"
				else
					clone.Text = "Changed the Navigate<font color=\"#ffff00\"> (Quest)</font>"
				end
			elseif childName == "Legacy Pose Mode Ghost Ship" then
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RichText = true

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "เปลี่ยนโหมดนำทาง<font color=\"#00ff00\"> (เรือผีสิง)</font>"
				else
					clone.Text = "Changed the Navigate<font color=\"#00ff00\"> (Ghost Ship)</font>"
				end
			elseif childName == "Legacy Pose Mode Gacha Fruit" then
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RichText = true

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "เปลี่ยนโหมดนำทาง<font color=\"#ff55ff\"> (กาชา)</font>"
				else
					clone.Text = "Changed the Navigate<font color=\"#ff55ff\"> (Gacha)</font>"
				end
			elseif childName == "Legacy Pose Mode Legacy Island" then
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RichText = true

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "เปลี่ยนโหมดนำทาง<font color=\"#00ffff\"> (Legacy Island)</font>"
				else
					clone.Text = "Changed the Navigate<font color=\"#00ffff\"> (Legacy Island)</font>"
				end
			elseif childName == "Progression Snake Form Require" then
				clone.Name = "Progression Snake Form Require"
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RichText = true

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "<font color=\"#ff0000\">สกิลล็อค!</font> ต้องผ่านความสำเร็จเควส Snake Form"
				else
					clone.Text = "<font color=\"#ff0000\">Skill locked!</font> Progression Snake Form require."
				end
			elseif childName == "Tracking Quest Enable" then
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RichText = true

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "การติดตามภารกิจ<font color=\"#55ff00\"> (เปิดใช้งาน)</font>"
				else
					clone.Text = "Tracking Quest<font color=\"#55ff00\"> (Enabled)</font>"
				end
			elseif childName == "Tracking Quest Disable" then
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RichText = true

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "การติดตามภารกิจ<font color=\"#ff0000\"> (ปิดใช้งาน)</font>"
				else
					clone.Text = "Tracking Quest<font color=\"#ff0000\"> (Disable)</font>"
				end
			elseif childName == "Current Quest Cancel" then
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RichText = true

				if localPlayer.PlayerStats.Language.Value == "TH" then
					clone.Text = "ภารกิจปัจจุบันถูก<font color=\"#ff0000\"> ยกเลิก</font>"
				else
					clone.Text = "The current quest has been<font color=\"#ff0000\"> canceled.</font>"
				end
			end

			clone.Parent = popup.Frame
		end
	end
end)
ReplicatedStorage.Chest.Remotes.Bindables.TextDamage.Event:Connect(function(instance, text, data)
	local localPlayer = game.Players.LocalPlayer
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")) or humanoidRootPart.Size.X >= 10 then
		return
	end

	if (localPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude > 300 or not _G.CheckSettingClient(
		localPlayer,
		"DamageText"
	) then
		return
	end

	local color = Color3.fromRGB(255, 0, 0)
	local v4 = not data and "Damage" or data.Mode or "Damage"

	if text == "Dead" then
		text = "☠️"
	elseif text == "Low Level" then
		text = localPlayer.PlayerStats.Language.Value == "TH" and "เลเวลต่ำ" or "Low Level"
		color = Color3.fromRGB(255, 255, 0)
	elseif text == "Dodge" then
		if not data then
			return
		end

		local dodgeCount = data.DodgeCount
		local maxCount = data.MaxCount

		if localPlayer.PlayerStats.Language.Value == "TH" then
			text = "หลบหลีก (" .. dodgeCount .. "/" .. maxCount .. ")"
		else
			text = "Dodge (" .. dodgeCount .. "/" .. maxCount .. ")"
		end

		color = Color3.fromRGB(255, 255, 255)
	elseif v4 == "Damage" then
		text = math.floor(text)
	elseif v4 == "Heal" then
		color = Color3.fromRGB(0, 255, 0)
		text = math.floor(text)
	end

	local part = Instance.new("Part")
	part.CastShadow = false
	part.Size = Vector3.new()
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.Name = instance.Name
	part.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.new(
		math.random(-5, 5),
		math.random(-3, 3),
		math.random(-5, 5)
	)
	part.Parent = workspace.Effects
	_G.PU:Dust(part, 2)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Active = false
	billboardGui.Adornee = part
	billboardGui.AlwaysOnTop = true
	billboardGui.MaxDistance = 300
	billboardGui.Enabled = true
	billboardGui.Size = UDim2.new(0, 0, 0, 0)
	billboardGui.StudsOffset = Vector3.new()
	billboardGui.ClipsDescendants = false
	billboardGui.Parent = part
	_G.PU:Dust(billboardGui, 2)
	local textLabel = Instance.new("TextLabel")
	_G.PU:Dust(textLabel, 2)
	textLabel.BackgroundTransparency = 1
	textLabel.Name = "TakeDamage"
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.Text = text
	textLabel.TextColor3 = color
	textLabel.TextScaled = true
	textLabel.RichText = true
	textLabel.TextTransparency = 1
	textLabel.TextWrapped = true
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	textLabel.Parent = billboardGui
	TweenService:Create(billboardGui, TweenInfo.new(0.3), {
		Size = UDim2.new(9, 0, 3, 0),
		StudsOffset = createVector(0, 5, 0)
	}):Play()
	local uIStroke = Instance.new("UIStroke")
	_G.PU:Dust(uIStroke, 2)
	uIStroke.Thickness = 2
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	uIStroke.Parent = textLabel
	TweenService:Create(textLabel, TweenInfo.new(0.25), {
		TextTransparency = 0,
		TextStrokeTransparency = 0
	}):Play()
	delay(0.15, function()
		if textLabel and textLabel.Parent then
			TweenService:Create(textLabel, TweenInfo.new(0.25), {
				TextColor3 = Color3.fromRGB(255, 255, 255)
			}):Play()
		end

		wait(0.1)

		if textLabel and textLabel.Parent then
			TweenService:Create(textLabel, TweenInfo.new(0.25), {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
		end

		if uIStroke and uIStroke.Parent then
			TweenService:Create(uIStroke, TweenInfo.new(0.25), {
				Transparency = 1
			}):Play()
		end

		if billboardGui and billboardGui.Parent then
			TweenService:Create(billboardGui, TweenInfo.new(0.25), {
				Size = UDim2.new(3, 0, 1, 0)
			}):Play()
		end

		task.wait(0.3)

		if part and part.Parent then
			part:Destroy()
		end
	end)
end)
ReplicatedStorage.Chest.Remotes.Events.TextAlert.OnClientEvent:Connect(function(p, list)
	local localPlayer = game.Players.LocalPlayer
	PeodizService.new({
		Time = 30
	}, function()
		if localPlayer:FindFirstChild("PlayerStats") then
			return true
		end
	end)

	if not localPlayer:FindFirstChild("PlayerStats") then
		return
	end

	local popup = localPlayer.PlayerGui:WaitForChild("Popup")

	if p == "Changed Sword" and unpack(list) == "None" then
		return
	end

	if p == "Custom Text" then
		if list.CheckRadius and list.Part then
			local checkStuds = list.CheckStuds or 250
			local character = localPlayer.Character

			if character and character:FindFirstChild("HumanoidRootPart") then
				if checkStuds < (character.HumanoidRootPart.Position - list.Part.Position).Magnitude then
					return
				end
			else
				return
			end
		end

		local name = list.Name
		local message = list.Message
		local debrisTime = list.DebrisTime or 5
		local color = list.Color or Color3.fromRGB(255, 255, 255)

		if not (name and message) then
			return
		end

		local overlay = list.Overlay

		if popup.Frame:FindFirstChild(name) and not overlay then
			return
		end

		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.Name = name
		clone.RichText = true
		clone.TextColor3 = color
		clone.Text = message
		clone:SetAttribute("DebrisTime", debrisTime)
		clone.Parent = popup.Frame

		if name == "WhirlpoolTrackingQuest" then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15153515341",
				Volume = 0.4,
				Name = "Bought"
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = workspace.Effects
			sound:Play()
		elseif name == "Easter Pass" then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://102911781187143",
				Volume = 1,
				Name = "LevelUp"
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = workspace.Effects
			sound:Play()
		end
	elseif p == "Legacy Event" then
		local name = list.Name or nil
		local color = list.Color or "<font color=\"#55ff00\">"

		if not name then
			return
		end

		local text = color .. name .. "</font> has appeared in the sea."

		if localPlayer.PlayerStats.Language.Value == "TH" then
			text = color .. name .. "</font> ได้ปรากฏขึ้นในท้องทะเล"
		end

		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.Name = name
		clone.RichText = true
		clone.Text = text
		clone.Parent = popup.Frame
	elseif p == "Dungeon Awake Progress" then
		local fruitName = list.FruitName or nil
		local fruitTextColor = list.FruitTextColor or "<font color=\"#ffff7f\">"
		local requireNumber = list.RequireNumber
		local getDungeonNumber = list.GetDungeonNumber
		local dungeonWorld = list.DungeonWorld or 1

		if not fruitName then
			return
		end

		local v4 = "???"
		local v5

		if localPlayer.PlayerStats.Language.Value == "TH" then
			if dungeonWorld == 1 then
				v5 = "โลกหนึ่ง"
			elseif dungeonWorld == 2 then
				v5 = "โลกสอง"
			elseif dungeonWorld == 3 then
				v5 = "โลกสาม"
			else
				v5 = v4
			end
		elseif dungeonWorld == 1 then
			v5 = "1st Sea"
		elseif dungeonWorld == 2 then
			v5 = "2nd Sea"
		elseif dungeonWorld == 3 then
			v5 = "3rd Sea"
		else
			v5 = v4
		end

		local text = "Complete the " .. v5 .. " Dungeon with the " .. fruitTextColor .. fruitName .. "</font> " .. requireNumber .. " time(s) <font color=\"#00ff00\">(" .. getDungeonNumber .. "/" .. requireNumber .. ")</font>"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			text = "เคลียร์ดันเจี้ยน " .. v5 .. " ด้วยพลัง " .. fruitTextColor .. fruitName .. "</font> " .. requireNumber .. " ครั้ง <font color=\"#00ff00\">(" .. getDungeonNumber .. "/" .. requireNumber .. ")</font>"
		end

		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.Name = fruitName
		clone.RichText = true
		clone.Text = text
		clone.Parent = popup.Frame
	elseif p == "BattleCount" then
		local text = list.Text
		local battleTimeLeft = popup.Frame:FindFirstChild("Battle Time Left")

		if battleTimeLeft then
			battleTimeLeft.Text = text
			battleTimeLeft:SetAttribute("DebrisTime", 5)
		else
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.Name = "Battle Time Left"
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.RichText = true
			clone.Text = text
			clone:SetAttribute("DebrisTime", 2)
			clone.Parent = popup.Frame
		end
	elseif p == "DungeonTimeCount" then
		local text = list.Text
		local dungeonTimeCount = popup.Frame:FindFirstChild("DungeonTimeCount")

		if dungeonTimeCount then
			dungeonTimeCount.Text = "Time Left: " .. text
			dungeonTimeCount:SetAttribute("DebrisTime", 5)
		else
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.Name = "DungeonTimeCount"
			clone.TextColor3 = Color3.fromRGB(119, 232, 255)
			clone.RichText = true
			clone.Text = "Time Left: " .. text
			clone:SetAttribute("DebrisTime", 2)
			clone.Parent = popup.Frame
		end
	elseif p == "Tentacle Solo Quest" then
		if popup.Frame:FindFirstChild("Tentacle Solo Quest") then
			return
		end

		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.Name = "Tentacle Solo Quest"
		clone.TextColor3 = Color3.fromRGB(255, 80, 80)
		clone.RichText = true
		clone.Text = "Solo Quest!"
		local clone2 = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone2.Name = "Tentacle Solo Quest2"
		clone2.TextColor3 = Color3.fromRGB(255, 255, 255)
		clone2.RichText = true
		clone2.Text = "Cannot attack enemies who are in a solo mission."

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "ภารกิจฉายเดี่ยว!"
			clone2.Text = "ไม่สามารถโจมตีศัตรูที่กำลังอยู่ในภารกิจเดี่ยวได้"
		end

		clone.Parent = popup.Frame
		clone2.Parent = popup.Frame
	elseif p == "Armament Require" then
		if popup.Frame:FindFirstChild("Armament Require") then
			return
		end

		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.Name = "Armament Require"
		clone.TextColor3 = Color3.fromRGB(255, 80, 80)
		clone.RichText = true
		clone.Text = "Enemy is immune to physical attacks!"
		local clone2 = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone2.Name = "Armament Require2"
		clone2.TextColor3 = Color3.fromRGB(255, 255, 255)
		clone2.RichText = true
		clone2.Text = "Activate your <font color=\"#aaaaff\">Armament</font> to deal damage [Hotkey: T]"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "ศัตรูมีภูมิคุ้มกันต่อการโจมตีทางกายภาพ!"
			clone2.Text = "เปิดใช้งาน<font color=\"#aaaaff\">เสริมแกร่ง</font>ของคุณเพื่อสร้างความเสียหาย [ปุ่ม: T]"
		end

		clone.Parent = popup.Frame
		clone2.Parent = popup.Frame
	elseif p == "Most Damage Fruit Reward" then
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.Name = "Most Damage"
		clone.TextColor3 = Color3.fromRGB(255, 80, 80)
		clone.RichText = true
		clone.Text = "You did the most damage!"
		local clone2 = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone2.Name = "Legacy Fruit Reward"
		clone2.TextColor3 = Color3.fromRGB(255, 255, 255)
		clone2.RichText = true
		clone2.Text = "You got a random fruit."

		if localPlayer.PlayerStats.Language.Value == "TH" then
			clone.Text = "คุณสร้างความเสียหายเยอะที่สุด!"
			clone2.Text = "คุณได้รับผลไม้แบบสุ่ม"
		end

		clone.Parent = popup.Frame
		clone2.Parent = popup.Frame
	elseif p == "Torch Quest Time" then
		local message = list.Message or nil
		local newText = list.NewText or nil

		if newText then
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.Name = "Torch Quest Time New"
			clone.TextColor3 = list.Color or Color3.fromRGB(255, 255, 255)
			clone.RichText = true
			clone.Text = newText
			clone:SetAttribute("DebrisTime", 3)
			clone.Parent = popup.Frame
		end

		local torchQuestTime = popup.Frame:FindFirstChild("Torch Quest Time")

		if torchQuestTime then
			if message then
				torchQuestTime.Text = message
			end

			torchQuestTime:SetAttribute("DebrisTime", 5)
		elseif message then
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.Name = "Torch Quest Time"
			clone.TextColor3 = list.Color or Color3.fromRGB(255, 255, 255)
			clone.RichText = true
			clone.Text = message
			clone:SetAttribute("DebrisTime", 3)
			clone.Parent = popup.Frame
		end
	elseif p == "SB Puzzle Quest Time" then
		local message = list.Message or nil
		local newText = list.NewText or nil

		if newText then
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.Name = "SB Puzzle Quest Time New"
			clone.TextColor3 = list.Color or Color3.fromRGB(255, 255, 255)
			clone.RichText = true
			clone.Text = newText
			clone:SetAttribute("DebrisTime", 3)
			clone.Parent = popup.Frame
		end

		local sBPuzzleQuestTime = popup.Frame:FindFirstChild("SB Puzzle Quest Time")

		if sBPuzzleQuestTime then
			if message then
				sBPuzzleQuestTime.Text = message
			end

			sBPuzzleQuestTime:SetAttribute("DebrisTime", 5)
		elseif message then
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.Name = "SB Puzzle Quest Time"
			clone.TextColor3 = list.Color or Color3.fromRGB(255, 255, 255)
			clone.RichText = true
			clone.Text = message
			clone:SetAttribute("DebrisTime", 3)
			clone.Parent = popup.Frame
		end
	elseif p == "Trade SafeZone" then
		local you = list.You or nil
		local name = list.Name
		local playerName = list.PlayerName or "Player"

		if you then
			playerName = localPlayer.PlayerStats.Language.Value == "TH" and "คุณ" or "You"
		end

		local text = "<font color =\"#00ff00\">" .. playerName .. "</font> must be in safezone!"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			text = "<font color =\"#00ff00\">" .. playerName .. "</font> ต้องอยู่ในเขตปลอดภัย!"
		end

		local overlay = list.Overlay

		if popup.Frame:FindFirstChild(name) and not overlay then
			return
		end

		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.Name = name
		clone.TextColor3 = Color3.fromRGB(255, 116, 116)
		clone.RichText = true
		clone.Text = text
		clone.Parent = popup.Frame
	elseif p == "Target Dodge Left To Target" then
		local dodgeCount = list.DodgeCount
		local maxCount = list.MaxCount
		local enemy = list.Enemy
		local name = "Dodge " .. enemy.Name
		local child = popup.Frame:FindFirstChild(name)

		if child then
			if localPlayer.PlayerStats.Language.Value == "TH" then
				child.Text = "คุณได้หลบ <font color=\"#ffaa00\">" .. enemy.Name .. "</font> <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			else
				child.Text = "You have dodged <font color=\"#ffaa00\">" .. enemy.Name .. "</font> <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			end

			if rotation == -10 then
				rotation = 10
			elseif rotation == 10 then
				rotation = -10
			end

			child.Rotation = 0
			TweenService:Create(
				child,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					Rotation = rotation
				}
			):Play()
			child:SetAttribute("DebrisTime", 5)
		else
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.Name = name
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.RichText = true
			clone:SetAttribute("DebrisTime", 2)
			clone.Parent = popup.Frame

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "คุณได้หลบ <font color=\"#ffaa00\">" .. enemy.Name .. "</font> <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			else
				clone.Text = "You have dodged <font color=\"#ffaa00\">" .. enemy.Name .. "</font> <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			end
		end
	elseif p == "Target Dodge Left To Player" then
		local dodgeCount = list.DodgeCount
		local maxCount = list.MaxCount
		local enemy = list.Enemy
		local name = "Dodge " .. enemy.Name
		local child = popup.Frame:FindFirstChild(name)

		if child then
			if localPlayer.PlayerStats.Language.Value == "TH" then
				child.Text = "<font color=\"#ffaa00\">" .. enemy.Name .. "</font> หลบคุณได้ " .. " <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			else
				child.Text = "<font color=\"#ffaa00\">" .. enemy.Name .. "</font> have dodged you " .. " <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			end

			if rotation == -10 then
				rotation = 10
			elseif rotation == 10 then
				rotation = -10
			end

			child.Rotation = 0
			TweenService:Create(
				child,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					Rotation = rotation
				}
			):Play()
			child:SetAttribute("DebrisTime", 5)
		else
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.Name = name
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.RichText = true
			clone:SetAttribute("DebrisTime", 2)
			clone.Parent = popup.Frame

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "<font color=\"#ffaa00\">" .. enemy.Name .. "</font> หลบคุณได้ " .. " <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			else
				clone.Text = "<font color=\"#ffaa00\">" .. enemy.Name .. "</font> have dodged you " .. " <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			end
		end
	elseif p == "Target Dodge Enemy" then
		local dodgeCount = list.DodgeCount
		local maxCount = list.MaxCount
		local _ = list.Enemy
		local selfDodge = popup.Frame:FindFirstChild("SelfDodge")

		if selfDodge then
			if localPlayer.PlayerStats.Language.Value == "TH" then
				selfDodge.Text = "คุณได้หลบศัตรู <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			else
				selfDodge.Text = "You have dodged enemy <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			end

			if rotation == -10 then
				rotation = 10
			elseif rotation == 10 then
				rotation = -10
			end

			selfDodge.Rotation = 0
			TweenService:Create(
				selfDodge,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					Rotation = rotation
				}
			):Play()
			selfDodge:SetAttribute("DebrisTime", 5)
		else
			local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
			clone.Name = "SelfDodge"
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.RichText = true
			clone:SetAttribute("DebrisTime", 2)
			clone.Parent = popup.Frame

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "คุณได้หลบศัตรู <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			else
				clone.Text = "You have dodged enemy <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			end
		end
	else
		local clone = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.RichText = true
		clone.TextColor3 = Color3.fromRGB(255, 0, 0)

		if p == "Pvp Off Player" then
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ผู้เล่นนี้<font color=\"#ff0000\">ปิด PvP</font>"
			else
				clone.Text = "This player has <font color=\"#ff0000\">PvP disabled</font>"
			end
		elseif p == "Boss Despawned" then
			local bossName = list.BossName or "N/A"
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "<font color=\"#ff0000\">" .. bossName .. "</font> ได้หายไปแล้ว!"
			else
				clone.Text = "<font color=\"#ff0000\">" .. bossName .. "</font> has despawned!"
			end
		elseif p == "You got Fruits" then
			local fruitName = list.FruitName
			local v4 = tostring(string.gsub(fruitName, "Fruit", " Fruit"))

			if CustomNames[v4] then
				v4 = CustomNames[v4]
			end

			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "คุณได้รับ <font color=\"#55ff00\">" .. v4 .. "</font> !!!"
			else
				clone.Text = "You got <font color=\"#55ff00\">" .. v4 .. "</font> !!!"
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://8614300513",
				Volume = 0.1,
				Name = "ItemDrop"
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = workspace.Effects
			sound:Play()
		elseif p == "Race Rerolls" then
			local raceName = list.RaceName
			local v4 = raceName == "Mink" and "Animal" or raceName == "Sky" and "Angel" or raceName
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "เผ่าเป็นเปลี่ยนเป็น <font color=\"#aaffff\">" .. v4 .. "</font>"
			else
				clone.Text = "Race changed to <font color=\"#aaffff\">" .. v4 .. "</font>"
			end
		elseif p == "Fighting Style Changed" then
			local fSName = list.FSName

			if CustomNames[fSName] then
				fSName = CustomNames[fSName]
			end

			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ไสตล์การต่อสู้เปลี่ยนเป็น <font color=\"#aaffff\">" .. fSName .. "</font>"
			else
				clone.Text = "Fighting Style changed to <font color=\"#aaffff\">" .. fSName .. "</font>"
			end
		elseif p == "Power Fruit Changed" then
			local dFName = list.DFName
			local v4 = tostring((string.sub(dFName, 1, #dFName / 2)))

			if CustomNames[v4] then
				v4 = CustomNames[v4]
			end

			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = v4 .. "<font color=\"#55ff00\"> เปิดใช้งาน!</font>"
			else
				clone.Text = v4 .. "<font color=\"#55ff00\"> Activated!</font>"
			end
		elseif p == "Refunded stats points" then
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "รีเซ็ตพ้อยคืนเรียบร้อย!"
			else
				clone.Text = "Refunded stats points!"
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15153515341",
				Volume = 0.4,
				Name = "Bought"
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = workspace.Effects
			sound:Play()
		elseif p == "+1 Refund Stats" then
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "+1 <font color=\"#00ff00\">รีเซ็ตค่าพลัง</font> (เปิดหน้าต่างค่าพลังของคุณ)"
			else
				clone.Text = "+1 <font color=\"#00ff00\">Refund Stats</font> (Open your stats menu)"
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15153515341",
				Volume = 0.4,
				Name = "Bought"
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = workspace.Effects
			sound:Play()
		elseif p == "BountyCooldown" then
			local _, v4 = unpack(list)
			local name = v4.Name or ""
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ค่าหัว <font color=\"#ff0000\">" .. name .. "</font> ถึงขีด<font color=\"#ff0000\">จำกัด</font>ต่อวันแล้ว!"
			else
				clone.Text = "<font color=\"#ff0000\">" .. name .. "</font> Bounty is now <font color=\"#ff0000\">limited</font> per day!"
			end
		elseif p == "Out Of Danger" then
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "คุณ<font color=\"#00ffff\">พ้นการต่อสู้</font>แล้ว"
			else
				clone.Text = "You are <font color=\"#00ffff\">out of combat.</font>"
			end
		elseif p == "Open Pvp Player" then
			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "Pvp ถูกปิด 40 นาที คุณต้องไปเปิดใหม่ที่ Setting"
			else
				clone.Text = "Pvp disabled for 40 minutes [Re-open in settings]"
			end
		elseif p == "Ally Player" then
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ไม่สามารถโจมตี<font color=\"#00ff00\">พันธมิตรของคุณ</font>"
			else
				clone.Text = "Cannot attack your <font color=\"#00ff00\">party members!</font>"
			end
		elseif p == "Crew Player" then
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ไม่สามารถโจมตี<font color=\"#ffaa00\">เพื่อนร่วมแคลน</font>ได้"
			else
				clone.Text = "Cannot attack your <font color=\"#ffaa00\">crew members!</font>"
			end
		elseif p == "Low Level" then
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ผู้เล่นคนนี้<font color=\"#ff0000\">เลเวลต่ำ</font>เกินไป"
			else
				clone.Text = "This Player too <font color=\"#ff0000\">low level.</font>"
			end
		elseif p == "You Low Level" then
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "คุณมี<font color=\"#ff0000\">เลเวลต่ำ</font>เกินไป"
			else
				clone.Text = "You are <font color=\"#ff0000\">low level</font>"
			end
		elseif p == "Sea King Spawn" then
			local v4 = unpack(list)
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.RichText = true

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "<font color=\"#00ff00\">" .. v4 .. "</font> ได้เสก <font color=\"#ffaa00\">Legacy Island</font>"
			else
				clone.Text = "<font color=\"#00ff00\">" .. v4 .. "</font> has spawned <font color=\"#ffaa00\">Legacy Island.</font>"
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15153515341",
				Volume = 0.4,
				Name = "Bought"
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = workspace.Effects
			sound:Play()
		elseif p == "Hydra Spawn" then
			local v4 = unpack(list)
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.RichText = true

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "<font color=\"#00ff00\">" .. v4 .. "</font> ได้เสก <font color=\"#ffaa00\">Hydra Island</font>"
			else
				clone.Text = "<font color=\"#00ff00\">" .. v4 .. "</font> has spawned <font color=\"#ffaa00\">Hydra Island.</font>"
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15153515341",
				Volume = 0.4,
				Name = "Bought"
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = workspace.Effects
			sound:Play()
		elseif p == "Ghost Ship Spawn" then
			local v4 = unpack(list)
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.RichText = true

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "<font color=\"#ffaa00\">" .. v4 .. "</font> ได้เสก <font color=\"#00ff00\">Ghost Ship</font>"
			else
				clone.Text = "<font color=\"#ffaa00\">" .. v4 .. "</font> has spawned <font color=\"#00ff00\">Ghost Ship.</font>"
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15153515341",
				Volume = 0.4,
				Name = "Bought"
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = workspace.Effects
			sound:Play()
		elseif p == "No Sea King Here" then
			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ไม่สามารถใช้ได้ในที่นี้"
			else
				clone.Text = "not available here"
			end
		elseif p == "Sea King Already" then
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.RichText = true

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "มี <font color=\"#ffaa00\">Legacy Island</font> อยู่แล้ว"
			else
				clone.Text = "There is already a <font color=\"#ffaa00\">Legacy Island.</font>"
			end
		elseif p == "Sea King Hydra Already" then
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.RichText = true

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "มี <font color=\"#ffaa00\">Hydra Island</font> อยู่แล้ว"
			else
				clone.Text = "There is already a <font color=\"#ffaa00\">Hydra Island.</font>"
			end
		elseif p == "Ghost Ship Already" then
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.RichText = true

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "มี <font color=\"#ffaa00\">เรือผีสิง</font> อยู่แล้ว"
			else
				clone.Text = "There is already a <font color=\"#ffaa00\">Ghost Ship.</font>"
			end
		elseif p == "Max Slot Fruit" then
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "คุณอัพเกรดจนสูงสุดแล้ว"
			else
				clone.Text = "You have upgraded to the maximum."
			end
		elseif p == "No Gem Upgrade Slot Fruit" then
			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "คุณมีมณีไม่เพียงพอ"
			else
				clone.Text = "Not enough gems"
			end
		elseif p == "Upgraded Slot Fruit" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "<font color=\"#00ff00\">+1</font> สล็อต อัพเกรดสำเร็จแล้ว"
			else
				clone.Text = "<font color=\"#00ff00\">+1</font> Slot Upgrade Successfully"
			end
		elseif p == "Bullitus Explode" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "<font color=\"#00ffff\">Bullitus</font> ระเบิดออกแล้ว"
			else
				clone.Text = "<font color=\"#00ffff\">The Bullitus</font> has exploded"
			end
		elseif p == "Banid" then
			local v4, v5 = unpack(list)
			clone.TextColor3 = Color3.fromRGB(math.random(100, 255), math.random(100, 255), math.random(100, 255))
			clone.Text = v4 .. " banned userid: " .. v5
		elseif p == "Ban" then
			local v4 = unpack(list)
			clone.TextColor3 = Color3.fromRGB(math.random(100, 255), math.random(100, 255), math.random(100, 255))
			clone.Text = "You banned player name: " .. v4
		elseif p == "Unbanid" then
			local v4, v5 = unpack(list)
			clone.TextColor3 = Color3.fromRGB(math.random(100, 255), math.random(100, 255), math.random(100, 255))
			clone.Text = v4 .. " unbanned userid: " .. v5
		elseif p == "Dodge Increased" then
			local dodgeCount = list.DodgeCount
			local maxCount = list.MaxCount
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "การหลบเพิ่มขึ้น <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			else
				clone.Text = "Dodge increased <font color=\"#55ffff\">(" .. dodgeCount .. "/" .. maxCount .. ")</font>"
			end
		elseif p == "Equipped Fruit" then
			local v4 = unpack(list)
			local v5 = tostring((string.sub(v4, 1, #v4 / 2)))

			if CustomNames[v5] then
				v5 = CustomNames[v5]
			end

			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = v5 .. " <font color=\"#55ff00\">ถูกใช้งาน!</font>"
			else
				clone.Text = v5 .. " <font color=\"#55ff00\">Activated!</font>"
			end
		elseif p == "Eaten Fruit" then
			local v4 = unpack(list)
			local v5 = tostring((string.sub(v4, 1, #v4 / 2))) .. " Fruit"

			if CustomNames[v5] then
				v5 = CustomNames[v5]
			end

			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "คุณกินผลไม้ <font color=\"#55ff00\">" .. v5 .. "</font>"
			else
				clone.Text = "You eat <font color=\"#55ff00\">" .. v5 .. "</font>"
			end
		elseif p == "Collected Fruit" then
			local v4 = unpack(list)
			local v5 = tostring(string.gsub(v4, "Fruit", " Fruit"))

			if CustomNames[v5] then
				v5 = CustomNames[v5]
			end

			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "เก็บ <font color=\"#55ff00\">" .. v5 .. "</font> เข้ากระเป๋าแล้ว"
			else
				clone.Text = "Stored <font color=\"#55ff00\">" .. v5 .. "</font> to fruit bag."
			end
		elseif p == "Dropped Fruit" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "<font color=\"#ffaaff\">ผลไม้</font>ถูก<font color=\"#ff0000\">ทิ้ง</font>แล้ว"
			else
				clone.Text = "The <font color=\"#ffaaff\">fruit</font> has been <font color=\"#ff0000\">dropped.</font>"
			end
		elseif p == "Un Dropped Fruit" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 93, 96)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "คุณไม่สามารถทิ้งผลไม้ที่มาจากกระเป๋าผลไม้ได้"
			else
				clone.Text = "You cannot drop fruit that comes from the fruit bag"
			end
		elseif p == "Changed Sword" then
			local v4 = unpack(list)
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if CustomNames[v4] then
				v4 = CustomNames[v4]
			end

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "คุณใช้ดาบ <font color=\"#00ff00\">" .. v4 .. "</font> แล้ว"
			else
				clone.Text = "You have Equipped <font color=\"#00ff00\">" .. v4 .. "</font>"
			end
		elseif p == "Changed Accessory" then
			local v4 = unpack(list)

			if CustomNames[v4] then
				v4 = CustomNames[v4]
			end

			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "เปลี่ยนเครื่องประดับ <font color=\"#ffff7f\">" .. v4 .. "</font>"
			else
				clone.Text = "Changed Accessory <font color=\"#ffff7f\">" .. v4 .. "</font>"
			end
		elseif p == "Removed Accessory" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ถอด<font color=\"#ffff7f\">เครื่องประดับ</font>"
			else
				clone.Text = "Removed <font color=\"#ffff7f\">Accessory</font>"
			end
		elseif p == "Added Fruit" then
			local v4 = unpack(list)
			local v5 = tostring(string.gsub(v4, "Fruit", " Fruit"))

			if CustomNames[v5] then
				v5 = CustomNames[v5]
			end

			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "เพิ่ม <font color=\"#ffaaff\">" .. v5 .. "</font> ไปยังแถบกระเป๋า."
			else
				clone.Text = "Added <font color=\"#ffaaff\">" .. v5 .. "</font> to backpack."
			end
		elseif p == "Fruit Bag Is Close" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "<font color=\"#ffaaff\">กระเป๋าผลไม้</font> <font color=\"#ff0000\">ใช้ไม่ได้</font> ในที่นี่!"
			else
				clone.Text = "<font color=\"#ffaaff\">Fruit Bag</font> are <font color=\"#ff0000\">not available</font> here!"
			end
		elseif p == "Anti Ally Marines" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "นาวิกโยธินไม่สามารถ<font color=\"#ffaaff\">ใช้ฟังก์ชันพันธมิตรได้</font>"
			else
				clone.Text = "Marines cannot use the <font color=\"#ffaaff\">ally function.</font>"
			end
		elseif p == "No passive to store" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 108, 108)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ไม่มีพาสซีฟให้เก็บ"
			else
				clone.Text = "No passives to store!"
			end
		elseif p == "No passive to equip" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 108, 108)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "ช่องนี้ว่างเปล่า!"
			else
				clone.Text = "This slot is empty!"
			end
		elseif p == "Passive store success" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 0, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "เก็บพาสซีฟไว้ได้สำเร็จ!"
			else
				clone.Text = "Passives stored successfully!"
			end
		elseif p == "Passive equip success" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(0, 255, 0)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "พาสซีฟทั้งหมดถูกใช้งาน"
			else
				clone.Text = "All passives equipped!"
			end
		elseif p == "Conqueror Access Drop" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "<font color=\"#ffff00\">พลังราชันย์</font>ของคุณได้รับสิทธิ์สำหรับสี"
			else
				clone.Text = "Your <font color=\"#ffff00\">Conqueror</font> Shade Eligible"
			end
		elseif p == "Dragon Arc Drop" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "คุณได้รับโชคของ<font color=\"#ffff00\">เกล็ดมังกร</font>"
			else
				clone.Text = "You get the luck of <font color=\"#ffff00\">dragon scale</font>"
			end
		elseif p == "Night Blade Power" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "คุณได้รับพลังแห่งความ<font color=\"#00ff00\">เขียวขจี!</font>"
			else
				clone.Text = "You get the force of <font color=\"#00ff00\">verdant!</font>"
			end
		elseif p == "Night Blade Awaken" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "<font color=\"#00ff00\">Night Blade</font> ถูกปลุกพลังขึ้นแล้ว!"
			else
				clone.Text = "<font color=\"#00ff00\">Night Blade</font> has been awakened!"
			end
		elseif p == "Shred Endangering Island Changed" then
			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "บางอย่างเปลี่ยนไปในเกาะ <font color=\"#ffaa00\">Shred Endangering</font>"
			else
				clone.Text = "Something has changed in the <font color=\"#ffaa00\">Shred Endangering</font>"
			end
		elseif p == "Armament Color" then
			local colorName = list.ColorName

			local function ColorHTML(colorName2)
				if colorName2 == "White" then
					return "#ffffff"
				elseif colorName2 == "Lime" then
					return "#aaff00"
				elseif colorName2 == "Green" then
					return "#00ff00"
				elseif colorName2 == "Yellow" then
					return "#ffff00"
				elseif colorName2 == "Carmine" then
					return "#ff0000"
				elseif colorName2 == "Fuchia" then
					return "#ff00ff"
				elseif colorName2 == "Azure" then
					return "#00ffff"
				elseif colorName2 == "Ultramarine" then
					return "#0000ff"
				elseif colorName2 == "Apricot" then
					return "#ffaa00"
				elseif colorName2 == "Indigo" then
					return "#aa00ff"
				end

				return colorName2 == "Arc" and "#000000" or "#ffffff"
			end

			clone.RichText = true
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				clone.Text = "Armament เปลี่ยนสีเป็น <font color =\"" .. ColorHTML(colorName) .. "\">" .. colorName .. "</font>"
			else
				clone.Text = "Armament Color change to <font color =\"" .. ColorHTML(colorName) .. "\">" .. colorName .. "</font>"
			end
		end

		clone.Parent = popup.Frame
	end
end)
ReplicatedStorage.Chest.Remotes.Events.Tween.OnClientEvent:connect(function(part, list, items)
	spawn(function()
		if part and part:IsA("BasePart") and (workspace.CurrentCamera.CFrame.Position - part.Position).magnitude >= 1000 then
			return
		end

		if part and part:IsA("BasePart") then
			local _ = (workspace.CurrentCamera.CFrame.Position - part.Position).magnitude < 1000
		end

		if part then
			local TweenService2 = game:GetService("TweenService")
			local tween = TweenService2:Create(part, TweenInfo.new(unpack(list)), items)
			tween:Play()
			tween.Completed:connect(function()
				for k, item in pairs(items) do
					part[k] = item
				end
			end)
		end
	end)
end)