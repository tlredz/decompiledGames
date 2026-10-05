local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local Config = require(script.Parent.Config)
local TransitionSounds = require(script.Parent.TransitionSounds)
require(script.Parent.Types)
local YearCounterView = require(script.Parent.YearCounterView)
local v = nil
local v2 = nil
local v3 = nil
local YearCounter = {
	setStatus = function(year: number?, seconds: number, instruction: string)
		v3 = {
			year = year,
			seconds = seconds,
			instruction = instruction
		}

		if v then
			v.setStatus(year, seconds, instruction)
		end
	end,
	show = function(fromYear: number, toYear: number)
		v2 = {
			fromYear = fromYear,
			toYear = toYear,
			rolling = false
		}

		if v then
			v.show(fromYear, toYear)
		end
	end,
	roll = function()
		if v2 then
			v2.rolling = true
		end

		if v then
			v.roll()
		end
	end,
	reset = function()
		v2 = nil
		v3 = nil

		if v then
			v.reset()
		end
	end
}
FeatureManager.RegisterFeature(script.Name, {
	OnUIInit = function()
		if RunService:IsClient() then
			local v4 = YearCounterView.mount(Players.LocalPlayer.PlayerGui, function()
				TransitionSounds.play(Config.yearTransitionSounds.yearTick)
			end)
			v = v4

			if v3 then
				v4.setStatus(v3.year, v3.seconds, v3.instruction)
			end

			if v2 then
				v4.show(v2.fromYear, v2.toYear)

				if v2.rolling then
					v4.roll()
				end
			end
		end
	end,
	OnRender = function()
		if v then
			v.update()
		end
	end
})
return YearCounter