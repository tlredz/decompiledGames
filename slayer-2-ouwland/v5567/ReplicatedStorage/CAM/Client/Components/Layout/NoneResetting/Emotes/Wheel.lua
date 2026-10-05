local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local faye = require(ReplicatedStorage.Packages.faye)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Emotes = require(ReplicatedStorage.CAM.Emotes)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Browser = require(script.Parent.Browser)
local localPlayer = Players.LocalPlayer
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Slot = require(script.Parent.Slot)
local HUD = ReplicatedStorage.CAM.Client.Components.Layout.Visibility.HUD
local v = {
	{
		"Super Saiyan",
		"Sit",
		"Cry",
		"Godlike",
		"Sleeping",
		"Laugh"
	},
	{
		"Grave Digger",
		"Salt Shaker",
		"Bunny Dance",
		"Take the L",
		"Griddy",
		"Dance Moves"
	}
}
local thumbstick2 = Enum.KeyCode.Thumbstick2
local springInfo = faye.SpringInfo(0.4, 1, 0.4)
local uDim = UDim2.fromScale(0, 0)
local info = faye.Info(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local v2 = 1
return function(parent, callback)
	local maid = faye.new()
	local v3 = Platform_Handler.Platform.Value == "Mobile"
	local isGamepad = Platform_Handler.IsGamepad()
	local value = maid:Value(0)
	local v4 = nil
	local value2 = maid:Value((math.clamp(v2, 1, #v)))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function step(p2: number)
		v2 = (value2:Get() - 1 + p2) % #v + 1
		value2:Set(v2)
	end

	local function names()
		return v[value2:Get()] or {}
	end

	maid:Add(InputHandler.ListenTo("Emotes_Prev", function(p2: string, flag: boolean)
		if p2 ~= "Down" or flag then
			return
		end

		step(-1) -- equivalent call inferred; original call site unknown
	end))
	maid:Add(InputHandler.ListenTo("Emotes_Next", function(p2: string, flag: boolean)
		if p2 ~= "Down" or flag then
			return
		end

		step(1) -- equivalent call inferred; original call site unknown
	end))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function sectorOf(point: Vector2)
		return math.floor(((math.atan2(point.Y, point.X) + 1.5707963267948966) / 1.0471975511965976 + 0.5) % 6) + 1
	end

	local function pointerSlot()
		local v5 = v4

		if v5 == nil then
			return 0
		end

		local v6 = v5.AbsolutePosition + v5.AbsoluteSize / 2
		local v7 = UserInputService:GetMouseLocation() - GuiService:GetGuiInset() - v6

		if v7.Magnitude < v5.AbsoluteSize.X * 0.15 then
			return 0
		end

		return sectorOf(v7)
	end

	local position = createVector(0, 0, 0)

	if isGamepad then
		maid:Connect(UserInputService.InputChanged, function(p2)
			if p2.KeyCode == thumbstick2 then
				position = p2.Position
			end
		end)
	end

	local function stickSlot()
		if position.Magnitude < 0.3 then
			return 1
		end

		return sectorOf(Vector2.new(position.X, -position.Y))
	end

	if not v3 then
		if isGamepad then
			pointerSlot = stickSlot
		end

		maid:Connect(RunService.PreRender, function()
			local v5 = pointerSlot()

			if not value:Compare(v5) then
				value:Set(v5)
			end
		end)
	end

	maid:Create("Frame")({
		Parent = parent,
		Name = "EmoteWheel",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = maid:Animation(UDim2.fromScale(0.4, 0.4), springInfo, {
			From = uDim
		}),
		Visible = Emotes.OnPodium(localPlayer) and true or maid:InstancePropertySync(HUD, "Value"),
		OnClean = function(object)
			return {
				Size = object:Animation(uDim, info)
			}
		end,
		BackgroundTransparency = 1,
		maid:Create("UIAspectRatioConstraint")({}),
		function(p2)
			v4 = p2
		end,
		maid:Create("ImageLabel")({
			Name = "Disc",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = BunchaIcons.EmoteDisc,
			ImageColor3 = Color3.new(),
			ImageTransparency = 0.65
		}),
		Browser(maid, value2, v3, step),
		maid:State(function(callback2, object)
			local v5 = v[callback2(value2)] or {}
			return object:Create("Frame")({
				Name = "Slots",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				CleanDelay = 0.2,
				object:Iterate(6, function(p2: number, _, p3)
					return Slot(p3, p2, 6, value, v3, 0.18, v5[p2], callback)
				end)
			})
		end)
	})
	return function()
		maid:Destroy()
	end, function()
		return (v[value2:Get()] or {})[value:Get()]
	end
end