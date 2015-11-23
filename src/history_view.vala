/*
Copyright (C) 2015, Cristian García <cristian99garcia@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

namespace Ontis {

    public class HistoryView: Ontis.BaseView {

        public signal void open_url(string url);

        public Gtk.ListBox listbox;

        public HistoryView() {
            this.listbox = new Gtk.ListBox();
            this.listbox.set_selection_mode(Gtk.SelectionMode.NONE);
            this.scroll.add(this.listbox);

            this.update.connect(this.update_cb);
            this.search_entry.changed.connect(this.update_cb);
        }

        public void update_cb(GLib.Object widget) {
            GLib.Idle.add(() => { this.update2(); return false; });
        }

        public void update2() { //string search="") {
            string search = this.search_entry.get_text().down();

            foreach (Gtk.Widget lrow in this.listbox.get_children()) {
                this.listbox.remove(lrow);
            }

            Json.Array history = Utils.get_history();
            GLib.List<unowned Json.Node> elements = history.get_elements();
            elements.reverse();

            int current = 0;

            foreach (Json.Node node in elements) {
                if (current > this.max) {
                    break;
                }

                current ++;

                string data = node.dup_string();
                string date = data.split(" ")[0].down();
                string time = data.split(" ")[1].down();
                string name = data.split(" ")[2].down();
                string url = data.split(" ")[3].down();

                if (search != "") {
                    if (!(search in name) || !(search in url)) {
                        continue;
                    }
                }

                Gtk.ListBoxRow row = new Gtk.ListBoxRow();
                this.listbox.add(row);

                Gtk.Box hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
                row.add(hbox);

                Gtk.CheckButton cbutton = new Gtk.CheckButton();
                cbutton.set_label("%s %s".printf(date, time));
                hbox.pack_start(cbutton, false, false, 0);

                Gtk.LinkButton lbutton = new Gtk.LinkButton.with_label(url, name + " " + url);
                lbutton.set_visited(false);
                lbutton.activate_link.connect(this.open_link);
                hbox.pack_start(lbutton, false, false, 0);
            }

            this.show_all();
        }

        private bool open_link(Gtk.LinkButton button) {
            this.open_url(button.get_uri());
            return true;
        }
    }
}
