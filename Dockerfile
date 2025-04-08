FROM node:16-buster AS builder

WORKDIR /usr/src/app

# Copy only the necessary files to install dependencies first
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Pre-install to avoid issues during copying all the source code
RUN yarn install --immutable

# Now copy the rest of the project
COPY . .

# Set up env and build
COPY .env.build .env
RUN yarn build:deps
RUN yarn build:highmem
RUN yarn workspaces focus --production --all

# --- Final image ---
FROM node:16-alpine

WORKDIR /usr/src/app
COPY --from=builder /usr/src/app ./

EXPOSE 5000
CMD [ "yarn", "start:inject" ]
