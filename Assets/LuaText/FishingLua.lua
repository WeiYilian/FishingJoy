local GameObject = CS.UnityEngine.GameObject
local Vector3 = CS.UnityEngine.Vector3
local Input = CS.UnityEngine.Input
local Quaternion = CS.UnityEngine.Quaternion
local Time = CS.UnityEngine.Time
local Random = CS.UnityEngine.Random
local Mathf = CS.UnityEngine.Mathf
local util= require "util"

--宝箱生成金币钻石太密集，分散一些
xlua.hotfix(CS.Treasour,'CreatePrize',function(self)
    for i = 1, 5 do
        local go = GameObject.Instantiate(
                self.gold,
                self.transform.position + Vector3(-10 + i * 40,0,0),
                self.transform.rotation)
        go.transform:SetParent(self.cavas)

        local go1 = GameObject.Instantiate(self.diamands,
                self.transform.position + Vector3(0,50,0) + Vector3(-10 + i * 45,0,0),
                self.transform.rotation)
        go1.transform:SetParent(self.cavas)
    end
end)

--金币不够时无法攻击
xlua.hotfix(CS.Gun,'Attack',function(self)
    if Input.GetMouseButtonDown(0) then
        --UI交互不不发射子弹
        if CS.UnityEngine.EventSystems.EventSystem.current:IsPointerOverGameObject() then
            return
        end
        if not canShootForFree then
            --炮台三太强，发射需要消耗钻石
            if self.gunLevel==3 and self.diamands < 1 then
                return
            elseif self.gunLevel~=3 and self.gold < -(-1-(self.gunLevel-1)*2) then
                return
            end
            
            if self.gunLevel == 3 then
                self:DiamandsChange(-1)
            elseif self.gunLevel~=3 then
                self:GoldChange(-1-(self.gunLevel-1)*2)
            end
        end
        self.bullectAudio.clip = self.bullectAudio[self.gunLevel-1]
        self.bullectAudio:Play()
        if self.Butterfly then
            GameObject.Instantiate(self.Bullects[self.gunLevel-1],self.attackPos.position,self.attackPos.rotation*Quaternion.Euler(0,0,20))
            GameObject.Instantiate(self.Bullects[self.gunLevel-1],self.attackPos.position,self.attackPos.rotation*Quaternion.Euler(0,0,-20))
        end
        
        GameObject.Instantiate(self.Bullects[self.gunLevel-1],self.attackPos.position,self.attackPos.rotation)
        self.attackCD = 0
        self.attack = false
    end
end)

--技能扣钻石太多
xlua.hotfix(CS.ButterFly,'Start',function(self)
    self.reduceDiamands = 10
end)
xlua.hotfix(CS.Fire,'Start',function(self)
    self.reduceDiamands = 8
end)
xlua.hotfix(CS.Ice,'Start',function(self)
    self.reduceDiamands = 5
end)

--随着炮台等级的提升，消耗的钻石也随之提升
xlua.hotfix(CS.ButterFly,'Fire',function(self)
    if self.canUse then
        self.reduceDiamands = 3*CS.Gun.Instance.gunLevel
        if CS.Gun.Instance.diamands < self.reduceDiamands then
            return
        end
        CS.Gun.Instance:DiamandsChange(-self.reduceDiamands)

        CS.Gun.Instance.Butterfly = true
        self.canUse = false
        self.cdSlider.transform:Find("Background").gameObject:SetActive(true)
        self.timeVal = 0
        self:Invoke("CloseFire",8)
        self.uiView:SetActive(true)
    end
end)
util.hotfix_ex(CS.Fire,'Attack',function(self)
    self.reduceDiamands = 2*CS.Gun.Instance.gunLevel
    self:Attack()
end)
util.hotfix_ex(CS.Ice,'ice',function(self)
    self.reduceDiamands = 1*CS.Gun.Instance.gunLevel
    self:ice()
end)


--Boss攻击玩家，玩家的金币和钻石数减少
util.hotfix_ex(CS.Boss,'Start',function(self)
    self:Start(self)
    self.m_reduceGold = -10
    self.m_reduceDiamond = -5
end)
util.hotfix_ex(CS.DeffendBoss,'Start',function(self)
    self:Start(self)
    self.m_reduceGold = -20
    self.m_reduceDiamond = -10
end)
util.hotfix_ex(CS.InvisibleBoss,'Start',function(self)
    self:Start(self)
    self.m_reduceGold = -50
    self.m_reduceDiamond = -20
end)

--被攻击后金币和钻石不为负数
util.hotfix_ex(CS.Gun,'GoldChange',function(self,number)
    self:GoldChange(number)
    self.gold = CS.UnityEngine.Mathf.Max(0,self.gold)
end)
util.hotfix_ex(CS.Gun,'DiamandsChange',function(self,number)
    self:DiamandsChange(number)
    self.diamands = CS.UnityEngine.Mathf.Max(0,self.diamands)
end)

--鱼生成的数量控制
local canCreateNewFish=true
local waveTimeVal=0
xlua.hotfix(CS.CreateFish,'Update',function(self)
    --浪潮控制
    if canCreateNewFish then
        if waveTimeVal> 20 then
            --通过AB包加载生成浪潮
            GameObject.Instantiate(CS.Gun.Instance.hot:GetABObj('SeaWave'))
            canCreateNewFish=false
            waveTimeVal=0
        else
            waveTimeVal=waveTimeVal+Time.deltaTime
        end
    else
        return
    end
    
    self:CreateALotOfFish()
    if self.ItemtimeVal >= 1  then
        self.num = Mathf.FloorToInt(Random.Range(0,4))
        self.ItemNum = Mathf.FloorToInt(Random.Range(1,101))
        --生成道具
        if self.ItemNum < 20 then
            self:CreateGameObject(self.item[3])
            local ItemIndex = Mathf.FloorToInt(Random.Range(1,101))
            if ItemIndex then
                self:CreateGameObject(self.item[Mathf.FloorToInt(Random.Range(0,3))])
            end
        end
        --生成普通鱼
        if self.ItemNum >= 20 and self.ItemNum < 45 then
            for i = 0,3 do
                self:CreateGameObject(self.fishList[Mathf.FloorToInt(Random.Range(0,7))])
            end
        end
        --增加的新鱼
        if self.ItemNum>=50 and self.ItemNum<55 then
            self:CreateGameObject(CS.Gun.Instance.hot:GetABObj('level3fish3'))
        end
        --生成Boss鱼
        if self.ItemNum >= 45 and self.ItemNum < 46 then
            self:CreateGameObject(self.boss)
        end
        if self.ItemNum >= 46 and self.ItemNum < 47 then
            self:CreateGameObject(self.boss2)
        end
        if self.ItemNum >= 47 and self.ItemNum < 48 then
            self:CreateGameObject(self.boss3)
        end

        self.ItemtimeVal = 0
    else
        self.ItemtimeVal =self.ItemtimeVal +Time.deltaTime
    end

    --游戏过程中隐藏鼠标
    if Input.GetMouseButtonUp(0) then
        CS.UnityEngine.Cursor.lockState=CS.UnityEngine.CursorLockMode.Locked
        CS.UnityEngine.Cursor.visible=false

    end
    --按ESC显示鼠标
    if Input.GetKeyDown(CS.UnityEngine.KeyCode.Escape) then
        CS.UnityEngine.Cursor.lockState=CS.UnityEngine.CursorLockMode.None
        CS.UnityEngine.Cursor.visible=true
    end
end)

--释放技能期间不能切换炮台
util.hotfix_ex(CS.Gun,'UpGun',function(self)
    if self.Fire or self.Butterfly or self.lce then
        return
    end
    self:UpGun()
end)
--释放技能期间不能切换炮台
util.hotfix_ex(CS.Gun,'DownGun',function(self)
    if self.Fire or self.Butterfly or self.lce then
        return
    end
    self:DownGun()
end)

--通过按键触发技能
util.hotfix_ex(CS.Fire,'Update',function(self)
    self:Update()
    if Input.GetKeyDown(CS.UnityEngine.KeyCode.Q) then
        self:Attack()
    end
end)
--通过按键触发技能
util.hotfix_ex(CS.ButterFly,'Update',function(self)
    self:Update()
    if Input.GetKeyDown(CS.UnityEngine.KeyCode.W) then
        self:Fire()
    end
end)
--通过按键触发技能
util.hotfix_ex(CS.Ice,'Update',function(self)
    self:Update()
    if Input.GetKeyDown(CS.UnityEngine.KeyCode.E) then
        self:ice()
    end
end)

local opentreasournum=0
local treasourspeed=0.05
util.hotfix_ex(CS.Treasour,'OpenTreasour',function(self)
    self:OpenTreasour()
    opentreasournum=opentreasournum+1
    print(opentreasournum)
    if treasourspeed>0.01 then
        treasourspeed = 0.05 - opentreasournum * 0.005
    end
end)
--通过按键触发宝箱奖励
util.hotfix_ex(CS.Treasour,'Update',function(self)
    self:Update()
    if Input.GetKeyDown(CS.UnityEngine.KeyCode.R) then
        self:OpenTreasour()
    end
    --宝箱冷却时间随开启次数而逐步增加
    if self.isDrease then
        self.img.color=self.img.color-CS.UnityEngine.Color(0,0,0,Time.deltaTime*10)
        if self.img.color.a<=0.2 then
            self.img.color=CS.UnityEngine.Color(self.img.color.r,self.img.color.g,self.img.color.b,0)
            self.isDrease=false
        end
    end
    self.img.color = self.img.color + CS.UnityEngine.Color(0,0,0,Time.deltaTime * treasourspeed)
    if self.img.color.a>0.95 then
        self.img.color=CS.UnityEngine.Color(self.img.color.r,self.img.color.g,self.img.color.b,1)
        self.cdView:SetActive(false)
    end
end)

--滚轮切换炮台
util.hotfix_ex(CS.GunChange,'Update',function(self)
    self:Update()
    if CS.Gun.Instance.canChangeGun then
        if Input.GetAxis("Mouse ScrollWheel")>0 then
            if self.add then
                CS.Gun.Instance:UpGun()
            end
        elseif Input.GetAxis("Mouse ScrollWheel")<0 then
            if not self.add then
                CS.Gun.Instance:DownGun()
            end
        end
    end
end)

--调整捕鱼的概率
xlua.hotfix(CS.Fish,'TakeDamage',function(self,attackValue)
    if CS.Gun.Instance.Fire then
        attackValue=attackValue*2
    end
    self.hp=self.hp-attackValue
    local CatchValue=Random.Range(0,100)
    local temp2=Random.Range(50,70)
    if CatchValue<= temp2-self.hp then
        self.isDead=true
        for i=0,8 do
            GameObject.Instantiate(self.pao,self.transform.position,
                    Quaternion.Euler(self.transform.eulerAngles + Vector3(0,45*i,0)))
        end
        self.gameObjectAni:SetTrigger("Die")
        self:Invoke("Prize",0.7)
    end
end)

--调整Boss捕获的概率
xlua.hotfix(CS.Boss,'TakeDamage',function(self,attackValue)
    if CS.Gun.Instance.Fire then
        attackValue=attackValue*2
    end
    self.hp=self.hp-attackValue
    local CatchValue=Random.Range(0,100)
    local temp2=Random.Range(5,10)
    if CatchValue< temp2-self.hp/10 then
        GameObject.Instantiate(self.deadEeffect,self.transform.position,self.transform.rotation)
        CS.Gun.Instance:GoldChange(self.GetGold*10)
        CS.GunInstance:DiamandsChange(self.GetDiamands*10)
        for i=0,10 do
            local itemGo= GameObject.Instantiate(self.gold,self.transform.position,Quaternion.Euler(self.transform.eulerAngles+Vector3(0,18+36*(i-1),0)))
            itemGo:GetComponent("Gold").bossPrize=true
        end
        for i=0,10 do
            local itemGo= GameObject.Instantiate(self.diamands,self.transform.position,Quaternion.Euler(self.transform.eulerAngles+Vector3(0,36+36*(i-1),0)))
            itemGo:GetComponent("Gold").bossPrize=true
        end
        Cs.UnityEngine.Object.Destroy(self.gameObject)
    end
end)


xlua.hotfix(CS.Gun,'Start',function(self)
    self.hot:LoadResources('level3fish3','level3fish3.ab')
    self.hot:LoadResources('SeaWave','seawave.ab')
end)

xlua.hotfix(CS.EmptyScript01,'Start',function(self)
    self:Invoke("EmptyMethod1",8)
end)

--浪潮的向右移动功能
xlua.hotfix(CS.EmptyScript01,'Update',function(self)
    self.transform:Translate(-self.transform.right*4*Time.deltaTime)
end)

--浪潮销毁触碰到的一切物体
xlua.hotfix(CS.EmptyScript01,'OnTriggerEnter',function(self,other)
    print("销毁了")
    if other.tag~="Untagged" and other.tag~="Wall" then
        print("销毁了")
        CS.UnityEngine.Object.Destroy(other.gameObject)
    end
end)

xlua.hotfix(CS.EmptyScript01,'EmptyMethod1',function(self)
    CS.Gun.Instance.changeAudio=true
    CS.Gun.Instance.level = CS.Gun.Instance.level+1
    if CS.Gun.Instance.level==4 then
        CS.Gun.Instance.level=1
    end
    canCreateNewFish=true
    CS.UnityEngine.Object.Destroy(self.gameObject)
end)