local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local v = Component.new({
	Tag = "EggLauncher_LaunchedEgg"
})

function v.Start(p)
	if p.Instance.Name ~= Players.LocalPlayer.Name then
		return
	end

	p.Instance.Touched:Connect(function(part)
		if not p.Instance:WaitForChild("EggLauncherSplat", 0.25) then
			Debris:AddItem(p.Instance, 0)
		end

		if part:IsA("BasePart") and not (Players.LocalPlayer.Character and part:IsDescendantOf(Players.LocalPlayer.Character)) then
			local closestPointOnSurface = part:GetClosestPointOnSurface(p.Instance.Position)
			local raycastResult = workspace:Raycast(
				p.Instance.Position,
				(closestPointOnSurface - p.Instance.Position) * 20
			)

			if raycastResult and raycastResult.Position then
				p.Instance.Transparency = 1
				local eggLauncherSplat = p.Instance:FindFirstChild("EggLauncherSplat")

				if eggLauncherSplat then
					local clone = eggLauncherSplat:Clone()
					Debris:AddItem(eggLauncherSplat, 0)
					local decal = clone:FindFirstChild("Decal")

					if decal then
						decal.Transparency = 0
					end

					clone.Anchored = true
					local v2 = math.random(90, 125) / 100
					clone.Size *= Vector3.new(v2, 0, v2)
					clone.CFrame = CFrame.new(
						raycastResult.Position - (closestPointOnSurface - p.Instance.Position).Unit * 0.2,
						raycastResult.Position + raycastResult.Normal
					) * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone.Parent = workspace.WorkspaceCom
					local attachment = clone:FindFirstChild("Attachment")

					if attachment then
						for _, child in attachment:GetChildren() do
							if child:IsA("ParticleEmitter") then
								child:Emit(child:GetAttribute("EmitCount"))
							elseif child:IsA("Sound") then
								child:Play()
							end
						end
					end

					task.delay(5, function()
						Debris:AddItem(clone, 0)
					end)
					p.Instance.AncestryChanged:Connect(function()
						if not p.Instance.Parent then
							Debris:AddItem(clone, 0.25)
						end
					end)
				end
			end
		end
	end)
end

return v