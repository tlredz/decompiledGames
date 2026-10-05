local commF_ = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local iceCastle = workspace:WaitForChild("Map"):WaitForChild("IceCastle", 10)

if not iceCastle then
	return
end

local detect = iceCastle:WaitForChild("Hall"):WaitForChild("LibraryDoor"):WaitForChild("Keyhole"):WaitForChild("Detect")

-- equivalent calls inferred from this helper; original call sites unknown
local function checkPhoeyu()
	if not commF_:InvokeServer("OpenLibrary") then
		return
	end

	detect.Parent.Parent.PhoeyuDoor:Destroy()
	detect.Parent:Destroy()
	return true
end

local v = false

for _ = 1, 15 do
	-- equivalent call inferred; original call site unknown
	if checkPhoeyu() then
		v = true
		break
	else
		wait(1)
	end
end

if not v then
	local flag = false
	detect.Touched:Connect(function(otherPart)
		if flag then
			return
		end

		if otherPart and otherPart:IsDescendantOf(game.Players.LocalPlayer.Character) then
			flag = true

			-- equivalent call inferred; original call site unknown
			if not checkPhoeyu() then
				flag = false
			end
		end
	end)
end

local detection = iceCastle:WaitForChild("RengokuChest"):WaitForChild("Detection")

-- equivalent calls inferred from this helper; original call sites unknown
local function checkRengoku()
	if not commF_:InvokeServer("OpenRengoku") then
		return
	end

	detection.Parent:Destroy()
	return true
end

local v2 = false

for _ = 1, 15 do
	-- equivalent call inferred; original call site unknown
	if checkRengoku() then
		v2 = true
		break
	else
		wait(1)
	end
end

if not v2 then
	local flag = false
	detection.Touched:Connect(function(otherPart)
		if flag then
			return
		end

		if otherPart and otherPart:IsDescendantOf(game.Players.LocalPlayer.Character) then
			flag = true

			-- equivalent call inferred; original call site unknown
			if not checkRengoku() then
				flag = false
			end
		end
	end)
end