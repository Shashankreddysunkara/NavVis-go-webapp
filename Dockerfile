FROM golang:1.18rc1-alpine3.15
LABEL maintainer="Shashank Reddy Sunkara"

# Set the Current Working Directory inside the container
RUN apk add --no-cache git \
    && apk add --update alpine-sdk \
    && mkdir /app

# Copy everything from the current directory to the PWD (Present Working Directory) inside the container
COPY . /app/.

WORKDIR /app

# Build all the dependencies
RUN go build -o main .

# This container exposes port 8080 to the outside world
EXPOSE 8080

# Run the executable
CMD ["/app/main"]
