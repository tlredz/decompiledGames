local localPlayer = game.Players.LocalPlayer
local SocialService = game:GetService("SocialService")
local import = _G.import("event")
local import2 = _G.import("romodel")
local import3 = _G.import("iterator")
local import4 = _G.import("viewImports")
local basic = import4:get("basic")
local menu = import4:get("menu")
local react = import4:get("react")
local ux = import4:get("ux")
local free = import4:get("free").Free
local v = {
	Invite = {
		Icon = "rbxassetid://86865428487273",
		Color = ColorSequence.new(Color3.fromRGB(82, 194, 255), Color3.fromRGB(48, 127, 230)),
		StrokeColor = Color3.fromRGB(39, 81, 118),
		Behavior = function(_)
			local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
			experienceInviteOptions.PromptMessage = "Ask your friends to join the adventure!"

			-- equivalent calls inferred from this helper; original call sites unknown
			local function canSendGameInvite(p)
				local success, result = pcall(function()
					return SocialService:CanSendGameInviteAsync(p)
				end)
				return success and result
			end

			if canSendGameInvite(localPlayer) then
				SocialService:PromptGameInvite(localPlayer, experienceInviteOptions)
			end
		end
	},
	Store = {
		Icon = "rbxassetid://83743957756812",
		Color = ColorSequence.new(
			Color3.fromHSV(0.16666666666666666, 1, 1),
			Color3.fromHSV(0.06944444444444445, 0.8627450980392157, 1)
		),
		StrokeColor = Color3.fromHSV(0.06975, 0.865034, 0.639216),
		Behavior = function(_)
			import.fire("openMenu", "Store")
		end
	},
	Free = {
		Icon = "rbxassetid://120603215831127",
		Color = ColorSequence.new(Color3.fromRGB(191, 0, 255), Color3.fromRGB(49, 33, 171)),
		StrokeColor = Color3.fromRGB(49, 33, 171),
		Menu = free,
		Behavior = function(_)
			import.fire("openMenu", "Free")
		end
	}
}
local model = import2.model(basic.ImageButton, basic.Corner, ux.Button, react.Reactive)

function model.init(p)
	local id = p.Id
	local v2 = v[id]
	return {
		Size = UDim2.new(1, 0, 1, 0),
		KeyChains = v2.Menu and v2.Menu:getExclamKeyChains(),
		SavedChanged = v2.Menu and function(p2, p3)
			p2.Exclam.Visible = v2.Menu:hasExclam(p3)
		end,
		StrokeColor = v2.StrokeColor,
		StrokeWidth = 5,
		Image = "rbxassetid://120822935454304",
		MouseButton1Down = function(p2)
			v2.Behavior(p2)
		end,
		CornerRadius = UDim.new(0.1, 0)
	}, {
		UIGradient = import2.make("UIGradient", {
			Color = v2.Color,
			Rotation = 90
		}),
		Stroke = import2.make(basic.Corner, {
			BackgroundColor3 = v2.StrokeColor,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1.075, 0, 1.075, 0),
			CornerRadius = UDim.new(0.11, 0),
			ZIndex = -1
		}, {
			Outer = import2.make(basic.Corner, {
				BackgroundColor3 = Color3.new(0, 0, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1.075, 0, 1.075, 0),
				CornerRadius = UDim.new(0.125, 0),
				ZIndex = -1
			})
		}),
		Icon = import2.make(basic.ImageLabel, {
			Location = "Center",
			Scale = 0.8,
			Image = v2.Icon
		}),
		TextLabel = import2.make(basic.TextLabel, {
			Position = UDim2.new(0, 0, 0.6, 0),
			Size = UDim2.new(1, 0, 0.3, 0),
			Font = Enum.Font.GothamBlack,
			StrokeWidth = 3,
			StrokeColor = Color3.new(0.1, 0.1, 0.1),
			Text = id,
			ZIndex = 2
		}),
		Exclam = v2.Menu and import2.make(menu.ExclamBadge, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.95, 0, 0.05, 0),
			Size = UDim2.new(0.3, 0, 0.3, 0),
			Visible = false,
			ZIndex = 3
		}) or nil
	}
end

local model2 = import2.model(basic.EmptyList)

function model2.init()
	return {
		Position = UDim2.new(0.2, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0.075, 0)
	}, import3.mapArr({ "Invite", "Store", "Free" }, function(p, id)
		return p, import2.make(model, {
			Id = id
		})
	end)
end

local model3 = import2.model("ScreenGui", basic.Ui)

function model3.init()
	return {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Scale = 0.065,
		AspectRatio = 0.3,
		MaxSize = 400,
		MinSize = 55,
		Location = "CenterLeft",
		Content = {
			Main = import2.make(model2)
		}
	}
end

return {
	LeftBar = model3
}