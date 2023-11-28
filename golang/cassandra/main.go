package main

import (
	"fmt"
	"time"

	"github.com/gocql/gocql"
)

func main() {
	cluster := gocql.NewCluster("localhost")
	cluster.ConnectTimeout = time.Second * 3
	cluster.Keyspace = "example"
	cluster.Consistency = gocql.Quorum
	session, _ := cluster.CreateSession()
	defer session.Close()

	for {
		if err := session.Query("DESCRIBE keyspaces;").Exec(); err != nil {
			fmt.Println("Test DB not oke !", err)
		}
		fmt.Println("Test DB oke !")
		time.Sleep(5 * time.Second)
	}
}

// DESCRIBE keyspaces;
