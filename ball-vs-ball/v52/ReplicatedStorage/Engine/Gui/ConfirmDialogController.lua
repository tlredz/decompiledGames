local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
local GamepadPages = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ButtonHints = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonHints)
local ConfirmDialogController = {}
local flag = false
local v = nil
local framesByName = {}
local sizesByFrame = {}
local v2 = {}
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local tweenInfo3 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local v3 = nil
local count = 0
local count2 = 0
local v4 = {}
local v5 = {}
local selectedObject = nil

function ConfirmDialogController:BindButton(p: string?, callback)
	local v6 = v5[self]

	if v6 then
		v6.connection:Disconnect()
	end

	self.Selectable = true
	ButtonHints.Ensure(self, p)
	local connection = ButtonActions.Bind(self, function()
		if not (v3 and v.Visible) then
			return
		end

		local v8 = framesByName[v3.panelName]

		if v8 and self:IsDescendantOf(v8) then
			callback()
		end
	end)
	v5[self] = {
		connection = connection
	}
	return connection
end

function ConfirmDialogController.HandleGamepadInput(p, flag2: boolean)
	if not flag2 then
		GamepadPages.HandleInput("", Enum.UserInputState.Begin, p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideAllPanels()
	for _, v6 in framesByName do
		v6.Visible = false
	end
end

local function canShow(p)
	return not (p.category and v4[p.category])
end

local function showNext()
	if v3 or not flag then
		return
	end

	while #v2 > 0 do
		local v6 = table.remove(v2, 1)

		if v6.category and v4[v6.category] then
			table.insert(v2, v6)
			return
		end

		local v7 = framesByName[v6.panelName]

		if v7 then
			count += 1
			hideAllPanels() -- equivalent call inferred; original call site unknown
			v.Visible = true
			v.BackgroundTransparency = 1
			v7.Visible = true
			v7.Size = UDim2.new(0, 0, 0, 0)
			TweenService:Create(v, tweenInfo3, {
				BackgroundTransparency = 0.5
			}):Play()
			TweenService:Create(v7, tweenInfo, {
				Size = sizesByFrame[v7] or v7.Size
			}):Play()

			if not selectedObject then
				selectedObject = GuiService.SelectedObject
			end

			GuiService.SelectedObject = nil
			v3 = v6

			if v6.onShown then
				local v8 = v6
				v6.onShown(v7, function()
					ConfirmDialogController.Complete(v8.id)
				end)
			end

			return
		else
			warn(("[ConfirmDialogController] 缺少面板: %s"):format(v6.panelName))
		end
	end

	v.Visible = false
end

function ConfirmDialogController.Init()
	if flag then
		return
	end

	local v6 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("通用确认框")
	v = v6:WaitForChild("背景")

	for _, frame in v:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		framesByName[frame.Name] = frame
		GamepadPages.Observe(frame)
		sizesByFrame[frame] = frame.Size
		frame.Visible = false
	end

	v.Visible = false
	flag = true
	GamepadSupport.WatchRoot(v6)
end

function ConfirmDialogController.Enqueue(panelName: string, data)
	ConfirmDialogController.Init()
	count2 += 1
	local v6 = {
		id = count2,
		panelName = panelName,
		category = data and data.category,
		priority = not data and 0 or data.priority or 0,
		onShown = data and data.onShown,
		onHidden = data and data.onHidden
	}
	local v7 = false

	for k, v9 in v2 do
		if not (v6.priority > v9.priority) then
			continue
		end

		table.insert(v2, k, v6)
		v7 = true
		break
	end

	if not v7 then
		table.insert(v2, v6)
	end

	showNext()
	return v6.id
end

function ConfirmDialogController.Show(p: string, p2)
	ConfirmDialogController.Init()

	if v3 and v3.onHidden then
		v3.onHidden()
	end

	v3 = nil
	hideAllPanels() -- equivalent call inferred; original call site unknown
	v.Visible = false
	local v6 = ConfirmDialogController.Enqueue(p, p2)

	if not v3 or v3.id == v6 then
		return v6
	end

	for k, v7 in v2 do
		if v7.id ~= v6 then
			continue
		end

		table.remove(v2, k)
		table.insert(v2, 1, v7)
		break
	end

	showNext()
	return v6
end

local function closeActive()
	if not v3 then
		showNext()
		return
	end

	local v6 = v3
	local v7 = framesByName[v6.panelName]
	count += 1
	local v8 = count
	v3 = nil

	if v6.onHidden then
		v6.onHidden()
	end

	if v7 then
		TweenService:Create(v, tweenInfo4, {
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(v7, tweenInfo2, {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		task.delay(tweenInfo2.Time, function()
			if v8 ~= count then
				return
			end

			v7.Visible = false
			v7.Size = sizesByFrame[v7] or v7.Size
			v.Visible = false
			showNext()

			if not v3 then
				if selectedObject and selectedObject.Parent and GamepadSupport.CanActivate(selectedObject) then
					GuiService.SelectedObject = selectedObject
				end

				selectedObject = nil
			end
		end)
	else
		hideAllPanels() -- equivalent call inferred; original call site unknown
		v.Visible = false
		showNext()
	end
end

function ConfirmDialogController.Complete(p: number)
	if v3 and v3.id == p then
		closeActive()
	end
end

function ConfirmDialogController.Cancel(p: number)
	if v3 and v3.id == p then
		closeActive()
		return
	end

	for k, v6 in v2 do
		if v6.id ~= p then
			continue
		end

		table.remove(v2, k)

		if v6.onHidden then
			v6.onHidden()
		end

		break
	end
end

function ConfirmDialogController.Hide()
	closeActive()
end

function ConfirmDialogController.SetCategorySuppressed(p: string, flag2: boolean)
	v4[p] = flag2

	if v3 and v3.category == p and flag2 then
		hideAllPanels() -- equivalent call inferred; original call site unknown
		v.Visible = false
	elseif not flag2 then
		showNext()
	end
end

function ConfirmDialogController.TweenBackground(backgroundTransparency: number, p2)
	ConfirmDialogController.Init()
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(v, p2, {
		BackgroundTransparency = backgroundTransparency
	}):Play()
end

function ConfirmDialogController.ShowMessage(text: string, p)
	local v6 = not p and {} or table.clone(p)
	local onShown = v6.onShown

	function v6.onShown(instance, p2)
		local waitForChild = instance:WaitForChild("文本")
		waitForChild.Text = text
		ConfirmDialogController.BindButton(instance:WaitForChild("确定按钮"), "A", p2)

		if onShown then
			onShown(instance, p2)
		end
	end

	return ConfirmDialogController.Show("通用提示面板", v6)
end

return ConfirmDialogController