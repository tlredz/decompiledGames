local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local PlayerTitleService = require(ReplicatedStorage.Engine.Service.PlayerTitleService)
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
return {
	new = function(instance)
		local v = instance:WaitForChild("下拉按钮")
		local v2 = instance:WaitForChild("当前头衔")
		local parent = instance:WaitForChild("头衔列表")
		local v4 = parent:WaitForChild("头衔选项模板")
		local backgroundColor3 = v4.BackgroundColor3
		local backgroundColor32 = backgroundColor3

		for _, button in parent:GetChildren() do
			if not (button ~= v4 and button:IsA("GuiButton")) then
				continue
			end

			if button:GetAttribute("IsSelected") == false then
				backgroundColor32 = button.BackgroundColor3
			end

			button:Destroy()
		end

		v4.Visible = false
		local v5 = parent.Size.Y.Scale / 5
		local v6 = false
		local v7 = ""
		local flag = false
		local v8 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isPointerInput(p)
			return p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch
		end

		local function markPointerInside(p)
			if isPointerInput(p) then
				v8 = true
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyCurrent(p)
			if p then
				v2.Text = PlayerTitleService.getText(p)
				v2.TextColor3 = PlayerTitleService.getColor(p)
			else
				v2.Text = PlayerTitleService.NO_TITLE_TEXT
				v2.TextColor3 = PlayerTitleService.NO_TITLE_COLOR
			end
		end

		local function clearOptions()
			for _, child in parent:GetChildren() do
				if child:GetAttribute("PlayerTitleGeneratedOption") then
					child:Destroy()
				end
			end
		end

		local fn

		local function buildOptions(ownedList, p: string)
			clearOptions()
			local clone = table.clone(ownedList)
			table.insert(clone, false)
			local count = #clone
			parent.Size = UDim2.new(parent.Size.X.Scale, parent.Size.X.Offset, v5 * count, 0)

			for k, v9 in clone do
				local v10 = not v9 and "" or v9.cnId
				local clone2 = v4:Clone()
				clone2.Name = "头衔选项" .. k
				clone2.LayoutOrder = k
				clone2.Size = UDim2.new(1, 0, 1 / count, 0)
				clone2:SetAttribute("PlayerTitleGeneratedOption", true)
				local v11 = v10 == p
				clone2:SetAttribute("IsSelected", v11)
				local backgroundColor

				if v11 then
					backgroundColor = backgroundColor3
				else
					backgroundColor = backgroundColor32
				end

				clone2.BackgroundColor3 = backgroundColor
				clone2.Selectable = true
				local v13 = clone2:WaitForChild("头衔名称")

				if v9 then
					v13.Text = PlayerTitleService.getText(v9)
					v13.TextColor3 = PlayerTitleService.getColor(v9)
				else
					v13.Text = PlayerTitleService.NO_TITLE_TEXT
					v13.TextColor3 = PlayerTitleService.NO_TITLE_COLOR
				end

				local waitForChild = clone2:WaitForChild("分隔线")
				waitForChild.Visible = k < count
				clone2.Visible = true
				clone2.InputBegan:Connect(markPointerInside)
				ButtonActions.Bind(clone2, function()
					if not GamepadSupport.CanActivate(clone2) then
						return
					end

					if v10 ~= client.equippedTitle() then
						PlayerTitleService.client.equip(v10)
					end

					fn()
				end)
				clone2.Parent = parent
			end
		end

		fn = function()
			flag = false
			parent.Visible = false
			v.Text = "▼"
			clearOptions()
			local selectedObject = GuiService.SelectedObject

			if selectedObject and selectedObject:IsDescendantOf(parent) then
				local v9 = GuiService
				local selectedObject2

				if v.Visible and instance.Visible then
					selectedObject2 = v
				end

				v9.SelectedObject = selectedObject2
			end
		end

		local function render()
			if v6 then
				local titles = client.titles()
				local ownedList = PlayerTitleService.getOwnedList(titles)
				instance.Visible = #ownedList > 0
				v.Visible = true
				local equippedTitle = client.equippedTitle()
				local v9

				if titles[equippedTitle] then
					v9 = PlayerTitleService.getConfig(equippedTitle)
				end

				applyCurrent(v9) -- equivalent call inferred; original call site unknown

				if #ownedList == 0 then
					fn()
				elseif flag then
					buildOptions(ownedList, not v9 and "" or equippedTitle)
				end
			else
				local config = PlayerTitleService.getConfig(v7)
				instance.Visible = config ~= nil
				v.Visible = false
				applyCurrent(config) -- equivalent call inferred; original call site unknown
				fn()
			end
		end

		local function expand()
			if not v6 then
				return
			end

			local titles = client.titles()
			local ownedList = PlayerTitleService.getOwnedList(titles)

			if #ownedList == 0 then
				return
			end

			flag = true
			v8 = false
			parent.Visible = true
			v.Text = "▲"
			local equippedTitle = client.equippedTitle()
			buildOptions(
				ownedList,
				not (titles[equippedTitle] and PlayerTitleService.getConfig(equippedTitle)) and "" or equippedTitle
			)
		end

		v.Selectable = true
		ButtonActions.Bind(v, function()
			if not GamepadSupport.CanActivate(v) then
				return
			end

			if flag then
				fn()
			else
				expand()
			end
		end)
		v.InputBegan:Connect(markPointerInside)
		parent.InputBegan:Connect(markPointerInside)
		UserInputService.InputBegan:Connect(function(input)
			if not flag or input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			task.delay(0, function()
				if not v8 then
					fn()
				end

				v8 = false
			end)
		end)
		client.titles.Changed(function()
			if v6 then
				render()
			end
		end)
		client.equippedTitle.Changed(function()
			if v6 then
				render()
			end
		end)
		parent.Visible = false
		instance.Visible = false
		return {
			setViewed = function(p: number?, value: string?)
				v6 = p == Players.LocalPlayer.UserId
				v7 = typeof(value) ~= "string" and "" or value
				flag = false

				if p == nil then
					fn()
				else
					render()
				end
			end,
			collapse = fn
		}
	end
}