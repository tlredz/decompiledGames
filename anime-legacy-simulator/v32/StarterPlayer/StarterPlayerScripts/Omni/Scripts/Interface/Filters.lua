local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(118, 255, 106)
local color3 = Color3.fromRGB(135, 144, 153)
local filters = module.Interface:WaitForChild("Frames"):WaitForChild("Filters")
local main = filters:WaitForChild("Main")
local buttons = main:WaitForChild("Buttons")
local scroll = main:WaitForChild("List"):WaitForChild("Scroll")
local filters2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Filters")
local v = {}
local v2 = nil
local Filters = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearCurrent()
	if not v2 then
		return
	end

	for _, connection in v2.Connections do
		connection:Disconnect()
	end

	table.clear(v2.Connections)
	v2 = nil
end

function Filters.Update()
	if not v2 then
		return
	end

	local v3 = {}

	for k, v4 in v2.List do
		local v5 = v2.Result[k]

		if not v5 then
			return
		end

		local formatted = `Category_{k}`
		local v6 = v[formatted]
		local layoutOrder = (v4.Index or 1) * 100

		if v6 then
			v6.LayoutOrder = layoutOrder
		else
			local clone = filters2.Category:Clone()
			clone.Name = formatted
			clone.Title.Text = k
			clone.LayoutOrder = layoutOrder
			clone.Parent = scroll
			clone.Visible = true
			v[formatted] = clone
		end

		for k2, v8 in v4.List do
			local formatted2 = `Option_{k2}_{k}`
			local clone = v[formatted2]
			local enabled = v5[v8.Name] == true

			if not clone then
				clone = filters2.Option:Clone()
				clone.Name = formatted2
				local v10 = k
				local v11 = v8
				module.Button:Create(clone.Main, "Small"):BindFunction("Click", function()
					if not v2 then
						return
					end

					local v12 = v2.List[v10]

					if not v12 then
						return
					end

					local v13 = v2.Result[v10]

					if not v13 then
						return
					end

					if v12.Multi then
						v13[v11.Name] = v13[v11.Name] == nil or nil
					else
						table.clear(v13)
						v13[v11.Name] = true
					end

					Filters.Update()
				end)

				if v8.Rarity then
					clone.Main.UIGradient:AddTag("GradientWaves")
					clone.Main.UIGradient:SetAttribute("Rarity", v8.Rarity)
				end

				clone.Parent = scroll
				clone.Visible = true
				v[formatted2] = clone
			end

			if v8.Rarity then
				clone.Main.UIGradient.Enabled = enabled
				clone.Main.ImageColor3 = enabled and color or color3
			else
				clone.Main.UIGradient.Enabled = true
				clone.Main.UIGradient.Color = ColorSequence.new(enabled and (v8.Color or color2) or color3)
			end

			clone.Main.Title.Text = v8.Text or "???"
			clone.LayoutOrder = layoutOrder + k2
			v3[formatted2] = true
		end

		v3[formatted] = true
	end

	for k, v4 in v do
		if v3[k] then
			continue
		end

		v4:Destroy()
		v[k] = nil
	end
end

function Filters.Start(data)
	if v2 then
		return
	end

	v2 = {
		List = data.List,
		Result = module.Utils.Table:DeepCopy(data.Current or data.Default),
		Default = data.Default,
		Callback = data.Callback,
		Connections = {
			Loop = module.Utils.Loop:Connect({
				Time = 1,
				Callback = Filters.Update
			})
		}
	}
	Filters.Update()

	if data.PastUI then
		module.Frame:SetPastUI(data.PastUI)
	end

	module.Frame:Open(filters)
end

function Filters.Stop()
	ClearCurrent() -- equivalent call inferred; original call site unknown
	module.Frame:Close(filters)
end

module.Button:Create(buttons.Apply.Main, "Small"):BindFunction("Click", function()
	if not v2 then
		return
	end

	v2.Callback(v2.Result)
	Filters.Stop()
end)
module.Button:Create(buttons.Cancel.Main, "Small"):BindFunction("Click", function()
	if not v2 then
		return
	end

	Filters.Stop()
end)
module.Button:Create(buttons.Reset.Main, "Small"):BindFunction("Click", function()
	if not v2 then
		return
	end

	v2.Result = module.Utils.Table:DeepCopy(v2.Default)
	Filters.Update()
end)
module.Frame:OnFrameClosed(filters, ClearCurrent)
return Filters