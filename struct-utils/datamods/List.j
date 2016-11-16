library List requires /*
    */ Alloc        /* https://github.com/ShittyJASS/scheisse/blob/master/struct-utils/Alloc.j
    */
    
    // List v1.0.1
    // by jondrean
    
    // Singly linked list module
    
    // module List
    //  static method allocate takes nothing returns thistype
    //      - Returnes unused instance
    //  method deallocate takes nothing returns nothing
    //      - Flushes & recycles given instance "this"
    //
    //  method add takes nothing returns thistype
    //      - Stores & returns new index
    //  method remove takes nothing returns thistype
    //      - Unstores & returns newest index
    //  method removeAt takes thistype whichNode returns nothing
    //      - Unstores given index
    //  method flush takes nothing returns nothing
    //      - Removes all associated indexes
    //
    //  method operator head takes nothing returns thistype
    //      - Returns newest index
    //  method operator empty takes nothing returns boolean
    //      - Whether instance has no associated indexes
    
    module List
        
        private static integer alloc = 0
        private static integer array rec
        readonly thistype head
        readonly thistype next
        debug private static boolean array used
        
        static method allocate takes nothing returns thistype
            local thistype this = rec[0]
            if 0 == this then
                set alloc = alloc + 1
                debug set used[alloc] = true
                return alloc
            endif
            set rec[0] = rec[this]
            debug set used[this] = true
            return this
        endmethod
        method flush takes nothing returns nothing
            local thistype node
            loop
                exitwhen 0 == head
                set node = head
                set head = node.next
                set node.next = 0
                static if not thistype.l_customAlloc then
                    //! runtextmacro ALLOC_DEALLOC("thistype", "node")
                endif
            endloop
        endmethod
        method deallocate takes nothing returns nothing
            debug if not used[this] then
            debug   call BJDebugMsg("|cffff0000thistype deallocate ERROR: Double free ("+I2S(this)+")|r")
            debug   call TimerStart(CreateTimer(), 0, false, function PauseGameOn)
            debug   call Player(1/0)
            debug endif
            debug set used[this] = false
            call flush()
            set rec[this] = rec[0]
            set rec[0] = this
        endmethod
        
        method has takes thistype node returns boolean
            local thistype probe = head
            loop
                exitwhen 0 == probe
                if probe == node then
                    return true
                endif
                set probe = probe.next
            endloop
            return false
        endmethod
        
        method length takes nothing returns integer
            local integer c = 0
            local thistype probe = head
            loop
                exitwhen 0 == probe
                set c = c + 1
                set probe = probe.next
            endloop
            return c
        endmethod
        
        static if thistype.l_customAlloc then
            method add takes thistype node returns nothing
                set node.next = head
                set head = node
            endmethod
        else
            implement Alloc
            method add takes nothing returns thistype
                local thistype swap = head
                //! runtextmacro ALLOC_ALLOC("thistype", "set head =")
                set head.next = swap
                return head
            endmethod
        endif
        method remove takes nothing returns thistype
            local thistype node = head
            set head = head.next
            static if not thistype.l_customAlloc then
                //! runtextmacro ALLOC_DEALLOC("thistype", "node")
            endif
            return node
        endmethod
        method removeAt takes thistype at returns nothing
            local thistype node = head
            if at == node then
                set head = node.next
                static if not thistype.l_customAlloc then
                    //! runtextmacro ALLOC_DEALLOC("thistype", "node")
                endif
            else
                loop
                    exitwhen at == node.next
                    set node = node.next
                    debug if 0 == node then
                    debug   call BJDebugMsg("|cffff0000thistype.removeAt: Non-existent node given")
                    debug   call TimerStart(CreateTimer(), 0, false, function PauseGameOn)
                    debug   call Player(1/0)
                    debug endif
                endloop
                set node.next = at.next
                static if not thistype.l_customAlloc then
                    //! runtextmacro ALLOC_DEALLOC("thistype", "node")
                endif
            endif
        endmethod
        
        method operator empty takes nothing returns boolean
            return 0 == head
        endmethod
        
    endmodule
    
endlibrary
