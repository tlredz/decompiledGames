local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)

local function renderlerp(clone, cFrame, primaryPart, p, quad, out, p2, p3, instance)
	local renderSteppedConnection = nil
	local total = 0
	local v = false
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if clone and cFrame and primaryPart then
			if p3 == true and instance then
				if instance.Parent == nil then
					v = true
					renderSteppedConnection:Disconnect()
				else
					local _, v2, _ = CFrame.lookAt(instance.PrimaryPart.Position, primaryPart.CFrame.Position):ToOrientation()
					local X = primaryPart.CFrame.Position.X
					local Y = primaryPart.CFrame.Position.Y
					local Z = primaryPart.CFrame.Position.Z
					local cFrame2 = instance.PrimaryPart.CFrame
					local v3 = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v2, 0)
					total += dt
					local v4 = total / 0.5
					local value = TweenService:GetValue(math.min(total / 0.5, 1), quad, out)
					local lerped = cFrame2.Position:Lerp(v3.Position, value)
					local lerped2 = cFrame2.Rotation:Lerp(v3.Rotation, value)
					clone:PivotTo(CFrame.new(lerped) * lerped2)

					if v4 >= 1 then
						v = true
						renderSteppedConnection:Disconnect()
					end
				end
			else
				total += dt
				local v2 = total / p
				local value = TweenService:GetValue(math.min(total / p, 1), quad, out)
				local lerped = cFrame.Position:Lerp(primaryPart.Position, value)
				local lerped2 = cFrame.Rotation:Lerp(primaryPart.Rotation, value)
				clone:PivotTo(CFrame.new(lerped) * lerped2)

				if v2 >= 1 then
					v = true
					renderSteppedConnection:Disconnect()
				end
			end
		else
			v = true
			renderSteppedConnection:Disconnect()
		end
	end)

	if p2 then
		while not v do
			task.wait()
		end
	end
end

return {
	RenderObject = function(list)
		local v, v2, clone, attachmentL0, skin
		local controlFlowState = 9

		while true do
			if controlFlowState == 0 then
				break
			end

			if controlFlowState == 1 then
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				clone = game.ReplicatedStorage.Parts.ScrapsTail.Default:Clone()
				v:WaitForChild("Torso")
				controlFlowState = 5
				continue
			else
				if controlFlowState == 2 then
					break
				end

				if controlFlowState == 3 then
					attachmentL0 = v.RootPart:FindFirstChild("AttachmentL0", true)

					if attachmentL0 then
						controlFlowState = 4
					else
						controlFlowState = 6
					end

					continue
				elseif controlFlowState == 4 then
					local config = v:WaitForChild("Config")
					local currentSkin = v:GetAttribute("CurrentSkin")
					local moduleName = config:WaitForChild("ModuleName")
					clone.PrimaryPart.Anchored = true
					clone.Parent = workspace
					clone.PrimaryPart.CFrame = v.PrimaryPart.CFrame
					clone.Base.RopeConstraint.Attachment0 = attachmentL0
					skin = currentSkin ~= "Default" and TowerLUT:GetSkin(moduleName.Value, currentSkin)

					if skin then
						controlFlowState = 8
					else
						controlFlowState = 7
					end

					continue
				elseif controlFlowState == 5 then
					if v.Parent then
						controlFlowState = 3
					else
						controlFlowState = 2
					end

					continue
				else
					if controlFlowState == 6 then
						controlFlowState = 5
						continue
					end

					if controlFlowState == 7 then
						Debris:AddItem(clone, 0.75)
						renderlerp(
							clone,
							v.PrimaryPart.CFrame,
							v2.PrimaryPart,
							0.25,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out,
							true,
							true,
							v
						)
						controlFlowState = 0
						continue
					elseif controlFlowState == 8 then
						local module = require(skin)
						module.UseAbility(v, clone)
						controlFlowState = 7
						continue
					else
						if controlFlowState ~= 9 then
							break
						end

						v = list[1]
						v2 = list[2]

						if v and v.Parent ~= nil then
							controlFlowState = 1
						else
							controlFlowState = 0
						end

						continue
					end
				end
			end
		end
	end
}