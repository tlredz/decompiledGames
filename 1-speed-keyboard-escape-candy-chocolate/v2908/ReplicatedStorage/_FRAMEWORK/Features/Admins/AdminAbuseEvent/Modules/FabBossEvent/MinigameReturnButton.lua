local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Button = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.Button)
local create = Vide.create
local uDim = UDim2.fromScale(0.1, 0.2)
local uDim2 = UDim2.fromScale(0.98, 0.96)
local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local colorSequence = ColorSequence.new(Color3.fromRGB(191, 86, 255), Color3.fromRGB(100, 35, 185))
return {
	mount = function(p, callback)
		local v = nil
		local v2 = nil
		local v3 = nil
		local v4 = false
		local v5 = false
		local source = Vide.source("Return to Lobby")

		local function tweenButtonScale(scale: number, tweenInfo3)
			local v6 = v2

			if v6 then
				local v7 = v3

				if v7 then
					v7:Cancel()
				end

				local tween = TweenService:Create(v6, tweenInfo3, {
					Scale = scale
				})
				v3 = tween
				tween:Play()
			end
		end

		local v6 = Vide.mount(function()
			return create("ScreenGui")({
				Name = "FabBossMinigameReturnButton",
				DisplayOrder = 28000,
				IgnoreGuiInset = false,
				ResetOnSpawn = false,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				Vide.action(function(p2)
					v = p2
				end),
				create("Frame")({
					Name = "ReturnToLobbyContainer",
					AnchorPoint = Vector2.one,
					Position = uDim2,
					Size = uDim,
					BackgroundTransparency = 1,
					create("UIAspectRatioConstraint")({
						AspectRatio = 3.6538461538461537,
						DominantAxis = Enum.DominantAxis.Height
					}),
					create("UIScale")({
						Scale = 1,
						Vide.action(function(p2)
							v2 = p2
							Vide.cleanup(function()
								local v7 = v3

								if v7 then
									v7:Cancel()
									v3 = nil
								end

								v2 = nil
							end)
						end)
					}),
					Button({
						Name = "ReturnToLobby",
						Size = UDim2.fromScale(1, 1),
						Text = source,
						Gradient = colorSequence,
						StrokeColor = Color3.fromRGB(63, 19, 105),
						OnMouseEnter = function()
							if not v5 then
								tweenButtonScale(1.04, tweenInfo)
							end
						end,
						OnMouseLeave = function()
							if not v5 then
								tweenButtonScale(1, tweenInfo)
							end
						end,
						OnActivated = function()
							if not v5 then
								v5 = true
								source("Returning...")
								tweenButtonScale(0.96, tweenInfo2)
								task.delay(tweenInfo2.Time, function()
									if not v4 then
										callback()
									end
								end)
							end
						end
					})
				})
			})
		end, p)
		return {
			destroy = function()
				if not v4 then
					v4 = true
					v6()
					local v7 = v

					if v7 ~= nil then
						v7:Destroy()
						v = nil
					end
				end
			end
		}
	end
}