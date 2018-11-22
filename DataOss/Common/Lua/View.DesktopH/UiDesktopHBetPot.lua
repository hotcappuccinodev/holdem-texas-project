-- Copyright(c) Cragon. All rights reserved.

---------------------------------------
UiDesktopHBetPot = {
    GivePlayerAniTm = 3.2,
    WinShowAniTm = 2
}

---------------------------------------
function UiDesktopHBetPot:new(betpot_index, bet_pot, ui_desktoph)
    local o = {}
    setmetatable(o, { __index = self })
    o.UiDesktopHBetPotItem = bet_pot
    o.TotalBetPotGold = 0
    o.BetPotIndex = betpot_index
    o.ListUiGolds = {}
    o.ViewDesktopH = ui_desktoph
    o.BDesktopHNotifyGameEndBetPot = nil
    o.FTaskerShowGameEndGoldAni = nil
    o.FTaskerSendGoldToPlayer = nil
    o.LooseShowAniTm = 0.2
    o.MaxUiChipNum = 100
    o.PosOffSet = 20
    return o
end

---------------------------------------
function UiDesktopHBetPot:InitBetPotInfo(bet_all_golds, self_betgolds)
    self:ResetBetPot()

    self.TotalBetPotGold = bet_all_golds
    local ListTmpUiGolds = {}
    if (bet_all_golds > 0) then
        self.ViewDesktopH:CreateGolds(self.ListUiGolds, ListTmpUiGolds, bet_all_golds, self, 20)
    end

    ListTmpUiGolds = nil

    self.UiDesktopHBetPotItem:SetBetPotTotalChips(bet_all_golds)

    self:setBetSelfChipsToPot(self_betgolds)
end

---------------------------------------
function UiDesktopHBetPot:Destroy()
    self:_goldEnPool()
    self:_cancelTask()
    self.UiDesktopHBetPotItem:Destroy()
end

---------------------------------------
function UiDesktopHBetPot:UpdateBetPotInfo(betpot_golds)
    self.TotalBetPotGold = self.TotalBetPotGold + betpot_golds
    self.UiDesktopHBetPotItem:SetBetPotTotalChips(self.TotalBetPotGold)
end

---------------------------------------
function UiDesktopHBetPot:SetGameEndResult(betpot_gameresult, win_rewardpot_gold)
    self.BDesktopHNotifyGameEndBetPot = betpot_gameresult
    self.UiDesktopHBetPotItem:SetGameEndResult(self.BDesktopHNotifyGameEndBetPot, win_rewardpot_gold)
end

---------------------------------------
function UiDesktopHBetPot:BetGold(from, gold_value)
    local list_uigold_tmp = {}
    self.ViewDesktopH:CreateGolds(self.ListUiGolds, list_uigold_tmp, gold_value, self)
    local delay_tm = 0.0
    local l = #list_uigold_tmp
    local delay_t = self.ViewDesktopH:GetMoveIntervalTm(l)
    for k, v in pairs(list_uigold_tmp) do
        local to = self:getRandomChipPos()
        v:InitMove(from, to, UiDesktopHGold.MOVE_CHIP_TM, UiDesktopHGold.MOVE_SOUND, nil, nil, false, delay_tm, true)
        delay_tm = delay_tm + delay_t
    end
    list_uigold_tmp = nil
end

---------------------------------------
function UiDesktopHBetPot:setBetSelfChipsToPot(self_betchips)
    self.UiDesktopHBetPotItem:SetBetPotSelfChips(self_betchips)
end

---------------------------------------
function UiDesktopHBetPot:showGameEndGoldAni(betpot_show_win_ani_tm, give_winplayer_gold_ani_tm)
    self:_cancelTask()
    local show_gameend_gold_ani_tm = 0
    if (self.UiDesktopHBetPotItem.IsWin == false) then
        show_gameend_gold_ani_tm = self.LooseShowAniTm
    else
        show_gameend_gold_ani_tm = betpot_show_win_ani_tm
        local t1 = CS.Casinos.FTMgr.Instance:startTask(give_winplayer_gold_ani_tm)
        self.FTaskerSendGoldToPlayer = CS.Casinos.FTMgr.Instance:whenAll(nil,
                function(map_param)
                    self:_resetGoldInfo(map_param)
                end, t1)
    end

    local t = CS.Casinos.FTMgr.Instance:startTask(show_gameend_gold_ani_tm)
    self.FTaskerShowGameEndGoldAni = CS.Casinos.FTMgr.Instance:whenAll(nil,
            function(map_param)
                self:_showGameEndGoldAni(map_param)
            end, t)
end

---------------------------------------
function UiDesktopHBetPot:ResetBetPot()
    self:_cancelTask()
    self.TotalBetPotGold = 0
    self:_goldEnPool()
    self.UiDesktopHBetPotItem:ResetBetPot()
    self.BDesktopHNotifyGameEndBetPot = nil
end

---------------------------------------
function UiDesktopHBetPot:_showGameEndGoldAni(map_param)
    if (self.UiDesktopHBetPotItem.IsWin == false) then
        if (self.BDesktopHNotifyGameEndBetPot ~= nil) then
            self.ViewDesktopH.UiDesktopHBanker:showWinGoldAni(self.BDesktopHNotifyGameEndBetPot.winloose_gold, self.ListUiGolds, self.BetPotIndex)
        end
        self.ListUiGolds = {}
        self.UiDesktopHBetPotItem:resetGoldsInfo()
    else
        self.ViewDesktopH.UiDesktopHBanker:giveGoldToPot(self.BetPotIndex)
        self.ViewDesktopH.UiDesktopHRewardPot:showLooseGoldAni(self.BetPotIndex, self.UiDesktopHBetPotItem.WinRewardPotGolds)
    end
    self.FTaskerShowGameEndGoldAni = nil
end

---------------------------------------
function UiDesktopHBetPot:_resetGoldInfo(map_param)
    self.UiDesktopHBetPotItem:resetGoldsInfo()
    self:_goldEnPool()
    self.FTaskerSendGoldToPlayer = nil
end

---------------------------------------
function UiDesktopHBetPot:_cancelTask()
    if (self.FTaskerShowGameEndGoldAni ~= nil) then
        self.FTaskerShowGameEndGoldAni:cancelTask()
        self.FTaskerShowGameEndGoldAni = nil
    end
    if (self.FTaskerSendGoldToPlayer ~= nil) then
        self.FTaskerSendGoldToPlayer:cancelTask()
        self.FTaskerSendGoldToPlayer = nil
    end
end

---------------------------------------
function UiDesktopHBetPot:getRandomChipPos()
    local pos = self.UiDesktopHBetPotItem.GListParent.xy
            + self.UiDesktopHBetPotItem.GListParent.container.xy
            + self.UiDesktopHBetPotItem.GCoBetPot.xy
            + self.UiDesktopHBetPotItem.GGraphBetPotArea.xy
    local betpotarea_halfwidth = self.UiDesktopHBetPotItem.GGraphBetPotArea.width / 2
    local betpotarea_halfheight = self.UiDesktopHBetPotItem.GGraphBetPotArea.height / 2
    pos.x = pos.x + betpotarea_halfwidth
    pos.y = pos.y + betpotarea_halfheight
    pos.x = pos.x + CS.UnityEngine.Random.Range(-betpotarea_halfwidth + self.PosOffSet, betpotarea_halfwidth - self.PosOffSet)
    pos.y = pos.y + CS.UnityEngine.Random.Range(-betpotarea_halfheight + self.PosOffSet, betpotarea_halfheight - self.PosOffSet)
    return pos
end

---------------------------------------
function UiDesktopHBetPot:_goldEnPool()
    for k, v in pairs(self.ListUiGolds) do
        self.ViewDesktopH.UiDesktopHGoldPool:goldHEnPool(v)
    end
    self.ListUiGolds = {}
end