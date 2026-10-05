local v = {}
local ConfigService = game:GetService("ConfigService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local FastSignal = require(ReplicatedStorage.Modules.FastSignal)
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local module = require("../Util")
local module2 = require("./ServerConfig")

local function getPlayerSnapshot(p)
	local configForPlayerAsync = nil
	local success, result = pcall(function()
		configForPlayerAsync = ConfigService:GetConfigForPlayerAsync(p)
	end)

	if not success then
		warn((`Failed to fetch player config. Error: {tostring(result)}`))
	end

	return configForPlayerAsync
end

function v:GetValue(p2: string)
	if not module:GetConfigData(p2) then
		error((`{p2} is not a registered GameConfig value!`))
	end

	if self.Snapshot then
		return module:ParseValue(p2, self.Snapshot:GetValue(p2))
	end

	return module2:GetValue(p2)
end

function v:GetValueChangedSignal(p: string)
	if not module:GetConfigData(p) then
		error((`{p} is not a registered GameConfig value!`))
	end

	if self.ValueChangedSignals[p] then
		return self.ValueChangedSignals[p]
	end

	self.ValueChangedSignals[p] = FastSignal.new()

	if self.Snapshot then
		self.Janitor:Add(self.Snapshot:GetValueChangedSignal(p):Connect(function()
			self.ValueChangedSignals[p]:Fire()
		end))
	end

	return self.ValueChangedSignals[p]
end

function v:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	self.Snapshot = nil
	self.Janitor:Destroy()
	self.Updated:Destroy()

	for _, valueChangedSignal in next, self.ValueChangedSignals, nil do
		valueChangedSignal:Destroy()
	end
end

return {
	new = function(player)
		local object = setmetatable({}, {
			__index = v
		})
		object.Player = player
		object.ValueChangedSignals = {}
		object.Janitor = Janitor.new()
		object.Updated = FastSignal.new()
		task.spawn(function()
			while not object.Snapshot and object.Player:IsDescendantOf(Players) and not object._destroyed do
				local v2 = object
				local configForPlayerAsync = nil
				local player2 = player
				local success, result = pcall(function()
					configForPlayerAsync = ConfigService:GetConfigForPlayerAsync(player2)
				end)

				if not success then
					warn((`Failed to fetch player config. Error: {tostring(result)}`))
				end

				v2.Snapshot = configForPlayerAsync

				if not object.Snapshot then
					task.wait(0.1)
				end
			end

			if object.Snapshot and not object._destroyed then
				object.Janitor:Add(object.Snapshot.UpdateAvailable:Connect(function()
					object.Snapshot:Refresh()
					object.Updated:Fire()
				end))

				for k, valueChangedSignal in next, object.ValueChangedSignals, nil do
					local v2 = valueChangedSignal
					object.Janitor:Add(object.Snapshot:GetValueChangedSignal(k):Connect(function()
						v2:Fire()
					end))
				end

				object.Updated:Fire()
			end
		end)
		return object
	end
}