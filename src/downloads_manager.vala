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

    public class Download: GLib.Object {

        public signal void started();
        public signal void progress_changed(int size);
        public signal void finished();
        public signal void cancelled();

        public int current_size;
        public int total_size;

        public string uri;
        public string path;

        public WebKit.Download download;

        public Download(WebKit.Download download) {
            this.download = download;
            this.path = GLib.Path.build_filename(Ontis.get_download_dir(), this.get_filename());

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

        public string get_uri() {
            return this.download.get_uri();
        }

        public string get_destination_file() {
            return this.path;
        }

        public string get_estimated_time() {
            return this.download.get_elapsed_time().to_string();
        }

        public void stop() {
            this.download.cancel();
        }

        public void pause() {
        }

        public void unpause() {
        }

        private void status_changed_cb(GLib.ParamSpec paramspec) {
            var status = this.download.get_status();
            this.total_size = (int)this.download.get_total_size();

            switch(status) {
                case WebKit.DownloadStatus.ERROR:
                    break;

                case WebKit.DownloadStatus.CREATED:
                    //("download created\n");
                    break;

                case WebKit.DownloadStatus.STARTED:
                    break;

                case WebKit.DownloadStatus.CANCELLED:
                    this.cancelled();
                    break;

                case WebKit.DownloadStatus.FINISHED:
                    this.finished();
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

        public signal void new_download(Ontis.Download download);

        public GLib.List<Ontis.Download> downloads;

        public DownloadManager() {
            this.downloads = new GLib.List<Ontis.Download>();
        }

        public void add_download(WebKit.Download d) {
            Ontis.Download download = new Ontis.Download(d);
            downloads.append(download);
            this.new_download(download);
        }
    }
}
