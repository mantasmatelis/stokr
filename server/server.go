package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"github.com/gorilla/schema"
	"github.com/julienschmidt/httprouter"
	"github.com/lionelbarrow/braintree-go"
_ "github.com/lib/pq"
	"log"
	"net/http"
	"net/url"
	"strings"
	"runtime/debug"
)

//CREATE TABLE users (id INTEGER PRIMARY KEY, email TEXT, password TEXT, braintree_customer_id TEXT, credit INTEGER)

var db *sql.DB
var servers map[string]bool
var bt *braintree.Braintree


func Index(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	defer recovery()
	http.ServeFile(w, r, "static/index.html")
}

func Static(w http.ResponseWriter, r *http.Request) {
	defer recover()
	fmt.Println(r.URL.Path)
	http.ServeFile(w, r, "public" + r.URL.Path)
}

type RegisterReq struct {
	Email          string
	Password       string
	SteamUser	string
	SteamPassword	string
	BraintreeNonce string
}

func recovery() {
	if err := recover(); err != nil {
		log.Println(err)
		debug.PrintStack()
		return
	}
}

func Register(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	defer recovery()
	err := r.ParseForm()
	fmt.Printf("%v\n", r.Form)

	if err != nil {
		w.WriteHeader(400)
		return
	}

	regReq := new(RegisterReq)
	decoder := schema.NewDecoder()
	if decoder.Decode(regReq, r.Form) != nil {
		w.WriteHeader(400)
		return
	}
	
	if regReq.Email == "" || regReq.SteamUser == "" || regReq.SteamPassword == "" || regReq.Password == "" || regReq.BraintreeNonce == "" {
		w.WriteHeader(400)
		return
	}
	

	selStmt, err := db.Prepare("SELECT id FROM users WHERE lower(email) = lower($1);")
	if err != nil {
		fmt.Println("SELECT")
		log.Fatal(err)
	}
	defer selStmt.Close()
	rows, err := selStmt.Query(regReq.Email)
	if err != nil {
		log.Fatal(err)
	}
	if rows.Next() {
		w.WriteHeader(403)
		return
	}

	customer := new(braintree.Customer)
	customer.CreditCard = &braintree.CreditCard{PaymentMethodNonce:regReq.BraintreeNonce}
	customer, err = bt.Customer().Create(customer)

	if err != nil {
		log.Fatal(err)
	}

	log.Println("Creating TRANSACTION")
//	t := &braintree.Transaction{Customer:customer, Amount:braintree.NewDecimal(5, 0), Type: "sale"}
//	t, err = bt.Transaction().Create(t)

_, err = bt.Transaction().Create(&braintree.Transaction{
  Type: "sale",
  Amount: braintree.NewDecimal(5, 0),
  CreditCard: &braintree.CreditCard{
    Number:         "4500600000000061",
    ExpirationDate: "05/16",
  },
})
	if err != nil {
		log.Fatal(err)
	}
	log.Println("CREATED")

	stmt, err := db.Prepare("INSERT INTO users(email, password, steam_user, steam_password, braintree_customer_id, credit) values ($1, $2, $3, $4, $5, $6)")
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()

	_, err = stmt.Exec(regReq.Email, regReq.Password, regReq.SteamUser, regReq.SteamPassword, customer.Id, 0) 
	if err != nil {
		log.Fatal(err)
	}

}

type LoginReq struct {
	Email         string
	Password      string
}

func Login(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	defer recovery()
	err := r.ParseForm()

	if err != nil {
		w.WriteHeader(400)
		return
	}

	loginReq := new(LoginReq)
	decoder := schema.NewDecoder()
	if decoder.Decode(loginReq, r.PostForm) != nil {
		w.WriteHeader(400)
		return
	}

	stmt, err := db.Prepare("SELECT email, credit, steam_user, steam_password FROM users WHERE email = $1 AND password = $2")
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()

	var email string
	var credit int
	var steam_user string
	var steam_password string

	err = stmt.QueryRow(loginReq.Email, loginReq.Password).Scan(&email, &credit, &steam_user, &steam_password)
	switch {
	case err == sql.ErrNoRows:
		log.Printf("No user with that id")
		w.WriteHeader(404)
		return
	case err != nil:
		log.Fatal(err)
	}

	for k, v := range servers {
		if !v {
			//servers[k] = true
			resp, err := http.PostForm("http://"+k+"/start", url.Values{"SteamUser": {steam_user}, "SteamPassword": {steam_password}})

			if err != nil {
				log.Fatal(err)
			}
			defer resp.Body.Close()

			js, _ := json.Marshal(map[string]string{"Ip": k, "Username": "Administrator", "Password": "hardcoded"})
	
			w.Header().Add("Content-Type", "application/json")
			w.Write(js)
			return
		}
	}
	w.WriteHeader(503)
	fmt.Println("ALL SERVERS BUSY")

	//GO THREAD WATCHING THE BILLING SHIT, LATER
}

func Disconnect(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	defer recovery()
	ip := strings.Split(r.RemoteAddr, ":")[0]
	servers[ip] = false
	w.WriteHeader(200)
}

func ClientNonce(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	defer recovery()
	token, err := bt.ClientToken().Generate()

	if err != nil {
		log.Fatal(err)
	}
	w.Write([]byte(token))
}

func main() {
	defer recovery()
	router := httprouter.New()
	router.POST("/api/clientToken", ClientNonce)
	router.POST("/api/register", Register)
	router.POST("/api/login", Login)
	router.POST("/api/disconnect", Disconnect)
	
	log.Println("Starting...")

	router.NotFound = http.HandlerFunc(Static)

	var err error
	db, err = sql.Open("postgres", "user=stokr dbname=stokr password=stokr123")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	bt = braintree.New(braintree.Sandbox, "67hhssgvxktqxnhp", "mj4sg5njfzmbb324", "73d27504ef63420cfcf8ef2af27953a5")

	servers = make(map[string]bool)
	servers["54.88.148.109"] = false

	log.Fatal(http.ListenAndServe(":80", router))
}
