local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Lighting")
game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local SammySBase = {}
require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Observers = require(ReplicatedStorage.Packages.Observers)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local parentModule = require(script.Parent.Parent)
local WorldBrainrotController = require(ReplicatedStorage.Controllers.WorldBrainrotController)
local name = script.Name
local maid = Trove.new()

function SammySBase.OnStart(_)
	assert((parentModule:GetActiveEventData(name)))
	maid:Add(Observers.observeTag("SammyBaseStep", function(instance)
		local index = instance:GetAttribute("Index") or 0
		local position = instance.Position
		instance.Position += Vector3.new(-(index % 1 * 2 - 1) * 2, 0, 0)
		CreateTween(instance, TweenInfo.new(0.5), {
			Transparency = 0,
			Position = position
		})
		return nil
	end))
	maid:Add(Observers.observeTag("HideInSammysBase", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	maid:Add(WorldBrainrotController:RenderPool({
		PoolId = "SammysBase",
		ReplicatorId = "SammysBase",
		ShowTimer = false,
		ShowDropButton = false,
		GrabHoldDuration = 1.5,
		GrabMaxDistance = 10,
		KeepWhenGrabbed = true
	}))
end

function SammySBase.OnStop(_)
	maid:Destroy()
end

function SammySBase.OnLoad(_) end

return SammySBase