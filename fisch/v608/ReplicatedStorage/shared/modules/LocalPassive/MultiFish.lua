game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("GuiService")
local module = require("./PassiveHandler")
require(ReplicatedStorage.shared.modules.fx)
require(ReplicatedStorage.client.legacyControllers.ReelController)
require(ReplicatedStorage.client.legacyControllers.HudController)
require(ReplicatedStorage.client.legacyControllers.ReelController.Types)
require(ReplicatedStorage.shared.modules.library.fish)
require(ReplicatedStorage.shared.modules.fishing.FishInstance.Types)
local Core = require(ReplicatedStorage.client.legacyControllers.ReelController.Core)
local v = {
	progress = true,
	perfect = true,
	onbar = true,
	progressefficiency = true,
	trueprogressefficiency = true,
	progressLossMultiplier = true,
	resilience = true,
	movementfactor = true,
	moveIntervalFactor = true,
	fishPosition = true,
	core = true
}
local MultiFish = {
	CreatePseudoReel = function(p, _, p2: number)
		local current = p.current

		local function index(_, p3)
			if v[p3] then
				return current[p3 .. p2]
			end

			return current[p3]
		end

		local function newindex(_, p3, p4)
			if v[p3] then
				current[p3 .. p2] = p4
			else
				current[p3] = p4
			end
		end

		local object = setmetatable({}, {
			__index = index,
			__newindex = newindex
		})
		local clone = table.clone(p.current.core)
		clone.minigame = Core.minigame.new(object)
		clone.fish = Core.fish.new(object)
		current[`core{p2}`] = clone
		rawset(object, "core", clone)
		return object
	end,
	Morph = function(p, _, p2)
		p.reelTrove:Add(p2.BuildEndingData:Bind(function(p3)
			if not secondReelEndData and secondReel.active then
				local _, _, v2 = secondReel.OnMinigameEnd:Wait()
				secondReelEndData = v2
			end

			if secondReelEndData then
				p3.SecondReel = {
					e = secondReel.progress,
					p = secondReel.perfect,
					l = {},
					d = secondReelEndData
				}
			end

			return p3
		end))
	end
}
setmetatable(MultiFish, module)
return MultiFish