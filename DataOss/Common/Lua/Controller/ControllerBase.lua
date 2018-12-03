-- Copyright(c) Cragon. All rights reserved.

---------------------------------------
ControllerBase = class()

function ControllerBase:ctor(this, controller_data, controller_name)
    self.ControllerData = controller_data
    self.ControllerName = controller_name
    self.CasinosContext = CS.Casinos.CasinosContext.Instance
    self.Context = Context
    self.ControllerMgr = ControllerMgr
    self.ViewMgr = ViewMgr
    self.Rpc = self.ControllerMgr.Rpc
    self.MC = CommonMethodType
end

function ControllerBase:OnCreate()
end

function ControllerBase:OnDestroy()
end

function ControllerBase:OnHandleEv(ev)
end

---------------------------------------
ControllerFactory = class()

function ControllerFactory:GetName()
end

function ControllerFactory:CreateController(controller_data)
end