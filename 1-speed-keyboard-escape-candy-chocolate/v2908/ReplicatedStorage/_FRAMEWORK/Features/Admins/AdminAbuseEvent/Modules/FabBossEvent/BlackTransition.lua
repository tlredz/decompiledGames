local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Preloader = require(ReplicatedStorage._FRAMEWORK.Features.Preloader)
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
local v = {
	{
		username = "X3ll3n",
		role = "Music Composer",
		image = "rbxassetid://111211209789698",
		aspectRatio = 1
	},
	{
		username = "HardenKey",
		role = "Animator",
		image = "rbxassetid://131044806052122",
		aspectRatio = 1.7777777777777777
	},
	{
		username = "Fabuss254",
		role = "Lead Dev",
		image = "rbxassetid://129922866080046",
		aspectRatio = 1
	}
}
local sine = Enum.EasingStyle.Sine
local inOut = Enum.EasingDirection.InOut

local function animateTransparency(callback, p: number, p2: number, p3: number, fn)
	if p3 <= 0 then
		callback(p2)
		return
	end

	local lastTime = os.clock()

	while fn() do
		local v2 = math.clamp((os.clock() - lastTime) / p3, 0, 1)
		local value = TweenService:GetValue(v2, sine, inOut)
		callback(p + (p2 - p) * value)

		if v2 >= 1 then
			break
		else
			task.wait()
		end
	end
end

local function createCredit(data)
	return create("Frame")({
		Name = data.username,
		Size = UDim2.fromScale(0.3, 1),
		BackgroundTransparency = 1,
		create("Frame")({
			Name = "ImageArea",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.32),
			Size = UDim2.fromScale(0.9, 0.9),
			BackgroundTransparency = 1,
			create("UIAspectRatioConstraint")({
				AspectRatio = data.aspectRatio,
				DominantAxis = Enum.DominantAxis.Width
			}),
			create("ImageLabel")({
				Name = "Portrait",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = data.image,
				ScaleType = Enum.ScaleType.Fit,
				Vide.action(function(p)
					Preloader.preload(p)
				end)
			})
		}),
		create("TextLabel")({
			Name = "Username",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.66),
			Size = UDim2.fromScale(1, 0.1),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = data.username,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			create("UITextSizeConstraint")({
				MaxTextSize = 28
			})
		}),
		create("TextLabel")({
			Name = "Role",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.78),
			Size = UDim2.fromScale(1, 0.075),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = data.role,
			TextColor3 = Color3.fromRGB(185, 185, 195),
			TextScaled = true,
			create("UITextSizeConstraint")({
				MaxTextSize = 20
			})
		})
	})
end

return {
	mount = function(playerGui)
		local source = Vide.source(1)
		local source2 = Vide.source(false)
		local source3 = Vide.source(1)
		local v2 = nil
		local v3 = false
		local v4 = false
		local v5 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroyTransition()
			if not v3 then
				v3 = true
				v5()
				local v6 = v2

				if v6 then
					v6:Destroy()
					v2 = nil
				end
			end
		end

		v5 = Vide.mount(function()
			local v6 = table.create(#v)

			for k, v7 in v do
				v6[k] = createCredit(v7)
			end

			local v7 = create("Frame")({
				Name = "BlackScreen",
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = source,
				BorderSizePixel = 0,
				Visible = source2,
				create("CanvasGroup")({
					Name = "Credits",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					GroupTransparency = source3,
					create("UIAspectRatioConstraint")({
						AspectRatio = 1,
						DominantAxis = Enum.DominantAxis.Height
					}),
					create("TextLabel")({
						Name = "Title",
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0.1),
						Size = UDim2.fromScale(0.85, 0.1),
						BackgroundTransparency = 1,
						FontFace = rbxassetfontsfamiliesGothamSSmjson,
						Text = "Fab Admin Event",
						TextColor3 = Color3.new(1, 1, 1),
						TextScaled = true,
						create("UITextSizeConstraint")({
							MaxTextSize = 48
						})
					}),
					create("Frame")({
						Name = "CreditCards",
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0.23),
						Size = UDim2.fromScale(0.94, 0.67),
						BackgroundTransparency = 1,
						create("UIListLayout")({
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(0.025, 0),
							SortOrder = Enum.SortOrder.LayoutOrder
						}),
						table.unpack(v6)
					})
				})
			})

			if playerGui:IsA("PlayerGui") then
				return create("ScreenGui")({
					Name = "FabBossBlackTransition",
					ClipToDeviceSafeArea = false,
					DisplayOrder = 3100000,
					IgnoreGuiInset = true,
					ResetOnSpawn = false,
					ScreenInsets = Enum.ScreenInsets.None,
					ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
					Vide.action(function(p)
						v2 = p
					end),
					v7
				})
			end

			return create("Frame")({
				Name = "FabBossBlackTransitionPreview",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Vide.action(function(p)
					v2 = p
				end),
				v7
			})
		end, playerGui)
		return {
			play = function(data)
				if not (v3 or v4) then
					local v6 = math.max(not data and 1.5 or data.fadeInDuration or 1.5, 0)
					local v7 = math.max(not data and 7.5 or data.blackHoldDuration or 7.5, 0)
					local v8 = math.max(data and data.fadeOutDuration or 1.5, 0)
					v4 = true
					task.spawn(function()
						source2(true)
						animateTransparency(source, 1, 0, v6, function()
							return not v3
						end)

						if not v3 then
							local v9 = math.min(0.4, v7 / 2)
							local v10 = math.max(v7 - v9 * 2, 0)
							animateTransparency(source3, 1, 0, v9, function()
								return not v3
							end)

							if not v3 then
								task.wait(v10)
								animateTransparency(source3, 0, 1, v9, function()
									return not v3
								end)
							end

							animateTransparency(source, 0, 1, v8, function()
								return not v3
							end)
						end

						if not v3 then
							source2(false)
							v4 = false
							destroyTransition() -- equivalent call inferred; original call site unknown
						end
					end)
				end
			end,
			destroy = function()
				destroyTransition() -- equivalent call inferred; original call site unknown
			end
		}
	end
}