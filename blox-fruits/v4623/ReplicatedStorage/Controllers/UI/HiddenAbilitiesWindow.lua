local HiddenAbilitiesWindow = {}
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local PlayerDataUtil = require(game.ReplicatedStorage.Modules.Player.PlayerDataUtil)
require(game.ReplicatedStorage.Modules.Flags)
local Net = require(game.ReplicatedStorage.Modules.Net)
local v = nil
local Notification = require(game.ReplicatedStorage:WaitForChild("Notification"))
local Abilities = require(game.ReplicatedStorage.Modules.HiddenAbilities.Abilities)
local abilityFromStorageName = Abilities.AbilityFromStorageName
local Abilities2 = require(game.ReplicatedStorage.Modules.HiddenAbilities.Abilities)
local experimentFromStorageName = Abilities2.ExperimentFromStorageName
local Abilities3 = require(game.ReplicatedStorage.Modules.HiddenAbilities.Abilities)
local abilitiesFromFruitName = Abilities3.AbilitiesFromFruitName
local Abilities4 = require(game.ReplicatedStorage.Modules.HiddenAbilities.Abilities)
local abilityFromExperimentName = Abilities4.AbilityFromExperimentName
local Abilities5 = require(game.ReplicatedStorage.Modules.HiddenAbilities.Abilities)
local comingSoon = Abilities5.ComingSoon
local AdminPanel = require(game.ReplicatedStorage.DialoguesList.AdminPanel)
local GetFruitName = require(game.ReplicatedStorage.Modules.Asset.GetFruitName)
local ImageUtil = require(game.ReplicatedStorage.Modules.Asset.ImageUtil)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local Util = require(script.Util)
local v2 = nil
task.spawn(function()
	local ItemData = require(game.ReplicatedStorage.Modules.Asset.ItemData)
	v2 = ItemData
end)
local remoteFunction = Net:RemoteFunction("HiddenAbilitiesRF")
local remoteEvent = Net:RemoteEvent("HiddenAbilitiesRE")
local FRUIT_APPEARANCE_SETTINGS = Util.FRUIT_APPEARANCE_SETTINGS
local maid = nil
local maid2 = nil
local v3 = nil
local v4 = nil
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = nil
local v9 = nil
local value = ""
local localPlayer = game.Players.LocalPlayer
local hiddenAbilities = nil
local modal = nil
local close = nil
local fruitView = nil
local abilityView = nil
local researchView = nil

local function fn(...)
	local Global = require(game.ReplicatedStorage.Global)

	if not Global.TestGamePrint then
		return
	end

	local Global2 = require(game.ReplicatedStorage.Global)
	Global2.TestGamePrint(...)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sendEquipMessage(p: string)
	Notification.new((`You must have <Color=Yellow><{GetFruitName(p)}><Color=/> equipped.`)):Display()
end

local flag = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function debounce(callback)
	if flag then
		fn("Debounced")
		return
	end

	flag = true
	local success, result = pcall(callback)

	if not success then
		warn(result)
	end

	flag = nil
end

local function getTemplate(instance, clones, content)
	local clone = nil

	for _, v11 in pairs(clones) do
		if v11:GetAttribute("InUse") then
			continue
		end

		clone = v11
		break
	end

	if not clone then
		clone = instance:Clone()
		local assert_2 = assert(clone)
		assert_2.Parent = content
	end

	clone:SetAttribute("InUse", true)

	if not table.find(clones, clone) then
		table.insert(clones, clone)
	end

	return clone
end

local function recycleTemplates(items)
	for _, guiObject in pairs(items) do
		if guiObject:IsA("Frame") then
			guiObject.Visible = false
		elseif guiObject:IsA("ImageButton") then
			guiObject.Visible = false
		end

		guiObject:SetAttribute("InUse", false)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSelectedObject(selectedObject)
	if LastInput:Get() == "Gamepad" then
		local GuiService = game:GetService("GuiService")
		GuiService.SelectedObject = selectedObject
	end
end

function displayExperiments(p: string, p2: string)
	setSelectedObject(close) -- equivalent call inferred; original call site unknown
	v8 = "Experiments"
	v4 = p
	fn((`Display experiments: {p}:{p2}`))
	Util.setDoubleText(modal:FindFirstChild("Title"):FindFirstChild("TextLabel"), "Research Report")
	Util.setDoubleText(close:FindFirstChild("TextLabel"), "Back")

	if v3 then
		v3:Destroy()
	end

	local maid3 = assert(maid2):Extend()
	v3 = maid3
	assert(maid3)
	maid3:Add(function()
		v3 = nil
		maid3 = nil
		researchView.Visible = false
		recycleTemplates(v5)
	end)
	local content = researchView:FindFirstChild("Content")
	local experimentViewTemplate3 = content:FindFirstChild("ExperimentViewTemplate3")
	experimentViewTemplate3.Visible = false
	local abilityInfo = assert(abilityFromStorageName(p))
	local currentAbilityReseach = content:FindFirstChild("CurrentAbilityReseach")
	currentAbilityReseach.AutoButtonColor = false
	local textButton = currentAbilityReseach:FindFirstChild("TextButton")
	textButton.Visible = false
	local textLabel = textButton:FindFirstChild("TextLabel")
	local backdrop = currentAbilityReseach:FindFirstChild("Backdrop")
	local abilityName = currentAbilityReseach:FindFirstChild("AbilityName")
	local description = currentAbilityReseach:FindFirstChild("Description")
	local progress = currentAbilityReseach:FindFirstChild("Progress")
	backdrop.BackgroundColor3 = assert(FRUIT_APPEARANCE_SETTINGS[p2].BackdropColor)
	progress.Text = ""
	description.Text = abilityInfo.HiddenDescription
	Util.setDoubleText(abilityName, abilityInfo.DisplayName)
	local getClientInfo = Util.getClientInfo
	maid3:Add(getClientInfo(function(p3)
		local ability = p3.FruitList[abilityInfo.FruitName].Abilities[abilityInfo.AbilityIndex]
		progress.Text = Util.formatProgress(ability.Progress, ability.Goal).String
		local v12 = nil

		if ability.Owned then
			v12 = abilityInfo.Experiments[#abilityInfo.Experiments]
		else
			for i = 1, #ability.Experiments do
				local experiment = ability.Experiments[i]
				v12 = experimentFromStorageName(experiment.ExperimentName)

				if experiment.Progress < v12.Goal then
					break
				end
			end
		end

		for _, experiment in pairs(ability.Experiments) do
			local v13 = experimentFromStorageName(experiment.ExperimentName)
			local experimentIndex = v13.ExperimentIndex
			local template = getTemplate(experimentViewTemplate3, v5, content)
			assert(template:IsA("Frame"))
			local locked = template:FindFirstChild("Locked")
			local unlocked = template:FindFirstChild("Unlocked")
			local footer = unlocked:FindFirstChild("Footer")
			local uIStroke = template:FindFirstChildOfClass("UIStroke")
			uIStroke.Color = Color3.fromRGB()
			footer.Visible = false
			locked.Visible = false
			unlocked.Visible = false

			if experimentIndex <= v12.ExperimentIndex then
				local progressBarFrame = footer:FindFirstChild("ProgressBarFrame")
				local progress2 = progressBarFrame:FindFirstChild("Progress")
				local bar = progressBarFrame:FindFirstChild("Bar")
				progressBarFrame.Visible = false
				local textButton2 = footer:FindFirstChild("TextButton", true)
				textButton2.Visible = false
				local observation = unlocked:FindFirstChild("Observation", true)
				local experiment2 = unlocked:FindFirstChild("Experiment", true)
				local imageLabel = unlocked:FindFirstChild("ImageLabel", true)
				local header = unlocked:FindFirstChild("Header", true)
				header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				local formatProgress = Util.formatProgress(experiment.Progress, v13.Goal)
				bar.Visible = formatProgress.Alpha > 0.1
				bar.Size = UDim2.fromScale(formatProgress.Alpha, 1)
				progress2.Text = formatProgress.Alpha == 1 and "Complete" or formatProgress.String
				observation.Text = v13.Observation

				if experiment.Progress > 0 or ability.Owned then
					experiment2.Text = v13.Experiment
				else
					experiment2.Text = "???"
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function setIconImage(flag2: boolean?)
					local complete = flag2 and Util.RESEARCH_ICONS.Complete or Util.RESEARCH_ICONS.InProgress
					imageLabel.Image = complete.Image
					imageLabel.ImageRectSize = complete.ImageRectSize
					imageLabel.ImageRectOffset = complete.ImageRectOffset
				end

				setIconImage(false) -- equivalent call inferred; original call site unknown
				-- equivalent calls inferred from this helper; original call sites unknown
				local v15 = v13
				local v17 = uIStroke
				local v19 = imageLabel

				local function setFrameComplete()
					fn((`Completed {v15.ExperimentName}`))
					header.BackgroundColor3 = Color3.fromRGB(48, 199, 65)
					v17.Color = header.BackgroundColor3
					progressBarFrame.Visible = true
					setIconImage(true) -- equivalent call inferred; original call site unknown
				end

				if ability.Owned then
					setFrameComplete() -- equivalent call inferred; original call site unknown
				elseif v12.ExperimentIndex == experimentIndex then
					if experiment.Researching then
						if v12.ExperimentIndex == #abilityInfo.Experiments and ability.CanComplete then
							fn((`Offer Craft: {v13.ExperimentName}`))
							setFrameComplete() -- equivalent call inferred; original call site unknown
							progress.Text = ""
							Util.setDoubleText(textLabel, "Complete Research")
							Util.setButtonState(textButton, "CompleteResearch")
							maid3:Add(Util.connectButtons({ textButton }, function()
								local function fn2()
									fn((`Open crafting for: {p}`))
									local v20 = not abilityInfo.Cost.Fragments or localPlayer.Data.Fragments.Value >= abilityInfo.Cost.Fragments
									local v21 = true

									for _, etcItem in pairs(abilityInfo.Cost.EtcItems) do
										local name = etcItem.Name

										if not (etcItem.Amount > ability.MaterialsOwned[name]) then
											continue
										end

										v21 = false
										break
									end

									local CraftWindow = require(game.ReplicatedStorage.Controllers.UI.CraftWindow)
									local v23 = {}

									if abilityInfo.Cost.Fragments then
										table.insert(v23, {
											Name = "Fragments",
											Required = abilityInfo.Cost.Fragments,
											Count = localPlayer.Data.Fragments.Value,
											Rarity = 1
										})
									end

									for _, etcItem in abilityInfo.Cost.EtcItems do
										local v24 = v2.Material[etcItem.Name]
										table.insert(v23, {
											Name = etcItem.Name,
											Required = etcItem.Amount,
											Count = ability.MaterialsOwned[etcItem.Name],
											Rarity = v24[1]
										})
									end

									CraftWindow:Open("HiddenAbilities", v23, {
										Could = v20 and v21,
										Name = p,
										Type = "Fruit",
										AbilityInfo = abilityInfo,
										Rarity = 4,
										IsChoosable = false
									}, nil, "Experiment", function(p4)
										if p4 then
											modal.Visible = true
											return
										end

										ability.Owned = true

										if not remoteFunction:InvokeServer({
											Context = "CraftAbility",
											AbilityName = p
										}) then
											ability.Owned = false
										end

										Util.getClientInfo(function()
											displayExperiments(p, p2)
											modal.Visible = true
										end, true)
									end, "NPC")
									modal.Visible = false
								end

								debounce(fn2) -- equivalent call inferred; original call site unknown
							end))
							textButton.Visible = true
						else
							fn((`In progress {v13.ExperimentName}`))
							progressBarFrame.Visible = true
						end
					else
						local v20

						if v12.ExperimentIndex == 1 then
							fn((`Offer First Research: {v13.ExperimentName}`))
							v20 = textButton
							Util.setDoubleText(textLabel, "Start Research")
							Util.setButtonState(v20, "StartResearch")
						else
							fn((`Offer Card Research: {v13.ExperimentName}`))
							Util.setDoubleText(textLabel, "Research")
							Util.setButtonState(textButton2, "StartResearch")
							v20 = textButton2
						end

						fn((`Offer Research: {v13.ExperimentName}`))
						local v21 = experiment
						maid3:Add(Util.connectButtons({ v20 }, function()
							local function fn2()
								v21.Researching = true
								displayExperiments(abilityInfo.StorageName, abilityInfo.FruitName)

								if not remoteFunction:InvokeServer({
									Context = "StartResearch",
									AbilityName = p
								}) then
									fn("StartResearch failed??")
									v21.Researching = false
									displayExperiments(abilityInfo.StorageName, abilityInfo.FruitName)
								end

								if maid3 then
									maid3:Add(Util.getClientInfo(function() end, true))
								end
							end

							debounce(fn2) -- equivalent call inferred; original call site unknown
						end))
						v20.Visible = true
					end
				else
					setFrameComplete() -- equivalent call inferred; original call site unknown
				end

				unlocked.Visible = true

				if progressBarFrame.Visible or textButton2.Visible then
					footer.Visible = true
				end
			else
				fn((`Hidden {v13.ExperimentName}`))
				local textLabel2 = locked:FindFirstChild("TextLabel")
				Util.setDoubleText(textLabel2, Util.getFileName(abilityInfo.AbilityIndex, experimentIndex))
				locked.Visible = true
			end

			template.Visible = true
		end
	end))
	researchView.Visible = true
end

function displayAbilities(p: string)
	setSelectedObject(close) -- equivalent call inferred; original call site unknown
	v9 = p
	v8 = "Abilities"
	local fruitName = GetFruitName(p)
	Util.setDoubleText(modal:FindFirstChild("Title"):FindFirstChild("TextLabel"), (`Admin Panel - {fruitName}`))
	Util.setDoubleText(close:FindFirstChild("TextLabel"), "Back")

	if v3 then
		v3:Destroy()
	end

	local maid3 = assert(maid2):Extend()
	v3 = maid3
	assert(maid3)
	maid3:Add(function()
		v3 = nil
		maid3 = nil
		abilityView.Visible = false
		recycleTemplates(v6)
	end)
	local content = abilityView:FindFirstChild("Content")
	local textLabel = abilityView:FindFirstChild("TextLabel")
	textLabel.Text = "..."
	local abilityViewTemplate = content:FindFirstChild("AbilityViewTemplate")
	abilityViewTemplate.Visible = false
	local v12 = abilitiesFromFruitName(p)
	local count = 0
	local count2 = 0

	for _, v13 in pairs(assert(v12)) do
		count += 1
		assert(abilityFromStorageName(v13.StorageName))
		local template = getTemplate(abilityViewTemplate, v6, content)
		assert(template:IsA("ImageButton"))
		template.AutoButtonColor = false
		local textButton = template:FindFirstChild("TextButton")
		textButton.AutoButtonColor = false
		local textButton2 = template:FindFirstChild("TextButton2")
		textButton2.Visible = false
		local v14 = assert(template:FindFirstChildOfClass("UIStroke"))
		v14.Color = Color3.fromRGB()
		local backdrop = template:FindFirstChild("Backdrop")
		local lockedOverlay = template:FindFirstChild("LockedOverlay")
		local abilityName = template:FindFirstChild("AbilityName")
		local description = template:FindFirstChild("Description")
		local progress = template:FindFirstChild("Progress")
		backdrop.Visible = false
		lockedOverlay.Visible = true
		description.Text = ""
		progress.Text = ""

		if Util._clientInfo == nil then
			local fileName = Util.getFileName(v13.AbilityIndex)
			Util.setDoubleText(abilityName, fileName)
			Util.setButtonText(textButton, "...")
			Util.setButtonState(textButton, "Inactive")
		else
			Util.setDoubleText(abilityName, "")
			Util.setButtonText(textButton, "")
			Util.setButtonState(textButton, "Inactive")
		end

		template.Name = `{p}>{v13.StorageName}`
		template.Visible = true
		local getClientInfo = Util.getClientInfo
		local v15 = v13
		maid3:Add(getClientInfo(function(p2)
			local v24 = p2.FruitList[p]

			for k, ability in pairs(v24.Abilities) do
				if ability.StorageName ~= v15.StorageName then
					continue
				end

				local currentlyResearching = Util.getCurrentlyResearching(p2, p, ability.StorageName)
				local v25 = v24.CurrentMastery >= v15.Mastery
				local locked = ability.Locked

				if v25 and not locked then
					Util.setDoubleText(abilityName, v15.DisplayName)
					count2 += 1
					backdrop.BackgroundColor3 = assert(FRUIT_APPEARANCE_SETTINGS[p].BackdropColor)
					backdrop.Visible = true
					lockedOverlay.Visible = false
					local v26 = value == v15.FruitName
					local v27 = {}

					if currentlyResearching then
						progress.Text = `{Util.formatProgress(ability.Progress, ability.Goal).String} Complete`

						if v26 then
							v14.Color = Color3.fromRGB(235, 218, 55)
						end
					end

					local v28 = ability

					local function updateEquippedAppearance()
						if v28.Owned then
							if v28.Enabled then
								Util.setButtonText(textButton2, "Unequip")
								Util.setButtonState(textButton2, "Inactive")
							else
								Util.setButtonText(textButton2, "Equip")
								Util.setButtonState(textButton2, "Green")
							end

							if not v26 then
								Util.setButtonState(textButton2, "Inactive")
							end
						end

						if v26 then
							Util.setButtonState(textButton, "ViewResearch")
						else
							Util.setButtonState(textButton, "Inactive")
						end

						Util.setButtonText(textButton, "View")

						if v28.Enabled then
							description.Text = v15.EquippedDescription
						else
							description.Text = v15.HiddenDescription
						end
					end

					if ability.Owned then
						if v26 then
							local v30 = ability
							local updateEquippedAppearance2 = updateEquippedAppearance

							function v27.equipButton()
								local enabled = not v30.Enabled
								v30.Enabled = enabled
								updateEquippedAppearance2()
								v30.Enabled = remoteFunction:InvokeServer({
									Context = "ToggleAbility",
									AbilityName = v15.StorageName
								})

								if enabled ~= v30.Enabled then
									updateEquippedAppearance2()
								end
							end
						else
							function v27.equipButton()
								sendEquipMessage(p) -- equivalent call inferred; original call site unknown
								task.wait(0.1)
							end
						end
					end

					if v26 then
						function v27.primaryButton()
							displayExperiments(v15.StorageName, v15.FruitName)
						end
					else
						function v27.primaryButton()
							sendEquipMessage(p) -- equivalent call inferred; original call site unknown
							task.wait(0.1)
						end
					end

					updateEquippedAppearance()

					if v27.equipButton then
						textButton2.Visible = true
						local v30 = v27
						maid3:Add(Util.connectButtons({ textButton2 }, function()
							local function fn2()
								v30.equipButton()
								task.wait(0.2)
							end

							debounce(fn2) -- equivalent call inferred; original call site unknown
						end))
					end

					if v27.primaryButton then
						textButton.AutoButtonColor = true
						local v30 = v27
						maid3:Add(Util.connectButtons({ textButton }, function()
							debounce(v30.primaryButton) -- equivalent call inferred; original call site unknown
						end))
					end
				else
					Util.setDoubleText(abilityName, Util.getFileName(v15.AbilityIndex))
					description.Text = ""
					backdrop.Visible = false
					lockedOverlay.Visible = true

					if locked then
						description.Text = ""
					else
						description.Text = `Mastery {v24.CurrentMastery}/{v15.Mastery}`
					end

					Util.setButtonText(textButton, "Locked")
				end

				textLabel.Text = `{fruitName} appears to have {count} unique abilities, {count2} of which you've unlocked...`
			end
		end))
	end

	abilityView.Visible = true
end

local function displayFruitList()
	v8 = "Fruits"
	Util.setDoubleText(modal:FindFirstChild("Title"):FindFirstChild("TextLabel"), "Admin Panel")
	Util.setDoubleText(close:FindFirstChild("TextLabel"), "Close")

	if v3 then
		v3:Destroy()
	end

	local maid3 = assert(maid2):Extend()
	v3 = maid3
	assert(maid3)
	maid3:Add(function()
		v3 = nil
		maid3 = nil
		fruitView.Visible = false
		recycleTemplates(v7)
	end)
	local content = fruitView:FindFirstChild("Content")
	local fruitViewTemplate = content:FindFirstChild("FruitViewTemplate")
	fruitViewTemplate.Visible = false
	local templatesByLayoutOrder = {}

	for k, name in Util.fruitList() do
		local v11 = assert(FRUIT_APPEARANCE_SETTINGS[name], (`{name} needs appearance settings`))
		local template = getTemplate(fruitViewTemplate, v7, content)
		assert(template:IsA("ImageButton"), template.ClassName)
		local backdrop = template:FindFirstChild("Backdrop")
		local icon = template:FindFirstChild("Icon")
		local fruitName = template:FindFirstChild("FruitName")
		local progress = template:FindFirstChild("Progress")
		local description = template:FindFirstChild("Description")
		local overlay = template:FindFirstChild("Overlay")
		icon.Size = v11.FruitIconSize or Util.DEFAULT_FRUIT_APPEARANCE_INFO.FruitIconSize
		icon.Position = v11.FruitIconPosition or Util.DEFAULT_FRUIT_APPEARANCE_INFO.FruitIconPosition
		backdrop.BackgroundColor3 = v11.BackdropColor or Util.DEFAULT_FRUIT_APPEARANCE_INFO.BackdropColor
		fruitName.Position = v11.FruitNamePosition or Util.DEFAULT_FRUIT_APPEARANCE_INFO.FruitNamePosition
		progress.Position = v11.Line1Position or Util.DEFAULT_FRUIT_APPEARANCE_INFO.Line1Position
		progress.Text = ""
		description.Position = v11.Line2Position or Util.DEFAULT_FRUIT_APPEARANCE_INFO.Line2Position
		description.Text = ""
		description.RichText = true
		template.Active = false
		template.AutoButtonColor = false
		template.Name = name
		template.LayoutOrder = math.max(#name - k, 1)
		templatesByLayoutOrder[template.LayoutOrder] = template
		local fruitName2 = GetFruitName(name)
		ImageUtil.applySpriteFromItemId(name, { "PhysicalMoveset" }, {
			Icon = icon
		})
		Util.setDoubleText(fruitName, fruitName2)

		if table.find(comingSoon, name) then
			progress.Text = "Coming Soon"
			icon.ImageColor3 = Color3.fromRGB()
			overlay.Visible = true
			template.LayoutOrder = #name + 9999
		else
			overlay.Visible = false
			local getClientInfo = Util.getClientInfo
			local v13 = name
			local fruitName3 = fruitName2
			local v15 = progress
			local v16 = description
			local v17 = template
			maid3:Add(getClientInfo(function(p)
				local currentlyResearching = Util.getCurrentlyResearching(p, v13)
				local color = Color3.fromRGB()
				local v18 = value == v13
				local layoutOrder = v18 and -#v13 or #v13
				local v20 = #p.FruitList[v13].Abilities
				local count = 0
				local text = "View potential Research"
				local transparency = 0

				for k2, ability in pairs(p.FruitList[v13].Abilities) do
					if ability.Owned then
						count += 1
					end
				end

				local formatProgress = Util.formatProgress(count, v20)
				local v23 = formatProgress.Alpha == 1
				local formatted = `{formatProgress.String} Complete{v23 and "" or ".."}`
				local v24 = currentlyResearching or formatProgress.Alpha > 0 or v18

				if v18 then
					color = Color3.fromRGB(233, 217, 54)

					if currentlyResearching then
						text = `Currently Researching: "{abilityFromExperimentName(currentlyResearching.ExperimentName).DisplayName}"`
					end
				elseif v24 then
					text = `Equip {fruitName3} to continue research`
				else
					text = `Equip {fruitName3} to view research`
				end

				local text2

				if v23 then
					text2 = ""

					if v18 then
						text = formatted
					else
						color = Color3.fromRGB(233, 217, 54)
						text = formatted
						transparency = 0.5
					end
				else
					text2 = formatted
				end

				v15.Text = text
				v16.Text = text2
				v17.LayoutOrder = layoutOrder
				local uIStroke = v17:FindFirstChildOfClass("UIStroke")
				uIStroke.Color = color
				uIStroke.Transparency = transparency

				if not v24 then
					maid3:Add(v17.MouseButton1Click:Connect(function()
						sendEquipMessage(v13) -- equivalent call inferred; original call site unknown
					end))
					return
				end

				v17.AutoButtonColor = true
				v17.Active = true
				maid3:Add(v17.MouseButton1Click:Connect(function()
					displayAbilities(v13)
				end))
			end))
		end

		template.Visible = true
	end

	fruitView.Visible = true

	for _, selectedObject in pairs(templatesByLayoutOrder) do
		if LastInput:Get() ~= "Gamepad" then
			break
		end

		local GuiService = game:GetService("GuiService")
		GuiService.SelectedObject = selectedObject
		break
	end
end

function setup()
	assert(maid)

	if maid2 then
		maid2:Destroy()
	end

	maid2 = maid:Extend()
	assert(maid2)
	maid2:Add(function()
		maid2 = nil
	end)
	displayFruitList()

	local function controllerAction(_: string, p, p2)
		if p ~= Enum.UserInputState.End or p2.UserInputType ~= Enum.UserInputType.Gamepad1 then
			return Enum.ContextActionResult.Pass
		end

		local GuiService = game:GetService("GuiService")
		GuiService.SelectedObject = close
		return Enum.ContextActionResult.Sink
	end

	local ContextActionService = game:GetService("ContextActionService")
	ContextActionService:BindActionAtPriority("HiddenAbilitiesEscape", controllerAction, false, 4, Enum.KeyCode.ButtonB)
	maid2:Add(function()
		local ContextActionService2 = game:GetService("ContextActionService")
		ContextActionService2:UnbindAction("HiddenAbilitiesEscape")
	end)
	maid2:Add(close.MouseButton1Click:Connect(function()
		if v8 == "Experiments" then
			displayAbilities(assert(v9))
		elseif v8 == "Abilities" then
			displayFruitList()
		else
			HiddenAbilitiesWindow:Close()
		end
	end))
end

local thread = nil

function HiddenAbilitiesWindow:Open()
	if maid then
		maid:Destroy()
	end

	maid = Trove.new()
	assert(maid)

	if thread then
		task.cancel(thread)
		thread = nil
	end

	Util._open = true
	maid:Add(function()
		Util._clientInfo = nil
		Util._open = false
		v8 = nil
		v9 = nil
		v4 = nil
		flag = nil
		maid = nil
		thread = task.delay(5, function()
			thread = nil

			for _, list in pairs({ v6, v7, v5 }) do
				for i = #list, 1, -1 do
					if maid then
						break
					end

					local v11 = list[i]
					table.remove(list, i)
					v11.Visible = false
					v11:Destroy()
					task.wait(0.25)
				end

				if maid then
					break
				end
			end
		end)
	end)
	maid:Add(PlayerDataUtil.waitForDataFolderReady(localPlayer, function(instance)
		local devilFruit = instance:WaitForChild("DevilFruit", 7)

		if maid and devilFruit and devilFruit:IsA("StringValue") then
			value = devilFruit.Value
			maid:Add(devilFruit:GetPropertyChangedSignal("Value"):Connect(function()
				fn((`DevilFruit changed:{devilFruit.Value}`))
				HiddenAbilitiesWindow:Open()
			end))
			setup()

			if maid then
				maid:Add(remoteEvent.OnClientEvent:Connect(function(p)
					if p.Context == "Update" then
						if not hiddenAbilities.Enabled then
							return
						end

						Util._clientInfo = nil

						if v8 == "Fruits" then
							displayFruitList()
						elseif v8 == "Abilities" then
							displayAbilities(assert(v9))
						elseif v8 == "Experiments" then
							displayExperiments(assert(v4), assert(v9))
						end
					end
				end))
			end
		end

		v(true)
		hiddenAbilities.Enabled = true
	end))
end

function HiddenAbilitiesWindow:Close()
	if maid then
		maid:Destroy()
	end

	hiddenAbilities.Enabled = false
	v(false)
end

function HiddenAbilitiesWindow._prewarm(_)
	Util.getClientInfo(function() end, true)
end

function HiddenAbilitiesWindow.WaitForClose(_)
	local bindableEvent

	if maid then
		bindableEvent = Instance.new("BindableEvent")
		maid:Add(function()
			bindableEvent:Fire()
			bindableEvent:Destroy()
		end)
	else
		bindableEvent = nil
	end

	if bindableEvent then
		bindableEvent.Event:Wait()
	end
end

function HiddenAbilitiesWindow.OnStart(_)
	local v10 = false

	local function init()
		assert(v10 == false)
		v10 = true
		hiddenAbilities = localPlayer:WaitForChild("PlayerGui"):WaitForChild("HiddenAbilities")
		local StarsAndQuote = require(game.ReplicatedStorage.Controllers.UI.HiddenAbilitiesWindow.StarsAndQuote)
		v = StarsAndQuote(hiddenAbilities)
		modal = hiddenAbilities.Modal
		close = modal.Title.Close
		assert(close:IsA("TextButton"))
		fruitView = modal.FruitView
		abilityView = modal.AbilityView
		researchView = modal.ResearchView
		fruitView.Visible = false
		abilityView.Visible = false
		researchView.Visible = false
		close.Visible = true
		HiddenAbilitiesWindow:Close()
		local RunService = game:GetService("RunService")

		if RunService:IsStudio() then
			local TextChatService = game:GetService("TextChatService")
			TextChatService.SendingMessage:Connect(function(p)
				local text = p.Text

				if text == "/open" then
					if hiddenAbilities.Enabled then
						return
					end

					HiddenAbilitiesWindow:Open()
				elseif text == "/cut" then
					AdminPanel.playCutscene()
				end
			end)
		end
	end

	if localPlayer.Team then
		task.spawn(init)
	else
		localPlayer:GetPropertyChangedSignal("Team"):Once(init)
	end
end

return HiddenAbilitiesWindow