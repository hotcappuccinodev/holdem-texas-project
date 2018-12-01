-- Copyright(c) Cragon. All rights reserved.
-- 废弃

---------------------------------------
ItemAnte = {}

---------------------------------------
function ItemAnte:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

---------------------------------------
function ItemAnte:setAnte(com, lan_mgr, ante)
    local btn_ante = com.asButton
    btn_ante.title = UiChipShowHelper:GetGoldShowStr(ante, lan_mgr.LanBase)
    self.Ante = ante
    --com.onClick:Add(
    --		function()
    --			self:_onClick()
    --		end
    --)
end

---------------------------------------
function ItemAnte:_onClick()
    local view_mgr = ViewMgr
    local view_playerprofile = view_mgr:GetView("PlayerProfile")
    if (self.IsBuy == false and view_playerprofile ~= nil)
    then
        return
    end
    local gift_detail = view_mgr:CreateView("GiftDetail")
    gift_detail:SetGift(self.ItemId, self.IsBuy, self.IsMine, self.ToGuid, self.FromName, self.GiftBelong, self.Item)
end