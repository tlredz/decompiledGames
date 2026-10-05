local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
local v5 = require3(ReplicatedStorage2.Shared.UiPresets)
local v6 = require3(ReplicatedStorage2.Controllers.SettingsController)
local v7 = require3(ReplicatedStorage2.Controllers.EmoteController)
local v8 = require3(ReplicatedStorage2.ServerInfo)
local v9 = require3(localPlayer.PlayerScripts:WaitForChild("Client"):WaitForChild("DeviceChecker"))
require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v10 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v11 = require3(ReplicatedStorage2.Shared.ItemInfo)
local v12 = require3(ReplicatedStorage2.Shared.Statable)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
require3(ReplicatedStorage2.Packages.Freeze)
local v13 = require3(ReplicatedStorage2.Shared.DeleteItemUtils)
local v14 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v15 = require3(ReplicatedStorage2.Controllers.DeleteItemPromptController)
local v16 = require3(ReplicatedStorage2.Controllers.UI.SpectateController)
require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v17 = require3(ReplicatedStorage2.Controllers.Trading.InventoryController)
require3(ReplicatedStorage2.Packages.Trove)
local state = v12.State("")
local state2 = v12.State("Default")
local state3 = v12.State("Most")
local spring = v3.Spring
local remoteEvent = v2:RemoteEvent("RequestFavoriteItem")
local changeEmotes = ReplicatedStorage2.Remotes.ChangeEmotes
local emotes = ReplicatedStorage2.Misc.Emotes
local emoteWheel = localPlayer.PlayerGui.EmoteWheel
local wheel = emoteWheel.Wheel
local center = wheel.Center
local text = center.Text
local pointer = center.Pointer
local highlighted = wheel.Highlighted
local holder = wheel.Holder
local list = emoteWheel.List
local searchFrame = list:WaitForChild("SearchFrame")
local content = list.Content
local TEMPLATE = content.UIGridLayout.TEMPLATE
local menu = emoteWheel.Menu
local content2 = menu.Content
local v18 = {}
local v19 = {}
local EmoteWheelController = {}

function EmoteWheelController:updatePage()
	wheel.Pages.Page.Text = `{EmoteWheelController.page}/{5}`
	EmoteWheelController:UpdateHolderEmotes()
	EmoteWheelController:UpdateMenuContentEmotes()
	EmoteWheelController:updateCenterText()
end

function EmoteWheelController.Init(_)
	EmoteWheelController.type = v9:IsMobile() and "Menu" or "Wheel"
	EmoteWheelController.thumbstickDelta = Vector2.new()
	EmoteWheelController.selected = 1
	EmoteWheelController.page = 1
	EmoteWheelController.selectedFrame = EmoteWheelController.type == "Wheel" and holder["1"] or content2["1"]
	EmoteWheelController.editing = false
end

function EmoteWheelController:updateCenterText()
	if EmoteWheelController.type ~= "Wheel" then
		return
	end

	local emoteName = EmoteWheelController.selectedFrame:GetAttribute("EmoteName") or ""
	local text2 = text

	if EmoteWheelController.editing then
		emoteName = "Replacing: " .. emoteName or emoteName
	end

	text2.Text = emoteName
end

function EmoteWheelController:populateEmoteList()
	local function doSearchAction()
		content.CanvasPosition = Vector2.zero
		state:Set(searchFrame.SearchBG.SearchInput.Text)
	end

	v17:CreateSortOptions(searchFrame.Sort, state2, state3)
	searchFrame.Search.MouseButton1Click:Connect(doSearchAction)
	searchFrame.SearchBG.SearchInput.FocusLost:Connect(doSearchAction)
	v4.Client:WaitReplion("Data")
	v17:CreateInventory({
		InventoryType = "Emote",
		ItemTemplate = TEMPLATE,
		Container = content,
		SearchFilter = state,
		SortOption = state2,
		SortOrder = state3,
		ChangeNameStroke = false,
		UseFavorites = v12.State(true),
		OnSlotCreated = function(p, p2, itemKey: string, data, maid)
			local favoriteState = v17:GetFavoriteState(p, p2.Name)
			data.Delete.Visible = v13.IsDeleteable(localPlayer, "Emote", p2)
			maid:Add(v12.Computed(function(callback)
				data.Favorite.Image = callback(favoriteState) and "rbxassetid://15697987058" or "rbxassetid://15697983062"
			end))
			maid:Add(v5.animateButtonHover(data))
			maid:Add(v5.animateButtonClick(data))
			maid:Add(data.Activated:Connect(function()
				changeEmotes:FireServer(
					tonumber(EmoteWheelController.selected) + (EmoteWheelController.page - 1) * 8,
					client:FindItemsWithKey("Emote", itemKey)[1]
				)
			end))
			maid:Add(data.Favorite.Activated:Connect(function()
				remoteEvent:FireServer("Emote", client:FindItemsWithKey("Emote", itemKey)[1])
			end))
			maid:Add(data.Delete.Activated:Connect(function()
				local isDeleteable, v20 = v13.IsDeleteable(localPlayer, "Emote", p2)

				if isDeleteable then
					local v21 = v11.Emote[p2.Name]
					local displayName = v21 and v21.DisplayName or p2.Name
					local formatted = `x1 {displayName}`
					local promptType

					if #client:FindItemsWithKey("Emote", itemKey) > 1 then
						formatted = displayName
						promptType = "Selector"
					else
						promptType = "Single"
					end

					v15:PromptConfirmation({
						PromptType = promptType,
						Description = `Are you sure you want to delete {formatted}? This cannot be undone.`,
						InventoryType = "Emote",
						ItemKey = itemKey
					}, function(p4, p5: string?)
						if p4 then
							return
						end

						if p5 then
							v14:SendNotification(p5)
						end
					end)
				elseif v20 then
					v14:SendNotification(v20)
				end
			end))
		end
	})
end

function EmoteWheelController:ShowSelectedItemsInPage(filterCallback)
	for k, v20 in v18 do
		v20.Visible = filterCallback(v19[k])
	end

	self.FilterCallback = filterCallback
end

function EmoteWheelController.ShowAllItemsInPage(_)
	EmoteWheelController:ShowSelectedItemsInPage(function()
		return true
	end)
end

function EmoteWheelController.ProcessSearch(_, value: string)
	local v20 = value:lower():gsub("\n", "")
	EmoteWheelController:ShowSelectedItemsInPage(function(p)
		local displayName = (p.DisplayName or p.Name):lower()
		return displayName:find(v20) or displayName == v20
	end)
end

function EmoteWheelController:handleList()
	v5.animateButtonHover(list.Close)
	v5.animateButtonClick(list.Close)
	list.Close.Activated:Connect(function()
		EmoteWheelController.editing = false
		EmoteWheelController:updateCenterText()
		list.Visible = false
		content.Visible = false
		spring.stop(wheel)
		spring.target(wheel, 1, 5, {
			Position = wheel:GetAttribute("WheelPosition")
		})
	end)
end

function EmoteWheelController:handleWheelInteractions()
	if EmoteWheelController.type ~= "Wheel" then
		return
	end

	v5.animateButtonHover(wheel.Edit)
	v5.animateButtonClick(wheel.Edit)
	wheel.Edit.Activated:Connect(function()
		EmoteWheelController.editing = true
		EmoteWheelController:updateCenterText()
		list.Visible = true
		content.Visible = true
		spring.target(EmoteWheelController.selectedFrame.Scale, 1, 5, {
			Scale = 1
		})
		spring.stop(wheel)
		spring.target(wheel, 1, 5, {
			Position = UDim2.fromScale(0.5, 0.5)
		})
	end)
	wheel.Edit.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		EmoteWheelController.editing = true
		EmoteWheelController:updateCenterText()
		list.Visible = true
		content.Visible = true
		spring.target(EmoteWheelController.selectedFrame.Scale, 1, 5, {
			Scale = 1
		})
		spring.stop(wheel)
		spring.target(wheel, 1, 5, {
			Position = UDim2.fromScale(0.5, 0.5)
		})
	end)
	v5.animateButtonHover(wheel.Close)
	v5.animateButtonClick(wheel.Close)
	wheel.Close.Activated:Connect(function()
		EmoteWheelController.editing = false
		EmoteWheelController:updateCenterText()
		list.Visible = false
		content.Visible = false
		EmoteWheelController:close()
		spring.stop(wheel)
		spring.target(wheel, 1, 5, {
			Position = wheel:GetAttribute("WheelPosition")
		})
	end)
end

function EmoteWheelController:UpdateHolderEmotes()
	v4.Client:WaitReplion("Data")
	local equippedList = client:GetEquippedList("Emote")

	for i = 1, 8 do
		local v20 = equippedList[i + (EmoteWheelController.page - 1) * 8]
		local v21 = holder[tostring(i)]

		if v20 and emotes[v20.Name] then
			local emote = emotes[v20.Name]
			v21.Image = emote:GetAttribute("Icon") or ""
			v21:SetAttribute("EmoteId", v20.Name)
			v21:SetAttribute("EmoteName", emote:GetAttribute("EmoteName"))
		else
			v21.Image = "rbxassetid://0"
			v21:SetAttribute("EmoteId", nil)
			v21:SetAttribute("EmoteName", nil)
		end
	end
end

function EmoteWheelController:UpdateMenuContentEmotes()
	v4.Client:WaitReplion("Data")
	local equippedList = client:GetEquippedList("Emote")

	for i = 1, 24 do
		local v20 = equippedList[i]
		local v21 = content2[tostring(i)]
		local child = v20 and emotes:FindFirstChild(v20.Name)

		if child then
			v21.Vector.Image = child:GetAttribute("Icon") or ""
			v21.Title.Text = child:GetAttribute("EmoteName")
			v21:SetAttribute("EmoteId", v20.Name)
			v21:SetAttribute("EmoteName", child:GetAttribute("EmoteName"))
		else
			v21.Vector.Image = ""
			v21.Title.Text = ""
			v21:SetAttribute("EmoteId", nil)
			v21:SetAttribute("EmoteName", nil)
		end
	end
end

function EmoteWheelController:handleWheelLoadout()
	if EmoteWheelController.type ~= "Wheel" then
		return
	end

	v4.Client:AwaitReplion("Data", function(_)
		EmoteWheelController:UpdateHolderEmotes()
		client:OnEquip("Emote", function()
			EmoteWheelController:UpdateHolderEmotes()
			EmoteWheelController:updateCenterText()
		end)
	end)
end

function EmoteWheelController:select(p: number)
	if EmoteWheelController.type ~= "Wheel" then
		return
	end

	local selected = p % 8 == 0 and 8 or p % 8

	if EmoteWheelController.selected == selected then
		return
	end

	spring.stop(highlighted)
	highlighted.Rotation = EmoteWheelController.selected * 45 - 90
	spring.stop(EmoteWheelController.selectedFrame)
	spring.target(EmoteWheelController.selectedFrame.Scale, 0.6, 6, {
		Scale = 1.5
	})
	local v21 = selected * 45 - 90
	local v22 = v21 < 0 and v21 + 360 or -(360 - v21)
	task.defer(function()
		spring.target(highlighted, 0.6, 6, {
			Rotation = math.abs(v21 - highlighted.Rotation) < math.abs(v22 - highlighted.Rotation) and v21 or v22
		})
	end)
	EmoteWheelController.selected = selected
	EmoteWheelController.selectedFrame = holder:FindFirstChild((tostring(selected)))
	spring.stop(EmoteWheelController.selectedFrame)
	spring.target(EmoteWheelController.selectedFrame.Scale, 0.6, 6, {
		Scale = 1.575
	})
	EmoteWheelController:updateCenterText()
end

function EmoteWheelController:registerRotation()
	if EmoteWheelController.type ~= "Wheel" then
		return
	end

	RunService:BindToRenderStep("EMOTE_WHEEL_PICKER", 1, function()
		if EmoteWheelController.editing or not wheel.Visible then
			return
		end

		local thumbstickDelta = EmoteWheelController.thumbstickDelta.Magnitude > 0.5 and EmoteWheelController.thumbstickDelta or v:GetMouseLocation() - emoteWheel.AbsoluteSize / 2

		if thumbstickDelta.Magnitude < 15 then
			return
		end

		local rotation = math.deg(math.atan2(thumbstickDelta.Y, thumbstickDelta.X) + 1.5707963267948966)
		pointer.Rotation = rotation
		EmoteWheelController:select((math.round((rotation + 90) / 45)))
	end)

	local function onInput(p, p2)
		if not wheel.Visible or p2 then
			return
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			local v20 = v:GetMouseLocation() - emoteWheel.AbsoluteSize / 2

			if p.UserInputType == Enum.UserInputType.Touch then
				v20 += Vector2.new(0, 36)
			end

			local rotation = math.deg(math.atan2(v20.Y, v20.X) + 1.5707963267948966)
			pointer.Rotation = rotation
			EmoteWheelController:select((math.round((rotation + 90) / 45)))
			self:close(true)
		elseif p.UserInputType.Name:find("Gamepad") then
			self:close(true)
		end
	end

	v.InputBegan:Connect(onInput)
	wheel.InputBegan:Connect(onInput)
	wheel.Holder.InputBegan:Connect(onInput)

	for _, child in ipairs(wheel.Holder:GetChildren()) do
		child.InputBegan:Connect(onInput)
	end
end

function EmoteWheelController:handleMenu()
	if EmoteWheelController.type == "Wheel" then
		return
	end

	local function changeSelection(selectedFrame)
		spring.stop(EmoteWheelController.selectedFrame)
		spring.target(EmoteWheelController.selectedFrame, 0.6, 6, {
			BackgroundTransparency = 1
		})
		EmoteWheelController.selected = tonumber(selectedFrame.Name)
		EmoteWheelController.selectedFrame = selectedFrame
		spring.stop(EmoteWheelController.selectedFrame)
		spring.target(EmoteWheelController.selectedFrame, 0.6, 6, {
			BackgroundTransparency = 0.8
		})
	end

	for _, button in ipairs(content2:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local selectedFrame = button
		button.Activated:Connect(function()
			changeSelection(selectedFrame)

			if EmoteWheelController.editing then
				return
			end

			v7:Play(selectedFrame:GetAttribute("EmoteId"), tonumber(selectedFrame.Name) or 0)
			EmoteWheelController:close()
		end)
		local selectedFrame2 = button
		button.TouchLongPress:Connect(function()
			changeSelection(selectedFrame2)
			EmoteWheelController.editing = true
			list.Visible = true
			content.Visible = true
		end)
		button.LayoutOrder = tonumber(button.Name) or 0
	end

	v5.animateButtonHover(menu.Close)
	v5.animateButtonClick(menu.Close)
	menu.Close.Activated:Connect(function()
		list.Visible = false
		content.Visible = false
		EmoteWheelController.editing = false
		EmoteWheelController:close()
	end)
	v5.animateButtonHover(menu.Edit)
	v5.animateButtonClick(menu.Edit)
	menu.Edit.Activated:Connect(function()
		EmoteWheelController.editing = true
		list.Visible = true
		content.Visible = true
	end)
	v5.animateButtonHover(menu.Auto)
	v5.animateButtonClick(menu.Auto)
	v4.Client:AwaitReplion("Data", function(_)
		menu.Auto.Activated:Connect(function()
			list.Visible = false
			content.Visible = false
			EmoteWheelController.editing = false
			EmoteWheelController:close()
			local equippedList = client:GetEquippedList("Emote")
			local v20

			if #equippedList >= 1 then
				v20 = math.random(1, #equippedList)
			else
				v20 = false
			end

			v7:Play(not v20 and "Emote1" or equippedList[v20].Name or "Emote1", v20)
		end)
		EmoteWheelController:UpdateMenuContentEmotes()
		client:OnEquip("Emote", function()
			EmoteWheelController:UpdateMenuContentEmotes()
		end)
	end)
end

function EmoteWheelController.open(_)
	if v8.isTestGame() and not RunService:IsStudio() then
		print("Request open wheel")
	end

	if v8.isAFKServer() or v8.isRhythmServer() or localPlayer.PlayerGui.ParryTutorialUI.Enabled then
		return
	end

	if EmoteWheelController.type ~= "Wheel" then
		menu.Visible = true
		return
	end

	wheel.Visible = true
	v16:SetVisibility(false)
	v.MouseBehavior = Enum.MouseBehavior.LockCenter
	task.spawn(function()
		task.wait()
		v.MouseBehavior = Enum.MouseBehavior.Default
	end)
end

function EmoteWheelController:close(p)
	if v8.isTestGame() and not RunService:IsStudio() then
		print("Request close wheel")
	end

	if EmoteWheelController.editing then
		return
	end

	if EmoteWheelController.type == "Wheel" then
		wheel.Visible = false
		v16:SetVisibility(true)
		local emoteId = p and EmoteWheelController.selectedFrame:GetAttribute("EmoteId")

		if emoteId then
			v7:Play(emoteId, tonumber(EmoteWheelController.selected) + (EmoteWheelController.page - 1) * 8)
		end
	elseif not p then
		menu.Visible = false
	end
end

function EmoteWheelController:listenToBinds()
	if EmoteWheelController.type ~= "Wheel" then
		return
	end

	local v20 = nil
	local v21 = nil

	local function UpdateBinds()
		local binds = v6:GetBinds("Emote")

		if not binds then
			return
		end

		debug.profilebegin("Get binds")
		local isType = v6:IsType(binds.Bind1)
		local isType2 = v6:IsType(binds.Bind2)
		debug.profileend()

		if isType == v20 and isType2 == v21 then
			return
		end

		debug.profilebegin("Update binds")
		ContextActionService:UnbindAction("EMOTE_WHEEL")
		ContextActionService:BindActionAtPriority("EMOTE_WHEEL", function(_, p)
			if p == Enum.UserInputState.Cancel then
				return Enum.ContextActionResult.Pass
			end

			EmoteWheelController[p == Enum.UserInputState.Begin and "open" or "close"](EmoteWheelController, true)
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, isType, isType2)
		v20 = isType
		v21 = isType2
		debug.profileend()
	end

	v4.Client:AwaitReplion("Data", function(object)
		UpdateBinds()
		object:OnChange("Settings.Keybinds", UpdateBinds)
		v.LastInputTypeChanged:Connect(UpdateBinds)
	end)
	ContextActionService:UnbindAction("EMOTE_WHEEL_SCROLL")
	ContextActionService:BindActionAtPriority("EMOTE_WHEEL_SCROLL", function(_, p, p2)
		if p == Enum.UserInputState.Cancel or (not wheel.Visible or v10._currentGui) then
			return Enum.ContextActionResult.Pass
		end

		local v22 = -math.round(p2.Position.Z)

		if v22 > 0 then
			EmoteWheelController.page = EmoteWheelController.page % 5 + v22
		else
			EmoteWheelController.page = EmoteWheelController.page <= 1 and 5 or EmoteWheelController.page + v22
		end

		EmoteWheelController:updatePage()
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseWheel)
end

function EmoteWheelController.Start(_)
	EmoteWheelController:registerRotation()
	task.spawn(function()
		EmoteWheelController:populateEmoteList()
	end)
	EmoteWheelController:handleWheelLoadout()
	EmoteWheelController:handleWheelInteractions()
	EmoteWheelController:handleList()
	EmoteWheelController:handleMenu()
	EmoteWheelController:close()
	EmoteWheelController:listenToBinds()

	local function setListPosition()
		list.Position = EmoteWheelController.type == "Wheel" and (v:GetLastInputType() == Enum.UserInputType.Touch and UDim2.fromScale(
			0.075,
			0.506
		) or UDim2.fromScale(0.7, 0.506)) or UDim2.fromScale(0.5, 0.506)
	end

	setListPosition()
	v.LastInputTypeChanged:Connect(function(p)
		if p == Enum.UserInputType.Touch then
			wheel:SetAttribute("WheelPosition", UDim2.fromScale(0.25, 0.5))
		else
			wheel:SetAttribute("WheelPosition", UDim2.fromScale(0.5, 0.5))
		end

		if not wheel.Visible then
			wheel.Position = wheel:GetAttribute("WheelPosition")
		end

		setListPosition()
	end)

	if v:GetLastInputType() == Enum.UserInputType.Touch then
		wheel:SetAttribute("WheelPosition", UDim2.fromScale(0.25, 0.5))
	else
		wheel:SetAttribute("WheelPosition", UDim2.fromScale(0.5, 0.5))
	end

	wheel.Position = wheel:GetAttribute("WheelPosition")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function nextPage()
		EmoteWheelController.page = EmoteWheelController.page % 5 + 1
		EmoteWheelController:updatePage()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function previousPage()
		EmoteWheelController.page = EmoteWheelController.page <= 1 and 5 or EmoteWheelController.page - 1
		EmoteWheelController:updatePage()
	end

	wheel.Pages.Next.Activated:Connect(nextPage)
	wheel.Pages.Previous.Activated:Connect(previousPage)
	v.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		debug.profilebegin("get keycode")
		local _ = input.KeyCode
		debug.profileend()

		if input.KeyCode == Enum.KeyCode.ButtonR1 then
			nextPage() -- equivalent call inferred; original call site unknown
		elseif input.KeyCode == Enum.KeyCode.ButtonL1 then
			previousPage() -- equivalent call inferred; original call site unknown
		end
	end)
	EmoteWheelController:updatePage()
end

return EmoteWheelController