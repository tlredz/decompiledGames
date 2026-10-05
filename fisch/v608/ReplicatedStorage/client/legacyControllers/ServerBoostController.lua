local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Timer = require(packages:WaitForChild("Timer"))
local modules = ReplicatedStorage.shared.modules
local serverboosts = require(modules:WaitForChild("library"):WaitForChild("serverboosts"))
local playerGui = Players.LocalPlayer.PlayerGui

-- equivalent calls inferred from this helper; original call sites unknown
local function setInteractable(guiObject, interactable)
	if guiObject:IsA("GuiObject") then
		guiObject.Interactable = interactable
	end
end

return {
	Start = function(self)
		local v = Timer.new(1)
		v.Tick:Connect(function()
			local serverTimeNow = workspace:GetServerTimeNow()

			if serverTimeNow > 2534023007990 then
				serverTimeNow = os.time()
			end

			DateTime.fromUnixTimestamp(serverTimeNow)
			local hud = playerGui:FindFirstChild("hud")

			if not hud then
				return
			end

			local safezone = hud:FindFirstChild("safezone")

			if not safezone then
				return
			end

			local statuses = safezone:FindFirstChild("statuses")

			if not statuses then
				return
			end

			for childName, v2 in serverboosts.Activated do
				local v3 = serverboosts.List[v2[1]]
				local v4 = v2[3] or DateTime.fromUniversalTime(0)
				local v5 = v2[4]
				local v6

				if v4.UnixTimestamp <= serverTimeNow then
					v6 = serverTimeNow < v5.UnixTimestamp
				else
					v6 = false
				end

				local clone = statuses:FindFirstChild(childName)

				if not (not clone or clone.Name ~= "FriendBoostButton") then
					continue
				end

				if clone and v6 == false then
					clone:Destroy()
				else
					if not clone and v6 == true then
						clone = script:WaitForChild("template"):Clone()
						clone.Name = childName
						clone.Parent = statuses
						clone.LayoutOrder = childName
						local _ = (v2[2] - 1) * 100
						local info = clone:WaitForChild("info")
						info.Text = v3.Description
						local intensity = clone:WaitForChild("intensity")
						intensity.Text = v3.Name
						setInteractable(clone:WaitForChild("info"), false) -- equivalent call inferred; original call site unknown
						setInteractable(clone:WaitForChild("intensity"), false) -- equivalent call inferred; original call site unknown
						setInteractable(clone:WaitForChild("length"), false) -- equivalent call inferred; original call site unknown

						if typeof(v3.Icon) == "Instance" then
							local clone2 = v3.Icon:Clone()
							clone2.Parent = clone
							clone2.Name = "IconInstance"
							clone2.Visible = true
							setInteractable(clone2, false) -- equivalent call inferred; original call site unknown
						else
							local icon = clone:WaitForChild("icon")
							icon.Image = v3.Icon
							setInteractable(clone:WaitForChild("icon"), false) -- equivalent call inferred; original call site unknown
						end

						if typeof(v3.OutlineColor) == "Color3" then
							clone.stroke.Color = v3.OutlineColor
							clone.corner.ImageColor3 = v3.OutlineColor
						elseif typeof(v3.OutlineColor) == "ColorSequence" then
							clone.stroke.UIGradient.Color = v3.OutlineColor
							clone.corner.UIGradient.Color = v3.OutlineColor
						end
					end

					if v6 then
						local dateTime = DateTime.fromUnixTimestamp(v5.UnixTimestamp - serverTimeNow)
						local universalTime = dateTime:ToUniversalTime()
						local v7 = ""

						if dateTime.UnixTimestamp >= 86400 then
							v7 ..= string.format("%02d:", universalTime.Day or 0)
						end

						if dateTime.UnixTimestamp >= 3600 then
							v7 ..= string.format("%02d:", universalTime.Hour or 0)
						end

						if dateTime.UnixTimestamp >= 60 then
							v7 ..= string.format("%02d:", universalTime.Minute or 0)
						end

						local text = v7 .. string.format("%02d", universalTime.Second)
						clone.length.Text = text
					end
				end
			end
		end)
		v:Start()
	end
}