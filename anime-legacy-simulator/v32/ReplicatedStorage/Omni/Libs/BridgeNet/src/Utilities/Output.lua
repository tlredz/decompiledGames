local RunService = game:GetService("RunService")
local Output = {
	silent = function(p: string)
		if RunService:IsStudio() then
			print((`[BridgeNet2] {p}`))
		end
	end,
	log = function(p: string)
		print((`[BridgeNet2] {p}`))
	end
}

function Output.logAssert(flag: boolean, p: string)
	if not flag then
		Output.log(p)
	end
end

function Output.warn(p: string)
	warn((`[BridgeNet2] {p}`))
end

function Output.warnAssert(flag: boolean, p: string)
	if not flag then
		Output.warn(p)
	end
end

function Output.typecheck(p: string, p2: string, p3: string, p4)
	local typeName = typeof(p4)

	if typeName ~= p then
		error(`[BridgeNet2] {p2} parameter {p3} takes {p}, got {typeName}`, 0)
	end
end

function Output.fatal(p: string)
	error(`[BridgeNet2] {p}`, 0)
end

function Output.fatalAssert(flag: boolean, p: string)
	if not flag then
		error(`[BridgeNet2] {p}`, 0)
	end
end

return Output