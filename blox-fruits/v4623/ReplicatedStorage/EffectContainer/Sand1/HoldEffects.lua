workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.Debris
return function(player)
	local DELAY_DURATION = 0.7
	local subID = player.SubID or 1

	if subID == 1 then
		local character = player.Character
		local humanoid = player.Humanoid
		local holdValue = player.HoldValue

		if not (character and holdValue) then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local rightHand = character:FindFirstChild("RightHand")

		if not (humanoidRootPart and rightHand) then
			return
		end

		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
		TweenInfo.new(3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)

		if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 600 then
			return
		end

		local rightUpperArm = character:FindFirstChild("RightUpperArm")
		local rightLowerArm = character:FindFirstChild("RightLowerArm")
		local clone = script.Light.SandDust:Clone()
		clone.Parent = rightUpperArm
		local clone2 = script.Light.SandDust:Clone()
		clone2.Parent = rightLowerArm
		local clone3 = script.Light.sandhold:Clone()
		clone3.CFrame = rightHand.CFrame
		clone3.Parent = rightHand
		local v = Util.Sound:Play("SandFlightLoop", humanoidRootPart)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Name = "sandholdweldhold"
		weldConstraint.Parent = rightHand
		weldConstraint.Part0 = rightHand
		weldConstraint.Part1 = clone3
		local diedConnection = nil

		if humanoid then
			diedConnection = humanoid.Died:Connect(function()
				diedConnection:Disconnect()
			end)
		end

		local function running()
			local v2 = diedConnection and holdValue

			if v2 then
				if holdValue.Value == true then
					return character
				else
					return false
				end
			end

			return v2
		end

		while true do
			local v2 = diedConnection

			if v2 then
				if holdValue then
					if holdValue.Value == true then
						v2 = character
					else
						v2 = false
					end
				else
					v2 = holdValue
				end
			end

			if v2 and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil then
				task.wait()
			else
				if diedConnection then
					diedConnection:Disconnect()
				end

				if clone3 then
					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					if v then
						v:Destroy()
					end

					task.delay(DELAY_DURATION, function()
						if clone3 then
							clone3:Destroy()
						end
					end)
				end

				if weldConstraint then
					task.delay(DELAY_DURATION, function()
						if weldConstraint then
							weldConstraint:Destroy()
						end
					end)
				end

				if clone then
					clone:Destroy()
				end

				if clone then
					clone2:Destroy()
				end

				return
			end
		end
	elseif subID == 2 then
		local character = player.Character
		local humanoid = player.Humanoid
		local holdValue = player.HoldValue

		if character and humanoid and holdValue then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local rightHand = character:FindFirstChild("RightHand")

			if humanoidRootPart and rightHand then
				TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
				TweenInfo.new(3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)

				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 600 then
					return
				end

				local rightUpperArm = character:FindFirstChild("RightUpperArm")
				local rightLowerArm = character:FindFirstChild("RightLowerArm")
				local clone = script.Heavy.SandDust:Clone()
				clone.Parent = rightUpperArm
				local clone2 = script.Heavy.SandDust:Clone()
				clone2.Parent = rightLowerArm
				local clone3 = script.Heavy.sandhold:Clone()
				clone3.CFrame = rightHand.CFrame
				clone3.Parent = rightHand
				local v = Util.Sound:Play("SandFlightLoop", humanoidRootPart)
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Name = "sandholdweldhold"
				weldConstraint.Parent = rightHand
				weldConstraint.Part0 = rightHand
				weldConstraint.Part1 = clone3
				local diedConnection = nil

				if humanoid then
					diedConnection = humanoid.Died:Connect(function()
						diedConnection:Disconnect()
					end)
				end

				local function running()
					local v2 = diedConnection and holdValue

					if v2 then
						if holdValue.Value == true then
							return character
						else
							return false
						end
					end

					return v2
				end

				while true do
					local v2 = diedConnection

					if v2 then
						if holdValue then
							if holdValue.Value == true then
								v2 = character
							else
								v2 = false
							end
						else
							v2 = holdValue
						end
					end

					if v2 and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil then
						task.wait()
					else
						if diedConnection then
							diedConnection:Disconnect()
						end

						if not rightHand then
							break
						end

						if clone3 then
							for _, emitter in pairs(clone3:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end

							if v then
								v:Destroy()
							end

							task.delay(DELAY_DURATION, function()
								if clone3 then
									clone3:Destroy()
								end
							end)
						end

						if weldConstraint then
							task.delay(DELAY_DURATION, function()
								if weldConstraint then
									weldConstraint:Destroy()
								end
							end)
						end

						if clone then
							clone:Destroy()
						end

						if not clone2 then
							break
						end

						clone2:Destroy()
						break
					end
				end
			end
		end
	end
end