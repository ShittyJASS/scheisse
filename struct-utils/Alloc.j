library Alloc
	
	// Alloc v1.0.1
	// by jondrean
	
	// Module for giving unused instance index
	
	// module Alloc
	//	- Standard alloc, prepares .next as necessary
	// module PreAlloc
	//	- Alloc that prepares .next:s on init
	
	// implement <Pre>Alloc
	//	static method allocate takes nothing returns thistype
	//		- Returns unused instance index
	//	method deallocate takes nothing returns nothing
	//		- Marks given index "this" as unused
	
	private keyword AllocMod
	
	module Alloc
		static integer max = 0
		implement AllocMod
	endmodule
	
	module PreAlloc
		static constant boolean preAlloc = true
		implement AllocMod
		private static method initInstances takes nothing returns nothing
			local integer n = 8189
			loop
				set thistype.next[n] = n + 1
				exitwhen 0 == n
				set n = n - 1
			endloop
		endmethod
		private static method onInit takes nothing returns nothing
			call initInstances.execute()
		endmethod
	endmodule
	
	private module AllocMod
		static thistype array next
		static if not DEBUG_MODE and not thistype.A_forceLog then
		else
			boolean used
			method operator isInstanciated takes nothing returns boolean
				return used
			endmethod
		endif
		method deallocate takes nothing returns nothing
			//! runtextmacro ALLOC_DEALLOC("thistype", "this")
		endmethod
		static method allocate takes nothing returns thistype
			//! runtextmacro ALLOC_ALLOC("thistype", "this", "return")
		endmethod
	endmodule
	
	globals
		public integer I
	endglobals
	
	//! textmacro ALLOC_DEALLOC takes STRUCT, NODE
		debug if not $STRUCT$($NODE$).used then
		debug	call BJDebugMsg("|cffff0000Alloc::$STRUCT$ ERROR: Double free|r")
		debug	call TimerStart(CreateTimer(), 0, false, function PauseGameOn)
		debug	call Player(1/0)
		debug endif
		static if not DEBUG_MODE and not $STRUCT$.A_forceLog then
		else
			set $STRUCT$($NODE$).used = false
		endif
		set $STRUCT$.next[$NODE$] = $STRUCT$.next[0]
		set $STRUCT$.next[0] = $NODE$
	//! endtextmacro
	
	//! textmacro ALLOC_ALLOC takes STRUCT, NODE, LEFTOP
		static if not $STRUCT$.preAlloc then
			if 0 == $STRUCT$.next[0] then
				debug if 8189 == $STRUCT$.max then
				debug	call BJDebugMsg("|cffff0000Alloc::$STRUCT$ ERROR: Double free|r")
				debug	call TimerStart(CreateTimer(), 0, false, function PauseGameOn)
				debug	call Player(1/0)
				debug endif
				set $STRUCT$.max = $STRUCT$.max + 1
				static if not DEBUG_MODE and not thistype.A_forceLog then
				else
					set $STRUCT$(max).used = true
				endif
				$LEFTOP$ $STRUCT$.max
			endif
		endif
		set Alloc_I = $STRUCT$.next[0]
		set $STRUCT$.next[0] = $STRUCT$.next[Alloc_I]
		static if not DEBUG_MODE and not thistype.A_forceLog then
		else
			set $STRUCT$(Alloc_I).used = true
		endif
		$LEFTOP$ Alloc_I
	//! endtextmacro
	
endlibrary
