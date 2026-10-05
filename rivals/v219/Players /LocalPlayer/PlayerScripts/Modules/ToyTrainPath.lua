local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local toyTrain = Players.LocalPlayer.PlayerScripts.Assets.Misc.ToyTrain
local ToyTrainPath = {}
ToyTrainPath.__index = ToyTrainPath

function ToyTrainPath.new(model)
	local self = setmetatable({}, ToyTrainPath)
	self.Model = model
	self._connections = {}
	self._num_paths = self.Model:GetAttribute("NumPaths")
	self._paths = {}
	self._path_to_running_total_length = {}
	self._length = 0
	self._padding = 0
	self._speed = 0
	self._progress = ServerOsTime:Get()
	self._tick = self._progress
	self._num_trains = 0
	self._trains = {}
	self._train_sizes = {}
	self._train_attachments = {}
	self._train_attachment_positions = {}
	self._train_attacheds = {}
	self._event_gifts = {}
	self._claim_event_gift_cooldown = 0
	self._sound_cooldown = tick() + 15
	self:_Init()
	return self
end

function ToyTrainPath:GetCFrame(p)
	local v = p % 1

	for i = 1, self._num_paths do
		local v2 = i == 1 and 0 or self._path_to_running_total_length[i - 1]
		local v3 = self._path_to_running_total_length[i]

		if v < v2 or v3 < v then
			continue
		end

		local _path = self._paths[i]
		return
			_path.Start.WorldPosition:Lerp(_path.Finish.WorldPosition, (v - v2) / (v3 - v2)),
			CFrame.new(_path.Start.WorldPosition, _path.Finish.WorldPosition).Rotation
	end

	return CFrame.identity
end

function ToyTrainPath:Update(p)
	self._tick += p
	self._progress += self._speed * p

	for k, _train in pairs(self._trains) do
		local cFrame, v = self:GetCFrame(self._progress - self._padding * (k - 1))
		local v2 = CFrame.new(cFrame) * _train:GetPivot().Rotation:Lerp(v, 0.1)
		local v3 = self._tick % self._num_trains + 1
		local v4 = not (k <= v3 and v3 <= k + 1) and 0 or math.sin(6.283185307179586 * self._tick)
		local v5 = v4 * (v4 < 0 and 0.25 or 1)
		local v6 = v5 * 1
		_train.Size = self._train_sizes[k] + Vector3.new(v5 * -0.5, v6, v5 * -0.5)
		_train:PivotTo(v2 + Vector3.new(0, v6 / 2, 0))

		if self._train_attachments[k] then
			self._train_attachments[k].Position = self._train_attachment_positions[k] + Vector3.new(0, v6, 0)
			self._train_attacheds[k]:PivotTo(self._train_attachments[k].WorldCFrame)
		end

		if not (k == 1 and tick() > self._sound_cooldown) then
			continue
		end

		self._sound_cooldown = tick() + 20 + 20 * math.random()
		Utility:CreateSound("rbxassetid://106675250798882", 0.25, 1, _train, true, 5)
		task.delay(0.4, Utility.CreateSound, Utility, "rbxassetid://114399683675542", 0.25, 1, _train, true, 5)
	end
end

function ToyTrainPath:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self.Model:Destroy()
end

function ToyTrainPath:_UpdateEventGiftEnabled()
	for k, _event_gift in pairs(self._event_gifts) do
		local parent

		if not (ServerOsTime:Get() < PlayerDataController:Get("LastEventGiftClaimed") + EventLibrary.EVENT_GIFT_COOLDOWN) then
			parent = self._trains[k]
		end

		_event_gift.Parent = parent
	end
end

function ToyTrainPath:_Setup()
	for i = 1, self._num_paths do
		local child = self.Model:WaitForChild(i)
		child.Start.Position = Vector3.new(child.Size.X / 2, 0, 0)
		child.Finish.Position = Vector3.new(-child.Size.X / 2, 0, 0)
		self._paths[i] = child
		self._length += (self._paths[i].Finish.Position - self._paths[i].Start.Position).Magnitude
		self._path_to_running_total_length[i] = self._length
		child.Transparency = 1
	end

	for k, v in pairs(self._path_to_running_total_length) do
		self._path_to_running_total_length[k] = v / self._length
	end

	self._padding = 8 / self._length
	self._speed = 4 / self._length
	local clone = toyTrain:Clone()
	self._num_trains = clone:GetAttribute("NumTrains")

	for i = 1, self._num_trains do
		local child = clone:WaitForChild(i)
		self._trains[i] = child
		self._train_sizes[i] = child.Size
		local attachment = child:FindFirstChild("Attachment")
		local attached = child:FindFirstChild("Attached")

		if not (attachment and attached) then
			continue
		end

		self._train_attachments[i] = attachment
		self._train_attachment_positions[i] = attachment.Position
		self._train_attacheds[i] = attached

		if not attached:GetAttribute("IsEventGift") then
			continue
		end

		self._event_gifts[i] = attached
		attached.Hitbox.Touched:Connect(function(otherPart)
			if Players:GetPlayerFromCharacter(otherPart.Parent) == Players.LocalPlayer and tick() > self._claim_event_gift_cooldown then
				self._claim_event_gift_cooldown = tick() + 3
				ReplicatedStorage.Remotes.Misc.ClaimEventGift:FireServer()
			end
		end)
	end

	clone.Parent = self.Model
end

function ToyTrainPath:_Init()
	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("LastEventGiftClaimed"):Connect(function()
		self:_UpdateEventGiftEnabled()
	end))
	self:_Setup()
	task.defer(self._UpdateEventGiftEnabled, self)
end

return ToyTrainPath