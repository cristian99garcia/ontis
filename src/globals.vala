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

enum LoadState {
    LOADING,
    FINISHED,
}

public string get_work_dir() {
    return GLib.Path.build_filename(GLib.Environment.get_user_config_dir(), "ontis");
}

public string get_favicons_path() {
    return GLib.Path.build_filename(get_work_dir(), "favicons");
}

public string get_history() {
    return GLib.Path.build_filename(get_work_dir(), "history.json");
}

public string search_in_google(string search) {
    string text = search.replace(" ", "+");
    return "https://www.google.com.uy/?gws_rd=cr&ei=vRJEVaPsNImlgwSh44DYBA#q=%s".printf(text);
}

public string get_favicon_name(string uri) {
    return uri.replace("//", ";;").split("/")[0];
}

public string get_favicon_file(string uri) {
    return GLib.Path.build_filename(get_favicons_path(), get_favicon_name(uri));
}

public bool check_needs_download_favicon(string uri) {
    var directory = File.new_for_path(get_favicons_path());
    var enumerator = directory.enumerate_children(FileAttribute.STANDARD_NAME, 0);
    FileInfo file_info;
    bool in_dir = false;
    string icon_name = get_favicon_name(uri);

    while((file_info = enumerator.next_file()) != null && !in_dir) {
        in_dir = file_info.get_name() == icon_name;
    }

    return in_dir;
}

public string parse_uri(string uri) {
    string url;

    if (" " in uri || !("." in uri) && !("/" in uri)) {
        url = search_in_google(uri);
    } else {
        if (!("http://" in uri) && !("https://" in uri) && !("ftp://" in uri) && !("file:///" in uri)) {
            url = "https://" + uri;
        } else {
            url = uri;
        }
    }

    return url;
}

public Gtk.Image get_image_from_name(string icon, int size=24) {
    try {
        var screen = Gdk.Screen.get_default();
        var theme = Gtk.IconTheme.get_for_screen(screen);
        var pixbuf = theme.load_icon(icon, size, Gtk.IconLookupFlags.FORCE_SYMBOLIC);

        if (pixbuf.get_width() != size || pixbuf.get_height() != size) {
            pixbuf = pixbuf.scale_simple(size, size, Gdk.InterpType.BILINEAR);
        }

        return new Gtk.Image.from_pixbuf(pixbuf);
    }
    catch (GLib.Error e) {
        return new Gtk.Image();
    }
}

public void save_to_history(string uri, string name) {
}

public void check_paths() {
}

public string get_download_dir() {
    return GLib.Environment.get_user_special_dir(GLib.UserDirectory.DOWNLOAD);
}

public class FaviconDownloader: GLib.Object {

    public signal void finish();

    public string favicon_url;
    public string website_url;
    public string name;

    public FaviconDownloader(string favicon_url, string website_url) {
        check_paths();

        this.favicon_url = favicon_url;
        this.website_url = website_url;
        this.name = get_favicon_name(this.website_url);
        this.download();
    }

    private void download() {
    //    path = os.path.join(FAVICONS_PATH, this.name)
    //    response = urlretrieve(this.favicon_url, path)
    //    this.finish();
    }
}

public class Download: GLib.Object {

    public signal void start();
    public signal void progress_changed(int size);
    public signal void finish();

    public int current_size;
    public int total_size;

    public string uri;
    public string path;

    public WebKit.Download download;

    public Download(WebKit.Download download) {
        this.download = download;
        this.path = GLib.Path.build_filename(get_download_dir(), this.get_filename());

        this.uri = this.download.get_uri();
        this.download.set_destination_uri("file://" + this.path);
        this.download.notify["status"].connect(this.status_changed_cb);
        this.download.notify["current-size"].connect(this.current_size_changed_cb);
    }

    public void start_now() {
        //this.download.start();
    }

    public string get_filename() {
        return this.download.get_suggested_filename();
    }

    public int get_total_size() {
        return this.total_size;
    }

    private void status_changed_cb(GLib.ParamSpec paramspec) {
        var status = this.download.get_status();
        this.total_size = (int)this.download.get_total_size();

        switch(status) {
            case WebKit.DownloadStatus.ERROR:
                break;

            case WebKit.DownloadStatus.CREATED:
                stdout.printf("download created\n");
                break;

            case WebKit.DownloadStatus.STARTED:
                break;

            case WebKit.DownloadStatus.CANCELLED:
                stdout.printf("download cacelled\n");
                break;

            case WebKit.DownloadStatus.FINISHED:
                this.finish();
                break;
        }
    }

    private void current_size_changed_cb(GLib.ParamSpec paramspec) {
        this.current_size = (int)this.download.get_current_size();
        if (this.current_size != this.total_size) {
            this.progress_changed(this.current_size);
        }
    }
}

public class DownloadManager: GLib.Object {

    public signal void new_download(Download download);

    GLib.List<Download> downloads;

    public DownloadManager() {
        this.downloads = new GLib.List<Download>();
    }

    public void add_download(WebKit.Download d) {
        Download download = new Download(d);
        downloads.append(download);
        //connect signals;
        this.new_download(download);
    }
}

