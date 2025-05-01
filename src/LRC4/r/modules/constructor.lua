local r = script.Parent.Parent
local rigs = r.rigs

local constructor = {}

type rig_type = "R15"|"R6"

function constructor:construct_rig_via_load_description(rig_type:rig_type,hd:HumanoidDescription, par)
	local rig
	
	if rig_type == "R15" then
		rig = rigs.R15:Clone()
	elseif rig_type == "R6" then
		rig = rigs.R6:Clone()
	else
		error("Unexpected rig_type value")
		return nil
	end
	
	if not rig then error("rig null") end
	rig.Parent = game.ReplicatedStorage
	rig.Archivable = false
	task.wait(2)
	rig.Humanoid:ApplyDescription(hd, Enum.AssetTypeVerification.Default)
	
	return rig
end

return constructor