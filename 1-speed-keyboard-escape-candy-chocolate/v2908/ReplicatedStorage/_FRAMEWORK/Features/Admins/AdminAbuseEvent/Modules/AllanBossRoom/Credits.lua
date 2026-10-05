local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Preloader = require(ReplicatedStorage._FRAMEWORK.Features.Preloader)
local Config = require(script.Parent.Config)
local create = Vide.create
local sine = Enum.EasingStyle.Sine
local inOut = Enum.EasingDirection.InOut
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
local source = Vide.source(0)
local source2 = Vide.source(0)
local v = nil
local v2 = nil
local count = 0

local function createCreditCard(credit)
	return create("Frame")({
		Name = credit.username,
		Size = UDim2.fromScale(0.3, 1),
		BackgroundTransparency = 1,
		create("Frame")({
			Name = "ImageArea",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.32),
			Size = UDim2.fromScale(0.9, 0.9),
			BackgroundTransparency = 1,
			create("UIAspectRatioConstraint")({
				AspectRatio = credit.aspectRatio,
				DominantAxis = Enum.DominantAxis.Width
			}),
			create("ImageLabel")({
				Name = "Portrait",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = credit.image,
				ScaleType = Enum.ScaleType.Fit,
				Vide.action(function(p)
					if credit.image ~= "" then
						Preloader.preload(p)
					end
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
			Text = credit.username,
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
			Text = credit.role,
			TextColor3 = Color3.fromRGB(185, 185, 195),
			TextScaled = true,
			create("UITextSizeConstraint")({
				MaxTextSize = 20
			})
		})
	})
end

local function ensureMounted()
	if v then
		return true
	end

	local localPlayer = Players.LocalPlayer
	local playerGui

	if localPlayer then
		playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	end

	if playerGui then
		v2 = Vide.mount(function()
			local v3 = table.create(#Config.credits)

			for k, credit in Config.credits do
				v3[k] = createCreditCard(credit)
			end

			local v4 = create("ScreenGui")({
				Name = "AllanBossRoomCredits",
				ClipToDeviceSafeArea = false,
				DisplayOrder = 3200100,
				IgnoreGuiInset = true,
				ResetOnSpawn = false,
				ScreenInsets = Enum.ScreenInsets.None,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				create("Frame")({
					Name = "Cover",
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = function()
						return 1 - source()
					end,
					BorderSizePixel = 0,
					Visible = function()
						return source() > 0
					end,
					create("CanvasGroup")({
						Name = "Credits",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						GroupTransparency = function()
							return 1 - source2()
						end,
						create("UIAspectRatioConstraint")({
							AspectRatio = 1,
							DominantAxis = Enum.DominantAxis.Height
						}),
						create("TextLabel")({
							Name = "Title",
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.fromScale(0.5, 0.14),
							Size = UDim2.fromScale(0.85, 0.1),
							BackgroundTransparency = 1,
							FontFace = rbxassetfontsfamiliesGothamSSmjson,
							Text = Config.creditsTitle,
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
							table.unpack(v3)
						})
					})
				})
			})
			v = v4
			return v4
		end, playerGui)
		return true
	end

	warn("[AllanBossRoom] Credits could not resolve the local PlayerGui; the credits roll is disabled")
	return false
end

local function animate(callback, p: number, creditsFadeSeconds: number, p2: number)
	local v3 = callback()

	if creditsFadeSeconds <= 0 then
		callback(p)
		return count == p2
	end

	local lastTime = os.clock()

	while count == p2 do
		local v4 = math.clamp((os.clock() - lastTime) / creditsFadeSeconds, 0, 1)
		local value = TweenService:GetValue(v4, sine, inOut)
		callback(v3 + (p - v3) * value)

		if v4 >= 1 then
			break
		else
			task.wait()
		end
	end

	return count == p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teardown()
	count += 1
	source(0)
	source2(0)

	if v2 then
		v2()
		v2 = nil
	end

	if v then
		v:Destroy()
		v = nil
	end
end

local Credits = {}

function Credits.play()
	if RunService:IsServer() or not ensureMounted() then
		return
	end

	count += 1
	local v3 = count
	source(1)
	source2(0)
	local creditsFadeSeconds = Config.creditsFadeSeconds
	task.spawn(function()
		if not animate(source2, 1, creditsFadeSeconds, v3) then
			return
		end

		local lastTime = os.clock()

		while count == v3 and os.clock() - lastTime < Config.creditsHoldSeconds do
			task.wait()
		end

		if animate(source2, 0, creditsFadeSeconds, v3) and animate(source, 0, creditsFadeSeconds, v3) then
			teardown() -- equivalent call inferred; original call site unknown
		end
	end)
end

function Credits.cleanup()
	teardown() -- equivalent call inferred; original call site unknown
end

return Credits