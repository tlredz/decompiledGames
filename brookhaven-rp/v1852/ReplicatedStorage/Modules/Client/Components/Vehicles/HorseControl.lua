local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "HorseControl"
})
local v2 = {
	[Enum.HumanoidStateType.Jumping] = true,
	[Enum.HumanoidStateType.Landed] = true,
	[Enum.HumanoidStateType.Running] = true
}

function v:Construct()
	self._Janitor = Janitor.new()
	self.MountCollider = self.Instance:WaitForChild("MountCollider")
end

function v:TransitionTo(activeState)
	if activeState ~= self.activeState then
		if v2[activeState] then
			Remotes.fireServerComponent(self.Instance, "ChangeState", activeState)
		end

		self.activeState = activeState
	end
end

function v:Start()
	local humanoid = self.Instance:WaitForChild("Humanoid")
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "HorseMount", function()
		if self.stateChangedConn then
			self._Janitor:Remove(self.stateChangedConn)
			self.stateChangedConn:Disconnect()
		end

		local character = Players.LocalPlayer.Character

		if not character then
			return
		end

		character:SetAttribute("IsOnHorse", true)
		local humanoid2 = character:FindFirstChild("Humanoid")
		humanoid2:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		humanoid2:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid2.EvaluateStateMachine = false
		workspace.CurrentCamera.CameraSubject = humanoid
		humanoid.CameraOffset = createVector(0, 1.2, 0)
		self.diedConnection = humanoid2.HealthChanged:Connect(function(p)
			if p > 0 then
				return
			end

			local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
			LegacyGame8Settings.HorseRemote:FireServer("HorseDismount")
		end)
		self.moveDirectionRelayConnection = humanoid2:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			local unit = CFrame.new(createVector(0, 0, 0), humanoid2.MoveDirection).LookVector.Unit
			humanoid:Move(unit ~= humanoid2.MoveDirection and createVector(0, 0, 0) or unit)
		end)
		self.jumpConnection = UserInputService.JumpRequest:Connect(function()
			humanoid.Jump = true
		end)
		self.stateChangedConn = humanoid.StateChanged:Connect(function(_, p)
			self:TransitionTo(p)
		end)
		self.cameraUpdateConn = RunService.RenderStepped:Connect(function()
			if not self.Instance.PrimaryPart then
				return
			end

			for _, part in character:GetDescendants() do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = self.Instance.PrimaryPart.LocalTransparencyModifier
				end
			end

			for _, part in self.Instance:GetDescendants() do
				if not (part:IsA("BasePart") and part ~= self.Instance.PrimaryPart) then
					continue
				end

				local v3 = part
				task.defer(function()
					v3.LocalTransparencyModifier = 0
				end)
			end
		end)
		self.Instance:AddTag("MusicNoMotorVehicle")
	end))
	local now = 0
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "HorseDismount", function()
		local character = Players.LocalPlayer.Character

		if character then
			character:SetAttribute("IsOnHorse", false)
		end

		if self.stateChangedConn then
			if not character then
				return
			end

			local humanoid2 = character:FindFirstChild("Humanoid")
			humanoid2.EvaluateStateMachine = true
			humanoid2:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
			humanoid2:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
			humanoid2:ChangeState(Enum.HumanoidStateType.Freefall)
			task.defer(function()
				humanoid2:Move(createVector(0, 0, 0))
			end)
			humanoid:Move(createVector(0, 0, 0))
			humanoid:ChangeState(Enum.HumanoidStateType.Landed)
			self.MountCollider.Anchored = true
			task.delay(0.1, function()
				self.MountCollider.Anchored = false
			end)

			for _, part in character:GetDescendants() do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 0
				end
			end

			workspace.CurrentCamera.CameraSubject = humanoid2
			now = os.clock()
			self._Janitor:Remove(self.stateChangedConn)
			self.stateChangedConn:Disconnect()
			self.moveDirectionRelayConnection:Disconnect()
			self.jumpConnection:Disconnect()
			self.diedConnection:Disconnect()
			self.cameraUpdateConn:Disconnect()
		end

		self.Instance:RemoveTag("MusicNoMotorVehicle")
	end))
	self._Janitor:Add(self.MountCollider.Touched:connect(function(instance)
		if self.PlayerOnHorse or instance.Name ~= "HumanoidRootPart" or os.clock() - now < 1 or not game.Players.LocalPlayer.Character then
			return
		end

		local parent = instance.Parent

		if parent and parent ~= game.Players.LocalPlayer.Character or self.Instance:WaitForChild("Owner").Value ~= game.Players.LocalPlayer then
			return
		end

		local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
		LegacyGame8Settings.HorseRemote:FireServer("Mount")
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v