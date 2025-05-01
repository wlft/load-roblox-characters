local enums = { -- lazy
	BodyPart = {
		[0] = Enum.BodyPart.Head;
		[33554432] = Enum.BodyPart.LeftArm;
		[50331648] = Enum.BodyPart.RightArm;
		[16777216] = Enum.BodyPart.Torso;
		[67108864] = Enum.BodyPart.LeftLeg;
		[83886080] = Enum.BodyPart.RightLeg;
	};
	
	AccessoryType = {
		[0] = Enum.AccessoryType.Unknown;
		[33554432] = Enum.AccessoryType.Hair;
		[117440512] = Enum.AccessoryType.Back;
		[285212672] = Enum.AccessoryType.DressSkirt;
		[301989888] = Enum.AccessoryType.Eyebrow;
		[318767104] = Enum.AccessoryType.Eyelash;
		[50331648] = Enum.AccessoryType.Face;
		[100663296] = Enum.AccessoryType.Front;
		[16777216] = Enum.AccessoryType.Hat;
		[201326592] = Enum.AccessoryType.Jacket;
		[251658240] = Enum.AccessoryType.LeftShoe;
		[67108864] = Enum.AccessoryType.Neck;
		[184549376] = Enum.AccessoryType.Pants;
		[268435456] = Enum.AccessoryType.RightShoe;
		[167772160] = Enum.AccessoryType.Shirt;
		[234881024] = Enum.AccessoryType.Shorts;
		[83886080] = Enum.AccessoryType.Shoulder;
		[218103808] = Enum.AccessoryType.Sweater;
		[150994944] = Enum.AccessoryType.TShirt;
		[134217728] = Enum.AccessoryType.Waist
	};
}

local utils = {}

function utils:find_lrc_animation_handler()
	for _, v in pairs(game.StarterPlayer.StarterPlayerScripts:GetChildren()) do
		if v.Name == 'LRC4_ANIMATION_HANDLER' and v:HasTag('lrc4') then
			return true
		end
	end
	
	return false
end

function utils:get_rig_type_ext(m:Model):'R15'|'R6'
	return m:FindFirstChild('LowerTorso') and 'R15'::'R15' or 'R6'::'R6' -- type solver is weird
end

function utils:get_enum_by_bit_thingy(sub:string, num:number):Enum?
	return enums[sub][num]
end

return utils