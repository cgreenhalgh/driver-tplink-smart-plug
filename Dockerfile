FROM golang:1.8.3-alpine3.6 as gobuild
WORKDIR /
ENV GOPATH="/"
RUN apk update && apk add git
COPY . .
RUN go get -u github.com/gorilla/mux
RUN go get -u golang.org/x/net/websocket
RUN go get -u github.com/me-box/lib-go-databox
RUN go get -u github.com/sausheong/hs1xxplug
RUN addgroup -S databox && adduser -S -g databox databox
RUN GGO_ENABLED=0 GOOS=linux go build -a -tags netgo -installsuffix netgo -ldflags '-d -s -w -extldflags "-static"' -o app /src/app.go

FROM scratch
COPY --from=gobuild /etc/passwd /etc/passwd
USER databox
WORKDIR /root
COPY --from=gobuild /app .
COPY --from=gobuild /www/ /root/www/
COPY --from=gobuild /tmpl/ /root/tmpl/
LABEL databox.type="driver"
EXPOSE 8080

CMD ["./app"]
#CMD ["sleep","2147483647"]
