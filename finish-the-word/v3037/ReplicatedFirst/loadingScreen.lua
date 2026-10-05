local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
ReplicatedFirst:RemoveDefaultLoadingScreen()
local machine = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Core"):WaitForChild("machine"))
local req = machine.req(ReplicatedStorage, "Services", "Core", "romodel")
local req2 = machine.req(ReplicatedStorage, "Data", "Core", "viewImports", "basic")
local req3 = machine.req(ReplicatedStorage, "Data", "Core", "viewImports", "popups", "rankedBackdrop")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local wrapped = req.wrap("UIScale", req2.Element)
local model = req.model(req2.Corner)

function model.init(p)
	return {
		Name = p.Name,
		Size = UDim2.new(1, 0, 1, 0),
		LayoutOrder = p.LayoutOrder,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		CornerRadius = UDim.new(1, 0),
		ZIndex = 20
	}, {
		Scale = req.make(wrapped, {
			Scale = 1
		})
	}
end

local model2 = req.model(req2.EmptyList)

function model2.init()
	return {
		Name = "Dots",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.1, 0, 0.055, 0),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0.14, 0)
	}, {
		["1"] = req.make(model, {
			Name = "1",
			LayoutOrder = 1
		}),
		["2"] = req.make(model, {
			Name = "2",
			LayoutOrder = 2
		}),
		["3"] = req.make(model, {
			Name = "3",
			LayoutOrder = 3
		})
	}
end

function model2:spawn()
	local v = { self["1"], self["2"], self["3"] }
	local lastTime = os.clock()
	self.WaveCon = RunService.Heartbeat:Connect(function()
		local v2 = os.clock() - lastTime

		for i, v3 in ipairs(v) do
			local v4 = (math.sin(v2 * 6 - (i - 1) * 1.35) + 1) * 0.5
			v3.Scale.Scale = v4 * 1.1 + 1
		end
	end)
end

function model2.despawn(p)
	p.WaveCon:Disconnect()
end

local model3 = req.model("ScreenGui", req2.Ui)

function model3.init()
	local props = req3.props()
	return {
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 10000,
		Name = "ReplicatedFirstLoadingScreen",
		Location = "Center",
		AspectRatio = 1.777,
		Scale = 1,
		Background = props.Background,
		Background2 = props.Background2,
		Content = {
			Dots = req.make(model2)
		}
	}
end

req.mount(req.make(model3), playerGui)