local ts = game:GetService("TweenService")
local http = game:GetService("HttpService")
local players = game:GetService("Players")
local ps = game:GetService("PolicyService")
local uis = game:GetService("UserInputService")
local us = game:GetService("UserService")
local selection = game:GetService("Selection")
local chs = game:GetService("ChangeHistoryService")
local is = game:GetService('InsertService')
local debris = game:GetService('Debris')
local mps = game:GetService('MarketplaceService')
local ss = game:GetService('StudioService')
local content = game:GetService('ContentProvider')

local user_id = game:GetService("StudioService"):GetUserId()

local r = script.Parent.Parent
local gateway = r.connect.plugin_gateway

local construct = require(r.modules.constructor)
local wrapper = require(script.Parent.wrapper)
local themes = require(r.modules.themes)
local notifs = require(r.modules.notifs)
local utils = require(r.modules.utils)
local lxm = require(r.modules.lxm)
local pvfr = require(script.Parent.pvfr)
local nav = r.modules.nav

local plugin_mouse = script.Parent.Parent.connect.plugin_gateway:Invoke("get", "mouse")

local rbxasset_cursors = {
	arrow = "rbxasset://SystemCursors/Arrow";
	pointer = "rbxasset://SystemCursors/PointingHand";
	open_hand = "rbxasset://SystemCursors/OpenHand";
	closed_hand = "rbxasset://SystemCursors/ClosedHand";
	i_beam = "rbxasset://SystemCursors/IBeam";
	forbidden = "rbxasset://SystemCursors/Forbidden";
	_wait = "rbxasset://SystemCursors/Wait";
	busy = "rbxasset://SystemCursors/Busy";
}

local cursors = {
	default = rbxasset_cursors.arrow;
	hover = rbxasset_cursors.pointer;
	forbidden = rbxasset_cursors.forbidden;
	_wait = rbxasset_cursors._wait;
	busy = rbxasset_cursors.busy;
}

local function c(cursor:string)
	plugin_mouse.Icon = cursor
end

local configs = {
	rig_type = "R15";
	root_rig_type = "R15";
	origin_rig_type = "R15";
	outfit_id = 0;
	outfit_name = "";
	uid = 0;
	auto_update = false;
	pushable = true;
	nametag = true;
	locked = false;
	inspectable = false;
	disable_health_display = true;
	disable_automatic_scaling = false;
	remove_packages = false;
	ignore_body_scale = false;
	body_colours = {};
	body_colour3s = {};
	assets = {};
	root_assets = {};
	emotes = {};
	scales = {};
	animation_id = 0;
	animation_applied = false;
	set_animation_action4 = false;
	last_loaded_rig = nil;
	viewport_active_rig = nil;
	is_local = false;
	local_req_info = {cai={};humanoid_desc={};};
	overwrite_3d_preview_pref = false;
}

local cache = {
	--outfits = {
	--	{id = 655331725; outfits = {
	--		[1] = {
	--			id = 0;
	--			name = "-";
	--			isEditable = false;
	--		}
	--	};};	
	--};
	outfits = {
		--[655331725] = "{"filteredCount":8,"data":[{"id":16295932724,"name":"gaming","isEditable":true},{"id":13949279770,"name":"cat","isEditable":true},{"id":10858097894,"name":"Yellow Wolfite","isEditable":true},{"id":10857067480,"name":"Red Wolfite","isEditable":true},{"id":10663644599,"name":"Blue Wolfite","isEditable":true},{"id":10484701302,"name":"Purple Wolfite","isEditable":true},{"id":10484672635,"name":"Orange Wolfite","isEditable":true},{"id":10314008137,"name":"Wolfite","isEditable":true}],"total":8}";
	};
}

--local function get_outfits(uid:number)
--	if cache.outfits[uid] ~= nil then
--		--print("cached")
--		return http:JSONDecode(cache.outfits[uid])
--	else
--		-- unfinished code area
--		local url = `https://oxalyl.apis.wolf1te.com/roblox.com/avatar/v1/users/{tostring(uid)}/outfits?isEditable=true&itemsPerPage=50&outfitType=Avatar&page=1` --`https://hydrogen.wolfite.dev/roblox/avatar/v1/users/{tostring(user_id)}/outfits?isEditable=true&itemsPerPage=50&outfitType=Avatar&page=1`
--		--print(url)
--		local outfits = http:GetAsync(url, false, {
--			["wlft-auth"]="public-key-lrc4-07-04-24-VYv34kD7YD2kq2LUxVykfYpgrkkZjvhHgU9V74hBnurCKzdphYB30Z00J2UyJT1AAPEqLXYmSV03VwTDvZ4b7d1U5mZu5DdcBZVd9hTY5jeHNqzfT9HpBW36kZeZ";
--		})

--		if outfits["errors"] == nil then
--			cache.outfits[uid] = outfits
--		end
--		return http:JSONDecode(outfits)
--	end
--end

local function use_viewport_by_default() local dsetting = gateway:Invoke("get","setting",{setting_name="use_3d_preview"}); return if dsetting ~= nil and dsetting == false then false else true end

local function upd_viewport_model_async(widget:DockWidgetPluginGui)
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end
	
	app.loader.view.contain_view.viewport_padding.rig_type_mismatch_warning.Visible = false
	
	if configs.viewport_active_rig then
		configs.viewport_active_rig:Destroy()
		configs.viewport_active_rig = nil
	end
	
	
	local rig = r.rigs[(configs.rig_type == "R6" or configs.rig_type == "R15") and configs.rig_type or "R6"]:Clone()
	--if configs.rig_type == 'R15' then rig = r.rigs.R15_low:Clone() end
	rig.Archivable = false
	
	local vs, verr
	
	if not configs.overwrite_3d_preview_pref and use_viewport_by_default() ~= true then
		vs, verr = true, nil
	else
		vs, verr = pcall(function()
			local rig_humanoid:Humanoid = rig:WaitForChild("Humanoid")

			rig.Parent = workspace
			rig.HumanoidRootPart.CFrame = CFrame.new(1e9,1e9,1e9)
			
			--rig.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
			
			for _, v in pairs(rig:GetDescendants()) do
				if v:IsA(string.reverse('D6rotoM')) then
					v.Archivable = false
					v:Destroy()
				end
			end
			
			
			local desc
			
			if configs.local_req_info and configs.local_req_info.humanoid_desc and typeof(configs.local_req_info.humanoid_desc) == 'Instance' and configs.local_req_info.humanoid_desc:IsA('HumanoidDescription') then desc = configs.local_req_info.humanoid_desc else
				if configs.outfit_id ~= 0 then
					desc = players:GetHumanoidDescriptionFromOutfitId(configs.outfit_id)
				else
					desc = players:GetHumanoidDescriptionFromUserId(configs.uid)
				end
			end
			
			if desc and typeof(desc) == 'Instance' then
				content:PreloadAsync({desc})
			end
			
			rig_humanoid:ApplyDescription(desc)
			rig.HumanoidRootPart.CFrame = CFrame.new(304.777527, 9.99545383, -303.347107, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			
		
			------ reduce load on lower-performance devices by removing instances that normally dont affect the appearance while in the viewport (barely helps)
			
			--for _, v in pairs(rig:GetDescendants()) do
			--	if v and v:IsA('Attachment') or v:IsA('Vector3Value') or v:IsA('Weld') then
			--		v:Destroy()
			--	end
			--end
			
			-- nvm
			
			
			--task.wait()
			
			rig.Parent = app.loader.view.contain_view.viewport_padding.viewport.wm -- apparently a death sentence for low-end devices now, great job roblox :+1:
			rig:PivotTo(CFrame.new())
			rig.HumanoidRootPart.CFrame = CFrame.new()
			configs.viewport_active_rig = rig
		end)		
	end
	

	if not vs then
		
		app.loader.view.contain_view.viewport_padding.viewport.Visible = false
		app.loader.view.contain_view.viewport_padding.fallback.Visible = true
		app.loader.view.contain_view.viewport_padding.preload.Visible = false
		app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button.ImageTransparency = 0.4
		app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button.Image = 'http://www.roblox.com/asset/?id=92043778278910'
		app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button:SetAttribute('cursor', 'forbidden')
		warn('LRC4 | failed to deploy rig to viewport: ', verr, ' : ', debug.traceback())
		configs.viewport_active_rig = nil
		debris:AddItem(rig, 0)
		notifs:banner(widget, 'An error occured when loading the 3D Preview', 'error', 3)
	else
		if not configs.overwrite_3d_preview_pref and use_viewport_by_default() ~= true then
			app.loader.view.contain_view.viewport_padding.viewport.Visible = false
			app.loader.view.contain_view.viewport_padding.preload.Visible = false
			app.loader.view.contain_view.viewport_padding.fallback.Visible = true
			app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button.ImageTransparency = 0.4
			app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button.Image = 'http://www.roblox.com/asset/?id=92043778278910'
		else
			app.loader.view.contain_view.viewport_padding.viewutil['3drotate'].button.ImageTransparency = 0
			app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button.ImageTransparency = 0
			app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button.Image = 'http://www.roblox.com/asset/?id=122051953862388'
			app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button:SetAttribute('cursor', 'hover')
			app.loader.view.contain_view.viewport_padding.viewport.Visible = true
			app.loader.view.contain_view.viewport_padding.fallback.Visible = false
			app.loader.view.contain_view.viewport_padding.preload.Visible = false
		end
	end
	
	if rig and rig.Parent then pvfr:enable(app.loader.view.contain_view.viewport_padding.viewport, rig, widget) end
end

local prefarotate = true -- prefer auto rotate

local loader = {}

function loader:init(widget:DockWidgetPluginGui)
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end
	
	local tbrid
	
	app.loader.main.insert_options.insert.c.hitbox.MouseButton1Click:Connect(function()
		app.loader.main.insert_options.insert.icon.img.Visible = false
		app.loader.main.insert_options.insert.icon.__quantum_spinner.Visible = true
		app.loader.main.insert_options.insert.UIListLayout.Padding = UDim.new(0,10)
		--app.loader.main.insert_options.insert.Size = UDim2.new(0,134,0,40)
		app.loader.main.insert_options.insert:TweenSize(UDim2.new(0,136,0,40),"In","Quad",0.15,true)
		
		local save_recents = gateway:Invoke("get","setting",{setting_name="save_recents"}) ~= false
		
		if save_recents then

			local last_loaded_db = gateway:Invoke("get","setting",{setting_name="last_loaded_db"}) or {}
			--print(gateway:Invoke("get","setting",{setting_name="last_loaded_db"}), last_loaded_db)
			last_loaded_db[tostring(configs.uid)] = os.time()
			--print("sent", last_loaded_db)
			gateway:Invoke("post","setting",{setting_name="last_loaded_db", target=last_loaded_db})
			--print('m', gateway:Invoke("get","setting",{setting_name="last_loaded_db"}))
			r.modules.home.__content_sync:Fire("lldbupd")
		end
		
		---[LOAD START]
		
		tbrid = chs:TryBeginRecording("lrc4-insert", "Insert Character")
		
		local usi = wrapper:get_user_info_for_individual(configs.uid)
		if usi == {} or usi == nil then if configs.uid == -444 then usi = {DisplayName = '_LOCAL'; HasVerifiedBadge = true; Id = -444; Username = '_LOCAL'} else error("[handled]User info is not available. Is the user terminated or hidden?") end end
		local rig = r.rigs[(configs.rig_type == "R6" or configs.rig_type == "R15") and configs.rig_type or "R6"]:Clone()
		local rig_humanoid:Humanoid = rig:WaitForChild("Humanoid")
		
		rig.Parent = workspace
		rig.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		
		local desc
		if configs.outfit_id ~= 0 then
			desc = players:GetHumanoidDescriptionFromOutfitId(configs.outfit_id)
		else
			desc = configs.local_req_info and configs.local_req_info.humanoid_desc and typeof(configs.local_req_info.humanoid_desc) == 'Instance' and configs.local_req_info.humanoid_desc:IsA('HumanoidDescription') and configs.local_req_info.humanoid_desc or players:GetHumanoidDescriptionFromUserId(configs.uid)
		end
		
		if configs.remove_packages then
			desc.Head = 0
			desc.LeftArm = 0
			desc.LeftLeg = 0
			desc.RightArm = 0
			desc.RightLeg = 0
			desc.Torso = 0
		end
		
		if configs.ignore_body_scale then
			desc.BodyTypeScale = 0
			desc.DepthScale = 1
			desc.HeadScale = 1
			desc.HeightScale = 1
			desc.ProportionScale = 0
			desc.WidthScale = 1
		end
		
		rig_humanoid:ApplyDescription(desc)
		
		if configs.outfit_id ~= 0 then
			rig_humanoid.DisplayName = `@{usi.Username}: "{configs.outfit_name}"`
			rig.Name = `{configs.rig_type}_{usi.Username}_{usi.Id}_{configs.outfit_name}_{configs.outfit_id}`
			rig:SetAttribute('is_outfit', true)
			rig:SetAttribute('outfit_id', configs.outfit_id)
		else
			if gateway:Invoke("get","setting",{setting_name="simplified_model_names"}) then
				rig.Name = usi.Username or tostring(usi.Id)
			else
				rig.Name = `{configs.rig_type}_{usi.Username}_{usi.Id}`
			end
			if gateway:Invoke("get","setting",{setting_name="prioritise_display_names"}) == true then
				rig_humanoid.DisplayName = usi.DisplayName
			else
				rig_humanoid.DisplayName = "@"..usi.Username
			end
		end
		
		if configs.is_local then rig.Name = `{configs.rig_type}_IMPORTED{configs.uid ~= -444 and '_'.. tostring(configs.uid) or ''}`; rig_humanoid.DisplayName = "IMPORTED" end
		
		local s, err2 = pcall(function()
			if configs.inspectable then
				local inspect = r.script_presets.inspectable:Clone()
				inspect:SetAttribute("uid", configs.uid)
				inspect:SetAttribute("is_outfit", configs.outfit_id ~= 0)
				inspect.Parent = rig
				inspect.Enabled = true
				inspect:AddTag("lrc4")
			end

			if configs.auto_update and configs.outfit_id == 0 and not configs.is_local then
				local auto = r.script_presets.auto_apply:Clone()
				auto:SetAttribute("uid", configs.uid)
				auto.Parent = rig
				auto.Enabled = true
				auto:AddTag("lrc4")
			end
		end)
		
		if not s then
			notifs:banner(widget, "An error occured while adding script(s) to character, please make sure LRC4 can modify scripts and try again. <u>Click to learn more</u>.", "error", 0, 'script_injection')
		end
		
		if configs.disable_health_display then
			rig_humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		end
		
		if not configs.nametag then
			rig_humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end
		
		if not configs.pushable then
			rig_humanoid.RootPart.Anchored = true
		end
		
		if configs.disable_automatic_scaling then
			rig_humanoid.AutomaticScalingEnabled = false
		end
		
		if not configs.locked then
			for _, v in pairs(rig:GetChildren()) do
				if (configs.rig_type == 'R15' and v:IsA('MeshPart')) or (configs.rig_type == 'R6' and v:IsA('Part')) then
					v.Locked = false
				end
			end
		else
			for _, v in pairs(rig:GetChildren()) do
				if (configs.rig_type == 'R15' and v:IsA('MeshPart')) or (configs.rig_type == 'R6' and v:IsA('Part')) then
					v.Locked = true
				end
			end
		end
		
		if configs.animation_id ~= 0 and configs.animation_applied and configs.rig_type == 'R15' then
			rig:SetAttribute('lrc4_animation__enabled', true)
			rig:SetAttribute('lrc4_animation__id', configs.animation_id)
			
			
			if configs.set_animation_action4 then
				rig:SetAttribute('lrc4_animation__use_action4', true)
			end
		end
		
		if not configs.is_local then
			rig:SetAttribute('appearance_uid', configs.uid)
		end
		
		if (gateway:Invoke("get","setting",{setting_name="insert_at_camera"}) or true) then
			local cam, m = workspace.Camera, rig:FindFirstChildOfClass("Humanoid").RootPart
			local offset = cam.CFrame.Position + (cam.CFrame.LookVector * 10)

			--m.Position = rig[if configs.rig_type == "R6" then "Torso" else "UpperTorso"].Position
			-- really overthinking things here
			--if configs.rig_type == "R6" then 
			--	--m.CFrame = CFrame.new(offset)-Vector3.new(0,4,0)
			--	--m.Position = Vector3.new(math.floor(m.Position.X + 0.5),math.floor(m.Position.Y + 0.5),math.floor(m.Position.Z + 0.5))
			--	--m.Position = rig.Torso.Position 
			--	rig:PivotTo(CFrame.new(offset)-Vector3.new(0,4,0))
			--elseif configs.rig_type == "R15" then 
			--	--a = (rig.UpperTorso.Position - rig.LowerTorso.Position)
			--	rig:PivotTo(CFrame.new(offset)-Vector3.new(0,4,0))
			--end

			rig:PivotTo(CFrame.new(offset)-Vector3.new(0,4,0))
		end
		
		selection:Set({rig})
		configs.last_loaded_rig = rig
		app.loader.view.contain_view.viewport_padding.util['export'].button.ImageTransparency = 0.4
		app.loader.view.contain_view.viewport_padding.util['export'].button:SetAttribute('cursor', 'hover')
		
		if typeof(tbrid) == "string" then
			chs:FinishRecording(tbrid, Enum.FinishRecordingOperation.Commit)
		end
		
		---[LOAD END]
		
		task.wait(.15)
		--app.loader.main.insert_options.insert.Size = UDim2.new(0,130,0,40)
		app.loader.main.insert_options.insert:TweenSize(UDim2.new(0,130,0,40),"Out","Quad",0.15,true)
		app.loader.main.insert_options.insert.UIListLayout.Padding = UDim.new(0,4)
		app.loader.main.insert_options.insert.icon.img.Visible = true
		app.loader.main.insert_options.insert.icon.__quantum_spinner.Visible = false
		
		
		local recent = gateway:Invoke("get","setting",{setting_name="recent"}) or {}
		if table.find(recent, configs.uid) then
			table.remove(recent,table.find(recent, configs.uid))
			--recent[table.find(recent, configs.uid)] = nil
		end
		table.insert(recent, 1, configs.uid)
		if #recent >= 30 then recent[30] = nil end
		--print(recent)
		gateway:Invoke("post","setting",{setting_name="recent",target=recent})
		r.modules.home.__content_sync:Fire("recent")
	end)
	
	app.loader.main.insert_options.insert_magic.c.hitbox.MouseButton1Click:Connect(function()
		-- not really what i had planned for 'magic', but sure
		app.loader.main.insert_options.insert_magic.icon.img.Visible = false
		app.loader.main.insert_options.insert_magic.icon.__quantum_spinner.Visible = true
		local res = r.connect.plugin_gateway:Invoke("post", "prompt", {prompt_header = "Insert"; prompt_desc = "This insert button will insert a character, but using an alternative method. If you are having issues loading a character, you should try using this button. This method usually takes longer. \n\nWARNING: THIS METHOD WILL IGNORE YOUR RIG TYPE (R6/R15) PREFERENCE (along with certain settings)."; prompt_id = "INSERTMAGICCONFIRM"})
		
		if res ~= true then app.loader.main.insert_options.insert_magic.icon.img.Visible = true; app.loader.main.insert_options.insert_magic.icon.__quantum_spinner.Visible = false; return end
		
		
		local save_recents = gateway:Invoke("get","setting",{setting_name="save_recents"}) ~= false

		if save_recents then
			local last_loaded_db = gateway:Invoke("get","setting",{setting_name="last_loaded_db"}) or {}
			last_loaded_db[tostring(configs.uid)] = os.time()
			gateway:Invoke("post","setting",{setting_name="last_loaded_db", target=last_loaded_db})
			r.modules.home.__content_sync:Fire("lldbupd")
		end
		
		---[LOAD START]

		tbrid = chs:TryBeginRecording("lrc4-insert", "Insert Character")

		local usi = wrapper:get_user_info_for_individual(configs.uid)
		if usi == {} or usi == nil then if configs.uid == -444 then usi = {DisplayName = '_LOCAL'; HasVerifiedBadge = true; Id = -444; Username = '_LOCAL'} else error("[handled]User info is not available. Is the user terminated or hidden?") end end
		local rig
		
		if configs.outfit_id ~= 0 then
			rig = players:CreateHumanoidModelFromDescription(players:GetHumanoidDescriptionFromOutfitId(configs.outfit_id), Enum.HumanoidRigType[configs.rig_type])		
		else
			rig = players:CreateHumanoidModelFromUserId(configs.uid)
		end
		
		rig.Parent = workspace
		rig.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		
		local rig_humanoid = rig:FindFirstChildOfClass('Humanoid')
		
		if configs.outfit_id ~= 0 then
			rig_humanoid.DisplayName = `@{usi.Username}: "{configs.outfit_name}"`
			rig.Name = `{configs.rig_type}_{usi.Username}_{usi.Id}_{configs.outfit_name}_{configs.outfit_id}`
			rig:SetAttribute('is_outfit', true)
			rig:SetAttribute('outfit_id', configs.outfit_id)
		else
			if gateway:Invoke("get","setting",{setting_name="simplified_model_names"}) then
				rig.Name = usi.Username or tostring(usi.Id)
			else
				rig.Name = `{configs.rig_type}_{usi.Username}_{usi.Id}`
			end
			if gateway:Invoke("get","setting",{setting_name="prioritise_display_names"}) == true then
				rig_humanoid.DisplayName = usi.DisplayName
			else
				rig_humanoid.DisplayName = "@"..usi.Username
			end
		end
		
		local s, err2 = pcall(function()
			if configs.inspectable then
				local inspect = r.script_presets.inspectable:Clone()
				inspect:SetAttribute("uid", configs.uid)
				inspect:SetAttribute("is_outfit", configs.outfit_id ~= 0)
				inspect.Parent = rig
				inspect.Enabled = true
				inspect:AddTag("lrc4")
			end

			if configs.auto_update and configs.outfit_id == 0 and not configs.is_local then
				local auto = r.script_presets.auto_apply:Clone()
				auto:SetAttribute("uid", configs.uid)
				auto.Parent = rig
				auto.Enabled = true
				auto:AddTag("lrc4")
			end
		end)
		
		if not s then
			notifs:banner(widget, "An error occurred while adding script(s) to character, please make sure LRC4 can modify scripts and try again. <u>Click to learn more</u>.", "error", 0, 'script_injection')
		end
		
		if configs.disable_health_display then
			rig_humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		end

		if not configs.nametag then
			rig_humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end

		if not configs.pushable then
			rig_humanoid.RootPart.Anchored = true
		end

		if configs.disable_automatic_scaling then
			rig_humanoid.AutomaticScalingEnabled = false
		end
		
		if not configs.locked then
			for _, v in pairs(rig:GetChildren()) do
				if (configs.rig_type == 'R15' and v:IsA('MeshPart')) or (configs.rig_type == 'R6' and v:IsA('Part')) then
					v.Locked = false
				end
			end
		else
			for _, v in pairs(rig:GetChildren()) do
				if (configs.rig_type == 'R15' and v:IsA('MeshPart')) or (configs.rig_type == 'R6' and v:IsA('Part')) then
					v.Locked = true
				end
			end
		end

		if configs.animation_id ~= 0 and configs.animation_applied and configs.rig_type == 'R15' then
			rig:SetAttribute('lrc4_animation__enabled', true)
			rig:SetAttribute('lrc4_animation__id', configs.animation_id)


			if configs.set_animation_action4 then
				rig:SetAttribute('lrc4_animation__use_action4', true)
			end
		end

		if not configs.is_local then
			rig:SetAttribute('appearance_uid', configs.uid)
		end

		if (gateway:Invoke("get","setting",{setting_name="insert_at_camera"}) or true) then
			local cam, m = workspace.Camera, rig:FindFirstChildOfClass("Humanoid").RootPart
			local offset = cam.CFrame.Position + (cam.CFrame.LookVector * 10)

			rig:PivotTo(CFrame.new(offset)-Vector3.new(0,4,0))
		end

		selection:Set({rig})
		configs.last_loaded_rig = rig
		app.loader.view.contain_view.viewport_padding.util['export'].button.ImageTransparency = 0.4
		app.loader.view.contain_view.viewport_padding.util['export'].button:SetAttribute('cursor', 'hover')

		if typeof(tbrid) == "string" then
			chs:FinishRecording(tbrid, Enum.FinishRecordingOperation.Commit)
		end

		---[LOAD END]
		
		task.wait(.15)
		
		local recent = gateway:Invoke("get","setting",{setting_name="recent"}) or {}
		if table.find(recent, configs.uid) then
			table.remove(recent,table.find(recent, configs.uid))
			--recent[table.find(recent, configs.uid)] = nil
		end
		table.insert(recent, 1, configs.uid)
		if #recent >= 30 then recent[30] = nil end
		--print(recent)
		gateway:Invoke("post","setting",{setting_name="recent",target=recent})
		r.modules.home.__content_sync:Fire("recent")
		
		
		app.loader.main.insert_options.insert_magic.icon.img.Visible = true
		app.loader.main.insert_options.insert_magic.icon.__quantum_spinner.Visible = false
	end)
	
	app.loader.view.contain_view.viewport_padding.util.bookmark.button.MouseEnter:Connect(function()
		ts:Create(app.loader.view.contain_view.viewport_padding.util.bookmark.button, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0.2}):Play()
	end)
	
	app.loader.view.contain_view.viewport_padding.util.bookmark.button.MouseLeave:Connect(function()
		ts:Create(app.loader.view.contain_view.viewport_padding.util.bookmark.button, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0.4}):Play()
	end)
		 
	app.loader.view.contain_view.viewport_padding.util2.refresh.button.MouseEnter:Connect(function()
		ts:Create(app.loader.view.contain_view.viewport_padding.util2.refresh.button, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0.2}):Play()
	end)

	app.loader.view.contain_view.viewport_padding.util2.refresh.button.MouseLeave:Connect(function()
		ts:Create(app.loader.view.contain_view.viewport_padding.util2.refresh.button, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0.4}):Play()
	end)
	
	app.loader.view.contain_view.viewport_padding.expand.expand.button.MouseEnter:Connect(function()
		ts:Create(app.loader.view.contain_view.viewport_padding.expand.expand.button, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0.2}):Play()
	end)

	app.loader.view.contain_view.viewport_padding.expand.expand.button.MouseLeave:Connect(function()
		ts:Create(app.loader.view.contain_view.viewport_padding.expand.expand.button, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0.4}):Play()
	end)
	
	app.loader.view.contain_view.viewport_padding.util.colours.button.MouseEnter:Connect(function()
		ts:Create(app.loader.view.contain_view.viewport_padding.util.colours.button, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0.2}):Play()
	end)

	app.loader.view.contain_view.viewport_padding.util.colours.button.MouseLeave:Connect(function()
		ts:Create(app.loader.view.contain_view.viewport_padding.util.colours.button, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0.4}):Play()
	end)
	
	local function toggle_bookmark()
		app.loader.view.contain_view.viewport_padding.util.bookmark.button.Visible = false
		app.loader.view.contain_view.viewport_padding.util.bookmark.__quantum_spinner.Visible = true
		local bookmarked = gateway:Invoke("get","setting",{setting_name="bookmarked"}) or {}
		if table.find(bookmarked, configs.uid) then
			bookmarked[table.find(bookmarked, configs.uid)] = nil
			app.loader.view.contain_view.viewport_padding.util.bookmark.button.Image = "http://www.roblox.com/asset/?id=17261516757" --add
		else
			table.insert(bookmarked, 1, configs.uid)
			app.loader.view.contain_view.viewport_padding.util.bookmark.button.Image = "http://www.roblox.com/asset/?id=17261520172" --remove
		end
		gateway:Invoke("post","setting",{setting_name="bookmarked",target=bookmarked})
		r.modules.home.__content_sync:Fire("bookmarked")
		task.wait(.2)
		app.loader.view.contain_view.viewport_padding.util.bookmark.button.Visible = true
		repeat task.wait() until app.loader.view.contain_view.viewport_padding.util.bookmark.button.IsLoaded
		app.loader.view.contain_view.viewport_padding.util.bookmark.__quantum_spinner.Visible = false
	end
	
	app.loader.view.contain_view.viewport_padding.util.bookmark.button.MouseButton1Click:Connect(toggle_bookmark)
	
	app.loader.main.content.top_buttons.R6.hitbox.MouseButton1Click:Connect(function()
		if configs.root_rig_type == "R15" then
			local res = r.connect.plugin_gateway:Invoke("post", "prompt", {prompt_header = "Are you sure you want to switch this rig to R6?"; prompt_desc = "This avatar could be incompatible with this rig type and may look broken. Are you sure you want to perform this action?"; prompt_id = "R6HATERPROMPT"})
			--print(res)
			
			if res == true then
				app.loader.view.contain_view.viewport_padding.viewport.Visible = false
				app.loader.view.contain_view.viewport_padding.fallback.Visible = false
				app.loader.view.contain_view.viewport_padding.preload.Visible = true
				ts:Create(app.loader.main.content.top_buttons.R6, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(42, 100, 246)}):Play()
				ts:Create(app.loader.main.content.top_buttons.R15, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play()
				configs.rig_type = "R6"
				app.loader.main.content.options.option__default_scale.__slider:SetAttribute("enabled", false)
				ts:Create(app.loader.main.content.top_buttons.animations.icon, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0.4}):Play()
				app.loader.main.content.top_buttons.animations.hitbox:SetAttribute('cursor', 'forbidden')
				if configs.animation_applied then app.loader.main.content.top_buttons.animations.crc.Visible = false end
				
				if configs.viewport_active_rig then
					configs.viewport_active_rig:Destroy()
				end
				
				upd_viewport_model_async(widget)
				if configs.rig_type ~= configs.origin_rig_type then app.loader.view.contain_view.viewport_padding.rig_type_mismatch_warning.Visible = true else app.loader.view.contain_view.viewport_padding.rig_type_mismatch_warning.Visible = false end
			end
		else
			if configs.rig_type ~= "R6" then
				app.loader.view.contain_view.viewport_padding.viewport.Visible = false
				app.loader.view.contain_view.viewport_padding.fallback.Visible = false
				app.loader.view.contain_view.viewport_padding.preload.Visible = true
				
				ts:Create(app.loader.main.content.top_buttons.R6, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(42, 100, 246)}):Play()
				ts:Create(app.loader.main.content.top_buttons.R15, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play()
				configs.rig_type = "R6"
				app.loader.main.content.options.option__default_scale.__slider:SetAttribute("enabled", false)
				ts:Create(app.loader.main.content.top_buttons.animations.icon, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0.4}):Play()
				app.loader.main.content.top_buttons.animations.hitbox:SetAttribute('cursor', 'forbidden')
				if configs.animation_applied then app.loader.main.content.top_buttons.animations.crc.Visible = false end
				
				upd_viewport_model_async(widget)
				if configs.rig_type ~= configs.origin_rig_type then app.loader.view.contain_view.viewport_padding.rig_type_mismatch_warning.Visible = true else app.loader.view.contain_view.viewport_padding.rig_type_mismatch_warning.Visible = false end
			end
		end
	end)
	
	app.loader.main.content.top_buttons.R15.hitbox.MouseButton1Click:Connect(function()
		if configs.rig_type ~= "R15" then -- just wrote != "R15" .. and im back because i also wrote root_rig_type instead of rig_type
			app.loader.view.contain_view.viewport_padding.viewport.Visible = false
			app.loader.view.contain_view.viewport_padding.fallback.Visible = false
			app.loader.view.contain_view.viewport_padding.preload.Visible = true
			
			ts:Create(app.loader.main.content.top_buttons.R6, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play()
			ts:Create(app.loader.main.content.top_buttons.R15, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(42, 100, 246)}):Play()
			configs.rig_type = "R15"
			app.loader.main.content.options.option__default_scale.__slider:SetAttribute("enabled", true)
			ts:Create(app.loader.main.content.top_buttons.animations.icon, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0}):Play()
			app.loader.main.content.top_buttons.animations.hitbox:SetAttribute('cursor', 'hover')
			if configs.animation_applied then app.loader.main.content.top_buttons.animations.crc.Visible = true end
			
			upd_viewport_model_async(widget)
			
			if configs.rig_type ~= configs.origin_rig_type then app.loader.view.contain_view.viewport_padding.rig_type_mismatch_warning.Visible = true else app.loader.view.contain_view.viewport_padding.rig_type_mismatch_warning.Visible = false end
		end
	end)
	
	local function open__outfits()
		if configs.is_local then return end

		app.loader.main.content.Visible = false
		app.loader.main.insert_options.Visible = false
		app.loader.main.outfits.content.Visible = false
		app.loader.main.outfits.preload.Visible = true
		app.loader.main.outfits.Visible = true
		app.loader.main.outfits.content.outfits.Visible = true
		app.loader.main.outfits.content.fallback.Visible = false
		app.loader.main.outfits.content.CanvasPosition = Vector2.new(0,0)

		for _, v in pairs(app.loader.main.outfits.content.outfits:GetChildren()) do
			if v:IsA("Frame") and v.Name:find("outfit") then
				v:Destroy()
			end
		end

		local res = wrapper:get_outfits(configs.uid, widget)

		--print(res)

		if res and typeof(res) == "table" then
			for _, v in pairs(res and res.data or {}) do
				local t = r.ui.outfit:Clone()

				t.Name = `outfit_{tostring(configs.uid)}_{tostring(configs.outfit_id)}`
				t.img.Image = `rbxthumb://type=Outfit&id={tostring(v.id)}&w=150&h=150`
				themes:apply_theme_to_ic(t, settings().Studio and settings().Studio.Theme and settings().Studio.Theme.Name and settings().Studio.Theme.Name:lower() == "light" and "def" or "dark")

				t.hitbox.MouseButton1Click:Connect(function()
					app.loader.view.contain_view.viewport_padding.fallback.Visible = false
					app.loader.view.contain_view.viewport_padding.viewport.Visible = false
					app.loader.view.contain_view.viewport_padding.preload.Visible = true
					configs.outfit_id = v.id
					configs.outfit_name = v.name
					app.loader.main.content.id.Text = `{tostring(configs.uid)}: "{v.name}"`
					app.loader.view.contain_view.viewport_padding.fallback.Image = `rbxthumb://type=Outfit&id={tostring(v.id)}&w=420&h=420`
					--local cai = players:getchar(configs.uid)
					app.loader.main.outfits.Visible = false
					app.loader.main.insert_options.Visible = true
					app.loader.main.content.Visible = true
					--local res = r.connect.plugin_gateway:Invoke("post", "prompt", {prompt_header = "Switched rig to R15"; prompt_desc = "The loader's rig preference is automatically switched to R15 whenever you select an outfit because we cannot determine rig types of outfits."; prompt_id = "WECANTTELLFORSOMEREASON"; disable_cancel=true;})
					--configs.rig_type = "R15"
					ts:Create(app.loader.main.content.top_buttons.R6, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play()
					ts:Create(app.loader.main.content.top_buttons.R15, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(42, 100, 246)}):Play()
					--app.loader.main.content.options.option__inspectable.__slider:SetAttribute("enabled", false) 
					--app.loader.main.content.options.option__inspectable.__slider:SetAttribute("state", false)
					app.loader.main.content.options.option__auto_update.__slider:SetAttribute("enabled", false)
					app.loader.main.content.options.option__auto_update.__slider:SetAttribute("state", false)
					app.loader.main.content.top_buttons.R6.Visible = false
					app.loader.main.content.top_buttons.R15.Visible = false
					app.loader.main.content.top_buttons.r_loading.Visible = true
					app.loader.view.contain_view.viewport_padding.util.colours.button.Visible = false
					app.loader.view.contain_view.viewport_padding.util.colours.__quantum_spinner.Visible = true
					local res = wrapper:get_outfits_details(v.id, widget)

					if res then
						configs.rig_type = res.playerAvatarType
						--print(res)
						if configs.rig_type == "R6" then
							ts:Create(app.loader.main.content.top_buttons.R6, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(42, 100, 246)}):Play()
							ts:Create(app.loader.main.content.top_buttons.R15, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play()
							ts:Create(app.loader.main.content.top_buttons.animations.icon, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0.4}):Play()
							if configs.animation_applied then app.loader.main.content.top_buttons.animations.crc.Visible = false end
							app.loader.main.content.top_buttons.animations.hitbox:SetAttribute('cursor', 'forbidden')
						elseif configs.rig_type == "R15" then
							ts:Create(app.loader.main.content.top_buttons.R6, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play()
							ts:Create(app.loader.main.content.top_buttons.R15, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(42, 100, 246)}):Play()
							ts:Create(app.loader.main.content.top_buttons.animations.icon, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0}):Play()
							if configs.animation_applied then app.loader.main.content.top_buttons.animations.crc.Visible = true end
							app.loader.main.content.top_buttons.animations.hitbox:SetAttribute('cursor', 'hover')
						end
						app.loader.main.content.top_buttons.r_loading.Visible = false
						app.loader.main.content.top_buttons.R6.Visible = true
						app.loader.main.content.top_buttons.R15.Visible = true
						app.loader.view.contain_view.viewport_padding.util.colours.button.Visible = true
						app.loader.view.contain_view.viewport_padding.util.colours.__quantum_spinner.Visible = false
						if res.bodyColors then
							configs.body_colours = res.bodyColors
						elseif res.BodyColor3s then
							configs.body_colour3s = res.BodyColor3s
						end

						if res.assets then
							configs.assets = res.assets
						end

						upd_viewport_model_async(widget)
					else
						app.loader.main.content.top_buttons.r_loading.Visible = false
						app.loader.main.content.top_buttons.R6.Visible = true
						app.loader.main.content.top_buttons.R15.Visible = true
						warn('lrc4 soft error - no res received')
					end
				end)

				t.MouseEnter:Connect(function()
					c(cursors.hover)
				end)

				t.MouseLeave:Connect(function()
					c(cursors.default)
				end)

				t.Parent = app.loader.main.outfits.content.outfits
			end
		end

		if not res or (res and not res.data) or (res and #res.data == 0) then
			app.loader.main.outfits.content.outfits.Visible = false
			app.loader.main.outfits.content.fallback.Visible = true
		end
		
		if res == 'error' then
			app.loader.main.content.Visible = true
			app.loader.main.insert_options.Visible = true
			app.loader.main.outfits.Visible = false
		end

		app.loader.main.outfits.preload.Visible = false
		app.loader.main.outfits.content.Visible = true
	end
	
	app.loader.main.content.top_buttons.outfits.hitbox.MouseButton1Click:Connect(open__outfits)
	
	app.loader.main.outfits.content.current.hitbox.MouseButton1Click:Connect(function()
		local was_sel = configs.outfit_id ~= 0 or configs.rig_type ~= configs.root_rig_type
		if was_sel then
			app.loader.view.contain_view.viewport_padding.fallback.Visible = false
			app.loader.view.contain_view.viewport_padding.viewport.Visible = false
			app.loader.view.contain_view.viewport_padding.preload.Visible = true
		end
		configs.outfit_id = 0
		configs.outfit_name = ""
		configs.rig_type = configs.root_rig_type
		configs.assets = configs.root_assets
		app.loader.main.content.id.Text = tostring(configs.uid)
		app.loader.view.contain_view.viewport_padding.fallback.Image = players:GetUserThumbnailAsync(configs.uid, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size352x352)
		app.loader.main.content.Visible = true
		app.loader.main.insert_options.Visible = true
		app.loader.main.outfits.Visible = false
		
		if configs.origin_rig_type == "R6" then
			ts:Create(app.loader.main.content.top_buttons.R6, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(42, 100, 246)}):Play()
			ts:Create(app.loader.main.content.top_buttons.R15, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play()
		elseif configs.origin_rig_type == "R15" then
			ts:Create(app.loader.main.content.top_buttons.R6, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play()
			ts:Create(app.loader.main.content.top_buttons.R15, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(42, 100, 246)}):Play()
		end
		
		if was_sel then
			if configs.viewport_active_rig then
				configs.viewport_active_rig:Destroy()
			end
			
			upd_viewport_model_async(widget)
		end
		
		app.loader.main.content.options.option__inspectable.__slider:SetAttribute("enabled", true)
		app.loader.main.content.options.option__inspectable.__slider:SetAttribute("state", configs.inspectable)
		app.loader.main.content.options.option__auto_update.__slider:SetAttribute("enabled", true)
		app.loader.main.content.options.option__inspectable.__slider:SetAttribute("state", configs.auto_update)
	end)
	
	app.loader.main.outfits.content.outfits.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		app.loader.main.outfits.content.outfits.Size = UDim2.new(1,0,0,app.loader.main.outfits.content.outfits.UIListLayout.AbsoluteContentSize.Y+20)
	end)
	
	local processing_animations_application_db = false
	local animation_selection_db = false
	
	local function open__animations()
		if configs.rig_type == 'R6' then return end

		if not utils:find_lrc_animation_handler() then
			local res = r.connect.plugin_gateway:Invoke("post", "prompt", {prompt_header = "Inject Animation Handler"; prompt_desc = "The Animaiton Handler was not found in your experience. Clicking continue will result in LRC4 injecting the LRC4_ANIMATION_HANDLER into StarterPlayer.StarterPlayerScripts"; prompt_id = "ANIMATIONSSIR"; force_show = true;})

			if res == false then
				return
			end

			local s, err = pcall(function()
				local ahscr = r.script_presets["LRC4_ANIMATION_HANDLER"]:Clone()
				ahscr.Parent = game.StarterPlayer.StarterPlayerScripts
				ahscr.Enabled = true
			end)

			if not s then
				notifs:banner(widget, 'An error occured while adding script(s), please ensure LRC4 can modify scripts and try again. <u>Click to learn more</u>.', 'error', nil, 'script_injection')
				return
			end
		end

		app.loader.main.animations.content.id.Text = configs.uid.. (configs.outfit_id ~= 0 and ': "'.. configs.outfit_name.. '"' or '')

		for _, v in pairs(app.loader.main.animations.content.equipped_emotes:GetChildren()) do
			if v:IsA('Frame') then
				v:Destroy()
			end
		end

		app.loader.main.animations.content.CanvasPosition = Vector2.new(0,0)
		app.loader.main.content.Visible = false
		app.loader.main.insert_options.Visible = false
		app.loader.main.animations.Visible = true


		--print(configs.emotes, #configs)
		if #configs.emotes > 0 then
			app.loader.main.animations.content.equipped_emotes__none_found.Visible = false
			for _, v in pairs(configs.emotes) do
				local t = r.ui.emote:Clone()
				t.__quantum_spinner.Visible = true
				--t.img.Visible = false
				t.img.Image = `rbxthumb://type=Asset&id={tostring(v.assetId)}&w=420&h=420`
				r.modules.components.__apply_scan:Fire(t.__quantum_spinner)
				t:SetAttribute("tooltip_text", v.assetName)
				t:SetAttribute("tooltip_is_hint", true)

				t.MouseEnter:Connect(function()
					c(cursors.hover)
				end)

				t.MouseLeave:Connect(function()
					c(cursors.default)
				end)

				t.hitbox.MouseButton1Click:Connect(function()
					if animation_selection_db or processing_animations_application_db then return end
					task.spawn(function() notifs:banner(widget, 'Finding emote\'s animation file. Please wait...', 'default', 1) end)
					animation_selection_db = true

					local s, err = pcall(function()
						processing_animations_application_db = true
						app.loader.main.animations.content.apply.m.icon.img.Visible = false
						app.loader.main.animations.content.apply.m.icon.__quantum_spinner.Visible = true
						local m = is:LoadAsset(v.assetId)
						local anim_id = m:FindFirstChildOfClass('Animation').AnimationId:gmatch('%d+')()
						app.loader.main.animations.content.custom.custom_anim_input.Text = tostring(anim_id)
						app.loader.main.animations.content.custom.custom_emote_input.Text = ''

						configs.animation_id = anim_id
						configs.animation_applied = true
						app.loader.main.animations.content.apply.m.icon.img.Visible = true
						app.loader.main.animations.content.apply.m.icon.__quantum_spinner.Visible = false
						app.loader.main.animations.content.apply.m.icon.img.Image = 'rbxassetid://14925004232'
						app.loader.main.animations.content.apply.m.label.Text = 'APPLIED'
						app.loader.main.content.top_buttons.animations.crc.Visible = true
						processing_animations_application_db = false
						debris:AddItem(m)
					end)

					if not s then
						if err == 'Asset is not trusted for this place' then
							notifs:banner(widget, 'Received \'Asset is not trusted for this place\' error when retrieving animation file', 'error', 4)
						else
							notifs:banner(widget, 'Unexpected error when finding animation ID: '.. err, 'error')
						end

						app.loader.main.animations.content.apply.m.icon.img.Image = 'http://www.roblox.com/asset/?id=17298900001'
						app.loader.main.animations.content.apply.m.label.Text = 'APPLY'
						configs.animation_id = 0
						configs.animation_applied = false
						app.loader.main.animations.content.apply.m.icon.img.Visible = true
						app.loader.main.animations.content.apply.m.icon.__quantum_spinner.Visible = false
						app.loader.main.content.top_buttons.animations.crc.Visible = false
						app.loader.main.animations.content.custom.custom_anim_input.Text  = ''
					end

					--configs.animation_id = v.assetId
					--configs.animation_applied = true
					--app.loader.main.animations.content.apply.m.icon.img.Image = 'rbxassetid://14925004232'
					--app.loader.main.animations.content.apply.m.label.Text = 'APPLIED'
					--app.loader.main.content.top_buttons.animations.crc.Visible = true
					animation_selection_db = false
				end)

				r.modules.components.__apply_scan:Fire(t)
				t.Parent = app.loader.main.animations.content.equipped_emotes
				--repeat task.wait() until not t or not t.Parent or t.img.IsLoaded -- /... ???
				if not t or not t.Parent then break end
				t.__quantum_spinner.Visible = false
				t.img.Visible = true
			end
		else
			app.loader.main.animations.content.equipped_emotes__none_found.Visible = true
		end


	end
	
	app.loader.main.content.top_buttons.animations.hitbox.MouseButton1Click:Connect(open__animations)
	
	app.loader.main.animations.content.back.icon.hitbox.MouseButton1Click:Connect(function()
		app.loader.main.content.Visible = true
		app.loader.main.insert_options.Visible = true
		app.loader.main.animations.Visible = false
	end)
	
	local function ispublicanim(asset_id)
		local asset_type
		
		local s, err = pcall(function()
			local pinfo = mps:GetProductInfo(asset_id, Enum.InfoType.Asset)
			
			asset_type = pinfo.AssetTypeId
		end)
			
		if not s then
			task.spawn(function() notifs:banner(widget, 'Could not check asset. Are you sure it exists? : '.. err, 'error', 10) end)
			return 0
		end
		
		if asset_type == 24 then
			return 1
		else
			task.spawn(function() notifs:banner(widget, 'Provided asset ID is not of type \'Animation\'. Animation was applied regardless, use with caution', 'warning', 4) end)
			return 2
		end
	end
	
	app.loader.main.animations.content.custom.custom_anim_input.FocusLost:Connect(function(ent)
		if tonumber(app.loader.main.animations.content.custom.custom_anim_input.Text) == nil then app.loader.main.animations.content.custom.custom_anim_input.Text = app.loader.main.animations.content.custom.custom_anim_input.Text:gsub('%D+', '') end
		if tonumber(app.loader.main.animations.content.custom.custom_anim_input.Text) == nil then app.loader.main.animations.content.custom.custom_anim_input.Text = '' return end
		
		if ent then
			processing_animations_application_db = true
			app.loader.main.animations.content.apply.m.icon.img.Visible = false
			app.loader.main.animations.content.apply.m.icon.__quantum_spinner.Visible = true
			app.loader.main.animations.content.apply.m.label.Text = 'APPLYING...'
			local t = ispublicanim(tonumber(app.loader.main.animations.content.custom.custom_anim_input.Text))
			if t == 1 or t == 2 then
				configs.animation_id = tonumber(app.loader.main.animations.content.custom.custom_anim_input.Text)
				configs.animation_applied = true
				app.loader.main.animations.content.apply.m.icon.img.Image = 'rbxassetid://14925004232'
				app.loader.main.animations.content.apply.m.label.Text = 'APPLIED'
				app.loader.main.animations.content.apply.m.icon.img.Visible = true
				app.loader.main.animations.content.apply.m.icon.__quantum_spinner.Visible = false
				app.loader.main.content.top_buttons.animations.crc.Visible = true
			else
				configs.animation_id = 0
				configs.animation_applied = false
				app.loader.main.animations.content.apply.m.icon.img.Image = 'http://www.roblox.com/asset/?id=17298900001'
				app.loader.main.animations.content.apply.m.label.Text = 'APPLY'
				app.loader.main.animations.content.apply.m.icon.img.Visible = true
				app.loader.main.animations.content.apply.m.icon.__quantum_spinner.Visible = false
				app.loader.main.content.top_buttons.animations.crc.Visible = false
				app.loader.main.animations.content.custom.custom_anim_input.Text  = ''
			end
			processing_animations_application_db = false
		end
	end)
	
	app.loader.main.animations.content.custom.custom_emote_input.FocusLost:Connect(function(ent)
		local s, err = pcall(function()
			if tonumber(app.loader.main.animations.content.custom.custom_emote_input.Text) == nil then app.loader.main.animations.content.custom.custom_emote_input.Text = app.loader.main.animations.content.custom.custom_emote_input.Text:gsub('%D+', '') end
			if tonumber(app.loader.main.animations.content.custom.custom_emote_input.Text) == nil then app.loader.main.animations.content.custom.custom_emote_input.Text = '' return end

			if ent then
				processing_animations_application_db = true
				app.loader.main.animations.content.apply.m.icon.img.Visible = false
				app.loader.main.animations.content.apply.m.icon.__quantum_spinner.Visible = true
				local m = is:LoadAsset(tonumber(app.loader.main.animations.content.custom.custom_emote_input.Text))
				local anim_id = m:FindFirstChildOfClass('Animation').AnimationId:gmatch('%d+')()
				app.loader.main.animations.content.custom.custom_anim_input.Text = tostring(anim_id)
				app.loader.main.animations.content.custom.custom_emote_input.Text = ''

				configs.animation_id = anim_id
				configs.animation_applied = true
				app.loader.main.animations.content.apply.m.icon.img.Visible = true
				app.loader.main.animations.content.apply.m.icon.__quantum_spinner.Visible = false
				app.loader.main.animations.content.apply.m.icon.img.Image = 'rbxassetid://14925004232'
				app.loader.main.animations.content.apply.m.label.Text = 'APPLIED'
				app.loader.main.content.top_buttons.animations.crc.Visible = true
				processing_animations_application_db = false
				debris:AddItem(m)
			end
		end)
		
		if not s then
			if err == 'Asset is not trusted for this place' then
				notifs:banner(widget, 'Could not load asset (ERROR1), are you sure this emote ID is correct?', 'error', 4)
			else
				notifs:banner(widget, 'Unexpected error when finding animation ID: '.. err, 'error')
			end
			
			app.loader.main.animations.content.apply.m.icon.img.Image = 'http://www.roblox.com/asset/?id=17298900001'
			app.loader.main.animations.content.apply.m.label.Text = 'APPLY'
			configs.animation_id = 0
			configs.animation_applied = false
			app.loader.main.animations.content.apply.m.icon.img.Visible = true
			app.loader.main.animations.content.apply.m.icon.__quantum_spinner.Visible = false
			app.loader.main.content.top_buttons.animations.crc.Visible = false
			app.loader.main.animations.content.custom.custom_anim_input.Text  = ''
		end
	end)
	
	app.loader.main.animations.content.apply.m.c.hitbox.MouseButton1Click:Connect(function()
		if processing_animations_application_db then return end
		
		if configs.animation_applied then
			processing_animations_application_db = true
			app.loader.main.animations.content.apply.m.icon.img.Visible = false
			app.loader.main.animations.content.apply.m.icon.__quantum_spinner.Visible = true
			task.wait(.1)
			configs.animation_applied = false
			app.loader.main.animations.content.apply.m.icon.img.Image = 'http://www.roblox.com/asset/?id=17298900001'
			app.loader.main.animations.content.apply.m.label.Text = 'APPLY'
			app.loader.main.animations.content.apply.m.icon.img.Visible = true
			app.loader.main.animations.content.apply.m.icon.__quantum_spinner.Visible = false
			app.loader.main.animations.content.custom.custom_anim_input.Text  = ''
			processing_animations_application_db = false
			app.loader.main.content.top_buttons.animations.crc.Visible = false
		else
			if configs.animation_id == 0 then
				notifs:banner(widget, 'No animation has been configured yet', 'warning')
				return
			end
			processing_animations_application_db = true
			app.loader.main.animations.content.apply.m.icon.img.Visible = false
			app.loader.main.animations.content.apply.m.icon.__quantum_spinner.Visible = true
			task.wait(.4)
			configs.animation_applied = true
			app.loader.main.animations.content.apply.m.icon.img.Image = 'rbxassetid://14925004232'
			app.loader.main.animations.content.apply.m.label.Text = 'APPLIED'
			app.loader.main.animations.content.apply.m.icon.img.Visible = true
			app.loader.main.animations.content.apply.m.icon.__quantum_spinner.Visible = false
			processing_animations_application_db = false
			app.loader.main.content.top_buttons.animations.crc.Visible = true
		end
	end)
	
	local function open__inspect()
		app.loader.main.inspect.content.CanvasPosition = Vector2.new(0,0)
		app.loader.main.content.Visible = false
		app.loader.main.insert_options.Visible = false

		app.loader.main.inspect.content.id.Text = configs.uid.. (configs.outfit_id ~= 0 and ': "'.. configs.outfit_name.. '"' or '')

		for _, v in pairs(app.loader.main.inspect.content.equipped_assets:GetChildren()) do
			if v:IsA('Frame') then
				v:Destroy()
			end
		end

		for _, v in pairs(app.loader.main.inspect.content.equipped_emotes:GetChildren()) do
			if v:IsA('Frame') then
				v:Destroy()
			end
		end

		for _, v in pairs(app.loader.main.inspect.content.scales_raw:GetChildren()) do
			if v:IsA('TextBox') then
				v:Destroy()
			end
		end

		for _, v in pairs(app.loader.main.inspect.content.bodycolor3s_raw:GetChildren()) do
			if v:IsA('TextBox') then
				v:Destroy()
			end
		end

		for _, v in pairs(app.loader.main.inspect.content.bodycolors_raw:GetChildren()) do
			if v:IsA('TextBox') then
				v:Destroy()
			end
		end

		app.loader.main.inspect.Visible = true


		for _, v in pairs(configs.assets) do
			local t = r.ui.asset:Clone()
			t.content.header.Text = v.name == '<unavailable>' and '' or v.name
			t.content.asset_type.Text = v.assetType.name
			t.content.asset_id.Text = v.id
			t.icon.img.Image = `rbxthumb://type=Asset&id={tostring(v.id)}&w=420&h=420`
			t.Parent = app.loader.main.inspect.content.equipped_assets
		end

		if configs.emotes then
			for _, v in pairs(configs.emotes) do
				local t = r.ui.asset:Clone()
				t.content.header.Text = v.assetName
				t.content.asset_type.Text = 'Emote'
				t.content.asset_id.Text = v.assetId
				t.icon.img.Image = `rbxthumb://type=Asset&id={tostring(v.assetId)}&w=420&h=420`
				t.Parent = app.loader.main.inspect.content.equipped_emotes
			end
		end


		if configs.scales then
			app.loader.main.inspect.content.header__scales.Visible = true

			for i, v in pairs(configs.scales) do
				local t = r.ui.raw_text_box:Clone()
				t.Text = `{i}: {tostring(v)}`
				--t.CursorPosition = string.len(i)+2
				t.Parent = app.loader.main.inspect.content.scales_raw
			end
		else
			app.loader.main.inspect.content.header__bodycolor3s.Visible = false
		end

		if configs.body_colour3s then
			app.loader.main.inspect.content.header__bodycolor3s.Visible = true			

			for i, v in pairs(configs.body_colour3s) do
				local t = r.ui.raw_text_box:Clone()
				t.Text = `{i}: {tostring(v)}`
				--t.CursorPosition = string.len(i)+2
				t.Parent = app.loader.main.inspect.content.bodycolor3s_raw
			end
		else
			app.loader.main.inspect.content.header__bodycolor3s.Visible = false
		end

		if configs.body_colours then
			app.loader.main.inspect.content.bodycolors_raw.Visible = true

			for i, v in pairs(configs.body_colours) do
				local t = r.ui.raw_text_box:Clone()
				t.Text = `{i}: {tostring(v)}`
				--t.CursorPosition = string.len(i)+2
				t.Parent = app.loader.main.inspect.content.bodycolors_raw
			end
		else
			app.loader.main.inspect.content.bodycolors_raw.Visible = false
		end
	end
	
	app.loader.main.content.top_buttons.inspect.hitbox.MouseButton1Click:Connect(open__inspect)
	
	app.loader.main.inspect.content.back.icon.hitbox.MouseButton1Click:Connect(function()
		app.loader.main.content.Visible = true
		app.loader.main.insert_options.Visible = true
		app.loader.main.inspect.Visible = false
	end)
	
		
	local function attempt_export()
		if configs.last_loaded_rig and configs.last_loaded_rig.Parent == workspace then
			selection:Set({configs.last_loaded_rig})
			gateway:Invoke('post', 'prompt_save_selection', {file_name = `lrc4_export__{configs.rig_type}_{configs.uid}{configs.outfit_id ~= 0 and '_'.. configs.outfit_name or ''}{configs.outfit_id ~= 0 and '_'.. tostring(configs.outfit_id) or ''}`})
		else
			app.loader.view.contain_view.viewport_padding.util['export'].button.ImageTransparency = 0.6
			app.loader.view.contain_view.viewport_padding.util['export'].button:SetAttribute('cursor', 'forbidden')
			notifs:banner(widget, 'Insert the character into the workspace before attempting to export', 'warning')
	end
		end
		
	app.loader.view.contain_view.viewport_padding.util['export'].button.MouseButton1Click:Connect(attempt_export)
	
	local function is_rbxm_valid_character(rbxm)
		if not rbxm or not rbxm.Tree or not rbxm.Tree[1] then return false end
		if #rbxm.Tree > 1 then return false end
		if rbxm.Tree[1].ClassName ~= 'Model' then return false end
		
		return true
	end
	
	local function attempt_import()
		local res = r.connect.plugin_gateway:Invoke("post", "prompt", {prompt_header = "Import Character [BETA]"; prompt_desc = "THIS FEATURE IS IN BETA AND IS MISSING SOME FUNCTIONALITY. IT MAY NOT WORK AS EXPECTED."; prompt_id = "IMPORTCHARACTERBETA"})

		if res ~= true then return end

		local rbxm:File = ss:PromptImportFile({'rbxm'})

		if rbxm then
			local rbxm_info = lxm(rbxm:GetBinaryContents())

			--print(rbxm_info)
			if not is_rbxm_valid_character(rbxm_info) then notifs:banner(widget, 'RBXM INVALID', 'error', 3) return end

			local name = rbxm_info.Tree[1].Properties.Name
			local id = -444
			if string.gmatch(name, '%a%d%d?_.*_%d+')() then
				id = string.gsub(name, '%a%d%d?_.*_', '')
				id = tonumber(id) or -444
			end

			local humanoid

			for _, v in pairs(rbxm_info.Tree[1].Children) do
				if v.ClassName == 'Humanoid' then
					humanoid = v
					break
				end
			end

			if not humanoid then notifs:banner(widget, 'RBXM INVALID: NO HUMANOID FOUND', 'error', 3) return end

			local desc_info

			for _, v in pairs(humanoid.Children) do
				if v.ClassName == 'HumanoidDescription' then
					desc_info = v
					break
				end
			end

			if not desc_info then notifs:banner(widget, 'RBXM INVALID: NO HUMANOIDDESCRIPTION FOUND', 'error', 3) return end

			local desc = Instance.new('HumanoidDescription')

			local emotes = {}
			local assets = {}

			for _, v in pairs(desc_info.Children) do
				local t = Instance.new(v.ClassName, desc)

				if v.ClassName == 'AccessoryDescription' then
					local enump = utils:get_enum_by_bit_thingy('AccessoryType', v.Properties.AccessoryType)

					table.insert(assets, {
						name = '<unavailable>';
						id = v.Properties.AssetId;
						currentVersionId = -1;
						assetType = {
							id = enump and enump.Value or -1;
							name = enump and enump.Name or 'Unknown';
						};
					})
				end

				for i, vv in pairs(v.Properties) do
					if i == 'SourceAssetId' or i == 'Tags' or (i == 'Instance' and typeof(i) ~= 'Instance' --[[doubt]]) or i == 'AttributesSerialize' or i == 'DefinesCapabilities' then continue end
					--if i:find('Type') or i =='BodyPart' then warn('skipping ', i) continue end
					if i == 'BodyPart' and v.ClassName == 'BodyPartDescription' then
						t[i] = utils:get_enum_by_bit_thingy('BodyPart', vv)	
					elseif i == 'AccessoryType' and v.ClassName == 'AccessoryDescription' then
						t[i] = utils:get_enum_by_bit_thingy('AccessoryType', vv)
					else
						--if i:find('Type') or i =='BodyPart' then warn('skipping ', i) t[i] = Enum.AccessoryType.Hair continue end
						t[i] = vv
					end
				end
			end

			for i, v in pairs(desc_info.Properties) do
				if i == 'EmotesDataInternal' then
					local items = {}
					for ee in string.gmatch(v, '([^%^]+)') do
						table.insert(items, ee)
					end
					--print(items)
					for ii = 1, #items, 2 do
						local name = items[ii]
						local id = items[ii+1]

						if id == nil or name == '\\' then break end
						table.insert(emotes, {
							assetId = tonumber(id);
							assetName = name:gsub('\\', '');
							position = -1;
						})
					end 
					continue
				elseif i:find('Animation') and v ~= 0 then
					if i == 'MoodAnimation' then
						table.insert(assets, {
							name = '<unavailable>';
							id = v;
							assetType = {
								id = 78;
								name = 'MoodAnimation';
							};
						})
					else
						table.insert(assets, {
							name = '<unavailable>';
							id = v;
							assetType = {
								id = 24;
								name = 'Animation';
							};
						})
					end
				end
				if i:find('Internal') or i:find('Source') or i == 'AttributesSerialize' or i == 'Tags' or i == 'AccessoryRigidAndLayeredBlob' or i == 'DefinesCapabilities' then continue end

				desc[i] = v
			end

			if desc.GraphicTShirt ~= 0 then
				table.insert(assets, {
					name = '<unavailable>';
					id = desc.GraphicTShirt;
					assetType = {
						id = 2;
						name = 'TShirt'
					};
				})
			end

			if desc.Shirt ~= 0 then
				table.insert(assets, {
					name = '<unavailable>';
					id = desc.Shirt;
					assetType = {
						id = 11;
						name = 'Shirt'
					};
				})
			end

			if desc.Pants ~= 0 then
				table.insert(assets, {
					name = '<unavailable>';
					id = desc.Pants;
					assetType = {
						id = 12;
						name = 'Pants'
					};
				})
			end

			if desc.Face ~= 0 then table.insert(assets, { name = '<unavailable>'; id = desc.Face; assetType = { id = 18; name = 'Face'; }; }) end
			if desc.Head ~= 0 then table.insert(assets, { name = '<unavailable>'; id = desc.Head; assetType = { id = 17; name = 'Head'; }; }) end
			if desc.LeftArm ~= 0 then table.insert(assets, { name = '<unavailable>'; id = desc.LeftArm; assetType = { id = 29; name = 'LeftArm'; }; }) end
			if desc.LeftLeg ~= 0 then table.insert(assets, { name = '<unavailable>'; id = desc.LeftLeg; assetType = { id = 30; name = 'LeftLeg'; }; }) end
			if desc.RightArm ~= 0 then table.insert(assets, { name = '<unavailable>'; id = desc.RightArm; assetType = { id = 28; name = 'RightArm'; }; }) end
			if desc.RightLeg ~= 0 then table.insert(assets, { name = '<unavailable>'; id = desc.RightLeg; assetType = { id = 31; name = 'RightLeg'; }; }) end
			if desc.Torso ~= 0 then table.insert(assets, { name = '<unavailable>'; id = desc.Torso; assetType = { id = 27; name = 'Torso'; }; }) end

			local has_lower_torso = false

			for _, v in pairs(rbxm_info.Tree[1].Children) do
				if v.Properties and v.Properties.Name == 'LowerTorso' then has_lower_torso = true break end
			end

			--desc.Parent = game.ServerScriptService

			loader:open(widget, typeof(id) == 'number' and id or -444, nil, nil, {is_local = true; cai = {
				assets = assets;
				bodyColor3s = {};
				bodyColors = {};
				defaultPantsApplied = false;
				defaultShirtApplied = false;
				emotes = emotes;
				playerAvatarType = has_lower_torso and 'R15' or 'R6';
			}::any; humanoid_desc = desc;})
		end
	end
	
	app.loader.view.contain_view.viewport_padding.util['import'].button.MouseButton1Click:Connect(attempt_import)
	
	local function toggle_3drotate()
		prefarotate = not prefarotate
		pvfr:pref__auto_rotate(prefarotate)
		if prefarotate then
			app.loader.view.contain_view.viewport_padding.viewutil['3drotate'].button.ImageTransparency = 0
		else
			app.loader.view.contain_view.viewport_padding.viewutil['3drotate'].button.ImageTransparency = 0.4
		end
	end
	
	local function toggle_3d()
		
		if app.loader.view.contain_view.viewport_padding.viewport.Visible then
			configs.overwrite_3d_preview_pref = false
			app.loader.view.contain_view.viewport_padding.viewport.Visible = false
			app.loader.view.contain_view.viewport_padding.fallback.Visible = true
			app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button.ImageTransparency = 0.4
			app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button.Image = 'http://www.roblox.com/asset/?id=92043778278910'
		else
			configs.overwrite_3d_preview_pref = true
			app.loader.view.contain_view.viewport_padding.preload.Visible = true
			app.loader.view.contain_view.viewport_padding.fallback.Visible = false
			app.loader.view.contain_view.viewport_padding.viewport.Visible = false
			if not configs.viewport_active_rig then upd_viewport_model_async(widget) end
			if not configs.viewport_active_rig then notifs:banner(widget, 'A 3D preview is not available right now for this character', 'warning')
				app.loader.view.contain_view.viewport_padding.preload.Visible = false
				app.loader.view.contain_view.viewport_padding.fallback.Visible = true
			return end
			app.loader.view.contain_view.viewport_padding.viewport.Visible = true
			app.loader.view.contain_view.viewport_padding.fallback.Visible = false
			app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button.ImageTransparency = 0
			app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button.Image = 'http://www.roblox.com/asset/?id=122051953862388'
		end
	end
	
	app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button.MouseButton1Click:Connect(toggle_3d)
	app.loader.view.contain_view.viewport_padding.viewutil['3drotate'].button.MouseButton1Click:Connect(toggle_3drotate)
	
	app.loader.main.content.top_buttons.expand.hitbox.MouseButton1Click:Connect(function()
		if configs.rig_type == 'R6' then
			local res = gateway:Invoke("get", "expand_context_menu_noanim")

			if res:find('lrc4%-ecmna%-otf') then
				open__outfits()
			elseif res:find('lrc4%-ecmna%-isp') then
				open__inspect()
			end
		else
			local res = gateway:Invoke("get", "expand_context_menu")
					
			if res:find('lrc4%-ecm%-otf') then
				open__outfits()
			elseif res:find('lrc4%-ecm%-anm') then
				open__animations()
			elseif res:find('lrc4%-ecm%-isp') then
				open__inspect()
			end
		end
	end)
	
	app.loader.view.contain_view.viewport_padding.expand.expand.button.MouseButton1Click:Connect(function()
		local res = gateway:Invoke("get", "expand_viewport_utils_context_menu")
		
		if res:find('lrc4%-evucm%-rfs') then
			loader:open(widget, configs.uid, nil, true)
		elseif res:find('lrc4%-evucm%-tvp') then
			toggle_3d()
		elseif res:find('lrc4%-evucm%-tvr') then
			toggle_3drotate()
		elseif res:find('lrc4%-evucm%-exp') then
			attempt_export()
		elseif res:find('lrc4%-evucm%-imp') then
			attempt_import()
		elseif res:find('lrc4%-evucm%-bkm') then
			toggle_bookmark()
		end
	end)
	
	app.loader.view.contain_view.viewport_padding.util2.refresh.button.MouseButton1Click:Connect(function()
		loader:open(widget, configs.uid, nil, true)
	end)
	
	r.connect.slider_opt.Event:Connect(function(sn, val)
		if sn == "option__auto_update" then
			configs.auto_update = val
		elseif sn == "option__inspectable" then
			configs.inspectable = val
		elseif sn == "option__pushable" then
			configs.pushable = val
		elseif sn == "option__nametag" then
			configs.nametag = val
			app.loader.main.content.options.option__health.__slider:SetAttribute("enabled", val)
			if not val then
				app.loader.main.content.options.option__health.__slider:SetAttribute("state", true)
			else
				app.loader.main.content.options.option__health.__slider:SetAttribute("state", configs.disable_health_display)
			end
		elseif sn == "option__health" then
			configs.disable_health_display = val
		elseif sn == "option__disable_auto_scale" then
			configs.disable_automatic_scaling = val
		elseif sn == "option__animation__override" then
			configs.set_animation_action4 = val
		elseif sn == "option__locked" then
			configs.locked = val
		elseif sn == "option__remove_packages" then
			configs.remove_packages = val
		elseif sn == "option__default_scale" then
			configs.ignore_body_scale = val
		end
	end)
end

function loader:open(widget:DockWidgetPluginGui, uid, usi, __disable_automatic_frame_switching:boolean?, info:{cai:{any}, is_local:boolean; humanoid_desc:HumanoidDescription?}?)
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end
	app.loader.null_select.Visible = false
	
	if not uid or not (type(uid) == "number") then return end
	
	local s, err = pcall(function()
		c(cursors.busy)
		app.loader.view.Visible = false
		app.loader.main.Visible = false
		app.loader.main.outfits.Visible = false
		app.loader.main.animations.Visible = false
		app.loader.main.inspect.Visible = false
		app.loader.main.content.Visible = true
		app.loader.preload.Visible = true
		app.loader.preload.__loader.m.GroupTransparency = 0
		app.loader.view.contain_view.viewport_padding.util.colours.button.Visible = false
		app.loader.view.contain_view.viewport_padding.util.colours.__quantum_spinner.Visible = true
		app.loader.view.contain_view.viewport_padding.util['export'].button.ImageTransparency = 0.6
		app.loader.view.contain_view.viewport_padding.util['export'].button:SetAttribute('cursor', 'forbidden')
		app.loader.view.contain_view.viewport_padding.util.bookmark.Visible = true
		app.loader.main.content.top_buttons.outfits.Visible = true
		app.loader.main.content.options.CanvasPosition = Vector2.new(0,0)
		app.loader.preload.__loader:SetAttribute("completion", 20)
		if not __disable_automatic_frame_switching then nav.__swtich:Fire(app.loader) end
		prefarotate = true
		pvfr:pref__auto_rotate(true)
		app.loader.view.contain_view.viewport_padding.viewutil['3drotate'].button.ImageTransparency = 0
		app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button.ImageTransparency = 0
		app.loader.view.contain_view.viewport_padding.viewutil['3dtoggle'].button.Image = 'http://www.roblox.com/asset/?id=122051953862388'
		app.loader.view.contain_view.viewport_padding.fallback.Visible = false
		app.loader.view.contain_view.viewport_padding.viewport.Visible = false
		app.loader.view.contain_view.viewport_padding.preload.Visible = true
		app.loader.main.insert_options.insert_magic.Visible = true
		configs.uid = uid
		configs.outfit_id = 0
		configs.outfit_name = ""
		configs.animation_id = 0
		configs.animation_applied = false
		configs.set_animation_action4 = false
		configs.last_loaded_rig = nil
		configs.emotes = {}
		configs.assets = {}
		configs.root_assets = {}
		configs.local_req_info.humanoid_desc = {}
		configs.local_req_info.cai = {}
		configs.is_local = false
		configs.overwrite_3d_preview_pref = false
		
		if info and info.is_local then
			configs.is_local = true
			configs.local_req_info.cai = info and info.cai or nil
			configs.local_req_info.humanoid_desc = info and info.humanoid_desc or nil
			app.loader.view.contain_view.viewport_padding.util.bookmark.Visible = false
			--app.loader.main.content.top_buttons.outfits.Visible = false
			ts:Create(app.loader.main.content.top_buttons.outfits.icon, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 0.4}):Play()
			app.loader.main.content.top_buttons.outfits.hitbox:SetAttribute('cursor', 'forbidden')
			
			if info.humanoid_desc and info.cai and info.cai.scales then
				info.cai.scales = {
					bodyType = info.humanoid_desc.BodyTypeScale;
					depth = info.humanoid_desc.DepthScale;
					head = info.humanoid_desc.HeadScale;
					height = info.humanoid_desc.HeightScale;
					proportion = info.humanoid_desc.ProportionScale;
					width = info.humanoid_desc.WidthScale;
				}
			end
			
			if info.humanoid_desc and info.cai and info.cai.bodyColor3s then
				info.cai.bodyColor3s = {
					headColor3 = info.humanoid_desc.HeadColor;
					leftArmColor3 = info.humanoid_desc.LeftArmColor;
					leftLegColor3 = info.humanoid_desc.LeftLegColor;
					rightArmColor3 = info.humanoid_desc.RightArmColor;
					rightLegColor3 = info.humanoid_desc.RightLegColor;
					torsoColor3 = info.humanoid_desc.TorsoColor;
				}
			end
			
			if info.humanoid_desc and info.cai and info.cai.bodyColors then
				info.cai.bodyColors = {
					headColor3 = BrickColor.new(info.humanoid_desc.HeadColor).Number;
					leftArmColor3 = BrickColor.new(info.humanoid_desc.LeftArmColor).Number;
					leftLegColor3 = BrickColor.new(info.humanoid_desc.LeftLegColor).Number;
					rightArmColor3 = BrickColor.new(info.humanoid_desc.RightArmColor).Number;
					rightLegColor3 = BrickColor.new(info.humanoid_desc.RightLegColor).Number;
					torsoColor3 = BrickColor.new(info.humanoid_desc.TorsoColor).Number;
				}
			end
		end
		app.loader.main.animations.content.custom.custom_anim_input.Text = ''
		app.loader.main.animations.content.custom.custom_emote_input.Text = ''
		app.loader.main.animations.content.apply.m.icon.img.Image = 'http://www.roblox.com/asset/?id=17298900001'
		app.loader.main.animations.content.apply.m.label.Text = 'APPLY'
		app.loader.main.animations.content.option__animation__override.__slider:SetAttribute('state', false)
		app.loader.main.content.top_buttons.animations.crc.Visible = false
		app.loader.main.content.options.option__inspectable.__slider:SetAttribute("enabled", true)
		app.loader.main.content.options.option__auto_update.__slider:SetAttribute("enabled", true)
		app.loader.main.content.options.option__inspectable.__slider:SetAttribute("state", configs.inspectable)
		app.loader.main.content.options.option__auto_update.__slider:SetAttribute("state", configs.auto_update)
		
		if table.find(gateway:Invoke("get","setting",{setting_name="bookmarked"}) or {}, configs.uid) then
			app.loader.view.contain_view.viewport_padding.util.bookmark.button.Image = "http://www.roblox.com/asset/?id=17261520172" --remove
		else
			app.loader.view.contain_view.viewport_padding.util.bookmark.button.Image = "http://www.roblox.com/asset/?id=17261516757" --add
		end

		usi = usi or us:GetUserInfosByUserIdsAsync({uid})[1]
		app.loader.preload.__loader:SetAttribute("completion", 40)
		if usi == {} or usi == nil then if uid == -444 then usi = {DisplayName = '_LOCAL'; HasVerifiedBadge = true; Id = -444; Username = '_LOCAL'} else error("[handled]User info is not available. Is the user terminated or hidden?") end end
		
		if usi == {} or usi == nil or uid == -444 then
			app.loader.view.contain_view.viewport_padding.util2.refresh.Visible = false
		else
			app.loader.view.contain_view.viewport_padding.util2.refresh.Visible = true
		end
		
		local recently_viewed = gateway:Invoke("get","setting",{setting_name="recently_viewed"}) or {}
		if table.find(recently_viewed, {id = configs.uid; n = usi.Username; v = usi.HasVerifiedBadge;}) then
			table.remove(recently_viewed,table.find(recently_viewed, {id = configs.uid; n = usi.Username; v = usi.HasVerifiedBadge;}))
		end
		table.insert(recently_viewed, 1, {id = configs.uid; n = usi.Username; v = usi.HasVerifiedBadge;})
		if #recently_viewed >= 90 then recently_viewed[90] = nil end
		
		gateway:Invoke("post","setting",{setting_name="recently_viewed", target = recently_viewed})


		local name = usi.Username
		local display_name = usi.DisplayName
		local is_verified = usi.HasVerifiedBadge --or (uid == 655331725)
		local burst = players:GetUserThumbnailAsync(uid ~= -444 and uid or 1, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size352x352)
		local headshot = players:GetUserThumbnailAsync(uid ~= -444 and uid or 1, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size352x352)
		local thumbnail = players:GetUserThumbnailAsync(uid ~= -444 and uid or 1, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
		app.loader.preload.__loader:SetAttribute("completion", 60)

		local cai = info and info.cai or players:GetCharacterAppearanceInfoAsync(uid)
		app.loader.preload.__loader:SetAttribute("completion", 80)

		app.loader.view.info.basic_identity.headshot.img.Image = headshot
		app.loader.view.contain_view.viewport_padding.fallback.Image = thumbnail
		app.loader.main.outfits.content.current.burst.img.Image = burst
		
		if gateway:Invoke("get","setting",{setting_name="compact_identical_names"}) ~= false then
			if display_name == name then
				app.loader.view.info.basic_identity.basic_identity_string.Text = `{name}{is_verified and ""  or ""}`
			else
				app.loader.view.info.basic_identity.basic_identity_string.Text = `<font weight="600">{display_name}</font>{if is_verified then "" else ""} <font transparency="0.2" weight="500">@{name}</font>`
			end
		else
			app.loader.view.info.basic_identity.basic_identity_string.Text = `<font weight="600">{display_name}</font>{if is_verified then "" else ""} <font transparency="0.2" weight="500">@{name}</font>`
		end
		
		app.loader.main.content.id.Text = tostring(uid)
		app.loader.main.content.id.switch.Position = UDim2.new(0,app.loader.main.content.id.TextBounds.X+4,0,0)
		if app.loader.view.contain_view.viewport_padding.viewport:FindFirstChildOfClass("Model") then app.loader.view.contain_view.viewport_padding.viewport:FindFirstChildOfClass("Model"):Destroy() end

		--local constructed_humanoid_model = players:CreateHumanoidModelFromUserId(uid)

		if cai.playerAvatarType == "R6" then
			--print("r6")
			configs.rig_type = "R6"
			configs.root_rig_type = "R6"
			configs.origin_rig_type = "R6"
			ts:Create(app.loader.main.content.top_buttons.R6, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(42, 100, 246)}):Play()
			ts:Create(app.loader.main.content.top_buttons.R15, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play()
			app.loader.main.content.top_buttons.animations.icon.ImageTransparency = 0.4
			app.loader.main.content.top_buttons.animations.hitbox:SetAttribute('cursor', 'forbidden')
			app.loader.main.content.options.option__default_scale.__slider:SetAttribute("enabled", false)
		elseif cai.playerAvatarType == "R15" then
			--print("r15")
			configs.rig_type = "R15"
			configs.root_rig_type = "R15"
			configs.origin_rig_type = "R15"
			ts:Create(app.loader.main.content.top_buttons.R6, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play()
			ts:Create(app.loader.main.content.top_buttons.R15, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(42, 100, 246)}):Play()
			app.loader.main.content.top_buttons.animations.icon.ImageTransparency = 0
			app.loader.main.content.top_buttons.animations.hitbox:SetAttribute('cursor', 'hover')
			app.loader.main.content.options.option__default_scale.__slider:SetAttribute("enabled", true)
		else
			error("unknown avatar type")
		end
		
		if not configs.nametag then
			app.loader.main.content.options.option__health.__slider:SetAttribute("enabled", false)
		else
			app.loader.main.content.options.option__health.__slider:SetAttribute("enabled", true)
		end

		for _, v in pairs(app.loader.view.contain_view.viewport_padding.viewport.wm:GetChildren()) do
			if v:IsA('Model') then
				v:Destroy()
			end
		end

		
		upd_viewport_model_async(widget)
		
		-- roblos
		--app.loader.view.contain_view.viewport_padding.viewport.Visible = false
		--app.loader.view.contain_view.viewport_padding.fallback.Visible = true
		
		if info and info.is_local then
			app.loader.main.content.id.Text = 'LOCAL'
			app.loader.main.insert_options.insert_magic.Visible = false
			if uid ~= -444 then app.loader.main.content.id.Text = 'LOCAL ('.. tostring(uid).. ')' end
			app.loader.view.info.basic_identity.basic_identity_string.Text = `Imported Character`
			app.loader.view.info.basic_identity.headshot.img.Image = ''
			app.loader.view.contain_view.viewport_padding.fallback.Image = ''
			app.loader.main.outfits.content.current.burst.img.Image = ''
			app.loader.main.content.options.option__auto_update.__slider:SetAttribute("enabled", false)
			app.loader.main.content.options.option__auto_update.__slider:SetAttribute("state", false)
		end
		
		if cai.bodyColors then
			app.loader.view.contain_view.viewport_padding.util.colours.button.Visible = true
			app.loader.view.contain_view.viewport_padding.util.colours.__quantum_spinner.Visible = false
			configs.body_colours = cai.bodyColors
			configs.body_colour3s = cai.bodyColor3s
		end
		
		if cai.emotes then
			configs.emotes = cai.emotes
		end
		
		if cai.assets then
			configs.assets = cai.assets
			configs.root_assets = cai.assets
		end
		
		if cai.scales then
			configs.scales = cai.scales
		end

		app.loader.preload.__loader:SetAttribute("completion", 100)
		ts:Create(app.loader.preload.__loader.m, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {GroupTransparency = 1}):Play()
		app.loader.view.Visible = true
		app.loader.main.Visible = true
		app.loader.main.insert_options.Visible = true
		app.loader.main.content.Visible = true
		--vr:Enable(app.loader.view.contain_view.viewport_padding.viewport)
		--if rig and rig.Parent then pvfr:enable(app.loader.view.contain_view.viewport_padding.viewport, rig, widget) end
		task.wait(.25)
		app.loader.preload.Visible = false
		c(cursors.default)
	end)
	
	if not s then
		c(cursors.default)
		notifs:banner(widget, "An error occured while loading the editor: "..err:gsub("%[handled%]",""), "error", 0)
		if not err:find("[handled]") then
			warn("LRC4 unhandled error: " .. err)
		end
	end
end

return loader