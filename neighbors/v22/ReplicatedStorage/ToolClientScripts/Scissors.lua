local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
require(ReplicatedStorage.Modules.Tool)
local scissors = ReplicatedStorage.Assets.Tools.Scissors
local Scissors = {}

function Scissors:HandleAnimations()
	local humanoidRootPart = self.HumanoidRootPart
	local character = self.Character

	if not (humanoidRootPart and character) then
		return
	end

	local humanoid = self.Humanoid
	local magnitude = humanoidRootPart.AssemblyLinearVelocity.Magnitude

	if self.Tool.Parent == character and humanoid:GetState() == Enum.HumanoidStateType.Running and not character:GetAttribute("UsingJetpack") then
		if not self.AnimationTracks.Idle.IsPlaying then
			self.AnimationTracks.Idle:Play()
		end

		if magnitude <= 0.15 then
			if self.AnimationTracks.Walk.IsPlaying then
				self.AnimationTracks.Walk:AdjustSpeed(1)
				self.AnimationTracks.Walk:Stop()
			end
		else
			if not self.AnimationTracks.Walk.IsPlaying then
				self.AnimationTracks.Walk:Play()
			end

			self.AnimationTracks.Walk:AdjustSpeed(magnitude / humanoid.WalkSpeed * 1.2)
		end
	else
		self.AnimationTracks.Idle:Stop()
		self.AnimationTracks.Walk:Stop()
	end
end

function Scissors:Initialize()
	local animator = self.Humanoid:WaitForChild("Animator")
	local track = animator:LoadAnimation(scissors:WaitForChild("Idle"))
	local track2 = animator:LoadAnimation(scissors:WaitForChild("Walk"))
	local track3 = animator:LoadAnimation(scissors:WaitForChild("Inspect"))
	track3.Priority = Enum.AnimationPriority.Action3
	self.AnimationTracks = {
		Idle = track,
		Walk = track2,
		Inspect = track3
	}
	self.InstanceAddedConnection = CollectionService:GetInstanceAddedSignal((`{self.Player.Name}_Limb`)):Connect(function(p)
		task.wait()
		p.CanCollide = true
	end)
	self.InputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.Y and not track3.IsPlaying then
			track3:Play()
		end
	end)
	task.spawn(function()
		while self and self.Tool and self.Tool.Parent do
			self:HandleAnimations()
			task.wait(0.05)
		end
	end)
end

function Scissors.Destroyed(data)
	if data.InstanceAddedConnection then
		data.InstanceAddedConnection:Disconnect()
	end

	if data.InputBeganConnection then
		data.InputBeganConnection:Disconnect()
	end

	for _, animationTrack in data.AnimationTracks do
		animationTrack:Stop()
	end
end

return Scissors