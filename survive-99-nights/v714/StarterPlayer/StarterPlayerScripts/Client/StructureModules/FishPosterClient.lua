game:GetService("TweenService")
local FishPosterClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = nil
local v2 = nil

function NewFishPoster(p)
	v = p

	if v2 then
		local fishHolder = v.Sign.SurfaceGui.FishHolder
		local count = 0

		for childName, v3 in pairs(v2) do
			if not (fishHolder:FindFirstChild(childName) and v3) then
				continue
			end

			count += 1
			local findFirstChild = fishHolder:FindFirstChild(childName)
			findFirstChild.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end

		fishHolder.Parent.TextLabel.Text = "Fish Discovered " .. count .. "/" .. 11
	end
end

Client.Events.InitializeFishPoster:Connect(function(items)
	repeat
		wait(10)
	until v

	local fishHolder = v:WaitForChild("Sign").SurfaceGui.FishHolder
	local count = 0

	for childName, item in pairs(items) do
		print(childName, item)

		if not (fishHolder:FindFirstChild(childName) and item) then
			continue
		end

		count += 1
		local findFirstChild = fishHolder:FindFirstChild(childName)
		findFirstChild.ImageColor3 = Color3.fromRGB(255, 255, 255)
	end

	fishHolder.Parent.TextLabel.Text = "Fish Discovered " .. count .. "/" .. 11
	v2 = items
end)
Client.Events.UnlockFish:Connect(function(childName)
	print("got", childName)

	if not v then
		return
	end

	local fishHolder = v.Sign.SurfaceGui.FishHolder
	local child = fishHolder:FindFirstChild(childName)
	print(child:GetFullName())

	if child then
		child.ImageColor3 = Color3.fromRGB(255, 255, 255)
	end

	local count = 0

	for _, image in pairs(fishHolder:GetChildren()) do
		if image:IsA("ImageLabel") and image.ImageColor3.R > 0.01 then
			count += 1
		end
	end

	fishHolder.Parent.TextLabel.Text = "Fish Discovered " .. count .. "/" .. 11
end)

local function animateFlipbook(imageLabel, value, position)
	local v3 = value or 12
	local v4 = 0
	local imageRectSize = imageLabel.ImageRectSize

	if imageRectSize == Vector2.new(0, 0) then
		imageRectSize = Vector2.new(1024, 1024)
	end

	imageLabel.ImageRectSize = imageRectSize / 4
	imageLabel.ImageRectOffset = Vector2.new(3 * imageRectSize.X / 4, 3 * imageRectSize.Y / 4)
	local v5 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function startAnimating()
		task.spawn(function()
			while true do
				if not v5 then
					v4 = 15
				end

				local v6 = math.floor(v4 / 4)
				local v7 = v4 % 4
				imageLabel.ImageRectOffset = Vector2.new(v7 * imageRectSize.X / 4, v6 * imageRectSize.Y / 4)
				v4 = (v4 + 1) % 16

				if not v5 then
					break
				end

				task.wait(1 / v3)
			end
		end)
	end

	task.spawn(function()
		while true do
			task.wait(1)
			local magnitude = (workspace.CurrentCamera.CFrame.Position - position).Magnitude

			if magnitude > 100 and v5 then
				v5 = false
			elseif magnitude < 100 and not v5 then
				v5 = true
				startAnimating() -- equivalent call inferred; original call site unknown
			end
		end
	end)
end

function NewHotspot(instance)
	if instance:IsDescendantOf(workspace) then
		task.spawn(function()
			instance.SurfaceGui.ImageLabel.ImageTransparency = 0.45
			animateFlipbook(instance.SurfaceGui.ImageLabel, 10, instance:GetPivot().Position)
		end)
	end
end

function FishPosterClient.Init()
	Client.Utility.ForAllTagged("FishPoster", NewFishPoster)
	Client.Utility.ForAllTagged("FishHotspot", NewHotspot)
end

return FishPosterClient