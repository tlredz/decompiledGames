local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local Cryogenic = {
	Morph = function(p, _, object)
		task.spawn(ContentProvider.PreloadAsync, ContentProvider, { script })
		task.spawn(function()
			object:WaitUntilReady()
			task.spawn(ContentProvider.PreloadAsync, ContentProvider, { script.FrostImg })
			object:WaitLogic(p.config.AttemptDelay)

			if object:GetRandom(3):NextNumber(0, 100) < p.config.FreezeChance then
				object:FreezeFish(1e999)
				local GuiService = game:GetService("GuiService")
				local guiInset = GuiService:GetGuiInset()
				local clone = script.FrostImg:Clone()
				clone.Size = UDim2.new(1, guiInset.X, 1, guiInset.Y)
				clone.Parent = object.reel
				object.renderTweens:Create(clone.CryogenicFlash, TweenInfo.new(3, Enum.EasingStyle.Linear), {
					BackgroundTransparency = 1
				}):Play()
				object.renderTweens:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Linear), {
					ImageTransparency = 0.5
				}):Play()
				ReplicatedStorage.resources.sounds.sfx.ui.cryogenic:Play()
			end
		end)
	end
}
setmetatable(Cryogenic, module)
return Cryogenic