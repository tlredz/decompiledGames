local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local StarterPlayer = game:GetService("StarterPlayer")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "HotSauceDispenser"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local v2 = nil
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "StartHotSauceAnimation", function()
		local character = localPlayer.Character

		if not character then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local animator = character:FindFirstChild("Animator", true)

		if not (humanoid and humanoidRootPart and animator) then
			return
		end

		humanoidRootPart.CFrame = self.Instance.CFrame * CFrame.new(0, 0, 2)
		humanoid.WalkSpeed = 0

		if v2 then
			v2:Play()
		else
			local v3 = self._Janitor:Add(Instance.new("Animation"))
			v3.Name = "HotSauceAnimation"
			v3.AnimationId = "rbxassetid://91319120753814"
			local v4 = self._Janitor:Add(animator:LoadAnimation(v3))
			v4:Play()
			v2 = v4
		end

		ContextActionService:BindAction("HotSauceDispenserCancel", function(_, p2, _)
			if p2 == Enum.UserInputState.Begin then
				Remotes.fireServerComponent(self.Instance, "CancelHotSauceAnimation")
			end

			return Enum.ContextActionResult.Sink
		end, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "StopHotSauceAnimation", function()
		local character = localPlayer.Character

		if character ~= nil then
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoid ~= nil then
				humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed
			end
		end

		if v2 ~= nil then
			v2:Stop()
		end

		ContextActionService:UnbindAction("HotSauceDispenserCancel")
	end))
end

function v:Stop()
	ContextActionService:UnbindAction("HotSauceDispenserCancel")
	self._Janitor:Destroy()
end

return v