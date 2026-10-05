local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SolidRectangleGradientHover = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.SolidRectangleGradientHover)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
require(ReplicatedStorage.Packages.faye)
require(ReplicatedStorage.Packages.simplesignal)
return function(object, p)
	local value = object:Value()
	local text = object:Value("Edit")
	local image = object:Value("rbxassetid://101612286691224")
	local value4 = object:Value(Color3.new(1, 1, 1))
	local bgProperties = {
		BackgroundTransparency = 0.5
	}
	local v2 = {
		Color = value4,
		Name = "3Select",
		Image = image,
		TextStrokeTransparency = 0.85,
		Text = text,
		StrokeThickness = 1.5,
		StrokeDisabled = true,
		TweenSizeOnEntry = true,
		Alignment = Enum.TextXAlignment.Right,
		Clicked = function()
			p.Enabled:Set(not p.Enabled.Value)
		end,
		BgProperties = bgProperties,
		ContentColor = value4
	}
	local flag = false
	local v3 = {
		TextStrokeTransparency = 0.85,
		Color = Color3.new(1, 0.007843, 0.007843),
		Text = "Delete",
		StrokeDisabled = true,
		TweenSizeOnEntry = true,
		Name = "2Sell",
		StrokeThickness = 1.5,
		BgProperties = bgProperties,
		ContentColor = Color3.new(1, 0.737255, 0.670588),
		Clicked = function()
			if flag then
				return
			end

			local data = Utility.GetData(Players.LocalPlayer)
			local v4 = {}
			local v5 = {}

			for k, v6 in pairs(p.Selected:Get()) do
				local total = 0

				if type(v6) == "table" then
					for k2, v7 in v6 do
						if k2 ~= "Count" and type(v7) == "number" then
							total += v7
						end
					end
				end

				local value5 = total < 1 and 1 or total
				local heldItem = Utility.HeldItem(data, k)
				local amount

				if heldItem ~= nil then
					amount = heldItem:FindFirstChild("Amount") or nil
				end

				if amount ~= nil and amount.Value < value5 then
					value5 = amount.Value
				end

				v4[k] = value5
				local v7 = string.gsub(k, "_", " ")

				if value5 > 1 then
					v7 ..= ` x{value5}`
				end

				table.insert(v5, v7)
			end

			if #v5 == 0 then
				return
			end

			local v6

			if #v5 > 3 then
				v6 = `{v5[1]}, {v5[2]}, {v5[3]} +{#v5 - 3}`
			elseif #v5 == 1 then
				v6 = v5[1]
			else
				v6 = `{table.concat(v5, ", ", 1, #v5 - 1)} and {v5[#v5]}`
			end

			flag = true

			if PopUpCreator.new({
				Type = "Question",
				Content = `Are you sure you want to delete {v6}?`
			}).Result:Wait(5) == "Yes" then
				local v7 = PopUpCreator.new({
					Type = "LoadingFull"
				})
				local server = SignalFunction.ToServer("DeleteItems", v4)
				v7:Destroy()
				p.Selected:Set({})

				if (tonumber(server) or 0) < 1 then
					game.ReplicatedStorage.Communication.CnC.Notifications.Notification:Fire("Notify", {
						Text = "Nothing could be deleted, those items are protected.",
						Type = "Denied"
					})
				end
			end

			flag = false
		end
	}

	local function updButtonsEq(p2)
		if p2 then
			value4:Set(Color3.new(1, 0.627451, 0.627451))
			text:Set("Close")
			image:Set("rbxassetid://140084835628457")
			value:Set({ v2, v3 })
		else
			value4:Reset()
			text:Reset()
			image:Reset()
			value:Set({ v2 })
		end
	end

	updButtonsEq(p.Enabled:Get())
	p.Enabled.Changed:Connect(updButtonsEq)
	return object:Iterate(value, function(_, p2, p3)
		return SolidRectangleGradientHover(p3, p2)
	end)
end