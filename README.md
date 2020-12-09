# NflRushing

## App Overview

![App Diagram](./app_overview.png?raw=true "App Diagram")

1. The application starts the DataManager GenServer to load in the data from `rushing.json`
2. The LiveView client will interact with the DataManager api to get the latest data
3. The DataManager utilizes the Rushing module for the heavy lifting for data processing

## Install Gudie

### Run using docker
To start your Phoenix server:

  1. Build the image `docker-compose build`
  2. Create and run a container `docker-compose up`
  3. Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Run locally
To start your Phoenix server:

  1. Install dependencies with `mix deps.get`
  2. Install Node.js dependencies with `npm install` inside the `assets` directory
  3. Start Phoenix endpoint with `mix phx.server`
  4. Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
