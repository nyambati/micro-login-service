# Guest Login Service

![microservice login flow](https://user-images.githubusercontent.com/32780926/40916035-ea28e4f0-6806-11e8-9cb3-4c0485416c95.jpg)

![micrologin flow 2](https://user-images.githubusercontent.com/32780926/40915981-b12bcdc0-6806-11e8-9406-81c757385d2a.jpg)

#### RSA PUBLIC KEY

```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu/PXShcrLcoKYYr6sAuU
GPjmb0qSwo5aYDjnXJ2fWbzeC+PadR2n6Pn9vWwZzOv6nSM5ocVNNRpAyHvT0mQf
7DikDJANSwpQHwYpKkgdBDydzMeOBhFpkhLeUOfnF4a/sfB8OP+/PvW5vsRhx4WR
+1PZDFXuCq/AbcBuzBsNJ8Q3gmB2/m7VeltIb5QXIs5zHCFC0tLS/WCNYfcfhviW
7sz3qVSggrhEs2SgpvMBwiQHwNkP7/vfrNl6pKctLTvibdlWfF9JiER+a8Eq/Dge
Snt70Gtn5rQnkN08DNLfxjiSskzef8pNh+9H5oI7Ee5UJpIOEyQ7p+XzEDzT1zy5
TQIDAQAB
-----END PUBLIC KEY-----
```

#### Validate JWT Origin Example

```
 def valid_learner_token(token)
    cert = OpenSSL::PKey::RSA.new Figaro.env.public_key
    valid = JWT.decode token, cert, true, algorithm: "RS256"
    valid ? true : false
  end
```

#### Important Endpoints

```
/invites # For forgot password and setting up
/users/login # For login with email and password
/auth/google_oauth2 # For google auth
```

#### Making Requests From The App

Please generate an access token `/users/generate_access_token` to use to make requests with your app for persistency as JWT expire

An Api login service to login learners and aspiring andelans into andela platforms i.e Vof Tracker

#### Api docs in `Api.md`

## External Dependencies

This web application is written with Ruby using the Ruby on Rails framework and a PostgreSQL database.

To install Ruby visit [Ruby Lang](https://www.ruby-lang.org). [v2.4.0]

To install Rails visit [Ruby on Rails](http://rubyonrails.org/). [v5.0.1]

Install [RubyGems](https://rubygems.org/) and [Bundler](http://bundler.io/) to help you manage dependencies in your [Gemfile](Gemfile).

To install PostgreSQL visit [Postgres app](http://postgresapp.com/).

## Installation

- Once you have Ruby, Rails and PostgreSQL installed. Take the following steps to install the application:

1.  Run `git clone https://github.com/andela/micro-login-service.git` to clone this repository

2.  Run `bundle install` to install all required gems

## Env file setup

1.  Create a file in the root directory called `.env`

2.  open it and add the following to it.

```
POSTGRES_USER: 'your username'
POSTGRES_PASSWORD: 'your password'
POSTGRES_HOST: 'localhost'
POSTGRES_DB: 'micro_login_db'
POSTGRES_TEST_DB: 'micro_login_test'
GMAIL_USERNAME: 'your gmail username'
GMAIL_PASSWORD: 'your gmail password'
GOOGLE_CLIENT_ID: 'your google client id'
GOOGLE_CLIENT_SECRET: 'your google client secret'
DOMAIN_DEVELOPMENT: 'http://localhost:3000'
```

## Database

#### Configuring the database

run
`$ rails db:setup`

## Tests

- Run test with `rspec spec`

## Limitations

- Login Service is still in development

## Coding Style

Refer to this links below for our coding style:

- https://github.com/bbatsov/ruby-style-guide
- https://github.com/bbatsov/rails-style-guide

## How to Contribute

- Fork this repository
- Clone it.
- Create your feature branch on your local machine with `git checkout -b your-feature-branch`
- Push your changes to your remote branch with `git push origin your-feature-branch` ensure you avoid redundancy in your commit messsage.
- Open a pull request to the `develop` branch and describe how your feature works
- Refer to this wiki for proper <a href="https://github.com/andela/engineering-playbook/blob/master/conventions.md">GIT CONVENTION</a>

```

```
