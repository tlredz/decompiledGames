local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local MonsterParasite = require(ReplicatedStorage.Data.MonsterParasite)
local Pads = require(ReplicatedStorage.Client.WorldFX.Pads)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Trove = require(ReplicatedStorage.Packages.Trove)
return {
	Start = function()
		local function bindPad(maid, part, name: string)
			maid:Add(Pads.Track(part, {
				Entered = function()
					Tabs.Activate(name)
				end,
				Left = function()
					if Tabs.Active() == name then
						Tabs.Deactivate({
							instant = true
						})
					end
				end
			}))
		end

		for _, part in Workspace:WaitForChild("Stands"):WaitForChild("Pads"):GetChildren() do
			if part:IsA("BasePart") and part.Name ~= MonsterParasite.PadName then
				bindPad(Trove.new(), part, part.Name)
			end
		end
	end
}