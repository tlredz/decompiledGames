local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Replion = require(ReplicatedStorage.Packages.Replion)
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("SinglePassBountyDisplay", function(instance)
	local profile = instance:WaitForChild("Profile", 100000)
	local profilePicture = profile.ProfilePicture
	local content = profile.Content

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resetBountyVisual()
		content.Username.Text = "NO TARGET"
		profilePicture.Headshot.ImageColor3 = Color3.fromRGB(0, 0, 0)
		profilePicture.Headshot.Image = "rbxassetid://18444806692"
	end

	local function onBountyUserIdChanged(expect: number)
		if expect == -100 then
			resetBountyVisual() -- equivalent call inferred; original call site unknown
		else
			local playerByUserId = Players:GetPlayerByUserId(expect)

			if playerByUserId then
				content.Username.Text = `{playerByUserId.DisplayName} (@{playerByUserId.Name})`
				profilePicture.Headshot.ImageColor3 = Color3.fromRGB(255, 255, 255)
				profilePicture.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={expect}&w=150&h=150`
				instance.Enabled = true
			else
				print("(bounty client) Failed to find player with userId:", expect)
				resetBountyVisual() -- equivalent call inferred; original call site unknown
			end
		end
	end

	task.spawn(function()
		local v = Replion.Client:WaitReplion("Data")
		v:OnChange("SinglePass.Bounty", onBountyUserIdChanged)
		onBountyUserIdChanged(v:GetExpect("SinglePass.Bounty"))
	end)
	return resetBountyVisual
end)