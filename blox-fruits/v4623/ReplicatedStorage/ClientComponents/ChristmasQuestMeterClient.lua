local Component = require(game.ReplicatedStorage.Modules.Component)
local Trove = require(game.ReplicatedStorage.Modules:WaitForChild("Util"):WaitForChild("Trove"))
local Flags = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Flags"))
local v = Component.new({
	Tag = "ChristmasQuestMeter"
})
local v2 = {
	Incomplete = Color3.fromRGB(100, 100, 100),
	Complete = {
		Color3.fromRGB(13, 105, 172),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(168, 146, 74),
		Color3.fromRGB(196, 40, 28),
		Color3.fromRGB(123, 47, 123)
	}
}

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	if not Flags.XMAS_RAID_ENABLED then
		return
	end

	local serverChristmasMagicMeter = workspace:WaitForChild("ServerChristmasMagicMeter")
	local instance = p.Instance
	local isPersonal = instance:GetAttribute("IsPersonal")
	local v3 = 0

	local function reflectMeterColor()
		local progress = serverChristmasMagicMeter:GetAttribute("Progress")
		local v4 = math.min(#v2.Complete, progress + 1)

		if isPersonal then
			for i = 1, 3 do
				local bar = instance.Bars[tostring(i)]
				local incomplete = v2.Incomplete

				if v3 == 3 then
					incomplete = v2.Complete[progress] or v2.Complete[v4]
				elseif i <= v3 then
					incomplete = Color3.fromRGB(255, 255, 255)
				end

				bar.Meter.Color = incomplete
				bar.Lamp.Color = incomplete
			end
		else
			for i = 1, 5 do
				local bar = instance.Bars[tostring(i)]
				local incomplete = v2.Incomplete

				if i <= progress then
					incomplete = v2.Complete[i]
				end

				bar.Meter.Color = incomplete
				bar.Lamp.Color = incomplete
			end
		end
	end

	reflectMeterColor()
	p.trove:Add(instance:GetAttributeChangedSignal("Progress"):Connect(reflectMeterColor))

	if isPersonal then
		p.trove:Add(instance:WaitForChild("UpdateProgress").OnClientEvent:Connect(function(p2)
			v3 = p2
			reflectMeterColor()
		end))
		p.trove:Add(serverChristmasMagicMeter:GetAttributeChangedSignal("Progress"):Connect(reflectMeterColor))
		v3 = instance:WaitForChild("GetMyProgress"):InvokeServer()
		reflectMeterColor()
	end
end

function v:Stop()
	self.trove:Destroy()
	self.trove = nil
end

return v