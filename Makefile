VALAC = valac
VAPIS = --vapidir=./vapis

VALAPKG = --pkg gtk+-3.0 \
          --pkg webkitgtk-3.0 \
          --pkg libsoup-2.4 \
          --pkg json-glib-1.0

SRC = src/consts.vala\
      src/cache.vala \
      src/downloads_manager.vala \
      src/down_panel.vala \
      src/newtab_view.vala \
      src/history_view.vala \
      src/ontis.vala \
      src/view.vala \
      src/downloads_view.vala \
      src/web_view.vala \
      src/utils.vala \
      src/notebook.vala \
      src/toolbar.vala \
      src/bookmarks_bar.vala \
      src/settings_manager.vala \
      src/settings_view.vala \
      src/base_view.vala \
      src/window.vala

OPTIONS = -X -lm -X -w

BIN = ontis

all:
	$(VALAC) $(VAPIS) $(VALAPKG) $(SRC) $(OPTIONS) -o $(BIN)

clean:
	rm -f $(BIN)
