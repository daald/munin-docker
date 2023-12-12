package main

// from example https://github.com/yookoala/gofast
// implements https://github.com/aheimsbakk/container-munin/blob/master/default.conf

import (
	"log"
//	"fmt"
	"net/http"
//	"os"

	"github.com/yookoala/gofast"
)

func main() {
	// Get fastcgi application server tcp address
	// from env FASTCGI_ADDR. Then configure
	// connection factory for the address.
	//address := os.Getenv("FASTCGI_ADDR")

	// handles static assets in the assets folder
    //location /munin/static/ {
    //    alias /etc/munin/static/;
    //}
	http.Handle("/munin/static/",
		http.StripPrefix("/munin/static/",
			http.FileServer(http.FileSystem(http.Dir("/etc/munin/static/")))))

	// route all requests to relevant PHP file
    //location ^~ /munin-cgi/munin-cgi-graph/ {
    //    fastcgi_split_path_info ^(/munin-cgi/munin-cgi-graph)(.*);
    //    fastcgi_param PATH_INFO $fastcgi_path_info;
    //    fastcgi_pass unix:/var/run/munin/fastcgi-graph.sock;
    //    include fastcgi_params;
    //}
	connFactory1 := gofast.SimpleConnFactory("unix", "/var/run/munin/fastcgi-graph.sock")
	http.Handle("/munin-cgi/munin-cgi-graph/", http.StripPrefix("/munin-cgi/munin-cgi-graph/", gofast.NewHandler(
		gofast.NewFileEndpoint("/var/www/html")(gofast.BasicSession),
		gofast.SimpleClientFactory(connFactory1),
	)))
    //location /munin/ {
    //    fastcgi_split_path_info ^(/munin)(.*);
    //    fastcgi_param PATH_INFO $fastcgi_path_info;
    //    fastcgi_pass unix:/var/run/munin/fastcgi-html.sock;
    //    include fastcgi_params;
    //}
	connFactory2 := gofast.SimpleConnFactory("unix", "/var/run/munin/fastcgi-html.sock")
	http.Handle("/munin/", http.StripPrefix("/munin/", gofast.NewHandler(
		gofast.NewFileEndpoint("/var/www/html")(gofast.BasicSession),
		gofast.SimpleClientFactory(connFactory2),
	)))

	// serve at 8080 port
	log.Fatal(http.ListenAndServe(":8080", nil))
}
