local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local Net = require(packages:WaitForChild("Net"))
local legacyControllers = ReplicatedStorage.client.legacyControllers
require(legacyControllers:WaitForChild("NotificationController"))
local PlayerController = require(legacyControllers:WaitForChild("PlayerController"))
local legacyLocalPlayerData = require(ReplicatedStorage.client:WaitForChild("modules"):WaitForChild("legacyLocalPlayerData"))
local anno_localthought = ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_localthought")
local iris = script:WaitForChild("iris")
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "ElevatorPrompt"
})
local remoteFunction = Net:RemoteFunction("ElevatorPrompt/RequestTeleport")
local v2 = false

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	p.trove:Add(p.Instance.Triggered:Connect(function()
		if v2 or localPlayer:GetAttribute("ElevatorActive") then
			return
		end

		if p.Instance:GetAttribute("RequiresToken") then
			local fetched = legacyLocalPlayerData.fetch()

			if not fetched:FindFirstChild("Stats") or not fetched.Stats:FindFirstChild("minetokens") or fetched.Stats.minetokens.Value <= 0 then
				anno_localthought:Fire("Seems like it needs a <font color='#ffb265'><b>Token</b></font> of some kind.")
				return
			end
		end

		v2 = true
		PlayerController:ToggleControls(false)
		p.Instance.Enabled = false
		local clone = iris:Clone()
		clone.UIStroke.Transparency = 1
		clone.Visible = true
		clone.Parent = localPlayer.PlayerGui:WaitForChild("over")
		clone.leversound:Play()
		TweenService:Create(clone.UIStroke, TweenInfo.new(2, Enum.EasingStyle.Linear), {
			Transparency = 0
		}):Play()
		task.wait(1)
		clone.sound:Play()
		task.wait(1)
		pcall(function()
			remoteFunction:InvokeServer(p.Instance)
		end)
		PlayerController:ToggleControls(true)
		TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(3, 0, 3, 0)
		}):Play()
		task.wait(3)
		clone:Destroy()
		v2 = false
		p.Instance.Enabled = true
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v