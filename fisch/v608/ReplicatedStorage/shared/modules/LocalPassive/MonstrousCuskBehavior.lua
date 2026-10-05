game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")

local function countActivePulls(p)
	local count = 0

	for _, activeButton in ipairs(p.activeButtons) do
		if activeButton.buttonType ~= "pull" or activeButton.removing then
			continue
		end

		count += 1
	end

	return count
end

local MonstrousCuskBehavior = {
	MorphHarpoon = function(self, _, object)
		self.random = object:GetRandom(77)
		self.burstTimer = 0
		self.burstFillTimer = 0
		self.fakesSpawned = 0
		self.fakesClicked = 0
		self.burstsSpawned = 0
		object:AddModifier("buttonSize", "multiply", self.config.PullSizeRatio)
		self.reelTrove:Add(object.core.pullButtons.OnButtonAdd:Connect(function(_)
			if self.burstTimer > 0 or self.random:NextNumber(0, 100) >= self.config.FakeSpawnChance then
				return
			end

			local v = object.buttonSize * self.config.FakeSizeRatio
			local randomButtonPosition = object:GetRandomButtonPosition(self.random, v)
			local randomButtonPosition2 = object:GetRandomButtonPosition(self.random, v)
			local button = object:SpawnButton("darkpull", randomButtonPosition, v)
			button.springTime = self.config.FakeLifetime
			button.springMaxSpeed = (randomButtonPosition - randomButtonPosition2).Magnitude / self.config.FakeLifetime
			button:MoveTo(randomButtonPosition2)
			button:ModifyDespawnTime("set", self.config.FakeLifetime)
			self.fakesSpawned += 1
			self.reelTrove:Add(button.OnClick:Connect(function(p)
				if p ~= "player" then
					return
				end

				self.fakesClicked += 1
				object:AddProgress(-self.config.FakeProgressLoss)
				object.perfect = false
				self.burstTimer = self.config.BurstDuration
				self.burstFillTimer = 0
				self.burstsSpawned = 0
				object.fx:SpawnShake(object.ui_safezone, 0.6, 0.5, 0.03, true)
			end))
		end))
		object.BuildEndingData:Bind(function(p)
			p.MonstrousCusk_FakesSpawned = self.fakesSpawned
			p.MonstrousCusk_FakesClicked = self.fakesClicked
			return p
		end)
	end,
	TickLogic_Harpoon = function(self, p, p2: number)
		if self.burstTimer <= 0 then
			return
		end

		self.burstTimer -= p2
		self.burstFillTimer -= p2

		if self.burstTimer <= 0 or self.burstFillTimer > 0 then
			return
		end

		self.burstFillTimer = self.config.BurstFillInterval

		if countActivePulls(p) >= self.config.BurstButtonCount then
			return
		end

		p.core.pullButtons:SpawnButton()
		self.burstsSpawned += 1
	end
}
setmetatable(MonstrousCuskBehavior, module)
return MonstrousCuskBehavior