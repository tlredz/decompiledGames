local Workspace = game:GetService("Workspace")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local ScyllaBehavior = {}
ScyllaBehavior.__index = ScyllaBehavior
ScyllaBehavior.MorphSpear = true
ScyllaBehavior.MorphHarpoon = true

function ScyllaBehavior:Morph(_, object2)
	self.lastScyllaBite = 0
	self.controlScyllaBite = false
	self.biteTween = object2.logicTweens:Create(
		object2.reel_progress.bar,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
		{
			BackgroundColor3 = self.config.Color
		}
	)
	local barResizer

	if object2.type ~= "harpoon" then
		barResizer = object2:CreateModifier(object2.type == "reel" and "barSize" or "handling", "multiply")
	end

	self.barResizer = barResizer
	self.random = object2:GetRandom(5)
	object2.OnFishMove:Connect(function()
		self:Update(object2)
	end)
end

function ScyllaBehavior:Update(object)
	local config = self.config

	if not object.active then
		return
	end

	local serverTimeNow = Workspace:GetServerTimeNow()

	if not (serverTimeNow < self.lastScyllaBite + config.Cooldown / 2) then
		self.lastScyllaBite = serverTimeNow + config.Cooldown / 2

		if self.random:NextNumber(0, 100) < config.BaseChance and object.progress >= config.MinimumProgress then
			object:AddProgress(object.progress * -config.ProgressLossRatio)
			self.biteTween:Play()

			if not self.controlScyllaBite then
				self.controlScyllaBite = true

				if self.barResizer then
					self.barResizer.Value = 1 - config.ControlReduction
					object:DelayLogic(config.Duration, function()
						if object.active then
							self.barResizer.Value = 1
						end
					end)
				elseif object.type == "harpoon" then
					local v = math.max(self.config.ControlReduction // 0.1, 1)

					for _ = 1, v do
						local button = object.core.pullButtons:SpawnButton()
						button.progressMultiplier /= v
						button:ModifyDespawnTime("add", 3)
						object:WaitLogic(1 / v)
					end
				end

				object:DelayLogic(config.Duration, function()
					if object.active then
						self.controlScyllaBite = false
					end
				end)
			end
		end
	end
end

setmetatable(ScyllaBehavior, module)
return ScyllaBehavior