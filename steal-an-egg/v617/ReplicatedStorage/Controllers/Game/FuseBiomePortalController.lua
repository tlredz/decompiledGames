local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local GUI = require(ReplicatedStorage.Client.GUI)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
return {
	Start = function()
		local fadeFrame = GUI.FadeFrame()
		local localPlayer = Players.LocalPlayer
		local count = 0
		local v = nil
		local v2 = nil

		local function characterRoot()
			local character = localPlayer.Character
			local humanoidRootPart

			if character ~= nil then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
				return nil
			end

			return humanoidRootPart
		end

		local function waitForArrival(position: Vector3)
			local v3 = os.clock() + 2

			while os.clock() < v3 do
				local character = localPlayer.Character
				local humanoidRootPart

				if character ~= nil then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				end

				if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
					humanoidRootPart = nil
				end

				if humanoidRootPart ~= nil and (humanoidRootPart.Position - position).Magnitude >= 200 then
					break
				end

				RunService.Heartbeat:Wait()
			end
		end

		local function faceCameraForward()
			local character = localPlayer.Character
			local humanoidRootPart

			if character ~= nil then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
				humanoidRootPart = nil
			end

			local currentCamera = Workspace.CurrentCamera

			if humanoidRootPart == nil or currentCamera == nil then
				return
			end

			local lookVector = humanoidRootPart.CFrame.LookVector
			currentCamera.CFrame = CFrame.lookAt(
				humanoidRootPart.Position - lookVector * 12 + createVector(0, 5, 0),
				humanoidRootPart.Position
			)
		end

		Remotes.FuseBiome.PortalTransition.OnClientEvent:Connect(function(duration: number, id: string?, flag: boolean?)
			if flag then
				if v and v.Id == id then
					v.Complete = true
				end
			else
				if v2 then
					v2:Cancel()
				end

				count += 1
				local v3 = count
				local character = localPlayer.Character
				local humanoidRootPart

				if character ~= nil then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				end

				if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
					humanoidRootPart = nil
				end

				if humanoidRootPart == nil then
					fadeFrame.BackgroundTransparency = 1
					v = nil
				else
					local v4 = id and {
						Id = id,
						Complete = false
					} or nil
					v = v4
					local position = humanoidRootPart.Position
					local tween = TweenService:Create(fadeFrame, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
						BackgroundTransparency = 0
					})
					v2 = tween
					tween:Play()
					tween.Completed:Wait()

					if v3 ~= count then
						return
					end

					if v4 then
						if not v4.Complete then
							Remotes.FuseBiome.PortalTransition:FireServer(v4.Id)
						end

						local v5 = os.clock() + 5

						while not v4.Complete and os.clock() < v5 and v3 == count do
							RunService.Heartbeat:Wait()
						end

						if v3 ~= count then
							return
						end

						local v6 = os.clock() + 2

						while v4.Complete and os.clock() < v6 and v3 == count do
							local character2 = localPlayer.Character
							local humanoidRootPart2

							if character2 ~= nil then
								humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
							end

							if humanoidRootPart2 == nil or not humanoidRootPart2:IsA("BasePart") then
								humanoidRootPart2 = nil
							end

							if not humanoidRootPart2 or humanoidRootPart2 ~= humanoidRootPart or (humanoidRootPart2.Position - position).Magnitude >= 1 then
								break
							end

							RunService.Heartbeat:Wait()
						end
					else
						waitForArrival(position)
					end

					task.wait(0.1)

					if v3 ~= count then
						return
					end

					local character2 = localPlayer.Character
					local humanoidRootPart2

					if character2 ~= nil then
						humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
					end

					if humanoidRootPart2 == nil or not humanoidRootPart2:IsA("BasePart") then
						humanoidRootPart2 = nil
					end

					local currentCamera = Workspace.CurrentCamera

					if humanoidRootPart2 ~= nil and currentCamera ~= nil then
						local lookVector = humanoidRootPart2.CFrame.LookVector
						currentCamera.CFrame = CFrame.lookAt(
							humanoidRootPart2.Position - lookVector * 12 + createVector(0, 5, 0),
							humanoidRootPart2.Position
						)
					end

					v = nil
					v2 = TweenService:Create(fadeFrame, TweenInfo.new(0.35, Enum.EasingStyle.Linear), {
						BackgroundTransparency = 1
					})
					v2:Play()
				end
			end
		end)
	end
}