local v = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local FastSignal = require(ReplicatedStorage.Modules.FastSignal)
local Network = require(ReplicatedStorage.Modules.Network)
local module = require("./Util")

function v.new()
	local self = setmetatable({}, {
		__index = v
	})
	self.Data = {}
	self.Pending = {}
	self.ValueChangedSignals = {}
	return self
end

function v:GetValue(p: string)
	if not module:GetConfigData(p) then
		error((`{p} is not a registered GameConfig value!`))
	end

	local lastTime = os.clock()

	while self.Pending[p] do
		task.wait()
	end

	if self.Data[p] ~= nil then
		return self.Data[p]
	end

	if self.Pending[p] ~= nil then
		return module:ParseValue(p, self.Data[p])
	end

	self.Pending[p] = true
	task.delay(2, function()
		if self.Pending[p] == true then
			warn((`Failed to fetch config ({p}). Using default value...`))
			self.Pending[p] = false
			task.wait(2)
			self:_setValue(p, (Network:invoke("GameConfig/GetValue", p)))
			print("Successfully fetched missing config!")
		end
	end)
	self:_setValue(p, (Network:invoke("GameConfig/GetValue", p)))
	self.Pending[p] = false

	if Players.LocalPlayer.UserId == 689602534 then
		print((`Fetched config ({p}). Took: {os.clock() - lastTime}`))
	end

	return module:ParseValue(p, self.Data[p])
end

function v:_setValue(p2: string, p3)
	if module:ParseValue(p2, self.Data[p2]) == p3 then
		return
	end

	self.Data[p2] = p3

	if self.ValueChangedSignals[p2] then
		self.ValueChangedSignals[p2]:Fire()
	end
end

function v.GetValueChangedSignal(p, p2: string)
	if not module:GetConfigData(p2) then
		error((`{p2} is not a registered GameConfig value!`))
	end

	if p.ValueChangedSignals[p2] then
		return p.ValueChangedSignals[p2]
	end

	p.ValueChangedSignals[p2] = FastSignal.new()
	return p.ValueChangedSignals[p2]
end

local v2 = v.new()
Network:listen("GameConfig/Updated", function()
	local v3 = {}

	for k, _ in next, v2.Data, nil do
		table.insert(v3, k)
	end

	local v4 = Network:invoke("GameConfig/GetUpdatedValues", v3)

	for k, v5 in next, v4, nil do
		v2:_setValue(k, v5)
	end
end)
return v2