-- Author      : Potdisc
-- Create Date : 10/11/2016
-- CustomModule
-- votingUtils.lua	Adds extra columns for the default voting frame

--[[ TODO:
]]


local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local EU = addon:NewModule("RCExtraUtilities", "AceComm-3.0", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LE = LibStub("AceLocale-3.0"):GetLocale("RCExtraUtilities")
local ItemUpgradeInfo = LibStub("LibItemUpgradeInfo-1.0")

local playerData = {} -- Table containing all EU data received, format playerData["playerName"] = {...}
local lootTable = {}
local session = 0
local guildInfo = {}
local debugPawn = false
local debugRCScore = true

local unpack, pairs, ipairs, UnitGUID = unpack, pairs, ipairs, UnitGUID

function EU:OnInitialize()
   self:RegisterComm("RCLootCouncil")
   self.version = GetAddOnMetadata("RCLootCouncil_ExtraUtilities", "Version")
   self.defaults = {
      profile = {
         columns = {
            traits =          { enabled = false, pos = 10, width = 40, func = self.SetCellTraits,   name = LE["Traits"]},
         --   upgrades =        { enabled = false, pos = -3, width = 55, func = self.SetCellUpgrades, name = LE["Upgrades"]},
            pawn =            { enabled = false, pos = -3, width = 50, func = self.SetCellPawn,     name = "Pawn"},
            sockets =         { enabled = false, pos = 11, width = 45, func = self.SetCellSocket,   name = LE["Sockets"]},
         -- setPieces =       { enabled = true, pos = 11, width = 40, func = self.SetCellPieces,   name = LE["Set Pieces"]},
            titanforged =     { enabled = false, pos = 10, width = 40, func = self.SetCellForged,   name = LE["Forged"]},
         --   legendaries =     { enabled = false, pos = 11, width = 55, func = self.SetCellLegend,   name = LE["Legendaries"]},
         --   ilvlUpgrade =     { enabled = false, pos = -4, width = 50, func = self.SetCellIlvlUpg,  name = LE["ilvl Upg."]},
            spec =            { enabled = false, pos = 1,  width = 20, func = self.SetCellSpecIcon, name = ""},
            bonus =           { enabled = false, pos = 100, width = 40, func = self.SetCellBonusRoll, name = LE["Bonus"]},
            guildNotes =      { enabled = false, pos = -1, width = 45, func = self.SetEpgpValue, name = "EPGP"},
            rcscore =         { enabled = false, pos = 16, width = 50, func = self.SetCellRCScore, name = "RC Score"},
         },
         normalColumns = {
            class =  { enabled = true, name = LE.Class, width = 20},
            rank =   { enabled = true, name = _G.RANK, width = 95,},
            role =   { enabled = true, name = _G.ROLE, width = 55},
            ilvl =   { enabled = true, name = _G.ITEM_LEVEL_ABBR, width = 45,},
            diff =   { enabled = true, name = L.Diff, width = 40},
            roll =   { enabled = true, name = _G.ROLL, width = 30},

            name =   { enabled = "", name = _G.NAME, width = 120},
            response={ enabled = "", name = L.Response, width = 240,},
            gear1 =  { enabled = "", name = L.g1, width = 20},
            gear2 =  { enabled = "", name = L.g2, width = 20},
            votes =  { enabled = "", name = L.Votes, width = 40},
            vote =   { enabled = "", name = L.Vote, width = 60},
            note =   { enabled = "", name = L.Notes, width = 240}, --Se ha cambiado el width para que quepa el cálculo
         },
         bonusRollsHistory = false,
         acceptPawn = true, -- Allow Pawn scores sent from candidates
         pawnNormalMode = false, -- Scoring mode, % or normal
         pawn = { -- Default Pawn scales
            WARRIOR = {
               [71] = '"MrRobot":WARRIOR1', -- Arms
               [72] = '"MrRobot":WARRIOR2', -- Fury
               [73] = '"MrRobot":WARRIOR3', -- Protection
            },
         	DEATHKNIGHT = {
               [250] = '"MrRobot":DEATHKNIGHT1', -- Blood
               [251] = '"MrRobot":DEATHKNIGHT2', -- Frost
               [252] = '"MrRobot":DEATHKNIGHT3', -- Unholy
            },
         	PALADIN = {
               [65] = '"MrRobot":PALADIN1', -- Holy
               [66] = '"MrRobot":PALADIN2', -- Protection
               [70] = '"MrRobot":PALADIN3', -- Retribution
            },
         	MONK = {
               [268] = '"MrRobot":MONK1', -- Brewmaster
               [269] = '"MrRobot":MONK2', -- Windwalker
               [270] = '"MrRobot":MONK3', -- Mistweaver
            },
         	PRIEST = {
               [256] = '"MrRobot":PRIEST1', -- Discipline
               [257] = '"MrRobot":PRIEST2', -- Holy
               [258] = '"MrRobot":PRIEST3', -- Shadow
            },
         	SHAMAN = {
               [262] = '"MrRobot":SHAMAN1', -- Elemental
               [263] = '"MrRobot":SHAMAN2', -- Enhancement
               [264] = '"MrRobot":SHAMAN3', -- Restoration
            },
         	DRUID = {
               [102] = '"MrRobot":DRUID1', -- Balance
               [103] = '"MrRobot":DRUID2', -- Feral
               [104] = '"MrRobot":DRUID3', -- Guardian
               [105] = '"MrRobot":DRUID4', -- Restoration
            },
         	ROGUE = {
               [259] = '"MrRobot":ROGUE1', -- Assassination
               [260] = '"MrRobot":ROGUE2', -- Outlaw
               [261] = '"MrRobot":ROGUE3', -- Subtlety
            },
         	MAGE = {
               [62] = '"MrRobot":MAGE1', -- Arcane
               [63] = '"MrRobot":MAGE2', -- Fire
               [64] = '"MrRobot":MAGE3', -- Frost
            },
         	WARLOCK = {
               [265] = '"MrRobot":WARLOCK1', -- Affliction
               [266] = '"MrRobot":WARLOCK2', -- Demonology
               [267] = '"MrRobot":WARLOCK3', -- Destruction
            },
         	HUNTER = {
               [253] = '"MrRobot":HUNTER1', -- Beast Mastery
               [254] = '"MrRobot":HUNTER2', -- Marksmanship
               [255] = '"MrRobot":HUNTER3', -- Survival
            },
         	DEMONHUNTER = {
               [577] = '"MrRobot":DEMONHUNTER1', -- Havoc
               [581] = '"MrRobot":DEMONHUNTER2', -- Vengeance
            },
         }
      }
   }
   -- The order of which the new cols appear in the advanced options
   self.optionsColOrder = {"pawn", "traits","sockets","titanforged","spec","bonus","guildNotes",--[["rcscore"]]}
   -- The order of which the normal cols appear ANYWHERE in the options
   self.optionsNormalColOrder = {"class","name","rank","role","response","ilvl","diff","gear1","gear2","votes","vote","note","roll"}

   addon.db:RegisterNamespace("ExtraUtilities", self.defaults)
   self.db = addon.db:GetNamespace("ExtraUtilities").profile
   self:Enable()

   -- Setup chat command for options
   if addon:VersionCompare(addon.version, "2.7.6") then
      addon:CustomChatCmd(self, "OpenOptions","- eu - Opens the ExtraUtilities options window", "EU", "eu")
   else
      addon:ModuleChatCmd(self, "OpenOptions", nil, LE["chat_cmd_desc"], "eu", "extrautilities")
   end

   self:RegisterEvent("BONUS_ROLL_RESULT")
end

function EU:OpenOptions()
   InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
   InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

function EU:GetPlayerData()
   return playerData
end

function EU:OnEnable()
   addon:DebugLog("Using ExtraUtilities", self.version)
   addon.db.profile.responses.default["BONUSROLL"] = { color = {1,0.8,0,1},	sort = 510,		text = LE["Bonus Rolls"],}
   -- Get the voting frame
   self.votingFrame = addon:GetActiveModule("votingframe")
   -- Crap a copy of the cols
   self.originalCols = {unpack(self.votingFrame.scrollCols)}

   -- Setup options
   self:OptionsTable()

   -- Hook SwitchSession() so we know which session we're on
   self:Hook(self.votingFrame, "SwitchSession", function(_, s) session = s end)

   -- Translate sortNext into colNames
   self.sortNext = {}
   for k,v in ipairs(self.votingFrame.scrollCols) do
      if v.sortNext then
         self.sortNext[v.colName] = self.votingFrame.scrollCols[v.sortNext].colName
      end
   end
   -- Make sure we handle external requirements
   self:HandleExternalRequirements()
   -- Setup our columns
   self:SetupColumns()

   self:UpdateGuildInfo()
end

function EU:OnDisable()
   -- Reset cols
   self.votingFrame.scrollCols = self.originalCols
   self:UnregisterAllComm()
   self:UnregisterAllEvents()
end

function EU:OnCommReceived(prefix, serializedMsg, distri, sender)
   if prefix == "RCLootCouncil" then
      -- data is always a table to be unpacked
		local test, command, data = addon:Deserialize(serializedMsg)
		if addon:HandleXRealmComms(self, command, data, sender) then return end

		if test then
         if command == "lootTable" then
            -- And grap a copy
            lootTable = unpack(data)
            -- Send out our data
            addon:SendCommand("group", "extraUtilData", addon.playerName, self:BuildData())

         elseif command == "lt_add" then
            if PawnVersion then -- Currently only Pawn has session specific data
               addon:SendCommand("group", "extraUtilData", addon.playerName, self:BuildData())
            end

         elseif command == "extraUtilData" then
            -- We received our EU data
            local name, data = unpack(data)
            playerData[name] = playerData[name] or {}
            for k, v in pairs(data) do
               playerData[name][k] = v
            end
            if playerData[name].bonusReference and playerData[name].bonusReference ~= addon.bossName then
               -- The bonus data belongs to an earlier session
               playerData[name].bonusType = nil
               playerData[name].bonusLink = nil
               playerData[name].bonusReference = nil
            end
            self.votingFrame:Update()

         elseif command == "extraUtilDataRequest" then
            addon:SendCommand("group", "extraUtilData", addon.playerName, self:BuildData())

         elseif command == "EUBonusRoll" then
            local name, type, link = unpack(data)
            if not playerData[name] then playerData[name] = {} end
            playerData[name].bonusType = type
            playerData[name].bonusLink = link
            playerData[name].bonusReference = addon.bossName
            self.votingFrame:Update()
            if self.db.bonusRollsHistory and addon.isMasterLooter and type == "item" and not addon.testMode then
               addon:GetActiveModule("masterlooter"):TrackAndLogLoot(name,link,"BONUSROLL", addon.bossName,0)
            end
         end
      end
   end
end

function EU:BONUS_ROLL_RESULT(event, rewardType, rewardLink, ...)--rewardQuantity, rewardSpecID)
   addon:SendCommand("group", "EUBonusRoll", addon.playerName, rewardType, rewardLink)
   --addon:Debug("BONUS_ROLL_RESULT", rewardType, rewardLink, rewardQuantity, rewardSpecID)
   addon:Debug(event, rewardType, rewardLink, ...)
   --[[ Results:
      BONUS_ROLL_RESULT (artifact_power) (|cff0070dd|Hitem:144297::::::::110:256:8388608:3::26:::|h[Talisman of Victory]|h|r) (1) (0)
      BONUS_ROLL_RESULT (item) (|cffa335ee|Hitem:140851::::::::110:256::3:3:3443:1467:1813:::|h[Nighthold Custodian's Hood]|h|r) (1) (257)
      BONUS_ROLL_RESULT (artifact_power) (|cff0070dd|Hitem:144297::::::::110:256:8388608:3::26:::|h[Talisman of Victory]|h|r) (1) (0)
      BONUS_ROLL_RESULT (artifact_power) (|cff0070dd|Hitem:144297::::::::110:256:8388608:3::26:::|h[Talisman of Victory]|h|r) (1) (0) (2) (false)
      BONUS_ROLL_RESULT (artifact_power) (|cff0070dd|Hitem:144297::::::::110:256:8388608:3::26:::|h[Talisman of Victory]|h|r) (1) (0) (2) (false)
      BONUS_ROLL_RESULT (artifact_power) (|cff0070dd|Hitem:144297::::::::110:256:8388608:3::26:::|h[Talisman of Victory]|h|r) (1) (0) (2) (false)
      BONUS_ROLL_RESULT (item) (|cffa335ee|Hitem:140804::::::::110:256::5:3:3516:1492:3336:::|h[Star Gate]|h|r) (1) (256) (3) (false)
      BONUS_ROLL_RESULT (item) (||cffa335ee||Hitem:140851::::::::110:256::3:3:3443:1467:1813:::||h[Nighthold Custodian's Hood]||h||r)

      Tests:
      /run EU:BONUS_ROLL_RESULT("BONUS_ROLL_RESULT", "artifact_power", "|cff0070dd|Hitem:144297::::::::110:256:8388608:3::26:::|h[Talisman of Victory]|h|r")
      /run EU:BONUS_ROLL_RESULT("BONUS_ROLL_RESULT", "item", "|cffa335ee|Hitem:140851::::::::110:256::3:3:3443:1467:1813:::|h[Nighthold Custodian's Hood]|h|r")

   ]]
end

function EU:HandleExternalRequirements()
   -- Pawn
   if self.db.columns.pawn.enabled and not PawnVersion then
      self.db.columns.pawn.enabled = false
      addon:Print(LE["Pawn column was disabled as Pawn isn't installed."])
   end
   -- RCScore
   if self.db.columns.rcscore.enabled and not (Details or Recount or Skada) then
      self.db.columns.rcscore.enabled = false
      addon:Print(LE["RCScore column was disabled as no damage meter is installed."])
   end
end

--- Adds or removes a column based on its name in self.db.columns/normalColumns
function EU:UpdateColumn(name, add)
   addon:Debug("UpdateColumn", name, add)
   local col = self.db.columns[name]
   if not col then -- It's one of the default RC columns
      -- find its' data
      for k,v in ipairs(self.originalCols) do
         if v.colName == name then
            -- We got it!
            col = v
            col.pos = k
            col.func = v.DoCellUpdate
            col.width = self.db.normalColumns[name].width or v.width -- We might have overridden the orignial value
         end
      end
   end
   if add then
      local pos = 0
      if col.pos < 0 then
         pos = #self.votingFrame.scrollCols + col.pos -- col.pos is negative, so add it for the desired effect
      elseif col.pos > #self.votingFrame.scrollCols then
         pos = #self.votingFrame.scrollCols
      else
         pos = col.pos
      end
      tinsert(self.votingFrame.scrollCols, pos,
         {name = col.name, align = "CENTER", width = col.width, DoCellUpdate = col.func, colName = name, sortNext = col.sortNext }
      )
   else
      self.votingFrame:RemoveColumn(name)
   end
   if self.votingFrame.frame then -- We might need to recreate it
      self.votingFrame.frame.UpdateSt()
   end
   self:UpdateSortNext()
end

--- Completely resets all columns
function EU:SetupColumns()
   -- First we need to know the order of the columns, so extract from both tables:
   local cols = {} -- The cols we want to use
   for name, v in pairs(self.db.columns) do -- EU cols First
      if v.enabled then tinsert(cols, {name = name, pos = v.pos}) end
   end
   for name, v in pairs(self.db.normalColumns) do -- then the default
      if v.enabled then tinsert(cols, {name = name, pos = v.pos and v.pos or self:GetScrollColIndexFromName(name)}) end
   end
   -- Now we know which columns to add, but we need to "translate" any negative or 0 positions
   for _, v in ipairs(cols) do
      if v.pos < 0 then v.pos = #cols + v.pos end
      if v.pos == 0 then v.pos = 1 end
   end
   -- Now sort the table to get the actual order:
   table.sort(cols, function(a,b) return a.pos < b.pos end)
   -- Now inject
   local temp
   local newCols = {}
   for pos,v in ipairs(cols) do
      --wipe(temp)
      if self.db.columns[v.name] then -- handle EU column
         temp = self.db.columns[v.name]
         tinsert(newCols, {name = temp.name, align = temp.align or "CENTER", width = temp.width, DoCellUpdate = temp.func, colName = v.name, sortNext = temp.sortNext or self:GetScrollColIndexFromName("reponse")})
      else -- Handle default column
         local i = self:GetScrollColIndexFromName(v.name)
         temp = self.votingFrame.scrollCols[i]
         temp.width = self.db.normalColumns[v.name].width
         tinsert(newCols, temp)
      end

   end
   self.votingFrame.scrollCols = {unpack(newCols)}
   self:UpdateSortNext()
end

--- Updates the sortNext index on scrollCols
-- Shouldn't be called until all columns have been set up.
function EU:UpdateSortNext()
   for index in ipairs(self.votingFrame.scrollCols) do
      if self.votingFrame.scrollCols[index].sortNext then
         local exists = self:GetScrollColIndexFromName(self.sortNext[self.votingFrame.scrollCols[index].colName])
         self.votingFrame.scrollCols[index].sortNext = exists
      end
   end
end

function EU:UpdateColumnWidth(name, width)
   -- Our storage has now been updated, but we still need to edit it in the scrollCols table:
   local i = self:GetScrollColIndexFromName(name)
   self.votingFrame.scrollCols[i].width = width
   -- The frame might not yet be created, so check before altering anything
   if self.votingFrame.frame then
      -- Update the width of the cols
      self.votingFrame.frame.st:SetDisplayCols(self.votingFrame.scrollCols)
      -- Now update the frame width
      self.votingFrame.frame:SetWidth(self.votingFrame.frame.st.frame:GetWidth() + 20)
   end
end

function EU:UpdateColumnPosition(name, pos)
   -- Find the index in scrollCols
   local i = self:GetScrollColIndexFromName(name)
   -- We might need to change pos abit
   if pos < 0 then -- "from the back, i.e. add it"
      pos = #self.votingFrame.scrollCols + pos
   end
   if pos > #self.votingFrame.scrollCols then
      pos = #self.votingFrame.scrollCols
   end
   if pos == 0 then pos = 1 end
   -- Move the column and update
   tinsert(self.votingFrame.scrollCols, pos, tremove(self.votingFrame.scrollCols, i))
   self:UpdateSortNext()
   if self.votingFrame.frame then -- Frame might not be created
      self.votingFrame.frame.st:SetDisplayCols(self.votingFrame.scrollCols)
      self.votingFrame.frame.st:SortData()
   end
end

function EU:GetScrollColIndexFromName(name)
   for i,v in ipairs(self.votingFrame.scrollCols) do
      if v.colName == name then
         return i
      end
   end
end

function EU:BuildData()
   local forged,_,sockets, upgrades, legend, ilvl = self:GetEquippedItemData()
   local spec = (GetSpecializationInfo(GetSpecialization()))
   local score = {}
   -- Calculate pawn scores
   if PawnVersion then
      for session, v in ipairs(lootTable) do
         score[session] = {}
         score[session].new = addon.round(EU:GetPawnScore(v.link, addon.playerClass, spec) or 0,3)
         local item1,item2 = addon:GetPlayersGear(v.link, v.equipLoc)
         -- Find the lowest score and use that
         local score1 =  EU:GetPawnScore(item1, addon.playerClass, spec)
         local score2 =  EU:GetPawnScore(item2, addon.playerClass, spec)
         score[session].equipped = addon.round((score2 and score1 > score2) and score2 or score1 or 0, 3)
      end
   end
   local hoaLocation = _G.C_AzeriteItem.FindActiveAzeriteItem()
   local hoalvl = 0
   if hoaLocation then
      hoalvl = C_AzeriteItem.GetPowerLevel(hoaLocation)
   end
   return {
      forged = forged,
      traits = hoalvl,
      --setPieces = 0,
      sockets = sockets,
      --upgrades = upgrades,
      --legend = legend,
      --upgradeIlvl = ilvl,
      specID = spec,
      pawn = {unpack(score)}
   }
end

function EU:GetEquippedItemData()
   local forgedTable = {
      [4783] = "Warforged",
      [4784] = "Titanforged",   }

   local titanforged, setPieces, sockets, legend = 0, 0, 0, 0
   local upgradeIlvl, upg, upgMax = 0, 0, 0
   for i = 1, 17 do
      if i ~= 4 then
         local link = GetInventoryItemLink("player", i)
         if link then
            local upgrade, max, delta = ItemUpgradeInfo:GetItemUpgradeInfo(item or " ")
            if upgrade then
               upg = upg + upgrade
               upgMax = upgMax + max
               upgradeIlvl = upgradeIlvl + delta
            end
            local color, itemType, itemID, enchantID, gemID1, gemID2, gemID3, gemID4, suffixID, uniqueID, linkLevel,
   	 		specializationID, upgradeTypeID, upgradeID, instanceDifficultyID, numBonuses, bonusIDs = addon:DecodeItemLink(link)

            if color == "ff8000" then
               legend = legend + 1
            end

            if (gemID1 > 0 or gemID2 > 0) and i ~= 16 then -- Avoid artifact as it has relics in its' gemIDs
               sockets = sockets + 1
            end

            if numBonuses > 0 then
               for _, v in ipairs(bonusIDs) do
                  if forgedTable[v] then
                     titanforged = titanforged + 1
                  end
               end
            end
         end
      end
   end

   return titanforged, setPieces, sockets, upg.."/"..upgMax, legend, upgradeIlvl
end

function EU:UpdateGuildInfo()
   addon:Debug("EU:UpdateGuildInfo")
   GuildRoster()
   for i = 1, GetNumGuildMembers() do
      local name, _, _, _, _, _, note, officernote = GetGuildRosterInfo(i)
      guildInfo[name] = {note, officernote}
   end
end

function EU:StripTextures()
   if not self.votingFrame.frame:IsVisible() then return end
   for k,v in ipairs(self.votingFrame.scrollCols) do
      for row = 1, self.votingFrame.frame.st.displayRows do
         local frame = self.votingFrame.frame.st.rows[row].cols[k]
         frame:SetNormalTexture("")
         frame.text:SetTextColor(1,1,1,1)
         if frame.voteBtn then frame.voteBtn:Hide(); frame.voteBtn = nil end
         if frame.noteBtn then frame.noteBtn:Hide(); frame.noteBtn = nil end
         if frame.bonusBtn then frame.bonusBtn:Hide(); frame.bonusBtn = nil end
      end
   end
   self.votingFrame.frame.st:Refresh()
end

-- A 10 value gradient going from 1-3: red ->4-7: yellow -> 8-10: green
local colorGradient = {
   [0] = {0.7, 0.7,0.7}, -- 0 #b2b2b2
      {0.7, 0, 0},      -- 1  #b20000
      {0.6, 0.1, 0},    -- 2  #991900
      {0.6, 0.2, 0},    -- 3  #993300
      {0.6, 0.4, 0},    -- 4  #996600
      {1,1,0},          -- 5  #ffff00
      {1, 1, 0},        -- 6  #ffff00
      {0.8,1,0},        -- 7  #ccff00
      {0.5,1,0},        -- 8  #7fff00
      {0.3,1,0},        -- 9  #4cff00
      {0,1,0},          -- 10 #00ff00
}

-- Returns a Pawn score calculated based on the select scale in the EU options
-- mathcing the class and spec
function EU:GetPawnScore(link, class, spec)
   if debugPawn then addon:Debug("GetPawnScore", link, class, spec) end
   local item = PawnGetItemData(link)
   if not (item and class and spec) then
      return --addon:Debug("Error in :GetPawnScore", link, item, class, spec)
   end
   -- Normalize
   PawnCommon.Scales[self.db.pawn[class][spec]].NormalizationFactor = 1
   local score = PawnGetSingleValueFromItem(item, self.db.pawn[class][spec])
   return score
end

-- Calculates a color for the score
-- Accepts normal or percent mode. Percent mode simply returns red/green for <0 / >=0
-- while normal is gradient based around the current session's max score
function EU:GetPawnScoreColor(score, mode)
   local r,g,b,a = 1,1,1,1
   if type(score) == "number" then
      if mode == "%" then
         if score > 0 then -- Green
            r,b = 0,0
         elseif score < 0 then -- Red
            g,b = 0,0
         else -- Greyout
            r,g,b = 0.7,0.7,0.7
         end
      elseif mode == "normal" then -- Gradient the top 90 %
         if lootTable[session] then
            if not lootTable[session].pawnMax or lootTable[session].pawnMax < score then
               lootTable[session].pawnMax = score
            end
            local val = score / lootTable[session].pawnMax
            if val > 0.1 then
               r,g,b = 1-val, val, 0
            else -- Greyout the 10th percentile
               r,g,b = 0.7, 0.7, 0.7
            end
         end
      else -- Greyout
         r,g,b = 0.7,0.7,0.7
      end
   else -- Greyout
      r,g,b = 0.7,0.7,0.7
   end
   return {r,g,b,a}
end
---------------------------------------------
-- Lib-st UI functions
---------------------------------------------
function EU.SetCellPawn(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
   if not playerData[name] then return end -- Might now be received
   -- We know which session we're on, we have the item link from lootTable, and we have access to Set/Get candidate data
   -- We can calculate the Pawn score here for each item/candidate and store the result in votingFrames' data
   local score
   -- If we've enabled it, we might have received a Pawn score from the player, in which case we want to display that.
   if EU.db.acceptPawn and playerData[name] and playerData[name].pawn and playerData[name].pawn[session] and playerData[name].pawn[session].new then
      -- For this we rely on our own storage:
      if EU.db.pawnNormalMode then
         score = playerData[name].pawn[session].new
      elseif playerData[name].pawn[session].equipped > 0 and playerData[name].pawn[session].new > 0  then
         score = (playerData[name].pawn[session].new / playerData[name].pawn[session].equipped - 1) * 100
      elseif playerData[name].pawn[session].equipped == 0 and playerData[name].pawn[session].new > 0 then -- Major, not realistic, upgrade
         score = 100
      end

   -- If we've already calculated it, then just retrieve it from the votingFrame data:
   elseif playerData[name] and playerData[name].pawn and playerData[name].pawn[session] and playerData[name].pawn[session].own then
      score = EU.votingFrame:GetCandidateData(session, name, "pawn")

   -- Or just calculate it ourself
   elseif lootTable[session] and lootTable[session].link then
      local class = EU.votingFrame:GetCandidateData(session, name, "class")
      local specID = EU.votingFrame:GetCandidateData(session, name, "specID")
      if specID then -- SpecID might not be received yet, so don't bother checking further
         score = EU:GetPawnScore(lootTable[session].link, class, specID)
         if not EU.db.pawnNormalMode then -- % mode
            if score then
               local item1 = EU.votingFrame:GetCandidateData(session, name, "gear1")
               local item2 = EU.votingFrame:GetCandidateData(session, name, "gear2")
               local score1 = item1 and EU:GetPawnScore(item1, class, specID)
               local score2 = item2 and EU:GetPawnScore(item2, class, specID)
               if score1 then
                  if not score2 or score1 < score2 then
                     score = (score / score1 - 1) * 100
                  else
                     score = (score / score2 - 1) * 100
                  end
               else -- We haven't received the candidate's gear yet
                  score = nil -- Nullify it
               end
            end
         end
         EU.votingFrame:SetCandidateData(session, name, "pawn", score)
         if not playerData[name].pawn then playerData[name].pawn = {} end -- Just to be sure
         playerData[name].pawn[session] = {own = true}
      end
   end
   data[realrow].cols[column].value = score or 0
   if EU.db.pawnNormalMode then
      frame.text:SetText(score and addon.round(score,1) or _G.NONE)
   else
      frame.text:SetText(score and (addon.round(score,1).."%") or _G.NONE)
   end
   local color
   if EU.db.pawnNormalMode then
      color = EU:GetPawnScoreColor(score, "normal")
   else
      color = EU:GetPawnScoreColor(score, "%")
   end
   frame.text:SetTextColor(unpack(color))
end

function EU.SetCellForged(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
   local val = playerData[name] and playerData[name].forged or 0
   frame.text:SetText(val)
   data[realrow].cols[column].value = val
end

function EU.SetCellTraits(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
   local val = playerData[name] and playerData[name].traits or 0
   frame.text:SetText(val)
   data[realrow].cols[column].value = val
end

function EU.SetCellPieces(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
   local val = playerData[name] and playerData[name].setPieces or 0
   frame.text:SetText(val)
   data[realrow].cols[column].value = val
end

function EU.SetCellSocket(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
   local val = playerData[name] and playerData[name].sockets or 0
   frame.text:SetText(val)
   data[realrow].cols[column].value = val
end

function EU.SetCellUpgrades(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
   local val = playerData[name] and playerData[name].upgrades or 0
   frame.text:SetText(val)
   data[realrow].cols[column].value = val
end

function EU.SetCellLegend(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
   local val = "|cffff8000"..(playerData[name] and playerData[name].legend or 0)
   frame.text:SetText(val)
   data[realrow].cols[column].value = val
end

function EU.SetCellIlvlUpg(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
   local val = playerData[name] and playerData[name].upgradeIlvl or 0
   frame.text:SetText(val)
   data[realrow].cols[column].value = val
end

function EU.SetCellSpecIcon(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
	local specID = EU.votingFrame:GetCandidateData(session, name, "specID")
   local icon
   if specID then
      icon = select(4,GetSpecializationInfoByID(specID))
   end
	if icon then
		frame:SetNormalTexture(icon);
	else -- if there's no class
		frame:SetNormalTexture("Interface/ICONS/INV_Sigil_Thorim.png")
	end
end

function EU.SetCellBonusRoll(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
   local f = frame.bonusBtn or CreateFrame("Button", nil, frame)
	f:SetSize(table.rowHeight, table.rowHeight)
	f:SetPoint("CENTER", frame, "CENTER")
   if playerData[name] and playerData[name].bonusType then
      local type, link = playerData[name].bonusType, playerData[name].bonusLink
      if type == "item" or type == "artifact_power" then
         local texture = select(10, GetItemInfo(link))
   		f:SetNormalTexture(texture)
   		f:SetScript("OnEnter", function() addon:CreateHypertip(link) end)
   		f:SetScript("OnLeave", function() addon:HideTooltip() end)
   		f:SetScript("OnClick", function()
   			if IsModifiedClick() then
   			   HandleModifiedItemClick(link);
   	      end
   		end)
   		f:Show()
      else
         f:SetScript("OnEnter", function() addon:CreateTooltip("Gold", type, link) end)
         --addon:Debug("BonusRoll was gold", type, link)
      end
   else
      f:Hide()
      f:SetScript("OnEnter", nil)
   end
   frame.bonusBtn = f
end
-- Importante
function EU.SetCellGuildNote(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
   local f = frame.noteBtn or CreateFrame("Button", nil, frame)
	f:SetSize(table.rowHeight, table.rowHeight)
	f:SetPoint("CENTER", frame, "CENTER")
   if guildInfo and guildInfo[name] then
      f:SetNormalTexture("Interface/BUTTONS/UI-GuildButton-PublicNote-Up.png")
		f:SetScript("OnEnter", function() addon:CreateTooltip(_G.LABEL_NOTE, guildInfo[name][1], " ", LE["Officer Note"], guildInfo[name][2])	end)
		f:SetScript("OnLeave", function() addon:HideTooltip() end)
		data[realrow].cols[column].value = 1 -- Set value for sorting compability
   else
      f:SetScript("OnEnter", nil)
		f:SetNormalTexture("Interface/BUTTONS/UI-GuildButton-PublicNote-Disabled.png")
		data[realrow].cols[column].value = 0
   end
   frame.noteBtn = f
end
function EU.SetEpgpValue(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
   local percent = guildInfo[name][2]
   local ep, gp = percent:match("([^,]+),([^,]+)")
   local val = 0
   ep = tonumber(ep)
   gp = tonumber(gp)
   if ep == 0 then 
    val = "Error -1"
   else
		if gp < 100 then
			gp = 100
		end
    val = tonumber(ep)/tonumber(gp)
	val = round(val,2)
   end
   frame.text:SetText(val)
   data[realrow].cols[column].value = val
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end
-- Max percentile: (MOD(ilvl,893)/3+1)*101068+614274
local function getDPSRCScore(dps, ilvl)
   return 100 * dps / ((ilvl % 893 / 3 + 1) * 101068 + 614274)
end

-- Max averaged percentile: (MOD(ilvl,893)/3+1)*86183+531928
local function getDPSRCScore2(dps, ilvl)
   return 100 * dps / ((ilvl % 893 / 3 + 1) * 86183 + 531928)
end

-- Max averaged percentile: (MOD(ilvl,893)/3+1)*60007+209101
local function getTankRCScore(dps, ilvl)
   return 100 * dps / ((ilvl % 893 / 3 + 1) * 60007 + 209101)
end

-- Max averaged percentile:(MOD(ilvl,893)/3+1)*70234+376532
local function getHealerRCScore(hps, ilvl)
   return 100 * hps / ((ilvl % 893 / 3 + 1) * 70234 + 376532)
end

function EU.getDPSFromLastFight(role, name)
   local dps = 0
   if Details then
      local combat = Details:GetCurrentCombat()
      if combat then
         if role == "HEALER" then -- look for hps
            local healingActor = combat:GetActor (DETAILS_ATTRIBUTE_HEAL, Ambiguate(name, "none"))
            dps = healingActor and (healingActor.total / healingActor:Tempo()) or 0
         else -- Look for dps
            local damageActor = combat:GetActor (DETAILS_ATTRIBUTE_DAMAGE, Ambiguate(name, "none"))
            dps = damageActor and (damageActor.total / damageActor:Tempo()) or 0
         end
      end
      if debugRCScore then addon:Debug("Details:", dps) end
   end
   if Recount then
      local data = Recount.db2.combatants[Ambiguate(name, "none")]
      if data then
         if role == "HEALER" then
            _,dps = Recount:MergedPetHealingDPS(data, "LastFightData")
         else -- Look for dps
            _,dps = Recount:MergedPetDamageDPS(data, "LastFightData")
         end
      else
         addon:Debug("No last fight in Recount for", name)
      end
      if debugRCScore then addon:Debug("Recount:",dps) end
   end
   if Skada then
      -- It seems Skada has no consistency in where its data is stored
      local last
      if Skada.last then -- so far so good
         local guid = UnitGUID(Ambiguate(name, "short"))
         if Skada.last._playeridx then
            last = Skada.last._playeridx[guid]
         else
            for _,data in ipairs(Skada.last.players) do
               if data.id == guid then
                  last = data
                  break
               end
            end
         end
      else
         if #Skada.char.sets > 0 then
            for _, data in pairs(Skada.char.sets[1].players) do
               if addon:UnitIsUnit(data.name, name) then
                  last = data
                  break
               end
            end
         end
      end
      if last then
         if role == "HEALER" then
            dps = last.healing / last.time or 1
         else -- Look for dps
            dps = last.damage / last.time or 1
         end
      else
         addon:Debug("No last fight for Skada for ",name)
      end
      if debugRCScore then addon:Debug("Skada:",dps) end
   end
   return dps
end

function EU.SetCellRCScore(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local name = data[realrow].name
   local ilvl = EU.votingFrame:GetCandidateData(session, name, "ilvl")
   -- check if ilvl is availble
   if ilvl and ilvl ~= "" then
      -- Now check if we've already stored the score
      local score = EU.votingFrame:GetCandidateData(1, name, "RCScore")
      if not score then -- Calculate it
         local role = EU.votingFrame:GetCandidateData(session, name, "role")
         local dps = EU.getDPSFromLastFight(role, name)
         if debugRCScore then addon:Debug("Role, dps:", role, dps) end
         if role == "DAMAGER" or role == "NONE" then
            score = getDPSRCScore2(dps, ilvl)
         elseif role == "TANK" then
            score = getTankRCScore(dps, ilvl)
         elseif role == "HEALER" then
            score = getHealerRCScore(dps, ilvl)
         else
            return addon:DebugLog("No valid role in SetCellRCScore", name, role)
         end
         if debugRCScore then addon:Debug("RCScore:", name, score) end
         -- Store the score
         EU.votingFrame:SetCandidateData(1, name, "RCScore", score)
      end
      data[realrow].cols[column].value = score or 0
      frame.text:SetText(addon.round(score,0) .. "%")
      frame.text:SetTextColor(unpack(colorGradient[math.ceil(score / 10)] or {0,1,0})) -- >100% is not included in the table, just make it green
   else -- Clear it
      frame.text:SetText("")
      data[realrow].cols[column].value = 0
   end
end
