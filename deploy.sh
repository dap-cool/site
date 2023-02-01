#!/usr/bin/env sh

aws s3 sync ./target/deploy/ s3://deployment.dap.cool/target/deploy/ --profile tap-in
