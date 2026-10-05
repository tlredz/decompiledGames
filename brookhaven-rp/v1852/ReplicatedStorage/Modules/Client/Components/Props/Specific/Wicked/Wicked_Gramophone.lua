local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MusicController = require(ReplicatedStorage.Modules.Client.Music.MusicController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local CharacterUtil = require(ReplicatedStorage.Modules.Shared.Utils.CharacterUtil)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "Wicked_Gramophone"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local clickDetector = self.Instance:FindFirstChild("ClickDetector")
	local genericBoombox = self.Instance:FindFirstChild("GenericBoombox", true)
	local animation = self.Instance:FindFirstChild("Animation")
	local animationController = self.Instance:FindFirstChild("AnimationController")

	if not clickDetector then
		warn("Wicked_Gramophone: ClickDetector not found")
		return
	end

	if not genericBoombox then
		warn("Wicked_Gramophone: GenericBoombox not found")
		return
	end

	if not animation then
		warn("Wicked_Gramophone: Animation not found")
		return
	end

	if not animationController then
		warn("Wicked_Gramophone: AnimationController not found")
		return
	end

	local animator = animationController:FindFirstChild("Animator")

	if not animator then
		warn("Wicked_Gramophone: Animator not found")
		return
	end

	local v2 = self._Janitor:Add(animator:LoadAnimation(animation))
	self._Janitor:Add(clickDetector.MouseClick:Connect(function()
		self:Clicked()
	end))
	self._Janitor:Add(genericBoombox:GetPropertyChangedSignal("Playing"):Connect(function()
		if genericBoombox.IsPlaying then
			v2:Play()
		else
			v2:Stop()
		end
	end))
end

function v:Clicked()
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local distanceTo = CharacterUtil.distanceTo(character, self.Instance, "UpperTorso")

	if distanceTo == nil or distanceTo >= 37 then
		return
	end

	MusicController.OpenMusicMenu("Wicked_Gramophone", AdFeatures.CAR_MUSIC, "WickedGramophone", self.Instance)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v