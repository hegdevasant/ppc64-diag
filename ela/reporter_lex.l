%{
/*
 * Tokenizer for reporters catalog
 *
 * Copyright (C) International Business Machines Corp., 2009, 2010
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

#define CATALOGS_IMPLEMENTATION
#include "catalogs.h"
#include "rr.tab.h"
#include <string.h>
#include <errno.h>

extern ReporterCtlgParser reporter_ctlg_parser;
static ReporterCtlgParser *pc = &reporter_ctlg_parser;

%}

%option noyywrap

%%
aliases		{ return KW_ALIASES; }
device_arg	{ return KW_DEVICE_ARG; }
meta_reporter	{ return KW_META_REPORTER; }
prefix_args	{ return KW_PREFIX_ARGS; }
prefix_format	{ return KW_PREFIX_FORMAT; }
reporter	{ return KW_REPORTER; }
source		{ return KW_SOURCE; }
variants	{ return KW_VARIANTS; }

[_A-Za-z][A-Za-z0-9_]* {
	char *name;
	if (! (name = strdup((const char*)yytext)) ) {
		perror("strdup");
		return ERRTOK;
	}
	rrlval.sval = name;
	return TK_NAME;
}

\"	{
	char *s = pc->get_string(1);
	if (!s)
		return ERRTOK;
	rrlval.sval = s;
	return TK_STRING;
}

[ \t\r]	;	/* Skip white space. */

\n	{ pc->lineno++; }

"/*"	{
	if (pc->skip_comment() < 0)
		return ERRTOK;
}

.	{ return yytext[0]; 	/* Pass through any other characters. */ }
%%

/* unput is a macro, but we need a function pointer. */
static void
unput_func(int c)
{
	unput(c);
}

void
ReporterCtlgParser::init_lex(void)
{
	YY_FLUSH_BUFFER;
	yyrestart(file);
	lineno = 1;
	p_input = yyinput;
	p_unput = unput_func;
}
