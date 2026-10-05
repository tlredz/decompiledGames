local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local HeadHoncho = require(script:WaitForChild("HeadHoncho"))
local teammateLabel = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("TeammateLabel")
local defaultDueler = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("DefaultDueler")
local IS_MATCHMAKING_SERVER = CONSTANTS.IS_MATCHMAKING_SERVER
local object = setmetatable({}, ReplicatedClass)
object.__index = object

function object.new(p, clientFighter, clientDuel)
	local object2 = setmetatable(ReplicatedClass.new(p), object)
	object2.Died = Signal.new()
	object2.EntityAdded = Signal.new()
	object2.HealthChanged = Signal.new()
	object2.Eliminated = Signal.new()
	object2.ItemAdded = Signal.new()
	object2.ItemRemoved = Signal.new()
	object2.Player = p.Player or clientFighter and clientFighter.Player
	object2.ClientFighter = clientFighter
	object2.ClientDuel = clientDuel
	object2.IsLocalPlayer = object2.ClientFighter.IsLocalPlayer
	object2.HeadHoncho = HeadHoncho.new(object2)
	object2._destroyed = false
	object2._connections = {}
	object2._is_ally = false
	object2._ally_highlight = nil
	object2._ally_label = nil
	object2._preloaded_character_model = nil
	object2._is_preloading_character_model = false
	object2._recorded_viewmodel_details = {}
	object2._viewmodel_detail_check = {}
	object2:_Init()
	return object2
end

function object:IsAlive()
	return self.ClientFighter and self.ClientFighter:IsAlive()
end

function object:IsRendered()
	return self.ClientDuel:IsRendered()
end

function object.CanShowRankToLocalPlayer(object2)
	return not IS_MATCHMAKING_SERVER or object2.IsLocalPlayer or not object2.ClientDuel.LocalDueler or object2.ClientDuel.LocalDueler:Get("TeamID") and object2.ClientDuel.LocalDueler:Get("TeamID") == object2:Get("TeamID")
end

function object:GetHealth()
	return self.ClientFighter and self.ClientFighter:GetHealth() or 0
end

function object:GetMaxHealth()
	return self.ClientFighter and self.ClientFighter:GetMaxHealth() or 100
end

function object:GetCharacterModel()
	return (self._preloaded_character_model or defaultDueler):Clone()
end

function object:GetCharacterModelForCutscene()
	local clone = (self._preloaded_character_model or defaultDueler):Clone()

	for _, part in pairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end

	if clone:FindFirstChild("HumanoidRootPart") then
		clone.HumanoidRootPart.Anchored = true
	end

	return clone
end

function object:GetRandomPlayedViewModelDetails(p2)
	table.sort(self._recorded_viewmodel_details, function(a, b)
		return Utility:StringLessThan(a.ViewModelName, b.ViewModelName)
	end)
	return #self._recorded_viewmodel_details > 0 and self._recorded_viewmodel_details[(p2 or Random.new()):NextInteger(
		1,
		#self._recorded_viewmodel_details
	)]
end

function object.GetStaggeredSpawnsTurn(object2)
	return table.find(
		not object2.ClientDuel:Get("StaggeredSpawnsOrder") and {} or object2.ClientDuel:Get("StaggeredSpawnsOrder")[object2:Get("TeamID")] or {},
		object2.Player.UserId
	)
end

function object:SetAlly(is_ally)
	self._is_ally = is_ally
	self:_UpdateAllyVisuals()
end

function object:ReplicateFromServer(p, ...)
	if p == "EliminationFeed" then
		if not self:IsRendered() then
			return
		end

		self.ClientDuel.DuelInterface.EliminationFeed:Play(self.Player, ...)
	else
		if p ~= "SummaryDetails" then
			ReplicatedClass.ReplicateFromServer(self, p, ...)
			return
		end

		if not self.IsLocalPlayer then
			return
		end

		self.ClientDuel.DuelInterface.FinalResults.Summary:SetDetails(...)
	end
end

function object:Destroy()
	self._destroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	if self._ally_highlight then
		self._ally_highlight:Destroy()
	end

	if self._ally_label then
		self._ally_label:Destroy()
	end

	self.HeadHoncho:Destroy()
	self.Died:Destroy()
	self.EntityAdded:Destroy()
	self.HealthChanged:Destroy()
	self.Eliminated:Destroy()
	self.ItemAdded:Destroy()
	self.ItemRemoved:Destroy()

	if self._preloaded_character_model then
		self._preloaded_character_model:Destroy()
		self._preloaded_character_model = nil
	end

	if self.ClientFighter then
		self.ClientFighter:ClearInterface()

		if self.ClientFighter.Entity then
			self.ClientFighter.Entity:SetTranslucent(false)
		end
	end

	ReplicatedClass.Destroy(self)
end

function object:_UpdateTranslucence()
	if self.IsLocalPlayer or not (self.ClientFighter and self.ClientFighter.Entity and self.ClientDuel:Get("IsSpectating")) then
		return
	end

	self.ClientFighter.Entity:SetTranslucent(self.ClientDuel:Get("Status") == "RoundStarting")
end

function object:_RecordEquippedViewModelDetails()
	if not self.ClientFighter or not self.ClientFighter.EquippedItem or self._viewmodel_detail_check[self.ClientFighter.EquippedItem:Get("ObjectID")] then
		return
	end

	self._viewmodel_detail_check[self.ClientFighter.EquippedItem:Get("ObjectID")] = true
	local viewModelDetails = self.ClientFighter.EquippedItem:GetViewModelDetails()

	if viewModelDetails and not ItemLibrary.THIRD_PERSON_VIEWMODEL_BLACKLIST[viewModelDetails.ViewModelName] then
		table.insert(self._recorded_viewmodel_details, viewModelDetails)
	end
end

function object:_PreloadCharacterModel()
	if self._is_preloading_character_model or not self.ClientDuel:Get("IsSpectating") then
		return
	end

	self._is_preloading_character_model = true

	for _ = 1, 3 do
		wait(1)

		if self._destroyed then
			break
		end

		local success, humanoidDescriptionFromUserIdAsync = pcall(
			Players.GetHumanoidDescriptionFromUserIdAsync,
			Players,
			self.Player.UserId
		)

		if success then
			if self._destroyed then
				break
			end

			humanoidDescriptionFromUserIdAsync.Torso = 15365012259
			humanoidDescriptionFromUserIdAsync.LeftArm = 15365010034
			humanoidDescriptionFromUserIdAsync.RightArm = 15365012263
			humanoidDescriptionFromUserIdAsync.LeftLeg = 15365010038
			humanoidDescriptionFromUserIdAsync.RightLeg = 15365010030
			local success2, result = pcall(
				Players.CreateHumanoidModelFromDescriptionAsync,
				Players,
				humanoidDescriptionFromUserIdAsync,
				Enum.HumanoidRigType.R15
			)

			if success2 then
				if self._destroyed then
					result:Destroy()
					break
				else
					self._preloaded_character_model = result
				end
			else
				warn("Failed to create humanoid model:", result)
			end
		else
			warn("Failed to fetch humanoid description:", humanoidDescriptionFromUserIdAsync)
		end
	end
end

function object:_ClearAllyVisuals()
	if self._ally_highlight then
		self._ally_highlight:Destroy()
		self._ally_highlight = nil
	end

	if self._ally_label then
		self._ally_label:Destroy()
		self._ally_label = nil
	end
end

function object:_UpdateAllyVisuals()
	self:_ClearAllyVisuals()

	if self.ClientDuel.LocalDueler and not (self._is_ally and self:IsAlive()) then
		return
	end

	if self.ClientFighter and (self.ClientFighter:Get("IsSpectating") or self.ClientFighter:Get("IsHiddenByEmotes")) or PlayerDataController:GetSetting("Hide Teammate Icons") then
		return
	end

	local teamColor = DuelLibrary:GetTeamColor(self.ClientFighter:Get("TeamID"))
	local v = not self.ClientFighter.Entity and 0 or self.ClientFighter.Entity:GetHealth() / self.ClientFighter.Entity:GetMaxHealth() or 0
	local lerped = Color3.fromRGB(255, 50, 50):Lerp(
		Color3.fromRGB(255, 215, 0):Lerp(Color3.fromRGB(100, 255, 50), v),
		v
	)
	local color = Color3.new(lerped.R / 2, lerped.G / 2, lerped.B / 2)
	self._ally_label = teammateLabel:Clone()
	self._ally_label.Player.BackgroundColor3 = teamColor
	self._ally_label.Player.Headshot.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, self.ClientFighter.Player.UserId)
	self._ally_label.Health.Bar.Visible = v > 0
	self._ally_label.Health.Bar.Size = UDim2.new(v, 0, 1, 0)
	self._ally_label.Health.BackgroundColor3 = color
	self._ally_label.Health.UIStroke.Color = Color3.new(lerped.R * 0.25, lerped.G * 0.25, lerped.B * 0.25)
	self._ally_label.Health.Bar.BackgroundColor3 = lerped
	self._ally_label.Health.Bar.UIStroke.Color = lerped
	self._ally_label.Parent = self.ClientFighter and self.ClientFighter.Entity and self.ClientFighter.Entity.RootPart or nil
end

function object:_Setup()
	self:_RecordEquippedViewModelDetails()
	self:_UpdateAllyVisuals()

	if not self.ClientFighter then
		return
	end

	table.insert(self._connections, self.ClientFighter.Died:Connect(function(...)
		self.Died:Fire(...)
	end))
	table.insert(self._connections, self.ClientFighter.EntityAdded:Connect(function(...)
		self.EntityAdded:Fire(...)
	end))
	table.insert(self._connections, self.ClientFighter.HealthChanged:Connect(function(...)
		self.HealthChanged:Fire(...)
	end))
	table.insert(self._connections, self.ClientFighter.Eliminated:Connect(function(...)
		self.Eliminated:Fire(...)
	end))
	table.insert(self._connections, self.ClientFighter.ItemAdded:Connect(function(...)
		self.ItemAdded:Fire(...)
	end))
	table.insert(self._connections, self.ClientFighter.ItemRemoved:Connect(function(...)
		self.ItemRemoved:Fire(...)
	end))
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("IsSpectating"):Connect(function(...)
		self:_UpdateAllyVisuals()
	end))
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("IsHiddenByEmotes"):Connect(function(...)
		self:_UpdateAllyVisuals()
	end))
	table.insert(self._connections, self.ClientFighter.EquippedItemChanged:Connect(function()
		self:_RecordEquippedViewModelDetails()
	end))
end

function object:_Init()
	self.Died:Connect(function()
		self:_UpdateAllyVisuals()
	end)
	self.EntityAdded:Connect(function()
		self:SetAlly(self._is_ally)
	end)
	self.HealthChanged:Connect(function()
		self:_UpdateAllyVisuals()
		self:_UpdateTranslucence()
	end)
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("IsSpectating"):Connect(function(...)
		self:_UpdateTranslucence()
		self:_PreloadCharacterModel()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("Status"):Connect(function(...)
		self:_UpdateTranslucence()
	end))
	table.insert(
		self._connections,
		PlayerDataController:GetSettingChangedSignal("Hide Teammate Icons"):Connect(function(...)
			self:_UpdateAllyVisuals()
		end)
	)
	self:_Setup()
	task.spawn(self._PreloadCharacterModel, self)
end

return object