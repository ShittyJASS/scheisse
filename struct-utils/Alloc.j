library Alloc
	
	// Alloc v1.0.0
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
	
	module Alloc
		private static thistype array next
		private static integer max = 0
		private static thistype swap
		static if not DEBUG_MODE and not thistype.A_forceLog then
		else
			debug private boolean used
		endif
		method deallocate takes nothing returns nothing
			//! runtextmacro ALLOC_ERROR("not used", "Double free")
			static if not DEBUG_MODE and not thistype.A_forceLog then
			else
				set used = false
			endif
			set next[this] = next[0]
			set next[0] = this
		endmethod
		static method allocate takes nothing returns thistype
			if 0 == next[0] then
				//! runtextmacro ALLOC_ERROR("8189 == max", "Exceeding instance limit")
				set max = max + 1
				static if not DEBUG_MODE and not thistype.A_forceLog then
				else
					set thistype(max).used = true
				endif
				return max
			endif
			set swap = next[0]
			set next[0] = next[next[0]]
			static if not DEBUG_MODE and not thistype.A_forceLog then
			else
				set swap.used = true
			endif
			return swap
		endmethod
	endmodule
	
	module PreAlloc
		private static thistype array next
		static if not DEBUG_MODE and not thistype.A_forceLog then
		else
			debug private boolean used
		endif
		method deallocate takes nothing returns nothing
			//! runtextmacro ALLOC_ERROR("not used", "Double free")
			static if not DEBUG_MODE and not thistype.A_forceLog then
			else
				set used = false
			endif
			set next[this] = next[0]
			set next[0] = this
		endmethod
		static method allocate takes nothing returns thistype
			local thistype swap = next[0]
			//! runtextmacro ALLOC_ERROR("8190 == swap", "Exceeding instance limit")
			static if not DEBUG_MODE and not thistype.A_forceLog then
			else
				set swap.used = true
			endif
			set next[0] = next[swap]
			return swap
		endmethod
		private static method initInstances takes nothing returns nothing
			local integer n = 8189
			loop
				set next[n] = n + 1
				exitwhen 0 == n
				set n = n - 1
			endloop
		endmethod
		private static method onInit takes nothing returns nothing
			call initInstances.execute()
		endmethod
	endmodule
	
	//! textmacro ALLOC_ERROR takes EXPRESSION, MESSAGE
		debug if $EXPRESSION$ then
		debug	call BJDebugMsg("|cffff0000Alloc::thistype ERROR: $MESSAGE$|r")
		debug	call TimerStart(CreateTimer(), 0, false, function PauseGameOn)
		debug	call Player(1/0)
		debug endif
	//! endtextmacro
	
endlibrary
