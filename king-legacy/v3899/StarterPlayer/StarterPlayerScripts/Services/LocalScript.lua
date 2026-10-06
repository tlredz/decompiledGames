local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
game:GetService("ProximityPromptService")

local function getval()
	return (HttpService:GenerateGUID(true))
end

local mouse = localPlayer:GetMouse()
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
workspace:WaitForChild("AllDroppedFruit")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
_G.LevelMaxClient = 5450
_G.ArmamentLevelMaxClient = 6
local MaterialList = require(ReplicatedStorage.Chest.Modules.MaterialList)
local ArmamentColorList = require(ReplicatedStorage.Chest.Modules.ArmamentColorList)

function _G.ArmamentColorUpdateClient(p)
	return ArmamentColorList[p].Color or Color3.fromRGB(255, 255, 255)
end

local flag = nil

function _G.ClickFrameEffect(data)
	if flag or not localPlayer.PlayerGui or not localPlayer.PlayerGui:FindFirstChild("Popup") then
		return
	end

	flag = true
	task.delay(0.05, function()
		flag = nil
	end)
	local clone = ReplicatedStorage.Chest.Gui.ClickFrame:Clone()
	clone.Size = UDim2.new()
	clone.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
	clone.Parent = localPlayer.PlayerGui.Popup
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		Size = UDim2.new(0.4, 0, 0.4, 0),
		ImageTransparency = 1
	}):Play()
	_G.PU:Dust(clone, 0.3)

	if data then
		if data.Sound then
			if data.Sound2 then
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 10000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://6228296129",
					Volume = 0.75
				})
				_G.PU:Dust(sound, 1)
				sound.Parent = clone
				sound:Play()
			elseif data.MenuSound then
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 10000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://9114380579",
					Volume = 1.2
				})
				_G.PU:Dust(sound, 1)
				sound.Parent = clone
				sound:Play()
			else
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 10000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://9486304857",
					Volume = 0.75
				})
				_G.PU:Dust(sound, 1)
				sound.Parent = clone
				sound:Play()
			end
		end

		if data.Parent then
			clone.Parent = data.Parent
		end
	end
end

function _G.DestroyObservationObject()
	task.spawn(function()
		for _, highlight in pairs(localPlayer.Character:GetChildren()) do
			if highlight:IsA("Highlight") and highlight.Name == "HighlightPlayer" then
				highlight:Destroy()
			end
		end
	end)

	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant:IsA("BillboardGui") and (descendant.Name == "ObservationNameUsed" or descendant.Name == "ObservationHealthUsed" or descendant.Name == "ObservationToolsUsed" or descendant.Name == "ObservationPassives" or descendant.Name == "ObservationTargetUsed") then
			descendant:Destroy()
		elseif descendant:IsA("Highlight") and descendant.Name == "ObservationHighlightUsed" then
			descendant:Destroy()
		end
	end

	for _, descendant in pairs(ReplicatedStorage.MOB:GetDescendants()) do
		if descendant:IsA("BillboardGui") and (descendant.Name == "ObservationNameUsed" or descendant.Name == "ObservationHealthUsed" or descendant.Name == "ObservationToolsUsed" or descendant.Name == "ObservationPassives" or descendant.Name == "ObservationTargetUsed") then
			descendant:Destroy()
		elseif descendant:IsA("Highlight") and descendant.Name == "ObservationHighlightUsed" then
			descendant:Destroy()
		end
	end

	for _, character in pairs(workspace.PlayerCharacters:GetChildren()) do
		local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)

		if playerFromCharacter then
			playerFromCharacter.Character.Humanoid.DisplayName = playerFromCharacter.Character.Humanoid.Parent.Name
		end
	end
end

function GetBackpackCapacity()
	local count = 0

	for _, tool in pairs(localPlayer.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:GetAttribute("LegacyFruit") then
			count += 1
		end
	end

	local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")

	if tool and tool:GetAttribute("LegacyFruit") then
		count += 1
	end

	return count
end

function _G.CheckAllyClient(instance, p)
	if not (p and instance ~= p) then
		return
	end

	local allies = instance:FindFirstChild("Allies")

	if allies and allies:FindFirstChild(p.Name) then
		return true
	end

	return false
end

function _G.ReturnEffects(p, p2)
	if not (p2 and p ~= p2) then
		return
	end

	if (_G.CheckSettingClient(p, "Setting_AllyEffects") or not _G.CheckAllyClient(p, p2)) and not _G.CheckSettingClient(
		p,
		"Setting_HideAllEffects"
	) then
		return
	end

	return true
end

function _G.StopAnimationClient(object, options)
	local v = options or {}
	task.spawn(function()
		object = _G.PU.GetAnimator(object)

		for _, v2 in pairs(object:GetPlayingAnimationTracks()) do
			if not v[v2.Name] then
				continue
			end

			v2:Stop()

			if v2.Name ~= "Fly" then
				continue
			end

			local v3 = v2
			task.delay(0.2, function()
				v3:Stop()
			end)
		end

		task.delay(5, function()
			table.clear(v)
		end)
	end)
end

function _G.CheckForcePowerClient(p, player)
	local powerType = player.PowerType
	local character = player.Character
	local amount = player.Amount
	local alertText = player.AlertText or nil
	local secondForm = player.SecondForm
	local thirdForm = player.ThirdForm
	local child = character:FindFirstChild(powerType)

	if not (child and child:FindFirstChild("Power")) then
		return false
	end

	local power = child.Power

	if amount <= power.Value then
		power.Value -= amount
		return true
	end

	if secondForm or thirdForm or alertText then
		local message = p.PlayerStats.Language.Value == "TH" and "Force ไม่พอ" or "Not enough force"
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
			Name = "No Force",
			Overlay = true,
			Message = message,
			Color = Color3.fromRGB(255, 160, 160)
		})
	end

	return false
end

function _G.CheckStunClient(character)
	if character:IsA("Player") then
		character = character.Character
	end

	if character:FindFirstChild("Stun") then
		return true
	end

	return false
end

function _G.InstanceDoingClient(p)
	local parent = p.Parent

	if parent:IsA("Player") then
		parent = parent.Character
	end

	local folder = Instance.new("Folder")
	folder.Name = "TotalDoing"
	local v = {
		Parent = parent,
		Object = folder
	}
	folder.Parent = parent
	setmetatable(v, require(ReplicatedStorage.Chest.Modules.FunctionModules))
	return v
end

function _G.CheckDoingClient(character)
	if character:IsA("Player") then
		character = character.Character
	end

	if character:FindFirstChild("TotalDoing") then
		return true
	end

	return false
end

function _G.CheckSwordClient(p, childName)
	if p.Inventory:FindFirstChild(childName) then
		return true
	end

	return nil
end

function _G.GetAwakeClient(instance)
	local playerStats = instance:FindFirstChild("PlayerStats")

	if not playerStats then
		return false
	end

	local misc = playerStats:FindFirstChild("Misc")

	if misc then
		return HttpService:JSONDecode(misc.Value)
	end

	return false
end

function _G.CheckAwakeClient(instance, p)
	local playerStats = instance:FindFirstChild("PlayerStats")

	if not playerStats then
		return false
	end

	local misc = playerStats:FindFirstChild("Misc")

	if not misc then
		return false
	end

	if HttpService:JSONDecode(misc.Value)[p] then
		return true
	end

	return false
end

function _G.CheckTitleClient(instance, p)
	if not instance:FindFirstChild("DataLoaded") then
		return
	end

	local playerStats = instance:FindFirstChild("PlayerStats")

	if not playerStats then
		return
	end

	if HttpService:JSONDecode(playerStats.TitleStore.Value)[p] then
		return true
	end

	return nil
end

function _G.CheckQuestProgressClient(instance, p)
	local playerStats = instance:FindFirstChild("PlayerStats")

	if not (playerStats and instance:FindFirstChild("DataLoaded")) then
		return
	end

	return HttpService:JSONDecode(playerStats.QuestProgression.Value)[p]
end

function _G.RaceDecodeClient(p)
	return (HttpService:JSONDecode(p.PlayerStats.RaceTbl.Value))
end

function _G.CanStoreFruitClient(p, value)
	if not localPlayer:FindFirstChild("DataLoaded") then
		return
	end

	local playerStats = localPlayer:FindFirstChild("PlayerStats")

	if not playerStats then
		return
	end

	local fruitStore = playerStats.FruitStore
	local fruitStorage = playerStats.FruitStorage

	if (HttpService:JSONDecode(fruitStore.Value)[p] or 0) + (value or 1) <= fruitStorage.Value then
		return true
	end
end

function _G.HasAnyFishClient(instance)
	if not instance:FindFirstChild("DataLoaded") then
		return
	end

	local playerStats = instance:FindFirstChild("PlayerStats")

	if not playerStats then
		return
	end

	local material = playerStats:FindFirstChild("Material")

	if not material then
		return
	end

	local jSONDecode = HttpService:JSONDecode(material.Value)

	for k, _ in pairs(jSONDecode) do
		local v = MaterialList[k]

		if v and v.Fish then
			return true
		end
	end
end

function _G.CheckMaterialClient(instance, p, value)
	local jSONDecode = HttpService:JSONDecode(instance:WaitForChild("PlayerStats"):WaitForChild("Material").Value)

	if jSONDecode[p] and (value or 1) <= jSONDecode[p] then
		return jSONDecode[p]
	end

	return nil
end

function _G.CheckFruitProgressionClient(instance, p)
	if HttpService:JSONDecode(instance:WaitForChild("PlayerStats"):WaitForChild("AwakeProgression").Value)[p] then
		return true
	end

	return false
end

function _G.CheckSettingClient(instance, p)
	if not instance:FindFirstChild("DataLoaded") then
		return false
	end

	if HttpService:JSONDecode(instance:WaitForChild("PlayerStats"):WaitForChild("Settings").Value)[p] then
		return true
	end

	return false
end

function _G.Suffix(p)
	local v = math.floor(p)

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

	if p >= 1000000000000000 and p < 1e18 then
		return tostring(math.floor(p / 1000000000000000 * 100) / 100) .. "Qa"
	end

	if p >= 1e18 and p < 1e21 then
		return tostring(math.floor(p / 1e18 * 100) / 100) .. "qi"
	end

	if p >= 1e21 and p < 1e24 then
		return tostring(math.floor(p / 1e21 * 100) / 100) .. "Sx"
	end

	if p >= 1e24 and p < 1e27 then
		return tostring(math.floor(p / 1e24 * 100) / 100) .. "Sp"
	end

	if p >= 1e27 and p < 1e30 then
		return tostring(math.floor(p / 1e27 * 100) / 100) .. "Oc"
	end

	if p >= 1e30 and p < 1e33 then
		return tostring(math.floor(p / 1e30 * 100) / 100) .. "No"
	end

	if p >= 1e33 and p < 1e36 then
		return tostring(math.floor(p / 1e33 * 100) / 100) .. "Dc"
	end

	if p >= 1e36 and p < 1e39 then
		return tostring(math.floor(p / 1e36 * 100) / 100) .. "Udc"
	end

	if p >= 1e39 and p < 1e42 then
		return tostring(math.floor(p / 1e39 * 100) / 100) .. "Ddc"
	end

	if p >= 1e42 and p < 1e45 then
		return tostring(math.floor(p / 1e42 * 100) / 100) .. "Tdc"
	end

	if p >= 1e45 and p < 1e48 then
		return tostring(math.floor(p / 1e45 * 100) / 100) .. "qdc"
	end

	if p >= 1e48 and p < 1e51 then
		return tostring(math.floor(p / 1e48 * 100) / 100) .. "Qdc"
	end

	if p >= 1e51 and p < 1e54 then
		return tostring(math.floor(p / 1e51 * 100) / 100) .. "Hdc"
	end

	if p >= 1e54 and p < 1e57 then
		return tostring(math.floor(p / 1e54 * 100) / 100) .. "Sdc"
	end

	if p >= 1e57 and p < 1e60 then
		return tostring(math.floor(p / 1e57 * 100) / 100) .. "Odc"
	end

	if p >= 1e60 and p < 1e63 then
		return tostring(math.floor(p / 1e60 * 100) / 100) .. "Ndc"
	end

	if p >= 1e63 and p < 1e66 then
		return tostring(math.floor(p / 1e63 * 100) / 100) .. "Vg"
	end

	if p >= 1e66 and p < 1e69 then
		return tostring(math.floor(p / 1e66 * 100) / 100) .. "Uvg"
	end

	if p >= 1e69 then
		return tostring(math.floor(p / 1e69 * 100) / 100) .. "Dvg"
	end

	return v
end

function _G.Suffix_Comma(p)
	return tostring((math.floor(p))):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local count = 0
local total = 0

repeat
	wait()
until localPlayer.PlayerGui:FindFirstChild("MainGui")

local v = nil
local v2 = nil
local lastTime = tick()
ReplicatedStorage.Chest.Remotes.Events.combo.OnClientEvent:Connect(function(p)
	local comboFrame = localPlayer.PlayerGui.MainGui.StarterFrame.ComboFrame

	if not comboFrame.Visible then
		comboFrame.Visible = true
	end

	count += 1
	total += math.floor(p)
	local v3 = count
	local v4 = total
	local textLabelHit = comboFrame.TextLabelHit
	local textLabelDmg = comboFrame.TextLabelDmg
	local line = comboFrame.Line
	local bGLine = comboFrame.BGLine
	local image = comboFrame.Image
	local color = Color3.fromRGB(255, 255, 255)
	task.spawn(function()
		if total >= 0 and total < 20000 then
			color = Color3.fromRGB(0, 255, 0)
		elseif total >= 20000 and total < 40000 then
			color = Color3.fromRGB(255, 255, 0)
		elseif total >= 40000 and total < 60000 then
			color = Color3.fromRGB(255, 85, 0)
		elseif total >= 60000 and total < 80000 then
			color = Color3.fromRGB(255, 0, 0)
		elseif total >= 80000 and total < 100000 then
			color = Color3.fromRGB(255, 0, 191)
		elseif total >= 100000 and total < 120000 then
			color = Color3.fromRGB(170, 0, 170)
		elseif total >= 120000 and total < 140000 then
			color = Color3.fromRGB(98, 37, 209)
		elseif total >= 140000 and total < 160000 then
			color = Color3.fromRGB(0, 100, 255)
		elseif total >= 160000 and total < 180000 then
			color = Color3.fromRGB(0, 255, 255)
		elseif total >= 180000 and total < 200000 then
			color = Color3.fromRGB(0, 255, 0)
		elseif total >= 200000 and total < 250000 then
			color = Color3.fromRGB(255, 255, 0)
		elseif total >= 250000 and total < 300000 then
			color = Color3.fromRGB(255, 85, 0)
		elseif total >= 300000 and total < 350000 then
			color = Color3.fromRGB(255, 0, 0)
		elseif total >= 350000 and total < 400000 then
			color = Color3.fromRGB(255, 0, 191)
		elseif total >= 400000 and total < 450000 then
			color = Color3.fromRGB(170, 0, 170)
		elseif total >= 450000 and total < 500000 then
			color = Color3.fromRGB(98, 37, 209)
		elseif total >= 500000 and total < 550000 then
			color = Color3.fromRGB(0, 100, 255)
		elseif total >= 550000 and total < 600000 then
			color = Color3.fromRGB(0, 255, 255)
		elseif total >= 600000 and total < 650000 then
			color = Color3.fromRGB(0, 255, 0)
		elseif total >= 650000 and total < 700000 then
			color = Color3.fromRGB(255, 255, 0)
		elseif total >= 700000 and total < 750000 then
			color = Color3.fromRGB(255, 85, 0)
		elseif total >= 750000 then
			color = Color3.fromRGB(255, 0, 0)
		end
	end)
	local v5 = p > 5000
	local v6 = color.R * 0.3
	local v7 = color.G * 0.3
	local v8 = color.B * 0.3
	image.ImageColor3 = color
	image.ImageTransparency = 0.85
	textLabelHit.TextTransparency = 0
	textLabelHit.TextStrokeTransparency = 0.5
	textLabelHit.TextColor3 = color
	textLabelHit.Text = _G.Suffix_Comma(count) .. " HITS"
	textLabelDmg.TextTransparency = 0
	textLabelDmg.TextStrokeTransparency = 0.5
	textLabelDmg.TextColor3 = color
	textLabelDmg.Text = _G.Suffix_Comma(total)
	line.BackgroundTransparency = 0
	line.BackgroundColor3 = color
	bGLine.BackgroundTransparency = 0
	bGLine.BackgroundColor3 = Color3.new(v6, v7, v8)

	if v5 then
		textLabelHit.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabelDmg.TextColor3 = Color3.fromRGB(255, 255, 255)
		line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TweenService:Create(textLabelHit, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			TextColor3 = color
		}):Play()
		TweenService:Create(textLabelDmg, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			TextColor3 = color
		}):Play()
		TweenService:Create(line, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			BackgroundColor3 = color
		}):Play()
	end

	if tick() - lastTime > 0.15 or v5 then
		lastTime = tick()

		if v then
			v:Pause()
			v = nil
		end

		if v2 then
			v2:Pause()
			v2 = nil
		end

		local v9 = v5 and 2 or 1
		line.Size = UDim2.new(0.75, 0, 0.015, 0)
		comboFrame.Size = UDim2.new(v9 * 0.3, 0, v9 * 0.5, 0)
		v = TweenService:Create(line, TweenInfo.new(3, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 0.015, 0)
		})
		v:Play()
		v2 = TweenService:Create(comboFrame, TweenInfo.new(0.3, Enum.EasingStyle.Circular), {
			Size = UDim2.new(0.15, 0, 0.25, 0)
		})
		v2:Play()
	end

	wait(3)

	if count == v3 then
		count = 0
		comboFrame.Visible = false
	end

	if total == v4 then
		total = 0
		textLabelDmg.Text = total
	end
end)
local v3 = false
ReplicatedStorage.Chest.Remotes.Events.camshake.OnClientEvent:connect(function(p, p2, p3)
	if v3 == false then
		v3 = true
		local _ = game.Workspace.CurrentCamera
		spawn(function()
			wait()
			v3 = false
		end)

		for i = p2, 0, p3 do
			workspace.CurrentCamera.CoordinateFrame = workspace.CurrentCamera.CoordinateFrame:lerp(
				workspace.CurrentCamera.CoordinateFrame * CFrame.new(
					math.sin(tick() * p) * i / 1 / 10,
					math.cos(tick() * p) * i / 1 / 10,
					0
				),
				0.1
			)
			RunService.RenderStepped:wait()
		end

		v3 = false
	end
end)
local underwaterCorrection = Lighting.UnderwaterCorrection
local underwaterBlur = Lighting.UnderwaterBlur
local currentCamera = workspace.CurrentCamera
local ambientReverb = SoundService.AmbientReverb
script.UnderwaterSound:Play()

function UPDATE()
	local character = localPlayer.Character

	if not character then
		return
	end

	if not character:GetAttribute("Device") then
		character:SetAttribute("Device", "PC")
	end

	underwaterCorrection.Enabled = false
	underwaterBlur.Enabled = false
	SoundService.AmbientReverb = ambientReverb
	script.UnderwaterSound.Volume = 0
	local race = character:GetAttribute("Race")

	if currentCamera.CFrame.Position.Y <= -3.35 then
		underwaterBlur.Size = 12

		if race and (race == "Fish" or race == "Sea Beast") then
			underwaterBlur.Size = 8
		end

		if not Lighting:FindFirstChild("UnderwaterAt") and ReplicatedStorage.Chest:FindFirstChild("UnderwaterAt") then
			local clone = ReplicatedStorage.Chest.UnderwaterAt:Clone()
			task.spawn(function()
				if race then
					if race == "Fish" then
						clone.Density = 0.375
					elseif race == "Sea Beast" then
						clone.Density = 0.3
					end
				end
			end)
			clone.Parent = Lighting
		end

		underwaterCorrection.Enabled = true
		underwaterBlur.Enabled = true
		SoundService.AmbientReverb = Enum.ReverbType.UnderWater
		script.UnderwaterSound.Volume = 0.25
	elseif Lighting:FindFirstChild("UnderwaterAt") then
		Lighting.UnderwaterAt:Destroy()
	end
end

currentCamera.Changed:Connect(function(p)
	if p == "CFrame" then
		UPDATE()
	end
end)
local UserGameSettings = UserSettings():GetService("UserGameSettings")

function UpdateQuality()
	if tonumber((tostring(UserGameSettings.SavedQualityLevel):gsub("Enum.SavedQualitySetting.QualityLevel", ""))) <= 3 then
		_G.LowQuality = true
	else
		_G.LowQuality = nil
	end
end

UserGameSettings.Changed:Connect(function(p)
	if p == "SavedQualityLevel" then
		pcall(function()
			UpdateQuality()
		end)
	end
end)
pcall(function()
	UpdateQuality()
end)
local Players = game:GetService("Players")
local localPlayer2 = Players.LocalPlayer
local character = localPlayer2.Character

if not character then
	repeat
		wait()
		character = localPlayer2.Character
	until character and character:FindFirstChild("HumanoidRootPart")
end

_G.RenderDist1 = 500
character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local _ = workspace.CurrentCamera
local CollectionService = game:GetService("CollectionService")
workspace:WaitForChild("Island")
workspace:WaitForChild("Monster")
CollectionService:GetTagged("Detail")
local v4 = {}

function AddEnemieDetail(instance)
	wait()

	if v4[instance] or not instance:WaitForChild("HumanoidRootPart", 3) then
		return
	end

	v4[instance] = {
		Char = instance,
		OldParent = instance.Parent,
		Render = true
	}
end

local children = workspace.Monster.Boss:GetChildren()
workspace.Monster.Boss.ChildAdded:Connect(AddEnemieDetail)
local children2 = workspace.Monster.Mon:GetChildren()
workspace.Monster.Mon.ChildAdded:Connect(AddEnemieDetail)
local v5 = true

for _, v6 in pairs(children) do
	local v7 = v6
	spawn(function()
		AddEnemieDetail(v7)
	end)
end

for _, v6 in pairs(children2) do
	local v7 = v6
	spawn(function()
		AddEnemieDetail(v7)
	end)
end

localPlayer2.CharacterAdded:Connect(function()
	v5 = true
end)
local _ = game.Players.LocalPlayer
local _ = workspace.CurrentCamera
local monster = workspace:WaitForChild("Monster")
local allNPC = workspace:WaitForChild("AllNPC")
local v6 = {}
local v7 = {}
_G.AnimRenderDistance = 350

function RoninFX(parent, p)
	if p then
		v7[parent] = v7[parent] or {}
		v7[parent].RoninFX = v7[parent].RoninFX or {}
		local v9 = { createVector(2.62, 6.256, 0), createVector(-2.62, 6.256, 0) }

		for _, v10 in pairs(v7[parent].RoninFX) do
			v10:Destroy()
		end

		v7[parent].RoninFX = {}

		for childName, _ in pairs({
			RightHand = true,
			RightLowerArm = true,
			RightUpperArm = true,
			LeftHand = true,
			LeftLowerArm = true,
			LeftUpperArm = true
		}) do
			local child = parent:FindFirstChild(childName)

			if not child then
				continue
			end

			local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Ronin.Smoke:Clone()
			clone.Parent = child
			clone.Enabled = true
			table.insert(v7[parent].RoninFX, clone)
		end

		for _, position in pairs(v9) do
			local attachment = Instance.new("Attachment")
			attachment.Position = createVector(0, -3.311, 0)
			local attachment2 = Instance.new("Attachment")
			attachment2.Position = position
			attachment2.Parent = attachment
			local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Ronin.RedWind:Clone()
			clone.Attachment0 = attachment
			clone.Attachment1 = attachment2
			clone.Parent = attachment
			local clone2 = ReplicatedStorage.Chest.Etc.PassiveVFX.Ronin.DarkWind:Clone()
			clone2.Attachment0 = attachment
			clone2.Attachment1 = attachment2
			clone2.Parent = attachment
			attachment.Parent = humanoidRootPart
			table.insert(v7[parent].RoninFX, attachment)
		end

		local humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 then
			local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Ronin.GlowPart:Clone()
			local weld = Instance.new("Weld")
			weld.Part0 = humanoidRootPart2
			weld.Part1 = clone
			weld.Parent = clone
			clone.Parent = parent
			table.insert(v7[parent].RoninFX, clone)
		end
	else
		local v8 = v7[parent]

		if not (v8 and v8.RoninFX) then
			return
		end

		for _, emitter in pairs(v8.RoninFX) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			else
				for _, emitter2 in pairs(emitter:GetDescendants()) do
					if emitter2:IsA("ParticleEmitter") then
						emitter2.Enabled = false
					end
				end
			end

			local v9 = emitter
			task.spawn(function()
				wait(1)
				v9:Destroy()
			end)
		end

		v8.RoninFX = {}
	end
end

function BrawlerFX(parent, p)
	if p then
		v7[parent] = v7[parent] or {}
		v7[parent].BrawlerFX = v7[parent].BrawlerFX or {}

		for _, v8 in pairs(v7[parent].BrawlerFX) do
			v8:Destroy()
		end

		v7[parent].BrawlerFX = {}

		for childName, _ in pairs({
			RightHand = true,
			LeftHand = true
		}) do
			local child = parent:FindFirstChild(childName)

			if not child then
				continue
			end

			local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Brawler.Lightning1:Clone()
			clone.Parent = child
			clone.Enabled = true
			local clone2 = ReplicatedStorage.Chest.Etc.PassiveVFX.Brawler.main:Clone()
			clone2.Parent = child
			clone2.Enabled = true
			table.insert(v7[parent].BrawlerFX, clone)
			table.insert(v7[parent].BrawlerFX, clone2)
		end

		for childName, _ in pairs({
			RightLowerArm = true,
			LeftLowerArm = true
		}) do
			local child = parent:FindFirstChild(childName)

			if not child then
				continue
			end

			local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Brawler.Swirl:Clone()
			clone.Parent = child
			clone.Enabled = true
			table.insert(v7[parent].BrawlerFX, clone)
		end

		local humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 then
			local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Brawler.GlowPart:Clone()
			local weld = Instance.new("Weld")
			weld.Part0 = humanoidRootPart2
			weld.Part1 = clone
			weld.Parent = clone
			clone.Parent = parent
			table.insert(v7[parent].BrawlerFX, clone)
		end
	else
		local v8 = v7[parent]

		if not (v8 and v8.BrawlerFX) then
			return
		end

		for _, emitter in pairs(v8.BrawlerFX) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			else
				for _, emitter2 in pairs(emitter:GetDescendants()) do
					if emitter2:IsA("ParticleEmitter") then
						emitter2.Enabled = false
					end
				end
			end

			local v9 = emitter
			task.spawn(function()
				wait(1)
				v9:Destroy()
			end)
		end

		v8.BrawlerFX = {}
	end
end

function EternalFX(parent, p)
	if p then
		v7[parent] = v7[parent] or {}
		v7[parent].EternalFX = v7[parent].EternalFX or {}

		for childName, _ in pairs({
			RightHand = true,
			RightLowerArm = true,
			RightUpperArm = true,
			RightFoot = true,
			RightLowerLeg = true,
			RightUpperLth = true,
			LeftHand = true,
			LeftLowerArm = true,
			LeftUpperArm = true,
			LeftFoot = true,
			LeftLowerLeg = true,
			LeftUpperLth = true,
			Head = true
		}) do
			local child = parent:FindFirstChild(childName)

			if not child then
				continue
			end

			for _, child2 in pairs(ReplicatedStorage.Chest.Etc.PassiveVFX.Eternal.Aura:GetChildren()) do
				local clone = child2:Clone()
				clone.Parent = child
				clone.Enabled = true
				table.insert(v7[parent].EternalFX, clone)
			end
		end

		local humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 then
			local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Eternal.GlowPart:Clone()
			local weld = Instance.new("Weld")
			weld.Part0 = humanoidRootPart2
			weld.Part1 = clone
			weld.Parent = clone
			clone.Parent = parent
			table.insert(v7[parent].EternalFX, clone)
		end
	else
		local v8 = v7[parent]

		if not (v8 and v8.EternalFX) then
			return
		end

		for _, emitter in pairs(v8.EternalFX) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			else
				for _, emitter2 in pairs(emitter:GetDescendants()) do
					if emitter2:IsA("ParticleEmitter") then
						emitter2.Enabled = false
					end
				end
			end

			local v9 = emitter
			task.spawn(function()
				wait(1)
				v9:Destroy()
			end)
		end

		v8.EternalFX = {}
	end
end

function RemoveFX(items)
	for _, item in pairs(items) do
		if type(item) == "table" then
			RemoveFX(item)
		elseif typeof(item) == "Instance" then
			local v8 = item
			pcall(function()
				v8:Destroy()
			end)
		end
	end
end

function CheckAnimationThatDidntUse()
	for k in pairs(v6) do
		if k:IsDescendantOf(monster) or not k:IsDescendantOf(ReplicatedStorage.MOB) or not v6[k] or not v6[k].Connected then
			continue
		end

		v6[k]:Disconnect()
		v6[k] = nil
		local humanoid = k:FindFirstChild("Humanoid")

		if humanoid then
			_G.StopAnimationClient(humanoid, {
				Idle = true,
				WalkAnim = true
			})
		end
	end
end

local flag2 = nil

function RenderNPCQuest()
	local parts = {}

	for _, part in pairs(allNPC:GetChildren()) do
		if flag2 or not part:IsA("BasePart") then
			continue
		end

		if (workspace.CurrentCamera.CFrame.Position - part.Position).Magnitude <= 500 then
			if not part:FindFirstChildOfClass("Model") then
				table.insert(parts, part)
			end
		else
			local model = part:FindFirstChildOfClass("Model")

			if model and model.Name ~= "ARandomFruit" then
				if model:FindFirstChild("FakeHumanoid") then
					for _, v8 in pairs(model.FAKEHumanoid:GetPlayingAnimationTracks()) do
						v8:Stop()
					end
				end

				model:Destroy()
			end
		end
	end

	for k, parent in pairs(parts) do
		local child = ReplicatedStorage.NPC:FindFirstChild(parent.Name)

		if parent.Name == "BuyShips" or parent.Name == "SetSpawn" or parent.Name == "SwordShop" then
			for _, child2 in pairs(ReplicatedStorage.NPC:GetChildren()) do
				if not (child2.Name == parent.Name and child2:FindFirstChild("HumanoidRootPart") and (child2.HumanoidRootPart.Position - parent.Position).Magnitude < 5) then
					continue
				end

				child = child2
			end
		end

		if child then
			local clone = child:Clone()
			clone:SetPrimaryPartCFrame(parent.CFrame)

			for _, part in pairs(clone:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				if part.Name == "HumanoidRootPart" then
					part.Anchored = true
				else
					part.Anchored = nil
				end

				part.CollisionGroup = "Mob"
			end

			clone.Parent = parent

			if clone:FindFirstChild("Animation") then
				_G.PU.PlayOneShotAnim({
					Animator = clone.FAKEHumanoid,
					Animation = clone.Animation
				})
			end
		end

		if not (#parts > 7) then
			continue
		end

		flag2 = true

		if k % 7 == 1 then
			task.wait(0.05)
		end
	end

	if flag2 then
		flag2 = nil
	end
end

function UpdateBin()
	for k, _ in pairs(v7) do
		if k.Parent or not v7[k] then
			continue
		end

		RemoveFX(v7[k])
		v7[k] = nil
	end

	for k, _ in pairs(v6) do
		if k.Parent or not v6[k] then
			continue
		end

		if v6[k].Connected then
			v6[k]:Disconnect()
		end

		v6[k] = nil
	end
end

local v8 = {}

function FruitAnim(instance)
	local animationController = instance:FindFirstChild("AnimationController") or instance:FindFirstChild("FruitModel") and instance.FruitModel:FindFirstChild("AnimationController")

	if not animationController then
		return
	end

	local animation = instance:FindFirstChild("Animation")

	if not animation then
		return
	end

	local handle = instance:FindFirstChild("Handle")

	if not handle then
		return
	end

	if (handle.Position - currentCamera.CFrame.Position).Magnitude > 200 then
		if not v8[instance] then
			return
		end

		v8[instance]:Stop()
		v8[instance] = nil
	else
		if v8[instance] then
			return
		end

		local track = animationController:LoadAnimation(animation)
		track:Play()
		v8[instance] = track
	end
end

function RenderFruitsAnimation()
	for _, child in pairs(workspace:WaitForChild("AllDroppedFruit"):GetChildren()) do
		if not (child:FindFirstChild("AnimationController") or child:FindFirstChild("FruitModel") and child.FruitModel:FindFirstChild("AnimationController")) then
			continue
		end

		FruitAnim(child)
	end

	for _, child in pairs(workspace.AllspawnDF:GetChildren()) do
		if not (child:FindFirstChild("AnimationController") or child:FindFirstChild("FruitModel") and child.FruitModel:FindFirstChild("AnimationController")) then
			continue
		end

		FruitAnim(child)
	end

	for k, v9 in pairs(v8) do
		if k:IsDescendantOf(workspace.AllspawnDF) or k:IsDescendantOf(workspace:WaitForChild("AllDroppedFruit")) then
			continue
		end

		v9:Stop()
		v8[k] = nil
	end
end

local _ = {
	WeaponRenderDistance = 800,
	ModelRenderDistance = 1500,
	SeaMonsterRenderDistance = 3000
}
local v9 = {}
local v10 = {
	Allosaurus = true,
	Brachiosaurus = true,
	Spinosaurus = true,
	MammothModel = true,
	Dragon = true,
	Giraffe = true,
	Wolf = true,
	Leopard = true,
	DemonForm = true,
	Phoenix_Model = true,
	Snow_Wing = true,
	ToyTrex = true,
	Pteranodon_KL = true,
	Tree_KL = true
}

function AddToRenderPerformance(folder)
	if v9[folder] then
		return
	end

	v9[folder] = {}

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		v9[folder][part] = part.Transparency
		part.Transparency = 1
	end
end

function RemoveToRenderPerformance(p)
	if not v9[p] then
		return
	end

	for part, transparency in pairs(v9[p]) do
		if part:IsA("BasePart") then
			part.Transparency = transparency
		end
	end

	table.clear(v9[p])
	v9[p] = nil
end

function RenderPerformance()
	for k, _ in pairs(v9) do
		if k.Parent or not v9[k] then
			continue
		end

		RemoveToRenderPerformance(k)
	end

	for _, model in pairs(workspace.CharacterWorkshop:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		if (model:GetBoundingBox().Position - currentCamera.CFrame.Position).Magnitude > 800 then
			AddToRenderPerformance(model)
		else
			RemoveToRenderPerformance(model)
		end
	end

	for _, model in pairs(workspace.PlayerCharacters:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		for childName, _ in pairs(v10) do
			local model2 = model:FindFirstChild(childName)

			if not (model2 and (not model2 or model2:IsA("Model"))) then
				continue
			end

			if (model2:GetBoundingBox().Position - currentCamera.CFrame.Position).Magnitude > 1500 then
				AddToRenderPerformance(model2)
			else
				RemoveToRenderPerformance(model2)
			end
		end
	end

	for _, model in pairs(workspace.SeaMonster:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		if (model:GetBoundingBox().Position - currentCamera.CFrame.Position).Magnitude > 3000 then
			AddToRenderPerformance(model)
		else
			RemoveToRenderPerformance(model)
		end
	end
end

local v11 = {}

function RenderFlagAnimation()
	for _, v12 in pairs(CollectionService:GetTagged("FlagCapture")) do
		if ((v12.PrimaryPart and v12:GetPivot() or v12:WorldPivot()).Position - currentCamera.CFrame.Position).Magnitude < 500 then
			if not v11[v12] then
				v11[v12] = v12.AnimationController:LoadAnimation(v12.Animation)
				v11[v12]:Play()
			end
		elseif v11[v12] then
			v11[v12]:Stop()
			v11[v12] = nil
		end
	end
end

task.spawn(function()
	while true do
		task.wait(1)
		RenderNPCQuest()
		local _, _ = pcall(function()
			RenderFlagAnimation()
		end)
	end
end)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {
	workspace.Effects,
	workspace.CharacterWorkshop,
	workspace.PlayerCharacters,
	character
}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

function _G.MouseHitMobileUpdate()
	local currentCamera2 = workspace.CurrentCamera

	if _G.ShiftLockMobile then
		local position = currentCamera2.CFrame.Position
		local v12 = currentCamera2.CFrame.LookVector * 10000
		local raycastResult = workspace:Raycast(position, v12, raycastParams)
		local position2 = position + v12

		if raycastResult then
			position2 = raycastResult.Position
		end

		local cframe = CFrame.new(position2)
		_G.MouseHitMobile = cframe
	elseif not (_G.ShiftLockMobile or mouse.X / currentCamera2.ViewportSize.X < 0.4 and mouse.Y / currentCamera2.ViewportSize.Y > 0.3) then
		local mouseLocation = UserInputService:GetMouseLocation()
		local viewportPointToRay = currentCamera2:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
		local v12 = viewportPointToRay.Direction * 10000
		local raycastResult = workspace:Raycast(viewportPointToRay.Origin, v12, raycastParams)
		local position = viewportPointToRay.Origin + v12

		if raycastResult then
			position = raycastResult.Position
		end

		local cframe = CFrame.new(position)
		_G.MouseHitMobile = cframe
	end
end