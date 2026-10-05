local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local parent = script.Parent
local flag = false
return {
	Start = function()
		assert(RunService:IsServer(), "ConcertTreadmill may only be started on the server.")

		if flag then
			return
		end

		flag = true
		local concertTreadmillNoChangeNamePls = Workspace:FindFirstChild("ConcertTreadmillNoChangeNamePls")

		if not concertTreadmillNoChangeNamePls then
			warn("[ConcertTreadmill] Could not find \"ConcertTreadmillNoChangeNamePls\" in Workspace.")
			return
		end

		local function Update()
			local concertActive = parent:GetAttribute("ConcertActive") == true
			local v = concertTreadmillNoChangeNamePls
			local parent2

			if concertActive then
				parent2 = Workspace
			end

			v.Parent = parent2
		end

		parent:GetAttributeChangedSignal("ConcertActive"):Connect(Update)
		local parent3

		if parent:GetAttribute("ConcertActive") == true then
			parent3 = Workspace
		end

		concertTreadmillNoChangeNamePls.Parent = parent3
	end
}