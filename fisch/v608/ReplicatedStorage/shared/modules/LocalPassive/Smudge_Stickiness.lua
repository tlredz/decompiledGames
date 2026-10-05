local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
require(ReplicatedStorage.shared.modules.fx)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local SmudgeStickiness = {
	Morph = function(p, _, object)
		if FischUtils.IsTradePlaza() then
			return
		end

		task.spawn(function()
			object:WaitUntilReady()

			if not object.data.SlashDisableStun then
				object:AddModifier("movementfactor", "multiply", p.config.FishSpeedRatio)
				local fish = object.reel_bar.fish
				local descendants = fish:GetDescendants()
				table.insert(descendants, fish)

				for _, instance in descendants do
					if instance:IsA("GuiObject") then
						TweenService:Create(instance, TweenInfo.new(1), {
							BackgroundColor3 = instance.BackgroundColor3:Lerp(Color3.fromRGB(167, 67, 255), 0.5)
						}):Play()
					end

					if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
						TweenService:Create(instance, TweenInfo.new(1), {
							ImageColor3 = instance.ImageColor3:Lerp(Color3.fromRGB(167, 67, 255), 0.5)
						}):Play()
					end

					if instance:IsA("UIStroke") then
						TweenService:Create(instance, TweenInfo.new(1), {
							Color = instance.Color:Lerp(Color3.fromRGB(167, 67, 255), 0.5)
						}):Play()
					end
				end
			end
		end)
	end
}
setmetatable(SmudgeStickiness, module)
return SmudgeStickiness