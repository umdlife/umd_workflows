FROM summerwind/actions-runner:ubuntu-22.04
USER 0
RUN apt update && apt install -y --no-install-recommends clang-format npm
RUN npm install -g semver
USER runner


ENTRYPOINT ["/bin/bash", "-c"]
CMD ["entrypoint.sh"]
