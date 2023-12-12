package main

// from example https://github.com/yookoala/gofast
// implements https://github.com/aheimsbakk/container-munin/blob/master/default.conf

import (
	"log"
//	"fmt"
	"net/http"
    "os/exec"
//	"os"
	"context"

	"github.com/yookoala/gofast"
)




/*
 https://guide.munin-monitoring.org/en/latest/reference/munin-cgi-html.html:
 PATH_INFO
 “/”
	refers to the top page.
 “/example.com/”
	refers to the group page for “example.com” hosts.
 “/example.com/client.example.com/”
	refers to the host page for “client.example.com” in the “example.com” group
*/
/*func SetPathInfo(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		p := "/" + r.URL.Path
		r.Params["PATH_INFO"] = p
		h.ServeHTTP(w, r)
		//r2 := new(Request)
		//*r2 = *r
		//r2.URL = new(url.URL)
		//*r2.URL = *r.URL
		//r2.URL.Path = p
		//h.ServeHTTP(w, r2)
	})
}*/


// next thing to try: https://pkg.go.dev/net/http/cgi

func SetPathInfo(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Add your additional parameter to the request context
		pathInfo := r.URL.Path
		ctx := context.WithValue(r.Context(), "PATH_INFO", pathInfo)
		log.Output(1, "P:" + pathInfo)

		// Create a new request with the updated context
		r = r.WithContext(ctx)

		// Call the next handler in the chain
		next.ServeHTTP(w, r)
	})
}



// spawn-fcgi -s /var/run/munin/fastcgi-graph.sock -U nginx -u munin -g munin -- /usr/share/webapps/munin/cgi/munin-cgi-graph
// spawn-fcgi -s /var/run/munin/fastcgi-html.sock -U nginx -u munin -g munin -- /usr/share/webapps/munin/cgi/munin-cgi-html


func SpawnProcess(prefix string, h http.Handler) http.Handler {
	cgistarted := true //T
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if (!cgistarted) {
		    cmd := exec.Command("spawn-fcgi", "-s", "/var/run/munin/fastcgi-html.sock", "-U", "nginx", "-u", "munin", "-g", "munin", "--", "/usr/share/webapps/munin/cgi/munin-cgi-html")
			err := cmd.Run()
			if err != nil {
				log.Fatal(err)
			}
			cgistarted = true
		}
		h.ServeHTTP(w, r)
	})
}

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
	http.Handle("/munin-cgi/munin-cgi-graph/", http.StripPrefix("/munin-cgi/munin-cgi-graph", SetPathInfo(gofast.NewHandler(
		gofast.NewFileEndpoint("/var/www/html")(gofast.BasicSession),
		gofast.SimpleClientFactory(connFactory1),
	))))
    //location /munin/ {
    //    fastcgi_split_path_info ^(/munin)(.*);
    //    fastcgi_param PATH_INFO $fastcgi_path_info;
    //    fastcgi_pass unix:/var/run/munin/fastcgi-html.sock;
    //    include fastcgi_params;
    //}




	connFactory2 := gofast.SimpleConnFactory("unix", "/var/run/munin/fastcgi-html.sock")
	http.Handle("/munin/", http.StripPrefix("/munin", SetPathInfo(gofast.NewHandler(
		gofast.NewFileEndpoint("/var/www/html")(gofast.BasicSession),
		gofast.SimpleClientFactory(connFactory2),
	))))

	// serve at 8080 port
	log.Fatal(http.ListenAndServe(":8080", nil))
}
