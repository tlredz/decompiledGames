local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local parkourPlayerSlot = Players.LocalPlayer.PlayerScripts.UserInterface.ParkourPlayerSlot
local obbyGradient = ReplicatedStorage.Assets.Misc.ObbyGradient
local HardcoreParkour = {}
HardcoreParkour.__index = HardcoreParkour

function HardcoreParkour.new(duelInterface)
	local self = setmetatable({}, HardcoreParkour)
	self.DuelInterface = duelInterface
	self.Frame = self.DuelInterface.Frame:WaitForChild("HardcoreParkour")
	self.Container = self.Frame:WaitForChild("Container")
	self.ProgressFrame = self.Container:WaitForChild("Progress")
	self.ProgressContainer = self.ProgressFrame:WaitForChild("Container")
	self.BarFrame = self.ProgressContainer:WaitForChild("Bar")
	self.BarStroke = self.BarFrame:WaitForChild("UIStroke")
	self.DuelersFrame = self.ProgressContainer:WaitForChild("Duelers")
	self._destroyed = false
	self._tasks = {}
	self._connections = {}
	self._slots = {}
	self:_Init()
	return self
end

function HardcoreParkour:Update()
	local v = not self._destroyed and self.DuelInterface:IsActive() and not self.DuelInterface.Scoreboard:IsOpen() and not (self.DuelInterface.Voting:IsOpen() or Pages.PageSystem.CurrentPage) and not self.DuelInterface.RoundResult.Frame.Visible and self.DuelInterface.ClientDuel:Get("Status") ~= "GameOver"
	local obbyStartPosition = self.DuelInterface.ClientDuel.Map and self.DuelInterface.ClientDuel.Map:Get("ObbyStartPosition")
	local obbyFinishPosition = self.DuelInterface.ClientDuel.Map and self.DuelInterface.ClientDuel.Map:Get("ObbyFinishPosition")
	local visible = obbyStartPosition and obbyFinishPosition and v and true

	if visible == self.Frame.Visible then
		return
	end

	self:_Cleanup()
	self.Frame.Visible = visible

	if not visible then
		return
	end

	local v3 = obbyStartPosition * createVector(1, 0, 1)
	local magnitude = (v3 - obbyFinishPosition * createVector(1, 0, 1)).Magnitude

	local function update_positions(p)
		local v4 = {}

		for _, _slot in pairs(self._slots) do
			local position = _slot.ClientDueler.ClientFighter and _slot.ClientDueler.ClientFighter.Entity and _slot.ClientDueler.ClientFighter.Entity.RootPart and _slot.ClientDueler.ClientFighter.Entity.RootPart.Position
			local v5

			if position then
				v5 = self.DuelInterface.ClientDuel:Get("Status") == "RoundStarting" and 0 or (position * createVector(
					1,
					0,
					1
				) - v3).Magnitude
			end

			table.insert(v4, { _slot, v5 })
		end

		table.sort(v4, function(a, b)
			return (a[2] or 0) < (b[2] or 0)
		end)

		for k, list in pairs(v4) do
			local v5, v6 = table.unpack(list)
			v5.Slot.ZIndex = k

			if not v6 then
				continue
			end

			local uDim = UDim2.new(math.clamp(v6 / magnitude, 0, 1), 0, 0.5, 0)
			local v7 = p == v5.ClientDueler or uDim.X.Scale < v5.Slot.Position.X.Scale

			if v7 then
				v5.Slot.Position = uDim
			end

			v5.Slot:TweenPosition(uDim, "Out", "Linear", v7 and 0 or 1, true)
		end
	end

	table.insert(self._tasks, task.spawn(function()
		while true do
			update_positions()
			wait(1)
		end
	end))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function dueler_removed(object2)
		if self._slots[object2.Player] then
			self._slots[object2.Player].Slot:Destroy()
			self._slots[object2.Player] = nil
		end

		update_positions()
	end

	table.insert(self._connections, self.DuelInterface.ClientDuel.DuelerRemoved:Connect(dueler_removed))

	local function dueler_added(object2)
		dueler_removed(object2) -- equivalent call inferred; original call site unknown
		local teamColor = DuelLibrary:GetTeamColor(object2:Get("TeamID"))
		local clone = parkourPlayerSlot:Clone()
		clone.Container.Arrow.ImageColor3 = teamColor
		clone.Container.Background.ImageColor3 = teamColor
		clone.Size = object2.IsLocalDueler and UDim2.new(1, 0, 1, 0) or UDim2.new(0.75, 0, 0.75, 0)
		clone.Container.Headshot.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, object2.Player.UserId)
		clone.Position = UDim2.new(0, 0, 0.5, 0)
		clone.Parent = self.DuelersFrame
		self._slots[object2.Player] = {
			Slot = clone,
			ClientDueler = object2
		}
		update_positions(object2)
	end

	table.insert(self._connections, self.DuelInterface.ClientDuel.DuelerAdded:Connect(dueler_added))

	for _, dueler in pairs(self.DuelInterface.ClientDuel.Duelers) do
		task.spawn(dueler_added, dueler)
	end
end

function HardcoreParkour:Destroy()
	self._destroyed = true
	self:_Cleanup()
end

function HardcoreParkour:_Cleanup()
	for _, _task in pairs(self._tasks) do
		task.cancel(_task)
	end

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	for _, _slot in pairs(self._slots) do
		_slot.Slot:Destroy()
	end

	self._tasks = {}
	self._connections = {}
	self._slots = {}
end

function HardcoreParkour:_Setup()
	local clone = obbyGradient:Clone()
	clone.Parent = self.BarFrame
	local clone_2 = obbyGradient:Clone()
	clone_2.Parent = self.BarStroke
end

function HardcoreParkour:_Init()
	self.DuelInterface.RoundResult.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		self:Update()
	end)
	self.DuelInterface.Scoreboard.VisibilityChanged:Connect(function()
		self:Update()
	end)
	self.DuelInterface.Voting.VisibilityChanged:Connect(function()
		self:Update()
	end)
	self:_Setup()
end

return HardcoreParkour