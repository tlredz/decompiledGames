game:GetService("RunService")
local module = require("./PassiveHandler")
local color = Color3.fromRGB(74, 158, 255)
local color2 = Color3.fromRGB(150, 205, 255)
local color3 = Color3.fromRGB(255, 156, 46)
local color4 = Color3.fromRGB(255, 62, 26)

-- equivalent calls inferred from this helper; original call sites unknown
local function heatColor(p: number)
	if p <= 0.5 then
		return color2:Lerp(color3, p / 0.5)
	end

	return color3:Lerp(color4, (p - 0.5) / 0.5)
end

local ScaldingHook = {
	_CacheOriginals = function(self)
		local reel = self.reel

		if not reel then
			return
		end

		local reel_playerbar = self.current and self.current.reel_playerbar

		if reel_playerbar then
			self.originalBarColor = reel_playerbar.BackgroundColor3
			self.barTween = self.current.logicTweens:Create(
				reel_playerbar,
				TweenInfo.new(1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					BackgroundColor3 = color
				}
			)
			self.barTween:Play()
		end

		local fish = reel:FindFirstChild("fish")
		local icon = fish and fish:FindFirstChild("icon")

		if icon and icon:IsA("ImageLabel") then
			self.fishIcon = icon
			self.originalIconColor = icon.ImageColor3
		end
	end,
	_RestoreOriginals = function(self)
		if self.barTween then
			self.barTween:Cancel()
			self.barTween = nil
		end

		local reel_playerbar = self.current and self.current.reel_playerbar

		if reel_playerbar and self.originalBarColor then
			reel_playerbar.BackgroundColor3 = self.originalBarColor
		end

		if self.fishIcon and self.originalIconColor and self.fishIcon.Parent then
			self.fishIcon.ImageColor3 = self.originalIconColor
		end

		self.originalBarColor = nil
		self.originalIconColor = nil
		self.fishIcon = nil
	end,
	_ApplyHeat = function(self, p: number)
		local config = self.config

		if self.forcedModifier then
			self.forcedModifier.Value = p * config.MaxForcedProgressSpeed / 100
		end

		if self.fishIcon and self.fishIcon.Parent then
			local fishIcon = self.fishIcon
			local imageColor = heatColor(p) -- equivalent call inferred; original call site unknown
			fishIcon.ImageColor3 = imageColor
		end
	end,
	_Advance = function(self, p: number)
		local config = self.config
		local current = self.current

		if current.onbar then
			self.heat += p / config.HeatUpTime
		else
			self.heat -= p / config.CoolDownTime
		end

		self.heat = math.clamp(self.heat, 0, 1)

		if self.heat > self.peakHeat then
			self.peakHeat = self.heat
			current.data.ScaldingPeakHeat = self.peakHeat
		end

		return self.heat
	end,
	Morph = function(self, _, object2)
		local ui = object2.core and object2.core.ui

		if ui then
			self.restoreColorChange = ui.OnBarEffects_ColorChangeEnabled
			ui.OnBarEffects_ColorChangeEnabled = false
			self.reelTrove:Add(function()
				ui.OnBarEffects_ColorChangeEnabled = self.restoreColorChange
			end)
		end

		self.reelTrove:Add(task.spawn(function()
			object2:WaitUntilReady()
			self.heat = 0
			self.peakHeat = 0
			object2.data.ScaldingPeakHeat = 0
			self.forcedModifier = object2:CreateModifier("progressefficiency", "force_add")
			self.forcedModifier.Value = 0
			self:_CacheOriginals()
			self.reelTrove:Add(object2.OnRenderStep:Connect(function(p)
				if not object2.active then
					return
				end

				self:_ApplyHeat(self:_Advance(p))
			end))
			self.reelTrove:Add(object2.BuildEndingData:BindAtPriority(1000, function(p)
				p.ScaldingForced = self.peakHeat * self.config.MaxForcedProgressSpeed
				return p
			end))
			self.reelTrove:Add(function()
				self:_RestoreOriginals()
			end)
		end))
	end
}
setmetatable(ScaldingHook, module)
return ScaldingHook