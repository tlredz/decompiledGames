local GatewayController = {}
local name = nil
local scrollingFrame = script.Parent.Container.List.ScrollingFrame
local template = script.Parent.Container.List.ScrollingFrame.Template
script.Parent:WaitForChild("Info"):WaitForChild("Exit").MouseButton1Click:Connect(function()
	name = false
end)

function GatewayController.Clear()
	for _, child in pairs(script.Parent.Container.List.ScrollingFrame:GetChildren()) do
		if child.Name ~= "Template" and child.Name ~= "UIGridLayout" then
			child:Destroy()
		end
	end
end

function getColor3Similarity(data, data2)
	local R = data.R
	local G = data.G
	local B = data.B
	local R2 = data2.R
	local G2 = data2.G
	local B2 = data2.B
	return 1 - math.sqrt((R2 - R) ^ 2 + (G2 - G) ^ 2 + (B2 - B) ^ 2) / 1.7320508075688772
end

local function setcolors(flag: boolean)
	local color = Color3.new(1, 0.839216, 0.192157)
	local color2 = Color3.new(1, 0.941176, 0.270588)
	local color3 = Color3.new(1, 0.945098, 0.341176)
	local color4 = Color3.new(1, 0.772549, 0.0784314)

	if flag then
		for _, descendant in script.Parent:GetDescendants() do
			local v = descendant
			pcall(function()
				if getColor3Similarity(v.BorderColor3, color2) > 0.9 then
					v.BorderColor3 = Color3.fromRGB(48, 158, 255)
				end

				if getColor3Similarity(v.BorderColor3, color4) > 0.9 then
					v.BorderColor3 = Color3.fromRGB(55, 108, 255)
				end
			end)
			local v2 = descendant
			pcall(function()
				if getColor3Similarity(v2.BackgroundColor3, color) > 0.9 then
					v2.BackgroundColor3 = Color3.fromRGB(116, 190, 255)
				end

				if getColor3Similarity(v2.BackgroundColor3, color3) > 0.9 then
					v2.BackgroundColor3 = Color3.fromRGB(148, 212, 255)
				end
			end)
		end
	else
		for _, descendant in script.Parent:GetDescendants() do
			local v = descendant
			pcall(function()
				if v.BorderColor3 == Color3.fromRGB(48, 158, 255) then
					v.BorderColor3 = color2
				end

				if v.BorderColor3 == Color3.fromRGB(55, 108, 255) then
					v.BorderColor3 = color4
				end
			end)
			local v2 = descendant
			pcall(function()
				if v2.BackgroundColor3 == Color3.fromRGB(116, 190, 255) then
					v2.BackgroundColor3 = color
				end

				if v2.BackgroundColor3 == Color3.fromRGB(148, 212, 255) then
					v2.BackgroundColor3 = color3
				end
			end)
		end
	end
end

function GatewayController.LoadListAndAwaitSelection(items)
	name = nil
	script.Parent.Title.Text = "GATEWAY"
	script.Parent.Visible = true
	GatewayController.Clear()

	for k, _ in pairs(items) do
		local clone = template:Clone()
		clone.TextLabel.Text = k
		clone.Name = k
		clone.Visible = true
		clone.Parent = scrollingFrame
		local v = k
		clone.MouseButton1Click:Connect(function()
			name = v
		end)
	end

	setcolors(false)

	repeat
		wait()
	until name ~= nil

	script.Parent.Visible = false
	return name
end

function GatewayController.LoadPriceListAndAwaitSelection(items, p)
	name = nil
	script.Parent.Visible = true
	script.Parent.Title.Text = "SUBMARINE"
	GatewayController.Clear()

	for _, item in pairs(items) do
		local clone = template:Clone()
		clone.TextLabel.Text = `{item.Name}\n${item.TransportationPrice == 0 and "Free" or item.TransportationPrice}`
		clone.Name = item.Name
		clone.Visible = true
		clone.Parent = scrollingFrame
		local v = item
		clone.MouseButton1Click:Connect(function()
			name = v.Name
		end)
	end

	setcolors(true)

	repeat
		wait()
	until name ~= nil or p and p.close

	script.Parent.Visible = false
	return name
end

return GatewayController