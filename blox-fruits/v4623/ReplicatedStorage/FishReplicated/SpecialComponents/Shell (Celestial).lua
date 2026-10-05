local createVector = vector.create
local Component = require(game.ReplicatedStorage.Modules.Component)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local v = Component.new({
	Tag = "Shell (Celestial)",
	Ancestors = { workspace.Characters }
})

function v:Construct()
	self.Maid = Maid.new()
end

function v:DestroyVFXTask()
	local vfxTask = self.vfxTask

	if vfxTask then
		task.defer(task.cancel, vfxTask)

		if vfxTask == self.vfxTask then
			self.vfxTask = nil
		end
	end

	self.Maid:DoCleaning()
end

function v:RestartWaiting()
	self:DestroyVFXTask()

	if not self.Enabled then
		return
	end

	self.vfxTask = task.delay(20, function()
		if self.Humanoid:GetMoveVelocity().Magnitude > 5 then
			return self:RestartWaiting()
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Boats, workspace.Map }
		local raycastResult = workspace:Raycast(
			self.Character:GetPivot().Position,
			createVector(-0, -10, -0),
			raycastParams
		)

		if not (raycastResult and raycastResult.Instance) then
			return self:RestartWaiting()
		end

		local folder = Instance.new("Folder", workspace._WorldOrigin)
		self.Maid:GiveTask(folder)
		local clone = script.CorruptedVortexNoLightning:Clone()
		clone.Parent = folder
		clone.CFrame = CFrame.new(
			raycastResult.Position - raycastResult.Normal * 2,
			raycastResult.Position + raycastResult.Normal * 3
		)
		local TweenService = game:GetService("TweenService")
		TweenService:Create(clone, TweenInfo.new(4, Enum.EasingStyle.Linear), {
			CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 3)
		}):Play()
	end)
end

function v:Start()
	self.Enabled = true
	self.Character = self.Instance.Parent
	warn(self.Character)
	self.Humanoid = self.Character:WaitForChild("Humanoid", 30)

	if not self.Enabled then
		return
	end

	self.conn = self.Humanoid.Changed:Connect(function(_)
		self:RestartWaiting()
	end)
	self:RestartWaiting()
end

function v:Stop()
	self.Enabled = false

	if self.conn then
		self.conn:Disconnect()
		self.conn = nil
	end

	self:DestroyVFXTask()
end

return v