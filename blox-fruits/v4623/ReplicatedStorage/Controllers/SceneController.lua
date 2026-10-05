local Scene = require(script.Scene)
require(game.ReplicatedStorage.Modules.Util.Trove)
local Locks = require(game.ReplicatedStorage.Controllers.Locks)
require(script.SceneRigs.Helper.HelperTypes)
local v = nil
local scene2 = nil
local v3 = nil
local v4 = nil
local scenes = {}
local SceneController = {
	Scenes = scenes,
	SequenceHistory = require(game.ReplicatedStorage.Controllers.SceneController.SequenceHistory)
}

local function fn(_: string, fn2)
	if v4 then
		v4:Destroy()
	end

	Locks.SceneLock:Lock()

	if not scene2 then
		local scene = Scene("ValentinesScene")
		scene2 = scene
		scene.Destroying:Once(function()
			Locks.SceneLock:Unlock()
			scene2 = nil
			v3 = nil
			v = nil
		end)
	end

	local maid = assert(scene2)._Maid:Extend()
	v4 = maid
	maid:Add(function()
		v4 = nil
		v = nil

		if scene2 and scene2._Rig then
			scene2._Rig:Destroy()
		end
	end)
	local v6 = fn2({
		Scene = scene2
	})
	v = v6
	return maid:Add(v6)
end

function SceneController.TryGetCurrentClass()
	return v
end

function SceneController.DestroyRig()
	if v4 then
		v4:Destroy()
	end
end

function SceneController.Destroy()
	if scene2 then
		scene2:Destroy()
	end
end

local HttpService = game:GetService("HttpService")
local GUID = HttpService:GenerateGUID()
local Gravity = require(script.SceneRigs.Gravity)
scenes["Gravity-Gravity"] = {
	Prewarm = Gravity.Prewarm,
	new = function(p)
		return fn(GUID, function(p2)
			return Gravity.new({
				PhysicalMoveset = "Gravity-Gravity",
				Scene = p2.Scene,
				SkinStorageName = p.SkinStorageName
			})
		end)
	end
}
local HttpService2 = game:GetService("HttpService")
local GUID2 = HttpService2:GenerateGUID()
local Diamond = require(script.SceneRigs.Diamond)
scenes["Diamond-Diamond"] = {
	Prewarm = Diamond.Prewarm,
	new = function(p)
		return fn(GUID2, function(p2)
			return Diamond.new({
				PhysicalMoveset = "Diamond-Diamond",
				Scene = p2.Scene,
				SkinStorageName = p.SkinStorageName
			})
		end)
	end
}
local HttpService3 = game:GetService("HttpService")
local GUID3 = HttpService3:GenerateGUID()
local Lightning = require(script.SceneRigs.Lightning)
scenes["Lightning-Lightning"] = {
	Prewarm = Lightning.Prewarm,
	new = function(p)
		return fn(GUID3, function(p2)
			return Lightning.new({
				PhysicalMoveset = "Lightning-Lightning",
				Scene = p2.Scene,
				SkinStorageName = p.SkinStorageName
			})
		end)
	end
}
local HttpService4 = game:GetService("HttpService")
local GUID4 = HttpService4:GenerateGUID()
local Ghost = require(script.SceneRigs.Ghost)
scenes["Ghost-Ghost"] = {
	Prewarm = Ghost.Prewarm,
	new = function(p)
		return fn(GUID4, function(p2)
			return Ghost.new({
				PhysicalMoveset = "Ghost-Ghost",
				Scene = p2.Scene,
				SkinStorageName = p.SkinStorageName
			})
		end)
	end
}
local HttpService5 = game:GetService("HttpService")
local GUID5 = HttpService5:GenerateGUID()
local Magnet = require(script.SceneRigs.Magnet)
scenes["Magnet-Magnet"] = {
	Prewarm = Magnet.Prewarm,
	new = function(p)
		return fn(GUID5, function(p2)
			return Magnet.new({
				PhysicalMoveset = "Magnet-Magnet",
				Scene = p2.Scene,
				SkinStorageName = p.SkinStorageName
			})
		end)
	end
}
local HttpService6 = game:GetService("HttpService")
local GUID6 = HttpService6:GenerateGUID()
local Yeti = require(script.SceneRigs.Yeti)
scenes["Fiend (Yeti)-Fiend (Yeti)"] = {
	Prewarm = Yeti.Prewarm,
	new = function(p)
		return fn(GUID6, function(p2)
			return Yeti.new({
				PhysicalMoveset = "Fiend (Yeti)-Fiend (Yeti)",
				Scene = p2.Scene,
				SkinStorageName = p.SkinStorageName
			})
		end)
	end
}
scenes["Yeti-Yeti"] = {
	Prewarm = Yeti.Prewarm,
	new = function(p)
		return fn(GUID6, function(p2)
			return Yeti.new({
				PhysicalMoveset = "Yeti-Yeti",
				Scene = p2.Scene,
				SkinStorageName = p.SkinStorageName
			})
		end)
	end
}
local HttpService7 = game:GetService("HttpService")
local GUID7 = HttpService7:GenerateGUID()
local Blade = require(script.SceneRigs.Blade)
scenes["Blade-Blade"] = {
	Prewarm = Blade.Prewarm,
	new = function(p)
		return fn(GUID7, function(p2)
			return Blade.new({
				PhysicalMoveset = "Blade-Blade",
				Scene = p2.Scene,
				SkinStorageName = p.SkinStorageName
			})
		end)
	end
}
local HttpService8 = game:GetService("HttpService")
local GUID8 = HttpService8:GenerateGUID()
local Tiger = require(script.SceneRigs.Tiger)
scenes["Tiger-Tiger"] = {
	Prewarm = Tiger.Prewarm,
	new = function(p)
		return fn(GUID8, function(p2)
			return Tiger.new({
				PhysicalMoveset = "Tiger-Tiger",
				Scene = p2.Scene,
				SkinStorageName = p.SkinStorageName
			})
		end)
	end
}
scenes["Werewolf (Tiger)-Werewolf (Tiger)"] = {
	Prewarm = Tiger.Prewarm,
	new = function(p)
		return fn(GUID8, function(p2)
			return Tiger.new({
				PhysicalMoveset = "Werewolf (Tiger)-Werewolf (Tiger)",
				Scene = p2.Scene,
				SkinStorageName = p.SkinStorageName
			})
		end)
	end
}
local HttpService9 = game:GetService("HttpService")
local GUID9 = HttpService9:GenerateGUID()
local Kitsune = require(script.SceneRigs.Kitsune)
scenes["Kitsune-Kitsune"] = {
	Prewarm = Kitsune.Prewarm,
	new = function(p)
		return fn(GUID9, function(p2)
			return Kitsune.new({
				PhysicalMoveset = "Kitsune-Kitsune",
				Scene = p2.Scene,
				SkinStorageName = p.SkinStorageName
			})
		end)
	end
}
scenes["Empyrean (Kitsune)-Empyrean (Kitsune)"] = {
	Prewarm = Kitsune.Prewarm,
	new = function(p)
		return fn(GUID9, function(p2)
			return Kitsune.new({
				PhysicalMoveset = "Empyrean (Kitsune)-Empyrean (Kitsune)",
				Scene = p2.Scene,
				SkinStorageName = p.SkinStorageName
			})
		end)
	end
}

function SceneController.OnStart(_)
	task.spawn(function()
		for _, v6 in pairs({
			scenes["Magnet-Magnet"],
			scenes["Fiend (Yeti)-Fiend (Yeti)"],
			scenes["Blade-Blade"],
			scenes["Lightning-Lightning"],
			scenes["Ghost-Ghost"],
			scenes["Diamond-Diamond"],
			scenes["Gravity-Gravity"]
		}) do
			v6.Prewarm()
		end
	end)
	task.spawn(function()
		local IrisLog = require(game.ReplicatedStorage.Util.IrisLog)
		local gacha = IrisLog.new("Gacha", nil, {
			Category = "Systems"
		})
		local v6 = {}
		table.insert(v6, gacha:AuthorityButton("Admin", "Exit", function(_)
			SceneController.Destroy()
		end))
		table.insert(v6, gacha:NewLine())

		for k, scene in pairs(SceneController.Scenes) do
			local v7 = scene
			table.insert(v6, gacha:AuthorityButton("Admin", k, function(p)
				local v8 = v7.new({})
				v8.Data.Scene:Init()
				v8.PlaySequence({
					Name = "Primary",
					OnFinish = function() end
				})
			end))
			table.insert(v6, gacha:NewLine())
		end

		gacha:AppendToTab("Scenes", table.unpack(v6))
	end)
end

return SceneController