local Maid = require(script.Parent.Maid)
local Signal = require(script.Parent.Signal)

local function DeepSearch(p, ...)
	local maid = Maid.new()
	maid.Active = true
	local v = Signal.new()
	maid:GiveTask(v)
	local v2 = {
		Objects = {},
		Destroy = function()
			maid:Destroy()
		end
	}
	v2.Loaded = {
		Connect = function(self, callback)
			for k in pairs(v2.Objects) do
				task.spawn(callback, k)
			end

			return v:Connect(callback)
		end,
		QuickConnect = function(_, callback)
			for k in pairs(v2.Objects) do
				task.spawn(callback, k)
			end

			v:Connect(callback)
			return v2
		end
	}
	local Find

	Find = function(instance, p2: string, ...)
		local v3 = Maid.new()
		local namesMaid = Maid.new()
		local v5 = { ... }
		local v6 = next(v5)
		local OnNameCheck

		OnNameCheck = function(instance2)
			if instance2.Name ~= p2 then
				namesMaid[instance2] = instance2:GetPropertyChangedSignal("Name"):Connect(function()
					OnNameCheck(instance2)
				end)
				return
			end

			local v7 = Maid.new()
			v7.NameChanged = instance2:GetPropertyChangedSignal("Name"):Connect(function()
				OnNameCheck(instance2)
			end)

			if v6 then
				v7.Tracker = Find(instance2, unpack(v5))
			else
				v2.Objects[instance2] = true
				v:Fire(instance2)

				function v7.Remove()
					v2.Objects[instance2] = nil
				end
			end

			namesMaid[instance2] = v7
		end

		for _, child in pairs(instance:GetChildren()) do
			OnNameCheck(child)
		end

		v3.NamesMaid = namesMaid
		v3.ChildAdded = instance.ChildAdded:Connect(OnNameCheck)
		v3.ChildRemoved = instance.ChildRemoved:Connect(function(child)
			namesMaid[child] = nil
		end)
		return v3
	end

	maid.Tracker = Find(p, ...)
	return v2
end

local Streamer = {}

function Streamer.Sync(_, p, ...)
	return DeepSearch(p, ...)
end

function Streamer.SyncPrimaryPart(_, instance)
	local v = Maid.new()
	v.Active = true
	local v2 = Signal.new()
	local v3 = {
		Destroy = function()
			v:Destroy()
		end
	}
	v3.Loaded = {
		Connect = function(self, callback)
			if v3.Object then
				callback(v3.Object)
			end

			return v2:Connect(callback)
		end
	}
	task.spawn(function()
		local primaryPart = nil

		while v.Active and not primaryPart do
			task.wait(0.25)
			primaryPart = instance.PrimaryPart
		end

		if not v.Active then
			return
		end

		v2:Fire(primaryPart)
		v3.Object = primaryPart
	end)
	return v3
end

return Streamer