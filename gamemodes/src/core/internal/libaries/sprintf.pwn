/**
 * Copyright (c) 2014 grandJobs
 *
 * This program is free software; you can redistribute it and/or modify it under the terms of the
 * GNU General Public License as published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program; if
 * not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 */

 /*

   sprintf()

   PAWNO: 
   native sprintf(const format[], {Float,_}:...);

   Credits: KoczkaHUN
   http://forum.sa-mp.com/showthread.php?t=281&page=62

*/

#if !defined ____sprintf
#define ____sprintf

#if !defined SPRINTF_MAX_STRING
    #define SPRINTF_MAX_STRING 4096
#endif
#if !defined SPRINTF_DEBUG_STRING
    #define SPRINTF_DEBUG_STRING "[sprintf debug] '%s'[%d]"
#endif

#assert SPRINTF_MAX_STRING > 2

new
    _s@T[SPRINTF_MAX_STRING];

#if defined SPRINTF_DEBUG
    new const _s@V[] = SPRINTF_DEBUG_STRING;
    #define sprintf(%1) (format(_s@T, SPRINTF_MAX_STRING, %1), printf(_s@V, _s@T, strlen(_s@T)), _s@T)
#else
    #define sprintf(%1) (format(_s@T, SPRINTF_MAX_STRING, %1), _s@T)
#endif

#endif
