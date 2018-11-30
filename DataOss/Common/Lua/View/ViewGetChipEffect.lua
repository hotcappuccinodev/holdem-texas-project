-- Copyright(c) Cragon. All rights reserved.
-- 未使用

---------------------------------------
ViewGetChipEffect = class(ViewBase)

---------------------------------------
function ViewGetChipEffect:ctor()
end

---------------------------------------
function ViewGetChipEffect:OnCreate()
    self.GGraphParcitle = self.ComUi:GetChild("HolderParticle").asGraph
    self.ShowTime = 0
end

---------------------------------------
function ViewGetChipEffect:ShowEffect(pos_start, pos_end)
    self.PosEnd = pos_end
    --self.GGraphParcitle.position = pos_start
    local ab_particle = ParticleHelper:GetParticel("getchipparticle.ab")
    local temp = ab_particle:LoadAsset("GetChipParticle")
    local prefab = CS.UnityEngine.GameObject.Instantiate(temp)
    self.ParticleSystem = prefab:GetComponent("ParticleSystem")
    self.GGraphParcitle:SetNativeObject(CS.FairyGUI.GoWrapper(prefab))
    local main = self.ParticleSystem.main
    main.simulationSpace = CS.UnityEngine.ParticleSystemSimulationSpace.Custom
    self.ParticleSystem:Play()
    self.ShowTime = 0
    self.ParticlePlayTime = 0.5
    self.GoldFlyTime = 1.5
    self.FlyGold = false
end

---------------------------------------
function ViewGetChipEffect:onUpdate(tm)
    self.ShowTime = self.ShowTime + tm
    if (self.ShowTime >= self.ParticlePlayTime and self.FlyGold == false) then
        self:flyGoldToHeadIcon()
        self.ParticleSystem:Clear()
        self.FlyGold = true
    end
    if (self.ShowTime >= self.ParticlePlayTime + self.GoldFlyTime) then
        self.ViewMgr:DestroyView(self)
    end
end

---------------------------------------
function ViewGetChipEffect:flyGoldToHeadIcon()
    local particles = CS.Casinos.LuaHelper.NewParticleArry(self.ParticleSystem.main.maxParticles)
    local count = self.ParticleSystem:GetParticles(particles)
    local tempImages = {}
    print(count)
    for i = 0, count - 1 do
        local pos = particles[i].position
        local screenPos = CS.UnityEngine.Camera.main:WorldToScreenPoint(pos)
        screenPos.y = CS.UnityEngine.Screen.height - screenPos.y
        local pt = CS.FairyGUI.GRoot.inst:GlobalToLocal(CS.UnityEngine.Vector2(screenPos.x, screenPos.y))
        local aImage = CS.FairyGUI.UIPackage.CreateObject("GetChipEffect", "ImageGold").asImage
        self.ComUi:AddChild(aImage)
        aImage:SetPivot(0.5, 0.5, true)
        aImage.position = CS.UnityEngine.Vector3(pt.x, pt.y, 0)
        table.insert(tempImages, aImage)
    end
    for i = 1, #tempImages do
        tempImages[i]:TweenMove(self.PosEnd, self.GoldFlyTime)
    end
end

---------------------------------------
ViewGetChipEffectFactory = class(ViewFactory)

---------------------------------------
function ViewGetChipEffectFactory:CreateView()
    local view = ViewGetChipEffect:new()
    return view
end