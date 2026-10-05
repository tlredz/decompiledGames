local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local StarterPlayer = game:GetService("StarterPlayer")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "IceCreamMachine"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local v2 = nil
	local v3 = false
	self._Janitor:Add(UserInputService.JumpRequest:Connect(function()
		if not v3 then
			return
		end

		Remotes.fireServerComponent(self.Instance, "CancelAnimation")
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "StartAnimation", function()
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

		local machinePart = self.Instance:FindFirstChild("MachinePart")

		if machinePart ~= nil then
			humanoidRootPart.CFrame = machinePart.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(0, 3.141592653589793, 0)
		end

		humanoid.WalkSpeed = 0

		if v2 then
			v2:Play()
		else
			local v4 = self._Janitor:Add(Instance.new("Animation"))
			v4.Name = "IceCreamAnimation"
			v4.AnimationId = "rbxassetid://91319120753814"
			local v5 = self._Janitor:Add(animator:LoadAnimation(v4))
			v5:Play()
			v2 = v5
		end

		ContextActionService:BindAction("JumpRequest", function(_, p2, _)
			if p2 == Enum.UserInputState.Begin then
				Remotes.fireServerComponent(self.Instance, "CancelAnimation")
			end

			return Enum.ContextActionResult.Sink
		end, false, Enum.KeyCode.Space)
		v3 = true
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "StopAnimation", function()
		v3 = false
		ContextActionService:UnbindAction("JumpRequest")
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
	end))
end

function v:Stop()
	ContextActionService:UnbindAction("JumpRequest")
	self._Janitor:Destroy()
end

return v