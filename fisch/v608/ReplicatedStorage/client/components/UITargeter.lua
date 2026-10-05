local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local v = Component.new({
	Tag = "UITargeter"
})

function v:Construct()
	self.trove = Trove.new()
	self.target = self.Instance.Value.Value
end

function v:Start()
	local RunService = game:GetService("RunService")
	local currentCamera = workspace.CurrentCamera
	local textLabel = self.Instance:FindFirstChildWhichIsA("TextLabel")

	if textLabel then
		self.trove:Add(RunService.PostSimulation:Connect(function()
			local target = self.target

			if not (target and target:IsDescendantOf(workspace)) then
				textLabel.Visible = false
				return
			end

			textLabel.Visible = true
			local position = self.Instance.Parent.Position
			local position2 = target.PrimaryPart.Position
			local magnitude = (position2 - position).Magnitude

			if magnitude < 8 or magnitude > 250 then
				textLabel.Visible = false
				self:Stop()
			end

			local unit = (position2 - position).Unit
			local vectorToObjectSpace = currentCamera.CFrame:VectorToObjectSpace(unit)
			textLabel.Rotation = math.deg((math.atan2(vectorToObjectSpace.X, -vectorToObjectSpace.Z)))
		end))
	else
		warn("UITargeter: No TextLabel found under instance", self.Instance)
	end
end

function v:Stop()
	self.trove:Destroy()
end

return v