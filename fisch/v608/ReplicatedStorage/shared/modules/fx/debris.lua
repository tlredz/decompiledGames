local Debris = {}
game:GetService("RunService")
game:GetService("ReplicatedStorage")

local function Init()
	if not shared.Debris2 then
		shared.Debris2 = {}
	end

	if not shared.Debris2.Storage then
		shared.Debris2.Storage = {}
		shared.Debris2.HeartbeatCoroutine = task.spawn(function()
			while task.wait(0.03333333333333333) do
				local v = {}

				for _, v2 in pairs(shared.Debris2.Storage) do
					if v2.Timer > 0 then
						v2.Timer -= 1
					elseif v2.Timer <= 0 or not v2.Object then
						table.insert(v, v2.Object)
					end
				end

				for _, v2 in pairs(v) do
					if not shared.Debris2.Storage[v2] then
						continue
					end

					shared.Debris2.Storage[v2].Object:Destroy()
					shared.Debris2.Storage[v2] = nil
				end
			end
		end)
	end
end

function Debris.AddItem(_, object, p2: number)
	local v = {
		Object = object,
		Timer = p2 * 60
	}

	if not shared.Debris2.Storage[object] then
		shared.Debris2.Storage[object] = v
	end
end

Init()
return Debris