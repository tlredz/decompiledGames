local import = _G.import("romodel")
local basic = _G.import("viewImports"):get("basic")
local model = import.model(basic.Element)

function model.init(p)
	return {
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0, -1),
		Size = UDim2.fromScale(1, 1),
		Callback = p.Callback
	}
end

function model.prespawn(object)
	local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	task.spawn(function()
		object:tween(tweenInfo, {
			Position = UDim2.fromScale(0, 0)
		})
		task.wait(0.35)

		if object.Callback then
			object.Callback()
		end

		object:tween(tweenInfo, {
			Position = UDim2.fromScale(0, -1)
		})
		task.wait(0.35)
		object.Parent:Destroy()
	end)
end

local model2 = import.model("ScreenGui")

function model2.init(p)
	return {
		Name = "WipeDown",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 20
	}, {
		Frame = import.make(model, p)
	}
end

return {
	WipeDown = model2
}