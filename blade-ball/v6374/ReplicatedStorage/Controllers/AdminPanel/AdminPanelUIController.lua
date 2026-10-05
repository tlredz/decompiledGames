local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v2 = require3(ReplicatedStorage2.Shared.AdminPanel)
local v3 = require3(ReplicatedStorage2.Shared.Statable)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
local v5 = require3(ReplicatedStorage2.Packages.Freeze)
local v6 = require3(ReplicatedStorage2.Shared.DynArgs)
local v7 = require3(ReplicatedStorage2.Shared.Action)
local v8 = require3(ReplicatedStorage2.Packages.Trove)
local v9 = require3(ReplicatedStorage2.Common.Utils)
local v10 = require3(ReplicatedStorage2.Shared.AdminPanel.AdminPanelUtils)
local localPlayer = Players.LocalPlayer
local adminPanel = localPlayer.PlayerGui:WaitForChild("AdminPanel")
local window = adminPanel.Window
local content = window.Content
local userInfo = window.UserInfo
local AdminPanelUIController = {
	_currentUserId = nil,
	AdminPanelUI = adminPanel,
	FullscreenToggle = v3.State(false),
	CurrentPage = v3.State("Home"),
	Transition = v6.Or(),
	ViewTrove = v8.new(),
	UserTrove = v8.new()
}
AdminPanelUIController.Transition:LinkState(v3.State())
AdminPanelUIController.IsBigScreen = v3.Computed(function(callback)
	local v11 = callback((v3.getPropertyState(workspace, "CurrentCamera")))

	if not v11 then
		return true
	end

	local v12 = callback((v3.getPropertyState(v11, "ViewportSize")))
	return v12.X >= 800 and v12.Y >= 500
end)
AdminPanelUIController.Fullscreen = v3.Computed(function(callback)
	return callback(AdminPanelUIController.FullscreenToggle) or not callback(AdminPanelUIController.IsBigScreen)
end)
AdminPanelUIController.LoadUserAction = v7.new(function(p)
	AdminPanelUIController._currentUserId = p.UserId
	AdminPanelUIController.Transition:SetTag("LoadUser", true)
	adminPanel.Enabled = true
	local serverTimeNow = workspace:GetServerTimeNow()
	window.LastUpdated.Text = "Last Updated: just now"
	AdminPanelUIController.UserTrove:Add(v9.Thread.Every(1, function()
		window.LastUpdated.Text = `Last Updated: {v9.ValueConvertor:FormatTimeWithDays(workspace:GetServerTimeNow() - serverTimeNow)}`
	end))
	return p
end)

function AdminPanelUIController:LoadUser(p: number)
	if not self:HasPermission("Session.Create") then
		return
	end

	window.LastUpdated.Text = "Updating now..."
	AdminPanelUIController.Transition:SetTag("RequestLoadUser", true)
	self.CurrentPage:Set("Home")
	xpcall(function()
		v2.Actions.LoadUser.Server:Call(p)
	end, function(p2)
		warn(debug.traceback(p2, 2))
	end)
	AdminPanelUIController.Transition:SetTag("RequestLoadUser", false)
end

local v11 = nil

function AdminPanelUIController:GetPermissions()
	if not v11 then
		v11 = v2.Actions.GetPermissions:Call()
	end

	return v11
end

function AdminPanelUIController:HasPermission(p: string)
	local permissions = self:GetPermissions()
	return table.find(permissions, p) ~= nil or table.find(permissions, "*") ~= nil
end

local v12 = {}
local v13 = true

function AdminPanelUIController:UpdateCoreGui()
	local v14 = not (self.Fullscreen:Get() and adminPanel.Enabled)

	if v14 and not v13 then
		for _, v15 in v12 do
			StarterGui:SetCoreGuiEnabled(v15, true)
		end

		table.clear(v12)
		v13 = true
	elseif not v14 and v13 then
		for _, v15 in Enum.CoreGuiType:GetEnumItems() do
			if StarterGui:GetCoreGuiEnabled(v15) then
				table.insert(v12, v15)
			end
		end

		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
		v13 = false
	end
end

local v14 = {}

function AdminPanelUIController.RegisterRefreshAction(p: string, callback)
	if v14[p] then
		warn("Action already registered, overwriting")
	end

	v14[p] = callback
end

function AdminPanelUIController:PromptError(text: string)
	local clone = window.Errors.UIListLayout.ErrorLabel:Clone()
	clone.Text = text
	clone.Parent = window.Errors
	task.delay(5, function()
		clone:Destroy()
	end)
end

function AdminPanelUIController:Start()
	for _, frame in content.Pages:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v15 = frame
		v3.setPropertyComputed(frame, "Visible", function(callback)
			return callback(self.CurrentPage):match("Home%.(.+)$") == v15.Name
		end)
	end

	v3.setPropertyComputed(content.HomeSection, "Visible", function(callback)
		return callback(self.CurrentPage) == "Home"
	end)
	window.TopHeader.PendingChanges.Activated:Connect(function()
		self.CurrentPage:Set("Home.PendingChanges")
	end)
	window.TopHeader.Filter.Visible = false
	local maid = v8.new()
	v3.Computed(function(callback)
		maid:Clean()
		local parts = callback(self.CurrentPage):split(".")

		for k, part in parts do
			local v15 = maid:Add(content.CurrentPage.UIListLayout.Section:Clone())
			v15.LayoutOrder = k * 2 - 1
			v15.Text = part
			v15.Parent = content.CurrentPage
			local v16 = k
			maid:Add(v15.Activated:Connect(function()
				self.CurrentPage:Set(table.concat(parts, ".", 1, v16))
			end))
		end

		for i = 2, #parts do
			local v15 = maid:Add(content.CurrentPage.UIListLayout.Separator:Clone())
			v15.LayoutOrder = i * 2 - 2
			v15.Parent = content.CurrentPage
		end

		return nil
	end)

	for _, button in content.HomeSection.Categories:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		button.Visible = self:HasPermission(button.Name)
		local v15 = button
		button.Activated:Connect(function()
			self.CurrentPage:Set((`Home.{v15.Name}`))
		end)
	end

	userInfo.Refresh.Activated:Connect(function()
		local v16 = v14[self.CurrentPage:Get()]

		if v16 then
			self.Transition:SetTag("RefreshPage", true)
			v16()
			self.Transition:SetTag("RefreshPage", false)
		end
	end)
	v3.setPropertyState(window.Transition, "Visible", self.Transition.State)

	local function doSave()
		self.Transition:SetTag("Save", true)
		local v15, v16 = xpcall(function()
			local v17, v18 = v2.Actions.Save:Call()

			if not v17 then
				error(v18 or "No output.")
			end
		end, warn)

		if not v15 then
			self:PromptError(v16)
		end

		self.Transition:SetTag("Save", false)
	end

	window.TopHeader.Save.Activated:Connect(doSave)
	self.LoadUserAction.Signal:Connect(function(p)
		local replion = p.Replion

		local function updateSaveVisibility()
			local v15 = v10.calculateDeltaTables(replion:Get("Data"), replion:Get("InitialData"), v5.None) or v10.calculateDeltaTables(
				replion:Get("Inventory"),
				replion:Get("InitialInventory"),
				v5.None
			)
			window.TopHeader.Save.Visible = v15 ~= nil
		end

		self.UserTrove:Add(replion:OnChange("Data", updateSaveVisibility))
		self.UserTrove:Add(replion:OnChange("Inventory", updateSaveVisibility))
		self.UserTrove:Add(replion:OnChange("InitialData", updateSaveVisibility))
		self.UserTrove:Add(replion:OnChange("InitialInventory", updateSaveVisibility))
		self.UserTrove:Add(task.spawn(updateSaveVisibility))
	end)
	adminPanel:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not adminPanel.Enabled then
			self.ViewTrove:Clean()
			v2.Actions.CloseSession:Call()
		end

		self:UpdateCoreGui()
	end)
	self.LoadUserAction.Signal:Connect(function()
		self.Transition:SetTag("LoadUser", false)
	end)
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 2
	v3.Computed(function(callback)
		local v15 = callback(self.Fullscreen)
		adminPanel.ClipToDeviceSafeArea = not v15
		local v16 = adminPanel
		local screenInsets

		if v15 then
			screenInsets = Enum.ScreenInsets.None
		else
			screenInsets = Enum.ScreenInsets.CoreUISafeInsets
		end

		v16.ScreenInsets = screenInsets
		local uIPadding = window.UIPadding
		local paddingTop

		if v15 then
			paddingTop = UDim.new(0, 40)
		else
			paddingTop = UDim.new()
		end

		uIPadding.PaddingTop = paddingTop
		local uICorner = window.UICorner
		local cornerRadius

		if v15 then
			cornerRadius = UDim.new()
		else
			cornerRadius = UDim.new(0, 8)
		end

		uICorner.CornerRadius = cornerRadius
		local v20 = window
		local size

		if v15 then
			size = UDim2.fromScale(1, 1)
		else
			size = UDim2.fromScale(0.75, 0.75)
		end

		v20.Size = size
		local v22 = uIAspectRatioConstraint
		local parent

		if not v15 then
			parent = window
		end

		v22.Parent = parent

		if adminPanel.Enabled then
			self:UpdateCoreGui()
		end

		return nil
	end)
	v2.Actions.LoadUser.Client:Listen(function(p, p2)
		self.ViewTrove:Add(self.UserTrove)
		self.UserTrove:Clean()
		self.UserTrove:Add(task.spawn(function()
			local replion = v4.Client:WaitReplion(p.SessionId)
			self.LoadUserAction:Call(v5.Dictionary.merge(p, {
				Replion = replion
			}))

			if p2 then
				self.CurrentPage:Set(p2)
			end
		end))
	end)

	local function temporaryText(textBox, text: string)
		textBox.Active = false
		textBox.TextEditable = false
		textBox.Text = text
		task.wait(1.5)
		textBox.Text = ""
		textBox.Active = true
		textBox.TextEditable = true
	end

	local function doSearch()
		local text = window.TopHeader.SearchUser.TextBox.Text
		local _ = localPlayer.UserId
		local userIdFromNameAsync = nil

		if text and text ~= "" and text ~= " " then
			local v15 = string.sub(text, 1, 1) == "@"
			local v16

			if not v15 then
				v16 = tonumber(text)
			end

			if v15 then
				text = string.sub(text, 2)
			end

			if v16 then
				if v16 <= 0 and not RunService:IsStudio() then
					return temporaryText(window.TopHeader.SearchUser.TextBox, "Invalid UserId")
				else
					userIdFromNameAsync = v16
				end
			else
				local success, _ = pcall(function()
					userIdFromNameAsync = Players:GetUserIdFromNameAsync(text)
				end)

				if not success then
					return temporaryText(window.TopHeader.SearchUser.TextBox, "Failed to fetch UserId, try again later")
				end
			end
		else
			userIdFromNameAsync = localPlayer.UserId
		end

		if not userIdFromNameAsync then
			return temporaryText(window.TopHeader.SearchUser.TextBox, "Invalid UserId [2]")
		end

		self:LoadUser(userIdFromNameAsync)
	end

	window.TopHeader.SearchUser.TextBox.FocusLost:Connect(function(flag: boolean)
		if not flag then
			return
		end

		doSearch()
	end)
	window.TopHeader.SearchUser.SearchUserIcon.Activated:Connect(doSearch)
	v.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.F8 and v:IsKeyDown(Enum.KeyCode.LeftControl) and not adminPanel.Enabled then
			self:LoadUser(localPlayer.UserId)
		end
	end)
	window.Close.Activated:Connect(function()
		adminPanel.Enabled = false
	end)
	v3.setPropertyState(window.Resize, "Visible", AdminPanelUIController.IsBigScreen)
	v3.setPropertyComputed(window.Resize, "Image", function(callback)
		if callback(AdminPanelUIController.FullscreenToggle) then
			return "rbxassetid://74501503561915"
		end

		return "rbxassetid://118821585117657"
	end)
	window.Resize.Activated:Connect(function()
		AdminPanelUIController.FullscreenToggle:Set(not AdminPanelUIController.FullscreenToggle:Get())
	end)
end

return AdminPanelUIController