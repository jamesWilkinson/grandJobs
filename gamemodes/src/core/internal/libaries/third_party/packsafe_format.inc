// Packed-safe format by Emmet

#include <a_samp>

#if !defined MAX_FORMAT_BUFFER
	#define MAX_FORMAT_BUFFER	(2048)
#endif

#define Packed:%0[%1] \
	%0[%1 char] = !" "

static
	g_sFormatBuffer[MAX_FORMAT_BUFFER],
	g_sPrintBuffer[MAX_FORMAT_BUFFER],
	g_iFormatArgs = 12
;

static const
	g_cBufferSize = MAX_FORMAT_BUFFER
;

forward @_psf_sysreq_(); @_psf_sysreq_() {
	static
	    str[2]
	;
	format(str, 2, "");
	strunpack(str, !"");
	ispacked(str);
	strlen(str);
}

stock static IsPackedArgument(arg)
{
	// Load the value of our argument.
	#emit LOAD.S.pri arg

	// Load the previous frame, stored in address zero.
	#emit LOAD.S.alt 0

	// Data is stored in bytes, so convert "arg" to bytes.
	#emit SHL.C.pri 2

	// Add the result to get the start of the frame.
	#emit ADD

	// Adding 12 bytes will point us to the function's header.
	#emit ADD.C 12

	// Load the address relative to the data.
	#emit LOAD.I

	// Push our loaded address into "ispacked".
	#emit PUSH.pri
	#emit PUSH.C 4
	#emit SYSREQ.C ispacked

	// Return the result.
	#emit STACK 8
	#emit RETN

	return 0;
}

stock ps_format(dest[], size, const str[], {Float,_}:...)
{
	new
	    pos = strlen(str),
	    idx = numargs(),
	    addr = 0,
	    len
	;
	// Bug fix (thanks to kvann).
	if (g_sFormatBuffer[0]) {
		g_sFormatBuffer[0] = '\0';
	}
	if (idx == 3) {
	    if (ispacked(str) && !ispacked(dest)) {
	        strunpack(dest, str, size);
	    } else if ((!ispacked(str) && ispacked(dest)) || (ispacked(str) && ispacked(dest))) {
	        strpack(dest, str, size);
		} else if (!ispacked(str) && !ispacked(dest)) {
		    strcat((dest[0] = 0, dest), str, size);
		}
		return 0;
	}
	strunpack(g_sFormatBuffer, str);

	while (pos--) {
		if ((idx > 2 && g_sFormatBuffer[pos] == '%') && g_sFormatBuffer[pos + 1] && g_sFormatBuffer[pos + 1] != '%') {
		    idx--;

			if (g_sFormatBuffer[pos + 1] == 's' && IsPackedArgument(idx)) {
			    // Load the address of our packed string.
		    	#emit LCTRL 5
		    	#emit ADD.C 12
				#emit LOAD.S.alt idx
				#emit SHL.C.alt 2
				#emit ADD
				#emit LOAD.I
				#emit STOR.S.pri addr

				// Get the length of the string.
				#emit PUSH.pri
				#emit PUSH.C 4
				#emit SYSREQ.C strlen
				#emit STOR.S.pri len
				#emit STACK 8

				strdel(g_sFormatBuffer, pos, pos + 2);

				while (len--) {
				    static
				        ch[2]
					;
					// Read a single character from the packed string.
					#emit LOAD.S.pri addr
					#emit LOAD.S.alt len
					#emit ADD
					#emit ALIGN.pri 1
     				#emit LODB.I 1
					#emit STOR.pri ch

				    strins(g_sFormatBuffer, ch, pos);
		    	}
		    }
		    else {
		        // Load the address relative to the parameter.
				#emit LCTRL 5
		    	#emit ADD.C 12
				#emit LOAD.S.alt idx
				#emit SHL.C.alt 2
				#emit ADD
				#emit LOAD.I
				#emit PUSH.pri
				
				if (g_sFormatBuffer[pos + 2] == '*' && g_sFormatBuffer[pos + 3] == 's') {
				    #emit LCTRL 5
					#emit LOAD.S.alt idx
					#emit DEC.alt
					#emit STOR.S.alt idx
					#emit SHL.C.alt 2
					#emit ADD
                    #emit ADD.C 12
					#emit LOAD.I
					#emit PUSH.pri

				    g_iFormatArgs = g_iFormatArgs + 8;
				}
				else g_iFormatArgs = g_iFormatArgs + 4;
			}
	    }
	}
	#emit PUSH.C g_sFormatBuffer
	#emit PUSH.C g_cBufferSize
	#emit PUSH.C g_sFormatBuffer
	#emit PUSH.C g_iFormatArgs
	#emit SYSREQ.C format
	#emit STACK 16

	if (ispacked(dest)) {
	    strpack(dest, g_sFormatBuffer, size);
	} else {
	    strcat((dest[0] = 0, dest), g_sFormatBuffer, size);
	}
	g_iFormatArgs = 12;

	#emit LCTRL 5
	#emit SCTRL 4
	#emit RETN

	return 0;
}

stock ps_printf(const str[], {Float,_}:...)
{
	new
	    args = numargs();

	// Bug fix (thanks to kvann).
	if (g_sPrintBuffer[0]) {
		g_sPrintBuffer[0] = '\0';
	}
	
	while (--args > 0) {
	    // Load the address relative to the parameter.
	    #emit LCTRL 5
	    #emit ADD.C 12
	    #emit LOAD.S.alt args
	    #emit SHL.C.alt 2
	    #emit ADD
	    #emit LOAD.I
	    #emit PUSH.pri
	}
	// Push the other variables to the function.
	#emit PUSH.S str
	#emit PUSH.C g_cBufferSize
	#emit PUSH.C g_sPrintBuffer

	// Push the number of arguments (stored in address 8).
	#emit LOAD.S.pri 8
	#emit ADD.C 8
	#emit PUSH.pri

	// SYSREQ.C is for natives and "ps_format" is not a native.
	// Therefore, we must jump to the function manually.
	#emit LCTRL 6
	#emit ADD.C 28
	#emit PUSH.pri
	#emit CONST.pri ps_format
	#emit SCTRL 6
	#emit STACK 4

	print(g_sPrintBuffer);

	#emit LCTRL 5
	#emit SCTRL 4
	#emit RETN

	return 0;
}

#if defined _ALS_format
	#undef format
#else
	#define _ALS_format
#endif

#if defined _ALS_printf
	#undef printf
#else
	#define _ALS_printf
#endif

#define format ps_format
#define printf ps_printf