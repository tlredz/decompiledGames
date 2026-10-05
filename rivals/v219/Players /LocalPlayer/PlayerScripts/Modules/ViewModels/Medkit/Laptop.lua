local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
local Medkit = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Medkit)
local _ = {
	"rbxassetid://74022970304005",
	"rbxassetid://111187699136127",
	"rbxassetid://112954097793399",
	"rbxassetid://130172392204108",
	"rbxassetid://77908437197378",
	"rbxassetid://74137744110473",
	"rbxassetid://107310976599084",
	"rbxassetid://81382682259697",
	"rbxassetid://96751920594258",
	"rbxassetid://106881280278820",
	"rbxassetid://128246615590458",
	"rbxassetid://113969192009519",
	"rbxassetid://136604786024861",
	"rbxassetid://107331047330856"
}
local object = setmetatable({}, Medkit)
object.__index = object

function object.new(...)
	local self = setmetatable(Medkit.new(...), object)
	self._play_cat_gif_hash = 0
	self._cat_surface_gui = self.ItemModel:WaitForChild("MedkitTop"):WaitForChild("Screen"):WaitForChild("CatGui")
	self._cat_image_label = self._cat_surface_gui:WaitForChild("Frame"):WaitForChild("ImageLabel"):WaitForChild("Picture"):WaitForChild("ImageLabel")
	self._use_surface_gui = self.ItemModel:WaitForChild("MedkitTop"):WaitForChild("Screen"):WaitForChild("UseGui")
	self._use_bar = self._use_surface_gui:WaitForChild("Frame"):WaitForChild("Frame"):WaitForChild("Bar")
	self._use_text = self._use_surface_gui:WaitForChild("Frame"):WaitForChild("Progress")
	self._use_background = self._use_surface_gui:WaitForChild("Frame"):WaitForChild("ImageLabel")
	self._use_effect_hash = 0
	self._use_tween = nil
	self:_Init()
	return self
end

function object:_CancelTween()
	if self._use_tween then
		self._use_tween:Pause()
		self._use_tween = nil
	end
end

function object:_UpdateUseBar()
	self._use_text.Text = self._use_bar.AbsoluteSize.X <= 1 and "• • •" or math.floor(self._use_bar.AbsoluteSize.X / self._use_bar.Parent.AbsoluteSize.X * 100) .. "%"
end

function object:_UpdateUseGui()
	self:_CancelTween()
	self._use_effect_hash += 1
	local _use_effect_hash = self._use_effect_hash
	local isAnimationPlaying = self:IsAnimationPlaying("Use")
	local v = not isAnimationPlaying or self:IsAnimationPlaying("UseQuick")
	self._use_surface_gui.Enabled = isAnimationPlaying or v

	if not self._use_surface_gui.Enabled then
		return
	end

	task.spawn(function()
		while not self._destroyed and self._use_effect_hash == _use_effect_hash do
			self._use_background.Image = "rbxassetid://134936596399147"
			wait(0.1)

			if self._destroyed or self._use_effect_hash ~= _use_effect_hash then
				break
			end

			self._use_background.Image = "rbxassetid://115756225131937"
			wait(0.1)
		end
	end)
	self._use_bar.Size = UDim2.new(0, 0, 1, 0)

	if isAnimationPlaying then
		local v2 = AnimationLibrary.Info[self.Info.Animations.Use]
		local v3 = 2.07765 / v2.Speed
		wait(v3)

		if self._destroyed or self._use_effect_hash ~= _use_effect_hash then
			return
		end

		self._use_tween = TweenService:Create(
			self._use_bar,
			TweenInfo.new(v2.ActionTimestamp - v3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(1, 0, 1, 0)
			}
		)
		self._use_tween:Play()
	elseif v then
		local v2 = AnimationLibrary.Info[self.Info.Animations.UseQuick]
		wait(v2.ActionTimestamp)

		if self._destroyed or self._use_effect_hash ~= _use_effect_hash then
			return
		else
			self._use_bar.Size = UDim2.new(1, 0, 1, 0)
		end
	end
end

function object:_UpdateCatGui()
	self._play_cat_gif_hash += 1
	local _play_cat_gif_hash = self._play_cat_gif_hash
	self._cat_surface_gui.Enabled = self:IsAnimationPlaying("RareInspect")

	if not self._cat_surface_gui.Enabled then
		return
	end

	local v = 1

	while not self._destroyed and self:IsAnimationPlaying("RareInspect") and self._play_cat_gif_hash == _play_cat_gif_hash do
		local v2 = (v - 1) % 4
		local v3 = math.floor((v - 1) / 4)
		self._cat_image_label.Position = UDim2.new(v2 * -1, 0, v3 * -1, 0)
		v = v % 14 + 1
		wait(0.1)
	end
end

function object:_Setup()
	self._cat_image_label.Image = "rbxassetid://120426879154579"
	self._cat_image_label.Size = UDim2.new(
		self._cat_image_label.Size.X.Scale * 4,
		self._cat_image_label.Size.X.Offset * 4,
		self._cat_image_label.Size.Y.Scale * 4,
		self._cat_image_label.Size.Y.Offset * 4
	)
end

function object:_Init()
	self.AnimationPlayed:Connect(function(p)
		if p == "RareInspect" then
			self:_UpdateCatGui()
		elseif p == "Use" or p == "UseQuick" then
			self:_UpdateUseGui()
		end
	end)
	self.AnimationStopped:Connect(function(p)
		if p == "RareInspect" then
			self:_UpdateCatGui()
		elseif p == "Use" or p == "UseQuick" then
			self:_UpdateUseGui()
		end
	end)
	self.Equipped:Connect(function()
		self:_CancelTween()
	end)
	self._use_bar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateUseBar()
	end)
	self:_Setup()
end

return object