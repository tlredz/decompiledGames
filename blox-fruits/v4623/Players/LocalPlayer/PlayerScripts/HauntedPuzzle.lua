local createVector = vector.create
local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local commF_ = remotes:WaitForChild("CommF_")
local map = workspace:WaitForChild("Map")
local WaitForStream = require(game.ReplicatedStorage.Util.WaitForStream)
local thread = nil
local hauntedCastle = map:WaitForChild("Haunted Castle", 10)

if not hauntedCastle then
	return
end

local cframe = CFrame.new(-9707.86328125, -71.68722534179688, 6517.90869140625)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("DialoguesList"))
local DialogueController = require(ReplicatedStorage:WaitForChild("DialogueController"))
local localPlayer = game.Players.LocalPlayer
local character = nil
localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
	pcall(refresh)
end)

if localPlayer.Character then
	character = localPlayer.Character
end

local flag = false
local v = false
local v2 = false
local v3 = false
local v4 = {}
local v5 = {
	2,
	2,
	1,
	2,
	1,
	1,
	1
}
local v6 = {
	2,
	2,
	2,
	2,
	2,
	2,
	2,
	2,
	2,
	2
}
local v7 = {
	math.random(1, 2),
	0,
	math.random(1, 2),
	math.random(1, 2),
	0,
	0,
	math.random(1, 2),
	0,
	0,
	math.random(1, 2)
}
local v8 = {
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1
}
local v9 = {
	1,
	1,
	2,
	4,
	1,
	3,
	1,
	2,
	1,
	4
}
local tablet = WaitForStream[hauntedCastle].Tablet()
local pivot = tablet:GetPivot()
tablet:PivotTo(cframe)
local blockers = WaitForStream[hauntedCastle].Blockers()
local roomBlock = blockers:WaitForChild("RoomBlock")
roomBlock.CanCollide = true
local roomBlock2 = blockers:WaitForChild("RoomBlock2")
roomBlock2.CanCollide = true
local v10 = false
local v11 = nil

function refresh(p)
	if thread then
		task.cancel(thread)
		thread = nil
	end

	thread = task.defer(function()
		v11 = commF_:InvokeServer("GuitarPuzzleProgress", "Check")

		if not hauntedCastle:WaitForChild("Trophies", 1000):WaitForChild("Quest"):GetAttribute("InitialCF") then
			local quest = hauntedCastle.Trophies.Quest
			local HttpService = game:GetService("HttpService")
			quest:SetAttribute(
				"InitialCF",
				HttpService:JSONEncode({ hauntedCastle.Trophies.Quest:GetPivot():GetComponents() })
			)
			hauntedCastle.Trophies.Quest:PivotTo(cframe)
		end

		if not hauntedCastle:WaitForChild("Trophies"):WaitForChild("Default"):GetAttribute("InitialCF") then
			local default = hauntedCastle.Trophies.Default
			local HttpService = game:GetService("HttpService")
			default:SetAttribute(
				"InitialCF",
				HttpService:JSONEncode({ hauntedCastle.Trophies.Default:GetPivot():GetComponents() })
			)
		end

		if not v10 then
			v10 = true
			task.spawn(function()
				local skeletonMachine = workspace:WaitForChild("NPCs"):FindFirstChild("Skeleton Machine")

				if not skeletonMachine then
					repeat
						wait(1)
						skeletonMachine = workspace.NPCs:FindFirstChild("Skeleton Machine")
					until skeletonMachine
				end

				v10 = { skeletonMachine, skeletonMachine:GetPrimaryPartCFrame() }
				skeletonMachine:SetPrimaryPartCFrame(cframe)
			end)
		end

		local function zad()
			for i = 1, 7 do
				for _, descendant in pairs(hauntedCastle:WaitForChild("Placard" .. i):GetDescendants()) do
					if descendant.ClassName == "Model" then
						continue
					end

					if descendant.Name == "ClickDetector" then
						descendant.MaxActivationDistance = 0
					else
						descendant.Transparency = 1
					end
				end
			end
		end

		if v11 then
			for i = 1, 4 do
				local waitForChild = hauntedCastle:WaitForChild("Candles"):WaitForChild("Candle" .. i)
				waitForChild.Attachment.Main.Enabled = true
				local waitForChild_2 = hauntedCastle:WaitForChild("Candles"):WaitForChild("Candle" .. i)
				waitForChild_2.Transparency = 0
			end

			local swamp = v11.Swamp
			local gravestones = v11.Gravestones
			local ghost = v11.Ghost
			local trophies = v11.Trophies
			local pipes = v11.Pipes

			if p == "promptDialogue" then
				task.spawn(function()
					local Effect = require(game.ReplicatedStorage.Effect)
					Effect.new("BlindCam"):replicate({
						Color = Color3.new(0.03, 0.03, 0.03),
						Duration = 2,
						Fade = 0.25,
						ZIndex = -10
					})
					local Sound = require(game.ReplicatedStorage.Util.Sound)
					Sound:Play("Thunder", workspace.CurrentCamera.CFrame.p)
					DialogueController.start({
						Title = "???",
						Get = function(_)
							return {
								Text = { pipes and "<Color=Yellow>Congratulations.<Color=/>" or "Excellent." }
							}
						end
					})
				end)
				task.wait(0.25)
			end

			if not swamp then
				local swampWater = hauntedCastle:WaitForChild("Swamp"):WaitForChild("SwampWater")
				swampWater.BrickColor = BrickColor.new("Maroon")
				zad()
			end

			if swamp then
				local main = hauntedCastle:WaitForChild("Candles"):WaitForChild("Candle1"):WaitForChild("Attachment"):WaitForChild("Main")
				main.Enabled = false
				local swampWater_2 = hauntedCastle:WaitForChild("Swamp"):WaitForChild("SwampWater")
				swampWater_2.BrickColor = BrickColor.new("Grime")

				if not v then
					v = true

					for i = 1, 7 do
						for k, childName in pairs({ "Left", "Right" }) do
							local child = hauntedCastle:WaitForChild("Placard" .. i)
							child:WaitForChild(childName):WaitForChild("Indicator", 3)
							child:WaitForChild(childName):WaitForChild("ClickDetector", 3)

							for _, child2 in pairs(child:WaitForChild(childName):GetChildren()) do
								if child2.Name == "ClickDetector" then
									child2.MaxActivationDistance = 22
									local v12 = i
									local v13 = k
									local v14 = child
									local v15 = childName
									child2.MouseClick:Connect(function()
										v4[v12] = v13

										for i2, part in pairs(v14[v15]:GetChildren()) do
											if part:IsA("BasePart") then
												part.BrickColor = BrickColor.new("Pearl")
											end
										end

										for i2, part in pairs(v14[v15 == "Left" and "Right" or "Left"]:GetChildren()) do
											if part:IsA("BasePart") then
												part.BrickColor = BrickColor.new("Pine Cone")
											end
										end

										local flag2 = true

										for i2 = 1, 7 do
											if v4[i2] == v5[i2] then
												continue
											end

											flag2 = false
											break
										end

										if flag2 then
											commF_:InvokeServer("GuitarPuzzleProgress", "Gravestones")
										end
									end)
								else
									child2.CanQuery = true

									if child2.Name == "Indicator" then
										local letterV = child2:WaitForChild("Letter V")
										letterV.Transparency = 0
									else
										child2.Transparency = 0
									end
								end
							end
						end
					end
				end
			end

			if gravestones then
				local main_2 = hauntedCastle:WaitForChild("Candles"):WaitForChild("Candle2"):WaitForChild("Attachment"):WaitForChild("Main")
				main_2.Enabled = false

				for i = 1, 7 do
					for _, childName in pairs({ "Left", "Right" }) do
						hauntedCastle:WaitForChild("Placard" .. i):WaitForChild(childName):WaitForChild(
							"ClickDetector",
							3
						)
						hauntedCastle:WaitForChild("Placard" .. i):WaitForChild(childName):WaitForChild("Indicator", 3)

						for _, child in pairs(hauntedCastle:WaitForChild("Placard" .. i):WaitForChild(childName):GetChildren()) do
							if child.Name == "ClickDetector" then
								child.MaxActivationDistance = 0
							else
								child.CanQuery = false
								child.Transparency = 1

								if child.Name == "Indicator" then
									local letterV_2 = child:WaitForChild("Letter V")
									letterV_2.Transparency = 1
								end
							end
						end
					end
				end

				pcall(function()
					roomBlock:Destroy()
				end)
				pcall(function()
					roomBlock2:Destroy()
				end)

				if ghost then
					task.spawn(function()
						local ghost2 = workspace.NPCs:FindFirstChild("Ghost")

						if not ghost2 then
							repeat
								wait(1)
								ghost2 = workspace.NPCs:FindFirstChild("Ghost")
							until ghost2
						end

						ghost2:SetPrimaryPartCFrame(cframe)
					end)

					for _, child in pairs(hauntedCastle:WaitForChild("ElevatorDoor"):GetChildren()) do
						local cFrame = child.CFrame
						child.Size = createVector(0.8, 16, 8.375)
						child.CFrame = cFrame
					end

					hauntedCastle:WaitForChild("Trophies"):WaitForChild("Default"):PivotTo(cframe)
					local quest = hauntedCastle:WaitForChild("Trophies"):WaitForChild("Quest")
					local HttpService = game:GetService("HttpService")
					quest:PivotTo(CFrame.new(unpack(HttpService:JSONDecode(hauntedCastle.Trophies.Quest:GetAttribute("InitialCF")))))
					tablet:PivotTo(pivot)

					if not v3 then
						v3 = true
						local count = 0

						for _, v12 in pairs(v7) do
							if v12 == 0 then
								continue
							end

							count += 1
							hauntedCastle.Trophies.Quest:WaitForChild("Trophy" .. count).Handle.CFrame *= CFrame.Angles(
								0,
								(v12 - 1) * 1.5707963267948966,
								0
							)
						end

						for i = 1, 10 do
							local child = hauntedCastle:WaitForChild("Tablet"):WaitForChild("Segment" .. i)
							local clickDetector = Instance.new("ClickDetector", child)
							clickDetector.MaxActivationDistance = 32
							local v12 = 1
							local cFrame = child.Line.CFrame
							local v15 = i
							clickDetector.MouseClick:Connect(function()
								v12 += 1

								if v12 == 4 then
									v12 = 1
								end

								if v12 == 1 then
									child.Line.CFrame = cFrame
									v6[v15] = 2
								elseif v12 == 2 then
									child.Line.CFrame = cFrame * CFrame.Angles(0, 0, 1.5707963267948966)
									v6[v15] = 1
								elseif v12 == 3 then
									child.Line.CFrame = cframe
									v6[v15] = 0
								end

								local flag2 = true

								for i2 = 1, 10 do
									if v6[i2] == v7[i2] then
										continue
									end

									flag2 = false
									break
								end

								if flag2 then
									commF_:InvokeServer("GuitarPuzzleProgress", "Trophies")
								end
							end)
						end
					end
				else
					if flag then
						return
					end

					flag = true
					task.spawn(function()
						hauntedCastle:WaitForChild("Trophies"):WaitForChild("Default"):PivotTo(cframe)
						local ghost2 = workspace.NPCs:FindFirstChild("Ghost")

						if not ghost2 then
							repeat
								wait(1)
								ghost2 = workspace.NPCs:FindFirstChild("Ghost")
							until ghost2
						end

						local lastTime = tick()

						while ghost2 and ghost2.HumanoidRootPart.Position.Y > 0 do
							for _, child in pairs(hauntedCastle:WaitForChild("ElevatorDoor"):GetChildren()) do
								local cFrame = child.CFrame
								child.Size = Vector3.new(0.8, 16, math.sin(tick() - lastTime) ^ 2 * 8 + 8.375)
								child.CFrame = cFrame
							end

							task.wait()
						end

						for _, child in pairs(hauntedCastle:WaitForChild("ElevatorDoor"):GetChildren()) do
							local cFrame = child.CFrame
							child.Size = createVector(0.8, 16, 8.375)
							child.CFrame = cFrame
						end
					end)
					return
				end
			end

			if trophies then
				local candle3 = hauntedCastle:WaitForChild("Candles"):WaitForChild("Candle3")
				candle3.Attachment.Main.Enabled = false
				tablet:PivotTo(cframe)
				hauntedCastle:WaitForChild("Trophies"):WaitForChild("Quest"):PivotTo(cframe)
				local default = hauntedCastle:WaitForChild("Trophies"):WaitForChild("Default")
				local HttpService = game:GetService("HttpService")
				default:PivotTo(CFrame.new(unpack(HttpService:JSONDecode(hauntedCastle.Trophies.Default:GetAttribute("InitialCF")))))

				if not v2 then
					v2 = true
					local v12 = {
						"Really black",
						"Dusty Rose",
						"Parsley green",
						"Storm blue"
					}

					for i = 1, 10 do
						local child = hauntedCastle:WaitForChild("Lab Puzzle"):WaitForChild("ColorFloor"):WaitForChild("Model"):WaitForChild("Part" .. i)
						local clickDetector = Instance.new("ClickDetector", child)
						clickDetector.MaxActivationDistance = 32
						local v13 = 1
						local v14 = i
						clickDetector.MouseClick:Connect(function()
							v13 += 1

							if v13 == 5 then
								v13 = 1
							end

							v8[v14] = v13
							child.BrickColor = BrickColor.new(v12[v13])
							local flag2 = true

							for i2 = 1, 10 do
								if v8[i2] == v9[i2] then
									continue
								end

								flag2 = false
								break
							end

							if flag2 then
								commF_:InvokeServer("GuitarPuzzleProgress", "Pipes")
							end
						end)
					end
				end
			end

			if pipes then
				task.spawn(function()
					repeat
						task.wait(1)
					until typeof(v10) == "table"

					v10[1]:SetPrimaryPartCFrame(v10[2])
				end)
				task.spawn(function()
					local main = hauntedCastle:WaitForChild("Candles"):WaitForChild("Candle4"):WaitForChild("Attachment"):WaitForChild("Main")
					main.Enabled = false
				end)
				task.spawn(function()
					for i = 1, 10 do
						local child = hauntedCastle:WaitForChild("Lab Puzzle"):WaitForChild("ColorFloor"):WaitForChild("Model"):WaitForChild("Part" .. i)
						local clickDetector = child:FindFirstChildWhichIsA("ClickDetector", 3)

						if clickDetector then
							clickDetector:Destroy()
						end

						child.BrickColor = BrickColor.new("Really black")
					end
				end)
			end
		else
			zad()

			for i = 1, 4 do
				local waitForChild_3 = hauntedCastle:WaitForChild("Candles"):WaitForChild("Candle" .. i)
				waitForChild_3.Attachment.Main.Enabled = false
				local waitForChild_4 = hauntedCastle:WaitForChild("Candles"):WaitForChild("Candle" .. i)
				waitForChild_4.Transparency = 1
			end
		end
	end)
end

remotes:WaitForChild("RefreshHauntedPuzzlePro").OnClientEvent:Connect(refresh)

repeat
	wait(3)
	local success, result = pcall(refresh)

	if not success and result then
		warn(result)
	end
until success and not result