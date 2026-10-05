local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("RunService")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local DuelsMachineController = require(ReplicatedStorage.Controllers.DuelsMachineController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local Settings = require(ReplicatedStorage.Shared.Settings)
local Index = require(ReplicatedStorage.Shared.Index)
local BaseSkins = require(ReplicatedStorage.Shared.BaseSkins)
local BaseSkinsFlags = require(ReplicatedStorage.Shared.Flags.BaseSkinsFlags)
local Updates = require(ReplicatedStorage.Shared.Updates)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Index2 = require(ReplicatedStorage.Datas.Index)
local MutationText = require(ReplicatedStorage.Shared.MutationText)
local remoteFunction = Net:RemoteFunction("SettingsService/ToggleSetting")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v = TopbarPlus.new():setImage(110481567543062, "Selected"):setImage(78403024093069, "Deselected"):setOrder(1)
local v2 = nil
local settings = playerGui:WaitForChild("Settings").Settings
local scrollingFrame = settings.Content.ScrollingFrame
local template = scrollingFrame.Template
local templateBaseSkin = scrollingFrame.TemplateBaseSkin
local close = settings.Header.Close
local maid = Trove.new()

local function GetMutationNames()
	local result = { "Normal" }

	for k, _ in Index2 do
		table.insert(result, k)
	end

	return result
end

local function resolveColor(p)
	if typeof(p) == "table" then
		return p.Color
	end

	return p
end

local function ConstructSettings(items)
	local v3 = Synchronizer:Get(localPlayer)
	maid:Clean()

	for k, item in items do
		if not Settings[k] then
			continue
		end

		local order = Settings[k].Order

		if k == "Base Skin" then
			local clone = maid:Clone(templateBaseSkin)
			clone.Name = "Base Skin"
			clone.Function.Text = "Base Skin"
			clone.Button.DropDown.AnchorPoint = Vector2.new(0.5, 0)
			clone.Button.DropDown.Position = UDim2.fromScale(0.5, 1.2)
			clone.Button.DropDown.Size = UDim2.fromScale(1.221, 0)
			clone.Button.DropDown.AutomaticSize = Enum.AutomaticSize.Y
			local clones = {}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function calculateCanvasSize(absoluteSize)
				local Y = scrollingFrame.UIListLayout.AbsoluteContentSize.Y
				local v6 = not clone.Button.DropDown.Visible and 0 or (#clones + 1) * ((absoluteSize or clone.Button.AbsoluteSize).Y + 8)
				return UDim2.fromOffset(0, Y + v6)
			end

			local v6 = { "Normal" }
			local v7 = {}

			for k2, _ in Index2 do
				table.insert(v6, k2)
			end

			for _, name in v6 do
				if name == item then
					continue
				end

				local v9 = Index2[name]
				local disableAutomaticSkin = Index2[name] and Index2[name].DisableAutomaticSkin
				local v10

				if v3 then
					v10 = BaseSkins.Owns(v3, name) or false
				else
					v10 = false
				end

				if name == "Normal" then
					v10 = true
				elseif not BaseSkins.IsInventoryManaged(name) and Index:IsComplete(localPlayer, name) then
					v10 = not disableAutomaticSkin or v10
				end

				if not (v10 or v9.ShowInSettings ~= false) then
					continue
				end

				local v11

				if name == "1 OF 1" then
					v11 = clone.Button.DropDown.Template1OF1
				else
					v11 = clone.Button.DropDown.Template
				end

				local clone2 = maid:Clone(v11)
				table.insert(clones, clone2)
				clone2.Name = name
				MutationText.apply(clone2.Text, name, "Settings")
				clone2.Locked.Visible = not v10

				if name ~= "1 OF 1" then
					clone2.BackgroundColor3 = name ~= "Normal" and v9.MainColor or Color3.new(
						0.490196,
						0.435294,
						0.435294
					)
					local uIStroke = clone2.UIStroke
					local color

					if name == "Normal" then
						color = Color3.new(0.490196, 0.435294, 0.435294)
					else
						if v9.Palettes then
							color = v9.Palettes[1][2]

							if typeof(color) == "table" then
								color = color.Color
							end
						else
							color = v9.MainColor
						end

						if not color then
							color = Color3.new(0.490196, 0.435294, 0.435294)
						end
					end

					uIStroke.Color = color
					local uIStroke2 = clone2.Text.UIStroke
					local color2

					if name == "Normal" then
						color2 = Color3.new(0.490196, 0.435294, 0.435294)
					else
						if v9.Palettes then
							color2 = v9.Palettes[1][2]

							if typeof(color2) == "table" then
								color2 = color2.Color
							end
						else
							color2 = v9.MainColor
						end

						if not color2 then
							color2 = Color3.new(0.490196, 0.435294, 0.435294)
						end
					end

					uIStroke2.Color = color2
				end

				if v10 then
					local v12 = AnimatedButton.new(clone2)
					maid:Add(v12)
					v12:Animate()
					local v13 = clone
					local v14 = clones
					local v15 = k
					local v16 = name
					maid:Add(v12.OnActivated:Connect(function()
						scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
						local dropDown = v13.Button.DropDown

						if dropDown.Visible then
							dropDown.Visible = not dropDown.Visible
							v13.Button.Polygon.Rotation = dropDown.Visible and 180 or 0
							scrollingFrame.CanvasSize = calculateCanvasSize()
							scrollingFrame.CanvasPosition = dropDown.Visible and Vector2.new(
								0,
								scrollingFrame.AbsoluteCanvasSize.Y - scrollingFrame.AbsoluteSize.Y
							) or Vector2.new(0, 0)
						end

						local v17, v18 = remoteFunction:InvokeServer(v15, v16)

						if not v17 then
							NotificationController:Error(v18)
							SoundController:PlaySound("Sounds.Sfx.Error")
						end
					end))
					table.insert(v7, v12)
				end

				clone2.LayoutOrder = name == "Normal" and 1 or Index2[name].Order or 1
				clone2.Visible = true
				clone2.Parent = clone.Button.DropDown
			end

			local v8 = clone
			local v9 = clones

			local function updateScaling()
				local absoluteSize = v8.Button.AbsoluteSize
				local uDim = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)

				for k2, v11 in v9 do
					v11.Size = uDim
				end

				for k2, v11 in v7 do
					v11.DefaultSize = uDim
				end

				scrollingFrame.CanvasSize = calculateCanvasSize(absoluteSize)
			end

			maid:Add(clone.Button:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScaling))
			maid:Add(clone.Button.DropDown:GetPropertyChangedSignal("Visible"):Connect(updateScaling))
			maid:Add(task.spawn(updateScaling))
			local v11 = Index2[item]
			local button = clone.Button
			MutationText.apply(button.Text, item, "Settings")

			if item == "1 OF 1" then
				local template1OF1 = button.DropDown.Template1OF1
				button.BackgroundColor3 = template1OF1.BackgroundColor3
				button.UIStroke.Color = template1OF1.UIStroke.Color
				button.Text.UIStroke.Color = template1OF1.Text.UIStroke.Color
				local clone_2 = maid:Clone(template1OF1.StarburstContainer)
				clone_2.Parent = button
			else
				button.BackgroundColor3 = (item ~= "Normal" and v11 and true or false) and v11.MainColor or Color3.new(
					0.490196,
					0.435294,
					0.435294
				)
				local uIStroke = button.UIStroke
				local color

				if item == "Normal" or not v11 then
					color = Color3.new(0.490196, 0.435294, 0.435294)
				else
					if v11.Palettes then
						color = v11.Palettes[1][1]

						if typeof(color) == "table" then
							color = color.Color
						end
					else
						color = v11.MainColor
					end

					if not color then
						color = Color3.new(0.490196, 0.435294, 0.435294)
					end
				end

				uIStroke.Color = color
			end

			local v12 = AnimatedButton.new(button)
			maid:Add(v12)
			local v14 = clone
			local v15 = clones
			maid:Add(v12.OnActivated:Connect(function()
				local dropDown = button.DropDown
				dropDown.Visible = not dropDown.Visible
				button.Polygon.Rotation = dropDown.Visible and 180 or 0
				scrollingFrame.CanvasSize = calculateCanvasSize()
				scrollingFrame.CanvasPosition = dropDown.Visible and Vector2.new(
					0,
					scrollingFrame.AbsoluteCanvasSize.Y - scrollingFrame.AbsoluteSize.Y
				) or Vector2.new(0, 0)
			end))
			clone.LayoutOrder = order
			clone.Visible = true
			clone.Parent = scrollingFrame
		elseif k == "Receive Duels from" then
			local clone = maid:Clone(template)
			clone.Name = "Receive Duels from"
			clone.Function.Text = "Receive Duels from"
			local color

			if item == "Everyone" then
				color = Color3.fromRGB(12, 119, 60)
			elseif item == "Friends" then
				color = Color3.fromRGB(255, 149, 0)
			else
				color = Color3.fromRGB(245, 56, 56)
			end

			local color2

			if item == "Everyone" then
				color2 = Color3.fromRGB(2, 56, 0)
			elseif item == "Friends" then
				color2 = Color3.fromRGB(190, 111, 0)
			else
				color2 = Color3.fromRGB(177, 0, 0)
			end

			local button = clone.Buttons.Button
			button.Text.Text = item
			button.BackgroundColor3 = color
			button.UIStroke.Color = color2
			button.Text.UIStroke.Color = color2
			local v4 = AnimatedButton.new(button)
			maid:Add(v4)
			v4:Animate()
			local v5 = item
			local v6 = "Receive Duels from"
			maid:Add(v4.OnActivated:Connect(function()
				local v7, v8 = remoteFunction:InvokeServer(
					v6,
					v5 == "Everyone" and "Friends" or v5 == "Friends" and "No one" or "Everyone"
				)

				if not v7 then
					NotificationController:Error(v8)
					SoundController:PlaySound("Sounds.Sfx.Error")
				end
			end))
			local v7 = "Receive Duels from" ~= "Receive Duels from" or DuelsMachineController:IsEnabled()
			clone.LayoutOrder = order
			clone.Visible = not ServerData.IsNewPlayersServer() and v7
			clone.Parent = scrollingFrame
		elseif k ~= "Receive Gifts from" and k ~= "Only Receive Trades With" and k ~= "Receive Trades from" then
			local clone = maid:Clone(template)
			clone.Name = k
			clone.Function.Text = k
			local button = clone.Buttons.Button
			button.Text.Text = item and "On" or "Off"
			button.BackgroundColor3 = item and Color3.new(0.0470588, 0.466667, 0.235294) or Color3.new(
				0.490196,
				0.435294,
				0.435294
			)
			button.UIStroke.Color = item and Color3.new(0.00784314, 0.219608, 0) or Color3.new(
				0.403922,
				0.356863,
				0.356863
			)
			button.Text.UIStroke.Color = item and Color3.new(0.00784314, 0.219608, 0) or Color3.new(
				0.403922,
				0.356863,
				0.356863
			)
			local v4 = AnimatedButton.new(button)
			maid:Add(v4)
			v4:Animate()
			local v5 = k
			maid:Add(v4.OnActivated:Connect(function()
				local v6, v7 = remoteFunction:InvokeServer(v5)

				if not v6 then
					NotificationController:Error(v7)
					SoundController:PlaySound("Sounds.Sfx.Error")
				end
			end))
			local visible = k ~= "Mobile Shift Lock" or UserInputService.PreferredInput == Enum.PreferredInput.Touch
			clone.LayoutOrder = order
			clone.Visible = visible
			clone.Parent = scrollingFrame
		end
	end
end

return {
	Start = function(_)
		local flag = nil
		v2 = InterfaceController:Register("Settings", settings, "TopQuint")
		v2:AttachCloseButton(close)
		v2:Close()
		v.selected:Connect(function()
			InterfaceController:SetState("Settings", true)
		end)
		v.deselected:Connect(function()
			InterfaceController:SetState("Settings", false)
		end)
		Synchronizer:WaitAndCall(localPlayer, function(object)
			-- equivalent calls inferred from this helper; original call sites unknown
			local function tryConstruct()
				if v2:IsOpened() then
					task.spawn(ConstructSettings, object:Get("Settings"))
				else
					flag = true
				end
			end

			UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
				tryConstruct() -- equivalent call inferred; original call site unknown
			end)
			v2.OnOpen:Connect(function()
				if flag then
					task.spawn(ConstructSettings, object:Get("Settings"))
					flag = nil
				end

				v:select()
			end)
			v2.OnClose:Connect(function()
				v:deselect()
			end)
			local settings2 = object:Get("Settings")
			object:OnDictionaryInserted("UnlockedBaseSkins", function()
				tryConstruct() -- equivalent call inferred; original call site unknown
			end)
			object:OnDictionaryRemoved("UnlockedBaseSkins", function()
				tryConstruct() -- equivalent call inferred; original call site unknown
			end)
			object:OnDictionaryInserted("BaseSkinInventory", function()
				tryConstruct() -- equivalent call inferred; original call site unknown
			end)
			object:OnDictionaryRemoved("BaseSkinInventory", function()
				tryConstruct() -- equivalent call inferred; original call site unknown
			end)
			Updates.OnUpdateEnabled:Connect(function()
				tryConstruct() -- equivalent call inferred; original call site unknown
			end)
			Updates.OnUpdateDisabled:Connect(function()
				tryConstruct() -- equivalent call inferred; original call site unknown
			end)

			for k, _ in settings2 do
				object:OnChanged(`Settings.{k}`, function(_: boolean)
					tryConstruct() -- equivalent call inferred; original call site unknown
				end)
			end

			local isCompletes = {}
			local v3 = {
				"Strawberry",
				"Meowl",
				"Skibidi",
				"Headless"
			}
			object:OnChanged("AnimalAddedOrRemoved", function()
				local flag2 = false

				for _, v4 in v3 do
					local isComplete = Index:IsComplete(localPlayer, v4)

					if isCompletes[v4] == isComplete then
						continue
					end

					isCompletes[v4] = isComplete
					flag2 = true
				end

				if flag2 then
					tryConstruct() -- equivalent call inferred; original call site unknown
				end
			end)
			localPlayer:GetAttributeChangedSignal("HasOneOfOneBrainrot"):Connect(tryConstruct)
			BaseSkinsFlags.OneOfOneEnabled.Changed:Connect(tryConstruct)
			tryConstruct() -- equivalent call inferred; original call site unknown
		end)
	end
}