FROM docker.io/rust:slim-trixie AS chef
RUN cargo install cargo-chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
RUN apt-get update && apt-get install -y pkg-config libssl-dev git
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN RUSTFLAGS="-C strip=symbols" cargo build --release

FROM docker.io/debian:stable-slim
WORKDIR /home/nonroot
COPY --from=builder /app/target/release/ironclaw /ironclaw
ENTRYPOINT ["/ironclaw"]
