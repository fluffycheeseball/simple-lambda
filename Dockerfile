FROM golang:1.16.2-alpine as builder
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Create a directory and its parents in our container 
RUN mkdir -p /go/src/github.com/jude
# Copy the contents of the src folder on the host to it
ADD ./src /go/src/github.com/jude
# Tell docker to use this folder as its working directory
WORKDIR /go/src/github.com/jude

# CGO_ENABLED allows go code to be cross compiled with C code eg on android device. Not required for linux
# -s = Flags for the Go linker.-s = Tells Go linker to omit the symbol table and debug information. See https://golang.org/cmd/link/
# -o = output filename. See https://golang.org/cmd/go/
# -a = force rebuilding of packages that are already up-to-date See https://golang.org/cmd/go/
RUN CGO_ENABLED=0 go build -a -ldflags '-s' -o api .

# run the output file
CMD [ "./api" ] 



