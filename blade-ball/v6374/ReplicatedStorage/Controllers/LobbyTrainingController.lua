local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Observers)
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local remoteEvent = v:RemoteEvent("LobbyTrainingDamageEffect")
local VFX = ReplicatedStorage2.Assets.LobbyTraining.VFX
local damageEffect = ReplicatedStorage2.Assets.DamageEffect
local soundPart = ReplicatedStorage2.Assets.SoundPart
local localPlayer = Players.LocalPlayer
return {
	Start = function(_)
		local clone = ReplicatedStorage2.Assets.FlatHealthBar:Clone()
		local thread = nil
		localPlayer:GetAttributeChangedSignal("LobbyTraining"):Connect(function()
			if not localPlayer:GetAttribute("LobbyTraining") and clone.Parent then
				if thread then
					v2.Thread.SafeCancel(thread)
					thread = nil
				end

				clone.Parent = nil
			end
		end)
		remoteEvent.OnClientEvent:Connect(function(instance, p: number)
			if thread then
				v2.Thread.SafeCancel(thread)
				thread = nil
			end

			local health = instance:GetAttribute("Health")
			local v3 = 1 - health / instance:GetAttribute("MaxHealth")
			clone.ProgressBar.TextLabel.Text = ""

			if health > 0 then
				local basePart = instance:FindFirstChildWhichIsA("BasePart") or instance:FindFirstChildWhichIsA("Model") or instance
				local parent = clone.Parent
				clone.Parent = basePart
				local v4 = parent == basePart and 0.5 or 0
				clone.ProgressBar.Holder:TweenPosition(
					UDim2.fromScale(-v3, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Sine,
					v4,
					true
				)
				clone.ProgressBar.Holder.Fill:TweenPosition(
					UDim2.fromScale(v3, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Sine,
					v4,
					true
				)
				local v5 = clone
				local v7

				if basePart:IsA("Model") then
					v7 = basePart:GetExtentsSize().Y
				else
					v7 = basePart.Size.Y
				end

				v5.StudsOffset = Vector3.new(0, v7, 0)
				thread = task.delay(5, function()
					clone.Parent = nil
				end)
			else
				clone.Parent = nil
			end

			local sound = instance:FindFirstChildWhichIsA("Sound", true)

			if sound then
				local clone2 = soundPart:Clone()
				clone2:PivotTo(instance:GetPivot())
				clone2.Parent = workspace.Runtime
				local clone3 = sound:Clone()
				clone3.Parent = clone2
				clone3.Ended:Connect(function()
					task.delay(0.3, function()
						clone2:Destroy()
						clone3:Destroy()
					end)
				end)
				clone3:Play()
			end

			if health <= 0 then
				local clone2 = VFX:Clone()
				clone2.Size = createVector(1, 1, 1) * instance.Size.X * 4
				clone2:PivotTo(instance:GetPivot())
				clone2.Parent = workspace.Runtime
				v2.Visual:PlayEffects(clone2)
				task.delay(3, function()
					clone2:Destroy()
				end)
			end

			local clone2 = damageEffect:Clone()
			clone2.BillboardGui.Size += UDim2.fromOffset(20, 20)
			local canvasGroup = clone2.BillboardGui.CanvasGroup
			canvasGroup.TextLabel.Text = `-{math.round(p)}`
			local pivot = instance:GetPivot()
			clone2.BillboardGui.AlwaysOnTop = true
			clone2:PivotTo(pivot)
			clone2.Parent = workspace.Runtime
			local vector2 = Vector3.new((math.random() - 0.5) * 35, 24, (math.random() - 0.5) * 35)
			canvasGroup.Size = UDim2.fromScale(0, 0)
			canvasGroup.Rotation = math.random(25, 45) * (math.random(0, 1) * 2 - 1)
			TweenService:Create(canvasGroup, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(1, 1)
			}):Play()
			TweenService:Create(
				canvasGroup,
				TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0.15),
				{
					Rotation = 0
				}
			):Play()
			TweenService:Create(
				canvasGroup,
				TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0.85),
				{
					GroupTransparency = 1
				}
			):Play()
			local lastTime = os.clock()
			local postSimulationConnection = nil
			postSimulationConnection = RunService.PostSimulation:Connect(function()
				local v4 = (os.clock() - lastTime) / 1

				if not (v4 > 1) then
					clone2.CFrame = CFrame.new(pivot.Position + vector2 * v4 + createVector(0, -24, 0) * v4 ^ 2)
				elseif postSimulationConnection and postSimulationConnection.Connected then
					postSimulationConnection:Disconnect()
					clone2:Destroy()
				end
			end)
		end)
	end
}