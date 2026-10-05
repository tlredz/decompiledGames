local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local YearCounterView = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent.Modules["20YearsEvent"].YearCounterView)
local UILabs = require(ReplicatedStorage.Packages["UI-Labs"])
local Vide = require(ReplicatedStorage.Packages.Vide)
local controls2 = {
	fromYear = UILabs.Slider(2009, 2006, 2026, 1),
	toYear = UILabs.Slider(2010, 2006, 2026, 1),
	peakAfterSeconds = UILabs.Slider(4.9, 0, 8, 0.1),
	loop = UILabs.Boolean(true)
}
return UILabs.CreateVideStory({
	name = "20 Years / Rolling Year Transition",
	vide = Vide,
	controls = controls2
}, function(p)
	return Vide.create("Frame")({
		Name = "YearCounterPreview",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(210, 220, 235),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Vide.action(function(p2)
			local v2 = YearCounterView.mount(p2)
			local lastTime = os.clock()
			local v3 = false
			local v4 = false
			local v5 = 0
			local v6 = true
			local controls = 2009
			local v7 = 2010

			-- equivalent calls inferred from this helper; original call sites unknown
			local function play()
				lastTime = os.clock()
				v3 = false
				v4 = false
				v2.reset()
				v2.setStatus(controls, 60, "Explore the map and collect win orbs!")
			end

			Vide.effect(function()
				controls = p.controls.fromYear()
				v7 = p.controls.toYear()
				v5 = p.controls.peakAfterSeconds()
				v6 = p.controls.loop()
				play() -- equivalent call inferred; original call site unknown
			end)
			local renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local v8 = os.clock() - lastTime

				if v8 >= 2 and not v4 then
					v4 = true
					v2.show(controls, v7)
				end

				if not v3 and v5 + 2 <= v8 then
					v3 = true
					v2.setStatus(v7, 60, "Explore the new map and collect wins!")
					v2.roll()
				end

				v2.update()

				if v6 and v5 + 6 <= v8 then
					play() -- equivalent call inferred; original call site unknown
				end
			end)
			Vide.cleanup(function()
				renderSteppedConnection:Disconnect()
				v2.destroy()
			end)
		end)
	})
end)