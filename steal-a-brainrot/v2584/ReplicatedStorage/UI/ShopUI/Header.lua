local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.vide)
local Layout = require(script.Parent.Layout)
local Reactive = require(script.Parent.Reactive)
require(script.Parent.State)
return table.freeze({
	Mount = function(p, data, _)
		local resolved = Layout.Resolve(p, data.List)

		if not (resolved and resolved:IsA("ScrollingFrame")) then
			return
		end

		local resolved2 = Layout.Resolve(p, data.Close)
		local main = resolved2 and resolved2.Parent and resolved2.Parent:FindFirstChild("Main")

		if not main then
			return
		end

		for _, button in main:GetChildren() do
			if not button:IsA("GuiButton") then
				continue
			end

			local tab = data.Tabs[button.Name]
			local resolved3

			if tab then
				resolved3 = Layout.Resolve(resolved, tab)
			end

			if not (resolved3 and resolved3:IsA("GuiObject")) then
				continue
			end

			local v = resolved3
			Reactive.Button(button, function()
				local v2 = v.AbsolutePosition.Y - resolved.AbsolutePosition.Y + resolved.CanvasPosition.Y
				resolved.CanvasPosition = Vector2.new(resolved.CanvasPosition.X, v2)
			end)
		end
	end
})