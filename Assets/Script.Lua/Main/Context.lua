-- Copyright(c) Cragon. All rights reserved.

---------------------------------------
--BundleUpdateURL = ''
--BundleVersionState = ''
--CommonLuaVersion = '1.00.652'
--CommonLuaRootURL = 'cragon-lua-oss.cragon.cn/1.00.652/'
--CommonLuaHelper = 'Helper/LuaHelper.lua'
--CommonWWWLoader = 'Helper/WWWLoader.lua'
--CommonLuaLoaderPath = 'Helper/CommonLuaLoader.lua'
--ProjectDataLoaderPath = 'Helper/ProjectDataLoader.lua'
--CommonLuaFileListTxtName = 'CommonLuaFileList.txt'
UCenterDomain = 'http://ucenter.cragon.cn'
AutopatcherUrl = 'cragon-king-oss.cragon.cn/autopatcher/VersionInfo.xml'
PlayerIconDomain = 'cragon-king-oss.cragon.cn/images/'
BotIconDomain = 'cragon-king-oss.cragon.cn/ucenter/'
SysNoticeInfoUrl = ''
GatewayIp = 'king-gateway.cragon.cn'
GatewayPort = 5882
BundleUpdateStata = 0
BundleUpdateVersion = '1.00.067'
BundleUpdateURL = 'https://cragon-king-oss.cragon.cn/KingTexas.apk'
DataVersion = '1.00.605'
DataRootURL = 'https://cragon-king-oss.cragon.cn/ANDROID/Data_1.00.605/'
DataFileListFileName = 'datafilelist.txt'
TbFileList = { 'KingCommon', 'KingDesktop', 'KingDesktopH', 'KingClient' }
ServerState = 0-- 服务器状态: 0正常,1维护
SysNotice = ''-- 系统公告
ClientShowFPS = true-- 客户端显示FPS信息 false 不显示 true 显示
FPSLimit = 60
ClientShowWeiChat = true-- 客户端显示微信登录按钮 false 不显示 true 显示
ClientShowFirstRecharge = true-- 客户端显示首充按钮 false 不显示 true 显示
NeedHideClientUi = false-- 客户端排行等界面显示与隐藏
DesktopHSysBankShowDBValue = true-- 百人系统庄是否显示SQlite配置值
ShootingTextShowVIPLimit = 0-- 弹幕发送后是否真正发送弹幕VIP等级限制，0为无限制
DesktopHCanChatVIPLimit = 1-- 百人是否可聊天VIP等级限制，0为无限制
DesktopCanChatVIPLimit = 0-- 普通桌是否可聊天VIP等级限制，0为无限制
CanReportLog = false-- 是否开启上传日志到Bugly后台
CanReportLogDeviceId = ""-- 可以上传的机器码
CanReportLogPlayerId = ""-- 可以上传的玩家Id
ShowGoldTree = false
UseWeiChatPay = true
UseALiPay = true
UseIAP = true
UseLan = true
UseDefaultLan = false
DefaultLan = 'Chinese'
ChipIconSolustion = 0
CurrentMoneyType = 0
CSharpLastMethodId = 0
BuglyAppId = '0aed5e7e56'
PinggPPAppId = 'app_TCi58CGKCSaHGCuP'
WeChatAppId = 'wxff929d92c3997b5d'
WeChatAppSecret = '159e7a0f00dd15fd81fd63c4844b0dfc'
WeChatState = 'WeChat'
DataEyeId = 'E02253AEC6F95038833955AC4FED9D77'
PushAppId = 'TXYr3LD0se8JU8UOtg9cj3'
PushAppKey = 'F6i4mvPKr96KuYsNAXciw9'
PushAppSecret = 'DWlJdILTq77OG68J4jFcx3'
ShareSDKAppKey = '254dedc7a3730'
ShareSDKAppSecret = '53788920e17ffa1d9af4ef3540352172'
BeeCloudId = '9c24464e-c912-44aa-bfe8-ca3a384410d0'
BeeCloudLiveSecret = '71625ddd-5a3d-4b73-be74-1580c8912dda'
BeeCloudTestSecret = '7bbc79a8-f310-4d76-a582-2622242c23f5'
PayUseTestMode = false
PayUrlScheme = "com.Cragon.KingTexas2"

---------------------------------------
Context = {}

---------------------------------------
function Context:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.CasinosContext = CS.Casinos.CasinosContext.Instance
    self.CasinosLua = CS.Casinos.CasinosContext.Instance.CasinosLua
    self.Launch = Launch
    self.LaunchStep = {}
    self.ControllerMgr = nil
    self.ViewMgr = nil
    self.TbDataMgr = nil
    self.LuaHelper = nil
    return o
end

---------------------------------------
function Context:Init()
    Context:new(nil)
    print('Context:Init()')

    -- 销毁所有资源，因为可以从Login返回到Launch
    -- Esc可以弹出退出确认对话框，随时退出

    Context:_initLaunchStep()
    Context:_nextLaunchStep()

    -- 弹框让玩家选择，更新Bundle，调用Native Api安装Bundle
end

---------------------------------------
function Context:Release()
    if (self.TimerUpdateCopyStreamingAssetsToPersistentData ~= nil)
    then
        self.TimerUpdateCopyStreamingAssetsToPersistentData:Close()
        self.TimerUpdateCopyStreamingAssetsToPersistentData = nil
    end

    if (self.TimerUpdateRemoteToPersistentData ~= nil)
    then
        self.TimerUpdateRemoteToPersistentData:Close()
        self.TimerUpdateRemoteToPersistentData = nil
    end

    self.CasinosContext = nil
    self.CasinosLua = nil
    self.Launch = nil
    self.LaunchStep = nil

    print('Context:Release()')
end

---------------------------------------
function Context:DoString(name)
    self.CasinosLua:DoString(name)
end

---------------------------------------
function Context:AddUiPackage(package_name)
    local p = CS.FairyGUI.UIPackage.GetByName(package_name)
    if p ~= nil then
        CS.FairyGUI.UIPackage.RemovePackage(package_name, true)
    end

    local full_name = CS.Casinos.CasinosContext.Instance.PathMgr:combinePersistentDataPath(
            "resources.kingtexas/ui/" .. string.lower(package_name) .. ".ab")
    print(full_name)
    local ab = CS.UnityEngine.AssetBundle.LoadFromFile(full_name)
    CS.FairyGUI.UIPackage.AddPackage(ab)
end

---------------------------------------
-- 初始化LaunchStep
function Context:_initLaunchStep()
    -- 检测Bundle是否需要更新
    if (BundleUpdateStata == 1 and BundleUpdateVersion ~= nil and BundleUpdateURL ~= nil and self.CasinosContext.Config.VersionBundle ~= BundleUpdateVersion)
    then
        self.LaunchStep[1] = "UpdateBundle"
    end

    -- 检测是否需要首次运行解压
    self.LaunchStep[2] = "CopyStreamingAssetsToPersistentData"

    -- 检测是否需要更新Data
    if (DataVersion ~= self.CasinosContext.Config.VersionDataPersistent)
    then
        self.LaunchStep[3] = "UpdateData"
    end

    -- 进入Login界面
    self.LaunchStep[4] = "ShowLogin"
end

---------------------------------------
-- 执行下一步LaunchStep
function Context:_nextLaunchStep()
    -- 更新Bundle
    if (self.LaunchStep[1] ~= nil)
    then
        local desc_copy = "准备更新安装包"
        self.Launch.PreLoading:UpdateDesc(desc_copy)
        self.Launch.PreLoading:UpdateLoadingProgress(0, 100)

        local view_premsgbox = self.PreViewMgr.createView("PreMsgBox")
        view_premsgbox:showMsgBox(self.CasinosContext.Config.VersionBundle,
                function()
                    print('更新安装包')
                end,
                function()
                    print('退出游戏')
                end
        )

        return
    end

    -- 首次运行解压
    if (self.LaunchStep[2] ~= nil)
    then
        local desc_copy = "首次运行解压资源，不消耗流量"
        self.Launch.PreLoading:UpdateDesc(desc_copy)
        self.Launch.PreLoading:UpdateLoadingProgress(0, 100)
        if (self.CopyStreamingAssetsToPersistentData == nil)
        then
            self.CopyStreamingAssetsToPersistentData = CS.Casinos.CopyStreamingAssetsToPersistentData2()
            self.CopyStreamingAssetsToPersistentData:CopyAsync('')
        end
        self.TimerUpdateCopyStreamingAssetsToPersistentData = self.CasinosContext.TimerShaft:RegisterTimer(30, self._timerUpdateCopyStreamingAssetsToPersistentData)
        return
    end

    -- 更新Data
    if (self.LaunchStep[3] ~= nil)
    then
        local desc_copy = "更新游戏数据"
        self.Launch.PreLoading:UpdateDesc(desc_copy)
        self.Launch.PreLoading:UpdateLoadingProgress(0, 100)
        local http_url = DataRootURL .. DataFileListFileName
        print(http_url)
        local async_asset_loadgroup = CS.Casinos.CasinosContext.Instance.AsyncAssetLoadGroup
        async_asset_loadgroup:LoadWWWAsync(http_url,
                function(url, www)
                    -- 比较Oss上的datafilelist.txt和Persistent中的datafilelist.txt差异集，获取需要更新的Data列表
                    local datafilelist_persistent = self.CasinosContext.PathMgr:combinePersistentDataPath(DataFileListFileName)
                    print(datafilelist_persistent)
                    self.RemoteDataFileListContent = www.text
                    local persistent_datafilelist_content = self.CasinosLua:ReadAllText(datafilelist_persistent)
                    self.UpdateRemoteToPersistentData = CS.Casinos.UpdateRemoteToPersistentData()
                    local update_data_count = self.UpdateRemoteToPersistentData:UpateAsync(self.RemoteDataFileListContent, persistent_datafilelist_content, DataRootURL)
                    print('需更新Data数量：' .. update_data_count)
                    self.TimerUpdateRemoteToPersistentData = self.CasinosContext.TimerShaft:RegisterTimer(30, self._timerUpdateRemoteToPersistentData)
                end
        )
        return
    end

    -- 卸载Launch，加载并显示Login
    if (self.LaunchStep[4] ~= nil)
    then
        self.LaunchStep[4] = nil

        local desc_copy = "准备进入登录界面"
        self.Launch.PreLoading:UpdateDesc(desc_copy)
        self.Launch.PreLoading:UpdateLoadingProgress(100, 100)

        local path_lua_root = self.CasinosContext.PathMgr:combinePersistentDataPath("Script.Lua/");
        self.CasinosLua:LoadLuaFromDir(path_lua_root);

        --local config_production = CS.Casinos.ConfigSection()
        --config_production.UCenterDomain = CS.Casinos.UiHelper.formateAndoridIOSUrl(UCenterDomain)
        --config_production.AutopatcherUrl = CS.Casinos.UiHelper.formateAndoridIOSUrl(AutopatcherUrl)
        --config_production.PlayerIconDomain = CS.Casinos.UiHelper.formateAndoridIOSUrl(PlayerIconDomain)
        --config_production.BotIconDomain = CS.Casinos.UiHelper.formateAndoridIOSUrl(BotIconDomain)
        --config_production.GatewayIp = GatewayIp
        --config_production.GatewayPort = GatewayPort
        --config_production.Tips = casinos_context.UserConfig.ConfigProduction.Tips
        --casinos_context.UserConfig.ConfigProduction = config_production
        local show_fps = ClientShowFPS
        local show_fps_obj = self.CasinosContext.Config.GoConfig:GetComponent("ShowFPS")
        show_fps_obj.enabled = show_fps
        if (FPSLimit == -1)
        then
            CS.UnityEngine.QualitySettings.vSyncCount = 0
        elseif (FPSLimit == 30)
        then
            CS.UnityEngine.QualitySettings.vSyncCount = 2
        elseif (FPSLimit == 60)
        then
            CS.UnityEngine.QualitySettings.vSyncCount = 1
        else
            CS.UnityEngine.QualitySettings.vSyncCount = 0
            CS.UnityEngine.Application.targetFrameRate = 60
        end

        local show_weichat = ClientShowWeiChat
        self.CasinosContext.ShowWeiChat = show_weichat
        self.CasinosContext.NeedHideClientUi = NeedHideClientUi
        self.CasinosContext.ClientShowFirstRecharge = ClientShowFirstRecharge
        self.CasinosContext.DesktopHSysBankShowDBValue = DesktopHSysBankShowDBValue
        self.CasinosContext.ShootingTextShowVIPLimit = ShootingTextShowVIPLimit
        self.CasinosContext.DesktopHCanChatVIPLimit = DesktopHCanChatVIPLimit
        self.CasinosContext.DesktopCanChatVIPLimit = DesktopCanChatVIPLimit
        self.CasinosContext.CanReportLog = CanReportLog
        self.CasinosContext.CanReportLogDeviceId = CanReportLogDeviceId
        self.CasinosContext.CanReportLogPlayerId = CanReportLogPlayerId
        self.CasinosContext.ShowGoldTree = ShowGoldTree
        if (self.CasinosContext.UnityAndroid == true)
        then
            self.CasinosContext.UseWeiChatPay = UseWeiChatPay
            self.CasinosContext.UseALiPay = UseALiPay
        end
        --self.CasinosContext.UseIAP = UseIAP
        self.CasinosContext.UseLan = UseLan
        self.CasinosContext.UseDefaultLan = UseDefaultLan
        self.CasinosContext.DefaultLan = DefaultLan
        self.CasinosContext.CSharpLastMethodId = CSharpLastMethodId
        self.CasinosContext.BuglyAppId = BuglyAppId
        self.CasinosContext.PinggPPAppId = PinggPPAppId
        self.CasinosContext.WeChatAppId = WeChatAppId
        self.CasinosContext.WeChatState = WeChatState
        self.CasinosContext.DataEyeId = DataEyeId
        self.CasinosContext.PushAppId = PushAppId
        self.CasinosContext.PushAppKey = PushAppKey
        self.CasinosContext.PushAppSecret = PushAppSecret
        self.CasinosContext.ShareSDKAppKey = ShareSDKAppKey
        self.CasinosContext.ShareSDKAppSecret = ShareSDKAppSecret

        self:DoString("LuaHelper")
        self.LuaHelper = LuaHelper:new(nil)
        self:DoString("TexasHelper")
        self:DoString("TbDataMgr")
        self:DoString("TbDataBase")
        self:DoString("TbDataMgrBase")
        self.TbDataMgr = TbDataMgr:new(nil)
        --self.TbDataMgr:onCreate()
        self:_regTbData()

        local t_db = {}
        for i, v in pairs(TbFileList) do
            t_db[i] = CS.Casinos.CasinosContext.Instance.PathMgr:combinePersistentDataPath("resources.kingtexasraw/tbdata/" .. v .. ".db")
        end
        self.TbDataMgrBase = TbDataMgrBase:new(nil, self.TbDataMgr, t_db,
                function()
                    self:LoadDataDone()
                end
        )

        self:DoString("EventSys")
        self.EventSys = EventSys:new(nil)
        self.EventSys:onCreate()

        self:DoString("ViewMgr")
        self.ViewMgr = ViewMgr:new(nil)
        self.ViewMgr:onCreate("Resources.KingTexas/Ui/", "Resources.KingTexasRaw/")
        self.ViewMgr.TbDataMgr = self.TbDataMgr
        self:_regView()
        self:DoString("ViewHelper")
        ViewHelper:new(nil)

        self:DoString("LanBase")
        self:DoString("LanEn")
        self:DoString("LanMgr")
        self:DoString("LanZh")

        self:DoString("UiChipShowHelper")
        self.UiChipShowHelper = UiChipShowHelper:new(nil)
        --self:DoString("ParticleHelper")

        self:DoString("MessagePack")
        self:DoString("json")
        self.Json = require("json")
        self:DoString("RPC")
        local rpc = RPC:new(nil)

        self:DoString("ControllerMgr")
        self.ControllerMgr = ControllerMgr:new(nil)
        self.ControllerMgr:OnCreate()
        self.ControllerMgr.TbDataMgr = self.TbDataMgr
        self.ControllerMgr.RPC = rpc
        self.ControllerMgr.Listener = self
        self:_regController()
        self.ViewMgr.ControllerMgr = self.ControllerMgr
        self.ViewMgr.RPC = rpc
        self.ViewMgr.Listener = self

        self:_addUiPackage()
        
        -- 加载登录界面
        self.ControllerMgr:CreateController("UCenter", nil, nil)
        self.ControllerMgr:CreateController("Login", nil, nil)
        PreViewMgr:destroyView(self.Launch.PreLoading)
        PreViewMgr:destroyView(self.Launch.PreMsgBox)
    end
end

---------------------------------------
-- 定时器，首次运行解压。被C#回调，没有传递self。
function Context:_timerUpdateCopyStreamingAssetsToPersistentData()
    local is_done = Context.CopyStreamingAssetsToPersistentData:IsDone()
    if (is_done)
    then
        Context.TimerUpdateCopyStreamingAssetsToPersistentData:Close()
        Context.TimerUpdateCopyStreamingAssetsToPersistentData = nil
        Context.CopyStreamingAssetsToPersistentData = nil

        -- 执行下一步LaunchStep
        Context.LaunchStep[2] = nil
        Context:_nextLaunchStep()
    else
        local value = Context.CopyStreamingAssetsToPersistentData.LeftCount
        local max = Context.CopyStreamingAssetsToPersistentData.TotalCount
        Context.Launch.PreLoading:UpdateLoadingProgress(max - value, max)
    end
end

---------------------------------------
-- 定时器，更新Data。被C#回调，没有传递self。
function Context:_timerUpdateRemoteToPersistentData()
    local is_done = Context.UpdateRemoteToPersistentData:IsDone()
    if (is_done)
    then
        Context.TimerUpdateRemoteToPersistentData:Close()
        Context.TimerUpdateRemoteToPersistentData = nil
        Context.UpdateRemoteToPersistentData = nil

        -- 用Remote DataFileList.txt覆盖Persistent中的；并更新VersionDataPersistent
        local datafilelist_persistent = Context.CasinosContext.PathMgr:combinePersistentDataPath(DataFileListFileName)
        CS.System.IO.File.WriteAllText(datafilelist_persistent, Context.RemoteDataFileListContent)
        Context.RemoteDataFileListContent = nil
        Context.CasinosContext.Config:WriteVersionDataPersistent(DataVersion)

        -- 执行下一步LaunchStep
        Context.LaunchStep[3] = nil
        Context:_nextLaunchStep()
    else
        local value = Context.UpdateRemoteToPersistentData.LeftCount
        local max = Context.UpdateRemoteToPersistentData.TotalCount
        Context.Launch.PreLoading:UpdateLoadingProgress(max - value, max)
    end
end

---------------------------------------
function Context:_regController()
    self:DoString("ControllerLogin")
    local con_login_fac = ControllerLoginFactory:new(nil)
    self.ControllerMgr:RegController("Login", con_login_fac)
    self:DoString("ControllerUCenter")
    local con_ucenter_fac = ControllerUCenterFactory:new(nil)
    self.ControllerMgr:RegController("UCenter", con_ucenter_fac)
    self:DoString("ControllerActivity")
    local con_activity_fac = ControllerActivityFactory:new(nil)
    self.ControllerMgr:RegController("Activity", con_activity_fac)
    self:DoString("ControllerActor")
    local con_actor_fac = ControllerActorFactory:new(nil)
    self.ControllerMgr:RegController("Actor", con_actor_fac)
    self:DoString("ControllerBag")
    local con_bag_fac = ControllerBagFactory:new(nil)
    self.ControllerMgr:RegController("Bag", con_bag_fac)
    self:DoString("ControllerDesk")
    local con_desk_fac = ControllerDeskFactory:new(nil)
    self.ControllerMgr:RegController("Desk", con_desk_fac)
    self:DoString("ControllerDeskH")
    local con_deskh_fac = ControllerDeskHFactory:new(nil)
    self.ControllerMgr:RegController("DeskH", con_deskh_fac)
    self:DoString("ControllerGrow")
    local con_grow_fac = ControllerGrowFactory:new(nil)
    self.ControllerMgr:RegController("Grow", con_grow_fac)
    self:DoString("ControllerIM")
    self:DoString("IMChat")
    self:DoString("IMFeedback")
    self:DoString("IMChatRecord")
    self:DoString("IMFriendList")
    self:DoString("IMMailBox")
    local con_im_fac = ControllerIMFactory:new(nil)
    self.ControllerMgr:RegController("IM", con_im_fac)
    self:DoString("ControllerLobby")
    local con_lobby_fac = ControllerLobbyFactory:new(nil)
    self.ControllerMgr:RegController("Lobby", con_lobby_fac)
    self:DoString("ControllerLotteryTicket")
    local con_lottery_fac = ControllerLotteryTicketFactory:new(nil)
    self.ControllerMgr:RegController("LotteryTicket", con_lottery_fac)
    self:DoString("ControllerMarquee")
    local con_marquee_fac = ControllerMarqueeFactory:new(nil)
    self.ControllerMgr:RegController("Marquee", con_marquee_fac)
    self:DoString("ControllerPlayer")
    local con_player_fac = ControllerPlayerFactory:new(nil)
    self.ControllerMgr:RegController("Player", con_player_fac)
    self:DoString("ControllerRanking")
    local con_ranking_fac = ControllerRankingFactory:new(nil)
    self.ControllerMgr:RegController("Ranking", con_ranking_fac)
    self:DoString("ControllerTrade")
    local con_trade_fac = ControllerTradeFactory:new(nil)
    self.ControllerMgr:RegController("Trade", con_trade_fac)
    self:DoString("ControllerMTT")
    local con_mtt = ControllerMTTFactory:new(nil)
    self.ControllerMgr:RegController("Mtt", con_mtt)
    self:DoString("Prop")
    self:DoString("Item")
    self:DoString("ItemData1")
    self:DoString("Unit")
    self:DoString("UnitBilling")
    self:DoString("UnitConsume")
    self:DoString("UnitGoodsVoucher")
    self:DoString("UnitGoldPackage")
    self:DoString("UnitGiftNormal")
    self:DoString("UnitRedEnvelopes")
    self:DoString("UnitGiftTmp")
    self:DoString("UnitMagicExpression")
    self:DoString("OnLineReward")
    self:DoString("TimingReward")
end

---------------------------------------
function Context:_regView()
    self:DoString("ViewLoading")
    local view_loading_fac = ViewLoadingFactory:new(nil, "Loading", "Loading", "Loading", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Loading", view_loading_fac)
    self:DoString("ViewMsgBox")
    local view_msgbox_fac = ViewMsgBoxFactory:new(nil, "Common", "MsgBox", "Waiting", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("MsgBox", view_msgbox_fac)
    self:DoString("ViewLogin")
    self:DoString("UiResetPwd")
    self:DoString("UiRegister")
    self:DoString("UiChooseCountryCode")
    local view_login_fac = ViewLoginFactory:new(nil, "Login", "Login", "Background", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Login", view_login_fac)
    self:DoString("ViewAbout")
    local view_about_fac = ViewAboutFactory:new(nil, "About", "About", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("About", view_about_fac)
    self:DoString("ViewDesktopChatParent")
    local view_chatparent_fac = ViewDesktopChatParentFactory:new(nil, "DesktopChatParent", "DesktopChatParent", "DesktopChat", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopChatParent", view_chatparent_fac)
    self:DoString("ViewFloatMsg")
    local view_floatmsg_fac = ViewFloatMsgFactory:new(nil, "Common", "FloatMsg", "Waiting", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("FloatMsg", view_floatmsg_fac)
    self:DoString("ViewMailDetail")
    local view_maildetail_fac = ViewMailDetailFactory:new(nil, "MailDetail", "MailDetail", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("MailDetail", view_maildetail_fac)
    self:DoString("ViewNotice")
    local view_notice_fac = ViewNoticeFactory:new(nil, "Notice", "Notice", "Loading", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Notice", view_notice_fac)
    self:DoString("ViewPayType")
    local view_paytype_fac = ViewPayTypeFactory:new(nil, "PayType", "PayType", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("PayType", view_paytype_fac)
    self:DoString("ViewPermanentPosMsg")
    local view_permanent_fac = ViewPermanentPosMsgFactory:new(nil, "Common", "PermanentPosMsg", "Loading", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("PermanentPosMsg", view_permanent_fac)
    self:DoString("ViewPool")
    local view_pool_fac = ViewPoolFactory:new(nil, "Pool", "Pool", "None", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Pool", view_pool_fac)
    self:DoString("ViewShootingText")
    local view_shooting_fac = ViewShootingTextFactory:new(nil, "ShootingText", "ShootingText", "ShootingText", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("ShootingText", view_shooting_fac)
    self:DoString("ViewTakePhoto")
    local view_takephoto_fac = ViewTakePhotoFactory:new(nil, "TakePhoto", "TakePhoto", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("TakePhoto", view_takephoto_fac)
    self:DoString("ViewWaiting")
    local view_waiting_fac = ViewWaitingFactory:new(nil, "Common", "Waiting", "Waiting", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Waiting", view_waiting_fac)
    self:DoString("ViewWaitingCountDown")
    local view_waiting1_fac = ViewWaitingCountDownFactory:new(nil, "Common", "WaitingCountDown", "Waiting", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("WaitingCountDown", view_waiting1_fac)
    self:DoString("ViewLotteryTicket")
    self:DoString("ViewLotteryTicketBase")
    self:DoString("ViewLotteryTicketRewardPot")
    self:DoString("ViewLotteryTicketTexas")
    self:DoString("ItemLotteryTicketBetOperate")
    self:DoString("ItemLotteryTicketBetPot")
    self:DoString("ItemLotteryTicketCard")
    self:DoString("ItemLotteryTicketHistory")
    self:DoString("ItemLotteryTicketRewardPotPlayerInfo")
    local view_lottery_fac = ViewLotteryTicketFactory:new(nil, "LotteryTicket", "LotteryTicket", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("LotteryTicket", view_lottery_fac)
    self:DoString("ViewDesktopTexas")
    self:DoString("PlayerSeatWidgetControllerTexas")
    self:DoString("PlayerOperateAni")
    self:DoString("PlayerShowTips")
    self:DoString("ViewHandCardTexas")
    self:DoString("ViewPotTexasPoker")
    self:DoString("ViewDesktopTypeBase")
    self:DoString("ViewTexasClassic")
    self:DoString("ViewTexasMTT")
    self:DoString("DealerEx")
    self:DoString("ViewMTTGameResult")
    self:DoString("ItemMttRewardItem")
    local view_mttresult_fac = ViewMTTGameResultFactory:new(nil, "MTTGameResult", "MTTGameResult", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("MTTGameResult", view_mttresult_fac)
    self:DoString("ViewMTTProcess")
    local view_mttprocess_fac = ViewMTTProcessFactory:new(nil, "MTTProcess", "MTTProcess", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("MTTProcess", view_mttprocess_fac)
    self:DoString("UiCardCommonEx")
    self:DoString("UiCardDealingEx")
    self:DoString("UiChipEx")
    self:DoString("UiChipMgrEx")
    self:DoString("ViewPlayerGiftAndVIP")
    self:DoString("DesktopPlayerTexas")
    self:DoString("DesktopBase")
    self:DoString("DesktopTexas")
    self:DoString("DesktopHelperBase")
    self:DoString("DesktopHelperTexas")
    self:DoString("DesktopTypeBase")
    self:DoString("DesktopTexasClassic")
    self:DoString("DesktopTexasMTT")
    local view_desktoptexas_fac = ViewDesktopTexasFactory:new(nil, "Desktop", "Desktop", "Background", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopTexas", view_desktoptexas_fac)
    self:DoString("ViewDesktopPlayerInfoTexas")
    local view_desktopplayerinfotexas_fac = ViewDesktopPlayerInfoTexasFactory:new(nil, "DesktopPlayerInfo", "DesktopPlayerInfo", "SceneActor", false, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopPlayerInfoTexas", view_desktopplayerinfotexas_fac)
    self:DoString("ViewDesktopPlayerOperateTexas")
    self:DoString("DesktopFastBet")
    local view_desktopoperatetexas_fac = ViewDesktopPlayerOperateTexasFactory:new(nil, "DesktopPlayerOperate", "DesktopPlayerOperate", "PlayerOperateUi", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopPlayerOperateTexas", view_desktopoperatetexas_fac)
    self:DoString("ViewLockChatTexas")
    local view_lockchattexas_fac = ViewLockChatTexasFactory:new(nil, "LockChat", "LockChat", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("LockChatTexas", view_lockchattexas_fac)
    self:DoString("ViewDesktopHintsTexas")
    local view_desktophintstexas_fac = ViewDesktopHintsTexasFactory:new(nil, "DesktopHints", "DesktopHints", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopHintsTexas", view_desktophintstexas_fac)
    self:DoString("ViewDesktopMenuTexas")
    local view_desktopmenutexas_fac = ViewDesktopMenuTexasFactory:new(nil, "DesktopMenu", "DesktopMenu", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopMenuTexas", view_desktopmenutexas_fac)
    self:DoString("ViewDesktopChatExpression")
    local view_desktopchatexp_fac = ViewDesktopChatExpressionFactory:new(nil, "ChatExPression", "ChatExPression", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("ChatExPression", view_desktopchatexp_fac)
    self:DoString("ViewDesktopH")
    self:DoString("ViewDesktopHBase")
    self:DoString("ViewDesktopHTexas")
    self:DoString("DesktopHBase")
    self:DoString("DesktopHTexas")
    self:DoString("DesktopHUiGold")
    self:DoString("DesktopHDealer")
    self:DoString("DesktopHBankPlayer")
    self:DoString("DesktopHCard")
    self:DoString("DesktopHCards")
    self:DoString("DesktopHCardTypeBase")
    self:DoString("DesktopHCardTypeTexas")
    self:DoString("DesktopHGoldPool")
    self:DoString("DesktopHRewardPot")
    self:DoString("DesktopHSelf")
    self:DoString("DesktopHStandPlayer")
    self:DoString("DesktopHChair")
    self:DoString("DesktopHChair")
    self:DoString("GoldController")
    self:DoString("DesktopHBetPot")
    local view_desktoph_fac = ViewDesktopHFactory:new(nil, "DesktopH", "DesktopH", "Background", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopH", view_desktoph_fac)
    self:DoString("ViewDesktopHBankList")
    local view_desktophbanklist_fac = ViewDesktopHBankListFactory:new(nil, "DesktopHBankPlayerList", "DesktopHBankPlayerList", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopHBankList", view_desktophbanklist_fac)
    self:DoString("ViewDesktopHBetReward")
    local view_desktophbetreward_fac = ViewDesktopHBetRewardFactory:new(nil, "DesktopHBetReward", "DesktopHBetReward", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopHBetReward", view_desktophbetreward_fac)
    self:DoString("ViewDesktopHCardType")
    local view_desktophcardtype_fac = ViewDesktopHCardTypeFactory:new(nil, "DesktopHCardType", "DesktopHCardType", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopHCardType", view_desktophcardtype_fac)
    self:DoString("ViewDesktopHHelp")
    local view_desktophhelp_fac = ViewDesktopHHelpFactory:new(nil, "DesktopHHelp", "DesktopHHelp", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopHHelp", view_desktophhelp_fac)
    self:DoString("ViewDesktopHHistory")
    local view_desktophhistory_fac = ViewDesktopHHistoryFactory:new(nil, "DesktopHHistory", "DesktopHHistory", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopHHistory", view_desktophhistory_fac)
    self:DoString("ViewDesktopHMenu")
    local view_desktophmenu_fac = ViewDesktopHMenuFactory:new(nil, "DesktopHMenu", "DesktopHMenu", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopHMenu", view_desktophmenu_fac)
    self:DoString("ViewDesktopHResult")
    local view_desktophresult_fac = ViewDesktopHResultFactory:new(nil, "DesktopHResult", "DesktopHResult", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopHResult", view_desktophresult_fac)
    self:DoString("ViewDesktopHSetCardType")
    local view_desktophsetcardtype_fac = ViewDesktopHSetCardTypeFactory:new(nil, "DesktopHSetCardType", "DesktopHSetCardType", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopHSetCardType", view_desktophsetcardtype_fac)
    self:DoString("ViewDesktopHRewardPot")
    local view_desktophrewardpot_fac = ViewDesktopHRewardPotFactory:new(nil, "DesktopHRewardPot", "DesktopHRewardPot", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DesktopHRewardPot", view_desktophrewardpot_fac)
    self:DoString("ViewAgreeOrDisAddFriendRequest")
    local view_agreefriend_fac = ViewAgreeOrDisAddFriendRequestFactory:new(nil, "AgreeOrDisAddFriendRequest", "AgreeOrDisAddFriendRequest", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("AgreeOrDisAddFriendRequest", view_agreefriend_fac)
    self:DoString("ViewBag")
    local view_bag_fac = ViewBagFactory:new(nil, "Bag", "Bag", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Bag", view_bag_fac)
    self:DoString("ViewBank")
    local view_bank_fac = ViewBankFactory:new(nil, "Bank", "Bank", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Bank", view_bank_fac)
    self:DoString("ViewChat")
    local view_chat_fac = ViewChatFactory:new(nil, "Chat", "Chat", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Chat", view_chat_fac)
    self:DoString("ViewChatChooseTarget")
    local view_chatchoose_fac = ViewChatChooseTargetFactory:new(nil, "ChatChooseTarget", "ChatChooseTarget", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("ChatChooseTarget", view_chatchoose_fac)
    self:DoString("ViewChatFriend")
    local view_chatfriend_fac = ViewChatFriendFactory:new(nil, "ChatFriend", "ChatFriend", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("ChatFriend", view_chatfriend_fac)
    self:DoString("ViewChipOperate")
    local view_chipoperate_fac = ViewChipOperateFactory:new(nil, "ChipOperate", "ChipOperate", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("ChipOperate", view_chipoperate_fac)
    self:DoString("ViewChooseLan")
    local view_chooselan_fac = ViewChooseLanFactory:new(nil, "ChooseLan", "ChooseLan", "Background", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("ChooseLan", view_chooselan_fac)
    self:DoString("ViewShare")
    local view_share_fac = ViewShareFactory:new(nil, "Share", "Share", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Share", view_share_fac)
    self:DoString("ViewShareType")
    local view_sharetype_fac = ViewShareTypeFactory:new(nil, "ShareType", "ShareType", "NomalUi", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("ShareType", view_sharetype_fac)
    self:DoString("ViewCreateDesktop")
    local view_createdesktop_fac = ViewCreateDesktopFactory:new(nil, "CreateDeskTop", "CreateDeskTop", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("CreateDeskTop", view_createdesktop_fac)
    self:DoString("ViewDailyReward")
    local view_dailyreward_fac = ViewDailyRewardFactory:new(nil, "DailyReward", "DailyReward", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("DailyReward", view_dailyreward_fac)
    self:DoString("ViewEdit")
    local view_edit_fac = ViewEditFactory:new(nil, "Edit", "Edit", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Edit", view_edit_fac)
    self:DoString("ViewFriend")
    local view_friend_fac = ViewFriendFactory:new(nil, "Friend", "Friend", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Friend", view_friend_fac)
    self:DoString("ViewFriendOnLine")
    local view_friendonline_fac = ViewFriendOnLineFactory:new(nil, "FriendOnLine", "FriendOnLine", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("FriendOnLine", view_friendonline_fac)
    self:DoString("ViewGiftDetail")
    local view_giftdetail_fac = ViewGiftDetailFactory:new(nil, "GiftDetail", "GiftDetail", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("GiftDetail", view_giftdetail_fac)
    self:DoString("ViewGiftShop")
    local view_giftshop_fac = ViewGiftShopFactory:new(nil, "GiftShop", "GiftShop", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("GiftShop", view_giftshop_fac)
    self:DoString("ViewGoldTree")
    local view_goldtree_fac = ViewGoldTreeFactory:new(nil, "GoldTree", "GoldTree", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("GoldTree", view_goldtree_fac)
    self:DoString("ViewInviteFriendPlay")
    local view_invite_fac = ViewInviteFriendPlayFactory:new(nil, "InviteFriendPlay", "InviteFriendPlay", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("InviteFriendPlay", view_invite_fac)
    self:DoString("ViewIdCardCheck")
    local id_check_fac = ViewIdCardCheckFactory:new(nil, "IdCardCheck", "IdCardCheck", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("IdCardCheck", id_check_fac)
    self:DoString("ViewLobby")
    local view_classicmodel_fac = ViewLobbyFactory:new(nil, "ClassicModel", "ClassicModel", "Background", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("ClassicModel", view_classicmodel_fac)
    self:DoString("ViewMail")
    local view_viewmail_fac = ViewMailFactory:new(nil, "Mail", "Mail", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Mail", view_viewmail_fac)
    self:DoString("ViewMain")
    self:DoString("ViewOnlineReward")
    self:DoString("ViewTimingReward")
    self:DoString("UiMainPlayerInfo")
    local view_viewmain_fac = ViewMainFactory:new(nil, "Main", "Main", "Background", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Main", view_viewmain_fac)
    self:DoString("ViewFeedback")
    local view_viewfeedback_fac = ViewFeedbackFactory:new(nil, "Feedback", "Feedback", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Feedback", view_viewfeedback_fac)
    self:DoString("ViewPlayerInfo")
    local view_playerinfo_fac = ViewPlayerInfoFactory:new(nil, "PlayerInfo", "PlayerInfo", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("PlayerInfo", view_playerinfo_fac)
    self:DoString("ViewPlayerProfile")
    local view_playerprofile_fac = ViewPlayerProfileFactory:new(nil, "PlayerProfile", "PlayerProfile", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("PlayerProfile", view_playerprofile_fac)
    self:DoString("ViewActivityCenter")
    local view_activitycenter_fac = ViewActivityCenterFactory:new(nil, "ActivityCenter", "ActivityCenter", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("ActivityCenter", view_activitycenter_fac)
    self:DoString("ViewQuitOrBack")
    local view_back_fac = ViewQuitOrBackFactory:new(nil, "QuitOrBack", "QuitOrBack", "QuitGame", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("QuitOrBack", view_back_fac)
    self:DoString("ViewRanking")
    local view_ranking_fac = ViewRankingFactory:new(nil, "Ranking", "Ranking", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Ranking", view_ranking_fac)
    self:DoString("ViewRechargeFirst")
    local view_recharge_fac = ViewRechargeFirstFactory:new(nil, "RechargeFirst", "RechargeFirst", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("RechargeFirst", view_recharge_fac)
    self:DoString("ViewResetPwd")
    local view_resetpwd_fac = ViewResetPwdFactory:new(nil, "ResetPwd", "ResetPwd", "NomalUi", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("ResetPwd", view_resetpwd_fac)
    self:DoString("ViewShop")
    local view_shop_fac = ViewShopFactory:new(nil, "Shop", "Shop", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Shop", view_shop_fac)
    self:DoString("ViewPurse")
    local view_purse_fac = ViewPurseFactory:new(nil, "Purse", "Purse", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Purse", view_purse_fac)
    self:DoString("ViewHeadIcon")
    self:DoString("ViewVIPSign")
    self:DoString("ViewHeadIconBig")
    local view_headionbig_fac = ViewHeadIconBigFactory:new(nil, "Common", "CoHeadIconBig", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("HeadIconBig", view_headionbig_fac)
    self:DoString("ViewActivityPopUpBox")
    local view_activity_popupbox_fac = ViewActivityPopUpBoxFactory:new(nil, "ActivityPopUpBox", "ActivityPopUpBox", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("ActivityPopUpBox", view_activity_popupbox_fac)
    self:DoString("ViewMatchLobby")
    local view_matchlobby_fac = ViewMatchLobbyFactory:new(nil, "MatchLobby", "MatchLobby", "Background", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("MatchLobby", view_matchlobby_fac)
    self:DoString("ViewApplySucceed")
    local view_applysucceed_fac = ViewApplySucceedFactory:new(nil, "ApplySucceed", "ApplySucceed", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("ApplySucceed", view_applysucceed_fac)
    self:DoString("ViewMatchInfo")
    local view_matchinfo_fac = ViewMatchInfoFactory:new(nil, "MatchInfo", "MatchInfo", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("MatchInfo", view_matchinfo_fac)
    self:DoString("ViewClub")
    local view_club_fac = ViewClubFactory:new(nil, "Club", "Club", "Background", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("Club", view_club_fac)
    self:DoString("ViewCreateMatch")
    local view_creatematch = ViewCreateMatchFactory:new(nil, "CreateMatch", "CreateMatch", "NomalUiMain", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("CreateMatch", view_creatematch)
    self:DoString("ViewBlindTable")
    local view_blindtable = ViewBlindTableFactory:new(nil, "BlindTable", "BlindTable", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("BlindTable", view_blindtable)
    self:DoString("ViewClubHelp")
    local view_clubhelp = ViewClubHelpFactory:new(nil, "ClubHelp", "ClubHelp", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("ClubHelp", view_clubhelp)
    self:DoString("ViewJoinMatch")
    local view_joinmatch = ViewJoinMatchFactory:new(nil, "JoinMatch", "JoinMatch", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("JoinMatch", view_joinmatch)
    self:DoString("ViewGetChipEffect")
    local view_getchipeffect = ViewGetChipEffectFactory:new(nil, "GetChipEffect", "GetChipEffect", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("GetChipEffect", view_getchipeffect)
    self:DoString("ViewEnterMatchNotify")
    local view_enterMatchNotify = ViewEnterMatchNotifyFactory:new(nil, "EnterMatchNotify", "EnterMatchNotify", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("EnterMatchNotify", view_enterMatchNotify)
    self:DoString("ViewSnowBallReward")
    local view_snowBallRewardFactory = ViewSnowBallRewardFactory:new(nil, "SnowBallReward", "SnowBallReward", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("SnowBallReward", view_snowBallRewardFactory)
    self:DoString("ViewEditAddress")
    local view_editAddressFactory = ViewEditAddressFactory:new(nil, "EditAddress", "EditAddress", "MessgeBox", true, CS.FairyGUI.FitScreen.FitSize)
    self.ViewMgr:regView("EditAddress", view_editAddressFactory)
    --Item
    self:DoString("ItemDesktopHBeBankPlayerInfo")
    self:DoString("ItemDesktopHBetOperate")
    self:DoString("ItemDesktopHBetPot")
    self:DoString("ItemDesktopHBetReward")
    self:DoString("ItemDesktopHGameEndPotResult")
    self:DoString("ItemDesktopHGameEndWinPlayer")
    self:DoString("ItemDesktopHHistroy")
    self:DoString("ItemDesktopHSeat")
    self:DoString("ItemDesktopHSetCardType")
    self:DoString("ItemUiDesktopHTongPei")
    self:DoString("ItemUiDesktopHTongSha")
    self:DoString("ItemLotteryTicketBetOperate")
    self:DoString("ItemLotteryTicketBetPot")
    self:DoString("ItemLotteryTicketCard")
    self:DoString("ItemLotteryTicketHistory")
    self:DoString("ItemLotteryTicketRewardPotPlayerInfo")
    self:DoString("ItemAttachment")
    self:DoString("ItemBetChipRange")
    self:DoString("ItemChatEx")
    self:DoString("ItemChatPresetMsg")
    self:DoString("ItemDailyReward")
    self:DoString("ItemDesktopHintsInfo")
    self:DoString("ItemDesktopRaiseOperateGFlower")
    self:DoString("ItemHeadIcon")
    self:DoString("ItemHeadIconWithNickName")
    self:DoString("ItemMagicExpIcon")
    self:DoString("ItemMagicExpSender")
    self:DoString("ItemMail")
    self:DoString("ItemNotice")
    self:DoString("ItemNumOperate")
    self:DoString("ItemPlayerChatLock")
    self:DoString("ItemPlayerReport")
    self:DoString("ItemChatDesktop")
    self:DoString("ItemCountryCode")
    self:DoString("ItemChatTargetInfo")
    self:DoString("ItemChooseChatTargetInfo")
    self:DoString("ItemDesktopHRewardPotPlayerInfo")
    self:DoString("ItemAnte")
    self:DoString("ItemGift")
    self:DoString("ItemGiftType")
    self:DoString("ItemInviteFriendPlay")
    self:DoString("ItemLan")
    self:DoString("ItemLobbyDesk")
    self:DoString("ItemLobbyDeskPlayInfo")
    self:DoString("ItemMainOperate")
    self:DoString("ItemRank")
    self:DoString("ItemReportPlayerOperate")
    self:DoString("ItemShowFriendSimple")
    self:DoString("ItemUiShopConsume")
    self:DoString("ItemUiShopDiamond")
    self:DoString("ItemUiShopGold")
    self:DoString("ItemUiShopVIPInfo")
    self:DoString("ItemUiShopVIPInfo")
    self:DoString("ItemVIPBuyInfo")
    self:DoString("ItemActivity")
    self:DoString("ItemActivityTitle")
    self:DoString("ItemUiShopGoods")
    self:DoString("ItemUiPurseGold")
    self:DoString("ItemMatchType")
    self:DoString("ItemMatchInfo")
    self:DoString("ItemBlind")
    self:DoString("ItemMatchInfoBlind")
    self:DoString("ItemMatchInfoReward")
    self:DoString("ItemSnowBallRewardPlayerNum")
    self:DoString("ItemSnowBallRewardInfo")
    self:DoString("ItemMatchInfoRank")
end

---------------------------------------
function Context:_addUiPackage()
    self:AddUiPackage("LotteryTicket")
    self:AddUiPackage("Chat")
    self:AddUiPackage("ChatFriend")
    self:AddUiPackage("About")
    self:AddUiPackage("Mail")
    self:AddUiPackage("PayType")
    self:AddUiPackage("Common")
    self:AddUiPackage("ChooseLan")
    self:AddUiPackage("Share")
    self:AddUiPackage("ShareType")
    self:AddUiPackage("Loading")
    self:AddUiPackage("LanZh")
    if CS.Casinos.CasinosContext.Instance.UnityAndroid then
        self:AddUiPackage("LanEn")
        self:AddUiPackage("LanZhAndroid")
    end
    self:AddUiPackage("Pool")
    self:AddUiPackage("ChatChooseTarget")
    self:AddUiPackage("ChatExPression")
    self:AddUiPackage("CreateDeskTop")
    self:AddUiPackage("AgreeOrDisAddFriendRequest")
    self:AddUiPackage("Bank")
    self:AddUiPackage("ChipOperate")
    self:AddUiPackage("QuitOrBack")
    self:AddUiPackage("Login")
    self:AddUiPackage("Main")
    self:AddUiPackage("Bag")
    self:AddUiPackage("MailDetail")
    self:AddUiPackage("DailyReward")
    self:AddUiPackage("Desktop")
    self:AddUiPackage("DesktopChatParent")
    self:AddUiPackage("DesktopPlayerInfo")
    self:AddUiPackage("DesktopPlayerOperate")
    local d_m = "DeskTopMenu"
    if CS.Casinos.CasinosContext.Instance.UnityAndroid then
        d_m = "DesktopMenu"
    end
    self:AddUiPackage(d_m)
    self:AddUiPackage("DesktopHints")
    self:AddUiPackage("MTTGameResult")
    self:AddUiPackage("MTTProcess")
    self:AddUiPackage("Friend")
    self:AddUiPackage("Feedback")
    self:AddUiPackage("InviteFriendPlay")
    self:AddUiPackage("IdCardCheck")
    self:AddUiPackage("ResetPwd")
    self:AddUiPackage("Ranking")
    self:AddUiPackage("DesktopH")
    self:AddUiPackage("DesktopHBetReward")
    self:AddUiPackage("DesktopHTexas")
    self:AddUiPackage("DesktopHBankPlayerList")
    self:AddUiPackage("DesktopHCardType")
    self:AddUiPackage("DesktopHHistory")
    self:AddUiPackage("DesktopHRewardPot")
    self:AddUiPackage("DesktopHMenu")
    self:AddUiPackage("DesktopHHelp")
    self:AddUiPackage("DesktopHResult")
    self:AddUiPackage("DesktopHSetCardType")
    self:AddUiPackage("DesktopHTongSha")
    self:AddUiPackage("DesktopHTongPei")
    self:AddUiPackage("Edit")
    self:AddUiPackage("FriendOnLine")
    self:AddUiPackage("GiftDetail")
    self:AddUiPackage("GiftShop")
    self:AddUiPackage("LockChat")
    self:AddUiPackage("PlayerProfile")
    self:AddUiPackage("PlayerInfo")
    self:AddUiPackage("Notice")
    self:AddUiPackage("ShootingText")
    self:AddUiPackage("Shop")
    self:AddUiPackage("Purse")
    self:AddUiPackage("TakePhoto")
    self:AddUiPackage("ClassicModel")
    self:AddUiPackage("RechargeFirst")
    self:AddUiPackage("ActivityPopUpBox")
    self:AddUiPackage("ActivityCenter")
    self:AddUiPackage("MatchLobby")
    self:AddUiPackage("ApplySucceed")
    self:AddUiPackage("Club")
    self:AddUiPackage("CreateMatch")
    self:AddUiPackage("BlindTable")
    self:AddUiPackage("ClubHelp")
    self:AddUiPackage("JoinMatch")
    self:AddUiPackage("GetChipEffect")
    self:AddUiPackage("MatchInfo")
    self:AddUiPackage("EnterMatchNotify")
    self:AddUiPackage("SnowBallReward")
    self:AddUiPackage("EditAddress")
end

---------------------------------------
function Context:_regTbData()
    self:DoString("TbDataHintsInfoTexas")
    self.TbDataMgr:RegTbDataFac("HintsInfoTexas", TbDataFactoryHintsInfoTexas:new(nil))
    self:DoString("TbDataActorLevel")
    self.TbDataMgr:RegTbDataFac("ActorLevel", TbDataFactoryActorLevel:new(nil))
    self:DoString("TbDataCommon")
    self.TbDataMgr:RegTbDataFac("Common", TbDataFactoryCommon:new(nil))
    self:DoString("TbDataDailyReward")
    self.TbDataMgr:RegTbDataFac("DailyReward", TbDataFactoryDailyReward:new(nil))
    self:DoString("TbDataExpression")
    self.TbDataMgr:RegTbDataFac("Expression", TbDataFactoryExpression:new(nil))
    self:DoString("TbDataItem")
    self.TbDataMgr:RegTbDataFac("Item", TbDataFactoryItem:new(nil))
    self:DoString("TbDataItemType")
    self.TbDataMgr:RegTbDataFac("ItemType", TbDataFactoryItemType:new(nil))
    self:DoString("TbDataLanEn")
    self.TbDataMgr:RegTbDataFac("LanEn", TbDataFactoryLanEn:new(nil))
    self:DoString("TbDataLans")
    self.TbDataMgr:RegTbDataFac("Lans", TbDataFactoryLans:new(nil))
    self:DoString("TbDataLanZh")
    self.TbDataMgr:RegTbDataFac("LanZh", TbDataFactoryLanZh:new(nil))
    self:DoString("TbDataLotteryTicket")
    self.TbDataMgr:RegTbDataFac("LotteryTicket", TbDataFactoryLotteryTicket:new(nil))
    self:DoString("TbDataLotteryTicketBetOperate")
    self.TbDataMgr:RegTbDataFac("LotteryTicketBetOperate", TbDataFactoryLotteryTicketBetOperate:new(nil))
    self:DoString("TbDataLotteryTicketGoldPercent")
    self.TbDataMgr:RegTbDataFac("LotteryTicketGoldPercent", TbDataFactoryLotteryTicketGoldPercent:new(nil))
    self:DoString("TbDataOnlineReward")
    self.TbDataMgr:RegTbDataFac("OnlineReward", TbDataFactoryOnlineReward:new(nil))
    self:DoString("TbDataPresetMsg")
    self.TbDataMgr:RegTbDataFac("PresetMsg", TbDataFactoryPresetMsg:new(nil))
    self:DoString("TbDataUnitBilling")
    self.TbDataMgr:RegTbDataFac("UnitBilling", TbDataFactoryUnitBilling:new(nil))
    self:DoString("TbDataUnitConsume")
    self.TbDataMgr:RegTbDataFac("UnitConsume", TbDataFactoryUnitConsume:new(nil))
    self:DoString("TbDataUnitGoodsVoucher")
    self.TbDataMgr:RegTbDataFac("UnitGoodsVoucher", TbDataFactoryUnitGoodsVoucher:new(nil))
    self:DoString("TbDataUnitGoldPackage")
    self.TbDataMgr:RegTbDataFac("UnitGoldPackage", TbDataFactoryUnitGoldPackage:new(nil))
    self:DoString("TbDataUnitGiftNormal")
    self.TbDataMgr:RegTbDataFac("UnitGiftNormal", TbDataFactoryUnitGiftNormal:new(nil))
    self:DoString("TbDataUnitRedEnvelopes")
    self.TbDataMgr:RegTbDataFac("UnitRedEnvelopes", TbDataFactoryUnitRedEnvelopes:new(nil))
    self:DoString("TbDataUnitGiftTmp")
    self.TbDataMgr:RegTbDataFac("UnitGiftTmp", TbDataFactoryUnitGiftTmp:new(nil))
    self:DoString("TbDataUnitMagicExpression")
    self.TbDataMgr:RegTbDataFac("UnitMagicExpression", TbDataFactoryUnitMagicExpression:new(nil))
    self:DoString("TbDataVIPLevel")
    self.TbDataMgr:RegTbDataFac("VIPLevel", TbDataFactoryVIPLevel:new(nil))
    self:DoString("TbDataConfigTexasDesktop")
    self.TbDataMgr:RegTbDataFac("ConfigTexasDesktop", TbDataFactoryConfigTexasDesktop:new(nil))
    self:DoString("TbDataDesktopInfoTexas")
    self.TbDataMgr:RegTbDataFac("DesktopInfoTexas", TbDataFactoryDesktopInfoTexas:new(nil))
    self:DoString("TbDataCfigTexasDesktopH")
    self.TbDataMgr:RegTbDataFac("CfigTexasDesktopH", TbDataFactoryCfigTexasDesktopH:new(nil))
    self:DoString("TbDataCfigTexasDesktopHGoldPercent")
    self.TbDataMgr:RegTbDataFac("CfigTexasDesktopHGoldPercent", TbDataFactoryCfigTexasDesktopHGoldPercent:new(nil))
    self:DoString("TbDataCfigTexasDesktopHSysBank")
    self.TbDataMgr:RegTbDataFac("CfigTexasDesktopHSysBank", TbDataFactoryCfigTexasDesktopHSysBank:new(nil))
    self:DoString("TbDataDesktopHBetOperateTexas")
    self.TbDataMgr:RegTbDataFac("DesktopHBetOperateTexas", TbDataFactoryDesktopHBetOperateTexas:new(nil))
    self:DoString("TbDataDesktopHBetPotTexas")
    self.TbDataMgr:RegTbDataFac("DesktopHBetPotTexas", TbDataFactoryDesktopHBetPotTexas:new(nil))
    self:DoString("TbDataDesktopHInfoTexas")
    self.TbDataMgr:RegTbDataFac("DesktopHInfoTexas", TbDataFactoryDesktopHInfoTexas:new(nil))
    self:DoString("TbDataDesktopHBetReward")
    self.TbDataMgr:RegTbDataFac("DesktopHBetReward", TbDataFactoryDesktopHBetReward:new(nil))
    self:DoString("TbDataTexasRaiseBlinds")
    self.TbDataMgr:RegTbDataFac("TexasRaiseBlinds", TbDataFactoryTexasRaiseBlinds:new(nil))
    self:DoString("TbDataDesktopFastBet")
    self.TbDataMgr:RegTbDataFac("DesktopFastBet", TbDataFactoryDesktopFastBet:new(nil))
    self:DoString("TbDataTexasSnowBallRewardPlayerNum")
    self.TbDataMgr:RegTbDataFac("TexasSnowBallRewardPlayerNum", TbDataFactoryTexasSnowBallRewardPlayerNum:new(nil))
    self:DoString("TbDataTexasSnowBallRewardInfo")
    self.TbDataMgr:RegTbDataFac("TexasSnowBallRewardInfo", TbDataFactoryTexasSnowBallRewardInfo:new(nil))
end

---------------------------------------
-- 字符串分隔方法
function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function (c) fields[#fields + 1] = c end)
    return fields
end

---------------------------------------
-- 打印Table
function PrintTable(t)
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            print(indent .. "*" .. tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
                        sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                        print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                    elseif (type(val) == "string") then
                        print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent .. tostring(t))
            end
        end
    end
    if (type(t) == "table") then
        print(tostring(t) .. " {")
        sub_print_r(t, "  ")
        print("}")
    else
        sub_print_r(t, "  ")
    end
    print()
end