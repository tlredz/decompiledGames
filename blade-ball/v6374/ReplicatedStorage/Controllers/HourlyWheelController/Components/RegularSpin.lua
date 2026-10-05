local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local _ = ReplicatedStorage2.Packages
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Shared.HourlyWheelData)
local v5 = require3(script.Parent.Parent)
local v6 = nil
local v7 = nil
local wrappedChildSingle = nil
local RegularSpin = {}

function UpdateSpins(p)
	local v8 = v7:Get((`{v4.ReplionPath}.Amount`))
	local container = p.Container
	local title = container:FindFirstChild("Title")
	local uIStroke = title:FindFirstChild("UIStroke")
	title.Text = `Spins (x{v8})`
	container.Image = v8 > 0 and "rbxassetid://132921642360881" or "rbxassetid://131200789715112"
	container.HoverImage = v8 > 0 and "rbxassetid://81571658157526" or "rbxassetid://96399532716703"
	uIStroke.Color = v8 > 0 and Color3.fromRGB(82, 63, 4) or Color3.fromRGB(89, 89, 89)
end

function RegularSpin:Hook(p)
	v6 = v3:RemoteEvent("HourlyWheel/ProcessRoll")
	v7 = v.Client:WaitReplion("Data")
	wrappedChildSingle = v5:GetWrappedChildSingle("Spinner")
	p.Container.Activated:Connect(function()
		if not wrappedChildSingle then
			wrappedChildSingle = v5:GetWrappedChildSingle("Spinner")
		end

		if wrappedChildSingle.IsSpinning then
			return
		end

		v6:FireServer()
	end)
	UpdateSpins(p)
	v7:OnChange(`{v4.ReplionPath}.Amount`, function()
		UpdateSpins(p)

		if v7:Get((`{v4.ReplionPath}.Amount`)) > 0 then
			v2:IsOpen("HourlyWheel")
		end
	end)
end

function RegularSpin.Init(_, container)
	local v8 = {
		Container = container
	}
	RegularSpin:Hook(v8)
	return v8
end

return RegularSpin