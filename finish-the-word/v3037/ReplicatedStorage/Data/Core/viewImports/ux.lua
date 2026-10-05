local import = _G.import("clientUtil")
local import2 = _G.import("romodel")
local basic = _G.import("viewImports"):get("basic")
local model = import2.model("Frame")

function model.init(options)
	return {
		Disabled = (options or {}).Disabled,
		MouseEnter = function(p)
			if p.Disabled then
				return
			end

			p.UIScale:tween(TweenInfo.new(0.2, Enum.EasingStyle.Back), {
				Scale = 1.15
			})
			import.sound("Pop3")
		end,
		MouseLeave = function(p)
			if p.Disabled then
				return
			end

			p.UIScale:tween(TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				Scale = 1
			})
		end,
		_Events = {
			MouseButton1Down = function(p)
				if p.Disabled then
					return
				end

				p.UIScale:tween(TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
					Scale = 0.7
				})
				task.wait(0.1)
				p.UIScale:tween(TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
					Scale = 1
				})
				import.sound("Pop1")
			end
		}
	}, {
		UIScale = import2.make("UIScale", basic.Element)
	}
end

return {
	Button = model
}