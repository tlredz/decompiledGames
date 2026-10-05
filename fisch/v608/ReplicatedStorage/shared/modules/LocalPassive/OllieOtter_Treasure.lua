local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local items = require(ReplicatedStorage.shared.modules.library.items)
local CompanionController = require(ReplicatedStorage.client.legacyControllers.CompanionController)
local remoteEvent = Net:RemoteEvent("Companion/OllieOtter/ClaimTreasure")
local remoteEvent2 = Net:RemoteEvent("Companion/OllieOtter/TreasureShown")
local remoteEvent3 = Net:RemoteEvent("Companion/RequestMoodPhase")
local OllieOtterTreasure = {
	Morph = function(data, _, object)
		if not (object.data and object.data.OllieTreasure and object.mock ~= "BellonasWaraxe") then
			return
		end

		local guiObject = script:FindFirstChildWhichIsA("GuiObject")

		if not guiObject then
			return
		end

		local clone = guiObject:Clone()
		clone.Parent = object.reel_bar
		data.reelTrove:Add(clone)
		local scaledConfig = CompanionController.GetScaledConfig(data.config)
		local random = object:GetRandom(31)
		local fillTime = scaledConfig.FillTime or 3.5
		local decayMult = scaledConfig.DecayMult or 0.4
		local zoneSize = scaledConfig.ZoneSize or 0.05
		local appearDelayMin = scaledConfig.AppearDelayMin or 1.5
		local appearDelayMax = scaledConfig.AppearDelayMax or 7
		local number = random:NextNumber(0.1, 0.9)
		local number2 = random:NextNumber(appearDelayMin, (math.max(appearDelayMax, appearDelayMin)))
		local item = object.data.OllieTreasure.Item
		local size = clone.Size
		local scale = clone.Position.Y.Scale
		clone.Visible = false
		clone.Position = UDim2.fromScale(number, scale)
		local image = clone:FindFirstChild("image") or clone

		if image:IsA("ImageLabel") then
			local v = fish[item] or items.Items[item]

			if v and v.Icon then
				image.Image = v.Icon
			end
		end

		local progress = clone:FindFirstChild("progress")
		local bar = progress and progress:FindFirstChild("bar")

		if progress then
			progress.Visible = false
		end

		if bar then
			bar.Size = UDim2.fromScale(0, bar.Size.Y.Scale)
		end

		task.spawn(function()
			object:WaitUntilReady()
			object:WaitLogic(number2)

			if not (clone.Parent and object.active) then
				return
			end

			clone.Visible = true
			remoteEvent2:FireServer()
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup, object.reel, true)
			clone.Size = UDim2.fromScale(0, 0)
			data.current.logicTweens:Create(
				clone,
				TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = size
				}
			):Play()
			local v = 0
			local v2 = false
			local total = 0
			local v3 = 0
			data.reelTrove:Add(object.OnLogicStep:Connect(function(p)
				if v2 or not object.active then
					return
				end

				if object:IsInBar(number, zoneSize) then
					total += p
					local v4 = math.sin(total * 40)
					image.Rotation = v4 * 12
					clone.Position = UDim2.fromScale(
						number + math.sin(total * 40 * 1.3) * 0.04 * zoneSize,
						scale + math.cos(total * 40 * 0.9) * 0.04
					)
					v = math.min(v + p / fillTime, 1)
					local v5 = v4 >= 0 and 1 or -1

					if v5 ~= v3 then
						v3 = v5
						local clone2 = ReplicatedStorage.resources.sounds.sfx.ui.clank1:Clone()
						clone2.PlaybackSpeed = v * 0.9 + 0.9
						clone2.Parent = object.reel
						clone2:Play()
						clone2.Ended:Once(function()
							clone2:Destroy()
						end)
					end
				else
					total = 0
					image.Rotation = 0
					clone.Position = UDim2.fromScale(number, scale)
					v = math.max(v - p / fillTime * decayMult, 0)
					v3 = 0
				end

				if progress then
					progress.Visible = v > 0
				end

				if bar then
					bar.Size = UDim2.fromScale(v, bar.Size.Y.Scale)
				end

				if v >= 1 then
					v2 = true
					remoteEvent:FireServer()
					remoteEvent3:FireServer("Grab")
					fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.collect1, object.reel, true)
					image.Rotation = 0
					clone.Position = UDim2.fromScale(number, scale)

					if progress then
						progress.Visible = false
					end

					local v4 = data.current.logicTweens:Create(
						clone,
						TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
						{
							Size = UDim2.fromScale(0, 0)
						}
					)
					v4.Completed:Once(function()
						clone.Visible = false
						clone.Size = size
					end)
					v4:Play()
				end
			end))
		end)
	end
}
setmetatable(OllieOtterTreasure, module)
return OllieOtterTreasure