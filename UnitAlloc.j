library UnitAlloc requires /*
	*/ UnitDex      /* http://www.hiveworkshop.com/threads/system-unitdex-unit-indexer.248209/ 
	*/

	// UnitAlloc v1.0.1
	// by jondrean
	
	// Links units together
	
	// implement UnitAlloc
	//  method operator unit takes nothing returns unit
	//      - Returns unit at given index "this"
	//  static method operator [] takes unit whichUnit returns thistype
	//      - Returns index of given unit "whichUnit"
	//  static method operator empty takes nothing returns boolean
	//      - Returns if there's no units linked
	//  method deallocate takes nothing returns nothing
	//      - Unlinks given index
	//  method allocate takes nothing returns nothing
	//      - Links given index
	
	module UnitAlloc
	
		static if not DEBUG_MODE and not thistype.UA_forceLog then
		else
			boolean UA_used
		endif
		
		thistype next
		thistype prev
		
		method operator unit takes nothing returns unit
			return GetUnitById(this)
		endmethod
		
		static method operator [] takes unit u returns thistype
			return GetUnitId(u)
		endmethod
		
		static method operator empty takes nothing returns boolean
			return 0 == thistype(0).next
		endmethod
		
		method deallocate takes nothing returns nothing
			//! runtextmacro UNITALLOC_DEALLOC("thistype", "this")
		endmethod
		
		method allocate takes nothing returns nothing
			//! runtextmacro UNITALLOC_ALLOC("thistype", "this")
		endmethod
		
	endmodule
	
	//! textmacro UNITALLOC_ALLOC takes STRUCT, NODE
		debug if $STRUCT$($NODE$).UA_used then
		debug   call BJDebugMsg("|cffff0000thistype ERROR: Double allocation|r")
		debug   call TimerStart(CreateTimer(), 0, false, function PauseGameOn)
		debug   call Player(1/0)
		debug endif
		debug set $STRUCT$($NODE$).UA_used = true
		static if not DEBUG_MODE and not $STRUCT$.UA_forceLog then
		else
			set $STRUCT$($NODE$).UA_used = true
		endif
		set $STRUCT$(0).next.prev = $NODE$
		set $STRUCT$($NODE$).next = $STRUCT$(0).next
		set $STRUCT$(0).next = $NODE$
		static if $STRUCT$.onAlloc.exists then
			call $STRUCT$($NODE$).onAlloc()
		endif
	//! endtextmacro
	
	//! textmacro UNITALLOC_DEALLOC takes STRUCT, NODE
		debug if not $STRUCT$($NODE$).UA_used then
		debug   call BJDebugMsg("|cffff0000thistype ERROR: Double free|r")
		debug   call TimerStart(CreateTimer(), 0, false, function PauseGameOn)
		debug   call Player(1/0)
		debug endif
		debug set $STRUCT$($NODE$).UA_used = false
		static if not DEBUG_MODE and not $STRUCT$.UA_forceLog then
		else
			set $STRUCT$($NODE$).UA_used = true
		endif
		if $NODE$ == $STRUCT$(0).next then
			set $STRUCT$(0).next = $STRUCT$($NODE$).next
			set $STRUCT$($NODE$).next.prev = 0
		else
			set $STRUCT$($NODE$).prev.next = $STRUCT$($NODE$).next
			set $STRUCT$($NODE$).next.prev = $STRUCT$($NODE$).prev
		endif
		static if $STRUCT$.onDealloc.exists then
			call $STRUCT$($NODE$).onDealloc()
		endif
	//! endtextmacro
	
endlibrary
