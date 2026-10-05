local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local clone = nil
local attachment = nil
local attachment2 = nil
return {
	setupAll = function()
		local panicBorder = GameContext.Gui.PanicBorder
		workspace.Info.Panic.Changed:Connect(function()
			if workspace.Info.Panic.Value == true then
				local elevator = workspace.Elevators:WaitForChild("Elevator", 5)

				if not elevator then
					return
				end

				workspace.Info.ElevatorPrompt.Position = elevator.PrimaryPart.Position + createVector(0, 10, 0)
				workspace.Info.ElevatorPrompt.ClaimIcon.Enabled = true
				TweenService:Create(panicBorder, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
					ImageTransparency = 0.4
				}):Play()
				Audio:PlayOne("Sounds.UI.Alerts.Panic1")
				Audio:PlayOne("Sounds.UI.Alerts.Panic2")
				local character = GameContext.Character

				if character then
					local success, result = pcall(function()
						clone = ReplicatedStorage.Parts.Beam:Clone()
						attachment = Instance.new("Attachment")
						attachment2 = Instance.new("Attachment")
						attachment.Parent = character.PrimaryPart
						clone.Parent = character.PrimaryPart
						clone.Attachment0 = attachment
						clone.Attachment1 = attachment2
						attachment2.Parent = elevator.PrimaryPart
						clone.Enabled = true
					end)

					if not success then
						warn(result)
					end
				end
			else
				workspace.Info.ElevatorPrompt.ClaimIcon.Enabled = false
				TweenService:Create(panicBorder, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageTransparency = 1
				}):Play()
				local success, result = pcall(function()
					if clone then
						clone:Destroy()
					end

					if attachment then
						attachment:Destroy()
					end

					if attachment2 then
						attachment2:Destroy()
					end
				end)

				if not success then
					warn(result)
				end
			end
		end)
	end
}