/*
 * This file is part of libbluray/libdvd
 * Copyright (C) 2009-2010  Obliter0n
 * Copyright (C) 2009-2010  John Stebbins
 * Copyright (C) 2017 Rootcoder, LLC (adapted for libdvd)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library. If not, see
 * <http://www.gnu.org/licenses/>.
 */

#ifndef DVD_MACRO_H_
#define DVD_MACRO_H_

#include <stdlib.h>  /* free() */

#define MKINT_BE16(X) ( (X)[0] << 8 | (X)[1] )
#define MKINT_BE24(X) ( (X)[0] << 16 | (X)[1] << 8 | (X)[2] )
#define MKINT_BE32(X) ( (X)[0] << 24 | (X)[1] << 16 |  (X)[2] << 8 | (X)[3] )
#define X_FREE(X)     ( free(X), X = NULL )

#define DVD_MIN(a,b) ((a)<(b)?(a):(b))
#define DVD_MAX(a,b) ((a)>(b)?(a):(b))

#define DVD_MAX_SSIZE ((int64_t)(((size_t)-1)>>1))

#endif /* DVD_MACRO_H_ */
