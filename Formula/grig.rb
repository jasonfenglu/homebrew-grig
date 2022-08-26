# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Grig < Formula
  desc ""
  homepage "http://groundstation.sourceforge.net/grig/"
  url "https://sourceforge.net/projects/groundstation/files/Grig/0.8.1/grig-0.8.1.tar.gz/download"
  sha256 "be8687418fb23efa0468674c3fdd15340fed06eef09be9de21106cc17e033c25"
  license ""

  # depends_on "cmake" => :build
  depends_on "gtk+"
  depends_on "hamlib" => "4.2"

  patch :DATA

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
    # https://rubydoc.brew.sh/Formula.html#std_configure_args-instance_method
    # system "./configure", *std_configure_args, "--disable-silent-rules"
    # system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    #
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test Grig`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

__END__

diff --git a/config.h.in b/config.h.in
index 2bdddf9..cd30bab 100644
--- a/config.h.in
+++ b/config.h.in
@@ -10,6 +10,24 @@
 /* The gettext domain */
 #undef GETTEXT_PACKAGE
 
+/* "Hamlib major version" */
+#undef HAMLIB_MAJOR_VERSION
+
+/* "Hamlib minor version" */
+#undef HAMLIB_MINOR_VERSION
+
+/* "Hamlib patch version" */
+#undef HAMLIB_PATCH_VERSION
+
+/* "Hamlib major version" */
+#undef HAMLIB_MAJOR_VERSION
+
+/* "Hamlib minor version" */
+#undef HAMLIB_MINOR_VERSION
+
+/* "Hamlib patch version" */
+#undef HAMLIB_PATCH_VERSION
+
 /* "Hamlib version" */
 #undef HAMLIB_VERSION
 
diff --git a/configure b/configure
index acb75d2..7fbdc3a 100755
--- a/configure
+++ b/configure
@@ -13903,8 +13903,19 @@ $as_echo "#define HAVE_DCGETTEXT 1" >>confdefs.h
 
 
 
+cat >>confdefs.h <<_ACEOF
+#define HAMLIB_MAJOR_VERSION `pkg-config --modversion hamlib | cut -d'.' -f1`
+_ACEOF
+
+
+cat >>confdefs.h <<_ACEOF
+#define HAMLIB_MINOR_VERSION `pkg-config --modversion hamlib | cut -d'.' -f2 | cut -d'~' -f1`
+_ACEOF
 
 
+cat >>confdefs.h <<_ACEOF
+#define HAMLIB_PATCH_VERSION `pkg-config --modversion hamlib | cut -d'.' -f2 | cut -d'~' -f2`
+_ACEOF
 
 
 cat >>confdefs.h <<_ACEOF
@@ -14091,8 +14102,19 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
+cat >>confdefs.h <<_ACEOF
+#define HAMLIB_MAJOR_VERSION `pkg-config --modversion hamlib | cut -d'.' -f1`
+_ACEOF
+
+
+cat >>confdefs.h <<_ACEOF
+#define HAMLIB_MINOR_VERSION `pkg-config --modversion hamlib | cut -d'.' -f2 | cut -d'~' -f1`
+_ACEOF
 
 
+cat >>confdefs.h <<_ACEOF
+#define HAMLIB_PATCH_VERSION `pkg-config --modversion hamlib | cut -d'.' -f2 | cut -d'~' -f2`
+_ACEOF
 
 
 ac_config_files="$ac_config_files Makefile doc/Makefile doc/man/grig.1 doc/man/Makefile grig.spec src/Makefile pixmaps/Makefile po/Makefile.in"
diff --git a/configure.ac b/configure.ac
index 86f1091..de6ee39 100644
--- a/configure.ac
+++ b/configure.ac
@@ -89,7 +89,9 @@ GDK_V=`pkg-config --modversion gdk-2.0`
 GTK_V=`pkg-config --modversion gtk+-2.0`
 
 AC_DEFINE_UNQUOTED([HAMLIB_VERSION],[`pkg-config --modversion hamlib`],["Hamlib version"])
-
+AC_DEFINE_UNQUOTED([HAMLIB_MAJOR_VERSION],[`pkg-config --modversion hamlib | cut -d'.' -f1`],["Hamlib major version"])
+AC_DEFINE_UNQUOTED([HAMLIB_MINOR_VERSION],[`pkg-config --modversion hamlib | cut -d'.' -f2 | cut -d'~' -f1`],["Hamlib minor version"])
+AC_DEFINE_UNQUOTED([HAMLIB_PATCH_VERSION],[`pkg-config --modversion hamlib | cut -d'.' -f2 | cut -d'~' -f2`],["Hamlib patch version"])
 
 AC_SUBST(CFLAGS)
 AC_SUBST(LDFLAGS)
diff --git a/src/rig-daemon-check.c b/src/rig-daemon-check.c
index c5c0d14..fe98dd6 100644
--- a/src/rig-daemon-check.c
+++ b/src/rig-daemon-check.c
@@ -42,6 +42,9 @@
 #include <gtk/gtk.h>
 #include <glib/gi18n.h>
 #include <hamlib/rig.h>
+#ifdef HAVE_CONFIG_H
+#  include <config.h>
+#endif
 #include "rig-data.h"
 #include "grig-debug.h"
 #include "rig-daemon-check.h"
@@ -396,15 +399,26 @@ rig_daemon_check_mode     (RIG               *myrig,
 			   this list is good for current mode   AND
 			   the current frequency is within this range
 			*/
+#if HAMLIB_MAJOR_VERSION >= 4
+			if (!found_mode &&
+			    ((mode & myrig->state.rx_range_list[i].modes) == mode) &&
+			    (get->freq1 >= myrig->state.rx_range_list[i].startf)    &&
+			    (get->freq1 <= myrig->state.rx_range_list[i].endf)) {
+
+				get->fmin = myrig->state.rx_range_list[i].startf;
+				get->fmax = myrig->state.rx_range_list[i].endf;
+#else
 			if (!found_mode &&
 			    ((mode & myrig->state.rx_range_list[i].modes) == mode) &&
 			    (get->freq1 >= myrig->state.rx_range_list[i].start)    &&
 			    (get->freq1 <= myrig->state.rx_range_list[i].end)) {
-					
-				found_mode = 1;
+
 				get->fmin = myrig->state.rx_range_list[i].start;
 				get->fmax = myrig->state.rx_range_list[i].end;
+#endif
 				
+				found_mode = 1;
+
 				grig_debug_local (RIG_DEBUG_VERBOSE,
 						  _("%s: Found frequency range for mode %d"),
 						  __FUNCTION__, mode);
@@ -884,7 +898,7 @@ rig_daemon_check_level     (RIG               *myrig,
 	if (has_get->att || has_set->att) {
 		int i = 0;
 
-		while ((i < MAXDBLSTSIZ) && (myrig->state.attenuator[i] != 0)) {
+		while ((i < HAMLIB_MAXDBLSTSIZ) && (myrig->state.attenuator[i] != 0)) {
 			rig_data_set_att_data (i, myrig->state.attenuator[i]);
 			i++;
 		}
@@ -895,7 +909,7 @@ rig_daemon_check_level     (RIG               *myrig,
 	if (has_get->preamp || has_set->preamp) {
 		int i = 0;
 
-		while ((i < MAXDBLSTSIZ) && (myrig->state.preamp[i] != 0)) {
+		while ((i < HAMLIB_MAXDBLSTSIZ) && (myrig->state.preamp[i] != 0)) {
 			rig_data_set_preamp_data (i, myrig->state.preamp[i]);
 			i++;
 		}
diff --git a/src/rig-daemon.c b/src/rig-daemon.c
index ddd922f..38bd2ab 100644
--- a/src/rig-daemon.c
+++ b/src/rig-daemon.c
@@ -50,6 +50,9 @@
 #include <hamlib/rig.h>
 #include <string.h>
 #include <stdlib.h>
+#ifdef HAVE_CONFIG_H
+#  include <config.h>
+#endif
 #include "grig-config.h"
 #include "grig-debug.h"
 #include "rig-anomaly.h"
@@ -537,7 +540,7 @@ rig_daemon_start       (int          rigid,
 	}
 
 	/* configure and open rig device */
-	strncpy (myrig->state.rigport.pathname, rigport, FILPATHLEN);
+	strncpy (myrig->state.rigport.pathname, rigport, HAMLIB_FILPATHLEN);
 	g_free (rigport);
 
 	/* set speed if any special whishes */
@@ -1673,13 +1676,23 @@ rig_daemon_exec_cmd         (rig_cmd_t cmd,
 						/* is this list good for current mode?
 						   is the current frequency within this range?
 						*/
+#if HAMLIB_MAJOR_VERSION >= 4
+						if (((mode & myrig->state.rx_range_list[i].modes) == mode) &&
+						    (get->freq1 >= myrig->state.rx_range_list[i].startf)    &&
+						    (get->freq1 <= myrig->state.rx_range_list[i].endf)) {
+
+							get->fmin = myrig->state.rx_range_list[i].startf;
+							get->fmax = myrig->state.rx_range_list[i].endf;
+#else
 						if (((mode & myrig->state.rx_range_list[i].modes) == mode) &&
 						    (get->freq1 >= myrig->state.rx_range_list[i].start)    &&
 						    (get->freq1 <= myrig->state.rx_range_list[i].end)) {
-					
-							found_mode = 1;
+
 							get->fmin = myrig->state.rx_range_list[i].start;
 							get->fmax = myrig->state.rx_range_list[i].end;
+#endif
+
+							found_mode = 1;
 				
 							grig_debug_local (RIG_DEBUG_VERBOSE,
 									  _("%s: Found frequency range for mode %d"),
@@ -2971,7 +2984,7 @@ rig_daemon_exec_cmd         (rig_cmd_t cmd,
 			val.i = set->voxdel;
 
 			/* try to execute command */
-			retcode = rig_set_level (myrig, RIG_VFO_CURR, RIG_LEVEL_VOX, val);
+			retcode = rig_set_level (myrig, RIG_VFO_CURR, RIG_LEVEL_VOXDELAY, val);
 
 			/* raise anomaly if execution did not succeed */
 			if (retcode != RIG_OK) {
@@ -2996,7 +3009,7 @@ rig_daemon_exec_cmd         (rig_cmd_t cmd,
 			value_t val;
 
 			/* try to execute command */
-			retcode = rig_get_level (myrig, RIG_VFO_CURR, RIG_LEVEL_VOX, &val);
+			retcode = rig_get_level (myrig, RIG_VFO_CURR, RIG_LEVEL_VOXDELAY, &val);
 
 			/* raise anomaly if execution did not succeed */
 			if (retcode != RIG_OK) {
diff --git a/src/rig-data.c b/src/rig-data.c
index cc76268..1858a8d 100644
--- a/src/rig-data.c
+++ b/src/rig-data.c
@@ -64,10 +64,10 @@ grig_cmd_avail_t has_get;  /*!< Flags to indicate reading capabilities. */
 
 
 /** \brief List of attenuator values (absolute values). */
-static int att[MAXDBLSTSIZ];
+static int att[HAMLIB_MAXDBLSTSIZ];
 
 /** \brief List of preamp values. */
-static int preamp[MAXDBLSTSIZ];
+static int preamp[HAMLIB_MAXDBLSTSIZ];
 
 /** \brief Bit field of available VFO's */
 static int vfo_list;
@@ -116,7 +116,7 @@ rig_data_set_vfos         (int vfos)
 void
 rig_data_set_att_data (int index, int data)
 {
-	if ((index >= 0) && (index < MAXDBLSTSIZ))
+	if ((index >= 0) && (index < HAMLIB_MAXDBLSTSIZ))
 		att[index] = data;
 }
 
@@ -132,7 +132,7 @@ rig_data_set_att_data (int index, int data)
 int
 rig_data_get_att_data (int index)
 {
-	if ((index >= 0) && (index < MAXDBLSTSIZ)) {
+	if ((index >= 0) && (index < HAMLIB_MAXDBLSTSIZ)) {
 		return att[index];
 	}
 	else {
@@ -158,7 +158,7 @@ rig_data_get_att_index    (int data)
 		return -1;
 
 	/* scan through the array */
-	while ((i < MAXDBLSTSIZ) && (att[i] != 0)) {
+	while ((i < HAMLIB_MAXDBLSTSIZ) && (att[i] != 0)) {
 		if (att[i] == data) {
 			return i;
 		}
@@ -182,7 +182,7 @@ rig_data_get_att_index    (int data)
 void
 rig_data_set_preamp_data (int index, int data)
 {
-	if ((index >= 0) && (index < MAXDBLSTSIZ))
+	if ((index >= 0) && (index < HAMLIB_MAXDBLSTSIZ))
 		preamp[index] = data;
 }
 
@@ -198,7 +198,7 @@ rig_data_set_preamp_data (int index, int data)
 int
 rig_data_get_preamp_data (int index)
 {
-	if ((index >= 0) && (index < MAXDBLSTSIZ)) {
+	if ((index >= 0) && (index < HAMLIB_MAXDBLSTSIZ)) {
 		return preamp[index];
 	}
 	else {
@@ -225,7 +225,7 @@ rig_data_get_preamp_index    (int data)
 		return -1;
 
 	/* scan through the array */
-	while ((i < MAXDBLSTSIZ) && (preamp[i] != 0)) {
+	while ((i < HAMLIB_MAXDBLSTSIZ) && (preamp[i] != 0)) {
 		if (preamp[i] == data) {
 			return i;
 		}
diff --git a/src/rig-data.h b/src/rig-data.h
index 5e9fc46..7947d09 100644
--- a/src/rig-data.h
+++ b/src/rig-data.h
@@ -190,7 +190,7 @@ typedef struct {
 
 #define GRIG_LEVEL_RD (RIG_LEVEL_RFPOWER | RIG_LEVEL_AGC | RIG_LEVEL_SWR | RIG_LEVEL_ALC | \
                        RIG_LEVEL_STRENGTH | RIG_LEVEL_ATT | RIG_LEVEL_PREAMP | \
-                       RIG_LEVEL_VOX | RIG_LEVEL_AF | RIG_LEVEL_RF | RIG_LEVEL_SQL | \
+                       RIG_LEVEL_VOXDELAY | RIG_LEVEL_AF | RIG_LEVEL_RF | RIG_LEVEL_SQL | \
                        RIG_LEVEL_IF | RIG_LEVEL_APF | RIG_LEVEL_NR | RIG_LEVEL_PBT_IN | \
                        RIG_LEVEL_PBT_OUT | RIG_LEVEL_CWPITCH |          \
                        RIG_LEVEL_MICGAIN | RIG_LEVEL_KEYSPD | RIG_LEVEL_NOTCHF | \
@@ -198,7 +198,7 @@ typedef struct {
                        RIG_LEVEL_VOXGAIN | RIG_LEVEL_ANTIVOX)
 
 #define GRIG_LEVEL_WR (RIG_LEVEL_RFPOWER | RIG_LEVEL_AGC | RIG_LEVEL_ATT | RIG_LEVEL_PREAMP | \
-                       RIG_LEVEL_VOX | RIG_LEVEL_AF | RIG_LEVEL_RF | RIG_LEVEL_SQL | \
+                       RIG_LEVEL_VOXDELAY | RIG_LEVEL_AF | RIG_LEVEL_RF | RIG_LEVEL_SQL | \
                        RIG_LEVEL_IF | RIG_LEVEL_APF | RIG_LEVEL_NR | RIG_LEVEL_PBT_IN | \
                        RIG_LEVEL_PBT_OUT | RIG_LEVEL_CWPITCH |          \
                        RIG_LEVEL_MICGAIN | RIG_LEVEL_KEYSPD | RIG_LEVEL_NOTCHF | \
diff --git a/src/rig-gui-buttons.c b/src/rig-gui-buttons.c
index ae95f4d..6873447 100644
--- a/src/rig-gui-buttons.c
+++ b/src/rig-gui-buttons.c
@@ -283,10 +283,10 @@ rig_gui_buttons_create_att_selector    ()
     /* add ATT OFF ie. 0 dB */
     gtk_combo_box_append_text (GTK_COMBO_BOX (att), _("ATT OFF"));
 
-    /* note: MAXDBLSTSIZ is defined in hamlib; it is the max size of the
+    /* note: HAMLIB_MAXDBLSTSIZ is defined in hamlib; it is the max size of the
         ATT and preamp arrays.
     */
-    while ((i < MAXDBLSTSIZ) && rig_data_get_att_data (i)) {
+    while ((i < HAMLIB_MAXDBLSTSIZ) && rig_data_get_att_data (i)) {
 
         text = g_strdup_printf ("-%d dB", rig_data_get_att_data (i));
         gtk_combo_box_append_text (GTK_COMBO_BOX (att), text);
@@ -343,10 +343,10 @@ rig_gui_buttons_create_preamp_selector    ()
     /* add ATT OFF ie. 0 dB */
     gtk_combo_box_append_text (GTK_COMBO_BOX (preamp), _("PREAMP OFF"));
 
-    /* note: MAXDBLSTSIZ is defined in hamlib; it is the max size of the
+    /* note: HAMLIB_MAXDBLSTSIZ is defined in hamlib; it is the max size of the
         ATT and preamp arrays.
     */
-    while ((i < MAXDBLSTSIZ) && rig_data_get_preamp_data (i)) {
+    while ((i < HAMLIB_MAXDBLSTSIZ) && rig_data_get_preamp_data (i)) {
 
         text = g_strdup_printf ("%d dB", rig_data_get_preamp_data (i));
         gtk_combo_box_append_text (GTK_COMBO_BOX (preamp), text);
diff --git a/src/rig-gui-info.c b/src/rig-gui-info.c
index 53733bf..d73ef2d 100644
--- a/src/rig-gui-info.c
+++ b/src/rig-gui-info.c
@@ -714,7 +714,7 @@ rig_gui_info_create_tunstep_frame  ()
 	/* Create a table with enough rows to show the
 	   max possible number of unique tuning steps.
 	*/
-	table = gtk_table_new (TSLSTSIZ, 2, FALSE);
+	table = gtk_table_new (HAMLIB_TSLSTSIZ, 2, FALSE);
 
 	label = gtk_label_new (NULL);
 	gtk_label_set_markup (GTK_LABEL (label), _("<b>STEP</b>"));
@@ -746,7 +746,7 @@ rig_gui_info_create_tunstep_frame  ()
 	      }
 	*/
 	/* for each available tuning ste */
-	for (i = 0; i < TSLSTSIZ; i++) {
+	for (i = 0; i < HAMLIB_TSLSTSIZ; i++) {
 
 		gboolean firsthit = TRUE;   /* indicates whether found mode is the first one
 					       for the current tuning step. */
@@ -757,7 +757,7 @@ rig_gui_info_create_tunstep_frame  ()
 		*/
 		if (myrig->caps->tuning_steps[i].ts == 0) {
 
-			i = TSLSTSIZ;
+			i = HAMLIB_TSLSTSIZ;
 		}
 		
 		/* otherwise continue */
@@ -853,7 +853,7 @@ rig_gui_info_create_frontend_frame ()
 	text = g_strdup ("");
 
 	/* loop over all available preamp values and concatenate them into a label */
-	for (i = 0; i < MAXDBLSTSIZ; i++) {
+	for (i = 0; i < HAMLIB_MAXDBLSTSIZ; i++) {
 
 		data = rig_data_get_preamp_data (i);
 
@@ -861,7 +861,7 @@ rig_gui_info_create_frontend_frame ()
 		   reached the terminator
 		*/
 		if (data == 0) {
-			i = MAXDBLSTSIZ;
+			i = HAMLIB_MAXDBLSTSIZ;
 		}
 		else {
 			if (i > 0) {
@@ -900,7 +900,7 @@ rig_gui_info_create_frontend_frame ()
 
 	text = g_strdup ("");
 	/* loop over all available attenuator values and concatenate them into a label */
-	for (i = 0; i < MAXDBLSTSIZ; i++) {
+	for (i = 0; i < HAMLIB_MAXDBLSTSIZ; i++) {
 
 		data = rig_data_get_att_data (i);
 
@@ -908,7 +908,7 @@ rig_gui_info_create_frontend_frame ()
 		   reached the terminator
 		*/
 		if (data == 0) {
-			i = MAXDBLSTSIZ;
+			i = HAMLIB_MAXDBLSTSIZ;
 		}
 		else {
 			if (i > 0) {
