local v = {}
local ConfigService = game:GetService("ConfigService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastSignal = require(ReplicatedStorage.Modules.FastSignal)
local module = require("../Util")

local function getServerSnapshot()
	local configAsync = nil
	local success, result = pcall(function()
		configAsync = ConfigService:GetConfigAsync()
	end)

	if not success then
		warn((`Failed to fetch server config. Error: {tostring(result)}`))
	end

	return configAsync
end

function v:GetValue(p2: string)
	if not module:GetConfigData(p2) then
		error((`{p2} is not a registered GameConfig value!`))
	end

	if self.Snapshot then
		return module:ParseValue(p2, self.Snapshot:GetValue(p2))
	end

	return module:GetDefaultValue(p2)
end

function v:GetValueChangedSignal(p2: string)
	if not module:GetConfigData(p2) then
		error((`{p2} is not a registered GameConfig value!`))
	end

	if self.ValueChangedSignals[p2] then
		return self.ValueChangedSignals[p2]
	end

	self.ValueChangedSignals[p2] = FastSignal.new()

	if self.Snapshot then
		self.Snapshot:GetValueChangedSignal(p2):Connect(function()
			self.ValueChangedSignals[p2]:Fire()
		end)
	end

	return self.ValueChangedSignals[p2]
end

return ({
	new = function()
		local object = setmetatable({}, {
			__index = v
		})
		object.ValueChangedSignals = {}
		task.spawn(function()
			while not object.Snapshot do
				local v3 = object
				local configAsync = nil
				local success, result = pcall(function()
					configAsync = ConfigService:GetConfigAsync()
				end)

				if not success then
					warn((`Failed to fetch server config. Error: {tostring(result)}`))
				end

				v3.Snapshot = configAsync

				if not object.Snapshot then
					task.wait(0.1)
				end
			end

			if object.Snapshot then
				object.Snapshot.UpdateAvailable:Connect(function()
					object.Snapshot:Refresh()
				end)

				for k, valueChangedSignal in next, object.ValueChangedSignals, nil do
					local v3 = valueChangedSignal
					object.Snapshot:GetValueChangedSignal(k):Connect(function()
						v3:Fire()
					end)
				end
			end
		end)
		return object
	end
}).new()