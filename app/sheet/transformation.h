#ifndef ZSVSHEET_TRANSFORMATION_H
#define ZSVSHEET_TRANSFORMATION_H

#include "zsv.h"
#include "zsv/utils/writer.h"

typedef struct zsvsheet_transformation *zsvsheet_transformation;

struct zsvsheet_transformation_opts {
  /**
   * As usual the zsv_opts used during parsing, but note that the
   * ctx passed to the row_handler is wrapped in zsvsheet_transformation.
   */
  struct zsv_opts zsv_opts;
  struct zsv_prop_handler *custom_prop_handler;
  const char *input_filename;
};

enum zsv_status zsvsheet_transformation_new(struct zsvsheet_transformation_opts, zsvsheet_transformation *);
void zsvsheet_transformation_delete(zsvsheet_transformation);

zsv_parser zsvsheet_transformation_parser(zsvsheet_transformation);
zsv_csv_writer zsvsheet_transformation_writer(zsvsheet_transformation);
char *zsvsheet_transformation_filename(zsvsheet_transformation);

#endif