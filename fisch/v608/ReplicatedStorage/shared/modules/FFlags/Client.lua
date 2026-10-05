local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Replion = require(ReplicatedStorage.packages.Replion)
local Signal = require(ReplicatedStorage.packages.Signal)
require(script.Parent.Types)
local FFlags = {
	_loaded = false,
	_updatedSignal = Signal.new(),
	_loadedSignal = Signal.new(),
	IsLoaded = function(self)
		return (Replion.Client:WaitReplion("FFlags"):Get("Loaded"))
	end,
	OnLoad = function(p, on_loadedSignal)
		return p._loadedSignal:Connect(on_loadedSignal)
	end,
	OnUpdate = function(p, on_updatedSignal)
		return p._updatedSignal:Connect(on_updatedSignal)
	end,
	OnChange = function(self, p, p2)
		return Replion.Client:WaitReplion("FFlags"):OnChange({ "Values", p }, p2)
	end,
	Get = function(self, p, p2)
		local v = Replion.Client:WaitReplion("FFlags")

		if not self:IsLoaded() then
			self._loadedSignal:Wait()
		end

		local v2 = v:Get({ "Values", p })

		if v2 == nil then
			return p2
		end

		return v2
	end,
	GetInstant = function(_, p, p2)
		local replion = Replion.Client:GetReplion("FFlags")

		if not replion then
			return p2
		end

		local v = replion:Get({ "Values", p })

		if v == nil then
			return p2
		end

		return v
	end,
	_loadMemoryStore = function(_)
		warn("FFlags:_loadMemoryStore() cannot be used on the client!")
		return false
	end,
	_loadDataStore = function(_)
		warn("FFlags:_loadDataStore() cannot be used on the client!")
		return false
	end,
	Set = function(_)
		warn("FFlags:Set() cannot be used on the client!")
		return false
	end,
	Load = function(_)
		warn("FFlags:Load() cannot be used on the client!")
		return false
	end,
	Start = function(state)
		local v = Replion.Client:WaitReplion("FFlags")
		state._loaded = v:Get("Loaded")
		local connection = nil
		connection = v:OnChange("Loaded", function(loaded: boolean, flag: boolean)
			if loaded and not flag then
				state._loaded = loaded
				state._loadedSignal:Fire(v.Data)

				if connection.Connected then
					connection:Disconnect()
				end
			end
		end)
		v:OnChange("LastChange", function(_: number, _: number)
			state._updatedSignal:Fire(v.Data)
		end)
	end
}
task.spawn(FFlags.Start, FFlags)
return FFlags