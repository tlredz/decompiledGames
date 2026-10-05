local modules = script.Parent.Parent.Modules
local Packages = require(modules.Packages)
local Roact = require(Packages.Directory.Roact)
local extended = Roact.Component:extend("PacketFrame")

function extended:render()
	local props = self.props
	return Roact.createElement("ImageLabel", {
		Size = props.PacketsChanged:map(function(p)
			local v = p[props.Index]

			if not v then
				return Roact.Constant.SkipBindingUpdate
			end

			local v2 = math.min(v.TotalSize / self.props.MaxFrameSize, 1)
			local uDim = UDim2.fromScale(1 / props.MaxFrames, v2)

			if uDim == self.PreviousFrameSize then
				return Roact.Constant.SkipBindingUpdate
			end

			self.PreviousFrameSize = uDim
			return uDim
		end),
		Image = "rbxassetid://10370998310",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(1 - props.Index / props.MaxFrames, 1),
		BorderSizePixel = 0,
		Visible = props.PacketsChanged:map(function(p)
			local previousIsVisible = p[props.Index] ~= nil

			if previousIsVisible == self.PreviousIsVisible then
				return Roact.Constant.SkipBindingUpdate
			end

			self.PreviousIsVisible = previousIsVisible
			return previousIsVisible
		end),
		BorderColor3 = Color3.new(1, 1, 1)
	})
end

return extended