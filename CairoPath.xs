/*
 * Copyright (c) 2004-2011 by the cairo perl team (see the file README)
 *
 * Licensed under the LGPL, see LICENSE file for more information.
 *
 * $Id$
 */

#include <cairo-perl.h>
#include <cairo-perl-private.h>

SV *
newSVCairoPath (cairo_path_t * path)
{
	AV * av;
	int i;
	cairo_path_data_t *data;

	av = newAV ();

	for (i = 0; i < path->num_data; i += path->data[i].header.length) {
		HV *hash;
		AV *points;
		AV *point;

		data = &path->data[i];
		hash = newHV ();
		points = newAV ();

		switch (data->header.type) {
		    case CAIRO_PATH_MOVE_TO:
		    case CAIRO_PATH_LINE_TO:
			point = newAV ();
			av_push (point, newSVnv (data[1].point.x));
			av_push (point, newSVnv (data[1].point.y));
			av_push (points, newRV_noinc ((SV *) point));
			break;
		    case CAIRO_PATH_CURVE_TO:
			point = newAV ();
			av_push (point, newSVnv (data[1].point.x));
			av_push (point, newSVnv (data[1].point.y));
			av_push (points, newRV_noinc ((SV *) point));

			point = newAV ();
			av_push (point, newSVnv (data[2].point.x));
			av_push (point, newSVnv (data[2].point.y));
			av_push (points, newRV_noinc ((SV *) point));

			point = newAV ();
			av_push (point, newSVnv (data[3].point.x));
			av_push (point, newSVnv (data[3].point.y));
			av_push (points, newRV_noinc ((SV *) point));
			break;
		    case CAIRO_PATH_CLOSE_PATH:
			break;
		}

		hv_store (hash, "type", 4, cairo_path_data_type_to_sv (data->header.type), 0);
		hv_store (hash, "points", 6, newRV_noinc ((SV *) points), 0);

		av_push (av, newRV_noinc ((SV *) hash));
	}

	cairo_path_destroy (path);

	return newRV_noinc ((SV *) av);
}

#define FETCH_POINT(i)						\
	if ((svp = av_fetch (points, i, 0)) &&			\
	    cairo_perl_sv_is_defined (*svp))			\
	{							\
		point = (AV *) SvRV (*svp);			\
		if ((svp = av_fetch (point, 0, 0)))		\
			data[i+1].point.x = SvNV (*svp);	\
		if ((svp = av_fetch (point, 1, 0)))		\
			data[i+1].point.y = SvNV (*svp);	\
	}

/* This uses cairo_perl_alloc_temp.  So the return value is only valid until
 * the next FREETMPS occurs.  At the moment, the only cairo function that
 * *takes* a cairo_path_t is cairo_append_path, and it acts on the path
 * immediately and does not store it.  So that's fine. */
cairo_path_t *
SvCairoPath (SV * sv)
{
	AV *av;
	int i, num_data;
	cairo_path_t *path;
	cairo_path_data_t *data;

	if (!cairo_perl_sv_is_array_ref (sv))
		croak ("a Cairo::Path has to be an array reference");

	av = (AV *) SvRV (sv);

	num_data = 0;
	for (i = 0; i <= av_len (av); i++) {
		SV **svp;
		HV *hv;

		svp = av_fetch (av, i, 0);
		if (!svp || !cairo_perl_sv_is_hash_ref (*svp))
			croak ("a Cairo::Path has to contain hash references");
		hv = (HV *) SvRV (*svp);

		svp = hv_fetch (hv, "type", 4, 0);
		if (!svp || !cairo_perl_sv_is_defined (*svp))
			croak ("hash references inside a Cairo::Path must have a 'type' key");

		switch (cairo_path_data_type_from_sv (*svp)) {
		    case CAIRO_PATH_MOVE_TO:
		    case CAIRO_PATH_LINE_TO:
			num_data += 2;
			break;
		    case CAIRO_PATH_CURVE_TO:
			num_data += 4;
			break;
		    case CAIRO_PATH_CLOSE_PATH:
			num_data += 1;
			break;
		}
	}

	path = cairo_perl_alloc_temp (sizeof (cairo_path_t));
	path->num_data = num_data;
	path->data = cairo_perl_alloc_temp (path->num_data * sizeof (cairo_path_data_t));
	path->status = CAIRO_STATUS_SUCCESS;

	data = path->data;
	for (i = 0; i <= av_len (av); i++) {
		SV **svp;
		HV *hv;
		AV *points, *point;

		svp = av_fetch (av, i, 0);
		hv = (HV *) SvRV (*svp);

		svp = hv_fetch (hv, "points", 6, 0);
		if (!svp || !cairo_perl_sv_is_array_ref (*svp))
			croak ("hash references inside a Cairo::Path must "
			       "contain a 'points' key which contains an array "
			       "reference of points");
		points = (AV *) SvRV (*svp);

		svp = hv_fetch (hv, "type", 4, 0);

		switch (cairo_path_data_type_from_sv (*svp)) {
		    case CAIRO_PATH_MOVE_TO:
			data->header.type = CAIRO_PATH_MOVE_TO;
			data->header.length = 2;
			FETCH_POINT (0);
			break;

		    case CAIRO_PATH_LINE_TO:
			data->header.type = CAIRO_PATH_LINE_TO;
			data->header.length = 2;
			FETCH_POINT (0);
			break;

		    case CAIRO_PATH_CURVE_TO:
			data->header.type = CAIRO_PATH_CURVE_TO;
			data->header.length = 4;
			FETCH_POINT (0);
			FETCH_POINT (1);
			FETCH_POINT (2);
			break;

		    case CAIRO_PATH_CLOSE_PATH:
			data->header.type = CAIRO_PATH_CLOSE_PATH;
			data->header.length = 1;
			break;
		}

		data += data->header.length;
	}

	return path;
}
