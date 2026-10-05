local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local exalted_rod_animation = ReplicatedStorage:WaitForChild("events"):WaitForChild("exalted_rod_animation")
local assets = require(ReplicatedStorage.shared.utils.assets)
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
return {
	Start = function(_)
		exalted_rod_animation.OnClientEvent:Connect(function()
			local exaltedPuzzle = workspace.world.map["Gamma Grotto"]:WaitForChild("ExaltedPuzzle")
			local clone = assets.getAsync("rod", "Rod Of The Exalted One"):WaitForChild("Rod Of The Exalted One"):Clone()
			clone.PrimaryPart.Anchored = true
			clone:PivotTo(exaltedPuzzle.ExaltedRodAnimation.Part0:GetPivot())
			clone.Parent = workspace.CurrentCamera
			TweenService:Create(clone.PrimaryPart, tweenInfo, {
				CFrame = exaltedPuzzle.ExaltedRodAnimation.Part1:GetPivot()
			}):Play()
			task.delay(tweenInfo.Time, function()
				script.Appear:Play()
			end)
			task.delay(10, function()
				for _, descendant in pairs(clone:GetDescendants()) do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") then
						TweenService:Create(descendant, TweenInfo.new(1), {
							Transparency = 1
						}):Play()
					elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
						descendant.Enabled = false
					end
				end

				task.wait(2)
				clone:Destroy()
			end)
		end)
	end
}