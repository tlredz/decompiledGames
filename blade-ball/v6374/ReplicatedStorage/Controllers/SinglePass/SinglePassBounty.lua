local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local v3 = nil
local bounty = Players.LocalPlayer.PlayerGui:WaitForChild("SinglePass").MainFrame.Main.Pages.Bounty
local v4 = v2.new()
local SinglePassBounty = {
	Start = function(_)
		v3 = v.Client:WaitReplion("Data")
		ReplicatedStorage2.Remotes.RoundEnded.OnClientEvent:Connect(function()
			task.wait(2)
			v4:Clean()
		end)
		v3:OnChange("SinglePass.Bounty", UpdateBounty)
		UpdateBounty(v3:GetExpect("SinglePass.Bounty"))
	end
}

function UpdateBounty(p: number)
	bountyVisual(p)
	drawBountyOverhead(p)
end

function resetBountyVisual()
	bounty.Bounty.Username.Text = "NO TARGET"
	bounty.Bounty.ProfilePicture.Headshot.ImageColor3 = Color3.fromRGB(0, 0, 0)
	bounty.Bounty.ProfilePicture.Headshot.Image = "rbxassetid://18444806692"
end

function bountyVisual(p: number)
	if not v3:Get({ "SinglePass", "Interaction" }) then
		resetBountyVisual()
		return
	end

	if p == -100 then
		resetBountyVisual()
		return
	end

	local playerByUserId = Players:GetPlayerByUserId(p)

	if not playerByUserId then
		resetBountyVisual()
		return
	end

	bounty.Bounty.Username.Text = playerByUserId.DisplayName
	bounty.Bounty.ProfilePicture.Headshot.ImageColor3 = Color3.fromRGB(255, 255, 255)
	bounty.Bounty.ProfilePicture.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={p}&w=150&h=150`
end

function drawBountyOverhead(p: number)
	if p == -100 then
		v4:Clean()
		return
	end

	local playerByUserId = Players:GetPlayerByUserId(p)

	if not playerByUserId then
		v4:Clean()
		return
	end

	local character = playerByUserId.Character
	local head = character and character:FindFirstChild("Head")

	if not head then
		return
	end

	v4:Clean()
	local clone = script.BountyDisplay:Clone()
	clone.Parent = head
	v4:Add(clone)
end

return SinglePassBounty