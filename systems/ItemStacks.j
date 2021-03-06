library ItemStacks requires /*
    */ UnitAlloc                        /* https://github.com/ShittyJASS/scheisse/blob/master/struct-utils/UnitAlloc.j
    */ SoundTools                       /* http://www.hiveworkshop.com/threads/system-soundtools.207308/
    */ optional RegisterPlayerUnitEvent /* http://www.hiveworkshop.com/threads/snippet-registerplayerunitevent.203338/
    */
    
    // Item Stacks v1.0.1
    // by jondrean
    
    // Upon acquiring an already existing consumable,
    // that item is removed and existing one's charge
    // count is increased by its charge count
    
    // function UnitTryAddItem takes unit whodWield, item theItem returns boolean
    //  - Replicates forementioned functionality
    //  - Plays sound if selected
    //  - Returns whether successful
    
    globals
        private Sound sPickUp
        private sound snd
    endglobals
    
    function UnitTryAddItem takes unit u, item it returns boolean
        local integer i = 5
        local integer itype
        local item ite
        local integer c = GetItemCharges(it)
        if 0 != c then
            set itype = GetItemTypeId(it)
            loop
                set ite = UnitItemInSlot(u, i)
                if itype == GetItemTypeId(ite) then
                    call SetItemCharges(ite, GetItemCharges(ite) + c)
                    call RemoveItem(it)
                    if IsUnitSelected(u, GetOwningPlayer(u)) then
                        call sPickUp.runUnit(u)
                    endif
                    return true
                endif
                exitwhen 0 == i
                set i = i - 1
            endloop
        endif
        if UnitAddItem(u, it) then
            if IsUnitSelected(u, GetOwningPlayer(u)) then
                call sPickUp.runUnit(u)
            endif
            return true
        endif
        return false
    endfunction
    
    private struct Approach extends array
        implement UnitAlloc
        static timer C = CreateTimer()
        item it
        trigger dt
        static method onExpire takes nothing returns nothing
            local thistype this = thistype(0).next
            local real dx
            local real dy
            loop
                set dx = GetItemX(it) - GetUnitX(unit)
                set dy = GetItemY(it) - GetUnitY(unit)
                if 14400 >= dx*dx + dy*dy then
                    call UnitTryAddItem(unit, it)
                    call IssueImmediateOrderById(unit, 851972)
                endif
                set this = this.next
                exitwhen 0 == this
            endloop
        endmethod
        static method onDeath takes nothing returns boolean
            local thistype this = thistype[GetTriggerUnit()]
            //! runtextmacro UNITALLOC_DEALLOC("thistype", "this")
            if empty then
                call PauseTimer(C)
            endif
            call DestroyTrigger(dt)
            set dt = null
            set it = null
            return false
        endmethod
    endstruct
    
    private struct S extends array
        static Sound sDrop
        static method onOrder takes nothing returns nothing
            local integer i = GetIssuedOrderId() - 852002
            local integer itype
            local integer c
            local unit u
            local item it
            local item ite
            local real dx
            local real dy
            if 0 <= i and 5 >= i then
                set u = GetTriggerUnit()
                set it = GetOrderTargetItem()
                set ite = UnitItemInSlot(u, i)
                if it == ite then
                    call SetItemPosition(it, GetUnitX(u), GetUnitY(u))
                    call sDrop.runUnit(u)
                elseif GetItemTypeId(it) == GetItemTypeId(ite) and ITEM_TYPE_CHARGED == GetItemType(it) then
                    call SetItemCharges(ite, GetItemCharges(ite) + GetItemCharges(it))
                    call RemoveItem(it)
                endif
                set it = null
                set ite = null
                set u = null
            elseif -31 == i then // smart
                set it = GetOrderTargetItem()
                if null != it then
                    set u = GetTriggerUnit()
                    set dx = GetItemX(it) - GetUnitX(u)
                    set dy = GetItemY(it) - GetUnitY(u)
                    if 14400 < dx*dx + dy*dy then
                        call IssuePointOrderById(u, 851971, GetItemX(it), GetItemY(it))
                        if Approach.empty then
                            call TimerStart(Approach.C, 0.05, true, function Approach.onExpire)
                        endif
                        set i = Approach[u]
                        //! runtextmacro UNITALLOC_ALLOC("Approach", "i")
                        set Approach(i).it = it
                        set Approach(i).dt = CreateTrigger()
                        call TriggerRegisterDeathEvent(Approach(i).dt, u)
                        call TriggerRegisterUnitEvent(Approach(i).dt, u, EVENT_UNIT_ISSUED_ORDER)
                        call TriggerRegisterUnitEvent(Approach(i).dt, u, EVENT_UNIT_ISSUED_POINT_ORDER)
                        call TriggerRegisterUnitEvent(Approach(i).dt, u, EVENT_UNIT_ISSUED_ORDER)
                        call TriggerAddCondition(Approach(i).dt, Condition(function Approach.onDeath))
                    else
                        set c = GetItemCharges(it)
                        if 0 != c then
                            set i = 5
                            set itype = GetItemTypeId(it)
                            loop
                                set ite = UnitItemInSlot(u, i)
                                if itype == GetItemTypeId(ite) then
                                    call SetItemCharges(ite, GetItemCharges(ite) + c)
                                    call RemoveItem(it)
                                    call sPickUp.runUnit(u)
                                    call IssueImmediateOrderById(u, 851972)
                                    exitwhen true
                                endif
                                exitwhen 0 == i
                                set i = i - 1
                            endloop
                        endif
                    endif
                    set ite = null
                    set u = null
                    set it = null
                endif
            endif
        endmethod
        static method onPickup takes nothing returns nothing
            local unit u
            local item it = GetManipulatedItem()
            local integer itype
            local integer i = 5
            local item ite
            local integer c = GetItemCharges(it)
            if 0 != c then
                set u = GetTriggerUnit()
                set itype = GetItemTypeId(it)
                loop
                    set ite = UnitItemInSlot(u, i)
                    if it != ite and GetItemTypeId(ite) == itype then
                        call SetItemCharges(ite, GetItemCharges(ite) + c)
                        call RemoveItem(it)
                        exitwhen true
                    endif
                    exitwhen 0 == i
                    set i = i - 1
                endloop
                set u = null
            endif
            set it = null
        endmethod
        static method onInit takes nothing returns nothing
            static if LIBRARY_RegisterPlayerUnitEvent then
                call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function thistype.onOrder)
                call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.onPickup)
            else
                local trigger t = CreateTrigger()
                call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
                call TriggerAddCondition(t, Filter(function thistype.onOrder))
                set t = CreateTrigger()
                call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM)
                call TriggerAddCondition(t, Filter(function thistype.onPickup))
                set t = null
            endif
            set sDrop = Sound.create("Sound\\Interface\\HeroDropItem1.wav", 486, false, true)
            set sPickUp = Sound.create("Sound\\Interface\\PickUpItem.wav", 174, false, true)
        endmethod
    endstruct
    
endlibrary
