local EasterEggsClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
Random.new()

function PlayCandyAnimation(value)
	local easterEggCount = Client.Interface.EasterEggCount
	local eggsBig = easterEggCount.EggsBig
	TweenService:Create(eggsBig, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Size = UDim2.new(1.7, 0, 1.7, 0)
	}):Play()
	task.spawn(function()
		wait(0.15)
		TweenService:Create(eggsBig, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Size = UDim2.new(1.3, 0, 1.3, 0)
		}):Play()
	end)
	task.spawn(function()
		wait(0.075)
		easterEggCount.Count.Text = localPlayer:GetAttribute("EasterCurrency") or 0
	end)

	for _ = 1, value or 1 do
		local clone = easterEggCount.SmallEggs:Clone()
		clone.Name = "CandyParticle"
		clone.Parent = easterEggCount
		clone.ZIndex = eggsBig.ZIndex + 1
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Visible = true
		local v = math.random() * 3.141592653589793 * 2
		local v2 = math.random(80, 150)
		local v3 = math.cos(v) * v2
		local v4 = math.sin(v) * v2 - 50
		local now = tick()
		local absoluteSize = easterEggCount.AbsoluteSize
		local renderSteppedConnection = nil
		local RunService = game:GetService("RunService")
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v10 = tick() - now

			if v10 >= 1.5 then
				renderSteppedConnection:Disconnect()
				clone:Destroy()
			else
				local v11 = v3 * v10
				local v12 = v4 * v10 + 300 * v10 * v10
				local v13 = eggsBig.Position.X.Scale + v11 / absoluteSize.X
				local v14 = 0.5 + v12 / absoluteSize.Y
				clone.Position = UDim2.new(v13, 0, v14, 0)

				if v10 > 1 then
					clone.ImageTransparency = (v10 - 1) / 0.5
				end

				clone.Rotation = v10 * 80
			end
		end)
	end
end

local thread = nil

function EasterEggsClient.Init()
	local easterEggCount = Client.Interface.EasterEggCount
	local easterCurrency = localPlayer:GetAttribute("EasterCurrency") or 0
	easterEggCount.Visible = false
	easterEggCount.Count.Text = easterCurrency

	-- equivalent calls inferred from this helper; original call sites unknown
	local function scheduleHide()
		if thread then
			task.cancel(thread)
		end

		thread = task.delay(25, function()
			easterEggCount.Visible = false
			thread = nil
		end)
	end

	localPlayer:GetAttributeChangedSignal("EasterCurrency"):Connect(function()
		local easterCurrency2 = localPlayer:GetAttribute("EasterCurrency") or 0
		local v = easterCurrency2 - easterCurrency

		if easterCurrency < easterCurrency2 then
			PlayCandyAnimation((math.clamp(v, 1, 3)))
		end

		if easterCurrency ~= easterCurrency2 or easterCurrency ~= 0 then
			easterEggCount.Visible = true
		end

		easterCurrency = easterCurrency2
		scheduleHide() -- equivalent call inferred; original call site unknown
	end)
end

return EasterEggsClient