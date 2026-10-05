local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local Matchmaking = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Lobby"):WaitForChild("Matchmaking"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileInputs"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local Queue = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Queue"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local bossHealthBar = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("BossHealthBar")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("MainFrame", "BossHealth")
	self.Container = self.Frame:WaitForChild("Container")
	self._duel_subject_connections = {}
	self._boss_health_bars = {}
	self._last_changed_health_bar_frame = nil
	self._update_health_bar_internal = Signal.new()
	self:_Init()
	return self
end

function class:_UpdateVisibility()
	local v = SpectateController.CurrentDuelSubject and SpectateController.CurrentDuelSubject.DuelInterface.Voting:IsOpen()
	self.Frame.Visible = not (v or Pages.PageSystem.CurrentPage or Equipment.IsOpen or Queue:IsVisible() or Teleporting.Enabled or MobileInputs.EditorEnabled or Matchmaking:IsVisible())
end

function class:_DuelSubjectChanged()
	for _, _duel_subject_connection in pairs(self._duel_subject_connections) do
		_duel_subject_connection:Disconnect()
	end

	self._duel_subject_connections = {}
	self:_UpdateVisibility()

	if not SpectateController.CurrentDuelSubject then
		return
	end

	table.insert(
		self._duel_subject_connections,
		SpectateController.CurrentDuelSubject.DuelInterface.Voting.VisibilityChanged:Connect(function()
			self:_UpdateVisibility()
		end)
	)
end

function class:_HumanoidAdded(instance)
	self:_HumanoidRemoved(instance)
	local connections = {}
	local threads = {}
	local clone = bossHealthBar:Clone()
	clone.Parent = self.Container

	local function update_name()
		clone.Title.Text = instance.Parent and instance.Parent.Name or ""
		clone.Title.AutoLocalize = not (instance.Parent and Players:GetPlayerFromCharacter(instance.Parent))
	end

	table.insert(connections, instance.Parent:GetPropertyChangedSignal("Name"):Connect(update_name))
	clone.Title.Text = not instance.Parent and "" or instance.Parent.Name or ""
	clone.Title.AutoLocalize = not (instance.Parent and Players:GetPlayerFromCharacter(instance.Parent))
	local visible = false

	local function update_visibility()
		local v = clone
		local visible2 = self.Frame.Visible

		if visible2 then
			if instance.Health > 0 then
				visible2 = instance.RootPart and (instance.RootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude <= 256
			else
				visible2 = false
			end
		end

		v.Visible = visible2

		if clone.Visible and not visible then
			clone.Size = UDim2.new(0, 0, 0, 0)
			clone:TweenSize(bossHealthBar.Size, "Out", "Quint", 0.5, true)
		end

		visible = clone.Visible
	end

	table.insert(connections, self._update_health_bar_internal:Connect(update_visibility))
	table.insert(connections, self.Frame:GetPropertyChangedSignal("Visible"):Connect(update_visibility))
	table.insert(threads, task.defer(function()
		while true do
			update_visibility()
			wait(1)
		end
	end))
	local v = nil
	local v2 = nil

	local function refresh()
		self._last_changed_health_bar_frame = clone
		self._update_health_bar_internal:Fire()
		local maxHealth = instance.MaxHealth
		local health = instance.Health
		local v3 = math.clamp(health / maxHealth, 0, 1)
		local lerped = Color3.fromRGB(255, 50, 50):Lerp(
			Color3.fromRGB(255, 215, 0):Lerp(Color3.fromRGB(100, 255, 50), v3),
			v3
		)
		local color = Color3.new(lerped.R / 2, lerped.G / 2, lerped.B / 2)
		clone.Health.BackgroundColor3 = color
		clone.Health.UIStroke.Color = color
		clone.Health.Bar.BackgroundColor3 = lerped
		clone.Health.Bar.Visible = v3 > 0
		clone.Health.Bar.UIStroke.Color = lerped
		clone.Health.Bar.Value.Title.Text = health > 1 and math.ceil(health) or ""
		local v4 = v and not (v3 < v) and 0.5 or 1
		local uDim = UDim2.new(math.max(0.06, v3), 2, 1, 2)

		if v2 then
			v2:Pause()
		end

		v2 = TweenService:Create(
			clone.Health.Bar,
			TweenInfo.new(0.5 / v4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Size = uDim
			}
		)
		v2:Play()
		v = v3
		update_visibility()
	end

	table.insert(connections, instance:GetPropertyChangedSignal("MaxHealth"):Connect(refresh))
	table.insert(connections, instance:GetPropertyChangedSignal("Health"):Connect(refresh))
	refresh()
	self._boss_health_bars[instance] = {
		Frame = clone,
		Connections = connections,
		Threads = threads
	}
end

function class:_HumanoidRemoved(p2)
	local _boss_health_bar = self._boss_health_bars[p2]

	if not _boss_health_bar then
		return
	end

	_boss_health_bar.Frame:Destroy()

	for _, connection in pairs(_boss_health_bar.Connections) do
		connection:Disconnect()
	end

	for _, thread in pairs(_boss_health_bar.Threads) do
		pcall(task.cancel, thread)
	end

	self._boss_health_bars[p2] = nil
end

function class:_Init()
	Equipment.Opened:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PageOpened:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PageClosed:Connect(function()
		self:_UpdateVisibility()
	end)
	Queue.VisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Matchmaking.VisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Teleporting.EnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	SpectateController.DuelSubjectChanged:Connect(function()
		self:_DuelSubjectChanged()
	end)
	CollectionService:GetInstanceAddedSignal("BossHealthBar"):Connect(function(p)
		self:_HumanoidAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("BossHealthBar")) do
		task.defer(self._HumanoidAdded, self, v)
	end

	self:_UpdateVisibility()
	task.defer(self._DuelSubjectChanged, self)
end

return class._new()