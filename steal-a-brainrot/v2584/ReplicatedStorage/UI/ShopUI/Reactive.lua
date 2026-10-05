local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Synchronizer = require(packages.Synchronizer)
local FFlags = require(packages.FFlags)
local Timer = require(packages.Timer)
local Trove = require(packages.Trove)
local vide = require(packages.vide)
require(ReplicatedStorage.UserGenerated.FastFlags)
local classes = ReplicatedStorage:WaitForChild("Classes")
local AnimatedButton = require(classes.AnimatedButton)
local Marketplace = require(ReplicatedStorage.Shared.Marketplace)
local source = vide.source
local cleanup = vide.cleanup
local apply = vide.apply
local localPlayer = Players.LocalPlayer
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function scopedTrove()
	local v2 = Trove.new()
	cleanup(function()
		v2:Destroy()
	end)
	return v2
end

v.Trove = scopedTrove

function v.Hydrate(p, p2)
	return (apply(p)(p2))
end

function v.FromSubscription(callback, callback2)
	local v2 = source(callback2());
	(scopedTrove()):Add(callback(function()
		v2(callback2())
	end))
	return v2
end

function v.FromChannel(callback, p, p2)
	return v.FromChannelOf(localPlayer, callback, p, p2)
end

function v.FromChannelOf(p, callback, p2, items)
	local v2 = source(p2)
	local maid = scopedTrove() -- equivalent call inferred; original call site unknown
	local v3 = true
	maid:Add(function()
		v3 = false
	end)
	task.spawn(function()
		local v4 = Synchronizer:Wait(p)

		if not (v4 and v3) then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			v2(callback(v4))
		end

		for _, item in items do
			maid:Add(v4[item.Method](v4, item.Path, update))
		end

		update() -- equivalent call inferred; original call site unknown
	end)
	return v2
end

function v.FromChannelPath(path, p2, p3)
	return v.FromChannel(function(object)
		local v2 = object:Get(path)

		if v2 == nil then
			return p2
		end

		return v2
	end, p2, p3 or {
		{
			Method = "OnChanged",
			Path = path
		}
	})
end

function v.FromFlag(p: string, p2)
	local function read()
		return FFlags:GetInstant(p, p2)
	end

	local v2 = source(read())
	local maid = scopedTrove() -- equivalent call inferred; original call site unknown
	maid:Add(FFlags:OnChange(p, function()
		v2(read())
	end))
	maid:Add(FFlags:OnUpdate(function()
		v2(read())
	end))
	return v2
end

function v.FFlag(object)
	return v.FromSubscription(function(callback)
		return object.Changed:Connect(function()
			callback()
		end)
	end, function()
		return object:Get()
	end)
end

function v.Clock(value: number?)
	local v2 = source(workspace:GetServerTimeNow());
	(scopedTrove()):Add(Timer.Simple(value or 1, function()
		v2(workspace:GetServerTimeNow())
	end))
	return v2
end

function v.ProductInfo(p: number, p2)
	local v2 = source(nil)
	local maid = scopedTrove() -- equivalent call inferred; original call site unknown
	local v3 = true
	maid:Add(function()
		v3 = false
	end)
	task.spawn(function()
		local success, result = pcall(function()
			return Marketplace:GetProductInfo(p, p2)
		end)

		if success and v3 then
			v2(result)
		end
	end)
	return v2
end

function v.Button(p, onOnActivated)
	local v2 = AnimatedButton.new(p)
	v2:Animate()
	v2.OnActivated:Connect(onOnActivated);
	(scopedTrove()):Add(v2, "Destroy")
	return v2
end

return table.freeze(v)