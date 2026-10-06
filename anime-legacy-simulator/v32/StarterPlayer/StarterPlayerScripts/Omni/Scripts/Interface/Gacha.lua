local module = require("@game/ReplicatedStorage/Omni")
local v = nil
local modulesByName = {}
local Gacha = {}

function Gacha.Start(p: string)
	if v and v ~= p then
		Gacha.Stop()
	end

	local v2 = module.Shared.Gacha.List[p]

	if not v2 then
		return
	end

	local v3 = modulesByName[v2.Interface]

	if not v3 then
		return
	end

	v = p
	v3.Start(p)
end

function Gacha.Resume(p: string)
	local v2 = module.Shared.Gacha.List[p]
	local v3 = v2 and modulesByName[v2.Interface]

	if not (v3 and v3.Resume) then
		module.AutoRoll.SaveGacha(nil)
		return
	end

	if v and v ~= p then
		Gacha.Stop()
	end

	v = p
	v3.Resume(p)
end

function Gacha.Stop()
	if not v then
		return
	end

	local v2 = module.Shared.Gacha.List[v]
	local v3 = v2 and modulesByName[v2.Interface]

	if v3 then
		v3.Stop()
	end

	v = nil
end

function Gacha.Rolled(p: string, p2, p3: number?)
	local v2 = module.Shared.Gacha.List[p]

	if not v2 then
		return
	end

	local v3 = modulesByName[v2.Interface]

	if not v3 then
		return
	end

	if v3.Rolled then
		v3.Rolled(p, p2, p3)
	end
end

function Gacha.RollFailed(p: string, p2: number?, p3: string?)
	local v2 = module.Shared.Gacha.List[p]

	if not v2 then
		return
	end

	local v3 = modulesByName[v2.Interface]

	if not v3 then
		return
	end

	if v3.RollFailed then
		v3.RollFailed(p, p2, p3)
	end
end

local v2 = nil

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module2 = require(moduleScript)
	modulesByName[name] = module2
end

module.Button:Create(module.Interface.Frames.Gacha.Currency.More, "Small"):BindFunction("Commerce", function()
	if v and module.Shared.Gacha.List[v] then
		v2 = v
		module.Signal:FireSelf("Interface", "GemProducts", "Open", "Gacha", v, "Gacha")
	end
end)
module.Frame:OnFrameOpened("Gacha", function()
	local v3 = v2
	v2 = nil

	if v3 and not v then
		Gacha.Start(v3)
	end
end)
return Gacha