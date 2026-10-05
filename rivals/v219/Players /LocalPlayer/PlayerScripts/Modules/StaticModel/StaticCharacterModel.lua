local Players = game:GetService("Players")
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local StaticModel = require(Players.LocalPlayer.PlayerScripts.Modules.StaticModel)
local object = setmetatable({}, StaticModel)
object.__index = object

function object.new(userID)
	local self = setmetatable(
		StaticModel.new(FighterController:GenerateCharacterModel(userID).Template:Clone()),
		object
	)
	self.UserID = userID
	self:_Init()
	return self
end

function object:_SetupCharacterModel()
	local characterModel = FighterController:GenerateCharacterModel(self.UserID, true)

	if self._destroyed or not characterModel then
		return
	end

	local clone = characterModel.Template:Clone()
	clone.HumanoidRootPart.Anchored = true
	clone.PrimaryPart = nil
	clone.WorldPivot = clone.HumanoidRootPart.CFrame * CFrame.new(0, 1.5, 0)
	clone:PivotTo(self.Model:GetPivot())
	clone:ScaleTo(clone:GetScale() * self.Model:GetScale() / self._original_scale)
	clone.Parent = self.Model.Parent
	task.defer(pcall, function()
		if clone:FindFirstChild("Animate") then
			clone.Animate:Destroy()
		end

		for _, v in pairs(clone.Humanoid:GetPlayingAnimationTracks()) do
			v:Stop()
		end

		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://507766388"
		clone.Humanoid:LoadAnimation(animation):Play()
	end)
	self.Model:Destroy()
	self.Model = clone
	self._original_scale = clone:GetScale()
end

function object:_Setup()
	self.Model.PrimaryPart = self.Model:FindFirstChild("HumanoidRootPart")
end

function object:_Init()
	self:_Setup()
	task.spawn(self._SetupCharacterModel, self)
end

return object