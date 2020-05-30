# Find and replace:
#    wordpressexample.com = your domain
#    0.0.0.0 = Your public IP

acl purger {
        "localhost";
        "0.0.0.0"; # Public IP
}


sub vcl_recv {

        if (req.method == "PURGE") {
                if (!client.ip ~ purger) {
                        return(synth(405, "This IP is not allowed to send PURGE requests."));
                }
                return (purge);
        }

        if (req.http.Authorization || req.method == "POST") {
                return (pass);
        }

        if (req.url ~ "/feed") {
                return (pass);
        }

    #if (req.http.host == "wordpressexample.com") {
        # ignore all cookies on a WP site without comments (except for admin areas)
                #if (req.url !~ "^/wp-(login|admin)") {
                #       unset req.http.cookie;
                #}
        #}
        if (req.http.host == "wordpressexample.com") {
                if (req.url ~ "/(wp-admin|wp-login|cart|my-account|checkout|addons|/?add-to-cart=)") {
                        return (pass);
                }
        }

        set req.http.cookie = regsuball(req.http.cookie, "wp-settings-\d+=[^;]+(; )?", "");

        set req.http.cookie = regsuball(req.http.cookie, "wp-settings-time-\d+=[^;]+(; )?", "");

        set req.http.cookie = regsuball(req.http.cookie, "wordpress_test_cookie=[^;]+(; )?", "");

        if (req.http.cookie == "") {
                unset req.http.cookie;
        }

}

sub vcl_backend_response {
        set beresp.ttl = 24h;
        set beresp.grace = 1h;
        #if (bereq.url !~ "wp-admin|wp-login|product|cart|checkout|my-account|/?remove_item=") {
        #       unset beresp.http.set-cookie;
        #}
}

sub vcl_purge {
        set req.method = "GET";
        set req.http.X-Purger = "Purged";
        return (restart);
}

sub vcl_deliver {
        if (req.http.X-Purger) {
                set resp.http.X-Purger = req.http.X-Purger;
        }