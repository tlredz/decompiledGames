game:GetService("UserInputService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("GamepadService")
game:GetService("GuiService")
require(ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.packages.Signal)
require(ReplicatedStorage.shared.modules.Hook)
require(ReplicatedStorage.shared.utils.GeneralUtils)
require("../Types")
require(ReplicatedStorage.client.legacyControllers.SettingsController)
local GenericDataHandlers = {}

function GenericDataHandlers.new(current)
	local object = setmetatable({}, {
		__index = GenericDataHandlers
	})
	object.current = current
	object.trove = current.trove:Extend()
	object.Disabled = false
	return object
end

function GenericDataHandlers.Start(p)
	local count = 0
	p.trove:Add(p.current.OnSlash:Connect(function()
		count += 1
	end))
	p.trove:Add(p.current.BuildEndingData:Bind(function(p2)
		p2.SlashCount = count
		return p2
	end))
	p.trove:Add(p.current.OnReady:Once(function()
		if p.current.data.TimedBoosts then
			for _, timedBoost in p.current.data.TimedBoosts do
				local v = timedBoost
				task.delay(timedBoost.Delay or 0, function()
					if not (p.current and p.current.active) then
						return
					end

					if v.ShakeIntensity and v.ShakeIntensity ~= 0 then
						p.current.fx:SpawnShake(
							p.current.ui_safezone,
							v.ShakeIntensity or 0.8,
							v.ShakeTime or 0.8,
							0.025,
							v.ShakeRotates,
							v.ShakeIntensityDecay
						)
					end

					local split = v.Split or 1

					for i = 1, split do
						if p.current and p.current.active then
							local finalMult = i == split and v.FinalMult or 1
							p.current:AddProgress((v.Progress or 30) / split * finalMult)
							task.wait(v.SplitInterval or 0.1)
						else
							break
						end
					end
				end)
			end
		end

		if p.current.data.RepeatedBoosts then
			for _, repeatedBoost in p.current.data.RepeatedBoosts do
				local v = repeatedBoost
				task.spawn(function()
					local random = p.current:GetRandom(v.SeedOffset or 10)

					while p.current and p.current.active do
						task.wait(random:NextNumber(v.MinInterval, v.MaxInterval))
						task.delay(v.ExtraDelay or 0, function()
							if not (p.current and p.current.active) then
								return
							end

							if v.ShakeIntensity and v.ShakeIntensity ~= 0 then
								p.current.fx:SpawnShake(
									p.current.ui_safezone,
									v.ShakeIntensity or 0.25,
									v.ShakeTime or 0.25,
									0.025,
									v.ShakeRotates,
									v.ShakeIntensityDecay
								)
							end

							p.current:AddProgress(v.Progress or 30)
						end)
					end
				end)
			end
		end
	end))
end

function GenericDataHandlers:Disable()
	self.Disabled = true
end

function GenericDataHandlers.Stop(p)
	p.trove:Clean()
end

function GenericDataHandlers.TickLogic(_: number) end

function GenericDataHandlers.TickRender(_: number) end

return GenericDataHandlers