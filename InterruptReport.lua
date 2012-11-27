-- InterruptReport
-- By Sadiniel <Dispel Stupid> of Garona-US

local IRversion = GetAddOnMetadata("InterruptReport", "Version");
local InterruptReport = CreateFrame("Frame", "InterruptReport");
local SPELL_LIST = {	-- Cataclysm
						"Arcane Annihilator", 	-- Arcanotron, Omnotron Defense System, Blackwing Descent
						"Arcane Storm",			-- Maloriak, Blackwing Descent
						"Blast Nova",			-- Chromatic Prototype, Nefarian, Blackwing Descent
						"Shadow Nova", 			-- Halfus Wyrmbreaker, Bastion of Twilight (Only if Storm Rider is active)
						"Hydro Lance", 			-- Feludius, Ascendant Council, Bastion of Twilight
						"Depravity",			-- Corrupting Adherent, Cho'gall, Bastion of Twilight
						"Fiery Web Spin",		-- Cinderweb Spinner (Heroic), Beth'tilac, Firelands
						"Fieroblast",			-- Blazing Talon Initiate, Alysrazor, Firelands
						-- Mists of Pandaria
						"Shadow Blast",			-- Tian Dreadshadow, The Spirit Emperors, Mogu'shan Vaults
						"Lightning Bolt",		-- Elder Regail, Protectors of the Endless, Terrace of the Endless Spring
						"Water Bolt",			-- Elder Asani, Protectors of the Endless, Terrace of the Endless Spring
						}

function InterruptReport_Config()

	-- This is to set up the options window.
	
	InterruptReportOptions = CreateFrame("Frame", "InterruptReportOptionPanel", UIParent);
	InterruptReportOptions.name = "InterruptReport";
	InterfaceOptions_AddCategory(InterruptReportOptions);

	InterruptReportOptions.title = InterruptReportOptions:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	InterruptReportOptions.title:SetText("InterruptReport Options");
	InterruptReportOptions.title:SetPoint("TOPLEFT", InterruptReportOptions,"TOPLEFT" , 10, -15);

	InterruptReportOptions.EnabledCheck = CreateFrame("CheckButton", "EnabledCheck", InterruptReportOptions, "InterfaceOptionsCheckButtonTemplate");
	EnabledCheckText:SetText("Enable this addon.");
	InterruptReportOptions.EnabledCheck:SetPoint("TOPLEFT", InterruptReportOptions, "TOPLEFT", 15, -50);
	
	InterruptReportOptions.NoDamageCheck = CreateFrame("CheckButton", "NoDamageCheck", InterruptReportOptions, "InterfaceOptionsCheckButtonTemplate");
	NoDamageCheckText:SetText("Annunce Interrupts when all casts interrupted.");
	InterruptReportOptions.NoDamageCheck:SetPoint("TOPLEFT", InterruptReportOptions, "TOPLEFT", 30, -80);
	
	ChannelMenu = CreateFrame("Frame", "AnnounceChannel", InterruptReportOptions, "UIDropDownMenuTemplate");
	ChannelMenu:SetPoint("TOPLEFT", InterruptReportOptions, "TOPLEFT" , 30, -110);
	ChannelMenu_OnEvent(ChannelMenu);
		
	InterruptReportOptions.AnnounceChannelText = InterruptReportOptions:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	InterruptReportOptions.AnnounceChannelText:SetText("Announcement Channel");
	InterruptReportOptions.AnnounceChannelText:SetPoint("TOPLEFT", InterruptReportOptions,"TOPLEFT" , 190, -117);
	
	InterruptReportOptions.okay = function (self) InterruptReport_Okay(); end;
	InterruptReportOptions.cancel = function (self) InterruptReport_Cancel(); end;
	InterruptReportOptions.default = function (self) InterruptReport_Default(); end;
end

function ChannelMenu_OnEvent(self, event, ...)
	
	local value = InterruptReportConfig.ANNOUNCE_CHANNEL;
	self.defaultValue = "group";
	self.oldValue = value;
	self.value = self.oldValue or self.defaultValue;
	
	UIDropDownMenu_Initialize(self, ChannelMenu_Initialize);
	UIDropDownMenu_SetSelectedValue(self, value);

	self.SetValue = 
		function (self, value)
			self.value = value;
			UIDropDownMenu_SetSelectedValue(self, value);
		end
	self.GetValue =
		function (self)
			return UIDropDownMenu_GetSelectedValue(self);
		end
	self.RefreshValue =
		function (self)
			UIDropDownMenu_Initialize(self, ChannelMenu_Initialize);
			UIDropDownMenu_SetSelectedValue(self, self.value);
		end

end

function ChannelMenu_OnClick( self )
	
	ChannelMenu:SetValue(self.value);

end

function ChannelMenu_Initialize(self)
	
	-- Making the DropDownBox List for the Channel Menu.
	
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();
	
	info.text = "Self";
	info.func = ChannelMenu_OnClick;
	info.value = "self";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = "Self";
	info.tooltipText = "Display to the Chat frame without announcing";
	UIDropDownMenu_AddButton(info);
	
	info.text = "Group";
	info.func = ChannelMenu_OnClick;
	info.value = "raid";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = "Group";
	info.tooltipText = "Announce to the /Party or /Raid chat channel";
	UIDropDownMenu_AddButton(info);
	
	info.text = "Guild";
	info.func = ChannelMenu_OnClick;
	info.value = "guild";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = "Guild";
	info.tooltipText = "Announce to the /Guild chat channel";
	UIDropDownMenu_AddButton(info);
	
end

function InterruptReport_Okay()

	-- When you click that little "Okay" button in the options window
	-- the game saves that information to your Saved Variables
	
	InterruptReportConfig.ENABLED = EnabledCheck:GetChecked();
	InterruptReportConfig.NO_DAMAGE = NoDamageCheck:GetChecked();
	InterruptReportConfig.ANNOUNCE_CHANNEL = UIDropDownMenu_GetSelectedValue(ChannelMenu);
    
end

function InterruptReport_Cancel()

	-- When you click that little "Cancel" button in the options window
	-- the game replaces the information in the window with your Saved Variables
	
	EnabledCheck:SetChecked(InterruptReportConfig.ENABLED);
	NoDamageCheck:SetChecked(InterruptReportConfig.NO_DAMAGE);
	ChannelMenu:SetValue(InterruptReportConfig.ANNOUNCE_CHANNEL);
	ChannelMenu:RefreshValue();
	
end

function InterruptReport_Default()

	-- When you click that little "Cancel" button in the options window
	-- the game replaces the information in the window with your Saved Variables
	
	EnabledCheck:SetChecked(nil);
	NoDamageCheck:SetChecked(nil);
	ChannelMenu:SetValue("raid");
	ChannelMenu:RefreshValue();
	
end

function InterruptReport_OnLoad(self)

	-- Version message for the chat window and registering events
	
	-- ChatFrame1:AddMessage("InterruptReport version " .. IRversion .. " loaded.", .9, 0, .9);
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("CHAT_MSG_ADDON");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	
	-- If we don't have a Saved Variables entry, we will after this
	-- Saved variables are by character so if you just want to announce on certain ones you can.
	
	if	(InterruptReportConfig == nil) then InterruptReportConfig = {}; end
	if	(InterruptReportConfig.ANNOUNCE_CHANNEL == nil) then InterruptReportConfig.ANNOUNCE_CHANNEL = "self"; end
	
	-- Everyone loves /commands, so much more convenient than clicking
	-- 40 buttons to find the options window.
	
	SlashCmdList["INTERRUPTREPORT"] = InterruptReport_SlashCommand;
	SLASH_INTERRUPTREPORT1 = "/irep"
	SLASH_INTERRUPTREPORT2 = "/ireport"
	SLASH_INTERRUPTREPORT3 = "/intrep"
	SLASH_INTERRUPTREPORT4 = "/intreport"
	SLASH_INTERRUPTREPORT5 = "/interruptreport"
	
end

function InterruptReport_SlashCommand()

	-- The only thing I do with the /command is open the options window
	-- Talk about being lazy.
	
	InterfaceOptionsFrame_OpenToCategory(InterruptReportOptions);
end

function InterruptReport_NumberFormat(number)

	-- recursive number formatting, sure I could have used a for or while loop, but where's the fun in that.
	
	local returnval;
	
	if ( number > 999 ) then
		returnval = InterruptReport_NumberFormat(floor(number/1000));
		number = format(",%03i", number % 1000);
	else
		returnval = "";
	end
	
	return ( returnval .. number );
end

function InterruptReport_Announce(self)

	-- This section actually makes the announcements to chat and sends announcement notification
	-- over the addon channel to prevent others using the addon from repeating the announcement
	
	local channel = InterruptReportConfig.ANNOUNCE_CHANNEL;
	local timesortime = " times.";
	
	if ( ( InterruptReportConfig.DAMAGE_TAKEN ) or ( ( #InterruptReportConfig.INTERRUPT_LIST > 1 ) and ( InterruptReportConfig.NO_DAMAGE ) ) ) then
		
		if ( InterruptReportConfig.DAMAGE_TAKEN == nil ) then InterruptReportConfig.DAMAGE_TAKEN = 0; end
		
		local formattednumber = InterruptReport_NumberFormat(InterruptReportConfig.DAMAGE_TAKEN);
		
		-- This is a hack for Water Bolt and Lightning Bolt which both occur during the Protectors of The Endless fight
		if ( ( InterruptReportConfig.DAMAGE_SPELL == "Water Bolt" ) or ( InterruptReportConfig.DAMAGE_SPELL == "Lightning Bolt" ) ) then
			InterruptReportConfig.DAMAGE_SPELL = "Lightning Bolt and Water Bolt";
		end
		
		if ( channel == "self" ) then
			ChatFrame1:AddMessage( formattednumber .. " damage taken from " .. InterruptReportConfig.DAMAGE_SPELL .. ".", .9, .9, .9);
		else
			if ( InterruptReportConfig.REPORTED == nil ) then
				SendChatMessage( formattednumber .. " damage taken from " .. InterruptReportConfig.DAMAGE_SPELL .. ".", channel , nil , nil );
			end
		end
	
		for i=1, #InterruptReportConfig.INTERRUPT_LIST, 2 do
			if ( InterruptReportConfig.INTERRUPT_LIST[i+1] > 1 ) then
				timesortime = " times.";
			else
				timesortime = " time."
			end
			
			if ( channel == "self") then
				ChatFrame1:AddMessage(	InterruptReportConfig.INTERRUPT_LIST[i] .. " interrupted " ..
										InterruptReportConfig.INTERRUPT_LIST[i+1] .. timesortime , .9, .9, .9);
			else
				if ( InterruptReportConfig.REPORTED ) then
					-- ChatFrame1:AddMessage( InterruptReportConfig.REPORTED .. " already announced damage and interrupts." , .9, 0, .9);
				else
					SendChatMessage(	InterruptReportConfig.INTERRUPT_LIST[i] .. " interrupted " ..
										InterruptReportConfig.INTERRUPT_LIST[i+1] .. timesortime , channel , nil , nil );
					SendAddonMessage( "InterruptReport" , UnitName("player") , channel , nil);
				end
			end
		end
	end
	
	-- ChatFrame1:AddMessage( "Combat Ended." , .9, 0, .9); -- debug
	
	InterruptReportConfig.REPORTED = nil;
	InterruptReportConfig.NEXT_CHECK = nil;
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	
	InterruptReportConfig.DAMAGE_TAKEN = nil;
	InterruptReportConfig.DAMAGE_SPELL = nil;
	wipe(InterruptReportConfig.INTERRUPT_LIST);
	
end

function InterruptReport_CombatCheck(self)
	
	local combat = false;
	local raidmembers = GetNumRaidMembers();
	
	for i = 1, raidmembers do
		local unitname = GetRaidRosterInfo(i);
		if ( unitname ) then
			if ( UnitAffectingCombat(unitname) ) then
				combat = true;
			end
		end
	end
	
	if ( combat == false ) then
		InterruptReport_Announce(self);
	end
	
end

function InterruptReport_OnEvent(self, event, ...)

	-- Event catching:
	
	if	( event == "PLAYER_LOGIN" ) then
		
		-- Setting up the otions window has to be done before the game starts up the UI
		-- I chose to do it at login although there are a couple of other choices

		InterruptReport_Config();
	
		-- We use the options window '_Cancel()' function to fill in the addon options window
		-- from the saved variables file before we see it
	
		InterruptReport_Cancel();
		
		ChatFrame1:AddMessage("InterruptReport version " .. IRversion .. " loaded.", .9, 0, .9);
	
	elseif	( ( event == "CHAT_MSG_ADDON" ) and ( select(1, ...) == "InterruptReport" ) ) then
		
		-- If someone announces before you their addon tells yours name of the target they
		-- looted to prevent yours from announcing it too.
		
		InterruptReportConfig.REPORTED = select(2, ...);
	
	elseif	( event == "PLAYER_REGEN_DISABLED" ) then
	
		InterruptReportConfig.REPORTED = nil;
	
		if	( InterruptReportConfig.ENABLED ) then
				
			if	( UnitInRaid("player") ) then
				
				-- ChatFrame1:AddMessage( "Combat Started." , .9, 0, .9); -- debug
				
				self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
				if	(InterruptReportConfig.INTERRUPT_LIST == nil) then InterruptReportConfig.INTERRUPT_LIST = {}; end
				
			end
			
		end
			
	elseif	( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
	
		local timestamp, logtype, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, -- arg1  to arg11
		spellId, spellName, spellSchool, -- arg12  to arg14
		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ... ; -- arg15 to arg23
		
		if ( logtype == "SPELL_DAMAGE" ) then
		
			if ( tContains(SPELL_LIST, spellName) ) then
			
				-- debug
				-- ChatFrame1:AddMessage( spellName .. " hit " .. destName .. " for " .. amount .. ". ( " .. resisted .. " resisted / " .. absorbed .. " absorbed. )" , .9, 0, .9);
		
				if ( InterruptReportConfig.DAMAGE_TAKEN == nil ) then InterruptReportConfig.DAMAGE_TAKEN = 0; end
				if ( amount == nil ) then amount = 0; end
				
				-- InterruptReportConfig.DAMAGE_SPELL = GetSpellLink(spellId);
				InterruptReportConfig.DAMAGE_SPELL = "\124cff71d5ff\124Hspell:" .. spellId .. "\124h[" .. spellName .. "]\124h\124r";
				InterruptReportConfig.DAMAGE_TAKEN = InterruptReportConfig.DAMAGE_TAKEN + amount;
				
			end
			
		end
		
		if ( logtype == "SPELL_INTERRUPT" ) then
		
			if ( tContains(SPELL_LIST, overkill) ) then

				-- ChatFrame1:AddMessage( overkill .. " was interrupted by " .. sourceName , .9, 0, .9); -- debug
				-- InterruptReportConfig.DAMAGE_SPELL = overkill;
				InterruptReportConfig.DAMAGE_SPELL = "\124cff71d5ff\124Hspell:" .. amount .. "\124h[" .. overkill .. "]\124h\124r";
				
				if ( tContains(InterruptReportConfig.INTERRUPT_LIST, sourceName) ) then
					local n = 1;
					while InterruptReportConfig.INTERRUPT_LIST[n] do
						if ( InterruptReportConfig.INTERRUPT_LIST[n] == sourceName ) then
							InterruptReportConfig.INTERRUPT_LIST[n+1] = InterruptReportConfig.INTERRUPT_LIST[n+1] + 1;
						end
						n = n + 1;
					end
				else
					tinsert(InterruptReportConfig.INTERRUPT_LIST, sourceName);
					tinsert(InterruptReportConfig.INTERRUPT_LIST, 1);
				end
				
			end
			
		end
		
		if (( InterruptReportConfig.NEXT_CHECK == nil ) or ( InterruptReportConfig.NEXT_CHECK <= time() )) then
			InterruptReportConfig.NEXT_CHECK = time() + 2;
			InterruptReport_CombatCheck(self);
		end
		
	end	
	
end -- 397 lines of boring code. With no library dependencies.
