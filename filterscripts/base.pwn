//
// Base FS
// Contains /pm /kick /ban commands.
//

#include <a_samp>

public OnFilterScriptInit()
{
	print("\n--Base FS loaded.\n");
    CallRemoteFunction("OnFilterScriptInit", "");
	return 1;
}