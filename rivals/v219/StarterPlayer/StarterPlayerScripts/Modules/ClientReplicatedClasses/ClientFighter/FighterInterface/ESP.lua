local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local eSPGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ESPGui")
local eSPSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ESPSlot")
local ESP = {}
ESP.__index = ESP

function ESP.new(fighterInterface)
	local self = setmetatable({}, ESP)
	self.FighterInterface = fighterInterface
	self._esp_connections = {}
	self._esp_slots = {}
	self._esp_gui = nil
	self._esp_gui_frame = nil
	self._esp_gui_fov_frame = nil
	self:_Init()
	return self
end

function ESP:Refresh()
	self:Clear()

	if not self.FighterInterface.ClientFighter:Get("CheaterMode") then
		return
	end

	self._esp_gui = self:_CreateGui()
	self._esp_gui_frame = self._esp_gui:WaitForChild("Frame")
	self._esp_gui_fov_frame = self._esp_gui_frame:WaitForChild("FOV")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clear_player(player)
		if self._esp_slots[player] then
			self._esp_slots[player].Slot:Destroy()
			self._esp_slots[player] = nil
		end
	end

	table.insert(self._esp_connections, Players.PlayerRemoving:Connect(clear_player))

	local function check_player(player)
		clear_player(player) -- equivalent call inferred; original call site unknown

		if player == Players.LocalPlayer or Players.LocalPlayer:GetAttribute("TeamID") and Players.LocalPlayer:GetAttribute("TeamID") == player:GetAttribute("TeamID") then
			return
		end

		local character = player.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChild("Humanoid")

		if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
			return
		end

		local clone = eSPSlot:Clone()
		clone.Parent = self._esp_gui_frame
		local line = clone.Line

		local function update(_)
			local worldToScreenPoint, _ = workspace.CurrentCamera:WorldToScreenPoint(humanoidRootPart.Position)
			local screenPointToPosition = UILibrary:ScreenPointToPosition(
				Vector2.new(worldToScreenPoint.X, worldToScreenPoint.Y),
				self._esp_gui_frame.AbsolutePosition
			)
			clone.Visible = worldToScreenPoint.Z >= 0 and worldToScreenPoint.Z < CONSTANTS.RENDER_DISTANCE and humanoid.Health > 0

			if not clone.Visible then
				return
			end

			local v3 = self._esp_gui_fov_frame.AbsolutePosition + self._esp_gui_fov_frame.AbsoluteSize / 2
			local v4 = math.sqrt((v3.X - worldToScreenPoint.X) ^ 2 + (v3.Y - worldToScreenPoint.Y) ^ 2)
			local v5 = 4.71238898038469 - math.atan2(worldToScreenPoint.X - v3.X, worldToScreenPoint.Y - v3.Y)
			clone.Position = UDim2.new(0, screenPointToPosition.X, 0, screenPointToPosition.Y)
			line.Size = UDim2.new(0, v4, 0, 0)
			line.Position = UDim2.new(0.5, math.cos(v5) * v4 / 2, 0.5, math.sin(v5) * v4 / 2)
			line.Rotation = math.deg(v5)
			local worldToScreenPoint2 = workspace.CurrentCamera:WorldToScreenPoint(humanoidRootPart.Position + createVector(
				0,
				2,
				0
			))
			local worldToScreenPoint3 = workspace.CurrentCamera:WorldToScreenPoint(humanoidRootPart.Position - createVector(
				0,
				3,
				0
			))
			local v6 = math.abs(worldToScreenPoint2.Y - worldToScreenPoint3.Y)
			clone.Size = UDim2.new(0, v6 * 0.8, 0, v6)
		end

		self._esp_slots[player] = {
			Slot = clone,
			Update = update
		}
	end

	local function player_added(instance)
		local function check()
			instance:WaitForChild("HumanoidRootPart", 3)
			check_player(instance)
		end

		table.insert(self._esp_connections, instance:GetAttributeChangedSignal("TeamID"):Connect(check))
		table.insert(self._esp_connections, instance.CharacterAdded:Connect(check))
		task.defer(check)
	end

	table.insert(self._esp_connections, Players.PlayerAdded:Connect(player_added))

	for _, v in pairs(Players:GetPlayers()) do
		task.defer(player_added, v)
	end

	local function check_all_players()
		for _, v in pairs(Players:GetPlayers()) do
			check_player(v)
		end
	end

	table.insert(
		self._esp_connections,
		Players.LocalPlayer:GetAttributeChangedSignal("TeamID"):Connect(check_all_players)
	)
	self._esp_gui.Parent = Players.LocalPlayer.PlayerGui
end

function ESP:Update(p, _)
	if not self._esp_gui then
		return
	end

	local screenPointToPosition = UILibrary:ScreenPointToPosition(
		self.FighterInterface.ClientFighter:GetMouseLocation(),
		self._esp_gui_frame.AbsolutePosition
	)
	self._esp_gui_fov_frame.Position = UDim2.new(0, screenPointToPosition.X, 0, screenPointToPosition.Y)

	for _, _esp_slot in pairs(self._esp_slots) do
		if CONSTANTS.IS_STUDIO then
			_esp_slot.Update(p)
		else
			pcall(_esp_slot.Update, p)
		end
	end
end

function ESP:Clear()
	for _, _esp_connection in pairs(self._esp_connections) do
		_esp_connection:Disconnect()
	end

	for _, _esp_slot in pairs(self._esp_slots) do
		_esp_slot.Slot:Destroy()
	end

	self._esp_connections = {}
	self._esp_slots = {}

	if self._esp_gui then
		self._esp_gui:Destroy()
		self._esp_gui = nil
	end
end

function ESP:Destroy()
	self:Clear()
end

function ESP:_CreateGui()
	local clone = eSPGui:Clone()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_visible()
		clone.Enabled = self.FighterInterface.Frame.Visible and self.FighterInterface.Frame.Parent
	end

	table.insert(
		self._esp_connections,
		self.FighterInterface.Frame:GetPropertyChangedSignal("Visible"):Connect(update_visible)
	)
	update_visible() -- equivalent call inferred; original call site unknown

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ancestry_changed()
		if not self.FighterInterface.Frame.Parent then
			return
		end

		table.insert(
			self._esp_connections,
			self.FighterInterface.Frame.Parent:GetPropertyChangedSignal("Visible"):Connect(update_visible)
		)
		update_visible() -- equivalent call inferred; original call site unknown
	end

	table.insert(self._esp_connections, self.FighterInterface.Frame.AncestryChanged:Connect(ancestry_changed))
	ancestry_changed() -- equivalent call inferred; original call site unknown
	return clone
end

function ESP:_Init() end

return ESP