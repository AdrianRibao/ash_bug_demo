# Helpdesk

This is a basic project to demostrate the [bug](https://github.com/ash-project/ash/issues/1842) for the Ash framework.

Steps to reproduce:

1. Clone the project
2. Start Postgres: `docker-compose up`
3. Run the setup command: `mix setup`
4. Start the Phoenix server: `mix phx.server`
5. Go to `http://localhost:4000/services/new` and create a new service.
6. Edit the server and click save. You will see the error.

The error is there also when updating the Service from `iex`.

The domain is `bookings` and the resources are:

* `Helpdesk.Bookings.Service`: The "parent" resource.
* `Helpdesk.Bookings.Stage`: The embedded resource.
