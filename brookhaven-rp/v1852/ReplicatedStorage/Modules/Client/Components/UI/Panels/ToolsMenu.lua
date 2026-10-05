local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoadableToolEntriesFilter = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableToolEntriesFilter)
local ExclusionController = require(ReplicatedStorage.Modules.Client.Exclusion.ExclusionController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local ExclusionConfig = require(ReplicatedStorage.Modules.Shared.DB.Exclusion.ExclusionConfig)
local ToolsConfig = require(ReplicatedStorage.Modules.Shared.DB.Tools.ToolsConfig)
local InteractableItem = require(ReplicatedStorage.Modules.Shared.Item.InteractableItem)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local RequirementBehaviors = require(ReplicatedStorage.Modules.Shared.RequirementBehaviors)
local PlayerToolsUtil = require(ReplicatedStorage.Modules.Shared.Tools.PlayerToolsUtil)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local clearTools = LegacyGame8Settings.ClearTools
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Component = require(ReplicatedStorage.Packages.Component)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PlayerLocalizationController = require(ReplicatedStorage.Modules.Client.Player.PlayerLocalizationController)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local EventItem = require(ReplicatedStorage.Modules.Shared.Item.Items.EventItem)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "ToolsMenu"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(clearTools.OnClientEvent:Connect(function(p2)
		if p2 == "AllGreenChecksOff" then
			local descendants = instance.Catalog.Container:GetDescendants()

			for _, descendant in descendants do
				if descendant.Name == "GreenCheckMark" then
					descendant.Visible = false
				end
			end
		end
	end))
	self._Janitor:Add(clearTools.OnClientEvent:Connect(function(p2, p3)
		if p2 == "TurnOnGreenCheckMark" then
			for _, descendant in instance.Catalog.Container:GetDescendants(), nil, nil do
				if not (descendant:isA("ImageButton") and descendant.Name == p3 and descendant:FindFirstChild("GreenCheckMark")) then
					continue
				end

				descendant.GreenCheckMark.Visible = true
			end
		end
	end))
	self._Janitor:Add(clearTools.OnClientEvent:Connect(function(p2, p3)
		if p2 == "TurnOffGreenCheckMark" then
			for _, descendant in instance.Catalog.Container:GetDescendants(), nil, nil do
				if not (descendant:isA("ImageButton") and descendant.Name == p3 and descendant:FindFirstChild("GreenCheckMark")) then
					continue
				end

				descendant.GreenCheckMark.Visible = false
			end
		end
	end))
	local maid = Janitor.new()
	local thread = nil
	local buttons = {}
	local v2 = false

	local function autoEquipTool(name: string)
		if not Platform.IsConsole() and name ~= "PropMaker" then
			return
		end

		local v3 = true
		local v4, v5 = ABTest.GetExperimentVariable("console-controls", "enabled"):timeout(7):await()

		if v4 and typeof(v5) == "boolean" then
			v3 = v5
		end

		if not v3 then
			return
		end

		task.spawn(function()
			local localPlayer = Players.LocalPlayer
			local character = localPlayer.Character

			if character == nil then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid == nil then
				return
			end

			local backpack = localPlayer:FindFirstChildOfClass("Backpack")

			if backpack == nil then
				return
			end

			local tool = backpack:WaitForChild(name, 3)

			if tool ~= nil and tool:IsA("Tool") then
				humanoid:EquipTool(tool)
			end
		end)
	end

	local function ToolButtonAdded(button)
		if button:IsA("ImageButton") then
			if button:GetAttribute("AttachedConnection") ~= nil then
				return
			end

			button:SetAttribute("AttachedConnection", true)
			local v3 = ToolsConfig.GetConfig()[button.Name]
			local v4 = false

			if v3 and v3.RequirementBehaviorData then
				local passesRequirementCheck = RequirementBehaviors.PassesRequirementCheck(
					Players.LocalPlayer,
					v3.RequirementBehaviorData.Behavior,
					unpack(v3.RequirementBehaviorData.Arguments)
				)

				if passesRequirementCheck then
					v4 = true
				elseif not passesRequirementCheck and (v3.HiddenUnlessUnlocked or not RequirementBehaviors.IsVisible(
					Players.LocalPlayer,
					v3.RequirementBehaviorData.Behavior,
					unpack(v3.RequirementBehaviorData.Arguments)
				)) then
					button.Visible = false
				end
			end

			if v3 and v3.HideIfNoItems and v3.IsCategory then
				local v5 = false

				for _, v7 in ToolsConfig.GetConfig() do
					if v7.Category ~= v3.Name then
						continue
					end

					if v7.RequirementBehaviorData then
						if RequirementBehaviors.PassesRequirementCheck(
							Players.LocalPlayer,
							v7.RequirementBehaviorData.Behavior,
							unpack(v7.RequirementBehaviorData.Arguments)
						) then
							v5 = true
							break
						end
					elseif v7.Item ~= nil then
						local item = ItemRegistry.GetItem(v7.Item, EventItem)

						if item and item:IsUnlockedClient() then
							v5 = true
							break
						end
					end
				end

				if not v5 then
					button.Visible = false
				end
			end

			if thread then
				table.insert(buttons, button)
			else
				thread = task.defer(function()
					local playerTool = PlayerToolsUtil.GetPlayerToolByDictionary(game.Players.LocalPlayer)
					local currentEquippedGunSkins = PlayerToolsUtil.GetCurrentEquippedGunSkinsByDictionary(game.Players.LocalPlayer)

					if button and button.Parent and playerTool[button.Name] then
						button.GreenCheckMark.Visible = true
					end

					if button and button.Parent and currentEquippedGunSkins[button.Name] then
						button.GreenCheckMark.Visible = true
					end

					for _, v5 in buttons do
						if v5 and v5.Parent and playerTool[v5.Name] then
							v5.GreenCheckMark.Visible = true
						end

						if v5 and v5.Parent and currentEquippedGunSkins[v5.Name] then
							v5.GreenCheckMark.Visible = true
						end
					end

					buttons = {}
					thread = nil
				end)
			end

			maid:Add(button.MouseButton1Click:Connect(function()
				local name = button.Name

				if v2 == false and name ~= "ClearTools" then
					TelemetryController.SendClientInteraction("filterClick", {
						filter = button.Parent:GetAttribute("CurrentFilter"),
						itemType = button.Parent:GetAttribute("ItemType"),
						name = button.Name
					})
					v2 = true
					task.delay(0.4, function()
						v2 = false
					end)

					local function equipTool()
						local gunSkin = v3 and v3.GunSkin or name
						local group = ExclusionConfig.GetGroupById(gunSkin)

						if group and ExclusionController.IsGroupExcluded(group) then
							local exclusionMessage = ExclusionController.GetExclusionMessage("You are not allowed to use this tool here.")
							NotificationController.Notify(exclusionMessage)
						elseif v3.IsCategory then
							ComponentUtil.GetComponentFromInstance(
								instance.Catalog.Container.ScrollingFrame,
								LoadableToolEntriesFilter
							):SetCategory(v3.Name)

							if v3.CategoryDisclaimer and (not v3.USOnlyDisclaimer or PlayerLocalizationController.GetCountryRegion() == "US") then
								instance.Catalog.Container.Disclaimer.Visible = true
								instance.Catalog.Container.Disclaimer.DisclaimerText.Text = v3.CategoryDisclaimer
							end
						elseif v3.GunSkin then
							local greenCheckMark = button:WaitForChild("GreenCheckMark")
							local success, result = pcall(function()
								local visible = Remotes.invokeServer("GunEquip", v3.GunSkin, v3.Name)

								if visible ~= nil then
									greenCheckMark.Visible = visible
								end
							end)

							if not success then
								warn(result)
							end
						elseif v4 or GamepassController.IsOwned(Gamepasses.PREMIUM) then
							local pickingTools = LegacyGame8Settings.PickingTools
							local v5 = LegacyGame8Settings.Tools:InvokeServer(pickingTools, name)
							local greenCheckMark = button:WaitForChild("GreenCheckMark")

							if v5 ~= true then
								greenCheckMark.Visible = false
								return
							end

							greenCheckMark.Visible = true
							autoEquipTool(name)
						elseif not button:FindFirstChild("Silver") then
							local pickingTools = LegacyGame8Settings.PickingTools
							local v5 = LegacyGame8Settings.Tools:InvokeServer(pickingTools, name)
							local greenCheckMark = button:WaitForChild("GreenCheckMark")

							if v5 == true then
								greenCheckMark.Visible = true
								autoEquipTool(name)
							else
								greenCheckMark.Visible = false
							end
						end
					end

					if v3 and v3.Item then
						local item = ItemRegistry.GetItem(v3.Item, InteractableItem)

						if not item then
							warn("Could not created Interactable Item, entry not found in CMS: ", v3.Item)
							return
						end

						if item:IsUnlockedClient() then
							v4 = true
						else
							item:OnDenied(function(text)
								local toolDeniedPopup = instance.Catalog.Header.ToolDeniedPopup
								toolDeniedPopup.Label.Text = text
								toolDeniedPopup.Visible = true
								task.wait(string.len(text) * 0.075)
								toolDeniedPopup.Visible = false
							end, "ToolsMenu", function()
								if button.Parent == nil or not self.Instance.Visible then
									return
								end

								equipTool()
							end)
							return
						end
					elseif v3 and v3.RequirementBehaviorData and not RequirementBehaviors.PassesRequirementCheck(
						Players.LocalPlayer,
						v3.RequirementBehaviorData.Behavior,
						unpack(v3.RequirementBehaviorData.Arguments)
					) then
						local deniedMessage = RequirementBehaviors.GetDeniedMessage(
							Players.LocalPlayer,
							v3.RequirementBehaviorData.Behavior,
							unpack(v3.RequirementBehaviorData.Arguments)
						)
						local toolDeniedPopup = instance.Catalog.Header.ToolDeniedPopup
						toolDeniedPopup.Label.Text = deniedMessage
						toolDeniedPopup.Visible = true
						task.wait(string.len(deniedMessage) * 0.075)
						toolDeniedPopup.Visible = false
						return
					end

					equipTool()
				end
			end))
		end
	end

	instance.Catalog.Header.CategoryTabs.BackButton.MouseButton1Click:Connect(function()
		ComponentUtil.GetComponentFromInstance(instance.Catalog.Container.ScrollingFrame, LoadableToolEntriesFilter):SetCategory(nil)
	end)

	for _, button in instance.Catalog.Header.CategoryTabs:GetChildren() do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.SelectionOrder = 2000
		end
	end

	local component = ComponentUtil.GetComponentFromInstance(
		instance.Catalog.Container.ScrollingFrame,
		LoadableToolEntriesFilter
	)
	local backButton = instance.Catalog.Header.CategoryTabs.BackButton
	local v3 = nil

	local function unbindBackAction()
		if not v3 then
			return
		end

		v3()
		v3 = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bindBackAction()
		if v3 then
			return
		end

		v3 = BackActionRouter.Bind(function()
			component:SetCategory(nil)
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateBackActionBinding()
		if instance.Visible and backButton.Visible then
			bindBackAction() -- equivalent call inferred; original call site unknown
		else
			if not v3 then
				return
			end

			v3()
			v3 = nil
		end
	end

	self._Janitor:Add(unbindBackAction)
	self._Janitor:Add(component.Loaded:Connect(function()
		for _, child in instance.Catalog.Container.ScrollingFrame:GetChildren() do
			ToolButtonAdded(child)
		end

		maid:Add(instance.Catalog.Container.ScrollingFrame.ChildAdded:Connect(ToolButtonAdded))
	end))

	if component:IsLoaded() then
		for _, child in instance.Catalog.Container.ScrollingFrame:GetChildren() do
			child:SetAttribute("AttachedConnection", nil)
			ToolButtonAdded(child)
		end

		maid:Add(instance.Catalog.Container.ScrollingFrame.ChildAdded:Connect(ToolButtonAdded))
	end

	self._Janitor:Add(component.Added:Connect(function(items)
		for _, item in items do
			ToolButtonAdded(item)
		end
	end))
	self._Janitor:Add(component.Unloaded:Connect(function()
		maid:Cleanup()

		for _, child in instance.Catalog.Container.ScrollingFrame:GetChildren() do
			child:SetAttribute("AttachedConnection", nil)
		end
	end))
	self._Janitor:Add(component.CategoryChanged:Connect(function(p2)
		instance.Catalog.Header.CategoryTabs.BackButton.Visible = p2 ~= nil
		updateBackActionBinding() -- equivalent call inferred; original call site unknown
		local v4 = ToolsConfig.GetConfig()[p2]

		if not v4 or not v4.CategoryDisclaimer or v4.USOnlyDisclaimer and PlayerLocalizationController.GetCountryRegion() ~= "US" then
			instance.Catalog.Container.Disclaimer.Visible = false
			return
		end

		instance.Catalog.Container.Disclaimer.Visible = true
		instance.Catalog.Container.Disclaimer.DisclaimerText.Text = v4.CategoryDisclaimer
	end))
	self._Janitor:Add(instance:GetPropertyChangedSignal("Visible"):Connect(function()
		updateBackActionBinding() -- equivalent call inferred; original call site unknown
		instance.Catalog.Container.ScrollingFrame.CanvasPosition = Vector2.new(0, 0)
	end))

	if instance.Visible and backButton.Visible then
		if not v3 then
			v3 = BackActionRouter.Bind(function()
				component:SetCategory(nil)
			end)
		end
	elseif v3 then
		v3()
		v3 = nil
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v