local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = RunService:IsStudio() and not RunService:IsRunning()
local MainBossUi = require(script.MainBossUi)
local Test = require(script.Test)
local faye = require(ReplicatedStorage.Packages.faye)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local bossUI = ReplicatedStorage.CAM.Client.Components.Layout.Visibility.BossUI
local localPlayer = Players.LocalPlayer
local v2 = {}

for _, v3 in ipairs(CollectionService:GetTagged("BossTag")) do
	if v3:IsDescendantOf(workspace.Humanoids) or v then
		table.insert(v2, v3)
	end
end

CollectionService:GetInstanceAddedSignal("BossTag"):Connect(function(p)
	table.insert(v2, p)
end)
CollectionService:GetInstanceRemovedSignal("BossTag"):Connect(function(p)
	local index = table.find(v2, p)

	if index ~= nil then
		table.remove(v2, index)
	end
end)
return function(p)
	local maid = faye.new()
	local v3 = nil
	local v4 = nil

	local function updVisibility()
		local value = bossUI.Value

		if value ~= v3 then
			v3 = value

			if v4 ~= nil then
				v4:Destroy()
				v4 = nil
			end

			if value then
				v4 = maid:Extend()
				v4:Spawn(function()
					local WAIT_INTERVAL = 0.5
					local v5 = {}
					local v6 = nil
					local v7 = nil
					local v8 = nil

					while true do
						local position, v9, model, position2, humanoidRootPart, v10, folder, flag, parent, model2, humanoidRootPart2, position3, v12, v13, mode

						if v then
							position = workspace.CurrentCamera.CFrame.Position

							if v5.Folder == nil then
								v9 = false

								for i, v16 in ipairs(v2) do
									model = v16.Parent:FindFirstChildOfClass("Model")
									position2 = model ~= nil and model:FindFirstChild("HumanoidRootPart") ~= nil and model.HumanoidRootPart.Position or v16:GetAttribute("Center")

									if not (position2 ~= nil and vector.magnitude(position - position2) <= (v16:GetAttribute("DetectionRange") or 80)) then
										continue
									end

									v5.DetectionDistance = v16:GetAttribute("DetectionRange")
									v5.CountdownEnabled = v16:GetAttribute("SpawnCountdown")
									v5.Title = v16:GetAttribute("Title")
									v5.DespawnedAt = v16.Parent:GetAttribute("DespawnedAt")
									v5.Folder = v16
									v5.Center = v16:GetAttribute("Center")

									if model == nil then
										humanoidRootPart = false
									else
										humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
									end

									v5.Mode = humanoidRootPart and 1 or 2
									v10 = (v5.Mode ~= 2 or not v5.DespawnedAt) and 0 or math.floor((math.max(
										0,
										(v16:GetAttribute("SpawnTime") or 0) - (Utility.Tick() - v5.DespawnedAt)
									)))
									v6 = v4:Extend()
									v8, v7 = MainBossUi(v6, p, v5, v5.Mode, v10)
									v9 = true
									break
								end

								if not v9 and v and Test.Enabled then
									folder = Test.Build()
									v5.DetectionDistance = 1e999
									v5.CountdownEnabled = Test.Config.Mode == 2
									v5.Title = Test.Config.Title
									v5.Rewards = Test.Config.Rewards
									v5.Folder = folder
									v5.Center = position
									v5.Mode = Test.Config.Mode
									v6 = v4:Extend()
									v6:Add(folder.Parent)
									v8, v7 = MainBossUi(v6, p, v5, v5.Mode, Test.Config.Timer)
								end

								task.wait(WAIT_INTERVAL)
							else
								parent = v5.Folder.Parent

								if parent ~= nil then
									model2 = parent:FindFirstChildOfClass("Model")
								end

								if model2 ~= nil then
									humanoidRootPart2 = model2:FindFirstChild("HumanoidRootPart")
								end

								if humanoidRootPart2 ~= nil then
									position3 = humanoidRootPart2.Position
								end

								v12 = position3 or v5.Center

								if parent == nil or position3 == nil and not v5.CountdownEnabled or v12 == nil then
									flag = true
								else
									v13 = vector.magnitude(position - v12)
								end

								if flag or not (v13 <= (v5.DetectionDistance or 80)) then
									flag = true
									v5.DetectionDistance = nil
									v5.Folder = nil
									v5.Center = nil
									v5.Mode = nil

									if v6 then
										v6:Destroy()
										v6 = nil
									end

									task.wait(WAIT_INTERVAL)
									v7 = nil
									v8 = nil
								else
									mode = position3 and 1 or 2

									if v7 then
										v7(v5)
									end

									if mode ~= v5.Mode then
										v5.Mode = mode

										if v8 then
											v8(v5)
										end
									end

									task.wait(0.15)

									if flag then
										v5.DetectionDistance = nil
										v5.Folder = nil
										v5.Center = nil
										v5.Mode = nil

										if v6 then
											v6:Destroy()
											v6 = nil
										end

										task.wait(WAIT_INTERVAL)
										v7 = nil
										v8 = nil
									end
								end
							end
						elseif localPlayer == nil or localPlayer.Character == nil or localPlayer.Character.PrimaryPart == nil then
							task.wait(WAIT_INTERVAL)
						else
							position = localPlayer.Character.PrimaryPart.Position

							if v5.Folder == nil then
								v9 = false

								for i, v16 in ipairs(v2) do
									model = v16.Parent:FindFirstChildOfClass("Model")
									position2 = model ~= nil and model:FindFirstChild("HumanoidRootPart") ~= nil and model.HumanoidRootPart.Position or v16:GetAttribute("Center")

									if not (position2 ~= nil and vector.magnitude(position - position2) <= (v16:GetAttribute("DetectionRange") or 80)) then
										continue
									end

									v5.DetectionDistance = v16:GetAttribute("DetectionRange")
									v5.CountdownEnabled = v16:GetAttribute("SpawnCountdown")
									v5.Title = v16:GetAttribute("Title")
									v5.DespawnedAt = v16.Parent:GetAttribute("DespawnedAt")
									v5.Folder = v16
									v5.Center = v16:GetAttribute("Center")

									if model == nil then
										humanoidRootPart = false
									else
										humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
									end

									v5.Mode = humanoidRootPart and 1 or 2
									v10 = (v5.Mode ~= 2 or not v5.DespawnedAt) and 0 or math.floor((math.max(
										0,
										(v16:GetAttribute("SpawnTime") or 0) - (Utility.Tick() - v5.DespawnedAt)
									)))
									v6 = v4:Extend()
									v8, v7 = MainBossUi(v6, p, v5, v5.Mode, v10)
									v9 = true
									break
								end

								if not v9 and v and Test.Enabled then
									folder = Test.Build()
									v5.DetectionDistance = 1e999
									v5.CountdownEnabled = Test.Config.Mode == 2
									v5.Title = Test.Config.Title
									v5.Rewards = Test.Config.Rewards
									v5.Folder = folder
									v5.Center = position
									v5.Mode = Test.Config.Mode
									v6 = v4:Extend()
									v6:Add(folder.Parent)
									v8, v7 = MainBossUi(v6, p, v5, v5.Mode, Test.Config.Timer)
								end

								task.wait(WAIT_INTERVAL)
							else
								parent = v5.Folder.Parent

								if parent ~= nil then
									model2 = parent:FindFirstChildOfClass("Model")
								end

								if model2 ~= nil then
									humanoidRootPart2 = model2:FindFirstChild("HumanoidRootPart")
								end

								if humanoidRootPart2 ~= nil then
									position3 = humanoidRootPart2.Position
								end

								v12 = position3 or v5.Center

								if parent == nil or position3 == nil and not v5.CountdownEnabled or v12 == nil then
									flag = true
								else
									v13 = vector.magnitude(position - v12)
								end

								if flag or not (v13 <= (v5.DetectionDistance or 80)) then
									flag = true
									v5.DetectionDistance = nil
									v5.Folder = nil
									v5.Center = nil
									v5.Mode = nil

									if v6 then
										v6:Destroy()
										v6 = nil
									end

									task.wait(WAIT_INTERVAL)
									v7 = nil
									v8 = nil
								else
									mode = position3 and 1 or 2

									if v7 then
										v7(v5)
									end

									if mode ~= v5.Mode then
										v5.Mode = mode

										if v8 then
											v8(v5)
										end
									end

									task.wait(0.15)

									if flag then
										v5.DetectionDistance = nil
										v5.Folder = nil
										v5.Center = nil
										v5.Mode = nil

										if v6 then
											v6:Destroy()
											v6 = nil
										end

										task.wait(WAIT_INTERVAL)
										v7 = nil
										v8 = nil
									end
								end
							end
						end
					end
				end)
			end
		end
	end

	updVisibility()
	maid:Add(bossUI.Changed:Connect(updVisibility))
	return function()
		maid:Destroy()
	end
end