local SwitchingHedgeClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)

function SetHedgePieceVisible(instance, flag: boolean)
	for _, part in pairs(instance:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Transparency = flag and 0 or 1
		part.CanCollide = flag
		part.CanQuery = flag
		part.CanTouch = flag
	end
end

function SwitchHedges(instance, items, p: number, flag: boolean)
	if instance:GetAttribute("LastSwitch") then
		return
	end

	if not flag then
		instance:GetAttribute("LastSwitch", workspace:GetServerTimeNow())
	end

	print("switch to hedge", p)

	for k, item in pairs(items) do
		local v = k == p
		SetHedgePieceVisible(item, not v)
	end
end

function TouchedAllTriggers(items)
	local v = time()

	for _, item in pairs(items) do
		if v - item.LastTrigger > 20 then
			return false
		end
	end

	return true
end

function SwitchingHedgeAdded(instance)
	local children = {}
	local v = {}

	for _, child in pairs(instance:GetChildren()) do
		if string.sub(child.Name, 1, 7) == "Trigger" then
			v[tonumber((string.sub(child.Name, 8)))] = {
				Part = child,
				LastTrigger = 0
			}
		elseif string.sub(child.Name, 1, 8) == "Entrance" then
			children[tonumber((string.sub(child.Name, 9)))] = child
		end
	end

	SwitchHedges(instance, children, 1, true)

	for k, v2 in pairs(v) do
		local v3 = k
		v2.Part.Touched:Connect(function(otherPart)
			if otherPart.Parent == localPlayer.Character then
				v[v3].LastTrigger = time()

				if v3 == #v and TouchedAllTriggers(v) then
					SwitchHedges(instance, children, 2)
				end
			end
		end)
	end
end

function SwitchingHedgeClient.Init()
	Client.Utility.ForAllTagged("SwitchingMazeHedge", SwitchingHedgeAdded)
end

return SwitchingHedgeClient