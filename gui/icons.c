/*
 * TilEm II
 *
 * Copyright (c) 2011 Benjamin Moody
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#include <stdio.h>
#include <gtk/gtk.h>

#include "icons.h"
#include "files.h"

static const char * const custom_icons[] = {
	/* Disassembly icons */
	"tilem-disasm-pc",
	"tilem-disasm-break",
	"tilem-disasm-break-pc",

	/* Debugger actions */
	"tilem-db-step",
	"tilem-db-step-over",
	"tilem-db-finish"
};

/* Set up custom icons. */
void init_custom_icons()
{
	GtkIconTheme *theme;
	char *path;

	path = get_shared_dir_path("icons", NULL);
	if (path) {
		theme = gtk_icon_theme_get_default();
		gtk_icon_theme_append_search_path(theme, path);
		g_free(path);
	}
}
