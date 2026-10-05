local createVector = vector.create
local BunnyTrapClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local bunnyTrapBillboard = nil
local v = {}
local v2 = {}
local enabled = false
local v4 = false
local count = 0

function MakeRangeCylinder(parent)
	local part = Instance.new("Part")
	part.Name = "BurrowRangeVisual"
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Color = Color3.fromRGB(0, 255, 127)
	part.Transparency = 1
	part.Size = createVector(0.4, 36, 36)
	part.CFrame = CFrame.new(parent:GetPivot().Position) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Parent = parent
	return part
end

function UpdateActive()
	local v5 = (localPlayer:GetAttribute("DraggingBunnyTrap") or v4) and true or false

	if v5 == enabled then
		return
	end

	enabled = v5
	count += 1

	if enabled then
		local v6 = count
		task.spawn(function()
			while enabled and v6 == count do
				for k, v7 in pairs(v2) do
					v7.CFrame = CFrame.new(k:GetPivot().Position) * CFrame.Angles(0, 0, 1.5707963267948966)
				end

				task.wait(0.2)
			end
		end)
	end

	task.spawn(function()
		local count2 = 0

		for k, v6 in pairs(v) do
			v6.Enabled = enabled
			local v7 = v2[k]

			if v7 then
				v7.Transparency = enabled and 0.55 or 1
			end

			count2 += 1

			if count2 % 50 == 0 then
				task.wait()
			end
		end
	end)
end

function BunnyTrapClient.Init()
	task.spawn(function()
		bunnyTrapBillboard = game.ReplicatedStorage.Assets.Billboards:WaitForChild("BunnyTrapBillboard", 60)

		if not bunnyTrapBillboard then
			return
		end

		local buildingHighlight = workspace:WaitForChild("Highlights"):WaitForChild("BuildingHighlight")
		localPlayer:GetAttributeChangedSignal("DraggingBunnyTrap"):Connect(UpdateActive)
		buildingHighlight:GetPropertyChangedSignal("Adornee"):Connect(function()
			local adornee = buildingHighlight.Adornee
			v4 = adornee ~= nil and adornee.Name == "Bunny Trap"
			UpdateActive()
		end)
		Client.Utility.ForAllTagged("BunnyBurrow", function(p)
			if p.Parent ~= workspace.Map.Landmarks or v[p] then
				return
			end

			local clone = bunnyTrapBillboard:Clone()
			clone.Adornee = p
			clone.Enabled = enabled
			clone.Parent = p
			v[p] = clone
			local v5 = MakeRangeCylinder(p)
			v5.Transparency = enabled and 0.55 or 1
			v2[p] = v5
		end, function(p)
			if v[p] then
				v[p]:Destroy()
				v[p] = nil
			end

			if v2[p] then
				v2[p]:Destroy()
				v2[p] = nil
			end
		end)
	end)
end

return BunnyTrapClient