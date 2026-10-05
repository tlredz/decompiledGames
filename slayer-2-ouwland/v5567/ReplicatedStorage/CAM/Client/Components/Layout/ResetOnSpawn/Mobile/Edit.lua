local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local HexagoneLeft = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.HexagoneLeft)
local MenuConfig = require(ReplicatedStorage.CAM.Client.Components.Layout.NoneResetting.Menu.MenuConfig)
local info = faye.Info(0.2)
local color = Color3.new(0.156863, 0.156863, 0.156863)
local color2 = Color3.new()
local color3 = Color3.new(1, 1, 1)
local color4 = Color3.new(1, 1, 1)
local color5 = Color3.new(1, 1, 1)
local color6 = Color3.new()
return function(maid, object, instance)
	local value = maid:Value(color)
	local value2 = maid:Value(color2)
	local value3 = maid:Value(color3)

	local function showState()
		local v = object:Get() == true
		local v3

		if v then
			v3 = color4
		else
			v3 = color
		end

		value:Set(v3)
		local v5

		if v then
			v5 = color5
		else
			v5 = color2
		end

		value2:Set(v5)
		local v7

		if v then
			v7 = color6
		else
			v7 = color3
		end

		value3:Set(v7)
	end

	local v = object:Get() == true
	local v2

	if v then
		v2 = color4
	else
		v2 = color
	end

	value:Set(v2)
	local v3

	if v then
		v3 = color5
	else
		v3 = color2
	end

	value2:Set(v3)
	local v4

	if v then
		v4 = color6
	else
		v4 = color3
	end

	value3:Set(v4)
	maid:Connect(object.Changed, showState)
	local initiateDestination = MenuConfig.InitiateDestination()

	local function mount(topBar)
		local left = topBar:FindFirstChild("Left") or topBar
		maid:Create("Frame")({
			Name = "1EditButton",
			Parent = left,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Visible = maid:Do(function(callback)
				return callback(initiateDestination) == ""
			end),
			maid:Create("UIAspectRatioConstraint")({}),
			maid:State(function(callback, maid2)
				if callback(initiateDestination) ~= "" then
					return nil
				end

				maid2:Add(function()
					object:Set(false)
				end)
				return maid2:Create("Frame")({
					Name = "Hexagon",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					HexagoneLeft(maid2, {
						Image = maid2:Do(function(callback2)
							if callback2(object) == true then
								return BunchaIcons.EditOn
							end

							return BunchaIcons.EditOff
						end),
						BgColor = maid2:Animation(value, info),
						FgColor = maid2:Animation(value2, info),
						ImageColor = maid2:Animation(value3, info),
						Clicked = function()
							object:Set(object:Get() ~= true)
						end
					})
				})
			end)
		})
	end

	maid:Add(function()
		object:Set(false)
	end)
	local topBar = instance:FindFirstChild("TopBar")

	if topBar == nil then
		maid:Spawn(function()
			local topBar2 = instance:WaitForChild("TopBar")

			if maid.IsActive and topBar2 ~= nil then
				mount(topBar2)
			end
		end)
	else
		mount(topBar)
	end
end