package main

import (
	"log"
	"net/http"
	"net/http/cgi"
)

func CgiHandler(cgiPath string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Add your additional parameter to the request context
		pathInfo := r.URL.Path
		log.Output(1, cgiPath + " >> " + pathInfo)

		// Call the next handler in the chain
		handler := cgi.Handler{Path: cgiPath}
		handler.Env = append(handler.Env, "PATH_INFO=" + pathInfo)
		handler.Env = append(handler.Env, "HOME=/home/httpd")
		handler.ServeHTTP(w, r)
	})
}

func main() {
	// handles static assets in the assets folder
	http.Handle("/munin/static/",
		http.StripPrefix("/munin/static/",
			http.FileServer(http.FileSystem(http.Dir("/etc/munin/static/")))))

	// route all requests to relevant CGI

	// see https://guide.munin-monitoring.org/en/latest/reference/munin-cgi-html.html
	http.Handle("/munin/",
		http.StripPrefix("/munin",
			CgiHandler("/usr/share/webapps/munin/cgi/munin-cgi-html")))
	// see https://guide.munin-monitoring.org/en/latest/reference/munin-cgi-graph.html
	http.Handle("/munin-cgi/munin-cgi-graph/",
		http.StripPrefix("/munin-cgi/munin-cgi-graph",
			CgiHandler("/usr/share/webapps/munin/cgi/munin-cgi-graph")))

	// serve at 8080 port
	log.Fatal(http.ListenAndServe(":8080", nil))
}
