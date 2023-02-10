# Use an official Node.js image as the base image for building the application
FROM node:14 AS build

# Set the working directory in the container to /app
WORKDIR /app

# Copy the package.json file to the container
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the rest of the project files to the container
COPY . .

# Build the Angular project
RUN npm run build

# Use a smaller base image for the final image
FROM node:14-alpine

# Set the working directory in the container to /app
WORKDIR /app

RUN npm install -g @angular/cli

# Copy the built artifacts from the build stage
COPY --from=build /app /app

# Expose port 4200 on the container
EXPOSE 4200

# Set the default command to run when the container starts
CMD [ "ng", "serve","--host","0.0.0.0" ]