# builder image
FROM amd64/golang:1.19 as builder
WORKDIR /build
ADD . /build
RUN go mod init main
RUN go mod tidy
RUN go get all
RUN go get github.com/go-sql-driver/mysql
# RUN ls -a -l
# RUN go build ./main.go
ENTRYPOINT [ "go", "run", "main.go" ]

# # generate clean, final image for end users
# FROM ubuntu:22.04
# WORKDIR /app
# COPY --from=builder /build/main .
# # RUN apt-get update && apt-get install curl -y

# RUN ls -a -l
# RUN chmod u+x main
# # executable
# ENTRYPOINT [ "/app/main" ]
