local HttpService = game:GetService("HttpService")
_G.import("global")
local import = _G.import("romodel")
_G.import("iterator")
local import2 = _G.import("event")
local import3 = _G.import("iconData")
local import4 = _G.import("clientUtil")
local import5 = _G.import("dictUtil")
local import6 = _G.import("viewImports")
local basic = import6:get("basic")
local react = import6:get("react")
local model = import.model(basic.EmptyList)

function model.init(p)
	return {
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Size = UDim2.new(1, 0, 0.475, 0),
		Padding = UDim.new(0.05, 0)
	}, {
		Icon = import.make(basic.ImageLabel, {
			Size = UDim2.new(1, 0, 1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Image = import3[p.Id]
		}),
		Text = import.make(import.wrap(basic.TextLabel, react.LinkedText), {
			Size = UDim2.new(0.5, 0, 0.75, 0),
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			StrokeWidth = 0.085,
			Text = "Hello",
			TextXAlignment = Enum.TextXAlignment.Left,
			KeyChains = { "Statistics." .. p.Id },
			TextSavedChanged = function(state, p2)
				local statistic = p2.Statistics[p.Id]
				local text = tonumber(state.Text)

				if not text then
					return statistic
				end

				local GUID = HttpService:GenerateGUID()
				state.Animation = GUID
				local v = statistic - text
				local _ = v / 1.5

				for i = 0, 1, 0.06666666666666667 do
					if state.Animation ~= GUID then
						break
					end

					state.Text = math.floor(text + v * i)
					task.wait(0.1)
				end

				return statistic
			end
		})
	}
end

local model2 = import.model(basic.List)

function model2.init()
	return {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0.05, 0, 0.925, 0),
		PaddingBottom = UDim.new(0.15, 0),
		PaddingLeft = UDim.new(0.075, 0),
		Size = UDim2.new(1, 0, 1, 0),
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0.05, 0)
	}, {
		WinsLabel = import.make(model, {
			Id = "Wins",
			LayoutOrder = 1
		}),
		CashLabel = import.make(model, {
			Id = "Cash",
			LayoutOrder = 2
		})
	}
end

function model2:prespawn()
	self.Con = import2.connect("StateChanged", function(_, p2, _, _, p3)
		if not (p2 == "savedState" and import5.match({ "Statistics", "Cash" }, p3)) then
			return
		end

		import4.sound("ItemPurchase1")
	end, {
		Blocking = true
	})
end

function model2.despawn(p)
	import2.disconnect(p.Con)
end

local model3 = import.model("ScreenGui", basic.Ui)

function model3.init()
	return {
		Scale = 0.19,
		AspectRatio = 2,
		Location = "BottomLeft",
		ResetOnSpawn = false,
		Content = {
			Container = import.make(model2)
		}
	}
end

return {
	BottomLeftBar = model3
}