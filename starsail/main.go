package main

import (
	"log"
	"net/http"
	"os"
	"time"

	"github.com/joho/godotenv"
	"github.com/urfave/negroni"
	"wanderer.starsail/pages"
)

func main() {
	// Configuration Environment
	// 0 -> Production
	// 1 -> Dev
	// We don't need .env file for production because we load from the
	// docker image environment when we deploy
	dev := os.Getenv("DEV")
	if len(dev) >= 0 {
		log.Println("Loaded DEV Environment!")
		godotenv.Load("dev.env")
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/", pages.Home)

	n := negroni.Classic()
	n.UseHandler(mux)

	serverConfiguration := &http.Server{
		Addr:           os.Getenv("ADDR"),
		Handler:        n,
		ReadTimeout:    10 * time.Second,
		WriteTimeout:   10 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}

	log.Fatal(serverConfiguration.ListenAndServe())
}
