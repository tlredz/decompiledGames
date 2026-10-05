local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local module = require("./PassiveHandler")
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
require(ReplicatedStorage.shared.utils.GeneralUtils)
local sounds = script:WaitForChild("Sounds")
local playerDataReplicator = DataController.PlayerDataReplicator
local v = {
	Images = {
		"rbxassetid://132346600076288",
		"rbxassetid://102737277304867",
		"rbxassetid://131181049572826",
		"rbxassetid://94113599396914",
		"rbxassetid://88623097245492",
		"rbxassetid://74629254921012",
		"rbxassetid://104186548624405",
		"rbxassetid://91222445924197",
		"rbxassetid://77653305232693",
		"rbxassetid://108250178383678",
		"rbxassetid://131554096422412"
	},
	Pivot = UDim2.fromScale(0.5, 0.5),
	Radius = Vector2.new(0.7, 3),
	Speed = 0.1,
	FaceOutward = true,
	ImageSize = UDim2.fromScale(1.5, 3.5)
}
local Castbound = {
	Morph = function(p, _, object)
		task.spawn(ContentProvider.PreloadAsync, ContentProvider, { script })
		local clone = table.clone(v)

		if p.config.ImagesOverride then
			clone.Images = p.config.ImagesOverride
		end

		local v2 = playerDataReplicator:TryIndex({ "Rods", object.rodName, "enchant" })
		local shine = object.reel:FindFirstChild("Shine")

		if v2 == "Restricted" then
			if shine then
				shine:Destroy()
			end
		else
			local frame = Instance.new("Frame")
			frame.Name = "OrbitContainer"
			frame.Size = UDim2.fromScale(1, 1)
			frame.BackgroundTransparency = 1
			frame.ZIndex = -99
			frame.Parent = object.reel_bar
			local v3 = {}

			for i, image in ipairs(clone.Images) do
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = "OrbitImage_" .. i
				imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				imageLabel.Size = clone.ImageSize
				imageLabel.BackgroundTransparency = 1
				imageLabel.ScaleType = Enum.ScaleType.Fit
				imageLabel.Image = image
				imageLabel.Parent = frame
				local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				uIAspectRatioConstraint.Parent = imageLabel
				table.insert(v3, imageLabel)
			end

			local total = 0
			p.reelTrove:Add(object.OnRenderStep:Connect(function(p2)
				total += p2
				local count = #v3

				if count == 0 then
					return
				end

				local v4 = 6.283185307179586 / count
				local v5 = total * clone.Speed * 2 * 3.141592653589793

				for i, v6 in ipairs(v3) do
					local v7 = v5 + v4 * (i - 1)
					local v8 = math.cos(v7) * clone.Radius.X
					local v9 = math.sin(v7) * clone.Radius.Y
					v6.Position = UDim2.new(
						clone.Pivot.X.Scale + v8,
						clone.Pivot.X.Offset,
						clone.Pivot.Y.Scale + v9,
						clone.Pivot.Y.Offset
					)

					if clone.FaceOutward then
						v6.Rotation = math.deg(v7) + 90
					end
				end
			end))

			if shine then
				p.reelTrove:Add(object.reel_bar:GetPropertyChangedSignal("Position"):Connect(function()
					shine.Position = object.reel_bar.Position
				end))
			end
		end

		task.spawn(function()
			object:WaitUntilReady()

			if v2 == "Restricted" then
				object.data.SlashDisabled = true
				return
			end

			local blade = object.reel_bar.fish:FindFirstChild("Blade")
			local flag = true
			local flag2 = true
			local count = 0
			local count2 = 0
			local modifier = object:CreateModifier("progressefficiency", "force_add")
			local modifier2 = object:CreateModifier("barSize", "add")
			local modifier3 = object:CreateModifier("minBarSize", "add")
			modifier3.Value = p.config.MinimumBarSize
			p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
				if flag then
					if object.onbar then
						flag2 = true

						if count2 <= 2 then
							if object.barSize > p.config.MinimumBarSize then
								modifier2.Value -= p2 / 10
							end

							if object.data.SlashesAtMaxInterval then
								object.data.SlashDamageReduction = 0.2
							end
						end
					else
						if flag2 then
							count2 += 1
							flag = false
						end

						flag2 = false

						if p.config.TheConfigBooleanThatTogglesTheMasteryBuff then
							if object.data.SlashDisabled then
								return
							end

							count += 1
							local v3 = count
							local v4 = count2 ~= 2 and 0 or -(p.config.LockInModeAmount / 2)
							object.data.SlashDisabled = true
							object.data.ResetChaoticSlashes = true
							object.data.SlashDamageReduction = 0.2
							object.logicTweens:CreateAndPlay(
								modifier2,
								TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
								{
									Value = -p.config.LockInModeAmount
								}
							).Completed:Wait()

							if count2 >= 3 then
								modifier3.Value = 0.1
								object.logicTweens:CreateAndPlay(
									modifier2,
									TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
									{
										Value = -0.5
									}
								)
								object:DelayLogic(0.25, function()
									flag = true
								end)
							else
								while not object.onbar and object.active do
									task.wait()
								end

								object:WaitLogic(1)

								if v3 == count then
									object:DelayLogic(0.75, function()
										if not (object.onbar and object.active) then
											return
										end

										sounds.Restored:Play()
										local uIGradient = object.reel.bar.playerbar:FindFirstChild("Shine"):FindFirstChild("UIGradient")

										if uIGradient then
											uIGradient.Offset = Vector2.new(-0.75, 0)
											object.logicTweens:CreateAndPlay(
												uIGradient,
												TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
												{
													Offset = Vector2.new(1, 0)
												}
											)
										end
									end)
									object.logicTweens:CreateAndPlay(modifier2, TweenInfo.new(1), {
										Value = v4
									}).Completed:Wait()
									object.data.SlashDisabled = false
									object:DelayLogic(0.25, function()
										flag = true
									end)
								else
									while not object.onbar and object.active do
										task.wait()
									end

									if not object.active then
										return
									end

									object.data.SlashDisabled = false
								end
							end
						elseif count2 == 1 then
							object.data.SlashDisabled = true
							object.logicTweens:CreateAndPlay(
								modifier2,
								TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
								{
									Value = -p.config.LockInModeAmount
								}
							)
							object.logicTweens:CreateAndPlay(
								modifier,
								TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
								{
									Value = p.config.LockInModeAmount
								}
							)
						end
					end
				end
			end))

			if blade then
				local v3 = nil
				p.reelTrove:Add(object.OnSlash:Connect(function()
					if v3 then
						v3:Cancel()
						v3 = nil
					end

					blade.Position = UDim2.fromScale(0.5, 0.25)
					v3 = object.logicTweens:CreateAndPlay(
						blade,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Position = UDim2.fromScale(0.5, 0)
						}
					)
				end))
			end
		end)
	end
}
setmetatable(Castbound, module)
return Castbound