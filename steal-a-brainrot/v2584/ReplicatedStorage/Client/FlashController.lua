local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EmitModule = require(ReplicatedStorage.Packages.EmitModule)
local Net = require(ReplicatedStorage.Packages.Net)
local Janitor = require(ReplicatedStorage.UserGenerated.Lang.Janitor)
local flashTeleport = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("Flash Teleport")
local lightningdissapear = flashTeleport:WaitForChild("lightningdissapear")
local lightningtrail = flashTeleport:WaitForChild("lightningtrail")
local lightningappear = flashTeleport:WaitForChild("lightningappear")
Net:RemoteEvent("Tools/Flash/Effects").OnClientEvent:Connect(function(player, cframe: CFrame, cframe2: CFrame)
	local character = player.Character

	if not (character and character.PrimaryPart and character:FindFirstChildWhichIsA("Humanoid")) then
		return
	end

	local maid = Janitor.new()
	local v = maid:Add(lightningdissapear:Clone())
	local v2 = maid:Add(lightningtrail:Clone())
	local v3 = maid:Add(lightningappear:Clone())
	v:PivotTo(cframe)
	v2:PivotTo(CFrame.lookAt(cframe2.Position, cframe.Position) * CFrame.fromOrientation(-1.5707963267948966, 0, 0))
	v2.Size = Vector3.new(v2.Size.X, (cframe.Position - cframe2.Position).Magnitude, v2.Size.Z)
	v3:PivotTo(cframe2)
	v.Parent = workspace
	v2.Parent = workspace
	v3.Parent = workspace
	EmitModule.emit(v, v2, v3).Finished:andThenCall(function()
		maid:Destroy()
	end)
end)