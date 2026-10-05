local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
game:GetService("Lighting")
game:GetService("GuiService")
require(ReplicatedStorage.shared.modules.fx)
require(ReplicatedStorage.client.legacyControllers.SettingsController)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
DataController = DataController.PlayerDataReplicator
local module = require("./PassiveHandler")
local random = Random.new()

local function cmap(p: number, p2: number, p3: number, p4: number, p5: number)
	return (math.clamp(math.map(p, p2, p3, p4, p5), math.min(p4, p5), (math.max(p4, p5))))
end

local TerrosunderBehavior = {
	MorphSpear = true,
	MorphHarpoon = true,
	Morph = function(self, _, object)
		ContentProvider:PreloadAsync(script:GetChildren())
		self.random = object:GetRandom(6)
		self.currentIntensity = 0

		if not self.reelTrove then
			return
		end

		self.overlay = self.reelTrove:Add(script.sandoverlay:Clone())
		self.overlay.container.borders.ImageTransparency = 1
		self.overlay.container.borders.SliceScale = 0.1
		self.overlay.container.gradient.UIGradient.Offset = Vector2.new(0, 1)
		self.overlay.Enabled = true
		self.overlay.Parent = HudController:GetPlayerGui()
		local v = self.overlay.container.borders.AbsoluteSize.Y * 0.5 / 277
		local v2 = 0
		local v3 = false
		object:AddCleanupDelay(1)
		self.reelTrove:Add(object.PreMinigameEnd:Once(function()
			v3 = true

			for _, guiObject in self.overlay:QueryDescendants("ImageLabel, Frame") do
				if guiObject:IsA("ImageLabel") and guiObject.ImageTransparency < 1 then
					TweenService:Create(guiObject, TweenInfo.new(1, Enum.EasingStyle.Linear), {
						ImageTransparency = 1
					}):Play()
				elseif guiObject:IsA("Frame") and guiObject.BackgroundTransparency < 1 then
					TweenService:Create(guiObject, TweenInfo.new(1, Enum.EasingStyle.Linear), {
						BackgroundTransparency = 1
					}):Play()
				end
			end
		end))
		self.reelTrove:Add(object.OnLogicStep:Connect(function(p)
			if not object or v3 then
				return
			end

			if object.active and not object.isPaused then
				self.currentIntensity = math.min(
					self.currentIntensity + self.config.AccumulateRate * p,
					self.config.MaxAccumulate or 1e999
				)
			end

			local borders = self.overlay.container.borders
			local currentIntensity = self.currentIntensity
			borders.ImageTransparency = math.clamp(math.map(currentIntensity, 0, 50, 1, 0), 0, 1)
			local borders2 = self.overlay.container.borders
			local currentIntensity2 = self.currentIntensity
			local v4 = v
			borders2.SliceScale = math.clamp(
				math.map(currentIntensity2, 0, 100, 0.1, v4),
				math.min(0.1, v4),
				(math.max(0.1, v4))
			)
			local uIGradient = self.overlay.container.gradient.UIGradient
			local currentIntensity3 = self.currentIntensity
			uIGradient.Offset = Vector2.new(0, (math.clamp(math.map(currentIntensity3, 50, 200, 1, -0.25), -0.25, 1)))
			local now = tick()

			if v2 < now then
				local number = random:NextNumber(1, 2)
				local integer = random:NextInteger(197, 255)
				local clone = script.sand:Clone()
				clone.Position = UDim2.fromScale(0, number)
				clone.ImageTransparency = 1
				clone.ImageColor3 = Color3.fromRGB(integer, integer, integer)
				clone.Parent = self.overlay.container.animatedContainer
				local number2 = random:NextNumber(1, 2)
				TweenService:Create(clone, TweenInfo.new(number2, Enum.EasingStyle.Linear), {
					Position = UDim2.fromScale(-1, number)
				}):Play()
				local tweenInfo = TweenInfo.new(random:NextNumber(0.25, 0.5), Enum.EasingStyle.Linear)
				local currentIntensity4 = self.currentIntensity
				TweenService:Create(clone, tweenInfo, {
					ImageTransparency = math.clamp(math.map(currentIntensity4, 0, 100, 0.9, 0), 0, 0.9)
				}):Play()
				local number3 = random:NextNumber(0.25, 0.5)
				task.delay(number2 - number3, function()
					if not clone.Parent or v3 then
						return
					end

					TweenService:Create(clone, TweenInfo.new(number3, Enum.EasingStyle.Linear), {
						ImageTransparency = 1
					}):Play()
					task.wait(number3)
					clone:Destroy()
				end)
				v2 = tick() + random:NextNumber(0.25, 0.5)
			end
		end))
	end
}
setmetatable(TerrosunderBehavior, module)
return TerrosunderBehavior