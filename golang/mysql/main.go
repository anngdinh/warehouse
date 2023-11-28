package main

import (
	"database/sql"
	"fmt"
	"log"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

func main() {

	db, err := sql.Open("mysql", "annd2:password@tcp(127.0.0.1:3306)/mysql")
	defer db.Close()

	if err != nil {
		log.Fatal(err)
	}

	for {
		var version string

		err2 := db.QueryRow("SELECT VERSION()").Scan(&version)

		if err2 != nil {
			fmt.Println(err2)
		}

		fmt.Println(version)

		time.Sleep(5 * time.Second)
	}

}
