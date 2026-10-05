local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
require(packages.Net)
local Trove = require(packages.Trove)
require(ReplicatedStorage.shared.modules.FishModel)
local QuestShared = require(ReplicatedStorage.shared.modules.QuestShared)
local SharedWeather = require(ReplicatedStorage.shared.modules.SharedWeather)
local color = Color3.fromRGB(255, 218, 143)
local color2 = Color3.fromRGB(121, 226, 255)
local color3 = Color3.fromRGB(255, 123, 123)
local v = Component.new({
	Tag = "AncientIdol",
	Ancestors = { workspace }
})
Random.new()

function v:Construct()
	self.Trove = Trove.new()
	self.EyesFlashing = false
	self.Eyes = self.Instance:WaitForChild("Head")

	if not self.Eyes:GetAttribute("OriginalColor") then
		self.Eyes:SetAttribute("OriginalColor", self.Eyes.Color)
	end

	if not self.Eyes:WaitForChild("PointLight"):GetAttribute("OriginalColor") then
		self.Eyes.PointLight:SetAttribute("OriginalColor", self.Eyes.PointLight.Color)
	end
end

function v:Update()
	local _, v2, v3 = QuestShared:GetCurrentSeriesQuest(localPlayer, self.Instance:GetAttribute("UID"))

	if v3 >= 11 and SharedWeather.IsActive("Raging Squall") and (v3 ~= 15 or not (v2 >= 4)) then
		self.EyesFlashing = 2
		self.Eyes.PointLight.Enabled = true
		self.Eyes.PointLight.Brightness = 5
	elseif v3 >= 6 and v3 <= 10 and SharedWeather.IsActive("Tropical Squall") then
		self.EyesFlashing = 1
		self.Eyes.PointLight.Enabled = true
		self.Eyes.PointLight.Brightness = 5
	elseif v3 > 5 then
		self.EyesFlashing = nil
		self.Eyes.Color = self.Eyes:GetAttribute("OriginalColor") or self.Eyes.Color
		self.Eyes.Material = Enum.Material.Neon
		self.Eyes.PointLight.Enabled = true
		self.Eyes.PointLight.Brightness = 1.4
	else
		self.EyesFlashing = nil
		self.Eyes.Color = self.Eyes:GetAttribute("OriginalColor") or self.Eyes.Color
		self.Eyes.PointLight.Color = self.Eyes.PointLight:GetAttribute("OriginalColor") or self.Eyes.PointLight.Color
		self.Eyes.Material = Enum.Material.Slate
		self.Eyes.PointLight.Enabled = false
	end
end

function v.RenderSteppedUpdate(p)
	if not p.EyesFlashing then
		return
	end

	local v2 = math.abs(1 - tick() * 2 % 2)
	local v4

	if p.EyesFlashing == 2 then
		v4 = color3
	else
		v4 = color2
	end

	local lerped = color:Lerp(v4, v2)
	p.Eyes.Color = lerped
	p.Eyes.PointLight.Color = lerped
end

function v:Start()
	self:Update()
	local dataPath = QuestShared:ReadDataPath(localPlayer, QuestShared.QuestsFolder.Finished)

	if dataPath then
		self.Trove:Add(dataPath.ChildAdded:Connect(function()
			self:Update()
		end))
	end

	self.Trove:Add(SharedWeather.WeatherChanged:Connect(function(p)
		if p == "squall" then
			self:Update()
		end
	end))
end

function v.Stop(p)
	p.Trove:Clean()
end

return v