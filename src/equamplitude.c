/*     CalculiX - A 3-dimensional finite element program                 */
/*              Copyright (C) 1998-2026                                  */

/*     This program is free software; you can redistribute it and/or     */
/*     modify it under the terms of the GNU General Public License as    */
/*     published by the Free Software Foundation(version 2);             */
/*                                                                       */

/*     This program is distributed in the hope that it will be useful,   */
/*     but WITHOUT ANY WARRANTY; without even the implied warranty of    */ 
/*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the      */
/*     GNU General Public License for more details.                      */

/*     You should have received a copy of the GNU General Public License */
/*     along with this program; if not, write to the Free Software       */
/*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.         */

// Calculates the ccx amplitude at a given time based on an equation which is
// given by a string.
// Calculation is based on the tinyexpr library (https://github.com/codeplea/tinyexpr)
// which is used here without any modification.
//
// ccx syntax example which makes use of this routine:
// *AMPLITUDE, name=EQUATION1, EQUATION

// Changes:
// 2026/04/27: Console output format for amplitude name and equation string.
// 2026/04/14: more printouts
// 2026/03/27: initial version based on the example file example2.c from the tinyexpr library

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "CalculiX.h"
#include "tinyexpr.h"

void equamplitude_(double *time, char *name, char *amequ, double *amplitude)
{
	ITG i;

    // for submodels a single virtual amplitude is defined without a name,
	// such amplitudes don't have an equation string:
    if(strlen(name)==0) return;

    for(i=0;i<512-2;i++){
	  amequ[i]=tolower(amequ[i]);	
	}
	amequ[512-1]='\0';
	//printf("Evaluating equation name %s\n with equation string %s\n at time% lf\n", name, amequ, *time);
	
    /* Time variable t is bound at eval-time. */
    te_variable vars[] = {{"t", time}};

    /* This will compile the equation expression string and check for errors. */
    int err;
	// "1" is the variable count in the equation string
	// which is here for the amplitude calculation the time t:
    te_expr *n = te_compile(amequ, vars, 1, &err);

    if (n) {
        *amplitude = te_eval(n);
        // printf("Value for amplitude %.80s at time %lf from the equation string %.512s: %lf\n", name, *time, amequ, *amplitude);
        te_free(n);
    } else {
        /* Show the user where the error is at. */
		printf("Error in tinyexpr library for amplitude name %.80s\n", name);
		printf("near equation string position %d for equation string:\n", err-1);
		printf("%s\n", amequ);
		exit(0);
    }

    return;
}
