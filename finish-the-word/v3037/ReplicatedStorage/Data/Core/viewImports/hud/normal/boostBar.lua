local import = _G.import("romodel")
local import2 = _G.import("viewImports")
local basic = import2:get("basic")
local react = import2:get("react")
local RunService = game:GetService("RunService")
local v = {
	WinBoost = {
		Label = "2x Wins",
		Color = Color3.fromRGB(100, 200, 255)
	},
	StreakBoost = {
		Label = "2x Streak",
		Color = Color3.fromRGB(255, 200, 60)
	},
	CashBoost = {
		Label = "2x Cash",
		Color = Color3.fromRGB(80, 230, 100)
	},
	XpBoost = {
		Label = "2x XP",
		Color = Color3.fromRGB(200, 100, 255)
	}
}

local function formatTime(p)
	local v2 = math.max(0, (math.floor(p)))

	if v2 >= 86400 then
		return math.floor(v2 / 86400) .. "d " .. math.floor(v2 % 86400 / 3600) .. "h"
	end

	if v2 >= 3600 then
		return math.floor(v2 / 3600) .. "h " .. math.floor(v2 % 3600 / 60) .. "m"
	end

	if v2 >= 60 then
		return math.floor(v2 / 60) .. "m " .. v2 % 60 .. "s"
	end

	return v2 .. "s"
end

local model = import.model(basic.EmptyList, basic.Corner, basic.Padding)

function model.init(p)
	local v2 = v[p.Id] or {
		Label = p.Id,
		Color = Color3.new(1, 1, 1)
	}
	return {
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.35,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		CornerRadius = UDim.new(0.4, 0),
		ExpirationDate = p.ExpirationDate,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10)
	}, {
		NameLabel = import.make(basic.TextLabel, {
			LayoutOrder = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = v2.Label,
			TextColor3 = v2.Color,
			StrokeWidth = 2
		}),
		Separator = import.make(basic.TextLabel, {
			LayoutOrder = 2,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "•",
			TextColor3 = Color3.fromRGB(160, 160, 160),
			StrokeWidth = 1
		}),
		TimeLabel = import.make(basic.TextLabel, {
			LayoutOrder = 3,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "...",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			StrokeWidth = 2
		})
	}
end

function model:prespawn()
	if self.Con then
		return
	end

	self.Con = RunService.Heartbeat:Connect(function()
		self.TimeLabel.Text = formatTime(self.ExpirationDate - os.time())
	end)
end

function model.despawn(p)
	if not p.Con then
		return
	end

	p.Con:Disconnect()
end

local model2 = import.model(basic.EmptyList, react.Reactive)

function model2.init()
	return {
		Size = UDim2.new(1, 0, 1, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		KeyChains = { "TimedProcessInstances" },
		SavedChanged = function(object, p)
			local result = {}

			for _, v2 in p.TimedProcessInstances:pairs() do
				if v2.ExpirationDate <= os.time() or not v[v2.Id] then
					continue
				end

				table.insert(result, import.make(model, {
					Id = v2.Id,
					ExpirationDate = v2.ExpirationDate
				}))
			end

			object:ClearReactiveChildren()
			return nil, result
		end
	}
end

local model3 = import.model("ScreenGui")

function model3.init()
	return {
		Name = "BoostBar",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 2
	}, {
		Container = import.make(basic.EmptyElement, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0.01, 0),
			Size = UDim2.new(0.45, 0, 0.04, 0)
		}, {
			Inner = import.make(model2)
		})
	}
end

return {
	BoostBar = model3
}