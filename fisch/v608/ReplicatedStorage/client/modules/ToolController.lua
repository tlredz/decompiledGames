local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.packages.Observers)
local Trove = require(ReplicatedStorage.packages.Trove)
local library = require(ReplicatedStorage.shared.modules.library)
local FishModel = require(ReplicatedStorage.shared.modules.FishModel)
local localPlayer = Players.LocalPlayer
local fish = ReplicatedStorage.resources.animations.fish
return {
	init = function()
		local track = nil

		local function hash(...)
			local v = select("#", ...)
			return string.format(string.rep("<%s>", v), ...)
		end

		Observers.observeTag("FishTool", function(parent)
			if not parent:WaitForChild("link", 300) then
				return
			end

			local v = nil
			local children = {}
			local flag = false

			local function clear()
				for _, v2 in children do
					v2:Destroy()
				end

				table.clear(children)

				if track then
					track:Stop()
					track = nil
				end

				v = nil
			end

			local function updateModel()
				if flag then
					return
				end

				flag = true
				task.defer(function()
					flag = false

					if not parent.Parent or parent.Parent:IsA("Backpack") then
						clear()
						return
					end

					local displayFishName = parent:GetAttribute("displayFishName")
					local displayFishWeight = parent:GetAttribute("displayFishWeight")
					local displayFishMutation = parent:GetAttribute("displayFishMutation")
					local displayFishShiny = parent:GetAttribute("displayFishShiny")
					local displayFishSparkling = parent:GetAttribute("displayFishSparkling")
					local v2 = hash(
						tostring(displayFishName),
						tostring(displayFishWeight),
						tostring(displayFishMutation),
						tostring(displayFishShiny),
						(tostring(displayFishSparkling))
					)

					if v2 == v then
						return
					end

					if not displayFishName then
						clear()
						return
					end

					clear()
					v = v2
					children = FishModel.Create({
						Name = displayFishName,
						ItemData = {
							Weight = displayFishWeight,
							Mutation = displayFishMutation,
							Shiny = displayFishShiny,
							Sparkling = displayFishSparkling
						}
					}):GetChildren()

					for _, script in children do
						if not script:IsA("Script") then
							script.Parent = parent
						end
					end

					local handle = parent:FindFirstChild("handle")

					if handle then
						local motor6D = Instance.new("Motor6D")
						motor6D.Name = "fish6d"
						motor6D.C0 = CFrame.new(0, -1, 0)
						motor6D.Part0 = parent.Parent:FindFirstChild("Right Arm")
						motor6D.Part1 = handle
						motor6D.Parent = handle
						local childAddedConnection = parent.Parent.ChildAdded:Connect(function(part)
							if part.Name == "Right Arm" then
								motor6D.Part0 = part
							end
						end)
						handle.Destroying:Once(function()
							childAddedConnection:Disconnect()
						end)
					end

					local parent2 = parent.Parent
					local humanoid = parent2:FindFirstChildOfClass("Humanoid")

					if not humanoid or parent2 ~= localPlayer.Character then
						return
					end

					local name = library.fish[displayFishName].HoldAnimation.Name
					track = humanoid:LoadAnimation(library.fish[displayFishName].HoldAnimation)

					if displayFishWeight then
						if displayFishWeight <= library.fish[displayFishName].WeightPool[2] / 10 / 1.5 then
							if name == "basic" or name == "small" then
								track = humanoid:LoadAnimation(fish:WaitForChild("underweight"))
							end

							if name == "basic" or name == "heavybasic" then
								track = humanoid:LoadAnimation(fish:WaitForChild("basic"))
							end
						elseif library.fish[displayFishName].WeightPool[2] / 10 * 1.8 <= displayFishWeight and (name == "tiny" or name == "underweight") then
							track = humanoid:LoadAnimation(fish:WaitForChild("small"))
						end
					end

					track.Priority = Enum.AnimationPriority.Action
					track:Play()
				end)
			end

			local maid = Trove.new()

			if not flag then
				flag = true
				task.defer(function()
					flag = false

					if not parent.Parent or parent.Parent:IsA("Backpack") then
						clear()
						return
					end

					local displayFishName = parent:GetAttribute("displayFishName")
					local displayFishWeight = parent:GetAttribute("displayFishWeight")
					local displayFishMutation = parent:GetAttribute("displayFishMutation")
					local displayFishShiny = parent:GetAttribute("displayFishShiny")
					local displayFishSparkling = parent:GetAttribute("displayFishSparkling")
					local v2 = hash(
						tostring(displayFishName),
						tostring(displayFishWeight),
						tostring(displayFishMutation),
						tostring(displayFishShiny),
						(tostring(displayFishSparkling))
					)

					if v2 == v then
						return
					end

					if not displayFishName then
						clear()
						return
					end

					clear()
					v = v2
					children = FishModel.Create({
						Name = displayFishName,
						ItemData = {
							Weight = displayFishWeight,
							Mutation = displayFishMutation,
							Shiny = displayFishShiny,
							Sparkling = displayFishSparkling
						}
					}):GetChildren()

					for _, script in children do
						if not script:IsA("Script") then
							script.Parent = parent
						end
					end

					local handle = parent:FindFirstChild("handle")

					if handle then
						local motor6D = Instance.new("Motor6D")
						motor6D.Name = "fish6d"
						motor6D.C0 = CFrame.new(0, -1, 0)
						motor6D.Part0 = parent.Parent:FindFirstChild("Right Arm")
						motor6D.Part1 = handle
						motor6D.Parent = handle
						local childAddedConnection = parent.Parent.ChildAdded:Connect(function(part)
							if part.Name == "Right Arm" then
								motor6D.Part0 = part
							end
						end)
						handle.Destroying:Once(function()
							childAddedConnection:Disconnect()
						end)
					end

					local parent2 = parent.Parent
					local humanoid = parent2:FindFirstChildOfClass("Humanoid")

					if not humanoid or parent2 ~= localPlayer.Character then
						return
					end

					local name = library.fish[displayFishName].HoldAnimation.Name
					track = humanoid:LoadAnimation(library.fish[displayFishName].HoldAnimation)

					if displayFishWeight then
						if displayFishWeight <= library.fish[displayFishName].WeightPool[2] / 10 / 1.5 then
							if name == "basic" or name == "small" then
								track = humanoid:LoadAnimation(fish:WaitForChild("underweight"))
							end

							if name == "basic" or name == "heavybasic" then
								track = humanoid:LoadAnimation(fish:WaitForChild("basic"))
							end
						elseif library.fish[displayFishName].WeightPool[2] / 10 * 1.8 <= displayFishWeight and (name == "tiny" or name == "underweight") then
							track = humanoid:LoadAnimation(fish:WaitForChild("small"))
						end
					end

					track.Priority = Enum.AnimationPriority.Action
					track:Play()
				end)
			end

			maid:Add(parent:GetPropertyChangedSignal("Parent"):Connect(updateModel))
			maid:Add(parent:GetAttributeChangedSignal("displayFishName"):Connect(updateModel))
			maid:Add(parent:GetAttributeChangedSignal("displayFishMutation"):Connect(updateModel))
			maid:Add(parent:GetAttributeChangedSignal("displayFishWeight"):Connect(updateModel))
			maid:Add(parent:GetAttributeChangedSignal("displayFishShiny"):Connect(updateModel))
			maid:Add(parent:GetAttributeChangedSignal("displayFishSparkling"):Connect(updateModel))
			maid:Add(clear)
			return maid:WrapClean()
		end)
	end
}