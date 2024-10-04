--- libavcodec/libx264.c.orig	2016-03-29 02:25:17 UTC
+++ libavcodec/libx264.c
@@ -260,16 +260,16 @@ static int X264_frame(AVCodecContext *ctx, AVPacket *p
                       int *got_packet)
 {
     X264Context *x4 = ctx->priv_data;
+    const AVPixFmtDescriptor *desc = av_pix_fmt_desc_get(ctx->pix_fmt);
     x264_nal_t *nal;
     int nnal, i, ret;
     x264_picture_t pic_out = {0};
     int pict_type;
-    AVFrameSideData *side_data;
 
     x264_picture_init( &x4->pic );
     x4->pic.img.i_csp   = x4->params.i_csp;
-    if (x264_bit_depth > 8)
-        x4->pic.img.i_csp |= X264_CSP_HIGH_DEPTH;
+    if (desc->comp[0].depth > 8)
+	  x4->pic.img.i_csp |= X264_CSP_HIGH_DEPTH;
     x4->pic.img.i_plane = avfmt2_num_planes(ctx->pix_fmt);
 
     if (frame) {
@@ -282,8 +282,8 @@ static int X264_frame(AVCodecContext *ctx, AVPacket *p
 
         switch (frame->pict_type) {
         case AV_PICTURE_TYPE_I:
-            x4->pic.i_type = x4->forced_idr >= 0 ? X264_TYPE_IDR
-                                                 : X264_TYPE_KEYFRAME;
+            x4->pic.i_type = x4->forced_idr > 0 ? X264_TYPE_IDR
+                                                : X264_TYPE_KEYFRAME;
             break;
         case AV_PICTURE_TYPE_P:
             x4->pic.i_type = X264_TYPE_P;
@@ -298,46 +298,24 @@ static int X264_frame(AVCodecContext *ctx, AVPacket *p
         reconfig_encoder(ctx, frame);
 
         if (x4->a53_cc) {
-            side_data = av_frame_get_side_data(frame, AV_FRAME_DATA_A53_CC);
-            if (side_data) {
-                x4->pic.extra_sei.payloads = av_mallocz(sizeof(x4->pic.extra_sei.payloads[0]));
-                if (x4->pic.extra_sei.payloads == NULL) {
-                    av_log(ctx, AV_LOG_ERROR, "Not enough memory for closed captions, skipping\n");
-                    goto skip_a53cc;
-                }
-                x4->pic.extra_sei.sei_free = av_free;
+	      void *sei_data;
+	      size_t sei_size;
 
-                x4->pic.extra_sei.payloads[0].payload_size = side_data->size + 11;
-                x4->pic.extra_sei.payloads[0].payload = av_mallocz(x4->pic.extra_sei.payloads[0].payload_size);
-                if (x4->pic.extra_sei.payloads[0].payload == NULL) {
-                    av_log(ctx, AV_LOG_ERROR, "Not enough memory for closed captions, skipping\n");
-                    av_freep(&x4->pic.extra_sei.payloads);
-                    goto skip_a53cc;
-                }
-                x4->pic.extra_sei.num_payloads = 1;
-                x4->pic.extra_sei.payloads[0].payload_type = 4;
-                memcpy(x4->pic.extra_sei.payloads[0].payload + 10, side_data->data, side_data->size);
-                x4->pic.extra_sei.payloads[0].payload[0] = 181;
-                x4->pic.extra_sei.payloads[0].payload[1] = 0;
-                x4->pic.extra_sei.payloads[0].payload[2] = 49;
+              x4->pic.extra_sei.payloads = av_mallocz(sizeof(x4->pic.extra_sei.payloads[0]));
+              if (x4->pic.extra_sei.payloads == NULL) {
+                  av_log(ctx, AV_LOG_ERROR, "Not enough memory for closed captions, skipping\n");
+                  av_free(sei_data);
+              } else {
+                  x4->pic.extra_sei.sei_free = av_free;
 
-                /**
-                 * 'GA94' is standard in North America for ATSC, but hard coding
-                 * this style may not be the right thing to do -- other formats
-                 * do exist. This information is not available in the side_data
-                 * so we are going with this right now.
-                 */
-                AV_WL32(x4->pic.extra_sei.payloads[0].payload + 3,
-                    MKTAG('G', 'A', '9', '4'));
-                x4->pic.extra_sei.payloads[0].payload[7] = 3;
-                x4->pic.extra_sei.payloads[0].payload[8] =
-                    ((side_data->size/3) & 0x1f) | 0x40;
-                x4->pic.extra_sei.payloads[0].payload[9] = 0;
-                x4->pic.extra_sei.payloads[0].payload[side_data->size+10] = 255;
-            }
+                  x4->pic.extra_sei.payloads[0].payload_size = sei_size;
+                  x4->pic.extra_sei.payloads[0].payload = sei_data;
+                  x4->pic.extra_sei.num_payloads = 1;
+                  x4->pic.extra_sei.payloads[0].payload_type = 4;
+	    }
         }
     }
-skip_a53cc:
+    
     do {
         if (x264_encoder_encode(x4->enc, &nal, &nnal, frame? &x4->pic: NULL, &pic_out) < 0)
             return AVERROR_EXTERNAL;
@@ -430,7 +408,7 @@ static int convert_pix_fmt(enum AVPixelFormat pix_fmt)
     case AV_PIX_FMT_YUVJ444P:
     case AV_PIX_FMT_YUV444P9:
     case AV_PIX_FMT_YUV444P10: return X264_CSP_I444;
-#ifdef X264_CSP_BGR
+#if CONFIG_LIBX264RGB_ENCODER
     case AV_PIX_FMT_BGR0:
         return X264_CSP_BGRA;
     case AV_PIX_FMT_BGR24:
@@ -656,6 +634,9 @@ FF_ENABLE_DEPRECATION_WARNINGS
         av_log(avctx, AV_LOG_ERROR,
                "x264 too old for AVC Intra, at least version 142 needed\n");
 #endif
+#if X264_BUILD >= 153
+	x4->params.i_bitdepth 	= av_pix_fmt_desc_get(avctx->pix_fmt)->comp[0].depth;
+#endif
     if (x4->b_bias != INT_MIN)
         x4->params.i_bframe_bias              = x4->b_bias;
     if (x4->b_pyramid >= 0)
@@ -783,8 +764,8 @@ FF_ENABLE_DEPRECATION_WARNINGS
     if(x4->x264opts){
         const char *p= x4->x264opts;
         while(p){
-            char param[256]={0}, val[256]={0};
-            if(sscanf(p, "%255[^:=]=%255[^:]", param, val) == 1){
+            char param[4096]={0}, val[4096]={0};
+            if(sscanf(p, "%4095[^:=]=%4095[^:]", param, val) == 1){
                 OPT_STR(param, "1");
             }else
                 OPT_STR(param, val);
@@ -858,6 +839,24 @@ FF_ENABLE_DEPRECATION_WARNINGS
     return 0;
 }
 
+static const enum AVPixelFormat pix_fmts[] = {
+    AV_PIX_FMT_YUV420P,
+    AV_PIX_FMT_YUVJ420P,
+    AV_PIX_FMT_YUV422P,
+    AV_PIX_FMT_YUVJ422P,
+    AV_PIX_FMT_YUV444P,
+    AV_PIX_FMT_YUVJ444P,
+    AV_PIX_FMT_YUV420P10,
+    AV_PIX_FMT_YUV422P10,
+    AV_PIX_FMT_YUV444P10,
+    AV_PIX_FMT_NV12,
+    AV_PIX_FMT_NV16,
+    AV_PIX_FMT_NV20,
+#ifdef X264_CSP_NV21
+    AV_PIX_FMT_NV21,
+#endif
+    AV_PIX_FMT_NONE
+};
 static const enum AVPixelFormat pix_fmts_8bit[] = {
     AV_PIX_FMT_YUV420P,
     AV_PIX_FMT_YUVJ420P,
@@ -885,22 +884,26 @@ static const enum AVPixelFormat pix_fmts_8bit_rgb[] = 
     AV_PIX_FMT_NONE
 };
 static const enum AVPixelFormat pix_fmts_8bit_rgb[] = {
-#ifdef X264_CSP_BGR
+#if CONFIG_LIBX264RGB_ENCODER
     AV_PIX_FMT_BGR0,
     AV_PIX_FMT_BGR24,
     AV_PIX_FMT_RGB24,
-#endif
     AV_PIX_FMT_NONE
 };
+#endif
 
 static av_cold void X264_init_static(AVCodec *codec)
 {
+#if X264_BUILD < 153
     if (x264_bit_depth == 8)
         codec->pix_fmts = pix_fmts_8bit;
     else if (x264_bit_depth == 9)
         codec->pix_fmts = pix_fmts_9bit;
     else if (x264_bit_depth == 10)
         codec->pix_fmts = pix_fmts_10bit;
+#else
+    codec->pix_fmts = pix_fmts;
+#endif
 }
 
 #define OFFSET(x) offsetof(X264Context, x)
@@ -913,7 +916,7 @@ static const AVOption options[] = {
     {"level", "Specify level (as defined by Annex A)", OFFSET(level), AV_OPT_TYPE_STRING, {.str=NULL}, 0, 0, VE},
     {"passlogfile", "Filename for 2 pass stats", OFFSET(stats), AV_OPT_TYPE_STRING, {.str=NULL}, 0, 0, VE},
     {"wpredp", "Weighted prediction for P-frames", OFFSET(wpredp), AV_OPT_TYPE_STRING, {.str=NULL}, 0, 0, VE},
-    {"a53cc",          "Use A53 Closed Captions (if available)",          OFFSET(a53_cc),        AV_OPT_TYPE_BOOL,   {.i64 = 0}, 0, 1, VE},
+    {"a53cc",          "Use A53 Closed Captions (if available)",          OFFSET(a53_cc),        AV_OPT_TYPE_BOOL,   {.i64 = 1}, 0, 1, VE},
     {"x264opts", "x264 options", OFFSET(x264opts), AV_OPT_TYPE_STRING, {.str=NULL}, 0, 0, VE},
     { "crf",           "Select the quality for constant quality mode",    OFFSET(crf),           AV_OPT_TYPE_FLOAT,  {.dbl = -1 }, -1, FLT_MAX, VE },
     { "crf_max",       "In CRF mode, prevents VBV from lowering quality beyond this point.",OFFSET(crf_max), AV_OPT_TYPE_FLOAT, {.dbl = -1 }, -1, FLT_MAX, VE },
@@ -970,7 +973,7 @@ static const AVOption options[] = {
     { "umh",           NULL, 0, AV_OPT_TYPE_CONST, { .i64 = X264_ME_UMH },  INT_MIN, INT_MAX, VE, "motion-est" },
     { "esa",           NULL, 0, AV_OPT_TYPE_CONST, { .i64 = X264_ME_ESA },  INT_MIN, INT_MAX, VE, "motion-est" },
     { "tesa",          NULL, 0, AV_OPT_TYPE_CONST, { .i64 = X264_ME_TESA }, INT_MIN, INT_MAX, VE, "motion-est" },
-    { "forced-idr",   "If forcing keyframes, force them as IDR frames.",                                  OFFSET(forced_idr),  AV_OPT_TYPE_BOOL,   { .i64 = -1 }, -1, 1, VE },
+    { "forced-idr",   "If forcing keyframes, force them as IDR frames.",                                  OFFSET(forced_idr),  AV_OPT_TYPE_BOOL,   { .i64 = 0 }, -1, 1, VE },
     { "coder",    "Coder type",                                           OFFSET(coder), AV_OPT_TYPE_INT, { .i64 = -1 }, -1, 1, VE, "coder" },
     { "default",          NULL, 0, AV_OPT_TYPE_CONST, { .i64 = -1 }, INT_MIN, INT_MAX, VE, "coder" },
     { "cavlc",            NULL, 0, AV_OPT_TYPE_CONST, { .i64 = 0 },  INT_MIN, INT_MAX, VE, "coder" },
@@ -1028,20 +1031,13 @@ static const AVCodecDefault x264_defaults[] = {
 };
 
 #if CONFIG_LIBX264_ENCODER
-static const AVClass x264_class = {
+static const AVClass X264_class = {
     .class_name = "libx264",
     .item_name  = av_default_item_name,
     .option     = options,
-    .version    = LIBAVUTIL_VERSION_INT,
+    .version	= LIBAVUTIL_VERSION_INT,
 };
 
-static const AVClass rgbclass = {
-    .class_name = "libx264rgb",
-    .item_name  = av_default_item_name,
-    .option     = options,
-    .version    = LIBAVUTIL_VERSION_INT,
-};
-
 AVCodec ff_libx264_encoder = {
     .name             = "libx264",
     .long_name        = NULL_IF_CONFIG_SMALL("libx264 H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10"),
@@ -1052,13 +1048,22 @@ AVCodec ff_libx264_encoder = {
     .encode2          = X264_frame,
     .close            = X264_close,
     .capabilities     = AV_CODEC_CAP_DELAY | AV_CODEC_CAP_AUTO_THREADS,
-    .priv_class       = &x264_class,
+    .priv_class       = &X264_class,
     .defaults         = x264_defaults,
     .init_static_data = X264_init_static,
     .caps_internal    = FF_CODEC_CAP_INIT_THREADSAFE |
                         FF_CODEC_CAP_INIT_CLEANUP,
 };
+#endif
 
+#if CONFIG_LIBX264RGB_ENCODER
+static const AVClass rgbclass = {
+    .class_name = "libx264rgb",
+    .item_name	= av_default_item_name,
+    .option	= options,
+    .version	= LIBAVUTIL_VERSION_INT,
+};
+
 AVCodec ff_libx264rgb_encoder = {
     .name           = "libx264rgb",
     .long_name      = NULL_IF_CONFIG_SMALL("libx264 H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10 RGB"),
@@ -1080,7 +1085,6 @@ static const AVClass X262_class = {
     .class_name = "libx262",
     .item_name  = av_default_item_name,
     .option     = options,
-    .version    = LIBAVUTIL_VERSION_INT,
 };
 
 AVCodec ff_libx262_encoder = {
