local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local ToonCatalogController = {}
local v = {
	tweens = nil
}
local flag = false
local activatedConnection = nil
local v2 = {
	{
		frameName = "HealthFrame",
		rankProperty = "Health"
	},
	{
		frameName = "DecodeSpeedFrame",
		rankProperty = "DecodeRank"
	},
	{
		frameName = "ExtractionSpeedFrame",
		rankProperty = "DecodeRank"
	},
	{
		frameName = "SpeedFrame",
		rankProperty = "SpeedRank"
	},
	{
		frameName = "StaminaFrame",
		rankProperty = "StaminaRank"
	},
	{
		frameName = "StealthFrame",
		rankProperty = "StealthRank"
	},
	{
		frameName = "SkillCheckFrame",
		rankProperty = "SkillCheckRank"
	}
}

local function updateTitleAndIcon(previewPane, p, p2)
	local title = previewPane:FindFirstChild("Title")

	if not title then
		return
	end

	local toonName = title:FindFirstChild("ToonName")

	if toonName then
		toonName.Text = p.Name or p2.Name
	end

	local preview = title:FindFirstChild("Preview")
	local itemImage = preview and preview:FindFirstChild("ItemImage")

	if itemImage then
		itemImage.Image = p.Icon or ""
	end
end

local function renderStatStars(child, p, frameName, p2)
	local starBar = child:FindFirstChild("StarBar")

	if not starBar then
		return
	end

	local count = 0

	for _, image in pairs(starBar:GetChildren()) do
		if not (image:IsA("ImageLabel") and image.Name == "Star") then
			continue
		end

		count += 1
		image.Visible = true
		image.ImageTransparency = count <= p and 0 or 0.8
	end

	if frameName == "HealthFrame" then
		local mainCharacter = p2.MainCharacter or false
		local images = {}

		for _, image in pairs(starBar:GetChildren()) do
			if image:IsA("ImageLabel") and image.Name == "Star" then
				table.insert(images, image)
			end
		end

		table.sort(images, function(a, b)
			return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
		end)

		for i, v3 in ipairs(images) do
			v3.Visible = i <= 3 or p > 3
			v3.ImageTransparency = 0
			v3.ImageColor3 = Color3.new(1, 1, 1)
		end

		if mainCharacter and #images > 0 and p > 0 then
			images[1].ImageColor3 = Color3.new(0, 0, 0)
		end
	end
end

local function updateStats(previewPane, p)
	local stats = previewPane:FindFirstChild("Stats")

	if not stats then
		return
	end

	for _, v3 in pairs(v2) do
		local child = stats:FindFirstChild(v3.frameName)
		local v4 = p[v3.rankProperty]

		if v3.frameName == "HealthFrame" and not v4 then
			v4 = p.MainCharacter and 2 or 3
		end

		if not (child and v4) then
			continue
		end

		renderStatStars(child, v4, v3.frameName, p)
		local statValue = child:FindFirstChild("StatValue") or child:FindFirstChild("Value")

		if statValue then
			statValue.Text = tostring(v4) .. "/5"
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setAbilityName(abilityName, text)
	if abilityName.Name == "TitleWithDrop" and GameContext.updateTextWithDropSupport then
		GameContext.updateTextWithDropSupport(abilityName, text)
		local titleTop = abilityName:FindFirstChild("TitleTop")

		if titleTop then
			GameContext.updateTextWithDropSupport(titleTop, text)
		end
	else
		abilityName.Text = text
	end
end

local function fillAbilityFrame(instance, text, value, value2)
	local abilityName = instance:FindFirstChild("AbilityName") or instance:FindFirstChild("Name") or instance:FindFirstChild("Title") or instance:FindFirstChild("TitleWithDrop")
	local abilityDescription = instance:FindFirstChild("AbilityDescription") or instance:FindFirstChild("Description") or instance:FindFirstChild("Text")
	local abilityType = instance:FindFirstChild("AbilityType") or instance:FindFirstChild("Type")

	if abilityName then
		setAbilityName(abilityName, text) -- equivalent call inferred; original call site unknown
	end

	if abilityDescription then
		abilityDescription.Text = value or ""
	end

	if abilityType then
		abilityType.Text = value2 or "Passive"
	end
end

local function updateAbilities(previewPane, data)
	local gui = GameContext.Gui
	local abilities = previewPane:FindFirstChild("Abilities")

	if not abilities then
		return
	end

	local ability1 = abilities:FindFirstChild("Ability1")

	if ability1 then
		fillAbilityFrame(
			ability1,
			data.Ability1Name or "No Ability",
			data.Ability1Description,
			data.Ability1Type or "Passive"
		)

		if gui:FindFirstChild("AbilityDetails") then
			gui.AbilityDetails.Ability1.Title.Text = data.Ability1Name
			gui.AbilityDetails.Ability1.Description.Text = data.Ability1Description
		end
	end

	local ability2 = abilities:FindFirstChild("Ability2")

	if ability2 then
		if data.Ability2Name then
			ability2.Visible = true
			fillAbilityFrame(ability2, data.Ability2Name, data.Ability2Description, data.Ability2Type or "Active")

			if gui:FindFirstChild("AbilityDetails") then
				gui.AbilityDetails.Ability2.Visible = true
				gui.AbilityDetails.Ability2.Title.Text = data.Ability2Name
				gui.AbilityDetails.Ability2.Description.Text = data.Ability2Description
			end
		else
			ability2.Visible = false

			if gui:FindFirstChild("AbilityDetails") then
				gui.AbilityDetails.Ability2.Visible = false
			end
		end
	end
end

local function setupEquipButton(previewPane, instance, p, p2)
	local equip = previewPane:FindFirstChild("Equip")

	if not equip then
		return
	end

	if activatedConnection then
		activatedConnection:Disconnect()
		activatedConnection = nil
	end

	activatedConnection = equip.Activated:Connect(function()
		if ReplicatedStorage.Events.Voted:InvokeServer(p2.Name) then
			local name = p.Name or p2.Name

			if GameContext.TextMessage then
				GameContext.TextMessage("Equipped " .. name:upper(), true)
			end

			Audio:PlayOne("Sounds.UI.TapePickup")

			for _, button in pairs(instance:GetChildren()) do
				if not button:IsA("ImageButton") then
					continue
				end

				local visible = button.Name:upper() == p2.Name:upper()
				button.Equipped.Visible = visible
				button.Background.ImageColor3 = visible and Color3.fromRGB(105, 255, 64) or Color3.fromRGB(
					255,
					255,
					255
				)
			end
		elseif GameContext.ErrorMessage then
			GameContext.ErrorMessage("Failed to vote for character!")
		end
	end)
end

local function selectCharacter(p, instance, instance2, p2, p3)
	for _, v3 in pairs(CollectionService:GetTagged("SelectedToonLoadout")) do
		CollectionService:RemoveTag(v3, "SelectedToonLoadout")
		local selected = v3:FindFirstChild("Selected")

		if selected then
			selected.Visible = false
		end
	end

	CollectionService:AddTag(instance2, "SelectedToonLoadout")
	local selected = instance2:FindFirstChild("Selected")

	if selected then
		selected.Visible = true
	end

	local toons = instance:FindFirstChild("Toons")
	local previewPane = toons and toons:FindFirstChild("PreviewPane")

	if previewPane then
		updateTitleAndIcon(previewPane, p2, p3)
		updateStats(previewPane, p2)
		updateAbilities(previewPane, p2)
		setupEquipButton(previewPane, p, p2, p3)
	end

	if GameContext.ensureTrinketCatalogPopulated then
		GameContext.ensureTrinketCatalogPopulated()
	end
end

local function buildToonButton(toonsCatalog, catalogFrame, toonTemplate, data, layoutOrder, child)
	local creature = data.creature
	local data2 = data.data
	local owned = data.owned
	local clone = toonTemplate:Clone()
	clone.Name = creature.Name
	clone.Visible = true
	clone.LayoutOrder = layoutOrder
	local toonImage = clone:FindFirstChild("ToonImage") or clone:FindFirstChild("ItemImage")

	if toonImage and data2.Icon then
		toonImage.Image = data2.Icon
	end

	local toonName = clone:FindFirstChild("ToonName") or clone:FindFirstChild("ItemName")

	if toonName then
		toonName.Text = data2.Name or creature.Name
	else
		local titleWithDrop = clone:FindFirstChild("TitleWithDrop")

		if titleWithDrop and GameContext.updateTextWithDropSupport then
			local name = data2.Name or creature.Name
			local v3 = owned and name or "???"
			GameContext.updateTextWithDropSupport(titleWithDrop, v3)
			local titleTop = titleWithDrop:FindFirstChild("TitleTop")

			if titleTop then
				GameContext.updateTextWithDropSupport(titleTop, v3)
			end
		end
	end

	local characterName = clone:FindFirstChild("CharacterName")

	if characterName then
		characterName.Text = data2.Name or creature.Name
	end

	clone:SetAttribute("DisplayName", data2.Name or creature.Name)
	local selected = clone:FindFirstChild("Selected")

	if selected then
		selected.Visible = false
	end

	if not owned then
		clone.Locked.Visible = true

		if clone.Name == "Dyle" or clone.Name == "Dandy" then
			clone:Destroy()
			return nil
		else
			clone.Name = "ZZ" .. clone.Name
			clone.ItemImage.ImageColor3 = Color3.fromRGB(94, 94, 94)
		end
	end

	clone.Parent = toonsCatalog

	if not owned then
		return clone
	end

	local selectedCharacter = child and child:FindFirstChild("SelectedCharacter")

	if selectedCharacter then
		local visible = selectedCharacter.Value == clone.Name
		clone.Equipped.Visible = visible
		clone.Background.ImageColor3 = visible and Color3.fromRGB(105, 255, 64) or Color3.fromRGB(255, 255, 255)
	end

	local tweens = v.tweens
	clone.Activated:Connect(function()
		selectCharacter(toonsCatalog, catalogFrame, clone, data2, creature)
		Audio:PlayOne("Sounds.UI.Buttons.Click")
		task.spawn(function()
			tweens:playTween(clone.Background, TweenInfo.new(0.1), {
				AnchorPoint = Vector2.new(0.5, 0.45)
			})
			tweens:playTween(clone.ItemImage, TweenInfo.new(0.1), {
				AnchorPoint = Vector2.new(0.5, 0.45)
			})
			tweens:playTween(clone:FindFirstChild("Selected"), TweenInfo.new(0.1), {
				AnchorPoint = Vector2.new(0.5, 0.45)
			})
			task.wait(0.1)
			tweens:playTween(clone.Background, TweenInfo.new(0.1), {
				AnchorPoint = Vector2.new(0.5, 0.5)
			})
			tweens:playTween(clone.ItemImage, TweenInfo.new(0.1), {
				AnchorPoint = Vector2.new(0.5, 0.5)
			})
			tweens:playTween(clone:FindFirstChild("Selected"), TweenInfo.new(0.1), {
				AnchorPoint = Vector2.new(0.5, 0.5)
			})
		end)
	end)
	clone.MouseEnter:Connect(function()
		Audio:PlayOne("Sounds.UI.SkillCheck.Ticks.TinyTick")
		tweens:playTween(clone.UIScale, TweenInfo.new(0.1), {
			Scale = 1.04
		})
	end)
	clone.MouseLeave:Connect(function()
		tweens:playTween(clone.UIScale, TweenInfo.new(0.1), {
			Scale = 1
		})
	end)
	return clone
end

function ToonCatalogController.populate()
	if flag then
		return
	end

	local gui = GameContext.Gui
	local player = GameContext.Player
	local margin = gui.SelectionFrame:FindFirstChild("Margin")
	local catalogFrame = margin and margin:FindFirstChild("CatalogFrame")
	local toons = catalogFrame and catalogFrame:FindFirstChild("Toons")
	local toonsCatalog = toons and toons:FindFirstChild("ToonsCatalog")

	if not toonsCatalog then
		warn("[ToonCatalogController] ToonsCatalog not found")
		return
	end

	for _, frame in pairs(toonsCatalog:GetChildren()) do
		if frame:IsA("Frame") and frame.Name ~= "ToonTemplate" then
			return
		end
	end

	local toonTemplate = toonsCatalog:FindFirstChild("ToonTemplate") or toonsCatalog:FindFirstChild("Template")

	if not toonTemplate then
		warn("[ToonCatalogController] ToonTemplate/Template not found in ToonsCatalog")
		return
	end

	local child = ReplicatedStorage.PlayerData:FindFirstChild((tostring(player.UserId)))
	local towers = child and child:FindFirstChild("Towers")
	local v3 = {}

	for _, moduleScript in pairs(TowerLUT:GetChildren()) do
		local owned = not towers or towers:FindFirstChild(moduleScript.Name) ~= nil
		local module = require(moduleScript)
		table.insert(v3, {
			creature = moduleScript,
			data = module,
			owned = owned,
			displayName = module.Name or moduleScript.Name
		})
	end

	table.sort(v3, function(a, b)
		if a.owned and not b.owned then
			return true
		end

		if a.owned or not b.owned then
			return a.displayName:lower() < b.displayName:lower()
		end

		return false
	end)

	for i, v4 in ipairs(v3) do
		buildToonButton(toonsCatalog, catalogFrame, toonTemplate, v4, i, child)
	end

	flag = true
	local selectedCharacter = child and child:FindFirstChild("SelectedCharacter")

	if selectedCharacter and selectedCharacter.Value then
		local child2 = toonsCatalog:FindFirstChild(selectedCharacter.Value)
		local tower = TowerLUT:GetTower(selectedCharacter.Value)

		if child2 and tower then
			local module = require(tower)
			selectCharacter(toonsCatalog, catalogFrame, child2, module, tower)
		end
	end
end

function ToonCatalogController.reset()
	flag = false
end

function ToonCatalogController.init(options)
	v = options or {}
	GameContext.ensureToonCatalogPopulated = ToonCatalogController.populate
	GameContext.resetToonCatalog = ToonCatalogController.reset
end

return ToonCatalogController