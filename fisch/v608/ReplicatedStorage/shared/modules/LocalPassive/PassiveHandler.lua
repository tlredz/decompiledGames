local PassiveHandler = {}
PassiveHandler.__index = PassiveHandler
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local packages = ReplicatedStorage.packages
local Trove = require(packages.Trove)
require(ReplicatedStorage.shared.modules.library.fish)
require(ReplicatedStorage.client.legacyControllers.ReelController.Types)
require(ReplicatedStorage.client.legacyControllers.StabController.Types)
require(ReplicatedStorage.client.legacyControllers.HarpoonMinigameController.Types)

function PassiveHandler.new(p, config, env)
	local self = setmetatable({}, table.freeze({
		__index = p
	}))
	self.config = config
	self.trove = Trove.new()
	self.reelTrove = self.trove:Extend()
	self.env = env
	self.uid = HttpService:GenerateGUID(false)
	return self
end

function PassiveHandler:Morph(reel, current)
	self.reel = reel
	self.current = current
end

function PassiveHandler:Destroy()
	self.trove:Destroy()
	table.clear(self)
end

function PassiveHandler:Cleanup()
	if self.reelTrove then
		self.reelTrove:Clean()
	end

	self.current = nil
end

return PassiveHandler