local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local Permissions = require(ReplicatedStorage.Modules.Shared.Permissions)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "DevProfilingUI"
})
local color = Color3.fromRGB(0, 153, 255)
local color2 = Color3.fromRGB(56, 56, 56)
local color3 = Color3.fromRGB(255, 87, 87)
local color4 = Color3.fromRGB(255, 255, 255)

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleProfilingUI()
	if PanelController.IsOpen("PerformanceUI", "DevProfilingUI") then
		PanelController.Close("PerformanceUI", "DevProfilingUI")
	else
		PanelController.OpenPanelByContext("PerformanceUI", "DevProfilingUI")
	end
end

local function getNumberFromString(value: string?)
	if not value then
		return nil
	end

	local v2 = tonumber(value)

	if v2 then
		return v2
	end

	local v3 = tonumber(string.match(value, "^[%d%.]+"))
	local v4 = string.match(value, "%a+$")

	if v4 == "s" then
		return v3
	elseif v4 == "m" then
		return v3 * 60
	elseif v4 == "h" then
		return v3 * 3600
	end

	return nil
end

local function formatRemainingTime(p: number)
	local v2 = math.max(0, (math.ceil(p)))

	if v2 >= 3600 then
		return string.format("%dh %dm", math.floor(v2 / 3600), (math.floor(v2 % 3600 / 60)))
	end

	if v2 >= 60 then
		return string.format("%dm %ds", math.floor(v2 / 60), v2 % 60)
	end

	return string.format("%ds", v2)
end

function v:Construct()
	if not Permissions.hasAdminAccess(Players.LocalPlayer) then
		self.Instance:Destroy()
		return
	end

	self._Janitor = Janitor.new()
	self._profileJanitor = self._Janitor:Add(self._Janitor.new())
	self._profileTimerJanitor = self._Janitor:Add(self._Janitor.new())
	self._isProfiling = false
	self._scope = Fusion.scoped({
		Value = Fusion.Value,
		Hydrate = Fusion.Hydrate,
		Computed = Fusion.Computed
	})
	self._selectedProfileId = self._scope:Value(nil)
	self._selectedInterval = self._scope:Value(nil)
	self._selectedTotalTime = self._scope:Value(nil)
	self._content = self.Instance:WaitForChild("Content")
	self:_ensureProgressUI()
end

function v:Start()
	self._Janitor:Add(self._content.Submit.Activated:Connect(function()
		self:OnSubmit()
	end))
	self:_watchSelectors(self._content.ProfileId, self._selectedProfileId)
	self:_watchSelectors(self._content.Interval, self._selectedInterval)
	self:_watchSelectors(self._content.TotalTime, self._selectedTotalTime)
	self:_updateProfileHistory()
	self._Janitor:Add(Players.LocalPlayer.Chatted:Connect(function(p)
		if p == "/profile" then
			PanelController.OpenPanelByContext("PerformanceUI", "DevProfilingUI")
		end
	end))

	if GameUtil.isDevPlace() or GameUtil.isQAPlace() then
		self._Janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
			if gameProcessed or input.KeyCode ~= Enum.KeyCode.Backspace or not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				return
			end

			toggleProfilingUI() -- equivalent call inferred; original call site unknown
		end))
	end
end

function v:OnSubmit()
	if self._isProfiling then
		return
	end

	local _selectedProfileId = Fusion.peek(self._selectedProfileId)
	local _selectedInterval = Fusion.peek(self._selectedInterval)
	local _selectedTotalTime = Fusion.peek(self._selectedTotalTime)
	local v2 = {
		profileId = self:_getValue(_selectedProfileId),
		interval = getNumberFromString(self:_getValue(_selectedInterval)),
		totalTime = getNumberFromString(self:_getValue(_selectedTotalTime))
	}

	if not v2.interval then
		self:_error("Invalid interval")
		return
	end

	if not v2.totalTime then
		self:_error("Invalid total time")
		return
	end

	self._isProfiling = true
	self._content.Submit.Interactable = false
	self:_startProfileTimer(v2.totalTime)
	NotificationController.NotifyCenter(string.format("Running profile for %s", formatRemainingTime(v2.totalTime)), 3)
	task.spawn(function()
		local v3, v4 = Remotes.invokeServer("StartProfile", v2.profileId, v2.interval, v2.totalTime)
		self:_stopProfileTimer()
		self._isProfiling = false
		self._content.Submit.Interactable = true

		if v3 then
			self:_updateProfileHistory()
		else
			self:_error(v4)
		end

		NotificationController.NotifyCenter(v4, 5)
	end)
end

function v:_updateProfileHistory()
	local v2 = Remotes.invokeServer("GetProfileHistory")

	if not v2 then
		self:_error("Failed to get profile history")
		return
	end

	self._profileJanitor:Cleanup()

	for _, v3 in v2 do
		local v4 = self._profileJanitor:Add(self._content.ProfileId.Template:Clone())
		v4.Name = v3
		v4.Title.Text = v3
		v4.Parent = self._content.ProfileId
		v4.Visible = true
		self._profileJanitor:Add(v4.Activated:Connect(function()
			self._selectedProfileId:set(v4)
		end))
		local v6 = v4
		self._scope:Hydrate(v4)({
			BackgroundColor3 = self._scope:Computed(function(use)
				return use(self._selectedProfileId) == v6 and color or color2
			end)
		})
	end
end

function v:_ensureProgressUI()
	local v2 = self._content:FindFirstChild("Progress")

	if v2 == nil then
		v2 = Instance.new("Frame")
		v2.Name = "Progress"
		v2.BackgroundTransparency = 1
		v2.Size = UDim2.fromScale(1, 0.08)
		v2.LayoutOrder = 5
		v2.Visible = false
		v2.Parent = self._content
		local frame = Instance.new("Frame")
		frame.Name = "Background"
		frame.BackgroundColor3 = color2
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(1, 0.45)
		frame.Position = UDim2.fromScale(0, 0.1)
		frame.Parent = v2
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0, 4)
		uICorner.Parent = frame
		local frame2 = Instance.new("Frame")
		frame2.Name = "Fill"
		frame2.BackgroundColor3 = color
		frame2.BorderSizePixel = 0
		frame2.Size = UDim2.fromScale(0, 1)
		frame2.Parent = frame
		local uICorner2 = Instance.new("UICorner")
		uICorner2.CornerRadius = UDim.new(0, 4)
		uICorner2.Parent = frame2
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Label"
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.fromScale(1, 0.4)
		textLabel.Position = UDim2.fromScale(0, 0.6)
		textLabel.Font = Enum.Font.GothamMedium
		textLabel.TextColor3 = color4
		textLabel.TextScaled = true
		textLabel.Text = ""
		textLabel.Parent = v2
	end

	self._progressContainer = v2
	self._progressFill = v2.Background.Fill
	self._progressLabel = v2.Label
end

function v:_startProfileTimer(p: number)
	self:_ensureProgressUI()
	self._profileTimerJanitor:Cleanup()
	local lastTime = os.clock()
	self._progressContainer.Visible = true
	self._progressFill.Size = UDim2.fromScale(0, 1)
	self._progressLabel.Text = string.format("Profiling: %s remaining", formatRemainingTime(p))
	self._profileTimerJanitor:Add(RunService.Heartbeat:Connect(function()
		local v2 = os.clock() - lastTime
		local v3 = math.clamp(v2 / p, 0, 1)
		local v4 = math.max(0, p - v2)
		self._progressFill.Size = UDim2.fromScale(v3, 1)

		if v4 > 0 then
			self._progressLabel.Text = string.format(
				"Profiling: %s remaining (%d%%)",
				formatRemainingTime(v4),
				(math.floor(v3 * 100))
			)
		else
			self._progressLabel.Text = "Profiling: finishing..."
		end
	end))
end

function v:_stopProfileTimer()
	self._profileTimerJanitor:Cleanup()

	if self._progressContainer ~= nil then
		self._progressFill.Size = UDim2.fromScale(1, 1)
		self._progressLabel.Text = "Profiling: complete"
		self._progressContainer.Visible = false
	end
end

function v:_getValue(instance)
	if not instance then
		return nil
	end

	if instance:IsA("TextButton") then
		return instance.Name
	end

	if instance:IsA("TextBox") then
		return instance.Text
	end

	return nil
end

function v:_error(value: string)
	self._content.Error.Text = value or "An unknown error occurred"
	self._content.Error.TextColor3 = color3
	task.delay(3, function()
		self._content.Error.Text = ""
	end)
end

function v:_watchSelectors(instance, state)
	for _, child in instance:GetChildren() do
		if not child:IsA("GuiObject") then
			continue
		end

		if child:IsA("TextButton") then
			local v2 = child
			self._Janitor:Add(child.Activated:Connect(function()
				if Fusion.peek(state) == v2 then
					state:set(nil)
				else
					state:set(v2)
				end
			end))
		elseif child:IsA("TextBox") then
			local v2 = child
			self._Janitor:Add(child.Focused:Connect(function()
				state:set(v2)
			end))
		end

		local v2 = child
		self._scope:Hydrate(child)({
			BackgroundColor3 = self._scope:Computed(function(use)
				return use(state) == v2 and color or color2
			end)
		})
	end
end

function v:Stop()
	Fusion.doCleanup(self._scope)
	self._Janitor:Destroy()
end

return v