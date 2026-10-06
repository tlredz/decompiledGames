local localPlayer = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local AntiMobSkill = require(ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules").AntiMobSkill)
local AntiMobShowRace = require(ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules").AntiMobShowRace)
local EntityAtlas = require(ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Assets"):WaitForChild("Modules").EntityAtlas)
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules"):WaitForChild("PeoUtils")
local _G2 = _G
_G2.PU = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local MarketplaceService = game:GetService("MarketplaceService")
shared.FruitPrices = {}
shared.ProductPrices = {}
task.spawn(function()
	local DFGiftRobux = require(ReplicatedStorage.Chest.Modules.DFGiftRobux)

	for k, v in pairs(DFGiftRobux) do
		local v2 = v
		local success, result = pcall(function()
			return MarketplaceService:GetProductInfo(v2, Enum.InfoType.Product)
		end)

		if success then
			shared.FruitPrices[k] = {
				RobuxPrice = result.PriceInRobux
			}
		end
	end

	shared.FruitsLoaded = true
end)
task.spawn(function()
	local DeveloperProductIds = require(ReplicatedStorage.Chest.Modules.DeveloperProductIds)

	for k, developerProductId in pairs(DeveloperProductIds) do
		local v = developerProductId
		local success, result = pcall(function()
			return MarketplaceService:GetProductInfo(v, Enum.InfoType.Product)
		end)

		if success then
			shared.ProductPrices[k] = {
				RobuxPrice = result.PriceInRobux
			}
		else
			warn(result)
		end
	end

	shared.ProductLoaded = true
end)

if UserInputService.TouchEnabled then
	_G.IsMobile = true
end

function ProcessName(value)
	local v = #value / 2

	if #value % 2 == 0 then
		local v2 = value:sub(1, v)

		if v2 == value:sub(v + 1) then
			return v2
		end
	end

	return (value:gsub("(%l)(%u)", "%1 %2"))
end

_G.ProcessName = ProcessName
_G.Layouts = {
	Common = 5,
	Uncommon = 4,
	Rare = 3,
	Epic = 2,
	Legendary = 1,
	Limited = 0,
	Mythical = -1,
	Divine = -2,
	Collectible = -3,
	Exotic = -4,
	Exclusive = -5
}
_G.UIVisible = true

function CheckInCombat()
	if not (tick() - _G.LastUpdate <= _G.DangerTimeClient) then
		return false
	end

	print("iNcOMBAT")
	local message = localPlayer.PlayerStats.Language.Value == "TH" and "ข้อผิดพลาด: อยู่ในการต่อสู้!!" or "Error: In Combat!!"
	ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
		Name = "In Combat",
		Overlay = true,
		Message = message,
		Color = Color3.fromRGB(255, 0, 0)
	})
	return true
end

_G.CheckInCombat = CheckInCombat

function VisibleGui(p)
	local visible = localPlayer.PlayerGui.Backpack.InventoryFrame.Visible

	if p and not _G.UIVisible then
		return
	end

	task.spawn(function()
		local v = _G.CheckSettingClient(localPlayer, "Setting_RetroUI")

		if localPlayer.PlayerGui:FindFirstChild("SkillCooldown") then
			localPlayer.PlayerGui.SkillCooldown.Enabled = p
		end

		if localPlayer.PlayerGui:FindFirstChild("Backpack") then
			localPlayer.PlayerGui.Backpack.Enabled = p
		end

		local mainGui = localPlayer.PlayerGui:FindFirstChild("MainGui")

		if mainGui then
			for _, guiObject in pairs(mainGui:GetChildren()) do
				if not (guiObject:IsA("Frame") or guiObject:IsA("ImageLabel")) then
					continue
				end

				if guiObject.Name == "StarterFrame" then
					local bossesHealthBar = guiObject:FindFirstChild("BossesHealthBar")

					if bossesHealthBar then
						bossesHealthBar.Visible = p
					end
				else
					guiObject.Visible = p
				end

				if not p then
					continue
				end

				if v and not visible then
					if guiObject.Name == "BaseFrame" then
						guiObject.Visible = nil
					elseif guiObject.Name == "BaseFrameOG" then
						guiObject.Visible = p
					end
				elseif not (v or visible) then
					if guiObject.Name == "BaseFrame" then
						guiObject.Visible = p
					elseif guiObject.Name == "BaseFrameOG" then
						guiObject.Visible = nil
					end
				end

				if visible and (guiObject.Name == "BaseFrame" or guiObject.Name == "BaseFrameOG") then
					guiObject.Visible = nil
				end
			end
		end
	end)
end

_G.VisibleGui = VisibleGui

function _G.CheckCrewClient(player, player2)
	if player:IsA("Player") and player2:IsA("Player") then
		if player2 and player2:FindFirstChild("PlayerStats") and player2.PlayerStats:FindFirstChild("Crew") and player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("Crew") and player2.PlayerStats.Crew.Value == player.PlayerStats.Crew.Value and player2.PlayerStats.Crew.Value ~= "" then
			return true
		end

		return false
	end
end

_G.RaceButtonImages = {
	Demon = "rbxassetid://70986398339264",
	Fish = "rbxassetid://76847002837730",
	Human = "rbxassetid://131562380057662",
	["Sea Beast"] = "rbxassetid://117582670764674",
	Sky = "rbxassetid://132683936061250",
	Mink = "rbxassetid://84995508065012"
}

function _G.CheckPvPOffClient(player, player2)
	if player:IsA("Player") and player2:IsA("Player") then
		if player2 and player:FindFirstChild("PlayerStats") and player2:FindFirstChild("PlayerStats") and not (player2.PlayerStats.PVP.Value and player.PlayerStats.PVP.Value) then
			return true
		end

		return false
	end
end

function _G.FindNearestTarget(instance)
	local player = instance.Player
	local rootPart = instance.RootPart
	local humanoid = instance.Humanoid
	local distance = instance.Distance or 75
	local v = nil

	if not (player and rootPart and humanoid) then
		return
	end

	for _, v2 in pairs(EntityAtlas.GetEntities()) do
		local humanoid2 = v2:FindFirstChild("Humanoid")
		local humanoidRootPart = v2:FindFirstChild("HumanoidRootPart")

		if not humanoid2 or not humanoidRootPart or humanoid.Health <= 0 or v2.Name == player.Name then
			continue
		end

		if _G.IsInSafezoneClient(humanoidRootPart) or _G.IsInSuperSafezoneClient(humanoidRootPart) or _G.IsInSafezoneClient(rootPart) or _G.IsInSuperSafezoneClient(rootPart) or _G.CheckPvPOffClient(
			player,
			v2
		) or _G.CheckAllyClient(player, v2) or _G.CheckCrewClient(player, v2) or distance < (humanoidRootPart.Position - rootPart.Position).Magnitude then
			continue
		end

		distance = (humanoidRootPart.Position - rootPart.Position).Magnitude
		v = v2
	end

	return v
end

function _G.FindNearestTargetMouse(instance)
	local player = instance.Player
	local rootPart = instance.RootPart
	local humanoid = instance.Humanoid
	local cFMouse = instance.CFMouse
	local distance = instance.Distance or 50
	local v = nil

	if not (player and rootPart and humanoid) then
		return
	end

	for _, v2 in pairs(EntityAtlas.GetEntities()) do
		local humanoid2 = v2:FindFirstChild("Humanoid")
		local humanoidRootPart = v2:FindFirstChild("HumanoidRootPart")

		if not humanoid2 or not humanoidRootPart or humanoid.Health <= 0 or v2.Name == player.Name then
			continue
		end

		if _G.IsInSafezoneClient(humanoidRootPart) or _G.IsInSuperSafezoneClient(humanoidRootPart) or _G.IsInSafezoneClient(rootPart) or _G.IsInSuperSafezoneClient(rootPart) or _G.CheckPvPOffClient(
			player,
			v2
		) or _G.CheckAllyClient(player, v2) or _G.CheckCrewClient(player, v2) or distance < (humanoidRootPart.Position - cFMouse.Position).Magnitude then
			continue
		end

		distance = (humanoidRootPart.Position - cFMouse.Position).Magnitude
		v = v2
	end

	return v
end

function _G.TransformableClient(instance)
	if instance:GetAttribute("SkyAwakenV3") or instance:GetAttribute("MinkAwakenV3") or instance:GetAttribute("FishAwakenV3") or instance:GetAttribute("SeaBeastAwakenV3") or instance:GetAttribute("HumanAwakenV3") or instance:GetAttribute("DemonAwakenV3") then
		local message = localPlayer.PlayerStats.Language.Value == "TH" and "ต้องรอให้ <font color='#ffff7f'>Race V3</font> หมดก่อน" or "You have to wait until <font color='#ffff7f'>Race V3</font> ends"
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
			Name = "Race V3",
			Overlay = true,
			Message = message,
			Color = Color3.fromRGB(255, 255, 255)
		})
		return false
	else
		return true
	end
end

function _G:ParticleSize(p)
	local numberSequenceKeypoints = {}

	for k, keypoint in pairs(self.Size.Keypoints) do
		numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
	end

	self.Size = NumberSequence.new(numberSequenceKeypoints)
	self.Speed = NumberRange.new(self.Speed.Min * p, self.Speed.Max * p)
	task.delay(5, function()
		table.clear(numberSequenceKeypoints)
	end)
end

function _G.AntiMobSkill(p)
	local character = localPlayer.Character

	if not character then
		return true
	end

	for childName, _ in pairs(AntiMobSkill) do
		if childName ~= p and character:FindFirstChild(childName) then
			return true, childName
		end
	end

	return false
end

function _G.AntiMobShowRace(character, p)
	if character:IsA("Player") then
		character = character.Character
	end

	if not character then
		return true
	end

	for childName, _ in pairs(AntiMobShowRace) do
		if childName ~= p and character:FindFirstChild(childName) then
			return true, childName
		end
	end

	return false
end

function _G.AntiMobSkillTarget(character, p)
	if character:IsA("Player") then
		character = character.Character
	end

	for childName, _ in pairs(AntiMobSkill) do
		if childName ~= p and character:FindFirstChild(childName) then
			return true, childName
		end
	end

	return false
end

function _G.AntiMobObservation(p)
	for _, v in pairs({
		"SeaKing",
		"HydraSeaKing",
		"SeaDragon",
		"FuryTentacle",
		"Skull King"
	}) do
		if p.Name == v then
			return true
		end
	end

	return false
end

function _G.AntiMobDiedTween(p)
	for _, v in pairs({
		"SeaKing",
		"HydraSeaKing",
		"Ghost Ship",
		"SeaDragon",
		"FuryTentacle",
		"ThirdSeaDragon",
		"ThirdSeaEldritch Crab"
	}) do
		if p.Name == v then
			return true
		end
	end

	return false
end

function _G.AntiMob()
	if not localPlayer.Character then
		return true
	end

	for _, childName in pairs({
		"DemonForm",
		"Dragon",
		"Telekinesis_Model",
		"Gas_Model",
		"Phoenix_Model",
		"Wings_Model",
		"MammothModel",
		"Snow_Wing"
	}) do
		if localPlayer.Character:FindFirstChild(childName) and (childName ~= "Phoenix_Model" or not _G.CheckAwakeClient(
			localPlayer,
			"PhoenixV"
		)) then
			return true
		end
	end

	return false
end

function _G.CheckIsGamePad()
	return UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1
end

function _G.StopAnimationLoopingClient(object)
	local v = {
		"Idle",
		"Walk",
		"Walking",
		"Run",
		"ZLoop",
		"Z1",
		"DragonIdle",
		"DragonFly",
		"Fly"
	}

	for _, v2 in pairs(object:GetPlayingAnimationTracks()) do
		for _, v3 in pairs(v) do
			if v2.Name == v3 or v3.Looped then
				v2:Stop()
			end
		end
	end
end

function UpdateRaceIcon(data)
	local localPlayer2 = data.LocalPlayer
	local raceTbl = data.RaceTbl
	local raceButtonImages = data.RaceButtonImages
	local raceV3Button = data.RaceV3Button
	local statusFrame = data.StatusFrame
	local race = HttpService:JSONDecode(raceTbl.Value).Race

	if race and raceButtonImages[race] then
		raceV3Button.Frame.ImageLabel.Image = raceButtonImages[race]
	end

	if _G.CheckAwakeClient(localPlayer2, race .. "V3") then
		statusFrame.RaceV3.Visible = true
	else
		statusFrame.RaceV3.Visible = nil
	end
end

_G.UpdateRaceIcon = UpdateRaceIcon
local clone = nil

function ShineGui(instance)
	local parent = instance.Parent
	local zIndex = instance.ZIndex or 2
	local color = instance.Color or Color3.fromRGB(255, 255, 255)
	local circle = instance.Circle or nil
	local size = instance.Size or UDim2.fromScale(1, 1)
	local antiRatio = instance.AntiRatio or nil
	local cornerRadius = instance.CornerRadius or nil

	if clone and clone.Parent then
		clone:Destroy()
		clone = nil
	end

	clone = ReplicatedStorage.Chest.Gui.ShineFrame:Clone()
	_G.PU:Dust(clone, 1)
	clone.ZIndex = zIndex
	clone.Size = size

	if circle then
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(1, 0)

		if cornerRadius then
			uICorner.CornerRadius = cornerRadius
		end

		uICorner.Parent = clone
	end

	local shine = clone.Shine
	shine.ImageColor3 = color
	shine.Position = UDim2.fromScale(-0.35, 0.5)

	if antiRatio then
		shine.UIAspectRatioConstraint:Destroy()
	end

	clone.Parent = parent
	TweenService:Create(shine, TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(1.5, 0.5)
	}):Play()
end

_G.ShineGui = ShineGui

function IsInSuperSafezoneClient(p)
	for _, child in pairs(workspace.SuperSafeZone:GetChildren()) do
		local v = child.CFrame:Inverse() * p.Position
		local v2 = math.abs(child.Size.X / 2)
		local v3 = math.abs(child.Size.Z / 2)

		if math.abs(v.X) <= v2 and math.abs(v.Z) <= v3 then
			return true
		end
	end

	return false
end

function IsInSafezoneClient(instance)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance.Parent)

	if playerFromCharacter then
		local danger = playerFromCharacter:FindFirstChild("Danger")

		if danger and time() - danger.Time.Value < _G.DangerTimeClient then
			return false
		end
	end

	for _, child in pairs(workspace.Safezone:GetChildren()) do
		local v = child.CFrame:Inverse() * instance.Position
		local v2 = math.abs(child.Size.X / 2)
		local v3 = math.abs(child.Size.Z / 2)

		if math.abs(v.X) <= v2 and math.abs(v.Z) <= v3 then
			return true
		end
	end

	return false
end

_G.IsInSafezoneClient = IsInSafezoneClient
_G.IsInSuperSafezoneClient = IsInSuperSafezoneClient

function VisiblePartFunc(player)
	local InvisiblePart = require(ReplicatedStorage.Chest.Modules.InvisiblePart)
	local characterWorkshop = workspace.CharacterWorkshop
	local part = player.Part
	local character = player.Character
	local haki = player.Haki
	local player2 = player.Player

	if part:IsA("BasePart") and part.Transparency ~= 0 and not InvisiblePart[part.Name] then
		part.Transparency = 0

		if part.Parent and part.Parent.Name == "Fake Sword" and characterWorkshop:FindFirstChild(player2.Name .. "Real Sword") then
			part.Transparency = 1
		end

		local phoenix_Model = character:FindFirstChild("Phoenix_Model")

		if phoenix_Model and part and part.Parent and part.Parent ~= phoenix_Model then
			part.Transparency = 1
		end

		if part.Parent and part.Parent:FindFirstChild("IsAccessory") and part.Name ~= "Bubble" and character:FindFirstChild("Services") and character.Services:FindFirstChild("HideAcc") and character.Services.HideAcc.Value then
			part.Transparency = 1
		end

		if part:GetAttribute("IsAGlass") then
			part:SetAttribute("IsAGlass", nil)
			part.Material = Enum.Material.Glass
		end
	elseif part:IsA("Highlight") then
		part.OutlineTransparency = 0
	elseif part.Name == "Bullitus" then
		part.Bubble.Transparency = 0
	elseif part:IsA("Decal") then
		part.Transparency = 0
	elseif haki and haki.Value == 1 and part:IsA("Beam") and not part.Enabled then
		part.Enabled = true
	elseif part:IsA("ParticleEmitter") and not (part.Enabled or part:GetAttribute("AE")) then
		part.Enabled = true

		if part.Parent and part.Parent.Parent and part.Parent.Parent.Name == "Fake Sword" and characterWorkshop:FindFirstChild(player2.Name .. "Real Sword") then
			part.Enabled = false
		end

		if part:GetAttribute("ArmamentParticle") and haki and haki.Value == 0 then
			part.Enabled = false
		end
	elseif part:IsA("Trail") and not part.Enabled then
		part.Enabled = true
	end
end

function InvisiblePartFunc(player)
	local part = player.Part
	local _ = player.Character

	if part:IsA("BasePart") and part.Transparency ~= 1 then
		part.Transparency = 1

		if part.Material == Enum.Material.Glass then
			part:SetAttribute("IsAGlass", true)
			part.Material = Enum.Material.SmoothPlastic
		end
	elseif part:IsA("Decal") then
		part.Transparency = 1
	elseif part:IsA("Highlight") then
		part.OutlineTransparency = 1
	elseif part:IsA("Beam") and part.Enabled then
		part.Enabled = false
	elseif part:IsA("ParticleEmitter") and part.Enabled then
		part.Enabled = false
	elseif part:IsA("Trail") and part.Enabled then
		part.Enabled = false
	end
end

local v = {
	FirstSeaDungeon = true,
	SecondSeaDungeon = true,
	ThirdSeaDungeon = true,
	FirstSeaDungeonEasy = true,
	SecondSeaDungeonEasy = true,
	ThirdSeaDungeonEasy = true,
	FirstSeaDungeonNormal = true,
	SecondSeaDungeonNormal = true,
	ThirdSeaDungeonNormal = true,
	FirstSeaDungeonHard = true,
	SecondSeaDungeonHardl = true,
	ThirdSeaDungeonHard = true
}

function _G.GetStatisticClient(instance, p, p2)
	local playerStats = instance:FindFirstChild("PlayerStats")

	if not (playerStats and instance:FindFirstChild("DataLoaded")) then
		return
	end

	local jSONDecode = HttpService:JSONDecode(playerStats.Statistics.Value)

	if v[p] and p2 then
		return (jSONDecode[p .. "s"] or {})[p2] or 0
	end

	return jSONDecode[p] or 0
end

function _G.GetEtcDataClient(instance, p)
	local playerStats = instance:FindFirstChild("PlayerStats")

	if not playerStats then
		return
	end

	return HttpService:JSONDecode(playerStats.EtcData.Value)[p], true
end

function _G.InvisibleClient(_, folder)
	local v2 = {}

	for _, descendant in pairs(folder:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("Highlight") or descendant:IsA("Decal") or descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail")) then
			continue
		end

		local v3 = {
			Part = descendant,
			Character = folder
		}
		InvisiblePartFunc(v3)
		table.insert(v2, v3)
	end

	task.delay(1, function()
		for _, list in pairs(v2) do
			table.clear(list)
		end

		table.clear(v2)
		v2 = nil
	end)
end

function _G.UnInvisibleClient(player, folder)
	local haki = folder:FindFirstChild("Services") and folder.Services:FindFirstChild("Haki")
	local v2 = {}

	for _, descendant in pairs(folder:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("Highlight") or descendant:IsA("Decal") or descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail")) then
			continue
		end

		if descendant:GetAttribute("NA") then
			continue
		end

		local v3 = {
			Part = descendant,
			Character = folder,
			Haki = haki,
			Player = player
		}
		VisiblePartFunc(v3)
		table.insert(v2, v3)
	end

	task.delay(1, function()
		for _, list in pairs(v2) do
			table.clear(list)
		end

		table.clear(v2)
		v2 = nil
	end)
end

function _G.UpdateCameraMaxZoom(p)
	local step = p.Step or 200
	local type2 = p.Type

	if type2 and _G.IsXbox then
		coroutine.wrap(function()
			if type2 then
				if type2 == "Xbox" then
					localPlayer.CameraMaxZoomDistance = step
					localPlayer.CameraMinZoomDistance = step
				elseif type2 == "Normal" then
					step = step
					local cameraMinZoomDistance = localPlayer.CameraMinZoomDistance

					if step < cameraMinZoomDistance then
						localPlayer.CameraMinZoomDistance = step
						localPlayer.CameraMaxZoomDistance = step
					else
						localPlayer.CameraMaxZoomDistance = step
						localPlayer.CameraMinZoomDistance = step
					end
				else
					localPlayer.CameraMinZoomDistance = step
					localPlayer.CameraMinZoomDistance = 0.5
				end
			end
		end)()
	end
end

local HttpService2 = game:GetService("HttpService")

function _G.CheckDailyQuestClient(instance, p)
	if not instance:FindFirstChild("DataLoaded") then
		return
	end

	local dailyQuest = instance.PlayerStats:FindFirstChild("DailyQuest")

	if not dailyQuest then
		return
	end

	if HttpService2:JSONDecode(dailyQuest.Value)[p] then
		return
	else
		return true
	end
end

function _G.CalculatedDate(p)
	local jSONDecode = HttpService2:JSONDecode(localPlayer.PlayerStats.DailyQuest.Value)

	for k, v2 in pairs(jSONDecode) do
		if k ~= p then
			continue
		end

		local v3 = math.floor((v2 + 72000 - os.time()) / 3600)
		local v4 = math.floor((v2 + 72000 - os.time()) / 60 % 60)
		local v5 = math.floor((v2 + 72000 - os.time()) % 60)
		return string.format("%02d:%02d:%02d", math.max(v3, 0), math.max(v4, 0), (math.max(v5, 0)))
	end

	return "00:00:00"
end

local v2 = {
	SW = "Swords",
	DF = "Fruits",
	FS = "Styles"
}

function _G.GetCooldownClient(value)
	local v3 = string.sub(value, 1, 2)
	local v4 = string.sub(value, 3, 3)

	if not localPlayer:FindFirstChild("PlayerStats") then
		return 7
	end

	local value2 = nil

	if v3 == "SW" then
		value2 = localPlayer.PlayerStats.SwordName.Value
	elseif v3 == "DF" then
		value2 = localPlayer.PlayerStats.DFName.Value
	elseif v3 == "FS" then
		value2 = localPlayer.PlayerStats.FightingStyle.Value
	end

	if not value2 then
		return 7
	end

	local v5 = v2[v3]

	if not v5 then
		return 7
	end

	local child = game.ReplicatedStorage.Chest.Modules.SkillData[v5]:FindFirstChild(value2 .. "_Data")

	if not child then
		return 7
	end

	local module = require(child)
	local v6 = module[v4] or 7
	local v7 = string.gsub(value2, "(%a+)%1", "%1")

	if _G.CheckAwakeClient(localPlayer, v7 .. v4) then
		v6 = module[v4 .. "Awake"] or module[v4] or 7
	end

	local character = localPlayer.Character

	if character then
		local characterPassives = character:FindFirstChild("CharacterPassives")

		if characterPassives then
			local reduceCooldown = characterPassives:FindFirstChild("ReduceCooldown")
			local sorrowspell = characterPassives:FindFirstChild("Sorrowspell")

			if reduceCooldown and reduceCooldown.Value > 0 then
				v6 -= v6 * reduceCooldown.Value / 100
			end

			if sorrowspell then
				v6 += v6 * 10 / 100
			end
		end
	end

	if character:GetAttribute("HumanAwakenV3") then
		v6 /= 2
	end

	return (math.max(v6, 0.5))
end

local flag = nil
_G.ShipMaxHealth = 0
_G.ShipMaxSpeed = 0
_G.ShipMaxSteering = 0

function CallShipCache()
	if flag then
		return
	end

	local ShipList = require(ReplicatedStorage.Chest.Modules.ShipList)

	for _, v3 in pairs(ShipList) do
		if type(v3) ~= "table" then
			continue
		end

		if v3.Health and v3.Health > _G.ShipMaxHealth then
			_G.ShipMaxHealth = v3.Health
		end

		if v3.Speed and v3.Speed > _G.ShipMaxSpeed then
			_G.ShipMaxSpeed = v3.Speed
		end

		if v3.Steering and v3.Steering > _G.ShipMaxSteering then
			_G.ShipMaxSteering = v3.Steering
		end
	end

	flag = true
end

_G.CallShipCache = CallShipCache