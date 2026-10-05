local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("ContentProvider")
local Players = game:GetService("Players")
local InputLibrary = require(ReplicatedStorage.Modules.InputLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ReplicatedController = require(Players.LocalPlayer.PlayerScripts.Modules.ReplicatedController)
local object = setmetatable({}, ReplicatedController)
object.__index = object

function object._new()
	local self = setmetatable(ReplicatedController.new("Duel"), object)
	self.LocalPlayerJoinedOrLeftDuel = Signal.new()
	self.LocalPlayerJoinedDuel = Signal.new()
	self.LocalPlayerLeftDuel = Signal.new()
	self:_Init()
	return self
end

function object.GetDuelByID(p, p2)
	for k, object2 in pairs(p.Objects) do
		if object2:Get("ObjectID") == p2 then
			return object2, k
		end
	end
end

function object:GetDuel(p2)
	for k, object2 in pairs(self.Objects) do
		if object2:GetDueler(p2) then
			return object2, k
		end
	end
end

function object:_SetupInputs()
	local ShootingRangeController = require(Players.LocalPlayer.PlayerScripts.Controllers.ShootingRangeController)
	local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		local duel = self:GetDuel(Players.LocalPlayer)

		if duel and duel.DuelInterface.Buttons:IsSwitchItemsVisible() and InputLibrary:InputIs(input, "SwitchItems") then
			duel.DuelInterface.Buttons:SwitchItemsRequest()
		elseif duel and duel.DuelInterface.Buttons:IsRespawnNowVisible() and InputLibrary:InputIs(input, "Jump") then
			duel.DuelInterface.Buttons:RespawnNowRequest()
		elseif InputLibrary:InputIs(input, "LeaveDuel") then
			if duel then
				duel:LeaveDuelRequest()
			elseif FighterController.LocalFighter and FighterController.LocalFighter:Get("IsInShootingRange") then
				ShootingRangeController:Leave()
			end
		end
	end)
end

function object:_Init()
	self.ObjectAdded:Connect(function(object2)
		local function check_local_dueler(dueler)
			if not (dueler and dueler.IsLocalPlayer) then
				return
			end

			object2.DuelerRemoved:Connect(function(p)
				if p == dueler then
					self.LocalPlayerLeftDuel:Fire(object2, p)
					self.LocalPlayerJoinedOrLeftDuel:Fire(object2, p)
				end
			end)
			self.LocalPlayerJoinedDuel:Fire(object2, dueler)
			self.LocalPlayerJoinedOrLeftDuel:Fire(object2, dueler)
		end

		object2.DuelerAdded:Connect(check_local_dueler)
		check_local_dueler(object2:GetDueler(Players.LocalPlayer))
	end)
	self.ObjectRemoved:Connect(function(object2)
		local dueler = object2:GetDueler(Players.LocalPlayer)

		if not dueler then
			return
		end

		self.LocalPlayerLeftDuel:Fire(object2, dueler)
		self.LocalPlayerJoinedOrLeftDuel:Fire(object2, dueler)
	end)
	task.defer(self._SetupInputs, self)
end

return object._new()