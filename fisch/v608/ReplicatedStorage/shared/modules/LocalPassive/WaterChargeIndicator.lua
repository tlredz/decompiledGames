local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local chargeMeter = ReplicatedStorage:WaitForChild("resources"):WaitForChild("ui"):WaitForChild("WrathOfOlympus"):WaitForChild("Zeus"):WaitForChild("ChargeMeter")
local color = Color3.fromRGB(255, 255, 100)
local color2 = Color3.fromRGB(80, 80, 80)
local WaterChargeIndicator = {
	MorphSpear = true,
	Morph = function(p, _, p2)
		local waterBody = p.config.WaterBody
		task.spawn(function()
			local reel_bar = p2.reel_bar

			if not reel_bar then
				return
			end

			local frame = Instance.new("Frame")
			frame.Name = "WaterChargeIndicator"
			frame.Size = UDim2.fromScale(0.1, 0.6)
			frame.Position = UDim2.fromScale(0, -2.35)
			frame.AnchorPoint = Vector2.new(0, 0)
			frame.BackgroundTransparency = 1
			frame.ZIndex = 10
			frame.Parent = reel_bar
			local uIScale = Instance.new("UIScale")
			uIScale.Scale = 3.5
			uIScale.Parent = frame
			local uIListLayout = Instance.new("UIListLayout")
			uIListLayout.FillDirection = Enum.FillDirection.Horizontal
			uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uIListLayout.Padding = UDim.new(0, 2)
			uIListLayout.Parent = frame
			local clone = chargeMeter:Clone()
			local main = clone:FindFirstChild("Main")

			if not main then
				return
			end

			local v = nil

			for _, uIListLayout2 in main:GetChildren() do
				if uIListLayout2:IsA("UIListLayout") then
					continue
				end

				v = uIListLayout2
				break
			end

			clone:Destroy()

			if not v then
				return
			end

			local clones = {}

			for i = 1, 5 do
				local clone2 = v:Clone()
				clone2.LayoutOrder = i
				clone2.Size = UDim2.fromScale(0.1, 1)
				clone2.Parent = frame
				table.insert(clones, clone2)
			end

			v:Destroy()
			p.reelTrove:Add(RunService.RenderStepped:Connect(function()
				if not p2.active then
					return
				end

				local v3 = math.floor((not (waterBody and waterBody.Parent) and 0 or waterBody:GetAttribute("Charge") or 0) * 5)

				for k, image in clones do
					if not image:IsA("ImageLabel") then
						continue
					end

					local imageColor

					if k <= v3 then
						imageColor = color
					else
						imageColor = color2
					end

					image.ImageColor3 = imageColor
				end
			end))
			p.reelTrove:Add(frame)
		end)
	end
}
setmetatable(WaterChargeIndicator, module)
return WaterChargeIndicator