return function(image, list, p, callback)
	local v = p or TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	image:IsA("ImageLabel")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateTexture(p2)
		local decal

		if image:IsA("ImageLabel") then
			decal = image
		else
			decal = image:FindFirstChildOfClass("Decal")
		end

		local v2 = decal and list[p2]

		if v2 then
			if image:IsA("ImageLabel") then
				decal.Image = v2
			else
				decal.Texture = v2
			end
		end
	end

	local v2 = #list
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 1
	local v3 = game.TweenService:Create(numberValue, v, {
		Value = v2
	})
	v3:Play()
	local changedConnection = numberValue.Changed:Connect(function(p2)
		updateTexture(math.floor(p2)) -- equivalent call inferred; original call site unknown
	end)
	local completedConnection = nil
	completedConnection = v3.Completed:Connect(function()
		numberValue:Destroy()

		if callback then
			task.spawn(callback)
		end

		changedConnection:Disconnect()
		completedConnection:Disconnect()
	end)
	return v3
end