local themes = {
	CutCorners = {
		MainButton = {
			Image = "rbxassetid://76476290918578",
			SliceCenter = Rect.new(32, 32, 34, 34),
			SliceScaleMultiplier = 0.00625
		},
		GamepadIconBackground = {
			Image = "rbxassetid://135976734207422",
			SliceCenter = Rect.new(32, 32, 34, 34),
			SliceScaleMultiplier = 0.00625
		}
	},
	CutTopLeftCorner = {
		MainButton = {
			Image = "rbxassetid://127204475432575",
			SliceCenter = Rect.new(32, 32, 34, 34),
			SliceScaleMultiplier = 0.00625
		},
		GamepadIconBackground = {
			Image = "rbxassetid://95201075795195",
			SliceCenter = Rect.new(32, 32, 34, 34),
			SliceScaleMultiplier = 0.00625
		}
	},
	CutBottomRightCorner = {
		MainButton = {
			Image = "rbxassetid://135976734207422",
			SliceCenter = Rect.new(32, 32, 34, 34),
			SliceScaleMultiplier = 0.00625
		},
		GamepadIconBackground = {
			Image = "rbxassetid://135976734207422",
			SliceCenter = Rect.new(32, 32, 34, 34),
			SliceScaleMultiplier = 0.00625
		}
	},
	RoundedCorners = {
		MainButton = {
			Image = "rbxassetid://136205699446611",
			SliceCenter = Rect.new(32, 32, 34, 34),
			SliceScaleMultiplier = 0.00625
		},
		GamepadIconBackground = {
			Image = "rbxassetid://98913835358317",
			SliceCenter = Rect.new(32, 32, 34, 34),
			SliceScaleMultiplier = 0.00625
		}
	}
}
local NexusInstance = require(script.Parent:WaitForChild("Packages"):WaitForChild("NexusInstance"))
local SimpleWrappedInstance = require(script.Parent:WaitForChild("SimpleWrappedInstance"))
local v2 = {
	Themes = themes
}
v2.__index = v2
setmetatable(v2, SimpleWrappedInstance)

function v2:__new()
	SimpleWrappedInstance.__new(self, Instance.new("ImageLabel"))
	local wrappedInstance = self:GetWrappedInstance()
	wrappedInstance.BackgroundTransparency = 1
	self:DisableChangeReplication("Theme")
	self.Theme = "CutCorners"
	self:DisableChangeReplication("SubTheme")
	self.SubTheme = "MainButton"
	self:DisableChangeReplication("BackgroundColor3")
	self:OnPropertyChanged("BackgroundColor3", function(imageColor: Color3)
		self.ImageColor3 = imageColor
	end)
	self:DisableChangeReplication("BackgroundTransparency")
	self:OnPropertyChanged("BackgroundTransparency", function(imageTransparency: number)
		self.ImageTransparency = imageTransparency
	end)
	self:DisableChangeReplication("SliceScaleMultiplier")
	self:OnPropertyChanged("SliceScaleMultiplier", function()
		self:UpdateSliceScale()
	end)
	self:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:UpdateSliceScale()
	end)
	self:OnPropertyChanged("Theme", function()
		self:UpdateTheme()
	end)
	self:OnPropertyChanged("SubTheme", function()
		self:UpdateTheme()
	end)
	self.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	self.BackgroundTransparency = 0
	self.ScaleType = Enum.ScaleType.Slice
	self.SliceScaleMultiplier = 1
	self.Size = UDim2.new(0, 100, 0, 100)
	self:UpdateTheme()
end

function v2:UpdateSliceScale()
	local v3 = v2.Themes[self.Theme][self.SubTheme]
	self.SliceScale = math.min(self.AbsoluteSize.X, self.AbsoluteSize.Y) * v3.SliceScaleMultiplier * (self.SliceScaleMultiplier or 1)
end

function v2:UpdateTheme()
	local theme = v2.Themes[self.Theme]

	if not theme then
		error((`Unknown theme: {self.Theme}`))
	end

	local v3 = theme[self.SubTheme]

	if not v3 then
		error((`Unknown subtheme: {self.SubTheme}`))
	end

	self.Image = v3.Image
	self.SliceCenter = v3.SliceCenter
	self:UpdateSliceScale()
end

return (NexusInstance.ToInstance(v2))