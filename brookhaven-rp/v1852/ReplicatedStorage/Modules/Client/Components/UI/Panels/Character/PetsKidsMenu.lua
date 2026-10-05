local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local GamepassIcon = require(ReplicatedStorage.Modules.Client.Item.GamepassIcon)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PetsConfig = require(ReplicatedStorage.Modules.Shared.DB.Pets.PetsConfig)
local PetController = require(ReplicatedStorage.Modules.Client.Pets.PetController)
local rPNameTextRemote = LegacyGame8Settings.RPNameTextRemote
local rPNameColorRemote = LegacyGame8Settings.RPNameColorRemote
local babyFollow = LegacyGame8Settings.BabyFollow
local v = {
	BabyBoy = true,
	BabyGirl = true
}
local v2 = {
	BabyBoy1 = true,
	BabyBoy2 = true,
	BabyBoy3 = true,
	BabyGirl1 = true,
	BabyGirl2 = true,
	BabyGirl3 = true
}
local v3 = Component.new({
	Tag = "PetsKidsMenu"
})

function v3:Construct()
	self._Janitor = Janitor.new()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCheckmarkVisible(instance, flag: boolean)
	if flag then
		instance:AddTag("Checked")
	else
		instance:RemoveTag("Checked")
	end
end

function v3:_GetEquippedKidName()
	local character = Players.LocalPlayer.Character
	local followCharacter

	if character == nil then
		followCharacter = false
	else
		followCharacter = character:FindFirstChild("FollowCharacter")
	end

	if followCharacter ~= nil then
		return followCharacter:GetAttribute("ModelName")
	end

	local playersBag = Players.LocalPlayer:FindFirstChild("PlayersBag")
	local followCharacterName

	if playersBag == nil then
		followCharacterName = false
	else
		followCharacterName = playersBag:FindFirstChild("FollowCharacterName")
	end

	if followCharacterName == nil or followCharacterName.Value == "NoFollowCharacter" then
		return nil
	end

	return followCharacterName.Value
end

function v3:_UpdateKidCheckmarks()
	if self._scrollingFrameKid == nil then
		return
	end

	local _GetEquippedKidName = self:_GetEquippedKidName()

	for _, button in self._scrollingFrameKid:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v4

		if _GetEquippedKidName == nil then
			v4 = false
		else
			v4 = button.Name == _GetEquippedKidName
		end

		if v4 then
			setCheckmarkVisible(button, true) -- equivalent call inferred; original call site unknown
		else
			setCheckmarkVisible(button, false) -- equivalent call inferred; original call site unknown
		end
	end
end

function v3:_SetupFollowControls(instance)
	local frame = instance:FindFirstChild("Frame")

	if frame == nil then
		return
	end

	local v4 = false

	for _, button in frame:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v5 = button
		self._Janitor:Add(button.MouseButton1Click:Connect(function()
			if v4 == true then
				return
			end

			v4 = true

			if v5.Name == "FollowColor" and v5:FindFirstChild("Color") ~= nil then
				rPNameColorRemote:FireServer("PickingRPFollowColor", v5.Color)
			end

			task.wait(0.3)
			v4 = false
		end))
	end

	local rPFollowName = frame:FindFirstChild("RPFollowName")

	if rPFollowName ~= nil and rPFollowName:IsA("TextBox") then
		self._Janitor:Add(rPFollowName.FocusLost:Connect(function()
			rPNameTextRemote:FireServer("RolePlayFollow", rPFollowName.Text)
		end))
	end
end

function v3:_SetupKidButtons(instance)
	local v4 = false

	for _, button in instance:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v5 = button
		self._Janitor:Add(button.MouseButton1Click:Connect(function()
			if v4 == true then
				return
			end

			local character = Players.LocalPlayer.Character
			local humanoid

			if character == nil then
				humanoid = false
			else
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			if humanoid ~= nil and humanoid.Sit == true then
				return
			end

			v4 = true
			local name = v5.Name
			local _GetEquippedKidName = self:_GetEquippedKidName()

			if _GetEquippedKidName == nil or _GetEquippedKidName ~= name then
				if v[name] == true then
					babyFollow:FireServer("SpawnChild", name)
				elseif v2[name] == true then
					if UnlockableController.IsFeatureUnlocked(name, Gamepasses.PREMIUM) then
						babyFollow:FireServer("SpawnChild", name)
					else
						GamepassController.Show(Gamepasses.PREMIUM, v5.Icon.Image, "baby character", nil, {
							id = name
						}, nil, "Kid Inventory", name, function()
							if v5.Parent == nil or not self.Instance.Visible or Players.LocalPlayer.Character ~= character then
								return
							end

							local humanoid2

							if character == nil then
								humanoid2 = false
							else
								humanoid2 = character:FindFirstChildOfClass("Humanoid")
							end

							if humanoid2 ~= nil and humanoid2.Sit == true then
								return
							end

							babyFollow:FireServer("SpawnChild", name)
						end)
					end
				end
			else
				babyFollow:FireServer("DeleteFollowCharacter")
			end

			task.wait(0.3)
			v4 = false
		end))
	end
end

function v3:_UpdatePetCheckmarks()
	if self._scrollingFramePet == nil then
		return
	end

	for _, button in self._scrollingFramePet:GetChildren() do
		if not (button:IsA("ImageButton") and button.Name ~= "Template") then
			continue
		end

		if PetController.IsPetEquipped(button.Name) then
			setCheckmarkVisible(button, true) -- equivalent call inferred; original call site unknown
		else
			setCheckmarkVisible(button, false) -- equivalent call inferred; original call site unknown
		end
	end
end

local function setGamepassIndicatorVisible(clone, p)
	local gamepass = clone:FindFirstChild("Gamepass")

	if gamepass == nil or not gamepass:IsA("GuiObject") then
		return
	end

	local requiredGamepass = PetsConfig.GetRequiredGamepass(p)

	if requiredGamepass == nil then
		gamepass.Visible = false
		return
	end

	gamepass.Visible = true

	if gamepass:IsA("ImageLabel") then
		local smallIcon = GamepassIcon.GetSmallIcon(requiredGamepass)

		if smallIcon ~= nil then
			gamepass.Image = smallIcon
		end
	end
end

function v3:_SetupPetButtons(parent)
	local template = parent:FindFirstChild("Template")

	if template == nil or not template:IsA("ImageButton") then
		warn("PetsKidsMenu: ScrollingFramePet is missing a Template ImageButton")
		return
	end

	template.Visible = false
	local config = PetsConfig.GetConfig()
	local v4 = {}

	for _, v5 in config do
		if typeof(v5) == "table" and v5.Name ~= nil then
			table.insert(v4, v5)
		end
	end

	table.sort(v4, function(a, b)
		return (a.Order or 0) < (b.Order or 0)
	end)
	local v5 = false

	for _, v6 in v4 do
		local clone = template:Clone()
		clone.Name = v6.Name
		clone.LayoutOrder = v6.Order or 0
		local icon = clone:FindFirstChild("Icon")

		if icon == nil or not icon:IsA("ImageLabel") or v6.Icon == nil then
			local label = clone:FindFirstChild("Label")

			if label ~= nil and label:IsA("TextLabel") then
				label.Text = v6.Name
			end
		else
			icon.Image = v6.Icon
		end

		setCheckmarkVisible(clone, false) -- equivalent call inferred; original call site unknown
		setGamepassIndicatorVisible(clone, v6)
		clone.Visible = true
		clone.Parent = parent
		local v7 = v6
		local image = icon
		self._Janitor:Add(clone.MouseButton1Click:Connect(function()
			if v5 == true then
				return
			end

			v5 = true
			local name = v7.Name
			local requiredGamepass = PetsConfig.GetRequiredGamepass(v7)

			if requiredGamepass == nil or UnlockableController.IsFeatureUnlocked(name, requiredGamepass) then
				if PetController.IsPetEquipped(name) then
					Remotes.fireServer("Pet_Unequip", name)
				else
					Remotes.fireServer("Pet_Equip", name)
				end
			else
				local v9 = (image == nil or not image:IsA("ImageLabel")) and "" or image.Image or ""
				GamepassController.Show(
					requiredGamepass,
					v9,
					"pet",
					nil,
					AdFeatures.Pets()[name],
					nil,
					"Pet Inventory",
					name,
					function()
						if clone.Parent == nil or not self.Instance.Visible then
							return
						end

						if not PetController.IsPetEquipped(name) then
							Remotes.fireServer("Pet_Equip", name)
						end
					end
				)
			end

			task.wait(0.3)
			v5 = false
		end))
	end

	self:_UpdatePetCheckmarks()
end

function v3:_SetupPetNameControls(instance)
	local frame = instance:FindFirstChild("Frame")

	if frame == nil then
		return
	end

	local v4 = false

	for _, button in frame:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v5 = button
		self._Janitor:Add(button.MouseButton1Click:Connect(function()
			if v4 == true then
				return
			end

			v4 = true

			if v5.Name == "FollowColor" then
				local color = v5:FindFirstChild("Color")

				if color ~= nil and color:IsA("StringValue") then
					Remotes.fireServer("Pet_SetNameColor", color.Value)
				end
			end

			task.wait(0.3)
			v4 = false
		end))
	end

	local rPFollowName = frame:FindFirstChild("RPFollowName")

	if rPFollowName ~= nil and rPFollowName:IsA("TextBox") then
		self._Janitor:Add(rPFollowName.FocusLost:Connect(function()
			Remotes.fireServer("Pet_SetName", rPFollowName.Text)
		end))
	end
end

function v3:_ShowTab(p: string)
	local visible = p == "Kids"

	if self._scrollingFrameKid ~= nil then
		self._scrollingFrameKid.Visible = visible
	end

	if self._scrollingFrameKid2 ~= nil then
		self._scrollingFrameKid2.Visible = visible
	end

	if self._scrollingFramePet ~= nil then
		self._scrollingFramePet.Visible = not visible
	end

	if self._scrollingFramePet2 ~= nil then
		self._scrollingFramePet2.Visible = not visible
	end

	if self._kidsTab ~= nil then
		local _kidsTab = self._kidsTab

		if visible then
			setCheckmarkVisible(_kidsTab, true) -- equivalent call inferred; original call site unknown
		else
			setCheckmarkVisible(_kidsTab, false) -- equivalent call inferred; original call site unknown
		end
	end

	if self._petsTab ~= nil then
		local _petsTab = self._petsTab

		if visible then
			setCheckmarkVisible(_petsTab, false) -- equivalent call inferred; original call site unknown
		else
			setCheckmarkVisible(_petsTab, true) -- equivalent call inferred; original call site unknown
		end
	end
end

function v3:_SetupTabs(instance)
	self._kidsTab = instance:FindFirstChild("KidsTab", true)
	self._petsTab = instance:FindFirstChild("PetsTab", true)

	if self._kidsTab ~= nil and self._kidsTab:IsA("GuiButton") then
		self._Janitor:Add(self._kidsTab.MouseButton1Click:Connect(function()
			self:_ShowTab("Kids")
		end))
	end

	if self._petsTab ~= nil and self._petsTab:IsA("GuiButton") then
		self._Janitor:Add(self._petsTab.MouseButton1Click:Connect(function()
			self:_ShowTab("Pets")
		end))
	end
end

function v3:Start()
	local instance = self.Instance
	local container = instance:WaitForChild("Catalog"):WaitForChild("Container")
	self._scrollingFrameKid = container:FindFirstChild("ScrollingFrameKid")
	self._scrollingFrameKid2 = container:FindFirstChild("ScrollingFrameKid2")
	self._scrollingFramePet = container:FindFirstChild("ScrollingFramePet")
	self._scrollingFramePet2 = container:FindFirstChild("ScrollingFramePet2")

	if self._scrollingFrameKid ~= nil then
		self:_SetupKidButtons(self._scrollingFrameKid)
	end

	if self._scrollingFrameKid2 ~= nil then
		self:_SetupFollowControls(self._scrollingFrameKid2)
	end

	if self._scrollingFramePet ~= nil then
		self:_SetupPetButtons(self._scrollingFramePet)
	end

	if self._scrollingFramePet2 ~= nil then
		self:_SetupPetNameControls(self._scrollingFramePet2)
	end

	self:_SetupTabs(instance)
	self:_ShowTab("Pets")
	self:_UpdateKidCheckmarks()
	local playersBag = Players.LocalPlayer:FindFirstChild("PlayersBag")
	local followCharacterName

	if playersBag == nil then
		followCharacterName = false
	else
		followCharacterName = playersBag:FindFirstChild("FollowCharacterName")
	end

	if followCharacterName ~= nil then
		self._Janitor:Add(followCharacterName:GetPropertyChangedSignal("Value"):Connect(function()
			self:_UpdateKidCheckmarks()
		end))
	end

	self._Janitor:Add(PetController.OnEquippedPetsChanged:Connect(function()
		self:_UpdatePetCheckmarks()
	end))
end

function v3:Stop()
	self._Janitor:Destroy()
end

return v3