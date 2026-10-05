local localPlayer = game.Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")
local import = _G.import("romodel")
local import2 = _G.import("iterator")
local import3 = _G.import("global")
local import4 = _G.import("viewImports")
local basic = import4:get("basic")
local ux = import4:get("ux")
local model = import.model(basic.ImageButton, basic.Corner, ux.Button)

function model.init(_)
	return {
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.new(0, 0, 0),
		Size = UDim2.new(1.1, 0, 1.1, 0),
		CornerRadius = UDim.new(1, 0),
		MouseButton1Down = function(p)
			MarketplaceService:PromptGamePassPurchase(localPlayer, p.Id)
		end,
		_Events = {
			MouseEnter = function(p)
				p.NoRotate = true
			end,
			MouseLeave = function(p)
				p.NoRotate = false
			end
		}
	}, {}
end

function model:prespawn()
	local productInfoAsync = MarketplaceService:GetProductInfoAsync(self.Id, Enum.InfoType.GamePass)
	task.spawn(function()
		if not self.Rate then
			return
		end

		self.Con = true
		local total = 0

		while self.Con do
			total += task.wait(0)

			if self.NoRotate then
				self.Inner.Rotation = 0
			else
				self.Inner.Rotation = math.sin(total * self.Rate) * 10
			end
		end
	end)
	return nil, {
		Inner = import.make(import.wrap("ImageLabel", basic.Gradient, basic.Corner), {
			Location = "Center",
			CornerRadius = UDim.new(1, 0),
			Size = UDim2.new(0.9, 0, 0.9, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Image = "rbxassetid://120822935454304",
			GradientColor = ColorSequence.new(Color3.fromRGB(134, 255, 5), Color3.fromRGB(39, 171, 87)),
			GradientRotation = 90
		}, {
			PriceLabel = import.make(basic.EmptyList, {
				ZIndex = 2,
				Rotation = -10,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.4, 0, 0.05, 0),
				Size = UDim2.new(1, 0, 0.4, 0),
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.04, 0)
			}, {
				PriceText = import.make(basic.TextLabel, {
					LayoutOrder = 1,
					Text = productInfoAsync.PriceInRobux,
					Size = UDim2.new(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					StrokeWidth = 3
				}),
				RobuxIcon = import.make(basic.ImageLabel, {
					LayoutOrder = 2,
					Scale = 1,
					AspectRatio = 0.95,
					Image = "rbxassetid://71088677577525"
				})
			}),
			Image = import.make(basic.ImageLabel, {
				Scale = 1,
				Image = "rbxassetid://" .. productInfoAsync.IconImageAssetId
			}),
			Text = import.make(basic.TextLabel, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.9, 0),
				Size = UDim2.new(0.96, 0, 0.5599999999999999, 0),
				Text = productInfoAsync.Name,
				StrokeWidth = 3,
				ZIndex = 2
			})
		})
	}
end

function model:despawn()
	self.Con = false
end

local model2 = import.model(basic.EmptyList)

function model2.init()
	local playerSave = import3.get("playerSave", localPlayer)
	local pass = playerSave:hasPass(1822375917)
	local v = {
		{
			Id = 1854105063
		},
		(pass or playerSave:hasPass(1853997082)) and ({
			Id = pass and 1822375917 or 1853997082
		} or nil) or nil
	}
	return {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0.8, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0.07, 0)
	}, import2.mapArr(v, function(p, p2)
		return p, import.make(model, {
			Id = p2.Id,
			Rate = p == 1 and 4 or false
		})
	end)
end

local model3 = import.model("ScreenGui", basic.Ui)

function model3.init()
	return {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Name = "RightBar",
		Scale = 0.065,
		AspectRatio = 0.3,
		MaxSize = 400,
		MinSize = 45,
		Location = "CenterRight",
		Content = {
			Main = import.make(model2)
		}
	}
end

return {
	RightBar = model3
}