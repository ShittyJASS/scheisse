library Dummy requires /*
	*/ UnitDex		/* http://www.hiveworkshop.com/threads/system-unitdex-unit-indexer.248209/ 
	*/
	
	// Dummy v1.0.1
	// by jondrean
	
	// Dummies for missiles, effects, casting and instant casting
	
	// - Download model: http://www.wc3c.net/showthread.php?p=1007469
	// - Save map once having correct input for below textmacro
	// - Comment out below textmacro
	
	//! runtextmacro DUMMY_OBJECT("dummy.mdl")
		
	// function GetDummy takes player owner, real x, real y, real a returns unit
	//	- Returns dummy matching given parameters
	// function ReleaseDummy takes unit whichDummy returns nothing
	//	- Either releases or stores given dummy
	
	// struct Dummy extends array
	//	static method operator unit takes nothing returns unit
	//		- Returns dummy for instant operations
	
	globals
		private integer array head
		private integer array next
		private integer array count
		private unit U
	endglobals
	
	function GetDummy takes player p, real x, real y, real a returns unit
		local integer i = R2I(a / 45)
		if 0 == head[i] then
			set U = CreateUnit(p, 'udum', x, y, a)
			call UnitAddAbility(U, 'arav')
			call UnitRemoveAbility(U, 'arav')
			return U
		endif
		set U = GetUnitById(head[i])
		set count[i] = count[i] - 1
		set head[i] = next[head[i]]
		call PauseUnit(U, false)
		call SetUnitFacing(U, a)
		call SetUnitX(U, x)
		call SetUnitY(U, y)
		call SetUnitOwner(U, p, false)
		return U
	endfunction
	
	function ReleaseDummy takes unit u returns nothing
		local integer i = R2I(GetUnitFacing(u) / 45)
		local integer ui = GetUnitId(u)
		if 32 == count[i] then
			call RemoveUnit(u)
		else
			set count[i] = count[i] + 1
			call SetUnitAnimationByIndex(u, 90)
			call SetUnitScale(u, 1, 0, 0)
			call SetUnitFacing(u, i*45 + 22.5)
			call PauseUnit(U, true)
			set next[ui] = head[i]
			set head[i] = ui
		endif
	endfunction
	
	private keyword Init
	
	struct Dummy extends array
		private static unit U
		static method operator unit takes nothing returns unit
			return U
		endmethod
		implement Init
	endstruct
	
	private module Init
		static method onInit takes nothing returns nothing
			set U = GetDummy(Player(PLAYER_NEUTRAL_PASSIVE), 0, 0, 0)
			debug if 0 == GetUnitUserData(U) then
			debug	call BJDebugMsg("|cffff0000Dummy ERROR: Unable to create dummies, check 'udum' object and UnitDex settings")
			debug	call TimerStart(CreateTimer(), 0, false, function PauseGameOn)
			debug	call Player(1/0)
			debug endif
		endmethod
	endmodule
	
	//! textmacro DUMMY_OBJECT takes MODELPATH
		//! externalblock extension=lua ObjectMerger $FILENAME$
			//! i setobjecttype("units")
			//! i createobject("ewsp","udum")
			//! i makechange(current,"uabi","Aloc")
			//! i makechange(current,"uble","0")
			//! i makechange(current,"ucbs","0")
			//! i makechange(current,"ucpt","0")
			//! i makechange(current,"umdl","$MODELPATH$")
			//! i makechange(current,"ulpz","0")
			//! i makechange(current,"uprw","0")
			//! i makechange(current,"ushu","")
			//! i makechange(current,"umvt","")
			//! i makechange(current,"ucol","0")
			//! i makechange(current,"ufle","0")
			//! i makechange(current,"ufoo","0")
			//! i makechange(current,"uhom","1")
			//! i makechange(current,"urac","commoner")
			//! i makechange(current,"usid","0")
			//! i makechange(current,"usin","0")
			//! i makechange(current,"upgr","")
			//! i makechange(current,"utyp","_")
			//! i makechange(current,"unam","Dummy")
		//! endexternalblock
	//! endtextmacro
	
endlibrary
