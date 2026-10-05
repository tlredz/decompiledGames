game:GetService("ContentProvider")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local Debounce = require(ReplicatedStorage.packages.Debounce)
require(ReplicatedStorage.client.legacyControllers.HarpoonMinigameController.Types)
local CuskShot = {
	MorphHarpoon = function(p, _, object)
		local random = object:GetRandom(51)
		p.reelTrove:Add(object.core.pullButtons.OnButtonAdd:Connect(function(object2)
			if random:NextNumber(0, 100) < p.config.DarkPullSpawnChance then
				object2:ModifyDespawnTime("add", p.config.DarkPullLifetime + 1)
				local v = object.buttonSize * p.config.DarkPullSizeRatio
				local randomButtonPosition = object:GetRandomButtonPosition(random, v)
				local randomButtonPosition2 = object:GetRandomButtonPosition(random, v)
				local button = object:SpawnButton("darkpull", object:GetRandomButtonPosition(random, v), v)
				button.springTime = p.config.DarkPullLifetime
				button.springMaxSpeed = (randomButtonPosition - randomButtonPosition2).Magnitude / p.config.DarkPullLifetime
				button:MoveTo(randomButtonPosition2)
				button:ModifyDespawnTime("set", p.config.DarkPullLifetime)
				button.clicksRemaining = 1e999
				button.requiredClicks = 1e999
				button.OnClick:Connect(function()
					if Debounce("ClickDarkPull", 0.1) then
						return
					end

					object:AddProgress(object.power * 0.5 * object.progressefficiency)
				end)
			end
		end))
	end
}
setmetatable(CuskShot, module)
return CuskShot